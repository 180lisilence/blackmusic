# -*- coding: utf-8 -*-
"""黑马云音乐 资源生成器：SVG 图标 + 渐变封面/横幅/启动图。"""
import os, math, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont

BASE = r"E:\2026music\entry\src\main\resources\base\media"
os.makedirs(BASE, exist_ok=True)

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\msyhbd.ttc", r"C:\Windows\Fonts\msyh.ttc",
    r"C:\Windows\Fonts\simhei.ttf", r"C:\Windows\Fonts\Deng.ttf",
]

def font(size):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()

# ---------------------------------------------------------------- SVG icons
ICONS = {
    "ic_tab_recommend": '<path d="M9 18.5V6.8l9-2.2v11.6a3 3 0 1 1-1.6-2.65V8.4l-5.8 1.4v8.1A2.9 2.9 0 1 1 9 18.5Z"/>',
    "ic_tab_find": '<path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm0 3.2 1.5 4.4 4.6.2-3.6 2.9 1.2 4.5-3.7-2.8-3.8 2.8 1.3-4.5-3.6-2.9 4.6-.2L12 5.2Z"/>',
    "ic_tab_moment": '<path d="M4 4h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H9.2L4.6 20.6A1 1 0 0 1 3 19.9V6a2 2 0 0 1 1-2Z"/>',
    "ic_tab_mine": '<path d="M12 12.4a4.6 4.6 0 1 0 0-9.2 4.6 4.6 0 0 0 0 9.2Zm0 1.8c-4.6 0-8.4 2.5-8.4 5.6V22h16.8v-2.2c0-3.1-3.8-5.6-8.4-5.6Z"/>',
    "ic_search": '<path d="M10.5 3a7.5 7.5 0 0 1 5.9 12.1l4.3 4.3-1.5 1.5-4.3-4.3A7.5 7.5 0 1 1 10.5 3Zm0 2.2a5.3 5.3 0 1 0 0 10.6 5.3 5.3 0 0 0 0-10.6Z"/>',
    "ic_scan": '<path d="M3 3h6v2H5v4H3V3Zm12 0h6v6h-2V5h-4V3ZM3 15h2v4h4v2H3v-6Zm16 0h2v6h-6v-2h4v-4ZM3 11h18v2H3v-2Z"/>',
    "ic_more": '<path d="M6 10a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm6 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Zm6 0a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z"/>',
    "ic_play": '<path d="M7 4.5v15l13-7.5-13-7.5Z"/>',
    "ic_pause": '<path d="M7 4h3.6v16H7V4Zm6.4 0H17v16h-3.6V4Z"/>',
    "ic_prev": '<path d="M18 5v14l-9-7 9-7ZM6 5h2.2v14H6V5Z"/>',
    "ic_next": '<path d="M6 5v14l9-7-9-7Zm9.8 0H18v14h-2.2V5Z"/>',
    "ic_heart": '<path d="M12 20.6 3.9 12.9a5.4 5.4 0 0 1 7.6-7.6l.5.5.5-.5a5.4 5.4 0 0 1 7.6 7.6L12 20.6Z"/>',
    "ic_comment": '<path d="M12 3c5 0 9 3.5 9 7.8 0 4.3-4 7.8-9 7.8a11 11 0 0 1-2.8-.4l-4 1.8 1-3.4A7.3 7.3 0 0 1 3 10.8C3 6.5 7 3 12 3Z"/>',
    "ic_share": '<path d="M14 3 21 9.6l-7 6.6v-4.1c-4.4 0-7.6 1.5-10 4.9.7-5.9 4-9.9 10-10.4V3Z"/>',
    "ic_back": '<path d="M15.4 3.6 7 12l8.4 8.4 1.6-1.6L10.2 12 17 5.2l-1.6-1.6Z"/>',
    "ic_note": '<path d="M9 18.5V6.8l9-2.2v11.6a3 3 0 1 1-1.6-2.65V8.4l-5.8 1.4v8.1A2.9 2.9 0 1 1 9 18.5Z"/>',
    "ic_clock": '<path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1.1 4.3v5.3l4 2.4-1.1 1.8-5-3V6.3h2.1Z"/>',
    "ic_star": '<path d="m12 2.6 2.9 5.9 6.5.9-4.7 4.6 1.1 6.5-5.8-3.1-5.8 3.1 1.1-6.5L2.6 9.4l6.5-.9L12 2.6Z"/>',
    "ic_setting": '<path d="M12 8.4a3.6 3.6 0 1 0 0 7.2 3.6 3.6 0 0 0 0-7.2Zm9 4.9v-2.6l-2.3-.5a6.9 6.9 0 0 0-.8-1.9l1.2-2-1.8-1.8-2 1.2a6.9 6.9 0 0 0-1.9-.8L12.9 2.7h-2.6l-.5 2.3a6.9 6.9 0 0 0-1.9.8l-2-1.2L4.1 6.4l1.2 2a6.9 6.9 0 0 0-.8 1.9l-2.3.5v2.6l2.3.5a6.9 6.9 0 0 0 .8 1.9l-1.2 2 1.8 1.8 2-1.2c.6.3 1.2.6 1.9.8l.5 2.3h2.6l.5-2.3c.7-.2 1.3-.5 1.9-.8l2 1.2 1.8-1.8-1.2-2c.3-.6.6-1.2.8-1.9l2.3-.5Z"/>',
    "ic_crown": '<path d="M3 8.2 7.4 11 12 5l4.6 6L21 8.2 19.3 18H4.7L3 8.2Z"/>',
    "ic_list": '<path d="M3 6h12v2H3V6Zm0 5h12v2H3v-2Zm0 5h8v2H3v-2Zm14.4-9.2a3 3 0 1 1 0 6 3 3 0 0 1 0-6ZM20 18.4V6l-2.4.8v10.4a2.4 2.4 0 1 1-1-1.9V5.2L21.6 4v13.4A2.4 2.4 0 1 1 20 18.4Z"/>',
    "ic_music_play": '<path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm-1.6 5.4 7 4.6-7 4.6V7.4Z"/>',
}
for name, body in ICONS.items():
    svg = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
           'width="24" height="24"><g fill="#FFFFFF">' + body + '</g></svg>\n')
    with open(os.path.join(BASE, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(svg)

# ---------------------------------------------------------------- helpers
def gradient(size, c1, c2, angle=135):
    """numpy 逐像素线性渐变，无接缝。"""
    import numpy as np
    w, h = size
    a = math.radians(angle)
    xs = np.arange(w, dtype=np.float32)[None, :]
    ys = np.arange(h, dtype=np.float32)[:, None]
    t = xs * math.cos(a) + ys * math.sin(a)
    t = (t - t.min()) / max(1e-6, (t.max() - t.min()))
    t = t[..., None]
    arr = (np.array(c1, dtype=np.float32) * (1 - t) + np.array(c2, dtype=np.float32) * t)
    arr = np.clip(arr, 0, 255).astype(np.uint8)
    return Image.fromarray(arr, "RGB")

def ring(img, cx, cy, r, color, width=6, alpha=70):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=color + (alpha,), width=width)
    return Image.alpha_composite(img.convert("RGBA"), layer)

def glow(img, cx, cy, r, color, alpha=120):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color + (alpha,))
    layer = layer.filter(ImageFilter.GaussianBlur(r * 0.45))
    return Image.alpha_composite(img.convert("RGBA"), layer)

def text(draw, xy, s, size, fill=(255, 255, 255, 255), anchor="la"):
    draw.text(xy, s, font=font(size), fill=fill, anchor=anchor)

def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m

# ---------------------------------------------------------------- covers
PALETTES = [
    ((232, 88, 138), (72, 34, 96)),
    ((58, 199, 255), (18, 32, 74)),
    ((123, 92, 255), (26, 18, 62)),
    ((255, 154, 92), (78, 28, 44)),
    ((86, 224, 178), (14, 52, 52)),
    ((255, 205, 96), (74, 42, 20)),
    ((180, 120, 255), (34, 22, 60)),
    ((80, 132, 255), (16, 26, 58)),
]

def cover(path, title, sub, palette, size=600, badge=None):
    c1, c2 = palette
    img = gradient((size, size), c2, c1, angle=115)
    cx, cy = int(size * 0.68), int(size * 0.34)
    img = glow(img, cx, cy, int(size * 0.34), c1, 110)
    for i, r in enumerate((0.42, 0.31, 0.2)):
        img = ring(img, cx, cy, int(size * r), (255, 255, 255), width=max(2, size // 180), alpha=54 - i * 10)
    d = ImageDraw.Draw(img)
    # bottom shade for text legibility
    shade = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for i in range(int(size * 0.42)):
        a = int(170 * (1 - i / (size * 0.42)) ** 1.7)
        sd.line([(0, size - i), (size, size - i)], fill=(0, 0, 0, a))
    img = Image.alpha_composite(img.convert("RGBA"), shade)
    d = ImageDraw.Draw(img)
    text(d, (size * 0.075, size * 0.07), "黑马云音乐", max(14, size // 34), (255, 255, 255, 190))
    text(d, (size * 0.075, size * 0.80), title, max(22, size // 11), (255, 255, 255, 255))
    if sub:
        text(d, (size * 0.075, size * 0.895), sub, max(13, size // 26), (255, 255, 255, 170))
    if badge:
        d.rounded_rectangle([size * 0.74, size * 0.07, size * 0.93, size * 0.15],
                            radius=size // 40, fill=(0, 0, 0, 110))
        text(d, (size * 0.835, size * 0.11), badge, max(11, size // 34), (255, 255, 255, 230), anchor="mm")
    img.convert("RGB").save(os.path.join(BASE, path), quality=92, optimize=True)

def banner(path, title, subtitle, palette, size=(1080, 560)):
    c1, c2 = palette
    img = gradient(size, c2, c1, angle=100)
    w, h = size
    img = glow(img, int(w * 0.78), int(h * 0.28), int(h * 0.42), c1, 120)
    for r in (0.3, 0.22, 0.14):
        img = ring(img, int(w * 0.78), int(h * 0.28), int(h * r), (255, 255, 255), width=4, alpha=60)
    shade = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for i in range(int(w * 0.55)):
        a = int(150 * (1 - i / (w * 0.55)) ** 1.6)
        sd.line([(i, 0), (i, h)], fill=(0, 0, 0, a))
    img = Image.alpha_composite(img.convert("RGBA"), shade)
    d = ImageDraw.Draw(img)
    text(d, (w * 0.06, h * 0.30), title, 46, (255, 255, 255, 255))
    text(d, (w * 0.06, h * 0.49), subtitle, 26, (255, 255, 255, 200))
    d.rounded_rectangle([w * 0.06, h * 0.66, w * 0.28, h * 0.80], radius=26, fill=(228, 96, 139, 235))
    text(d, (w * 0.17, h * 0.73), "立即播放", 22, (255, 255, 255, 255), anchor="mm")
    img.convert("RGB").save(os.path.join(BASE, path), quality=92, optimize=True)

def avatar(path, letter, palette, size=240):
    c1, c2 = palette
    img = gradient((size, size), c1, c2, angle=140)
    img = glow(img, int(size * 0.3), int(size * 0.25), int(size * 0.4), c1, 110)
    d = ImageDraw.Draw(img)
    text(d, (size / 2, size / 2), letter, int(size * 0.42), (255, 255, 255, 240), anchor="mm")
    img = img.convert("RGB")
    img.putalpha(rounded_mask((size, size), size // 2))
    img.save(os.path.join(BASE, path), optimize=True)

def splash(path, size=(1080, 2340)):
    w, h = size
    img = gradient(size, (10, 10, 14), (52, 18, 46), angle=105)
    img = glow(img, int(w * 0.5), int(h * 0.34), int(w * 0.42), (228, 96, 139), 96)
    img = glow(img, int(w * 0.24), int(h * 0.72), int(w * 0.3), (58, 120, 255), 70)
    for r in (0.46, 0.36, 0.28, 0.2):
        img = ring(img, int(w * 0.5), int(h * 0.34), int(w * r), (255, 255, 255), width=4, alpha=46)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([w * 0.5 - 84, h * 0.335 - 84, w * 0.5 + 84, h * 0.335 + 84],
                        radius=48, fill=(255, 255, 255, 26))
    d.ellipse([w * 0.5 - 34, h * 0.335 - 34, w * 0.5 + 34, h * 0.335 + 34], fill=(228, 96, 139, 255))
    d.polygon([(w * 0.5 - 9, h * 0.335 - 18), (w * 0.5 + 20, h * 0.335),
               (w * 0.5 - 9, h * 0.335 + 18)], fill=(255, 255, 255, 255))
    text(d, (w / 2, h * 0.50), "黑马云音乐", 84, (255, 255, 255, 255), anchor="mm")
    text(d, (w / 2, h * 0.555), "HEIMA  CLOUD  MUSIC", 28, (255, 255, 255, 150), anchor="mm")
    text(d, (w / 2, h * 0.905), "听见每一次心动", 30, (255, 255, 255, 165), anchor="mm")
    img.convert("RGB").save(os.path.join(BASE, path), quality=92, optimize=True)

def mine_bg(path, size=(1080, 1920)):
    w, h = size
    img = gradient(size, (12, 12, 16), (44, 26, 54), angle=115)
    img = glow(img, int(w * 0.2), int(h * 0.08), int(w * 0.5), (228, 96, 139), 90)
    img = glow(img, int(w * 0.85), int(h * 0.3), int(w * 0.45), (90, 80, 255), 80)
    rnd = random.Random(7)
    for _ in range(26):
        x = rnd.randint(0, w); y = rnd.randint(0, int(h * 0.75)); r = rnd.randint(2, 7)
        glow_v = Image.new("RGBA", (r * 4, r * 4), (0, 0, 0, 0))
        ImageDraw.Draw(glow_v).ellipse([r, r, r * 3, r * 3], fill=(255, 255, 255, 120))
        img.alpha_composite(glow_v, (x, y)) if hasattr(img, "alpha_composite") else None
    img = img.convert("RGB").filter(ImageFilter.GaussianBlur(0.4))
    shade = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for i in range(int(h * 0.55)):
        a = int(200 * (1 - i / (h * 0.55)) ** 1.9)
        sd.line([(0, h - i), (w, h - i)], fill=(0, 0, 0, a))
    img = Image.alpha_composite(img.convert("RGBA"), shade)
    img.convert("RGB").save(os.path.join(BASE, path), quality=90, optimize=True)

def app_icon():
    size = 1024
    bg = gradient((size, size), (20, 12, 24), (72, 22, 48), angle=130)
    bg = glow(bg, size // 2, int(size * 0.45), size // 3, (228, 96, 139), 130)
    bg.convert("RGB").save(os.path.join(BASE, "background.png"))
    fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(fg)
    d.ellipse([size * 0.22, size * 0.22, size * 0.78, size * 0.78], fill=(255, 255, 255, 28))
    d.ellipse([size * 0.35, size * 0.35, size * 0.65, size * 0.65], fill=(228, 96, 139, 255))
    d.polygon([(size * 0.465, size * 0.40), (size * 0.60, size * 0.50), (size * 0.465, size * 0.60)],
              fill=(255, 255, 255, 255))
    fg.save(os.path.join(BASE, "foreground.png"))
    fg.save(os.path.join(BASE, "startIcon.png"))

# ---------------------------------------------------------------- emit
banners = [
    ("banner_1.jpg", "每日推荐", "今天从《逐梦星辰》听起", PALETTES[0]),
    ("banner_2.jpg", "私人漫游", "从《彩虹之旅》开启无限漫游", PALETTES[2]),
    ("banner_3.jpg", "华语流行", "每日推荐《快乐无界》", PALETTES[3]),
]
for name, t, s, p in banners:
    banner(name, t, s, p)

dailies = [
    ("daily_1.jpg", "每日推荐", "从《逐梦星辰》听起", PALETTES[0]),
    ("daily_2.jpg", "私人漫游", "从《彩虹之旅》开启", PALETTES[1]),
    ("daily_3.jpg", "华语流行", "《快乐无界》", PALETTES[5]),
]
for name, t, s, p in dailies:
    cover(name, t, s, p, size=560)

playlists = [
    ("playlist_1.jpg", "深夜慢摇", "270.9万", PALETTES[3]),
    ("playlist_2.jpg", "星际旅途", "476.1万", PALETTES[2]),
    ("playlist_3.jpg", "City Pop", "188.4万", PALETTES[1]),
    ("playlist_4.jpg", "启程", "92.6万", PALETTES[4]),
    ("playlist_5.jpg", "雨后电台", "133.7万", PALETTES[6]),
    ("playlist_6.jpg", "慢速呼吸", "61.2万", PALETTES[7]),
]
for name, t, s, p in playlists:
    cover(name, t, "", p, size=560, badge=s)

songs = ["逐梦星辰", "彩虹之旅", "快乐无界", "晚风与海",
         "银河列车", "山与雾", "青柠汽水", "十七号公路"]
for i, t in enumerate(songs, 1):
    cover("cover_%d.jpg" % i, t, "黑马唱片", PALETTES[(i - 1) % len(PALETTES)], size=520)

authors = [("avatar_1.png", "树", PALETTES[4]), ("avatar_2.png", "满", PALETTES[0]),
           ("avatar_3.png", "云", PALETTES[2]), ("avatar_4.png", "马", PALETTES[3])]
for name, letter, p in authors:
    avatar(name, letter, p)

splash("splash.jpg")
mine_bg("mine_bg.jpg")
app_icon()
print("done:", len(os.listdir(BASE)), "media files")

