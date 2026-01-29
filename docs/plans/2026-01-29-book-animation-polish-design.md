# Book Animation Polish Design

**Date:** 2026-01-29
**Status:** Approved

## Overview

Enhance the book opening animation with 3D depth (spine & thickness) and add a full reverse closing animation that mirrors the opening sequence.

## Goals

1. Add visual polish with realistic 3D book rendering (cover, spine, page edges)
2. Implement a satisfying reverse animation when closing the book
3. Maintain 60fps performance on target devices

## Design

### 3D Book Model

The book becomes a composite view with three visible faces:

| Face | Description | Visibility |
|------|-------------|------------|
| Front cover | Existing cover image | 0° - 90° rotation |
| Spine | Vertical strip, color extracted from cover | Prominent at 45° - 135° |
| Page edges | Cream-colored strip representing closed pages | Visible alongside spine |

**Spine dimensions:** 14pt width at centered size, scales proportionally.

**Spine color extraction:** Sample pixels from the left edge of the cover UIImage, return average color. Falls back to rich brown if image unavailable.

**Page edge color:** `Color(white: 0.95)` for warmth.

### Animation Phases

```
Opening:  idle → selected → moving → flipping → revealing → complete
Closing:  complete → closing → unflipping → returning → idle
```

### Opening Animation (existing, enhanced)

| Phase | Duration | Action |
|-------|----------|--------|
| selected | 0.0 - 0.2s | Book scales to 1.05x, library blurs |
| moving | 0.2 - 0.6s | Book glides to screen center, scales up |
| flipping | 0.6 - 1.2s | 3D flip 0° → 180°, spine rotates through |
| revealing | 1.2 - 1.5s | Expands to reader size, transitions to StoryReaderView |

### Closing Animation (new)

| Phase | Duration | Action |
|-------|----------|--------|
| closing | 0.0 - 0.3s | Reader fades out, book appears at full size showing current page |
| unflipping | 0.3 - 0.9s | Cover flips closed 180° → 0°, spine visible |
| returning | 0.9 - 1.3s | Book shrinks, glides back to original grid position |
| idle | 1.3s+ | Library unblurs, book settles with subtle bounce |

### Shadow Dynamics

- **Lift:** Shadow grows larger and softer (radius 8 → 20) as book elevates
- **Flip:** Shadow shifts subtly with rotation
- **Return:** Shadow contracts as book settles back

### Timing Curves

- **Opening:** `spring(duration: 0.6, bounce: 0.1)` - energetic
- **Closing:** `spring(duration: 0.5, bounce: 0.05)` - gentle settle

## Implementation

### Files to Modify

1. **`ContentView.swift`**
   - Add closing phases to `AnimationPhase` enum
   - Capture tapped book's original frame position
   - Update `closeBook()` to trigger reverse sequence

2. **`BookOpeningView.swift`** → Rename to **`BookTransitionView.swift`**
   - Handle both opening and closing directions
   - Add spine and page edge rendering
   - Support position tracking for return animation

3. **`Book3DFlipModifier.swift`**
   - Enhance to render multi-face 3D book

### New File

4. **`Book3DView.swift`**
   - Renders the 3D book composite (cover + spine + pages)
   - Contains color extraction utility
   - Manages face visibility based on rotation angle

### State Additions

```swift
// In ContentView
@State private var originalBookFrame: CGRect = .zero

// In AnimationPhase enum
enum AnimationPhase {
    case idle, selected, moving, flipping, revealing, complete
    case closing, unflipping, returning  // New
}
```

### Color Extraction Utility

```swift
extension UIImage {
    func dominantColorFromLeftEdge() -> Color {
        // Sample pixels from left 10% of image
        // Return average color
        // Fallback: Color(red: 0.4, green: 0.25, blue: 0.15) // Rich brown
    }
}
```

## Edge Cases

| Case | Handling |
|------|----------|
| Missing cover image | Spine defaults to rich brown |
| Tap during animation | Ignored until complete |
| Orientation change mid-animation | Completes to target, recalculates on next interaction |

## Performance

- Color extraction: Once per tap, cached
- 3D transforms: Use `drawingGroup()` for Metal acceleration
- No re-renders during animation: State pre-calculated

## Testing Checklist

- [ ] 3D book shows spine during flip
- [ ] Spine color matches cover's left edge
- [ ] Page edges visible during rotation
- [ ] Closing animation mirrors opening
- [ ] Book returns to correct grid position
- [ ] Shadow dynamics feel natural
- [ ] 60fps on iPhone 12 and newer
- [ ] Handles missing cover images gracefully
