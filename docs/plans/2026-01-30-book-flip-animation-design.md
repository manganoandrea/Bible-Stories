# Book Flip Animation Design

## Overview

Redesign the book opening/closing animation to use the PhysicalBookView component, ensuring design consistency and smooth transitions.

## Goals

1. Reuse PhysicalBookView so design changes apply everywhere
2. Smooth, natural transitions between animation phases
3. Match the reference animation frames

## Component Structure

```
PhysicalBookView (existing - shared)
├── Cover (180w × 212h)
├── Pages (6px white, right side)
└── Binding (5px teal, right edge)

AnimatedBookView (new - for flip animation)
├── Uses PhysicalBookView for closed state
├── Cover flips with 3D rotation (hinge on LEFT)
├── Back of cover = primary cover color
├── Reveals two-page spread underneath
└── Scales to fullscreen
```

## Animation Phases

### Opening Flow

| Phase | Duration | Description |
|-------|----------|-------------|
| IDLE | - | Book at original position in library grid |
| SELECTED | 0.2s | Slight scale up (1.05x) for tap feedback |
| MOVING | 0.4s | Book moves to screen center, scales up |
| FLIPPING | 0.6s | Cover rotates -180° revealing spread |
| ZOOMING | 0.4s | Open book scales to fill screen |
| MODE_SELECTION | - | Read/Listen/Record buttons appear |

### Closing Flow

| Phase | Duration | Description |
|-------|----------|-------------|
| MODE_SELECTION | - | User taps Home button |
| UNZOOMING | 0.3s | Buttons fade, book scales down |
| CLOSING | 0.3s | Teal back cover slides in from left |
| UNFLIPPING | 0.6s | Cover rotates back (180° → 0°) |
| RETURNING | 0.4s | Book moves to original grid position |
| IDLE | 0.2s | Book settles, music fades in |

## Flip Visual Details

### Cover Rotation
- **Anchor:** LEFT edge (hinge point)
- **Axis:** Y-axis (horizontal flip)
- **Perspective:** 0.35 for 3D depth
- **Back face:** Primary cover color (solid, extracted from cover image)

### Layers Revealed During Flip
1. Left page: First story page (left half)
2. Right page: First story page (right half)
3. Gutter shadow: Subtle center shadow
4. Border: Teal binding frame around spread

### Shadow Behavior
- Grows as cover lifts (depth effect)
- Shifts left as cover rotates

## Spread View (Open Book)

- Teal binding visible on all edges
- White page border inside binding
- Two-page spread fills the interior
- Gutter shadow in center

## Easing

- **Spring animations:** For flip and scale (natural, bouncy feel)
- **Ease-out:** For zoom and movement transitions

## Implementation Notes

1. AnimatedBookView should compose PhysicalBookView, not duplicate code
2. Extract shared constants (colors, dimensions) to be reused
3. Cover back color uses same `dominantColorFromLeftEdge()` as binding
4. Ensure smooth interpolation between all phases
