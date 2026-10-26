# Network Explorer icon sources

Approved design: the wireless-discovery concept selected by Magnus on 2026-10-25.

- NetworkExplorer.png: approved full-detail master, generated with the built-in ImageGen tool.
- NetworkExplorer-small.png: ImageGen edit of that same master, optimized for 16- and 32-point sizes.
- ../Assets.xcassets/AppIcon.appiconset: all ten standard macOS icon slots. Logical sizes 16 and 32 use the small companion; larger slots use the full-detail master.
- ../../Resources/NetworkExplorerIcon.icns: matching standalone icon resource.
- ../../docs/images/app-icon.png: 256-pixel help-site copy of the full-detail icon.

Small-icon edit brief: preserve the exact layout, navy tile, turquoise upper arc,
ivory middle arc, amber dot and all three discovered-device symbols. Simplify
reflections, surface texture and fine bevels; strengthen device silhouettes and
contrast. Keep the same palette. No added elements.

Production correction (built-in ImageGen edit): extend the existing sapphire/navy
background seamlessly to every edge of a fully opaque square. Preserve the
foreground composition exactly. Remove the inset tile boundary and exterior
transparency because macOS supplies its own icon background and corner mask.
All catalog PNGs are opaque sRGB without a pre-rendered outer frame or corners.
