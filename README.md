# 黑马云音乐 · heimayun-music-self

> 个人学习项目，与官方音乐平台无关。
> HarmonyOS ArkTS 音乐应用，经 ArkUI-X 运行于安卓设备；配套零依赖 Node.js 后端 API。

- 应用包名：`com.heima.cloudmusic`
- 版本：`6.0.0`
- 客户端：ArkTS / ArkUI，4 个页面 + 4 个视图
- 后端：Node.js 原生 `http`，无第三方依赖，pm2 托管 + nginx 反代

## 仓库分工

| 角色 | 仓库 | 分支 | 说明 |
| --- | --- | --- | --- |
| 本地主线 / 客户端（本仓库） | [heimayun-music-self](https://github.com/180lisilence/heimayun-music-self) | `main` / `local` | ArkTS 客户端工程，主线开发方向，日常提交与推送均指向本仓库 |
| 服务器版本 | [housemusic](https://github.com/180lisilence/housemusic) | `main` | 后端 / 服务器部署版本，独立仓库维护；本仓库仅做跳转标注，不向其推送 |

## 功能特性

- **首页推荐**：轮播 Banner、每日推荐、推荐歌单，远程数据优先，拉取失败回退内置本地样本。
- **音乐列表**：歌曲标题、歌手、封面、时长；动态（Moment）内嵌歌曲信息。
- **播放页**：封面、进度、上一首 / 播放暂停 / 下一首；已接入 AVPlayer 真播放（事件驱动状态机），运行时不具备播放器能力时回退计时模拟。
- **服务器设置**：地址运行时可配，持久化到 Preferences；首页顶部标记「远程数据 / 本地演示」。
- **统一数据层**：入口页生命周期预加载 → 写入 AppStorage → 子视图 `@StorageLink` 订阅（规避 ArkUI-X 子组件生命周期不回调的问题）。
- **后端 API**：五个业务接口 + 封面图 / 音频静态目录，读 JSON 即取，改数据无需重启进程。

## 目录结构

```
├─ entry/src/main/ets/
│  ├─ pages/                Splash / Index / Player / Settings
│  ├─ views/               Recommend / Find / Moment / Mine
│  ├─ api/                 HttpClient（@ohos.net.http 封装）、MusicApi（接口与字段兼容解析）
│  ├─ common/              AppConfig（地址配置）、DataStore（预加载）、Nav、Theme、Widgets
│  ├─ models/              MusicModels 数据模型
│  ├─ entryability/        EntryAbility、EntryBackupAbility
│  └─ mock/                本地样本配置
├─ entry/src/main/resources/  内置图标、封面、配色与多深色模式资源
├─ deploy/music-server/
│  ├─ server.js            零依赖 Node API（端口 3102）
│  └─ data/                swiper / daily / playlists / songs / moments 五个 JSON
├─ tools/                  构建、校验、部署、隧道与素材生成脚本
└─ AppScope/               应用全局配置与图标
```

## 后端接口

基础路径：`http://<host>/music/`

| 路径 | 说明 |
| --- | --- |
| `GET /health` | 健康检查，返回服务名、时间戳与路由清单 |
| `GET /swiper` | 轮播图 |
| `GET /dailyRecommend` | 每日推荐 |
| `GET /recommendList` | 推荐歌单 |
| `GET /songList` | 歌曲列表 |
| `GET /momentList` | 动态列表（内嵌歌曲） |
| `GET /images/<file>` | 封面 / 头像静态资源 |
| `GET /audio/<file>` | 音频静态资源（目录预留） |

响应统一为 `{ code, data, total }`，同时兼容裸数组；静态目录 `public/` 不随源码入库，由生成脚本产出。

## 构建 HAP

```powershell
# debug 构建（产物在 dist/）
.\tools\build.ps1

# release 构建 + 交付校验
.\tools\build.ps1 -Mode release -Verify
```

构建依赖 DevEco Studio 自带的 JDK、SDK 与 hvigor；脚本内已写入对应的 `JAVA_HOME` / `DEVECO_SDK_HOME`。

## 数据与素材

- `music/`（源 mp3）、`png/`（源壁纸）、`deploy/music-server/public/`（音频与封面产物）、成品 HAP/APK、调试截图均不入库，保留在本地。
- 后端 JSON 与静态资源可由脚本从本地素材重新生成：
  - `tools/gen_music_from_folder.py`：从 `music/`、`png/` 整理音频、壁纸并写出五个接口 JSON；
  - `tools/gen_music_backend.py`：从客户端内置资源生成早期后端样本；
  - `tools/gen_assets.py`：生成应用图标与封面。

## 部署脚本与凭据

`tools/` 下的 SSH / SFTP / 隧道 / nginx 脚本通过 `_ssh_cfg.py` 读取凭据：

1. 环境变量 `MUSIC_SSH_HOST` / `MUSIC_SSH_USER` / `MUSIC_SSH_PWD`；
2. 或同目录未入库的 `tools/deploy.local.env`（`KEY=VALUE`，已在 `.gitignore`）；
3. 都缺失时使用占位符。

仓库内不含任何服务器密码与真实地址，默认地址为 `http://example.com/music`，部署时在客户端设置页或配置中替换。

## 当前状态 / 待办

- [x] 播放页 AVPlayer 真播放（事件驱动状态机，计时模拟作降级，真机已验证）
- [x] 清理调试埋点日志（保留 error 与生命周期模板日志）
- [ ] 点赞 / 收藏落库（不在本次范围，当前为内存态）
- [ ] 离线版（rawfile 打包）改造：口径待拍板，详见 `LOCAL-VERSION.md`

## 关联项目

- [housemusic](https://github.com/180lisilence/housemusic)：服务器 / 后端部署版本仓库（`main` 分支）。
- [hap-runner-HarmonyOS](https://github.com/180lisilence/hap-runner-HarmonyOS)：加载本 HAP 的安卓宿主运行器。
