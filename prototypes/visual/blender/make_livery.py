"""Rasterize the supplied Colonel vector and lay out original vehicle paint maps.

This creates material assets, not an edited reference photograph. The owner's
kfc_racer_van.png remains untouched. Run with the workstation Python/Pillow.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont, ImageChops

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "blender" / "export"
OUT.mkdir(parents=True, exist_ok=True)
RED = (192, 12, 29, 255)
WHITE = (249, 246, 235, 255)


def contours(data):
    tokens = re.findall(r"[MmCcSsZz]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?", data)
    i, command, point, start, control = 0, None, (0, 0), (0, 0), None
    loops, loop = [], []
    while i < len(tokens):
        if tokens[i].isalpha():
            command = tokens[i]
            i += 1
        if command.lower() == "z":
            if loop:
                loops.append(loop)
            loop, point, control, command = [], start, None, None
            continue
        relative = command.islower()
        count = {"m": 2, "l": 2, "c": 6, "s": 4}[command.lower()]
        values = [float(v) for v in tokens[i:i + count]]
        i += count
        pairs = [(values[j], values[j + 1]) for j in range(0, count, 2)]
        if relative:
            pairs = [(x + point[0], y + point[1]) for x, y in pairs]
        if command.lower() == "m":
            if loop:
                loops.append(loop)
            point = start = pairs[0]
            loop = [point]
            control = None
            command = "l" if relative else "L"
        elif command.lower() == "l":
            point, control = pairs[0], None
            loop.append(point)
        else:
            p0 = point
            if command.lower() == "s":
                p1 = (2 * point[0] - control[0], 2 * point[1] - control[1]) if control else point
                p2, p3 = pairs
            else:
                p1, p2, p3 = pairs
            for step in range(1, 13):
                t = step / 12
                loop.append(tuple((1-t)**3*p0[k] + 3*(1-t)**2*t*p1[k] + 3*(1-t)*t*t*p2[k] + t**3*p3[k] for k in (0, 1)))
            point, control = p3, p2
    if loop:
        loops.append(loop)
    return loops


def colonel():
    svg = ET.parse(ROOT / "references" / "colonel-portrait.svg").getroot()
    scale = 4
    size = (round(317.3 * scale), round(563.6 * scale))
    art = Image.new("RGBA", size)
    for element in svg.iter():
        if not element.tag.endswith("path"):
            continue
        mask = Image.new("1", size)
        for loop in contours(element.attrib["d"]):
            layer = Image.new("1", size)
            ImageDraw.Draw(layer).polygon([(x * scale, y * scale) for x, y in loop], fill=1)
            mask = ImageChops.logical_xor(mask, layer)
        fill = WHITE if element.get("class") == "st0" else (12, 13, 15, 255)
        art.paste(fill, (0, 0), mask.convert("L"))
    art.save(OUT / "colonel-raster.png")
    return art


def font(size, italic=False):
    name = "cambriaz.ttf" if italic else "arialbd.ttf"
    return ImageFont.truetype(str(Path("C:/Windows/Fonts") / name), size)


def fries(canvas, center):
    # Original illustrated food graphic: white/red carton with shaded golden fries.
    x, y = center
    draw = ImageDraw.Draw(canvas)
    for index in range(14):
        left = x - 95 + index * 14
        top = y - 145 + ((index * 37) % 70)
        draw.polygon([(left, top), (left+13, top-4), (left+32, y+15), (left+17, y+18)], fill=(236, 165, 27, 255))
        draw.line([(left+3, top+3), (left+20, y+6)], fill=(255, 213, 93, 255), width=4)
    draw.polygon([(x-102,y-20),(x+122,y-30),(x+82,y+133),(x-58,y+148)], fill=WHITE)
    for offset in (-70, -15, 40):
        draw.polygon([(x+offset,y-22),(x+offset+22,y-24),(x+offset+12,y+139),(x+offset-4,y+141)], fill=RED)
    draw.text((x+10,y+35), "KFC", font=font(47,True), fill=(35,25,22,255), anchor="mm")


def side(portrait, right=False):
    image = Image.new("RGBA", (2048, 1024), RED)
    art = portrait.resize((430, 765), Image.Resampling.LANCZOS)
    # Separate arrangements, not mirrored text. Rear portrait stays at rear on both sides.
    image.alpha_composite(art, (1338 if right else 260, 128))
    d = ImageDraw.Draw(image)
    d.text((1150 if right else 990, 512), "KFC", font=font(112,True), fill=WHITE, anchor="mm")
    d.text((975 if right else 1100, 196), "it's finger lickin' good", font=font(47,True), fill=WHITE, anchor="mm")
    fries(image, (725 if right else 1390, 620))
    little = portrait.resize((63,112), Image.Resampling.LANCZOS)
    image.alpha_composite(little, (190 if right else 1770, 600))
    image.save(OUT / ("body_right.png" if right else "body_left.png"))


portrait = colonel()
side(portrait)
side(portrait, True)
front = Image.new("RGBA", (1024,512), RED)
d = ImageDraw.Draw(front)
d.text((512,85), "KFC", font=font(125,True), fill=WHITE, anchor="mm")
front.save(OUT / "body_front.png")
roof = Image.new("RGBA", (1024,2048), RED)
roof.alpha_composite(portrait.resize((560,994),Image.Resampling.LANCZOS),(232,730))
ImageDraw.Draw(roof).text((512,420),"KFC",font=font(210,True),fill=WHITE,anchor="mm")
roof.save(OUT / "body_roof.png")
print("Created separate left/right UV paint maps, front/roof maps and Colonel raster")
