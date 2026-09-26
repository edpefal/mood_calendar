## Context

The `app_icon.png` (500×500px, RGBA) uses `#8C52FF` as its opaque background. The launch screen was configured with `#5F3DC4` — a different shade of purple — causing a visible square artifact around the icon during app launch.

Sampling pixel (0,0) of `app_icon.png` confirmed: `rgba(140, 82, 255, 255)` = `#8C52FF`.

## Goals / Non-Goals

**Goals:**
- Eliminate the visible color mismatch on the launch screen
- No asset regeneration required

**Non-Goals:**
- Changing the app icon itself
- Aligning brand color across the rest of the app UI

## Decisions

**Match background to icon color (`#8C52FF`)**

The icon's background is `#8C52FF` and cannot be changed without regenerating the asset. The launch screen background is a config value in two files — trivial to change. Updating those two files is the minimal, zero-risk fix.

iOS storyboard RGB float equivalent of `#8C52FF`:
- R: 140/255 ≈ 0.549
- G: 82/255 ≈ 0.322
- B: 255/255 = 1.0

## Risks / Trade-offs

- `#8C52FF` is slightly brighter than the original `#5F3DC4`. This only affects the launch screen, not any in-app UI.
