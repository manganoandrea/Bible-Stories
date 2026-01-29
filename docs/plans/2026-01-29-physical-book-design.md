# Physical Book Design

## Overview

Implement a 3D-styled book component matching the Figma design for the library view.

## Dimensions

- **Book size:** 212w × 192h pixels (landscape orientation)
- All proportions scale proportionally with book size

## Structure (left to right)

```
┌─────────────────────────────────────┐
│ SPINE │        COVER        │ PAGES │ BINDING
│ (10px)│    (full height)    │ (3px) │ (3px)
│       │                     │ white │ teal
│ dark  │   [cover image]     │       │
│       │                     │       │
│       │   "Adam & Eve"      │       │
│       │   [title at bottom] │       │
└───────┴─────────────────────┴───────┘
```

### Widths
- Spine: 10px (~4.7% of width)
- Cover: 196px (remaining space)
- White pages: 3px (~1.4% of width)
- Teal binding: 3px (~1.4% of width) - **RIGHT edge only**

### Heights
- Full height: 192px
- **No top/bottom borders** - cover and spine extend full height

## Corner Radii

- Outer binding: 6px all corners
- Spine: 6px on LEFT corners only (top-left, bottom-left)
- Cover: 6px on RIGHT corners only (top-right, bottom-right)

## Cover Content

1. **Background:** Dark placeholder (#262640) when no image
2. **Cover image:** Fills entire cover area, aspect fill, clipped
3. **Title overlay at bottom:**
   - Gradient background (clear → 80% black)
   - White text, bold rounded font (~14pt)
   - Text shadow for readability
   - Centered, 2 line limit
4. **Lock overlay (locked books):**
   - 60% black overlay covering entire cover
   - White lock icon centered

## Dynamic Colors

Colors extracted from cover image left edge:

- **Binding:** dominant color + 10% brightness
- **Spine:** dominant color - 15% brightness

### Fallback Colors (no image)
- Binding: #13626E (teal)
- Spine: #093238 (dark teal)

## Shadow

- Color: black 25% opacity
- Radius: 12px
- Offset: (0, 4)

## Figma Reference

Node ID: 7:31
URL: https://www.figma.com/design/Eu7rcnVW7OOJ5UUIu1ldYV/Untitled?node-id=7-31
