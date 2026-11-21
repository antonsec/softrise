"""Render repo-native SVG brand assets; optional dependencies: cairosvg, Pillow."""
from pathlib import Path
import cairosvg
from PIL import Image, ImageCms

root = Path(__file__).resolve().parent.parent
brand = root / "assets" / "brand"
profile = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()
exports = [
    ("softrise-icon.svg", brand / "softrise-store-500.png", 500, 500, "RGB"),
    ("softrise-icon.svg", brand / "softrise-device-128.png", 128, 128, "RGB"),
    ("softrise-logo-transparent.svg", brand / "softrise-logo-transparent.png", 500, 500, "RGBA"),
    ("softrise-wordmark.svg", brand / "softrise-wordmark.png", 1200, 320, "RGBA"),
    ("softrise-logo-transparent.svg", root / "resources/drawables/launcher.png", 60, 60, "RGBA"),
]
for source, output, width, height, mode in exports:
    cairosvg.svg2png(url=str(brand / source), write_to=str(output),
                    output_width=width, output_height=height)
    with Image.open(output) as rendered:
        rendered.convert(mode).save(output, icc_profile=profile)
    print(f"Rendered {output.name}: {width}x{height}, {mode}/sRGB")
