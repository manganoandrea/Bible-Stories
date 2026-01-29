# Book Opening Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement two-page spread effect, depth zoom transition, and add book titles to library thumbnails.

**Architecture:** Extend existing animation phase state machine with zooming phases, add UIImage splitting utility, modify Book3DView to render split pages with gutter shadow, and enhance BookCoverView with title overlays.

**Tech Stack:** SwiftUI, UIKit (UIImage processing), iOS 17+ Observation framework

---

## Task 1: Add Book Title to Library Thumbnails

**Files:**
- Modify: `BibleStories/Features/Library/BookCoverView.swift`

**Step 1: Add title overlay to BookCoverView**

Update the `coverImage` computed property to include a title overlay at the bottom:

```swift
@ViewBuilder
private var coverImage: some View {
    if let uiImage = UIImage(named: book.coverImage) {
        ZStack(alignment: .bottom) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 280)
                .clipped()

            // Title overlay
            VStack {
                Spacer()
                Text(book.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .frame(width: 200, height: 280)
    } else {
        // Keep existing placeholder unchanged
        ...
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 3: Commit**

```bash
git add BibleStories/Features/Library/BookCoverView.swift
git commit -m "feat: add book title overlay to library thumbnails"
```

---

## Task 2: Create UIImage Split Extension

**Files:**
- Create: `BibleStories/Extensions/UIImage+Split.swift`

**Step 1: Create the extension file**

```swift
//
//  UIImage+Split.swift
//  BibleStories
//
//  Utility for splitting images into left and right halves for book spread effect.
//

import UIKit

extension UIImage {
    /// Returns the left half of the image
    func leftHalf() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let halfWidth = cgImage.width / 2
        let cropRect = CGRect(x: 0, y: 0, width: halfWidth, height: cgImage.height)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }

    /// Returns the right half of the image
    func rightHalf() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let halfWidth = cgImage.width / 2
        let cropRect = CGRect(x: halfWidth, y: 0, width: cgImage.width - halfWidth, height: cgImage.height)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 3: Commit**

```bash
git add BibleStories/Extensions/UIImage+Split.swift
git commit -m "feat: add UIImage split extension for book spread effect"
```

---

## Task 3: Add Zooming Animation Phases

**Files:**
- Modify: `BibleStories/App/ContentView.swift`

**Step 1: Add zooming and unzooming phases to AnimationPhase enum**

```swift
enum AnimationPhase: Equatable {
    // Opening phases
    case idle
    case selected
    case moving
    case flipping
    case revealing
    case zooming      // NEW - depth zoom into spread
    case complete
    // Closing phases
    case closing
    case unzooming    // NEW - reverse depth zoom
    case unflipping
    case returning
}
```

**Step 2: Add library scale and blur computed properties**

Add these computed properties to ContentView:

```swift
private var libraryScale: CGFloat {
    switch animationPhase {
    case .zooming, .complete:
        return 0.85
    case .closing:
        return 0.85
    case .unzooming:
        return 0.925 // Animating back
    default:
        return 1.0
    }
}

private var libraryBlur: CGFloat {
    switch animationPhase {
    case .idle:
        return 0
    case .selected, .moving, .flipping, .revealing:
        return 10
    case .zooming, .complete:
        return 25
    case .closing:
        return 25
    case .unzooming:
        return 17.5 // Animating back
    case .unflipping, .returning:
        return 10
    }
}

private var libraryOpacity: Double {
    switch animationPhase {
    case .zooming, .complete, .closing:
        return 0.0
    default:
        return 1.0
    }
}
```

**Step 3: Apply scale, blur, and opacity to LibraryView**

Update the LibraryView in body:

```swift
LibraryView(
    viewModel: viewModel,
    namespace: bookAnimation,
    onBookTapped: { book, frame in
        handleBookTap(book, frame: frame)
    }
)
.scaleEffect(libraryScale)
.blur(radius: libraryBlur)
.opacity(libraryOpacity)
.animation(.easeOut(duration: 0.3), value: animationPhase)
```

**Step 4: Add zooming phase timing constants**

```swift
private let openingZoomDelay: Double = 1.4
private let closingUnzoomDelay: Double = 0.1
```

**Step 5: Update handleBookTap to add zooming phase**

After the revealing phase dispatch, add:

```swift
// Phase 5: Zoom into spread
DispatchQueue.main.asyncAfter(deadline: .now() + openingZoomDelay) {
    withAnimation(.easeInOut(duration: 0.4)) {
        animationPhase = .zooming
    }
}
```

**Step 6: Update closeBook to add unzooming phase**

Update the closing sequence:

```swift
private func closeBook() {
    // Phase 1: Unzoom - library starts returning
    withAnimation(.easeOut(duration: 0.3)) {
        showingReader = false
        animationPhase = .unzooming
    }

    // Phase 2: Closing - book appears at spread
    DispatchQueue.main.asyncAfter(deadline: .now() + closingUnzoomDelay) {
        withAnimation(.easeOut(duration: 0.3)) {
            animationPhase = .closing
        }
    }

    // Phase 3: Unflipping - book cover flips closed
    DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase2Delay) {
        withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
            animationPhase = .unflipping
        }
    }

    // Phase 4: Returning - book shrinks and moves back
    DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase3Delay) {
        withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
            animationPhase = .returning
        }
    }

    // Phase 5: Idle - complete
    DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase4Delay) {
        withAnimation(.easeOut(duration: 0.2)) {
            animationPhase = .idle
            selectedBook = nil
        }
    }
}
```

**Step 7: Build and verify**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 8: Commit**

```bash
git add BibleStories/App/ContentView.swift
git commit -m "feat: add zooming animation phases with library depth effects"
```

---

## Task 4: Update Book3DView for Split Page Display

**Files:**
- Modify: `BibleStories/Features/BookTransition/Book3DView.swift`

**Step 1: Update properties to accept split images**

Replace `firstPageImage` with `leftHalfImage` and `rightHalfImage`:

```swift
struct Book3DView: View {
    let coverImage: UIImage?
    let leftHalfImage: UIImage?    // Left half of first page
    let rightHalfImage: UIImage?   // Right half of first page
    let size: CGSize
    let flipAngle: Double
    let spineWidth: CGFloat
    let showSpread: Bool           // NEW - show two-page spread mode

    // ... existing constants ...

    private let gutterWidth: CGFloat = 24
    private let gutterShadowOpacity: Double = 0.15
```

**Step 2: Add spread view with gutter shadow**

Add this new view:

```swift
@ViewBuilder
private var spreadView: some View {
    HStack(spacing: 0) {
        // Left page
        if let leftImage = leftHalfImage {
            Image(uiImage: leftImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width / 2, height: size.height)
                .clipped()
        }

        // Right page
        if let rightImage = rightHalfImage {
            Image(uiImage: rightImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width / 2, height: size.height)
                .clipped()
        }
    }
    .frame(width: size.width, height: size.height)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    .overlay(
        // Gutter shadow in center
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(gutterShadowOpacity),
                        .black.opacity(gutterShadowOpacity * 1.2),
                        .black.opacity(gutterShadowOpacity),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: gutterWidth)
    )
    .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
    )
}
```

**Step 3: Update body to conditionally show spread**

```swift
var body: some View {
    ZStack {
        // Layer 1: Spread view (when fully open)
        if showSpread && flipAngle >= 170 {
            spreadView
        } else {
            // Layer 1: First page (revealed when angle > firstPageRevealAngle)
            if flipAngle > firstPageRevealAngle {
                firstPageView
                    .opacity(firstPageOpacity)
            }
        }

        // Layer 2: Page edges (visible during flip, hidden in spread mode)
        if !showSpread || flipAngle < 170 {
            pageEdgesView
                .opacity(pageEdgesOpacity)
        }

        // Layer 3: Spine (visible during flip, hidden in spread mode)
        if !showSpread || flipAngle < 170 {
            spineView
                .opacity(spineOpacity)
        }

        // Layer 4: Front cover (flips open)
        coverView
            .rotation3DEffect(
                .degrees(-flipAngle),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                anchorZ: 0,
                perspective: 0.5
            )
            .opacity(coverOpacity)
    }
}
```

**Step 4: Update firstPageView to use rightHalfImage for preview during flip**

```swift
@ViewBuilder
private var firstPageView: some View {
    if let image = rightHalfImage {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width / 2, height: size.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
            )
            .offset(x: size.width / 4) // Position on right side
    } else {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.celestialLight)
            .frame(width: size.width / 2, height: size.height)
            .offset(x: size.width / 4)
    }
}
```

**Step 5: Build and verify**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 6: Commit**

```bash
git add BibleStories/Features/BookTransition/Book3DView.swift
git commit -m "feat: update Book3DView for two-page spread with gutter shadow"
```

---

## Task 5: Update BookOpeningView for Spread and Zoom

**Files:**
- Modify: `BibleStories/Features/BookTransition/BookOpeningView.swift`

**Step 1: Update image state properties**

Replace `firstPageImage` with split images:

```swift
@State private var coverImage: UIImage?
@State private var leftHalfImage: UIImage?
@State private var rightHalfImage: UIImage?
```

**Step 2: Update loadImages function**

```swift
private func loadImages() {
    coverImage = UIImage(named: book.coverImage)
    if let firstPage = book.pages.first,
       let pageImage = UIImage(named: firstPage.imageAsset) {
        leftHalfImage = pageImage.leftHalf()
        rightHalfImage = pageImage.rightHalf()
    }
}
```

**Step 3: Add showSpread computed property**

```swift
private var showSpread: Bool {
    switch phase {
    case .revealing, .zooming, .complete, .closing, .unzooming:
        return true
    default:
        return false
    }
}
```

**Step 4: Add zoom scale computed property**

```swift
private var zoomScale: CGFloat {
    switch phase {
    case .zooming, .complete:
        // Scale spread to fill screen
        let targetWidth = screenSize.width * 0.95
        return targetWidth / coordinator.readerSize.width
    case .closing, .unzooming:
        // Same scale during initial closing
        let targetWidth = screenSize.width * 0.95
        return targetWidth / coordinator.readerSize.width
    default:
        return 1.0
    }
}
```

**Step 5: Update currentSize for zooming phases**

```swift
private var currentSize: CGSize {
    switch phase {
    case .idle, .returning:
        return bookCoverSize
    case .selected:
        return CGSize(
            width: bookCoverSize.width * bookSelectedScale,
            height: bookCoverSize.height * bookSelectedScale
        )
    case .moving, .flipping, .unflipping:
        return coordinator.centeredBookSize
    case .revealing, .closing, .unzooming:
        return coordinator.readerSize
    case .zooming, .complete:
        // Scale up for zoom effect
        return CGSize(
            width: coordinator.readerSize.width * zoomScale,
            height: coordinator.readerSize.height * zoomScale
        )
    }
}
```

**Step 6: Update body to use new Book3DView API**

```swift
var body: some View {
    Book3DView(
        coverImage: coverImage,
        leftHalfImage: leftHalfImage,
        rightHalfImage: rightHalfImage,
        size: currentSize,
        flipAngle: flipAngle,
        spineWidth: currentSpineWidth,
        showSpread: showSpread
    )
    .position(currentPosition)
    .scaleEffect(phase == .zooming || phase == .complete ? 1.0 : 1.0) // Handled by currentSize
    .onChange(of: phase) { _, newPhase in
        handlePhaseChange(newPhase)
    }
    .onAppear {
        loadImages()
    }
}
```

**Step 7: Update handlePhaseChange for new phases**

```swift
private func handlePhaseChange(_ newPhase: ContentView.AnimationPhase) {
    switch newPhase {
    // Opening phases
    case .flipping:
        withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
            flipAngle = 180
        }
    case .revealing:
        // Spread is now visible, wait then trigger zoom
        break
    case .zooming:
        // Zoom handled by currentSize, trigger completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            guard phase == .zooming else { return }
            onComplete()
        }

    // Closing phases
    case .unzooming:
        // Library starts returning, book still at zoom scale
        break
    case .closing:
        // Book appears at full flip (already open)
        flipAngle = 180
    case .unflipping:
        withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
            flipAngle = 0
        }
    case .returning:
        break

    default:
        break
    }
}
```

**Step 8: Build and verify**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 9: Commit**

```bash
git add BibleStories/Features/BookTransition/BookOpeningView.swift
git commit -m "feat: update BookOpeningView for spread display and zoom transition"
```

---

## Task 6: Integration Testing

**Step 1: Build the complete project**

Run: `xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build`

**Step 2: Test on simulator**

1. Launch app
2. Verify book title appears on thumbnail
3. Tap book - verify library blurs and scales
4. Verify cover flips and reveals two-page spread
5. Verify gutter shadow between pages
6. Verify zoom into spread
7. Verify transition to reader
8. Close book - verify reverse sequence
9. Verify library returns to normal

**Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete book opening improvements with spread and zoom"
```

---

## Summary

| Task | Description |
|------|-------------|
| 1 | Add book title overlay to library thumbnails |
| 2 | Create UIImage split extension |
| 3 | Add zooming animation phases to ContentView |
| 4 | Update Book3DView for split page display |
| 5 | Update BookOpeningView for spread and zoom |
| 6 | Integration testing |
