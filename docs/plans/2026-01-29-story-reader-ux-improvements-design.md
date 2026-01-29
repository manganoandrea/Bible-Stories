# Story Reader UX Improvements Design

**Date:** 2026-01-29
**Status:** Approved

## Overview

Enhance the Bible Stories app with improved book animations, story mode selection, adaptive framing, and reader interactions to match premium children's storybook app standards.

---

## 1. Enhanced 3D Book Opening Animation

### Opening Sequence

| Phase | Duration | Description |
|-------|----------|-------------|
| 1. Selected | 0.2s | Book scales up 1.05x, vertical spine line fades in on right edge |
| 2. Lifts | 0.4s | Book moves to screen center, grows larger, tilts in 3D space |
| 3. Cover flips | 0.6s | Cover rotates open on left-edge hinge with thick spine (adaptive color) and page edges visible |
| 4. Spread forms | 0.3s | Open spread with adaptive frame border revealing first story page |
| 5. Spread zooms | 0.4s | Framed first page fills screen |
| 6. Mode overlay | 0.3s | Dim overlay + Read/Listen buttons fade in over first page |

### Closing Sequence
Reverse of opening: mode overlay fades → spread shrinks → cover flips closed → book returns to library position

### Technical Details
- **Spine color:** Extracted from book cover (existing `UIImage+ColorExtraction`)
- **Spine width:** 2-3x current width for more prominent 3D effect
- **Perspective:** More dramatic 3D depth than current implementation
- **Frame border:** Visible during spread reveal, uses adaptive color

### Animation End State
The first story page (with adaptive frame) is visible as the backdrop for mode selection. When user selects a mode, the overlay fades and the same page becomes the active reading page (seamless transition).

---

## 2. Mode Selection Screen

### Layout
- **Backdrop:** First story page, dimmed ~50% with dark overlay
- **Top left:** Home button (sticker style) - returns to library
- **Top right:** Music toggle button (sticker style) - controls library background music
- **Center:** Two pill-shaped buttons stacked vertically

### Buttons
| Button | Icon | Action |
|--------|------|--------|
| Read | Book icon | Enter Read mode (manual, silent) |
| Listen | Headphones icon | Enter Listen mode (auto-play, auto-advance) |

### Button Style
- Rounded capsule shape
- Semi-transparent blue fill with white text/icons
- Subtle border and shadow (sticker aesthetic)
- Spring animation on tap

### Interactions
- Tap Read → fade out overlay → enter Read mode
- Tap Listen → fade out overlay → enter Listen mode, audio starts immediately
- Tap Home → triggers closing animation back to library
- Tap Music → toggles library background music

---

## 3. Story Reader - Adaptive Frame & UI

### Adaptive Frame
- Extract dominant color from each page's illustration
- Frame border (8-12pt) with rounded corners
- Corner dot decorations at each corner
- Frame color transitions smoothly when changing pages (0.3s crossfade)

### Top Bar
| Position | Element | Action |
|----------|---------|--------|
| Left | Home button (sticker) | Closes book, returns to library |
| Center | Contents button (sticker, grid icon) | Opens page grid overlay |
| Right | Mode toggle (sticker) | Shows current mode icon, tap to switch |

### Reading Modes

**Read Mode:**
- No auto-play audio
- Manual swipe to turn pages
- Narration text visible at bottom
- Tap play button to hear current page narration

**Listen Mode:**
- Auto-plays audio when page loads
- Auto-advances to next page when narration ends
- Narration text visible at bottom
- Tap to pause/resume

### Mode Toggle Behavior
- Icon shows current mode (book icon = Read, headphones = Listen)
- Tap to switch modes instantly
- If switching to Listen while on a page, audio begins playing

### Narration Text
- Positioned at bottom, inside the framed area
- Semi-transparent background pill
- Consistent with current implementation style

---

## 4. Tap-to-Hide UI (Immersive Mode)

### Trigger
Single tap anywhere on illustration

### Behavior
- All UI fades out (0.3s ease)
- Illustration expands to full-bleed
- Single tap again → UI fades back in (0.3s)

### Elements That Hide
- Top bar (home, contents, mode toggle)
- Adaptive frame border
- Narration text overlay
- Page indicator dots

### Elements That Stay
- Illustration (expands to fill screen)
- Audio continues if in Listen mode

### Edge Cases
- Subtle pulsing indicator in corner when audio is playing (so user knows it's active)
- Swipe gestures still work for page turning with UI hidden
- Double-tap reserved for future use (no current action)

---

## 5. Page Grid (Contents) Overlay

### Trigger
Tap contents button (grid icon) in top bar

### Layout
- Full screen overlay with blurred/dimmed background (current page visible behind)
- Close button (X) in top-left corner
- 2-column scrollable grid of page thumbnails

### Thumbnail Design
- Landscape ratio matching illustrations
- Page illustration (cropped/scaled to fit)
- Bookmark-style badge in top-left corner with page number
- Current page has white border highlight (2-3pt)
- ~16pt gap between thumbnails
- Padding from screen edges

### Interactions
- Tap thumbnail → closes overlay, jumps to that page
- Tap X → closes overlay, stays on current page
- Tap outside grid area → closes overlay
- Smooth scroll with momentum

### Animations
- Overlay fades in (0.3s)
- Optional: thumbnails stagger-animate in
- Selected thumbnail springs slightly before closing

---

## 6. Library Background Music

### Audio File
- Source: `Garden_of_Joy_2026-01-29T180734.wav`
- Location: Add to Resources folder
- Consider converting to .m4a for smaller file size

### Playback Behavior
- Music starts when app launches (Library view appears)
- Loops continuously while on Library screen
- Music toggle button in header controls playback

### Transitions
- Book opens → music fades out (0.5s) during animation
- Book closes → music fades back in (0.5s) as library appears
- Smooth crossfade, not abrupt cut

### Persistence
- Music on/off state saved to UserDefaults
- Remembered across app sessions

---

## 7. Summary of New Components

### New Files to Create
- `StoryModeSelectionView.swift` - Mode selection overlay
- `PageGridOverlay.swift` - Contents/page grid view
- `PageThumbnailView.swift` - Individual grid thumbnail
- `AdaptiveFrameModifier.swift` - Frame border with adaptive color
- `LibraryMusicPlayer.swift` - Background music controller

### Files to Modify
- `ContentView.swift` - Updated animation phases, mode selection flow
- `BookOpeningView.swift` - Enhanced 3D animation, thicker spine
- `Book3DView.swift` - Improved 3D perspective and spine rendering
- `StoryReaderView.swift` - New top bar, mode toggle, tap-to-hide, contents button
- `StoryPageView.swift` - Adaptive frame, immersive mode support
- `LibraryView.swift` - Background music integration

### Assets to Add
- `Garden_of_Joy.wav` (or .m4a) - Library background music

---

## 8. Design Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Spine color | Adaptive (from cover) | Cohesive with book art |
| Frame color | Adaptive (from page) | Each page feels unique |
| Button style | Sticker (existing) | Consistent, kid-friendly |
| Story modes | Read + Listen only | Ship existing features first |
| UI hide trigger | Single tap | Simple, intuitive |
| Mode toggle position | Replaces auto-advance | Cleaner UI, mode implies auto-advance |
