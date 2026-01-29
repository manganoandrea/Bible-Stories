# Book Opening Animation Improvements Design

**Date:** 2026-01-29
**Status:** Approved

## Overview

Improve the book opening animation with two key enhancements:
1. Two-page spread effect - first page already visible under the cover, split in half like a real book
2. Depth zoom transition - camera "dives into" the book as library recedes behind

## Goals

- Create authentic "opening a storybook" feeling
- Smooth transition from library to reader without jarring blur cutoff
- Maintain 60fps performance

---

## Design

### Two-Page Spread Effect

When the book opens, the first page illustration is already positioned beneath the cover, split into two halves:

- **Left half** - Sits stationary, representing the "left page" of the open book
- **Right half** - Initially hidden under the cover, revealed as the cover rotates open

**Visual sequence:**

1. Book cover begins to flip (0° → 90°)
2. As cover passes ~45°, right half of illustration peeks out
3. Cover reaches 90° (edge-on) - both halves visible side by side with subtle gutter shadow
4. Cover continues past 90° and folds away/fades
5. Two halves fully visible as a spread

**Image handling:**

Create a utility that takes a `UIImage` and returns left/right halves at render time. A subtle vertical shadow runs down the center to simulate the book's gutter.

### Depth Zoom Transition

As the book opens and reveals the spread, the camera appears to zoom forward into the pages while the library recedes behind.

**Visual sequence:**

1. **Book opens** (0.0 - 0.8s) - Cover flips, spread revealed, library blurred behind
2. **Zoom begins** (0.8 - 1.4s):
   - Book spread scales up (1.0x → fills screen)
   - Library scales down (1.0x → 0.85x)
   - Library blur increases (10 → 25)
   - Library opacity fades (1.0 → 0.0)
   - Subtle parallax: book moves faster than library
3. **Transition complete** (1.4s) - Spread fills screen, becomes reader view

### Combined Animation Timeline

| Time | Book | Library | Effect |
|------|------|---------|--------|
| 0.0s | Tap - scales 1.05x | Blur starts (0 → 10) | Selection feedback |
| 0.2s | Moves to center | Blur holds at 10 | Book lifts off shelf |
| 0.5s | Cover flipping | - | Spine visible, right page peeks |
| 0.8s | Cover at 90°, spread visible | - | Both halves with gutter shadow |
| 0.9s | Cover folds away | Scale (1.0 → 0.85), blur (10 → 25) | Zoom begins |
| 1.2s | Spread scales to fill | Opacity (1.0 → 0) | Diving into book |
| 1.4s | Full screen reader | Gone | Complete |

### Closing Animation

Reverse of opening:
- Reader shrinks back into spread view
- Library zooms up from behind (0.85x → 1.0x)
- Blur decreases (25 → 10 → 0)
- Opacity returns (0 → 1.0)
- Book closes (spread → cover flip → return to shelf)

---

## Implementation

### Files to Modify

1. **`BookOpeningView.swift`**
   - Orchestrate new timeline with zooming phase
   - Handle spread display with left/right halves
   - Coordinate with library scale/blur changes

2. **`Book3DView.swift`**
   - Accept `leftHalfImage` and `rightHalfImage` instead of single `firstPageImage`
   - Render split halves with gutter shadow between them
   - Position left half stationary, right half revealed with cover flip

3. **`ContentView.swift`**
   - Add `scaleEffect` to LibraryView tied to animation phase
   - Enhance blur animation with parallax offset
   - Add `.zooming` phase handling

### New File

4. **`Extensions/UIImage+Split.swift`**
   - `func leftHalf() -> UIImage?`
   - `func rightHalf() -> UIImage?`
   - Split at center point, return cropped images

### Animation Phase Changes

```swift
enum AnimationPhase: Equatable {
    // Opening
    case idle
    case selected
    case moving
    case flipping
    case revealing
    case zooming      // NEW - depth zoom into spread
    case complete
    // Closing
    case closing
    case unzooming    // NEW - reverse depth zoom
    case unflipping
    case returning
}
```

### Gutter Shadow

Add a subtle vertical gradient overlay between the two halves:
- Width: 20-30pt
- Color: Black at 15% opacity in center, fading to transparent at edges
- Creates the illusion of pages curving into the book's spine

---

## Edge Cases

| Case | Handling |
|------|----------|
| Book has no pages | Show decorative "Coming Soon" spread |
| Single page book | Use same image for both halves (no split) |
| Performance | Use `drawingGroup()` for complex compositions |

---

## Testing Checklist

- [ ] Cover flip reveals right half progressively
- [ ] Both halves align perfectly when spread is complete
- [ ] Gutter shadow visible between halves
- [ ] Library scales down and blurs during zoom
- [ ] Parallax effect creates depth feeling
- [ ] Transition to reader is seamless
- [ ] Closing animation reverses all effects smoothly
- [ ] 60fps maintained throughout
