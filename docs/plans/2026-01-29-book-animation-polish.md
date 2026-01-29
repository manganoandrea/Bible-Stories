# Book Animation Polish Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 3D book depth (spine + page edges) to the flip animation and implement a full reverse closing animation.

**Architecture:** Create a `Book3DView` component that renders cover, spine, and page edges as a composite. Extend `AnimationPhase` with closing states. Track original book position for return animation.

**Tech Stack:** SwiftUI, iOS 17+, rotation3DEffect, UIImage color sampling

---

### Task 1: Create UIImage Color Extraction Extension

**Files:**
- Create: `BibleStories/Extensions/UIImage+ColorExtraction.swift`

**Step 1: Create the extensions directory and file**

```swift
//
//  UIImage+ColorExtraction.swift
//  BibleStories
//
//  Extracts dominant color from image edges for spine coloring.
//

import SwiftUI
import UIKit

extension UIImage {
    /// Extracts the average color from the left edge of the image (for book spine)
    func dominantColorFromLeftEdge(sampleWidth: CGFloat = 0.1) -> Color {
        guard let cgImage = self.cgImage else {
            return Color(red: 0.4, green: 0.25, blue: 0.15) // Fallback brown
        }

        let width = cgImage.width
        let height = cgImage.height
        let samplePixelWidth = max(1, Int(CGFloat(width) * sampleWidth))

        // Create a smaller image from just the left edge
        guard let croppedImage = cgImage.cropping(to: CGRect(x: 0, y: 0, width: samplePixelWidth, height: height)) else {
            return Color(red: 0.4, green: 0.25, blue: 0.15)
        }

        // Sample the cropped image
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return Color(red: 0.4, green: 0.25, blue: 0.15)
        }

        context.draw(croppedImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        guard let data = context.data else {
            return Color(red: 0.4, green: 0.25, blue: 0.15)
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: 4)
        let r = CGFloat(pointer[0]) / 255.0
        let g = CGFloat(pointer[1]) / 255.0
        let b = CGFloat(pointer[2]) / 255.0

        // Darken slightly for spine effect
        return Color(red: r * 0.85, green: g * 0.85, blue: b * 0.85)
    }
}
```

**Step 2: Verify file compiles**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"`

Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add BibleStories/Extensions/UIImage+ColorExtraction.swift
git commit -m "feat: add UIImage color extraction for book spine"
```

---

### Task 2: Create Book3DView Component

**Files:**
- Create: `BibleStories/Features/BookTransition/Book3DView.swift`

**Step 1: Create the 3D book view**

```swift
//
//  Book3DView.swift
//  BibleStories
//
//  Renders a 3D book with cover, spine, and page edges.
//

import SwiftUI

struct Book3DView: View {
    let coverImage: UIImage?
    let firstPageImage: UIImage?
    let size: CGSize
    let flipAngle: Double // 0 = closed, 180 = fully open
    let spineWidth: CGFloat

    @State private var spineColor: Color = Color(red: 0.4, green: 0.25, blue: 0.15)

    private let pageEdgeColor = Color(white: 0.95)

    var body: some View {
        ZStack {
            // Layer 1: First page (revealed when angle > 90)
            if flipAngle > 90 {
                firstPageView
                    .opacity(firstPageOpacity)
            }

            // Layer 2: Page edges (visible during flip)
            pageEdgesView
                .opacity(pageEdgesOpacity)

            // Layer 3: Spine (visible during flip)
            spineView
                .opacity(spineOpacity)

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
        .onAppear {
            extractSpineColor()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var coverView: some View {
        if let image = coverImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: 6)
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppColors.celestialMid)
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.gold)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
            )
    }

    @ViewBuilder
    private var firstPageView: some View {
        if let image = firstPageImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.celestialLight)
                .frame(width: size.width, height: size.height)
        }
    }

    private var spineView: some View {
        // Spine positioned at the left edge, rotated to face camera during flip
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        spineColor.opacity(0.7),
                        spineColor,
                        spineColor.opacity(0.5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: spineWidth, height: size.height)
            .overlay(
                // Spine detail line
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 1)
                    .offset(x: -spineWidth / 2 + 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.5
            )
            .offset(x: -size.width / 2 + spineWidth / 2)
    }

    private var pageEdgesView: some View {
        // Page edges - cream colored strip representing closed pages
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        pageEdgeColor.opacity(0.9),
                        pageEdgeColor,
                        pageEdgeColor.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: spineWidth * 0.8, height: size.height - 8)
            .overlay(
                // Page lines
                VStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 0.5)
                    }
                }
                .padding(.vertical, 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.5
            )
            .offset(x: -size.width / 2 + spineWidth + (spineWidth * 0.4))
    }

    // MARK: - Computed Properties

    private var coverOpacity: Double {
        flipAngle < 170 ? 1.0 : 0.0
    }

    private var firstPageOpacity: Double {
        if flipAngle <= 90 { return 0 }
        return min(1.0, (flipAngle - 90) / 45)
    }

    private var spineOpacity: Double {
        // Visible from 20° to 160°
        if flipAngle < 20 { return flipAngle / 20 }
        if flipAngle > 160 { return (180 - flipAngle) / 20 }
        return 1.0
    }

    private var pageEdgesOpacity: Double {
        spineOpacity * 0.9
    }

    private var shadowRadius: CGFloat {
        // Shadow grows as book lifts
        let baseRadius: CGFloat = 8
        let maxAdditional: CGFloat = 12
        let progress = min(flipAngle, 90) / 90
        return baseRadius + (maxAdditional * progress)
    }

    private var shadowOffsetX: CGFloat {
        // Shadow shifts with rotation
        let maxOffset: CGFloat = 15
        return -maxOffset * sin(flipAngle * .pi / 180)
    }

    private var shadowColor: Color {
        AppColors.stickerShadow.opacity(0.3 + 0.2 * min(flipAngle, 90) / 90)
    }

    // MARK: - Methods

    private func extractSpineColor() {
        if let image = coverImage {
            spineColor = image.dominantColorFromLeftEdge()
        }
    }
}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Book3DView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 200, height: 280),
                flipAngle: 0,
                spineWidth: 14
            )

            Book3DView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 200, height: 280),
                flipAngle: 90,
                spineWidth: 14
            )
        }
    }
}
```

**Step 2: Verify file compiles**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"`

Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add BibleStories/Features/BookTransition/Book3DView.swift
git commit -m "feat: add Book3DView with spine and page edges"
```

---

### Task 3: Add Closing Animation Phases

**Files:**
- Modify: `BibleStories/App/ContentView.swift`

**Step 1: Extend AnimationPhase enum**

In `ContentView.swift`, update the `AnimationPhase` enum to include closing states:

```swift
enum AnimationPhase: Equatable {
    // Opening phases
    case idle
    case selected
    case moving
    case flipping
    case revealing
    case complete
    // Closing phases
    case closing
    case unflipping
    case returning
}
```

**Step 2: Add original book frame tracking**

Add a new state variable after the existing state declarations:

```swift
@State private var originalBookFrame: CGRect = .zero
```

**Step 3: Update handleBookTap to capture position**

Modify `handleBookTap` to accept and store the book's frame:

```swift
private func handleBookTap(_ book: Book, frame: CGRect) {
    guard !book.isLocked else { return }

    selectedBook = book
    originalBookFrame = frame

    // ... rest of existing animation code
}
```

**Step 4: Implement closeBook with reverse animation**

Replace the existing `closeBook()` method:

```swift
private func closeBook() {
    // Phase 1: Closing - reader fades, book appears
    withAnimation(.easeOut(duration: 0.3)) {
        showingReader = false
        animationPhase = .closing
    }

    // Phase 2: Unflipping - book cover flips closed
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
            animationPhase = .unflipping
        }
    }

    // Phase 3: Returning - book shrinks and moves back
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
        withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
            animationPhase = .returning
        }
    }

    // Phase 4: Idle - complete
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
        withAnimation(.easeOut(duration: 0.2)) {
            animationPhase = .idle
            selectedBook = nil
        }
    }
}
```

**Step 5: Update body to show transition view during closing**

Update the condition for showing BookOpeningView:

```swift
// Book Opening/Closing Animation Overlay
if let book = selectedBook, animationPhase != .idle {
    BookOpeningView(
        book: book,
        namespace: bookAnimation,
        phase: $animationPhase,
        screenSize: geometry.size,
        originalFrame: originalBookFrame,
        onComplete: {
            withAnimation(.easeOut(duration: 0.3)) {
                showingReader = true
                animationPhase = .complete
            }
        }
    )
}
```

**Step 6: Verify file compiles**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"`

Expected: Errors about BookOpeningView signature (we'll fix in next task)

**Step 7: Commit work in progress**

```bash
git add BibleStories/App/ContentView.swift
git commit -m "feat: add closing animation phases to ContentView"
```

---

### Task 4: Update BookCoverView to Report Frame

**Files:**
- Modify: `BibleStories/Features/Library/BookCoverView.swift`

**Step 1: Add frame reporting callback**

Update BookCoverView to accept a frame reporting closure:

```swift
struct BookCoverView: View {
    let book: Book
    let namespace: Namespace.ID
    let onTap: (CGRect) -> Void  // Changed to pass frame

    @State private var isPressed = false

    var body: some View {
        GeometryReader { geometry in
            StickerButton(action: {
                let frame = geometry.frame(in: .global)
                onTap(frame)
            }) {
                ZStack(alignment: .topTrailing) {
                    // ... existing content unchanged
                }
                .frame(width: 200, height: 280)
                .stickerBorder(cornerRadius: 16, borderWidth: book.isLocked ? 2 : 3)
                .opacity(book.isLocked ? 0.7 : 1.0)
            }
        }
        .frame(width: 200, height: 280)
    }

    // ... rest unchanged
}
```

**Step 2: Update preview**

```swift
#Preview {
    ZStack {
        CelestialVaultBackground()
            .ignoresSafeArea()

        HStack(spacing: 24) {
            BookCoverView(
                book: .adamAndEve,
                namespace: Namespace().wrappedValue,
                onTap: { _ in }
            )

            BookCoverView(
                book: .noahsArk,
                namespace: Namespace().wrappedValue,
                onTap: { _ in }
            )
        }
    }
}
```

**Step 3: Update LibraryView to pass frame**

In `BibleStories/Features/Library/LibraryView.swift`, update the onBookTapped callback type and usage:

Change the property declaration:
```swift
let onBookTapped: (Book, CGRect) -> Void
```

Update the ForEach:
```swift
ForEach(viewModel.books) { book in
    BookCoverView(
        book: book,
        namespace: namespace,
        onTap: { frame in
            onBookTapped(book, frame)
        }
    )
}
```

Update the preview:
```swift
LibraryView(
    viewModel: LibraryViewModel(),
    namespace: namespace,
    onBookTapped: { _, _ in }
)
```

**Step 4: Update ContentView to use new signature**

In ContentView body, update the LibraryView callback:

```swift
LibraryView(
    viewModel: viewModel,
    namespace: bookAnimation,
    onBookTapped: { book, frame in
        handleBookTap(book, frame: frame)
    }
)
```

**Step 5: Verify file compiles**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"`

Expected: Errors about BookOpeningView (next task)

**Step 6: Commit**

```bash
git add BibleStories/Features/Library/BookCoverView.swift BibleStories/Features/Library/LibraryView.swift BibleStories/App/ContentView.swift
git commit -m "feat: add frame reporting to BookCoverView for return animation"
```

---

### Task 5: Rewrite BookOpeningView as BookTransitionView

**Files:**
- Modify: `BibleStories/Features/BookTransition/BookOpeningView.swift` (rename to BookTransitionView)

**Step 1: Rewrite the complete file**

Replace the entire contents of `BookOpeningView.swift`:

```swift
//
//  BookTransitionView.swift
//  BibleStories
//
//  Orchestrates opening and closing book animations with 3D effects.
//

import SwiftUI

struct BookOpeningView: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var phase: ContentView.AnimationPhase
    let screenSize: CGSize
    let originalFrame: CGRect
    let onComplete: () -> Void

    @State private var flipAngle: Double = 0
    @State private var coverImage: UIImage?
    @State private var firstPageImage: UIImage?

    private var coordinator: TransitionCoordinator {
        TransitionCoordinator(screenSize: screenSize)
    }

    private let spineWidth: CGFloat = 14

    var body: some View {
        Book3DView(
            coverImage: coverImage,
            firstPageImage: firstPageImage,
            size: currentSize,
            flipAngle: flipAngle,
            spineWidth: currentSpineWidth
        )
        .position(currentPosition)
        .onChange(of: phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
        .onAppear {
            loadImages()
        }
    }

    // MARK: - Computed Properties

    private var currentSize: CGSize {
        switch phase {
        case .idle, .returning:
            return CGSize(width: 200, height: 280)
        case .selected:
            return CGSize(width: 210, height: 294)
        case .moving, .flipping, .unflipping:
            return coordinator.centeredBookSize
        case .revealing, .complete, .closing:
            return coordinator.readerSize
        }
    }

    private var currentPosition: CGPoint {
        switch phase {
        case .idle:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        case .selected:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        case .returning:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        case .moving, .flipping, .unflipping, .revealing, .complete, .closing:
            return coordinator.screenCenter
        }
    }

    private var currentSpineWidth: CGFloat {
        let baseSpine: CGFloat = 14
        let scale = currentSize.width / 200
        return baseSpine * scale
    }

    // MARK: - Methods

    private func loadImages() {
        coverImage = UIImage(named: book.coverImage)
        if let firstPage = book.pages.first {
            firstPageImage = UIImage(named: firstPage.imageAsset)
        }
    }

    private func handlePhaseChange(_ newPhase: ContentView.AnimationPhase) {
        switch newPhase {
        // Opening phases
        case .flipping:
            withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                flipAngle = 180
            }
        case .revealing:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }

        // Closing phases
        case .closing:
            // Book appears at full flip
            flipAngle = 180
        case .unflipping:
            withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
                flipAngle = 0
            }
        case .returning:
            // Size and position animate via currentSize/currentPosition
            break

        default:
            break
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var phase: ContentView.AnimationPhase = .moving

    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        BookOpeningView(
            book: .adamAndEve,
            namespace: namespace,
            phase: $phase,
            screenSize: CGSize(width: 1024, height: 768),
            originalFrame: CGRect(x: 100, y: 200, width: 200, height: 280),
            onComplete: {}
        )
    }
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            phase = .flipping
        }
    }
}
```

**Step 2: Verify project compiles**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "(error:|BUILD)"`

Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add BibleStories/Features/BookTransition/BookOpeningView.swift
git commit -m "feat: rewrite BookOpeningView with 3D book and closing support"
```

---

### Task 6: Add Extensions Directory to Xcode Project

**Files:**
- Modify: `BibleStories.xcodeproj/project.pbxproj`

**Step 1: Create Extensions directory**

```bash
mkdir -p "/Users/andreamangano/Bible Stories/BibleStories/BibleStories/Extensions"
```

**Step 2: Move color extraction file if created elsewhere, or ensure it's in place**

The file should already exist from Task 1. Verify:

```bash
ls -la "/Users/andreamangano/Bible Stories/BibleStories/BibleStories/Extensions/"
```

**Step 3: Rebuild to verify everything works**

Run: `cd "/Users/andreamangano/Bible Stories/BibleStories" && xcodebuild -project BibleStories.xcodeproj -scheme BibleStories -destination 'platform=iOS Simulator,name=iPhone 17 Pro' clean build 2>&1 | tail -20`

Expected: `BUILD SUCCEEDED`

**Step 4: Run on simulator to test**

```bash
xcrun simctl install "iPhone 17 Pro" ~/Library/Developer/Xcode/DerivedData/BibleStories-*/Build/Products/Debug-iphonesimulator/BibleStories.app && xcrun simctl launch "iPhone 17 Pro" com.biblestories.app
```

**Step 5: Commit all changes**

```bash
git add -A
git commit -m "feat: complete book animation polish with 3D spine and closing animation"
```

---

### Task 7: Manual Testing Checklist

**Test the opening animation:**
1. Launch app on simulator
2. Tap "Adam and Eve" book
3. Verify: Library blurs, book scales up
4. Verify: Book moves to center
5. Verify: 3D flip shows spine during rotation
6. Verify: Page edges visible alongside spine
7. Verify: First page appears as cover opens past 90°
8. Verify: Smooth transition to reader view

**Test the closing animation:**
1. In reader view, tap the X close button
2. Verify: Reader fades out
3. Verify: Book cover flips closed (spine visible)
4. Verify: Book shrinks and returns to grid position
5. Verify: Library unblurs
6. Verify: No visual glitches or jumps

**Test edge cases:**
1. Tap a locked book - should not animate
2. Rapidly tap during animation - should be ignored
3. Rotate device during animation - should complete gracefully

**Step 1: Document any issues found**

If issues found, create follow-up tasks.

**Step 2: Final commit with any fixes**

```bash
git add -A
git commit -m "test: verify book animation polish implementation"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Color extraction extension | `Extensions/UIImage+ColorExtraction.swift` |
| 2 | Book3DView component | `BookTransition/Book3DView.swift` |
| 3 | Closing animation phases | `App/ContentView.swift` |
| 4 | Frame reporting | `Library/BookCoverView.swift`, `LibraryView.swift` |
| 5 | Rewrite transition view | `BookTransition/BookOpeningView.swift` |
| 6 | Build verification | Project files |
| 7 | Manual testing | N/A |

**Total: 7 tasks, ~20-30 minutes estimated**
