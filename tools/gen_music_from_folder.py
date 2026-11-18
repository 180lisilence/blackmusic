# -*- coding: utf-8 -*-
"""把 music/ 与 png/ 里的真实素材整理成后端数据：音频改名上传、壁纸做封面、写出五个接口的 JSON。"""
import json, os, re, shutil
from mutagen.mp3 import MP3

ROOT = r"E:\2026music"
MUSIC = os.path.join(ROOT, "music")
PNG = os.path.join(ROOT, "png")
OUT = os.path.join(ROOT, "deploy", "music-server")
AUDIO_OUT = os.path.join(OUT, "public", "audio")
IMG_OUT = os.path.join(OUT, "public", "images")
DATA_OUT = os.path.join(OUT, "data")
BASE = "http://example.com/music"

for d in (AUDIO_OUT, IMG_OUT, DATA_OUT):
    os.makedirs(d, exist_ok=True)

# ---------------------------------------------------------------- 音频整理
def clean_title(name):
    n = os.path.splitext(name)[0]
    n = n.replace("_325771", "")
    n = re.sub(r"\s*\(\d+\)\s*", "", n)
    n = n.strip(" -")
    return n

tracks = []
seen = set()
for fn in sorted(os.listdir(MUSIC)):
    if not fn.lower().endswith(".mp3"):
        continue
    path = os.path.join(MUSIC, fn)
    title = clean_title(fn)
    key = title.lower()
    if key in seen:
        continue
    seen.add(key)
    try:
        dur = int(round(MP3(path).info.length))
    except Exception:
        dur = 0
    core = title
    artist = "未知歌手"
    if " - " in title:
        # 形如「歌手 - 歌名」
        left, right = title.split(" - ", 1)
        core, artist = right.strip(), left.strip()
    elif "-" in title:
        # 形如「歌名-歌手」
        left, right = title.split("-", 1)
        if 0 < len(left) <= 20 and 0 < len(right) <= 16:
            core, artist = left.strip(), right.strip()
    tracks.append({"file": path, "title": core, "artist": artist, "duration": dur})

# 时长排序，时长过短的（提示音）排后
tracks.sort(key=lambda t: -t["duration"])

songs = []
for i, t in enumerate(tracks):
    idx = i + 1
    audio_name = "song_%d.mp3" % idx
    shutil.copy2(t["file"], os.path.join(AUDIO_OUT, audio_name))
    songs.append({
        "id": idx,
        "title": t["title"],
        "artist": t["artist"],
        "album": "黑马精选",
        "duration": t["duration"],
        "url": BASE + "/audio/" + audio_name,
        "cover": None,  # 下面用壁纸填
    })

# ---------------------------------------------------------------- 封面/壁纸
walls = sorted([f for f in os.listdir(PNG) if f.lower().endswith((".jpg", ".jpeg", ".png"))])
wall_urls = []
for i, fn in enumerate(walls):
    ext = os.path.splitext(fn)[1].lower()
    name = "wall_%02d%s" % (i + 1, ext)
    shutil.copy2(os.path.join(PNG, fn), os.path.join(IMG_OUT, name))
    wall_urls.append(BASE + "/images/" + name)

if not wall_urls:
    wall_urls = [BASE + "/images/cover_1.jpg"]

for i, s in enumerate(songs):
    s["cover"] = wall_urls[i % len(wall_urls)]

# ---------------------------------------------------------------- 其它接口
swiper = [
    {"id": 1, "title": "今日推荐", "subtitle": songs[0]["title"] + " · " + songs[0]["artist"],
     "image": wall_urls[0]},
    {"id": 2, "title": "私人漫游", "subtitle": "为你挑选的 " + str(len(songs)) + " 首",
     "image": wall_urls[1 % len(wall_urls)]},
    {"id": 3, "title": "华语流行", "subtitle": "每日更新",
     "image": wall_urls[2 % len(wall_urls)]},
]

daily = [
    {"id": 1, "title": "每日推荐", "desc": songs[1]["title"] + " 听起", "cover": songs[1]["cover"]},
    {"id": 2, "title": "私人漫游", "desc": "从《" + songs[2]["title"] + "》开始", "cover": songs[2]["cover"]},
    {"id": 3, "title": "华语流行", "desc": "《" + songs[3]["title"] + "》", "cover": songs[3]["cover"]},
]

playlists = []
for i in range(6):
    s = songs[i % len(songs)]
    playlists.append({
        "id": i + 1,
        "title": s["title"] + " · 精选集",
        "count": "%d.%d万" % (30 + i * 17, i * 3 + 1),
        "cover": wall_urls[(i + 3) % len(wall_urls)],
    })

moments = [
    {"id": 1, "avatar": wall_urls[0], "author": "阿树",
     "content": "把这首放进深夜歌单，" + songs[0]["title"] + " 一响就安静了。",
     "publishedAt": "2 小时前", "song": songs[0], "likes": 1286, "comments": 233, "shares": 45},
    {"id": 2, "avatar": wall_urls[1 % len(wall_urls)], "author": "小满",
     "content": "通勤路上单曲循环，地铁都坐过站。",
     "publishedAt": "5 小时前", "song": songs[1 % len(songs)], "likes": 864, "comments": 102, "shares": 18},
    {"id": 3, "avatar": wall_urls[2 % len(wall_urls)], "author": "云雀",
     "content": "编曲很克制，越听越上头。",
     "publishedAt": "昨天 22:40", "song": songs[2 % len(songs)], "likes": 2031, "comments": 356, "shares": 88},
    {"id": 4, "avatar": wall_urls[3 % len(wall_urls)], "author": "老马",
     "content": "推荐给所有需要一点光的人。",
     "publishedAt": "昨天 19:12", "song": songs[3 % len(songs)], "likes": 512, "comments": 61, "shares": 9},
]

for name, payload in [("songs.json", songs), ("swiper.json", swiper), ("daily.json", daily),
                      ("playlists.json", playlists), ("moments.json", moments)]:
    with open(os.path.join(DATA_OUT, name), "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

print("songs:", len(songs), "walls:", len(wall_urls))
for s in songs[:5]:
    print("  %-14s %-10s %ss  %s" % (s["title"], s["artist"], s["duration"], s["url"].split("/")[-1]))

