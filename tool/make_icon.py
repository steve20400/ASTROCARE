"""Builds the Android launcher icon from the team logo (assets/images/logo.png).
 
Run by GitHub Actions before the build. It keeps the emblem of the logo (the
astronaut and the cross, without the name) and writes:
- the classic icons, res/mipmap-*/ic_launcher.png;
- the adaptive icon (Android 8 and later): a Deep Blue background color and the
  emblem as foreground.
The images are written first and the XML files last, so a failure halfway leaves the
default icon in place and never breaks the build.
"""
import os
 
from PIL import Image
 
LOGO = "assets/images/logo.png"
RES = "android/app/src/main/res"
DEEP_BLUE = (7, 23, 63, 255)
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
 
logo = Image.open(LOGO).convert("RGBA")
width, height = logo.size
alpha = logo.getchannel("A")
 
# The emblem is above the name. The emptiest row of pixels between 50 % and 80 % of
# the height separates them.
rows = [sum(alpha.crop((0, y, width, y + 1)).getdata()) for y in range(height)]
cut = min(range(int(height * 0.5), int(height * 0.8)), key=lambda y: rows[y])
emblem = logo.crop((0, 0, width, cut))
emblem = emblem.crop(emblem.getbbox())
 
 
def square(size, share, background):
    """Square image with the emblem centered, taking [share] of the width."""
    canvas = Image.new("RGBA", (size, size), background)
    scale = size * share / max(emblem.size)
    w = max(1, round(emblem.width * scale))
    h = max(1, round(emblem.height * scale))
    small = emblem.resize((w, h), Image.LANCZOS)
    canvas.alpha_composite(small, ((size - w) // 2, (size - h) // 2))
    return canvas
for name, factor in DENSITIES.items():
    os.makedirs(f"{RES}/mipmap-{name}", exist_ok=True)
    os.makedirs(f"{RES}/drawable-{name}", exist_ok=True)
    square(round(48 * factor), 0.84, DEEP_BLUE).save(f"{RES}/mipmap-{name}/ic_launcher.png")
    square(round(108 * factor), 0.56, (0, 0, 0, 0)).save(
        f"{RES}/drawable-{name}/ic_launcher_foreground.png"
    )
 
os.makedirs(f"{RES}/values", exist_ok=True)
with open(f"{RES}/values/ic_launcher_background.xml", "w", encoding="utf-8") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        '    <color name="ic_launcher_background">#07173F</color>\n'
        "</resources>\n"
    )
os.makedirs(f"{RES}/mipmap-anydpi-v26", exist_ok=True)
with open(f"{RES}/mipmap-anydpi-v26/ic_launcher.xml", "w", encoding="utf-8") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@drawable/ic_launcher_foreground"/>\n'
        "</adaptive-icon>\n"
    )
print("Launcher icon written from", LOGO)
