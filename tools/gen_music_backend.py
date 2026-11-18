# -*- coding: utf-8 -*-
"""生成音乐后端静态数据（图片走公网绝对地址）。"""
import json, os, shutil

BASE = "http://example.com/music"
SRC = r"E:\2026music\entry\src\main\resources\base\media"
OUT = r"E:\2026music\deploy\music-server"
IMG = os.path.join(OUT, "public", "images")
DATA = os.path.join(OUT, "data")
os.makedirs(IMG, exist_ok=True)
os.makedirs(DATA, exist_ok=True)

IMAGES = ["banner_1.jpg", "banner_2.jpg", "banner_3.jpg", "daily_1.jpg", "daily_2.jpg", "daily_3.jpg",
          "playlist_1.jpg", "playlist_2.jpg", "playlist_3.jpg", "playlist_4.jpg", "playlist_5.jpg", "playlist_6.jpg",
          "cover_1.jpg", "cover_2.jpg", "cover_3.jpg", "cover_4.jpg", "cover_5.jpg", "cover_6.jpg", "cover_7.jpg", "cover_8.jpg",
          "avatar_1.png", "avatar_2.png", "avatar_3.png", "avatar_4.png", "mine_bg.jpg", "splash.jpg"]
for n in IMAGES:
    src = os.path.join(SRC, n)
    if os.path.exists(src):
        shutil.copy2(src, os.path.join(IMG, n))

def img(n):
    return BASE + "/images/" + n

swiper = [
    {"id": 1, "title": "每日推荐", "subtitle": "今天从《逐梦星辰》听起", "image": img("banner_1.jpg")},
    {"id": 2, "title": "私人漫游", "subtitle": "从《彩虹之旅》开启无限漫游", "image": img("banner_2.jpg")},
    {"id": 3, "title": "华语流行", "subtitle": "每日推荐《快乐无界》", "image": img("banner_3.jpg")},
]

daily = [
    {"id": 1, "title": "每日推荐", "desc": "今天从《逐梦星辰》听起！", "cover": img("daily_1.jpg")},
    {"id": 2, "title": "私人漫游", "desc": "从《彩虹之旅》开启无限漫游", "cover": img("daily_2.jpg")},
    {"id": 3, "title": "华语流行", "desc": "每日推荐《快乐无界》", "cover": img("daily_3.jpg")},
]

playlists = [
    {"id": 1, "title": "深夜慢摇", "count": "270.9万", "cover": img("playlist_1.jpg")},
    {"id": 2, "title": "星际旅途", "count": "476.1万", "cover": img("playlist_2.jpg")},
    {"id": 3, "title": "City Pop 夜行", "count": "188.4万", "cover": img("playlist_3.jpg")},
    {"id": 4, "title": "启程", "count": "92.6万", "cover": img("playlist_4.jpg")},
    {"id": 5, "title": "雨后电台", "count": "133.7万", "cover": img("playlist_5.jpg")},
    {"id": 6, "title": "慢速呼吸", "count": "61.2万", "cover": img("playlist_6.jpg")},
]

songs = [
    {"id": 1, "title": "逐梦星辰", "artist": "云雀合唱团", "cover": img("cover_1.jpg"), "duration": 252},
    {"id": 2, "title": "彩虹之旅", "artist": "林夕", "cover": img("cover_2.jpg"), "duration": 228},
    {"id": 3, "title": "快乐无界", "artist": "黑马乐队", "cover": img("cover_3.jpg"), "duration": 245},
    {"id": 4, "title": "晚风与海", "artist": "陈一", "cover": img("cover_4.jpg"), "duration": 212},
    {"id": 5, "title": "银河列车", "artist": "苏眠", "cover": img("cover_5.jpg"), "duration": 266},
    {"id": 6, "title": "山与雾", "artist": "白昼", "cover": img("cover_6.jpg"), "duration": 237},
    {"id": 7, "title": "青柠汽水", "artist": "小满", "cover": img("cover_7.jpg"), "duration": 198},
    {"id": 8, "title": "十七号公路", "artist": "远方", "cover": img("cover_8.jpg"), "duration": 280},
]

moments = [
    {"id": 1, "avatar": img("avatar_1.png"), "author": "阿树", "content": "今天循环了一整天，副歌一响整个人都亮了。",
     "publishedAt": "2 小时前", "song": songs[0], "likes": 1286, "comments": 233, "shares": 45},
    {"id": 2, "avatar": img("avatar_2.png"), "author": "小满", "content": "通勤路上单曲循环，地铁都坐过站了。",
     "publishedAt": "5 小时前", "song": songs[6], "likes": 864, "comments": 102, "shares": 18},
    {"id": 3, "avatar": img("avatar_3.png"), "author": "云雀", "content": "把这首放进深夜歌单，闭眼就是星空。",
     "publishedAt": "昨天 22:40", "song": songs[4], "likes": 2031, "comments": 356, "shares": 88},
    {"id": 4, "avatar": img("avatar_4.png"), "author": "老马", "content": "编曲太克制了，越听越上头。",
     "publishedAt": "昨天 19:12", "song": songs[7], "likes": 512, "comments": 61, "shares": 9},
]

for name, payload in [("swiper.json", swiper), ("daily.json", daily), ("playlists.json", playlists),
                      ("songs.json", songs), ("moments.json", moments)]:
    with open(os.path.join(DATA, name), "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

print("images:", len(os.listdir(IMG)), "data files:", os.listdir(DATA))
