# 无服务器本地版（local 分支）调研方案

> 状态：**调研阶段**，本文件只记录现状、方案、风险与待拍板项，业务代码尚未改造。
> 分支：`local`　副本目录：`E:\2026music-local`　主干对照：`E:\2026music`（main）

## 1. 目标

去掉对公网后端与网络的依赖，App 直接读取打包进 HAP 包内的音频 mp3 与封面图片素材：
- 不发 HTTP 请求，不连 `206.187.214.190/music`；
- 5 份列表数据（轮播 / 每日推荐 / 推荐歌单 / 歌曲 / 动态）从包内 JSON 读取；
- 音频、封面、头像全部来自包内资源。

## 2. 现状：远程依赖点（main 分支链路）

```
DataStore.preloadAll()
  └─ 5 个 getXxx() in MusicApi
       └─ HttpClient.httpGet(path)  拼 getBaseUrl() + 端点
            └─ http.request 公网 JSON
                 └─ 解析（字段别名兼容）→ 模型；封面/音频为 http URL 字符串
                      └─ 失败回退内置 mock（$r 占位图，url 为空字符串）
```

涉及文件（`entry/src/main/ets/`）：

| 文件 | 现状职责 | 本地版处置 |
| --- | --- | --- |
| `common/DataStore.ets` | 并行取 5 类数据写 AppStorage | 基本不变，仅数据源换成本地 |
| `api/MusicApi.ets` | 5 端点 HTTP 取数 + 解析 + mock 兜底 | 改为读 rawfile JSON；解析器复用 |
| `api/HttpClient.ets` | http 拼接与请求 | 本地版不再调用（可保留备用） |
| `common/AppConfig.ets` | baseUrl 存取、Preferences | 本地版去掉服务器地址探测/保存 |
| `common/Nav.ets` | 路由携带 PlayerParams（含 cover/url） | 字段语义改为本地资源标识 |
| `models/MusicModels.ets` | cover: ResourceStr、avatar: ResourceStr、url: string | 模型结构可不动，url/cover 取值改为本地标识 |
| `player/MusicPlayer.ets` | `load(url)` → `player.url = url`，事件驱动状态机 | 增加 rawfile fd 播放分支 |
| `views/*`、`pages/*` | `Image(item.cover)` / `Image(song.cover)` 渲染 | 适配本地资源引用 |

## 3. 包内资源规划（rawfile）

```
entry/src/main/resources/rawfile/
  data/
    swiper.json        # 轮播
    daily.json         # 每日推荐
    playlists.json     # 推荐歌单
    songs.json         # 歌曲列表
    moments.json       # 动态（含内嵌 song）
  audio/
    song_1.mp3 ... song_12.mp3
  images/
    wall_01.jpg ... wall_21.jpg
```

- rawfile 原样打包、不做索引编译，适合放 mp3 / 大图 / JSON；
- 文件名统一用 ASCII（`song_N.mp3`、`wall_NN.jpg`），避免中文、空格、括号在不同运行时下的编码问题；
- JSON 内的 `url` / `cover` / `image` / `avatar` 字段由公网 URL 改为包内相对标识，例如：
  - 音频：`audio/song_1.mp3`
  - 封面：`images/wall_01.jpg`

## 4. 素材现状与归置依据

| 素材 | 位置 | 数量 | 体积 | 说明 |
| --- | --- | --- | --- | --- |
| 原始 mp3 | `music/` | 13 文件 | 50.7 MB | 含 1 组重复（LinWanXia 两个 147210 字节）；去重后 12 首 |
| 封面壁纸 | `png/` | 21 张 jpg | 约 12.8 MB | JSON 引用 `wall_01…wall_12` 轮换 |
| 原始拍照 | `app/DCIM/` | 25 张 | 129.7 MB | 未被数据使用，**不进包**，副本已排除 |
| 内置图标/占位图 | `resources/base/media/` | 52 文件 | — | svg 图标 + banner/cover/playlist/avatar 占位，继续用 `$r` |
| 服务端样本 JSON | `deploy/music-server/data/` | 5 份 | 合计约 7.1 KB | 字段口径与解析别名以此为准 |

现有生成脚本 `tools/gen_music_from_folder.py` 已实现「mp3 按时长排序去重 → `song_N.mp3`；壁纸 → `wall_NN.ext`；生成 5 份 JSON」的映射逻辑，本地版可改造该脚本，把输出目录从后端 `public/` 改为 rawfile，URL 前缀改为本地相对路径。

### 歌曲与素材对应（以 songs.json id 为准）

| id | 标题 | 歌手 | 时长(s) | 音频文件（music/） |
| --- | --- | --- | --- | --- |
| 1 | 冬眠 | 司南 | 270 | 冬眠-司南.mp3 |
| 2 | 晴天 | 周杰伦 | 270 | 晴天-周杰伦.mp3 |
| 3 | 忘情水 | 刘德华 | 266 | 刘德华 - 忘情水_325771.mp3 |
| 4 | 青花瓷 | 周杰伦 | 240 | 青花瓷-周杰伦.mp3 |
| 5 | 菩提树下为你许愿 | 烟嗓兄弟 | 172 | 菩提树下为你许愿-烟嗓兄弟.mp3 |
| 6 | 古月方源1 | — | 19 | 古月方源1.mp3 |
| 7 | HuiLiYi | — | 13 | HuiLiYi (2).mp3 |
| 8 | LinWanXia | — | 9 | LinWanXia (1).mp3（去重） |
| 9 | hnqinjqj16lqg920 | — | 2 | -hnqinjqj16lqg920.mp3 |
| 10 | Cartethyia | — | 0 | Cartethyia.mp3 |
| 11 | Changli | — | 0 | Changli.mp3 |
| 12 | Yinlin | — | 0 | Yinlin (2).mp3 |

> id 10/11/12 时长为 0，代码按 240s 兜底；是否保留进包待拍板。

## 5. 代码改造点（逐层，实施时再落码）

### 5.1 数据层 `api/MusicApi.ets`
- 新增本地读取分支：`resourceManager.getRawFileContentSync('<data/xxx.json>')` → `Uint8Array.buffer` → 转字符串 → `JSON.parse`；
- 现有 `parseSong / parseSwiper / parseDaily / parsePlaylist / parseMoment` 解析器直接复用，字段别名兼容逻辑不动；
- 5 个 getter 优先读 rawfile，不再 `httpGet`；
- 封面/头像/图名字段取本地相对路径，空值继续回退 `$r` 占位图。

### 5.2 播放层 `player/MusicPlayer.ets`
- `load()` 增加本地数据源分支：
  - `context.resourceManager.getRawFd('audio/song_N.mp3')` 得 `{ fd, offset, length }`；
  - `avPlayer.fdSrc = { fd, offset, length }` 触发 `initialized`，后续 `prepare → play` 状态机不变；
- 当前封装未持有 context，需要通过构造或全局 UIAbilityContext 传入；
- 切歌沿用 `reset()` 后重新赋 `fdSrc`（AVPlayer 独占 fd，必须先 reset）；
- 保留 `url` 远程分支作为对照（是否保留远程兜底待拍板）。

### 5.3 图片渲染
- 封面/头像在 `Image(cover)` 中消费，`cover` 类型为 `ResourceStr`；
- 本地图片优先用 `$rawfile('images/wall_01.jpg')` 构造 Resource 对象；字符串路径形式（`rawfile://…`）在 ArkUI-X 下兼容性需实测。

### 5.4 配置与设置页
- 去掉 baseUrl 探测、Preferences 保存与设置页里的服务器地址输入/自检；
- `AppConfig` 保留空实现或删除网络相关方法，Settings 页对应入口隐藏。

## 6. 已核实的鸿蒙 API（官方文档）

- 读 rawfile JSON：
  ```ts
  const value: Uint8Array = context.resourceManager.getRawFileContentSync('data/songs.json');
  const text = buffer.from(value.buffer).toString();
  const obj = JSON.parse(text);
  ```
- 读音频 fd 播放：
  ```ts
  const fd = await context.resourceManager.getRawFd('audio/song_1.mp3');
  avPlayer.fdSrc = { fd: fd.fd, offset: fd.offset, length: fd.length }; // media.AVFileDescriptor
  ```
- 图片引用：`Image($rawfile('images/wall_01.jpg'))`。
- 注意：AVPlayer 使用本地资源时独占 fd；换源必须 `reset()` 后重新赋值。

## 7. 体积与压缩建议（未压缩估算）

- 音频 50.7 MB + 封面 12.8 MB ≈ **63.5 MB** 进包；现有无音频 HAP 约 1.41 MB。
- 建议（待拍板）：
  - 音频转低码率 mp3（64–96 kbps），可降到原体积 1/3~1/4；
  - 封面缩到 300–500 px、JPEG 质量 70%；
  - 时长 0/2/9s 的短提示音曲目评估是否剔除。

## 8. 风险与未验证项

1. **【最大不确定】ArkUI-X 安卓桥接运行时**：本项目跑在安卓宿主，现有远程 http URL 桥接播放已验证（PCM 送 AudioFlinger）；但 `getRawFd` / `fdSrc` / `$rawfile` 是否被桥接层完整透传，**未实测**。
   - 备选链路：首次启动把 rawfile 素材拷贝到应用沙箱 `filesDir`，用 `file://` 或沙箱 `fd` 播放，走宿主更可能支持的本地文件通道。
2. 图片字符串协议在桥接渲染层的兼容性；优先 Resource（`$rawfile`）形式。
3. HAP 包体过大时的分包/限制。
4. 素材一一对应：song id ↔ mp3、wall 序号 ↔ jpg，映射表由脚本生成并核对，避免错位。

## 9. 分支与目录约定

- 主干对照 `E:\2026music`（main，已推送 origin/main，tag 1.0.0）保持不动；
- 本地版在 `E:\2026music-local` 副本内的 `local` 分支上开发；
- 副本已排除：`oh_modules`、`build`、`entry/build`、`.hvigor`、`.appanalyzer`、`backup`、`app/DCIM`、`*.hap/*.apk/*.zip`；
- 本地版是否推送远端、何时推送，等明确指令后再执行（沿用改动前时间戳备份习惯）。

## 10. 待拍板口径

1. 音频是否压缩降码率？封面是否压缩为缩略图？
2. id 10/11/12 三首近静音/超短曲目是否保留？
3. 本地版是否保留远程服务器兜底开关，还是纯离线？
4. 本地 JSON 是否保留 `album` 等冗余字段？

## 11. 建议实施顺序（待确认后开工）

1. 改造素材生成脚本：输出 rawfile `audio/ images/ data/`，生成本地路径 JSON 与映射清单；
2. 数据层接入 rawfile 读取，复用解析器；
3. 播放层接 `getRawFd → fdSrc`；
4. 图片渲染适配本地资源；
5. 构建 HAP 装机：先验证封面显示，再验证本地音频出声；
6. 桥接不通时，回退到「rawfile → 沙箱 file://」备选链路。
