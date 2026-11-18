# 黑马云音乐 · blackmusic

> 个人学习项目，与官方音乐平台无关。
> HarmonyOS ArkTS 音乐应用，经 ArkUI-X 运行于安卓设备；歌曲、封面、头像等素材与列表数据均打包在应用内，由设备本地数据源提供，不依赖外部网络服务。

- 应用包名：`com.heima.cloudmusic`
- 版本：`6.0.0`
- 客户端：ArkTS / ArkUI，4 个页面 + 4 个视图
- 数据与素材：内置本地样本 + 包内资源

## 仓库分工

| 角色 | 仓库 | 分支 | 说明 |
| --- | --- | --- | --- |
| 本仓库（客户端） | [blackmusic](https://github.com/180lisilence/blackmusic) | `main` | ArkTS 客户端工程，素材打包进应用；主线开发方向，日常提交与推送均指向本仓库 |
| 配套数据版本 | [housemusic](https://github.com/180lisilence/housemusic) | `main` | 配套的数据 / 素材版本仓库，独立维护；本仓库仅做跳转标注，不向其推送 |
| 旧仓库（冷备份） | [heimayun-music-self](https://github.com/180lisilence/heimayun-music-self) | `main` / `local` | 历史备份，不再主动维护与推送 |

## 功能特性

- **首页推荐**：轮播 Banner、每日推荐、推荐歌单，数据来自应用内置本地样本。
- **音乐列表**：歌曲标题、歌手、封面、时长；动态（Moment）内嵌歌曲信息。
- **播放页**：封面、进度、上一首 / 播放暂停 / 下一首；已接入 AVPlayer 真播放（事件驱动状态机），运行时不具备播放器能力时回退计时模拟。
- **统一数据层**：入口页生命周期预加载 → 写入 AppStorage → 子视图 `@StorageLink` 订阅（规避 ArkUI-X 子组件生命周期不回调的问题）。
- **本地素材**：图标、封面、壁纸、头像等资源随包内置；列表样本由本地配置提供。

## 目录结构

```
├─ entry/src/main/ets/
│  ├─ pages/                Splash / Index / Player / Settings
│  ├─ views/               Recommend / Find / Moment / Mine
│  ├─ api/                 MusicApi（数据读取与字段兼容解析）
│  ├─ common/              AppConfig、DataStore（预加载）、Nav、Theme、Widgets
│  ├─ models/              MusicModels 数据模型
│  ├─ entryability/        EntryAbility、EntryBackupAbility
│  └─ mock/                本地样本配置
├─ entry/src/main/resources/  内置图标、封面、配色与多深色模式资源
├─ tools/                  构建、校验与素材生成脚本
└─ AppScope/               应用全局配置与图标
```

## 构建 HAP

```powershell
# debug 构建（产物在 dist/）
.\tools\build.ps1

# release 构建 + 交付校验
.\tools\build.ps1 -Mode release -Verify
```

构建依赖 DevEco Studio 自带的 JDK、SDK 与 hvigor；脚本内已写入对应的 `JAVA_HOME` / `DEVECO_SDK_HOME`。

## 数据与素材

- `music/`（源 mp3）、`png/`（源壁纸）、成品 HAP/APK、调试截图均不入库，保留在本地。
- 素材可由脚本从本地素材重新整理生成：
  - `tools/gen_music_from_folder.py`：从 `music/`、`png/` 整理音频、壁纸并写出五个列表 JSON；
  - `tools/gen_assets.py`：生成应用图标与封面。

## 当前状态 / 待办

- [x] 播放页 AVPlayer 真播放（事件驱动状态机，计时模拟作降级，真机已验证）
- [x] 清理调试埋点日志（保留 error 与生命周期模板日志）
- [ ] 点赞 / 收藏落库（不在本次范围，当前为内存态）
- [ ] 内置素材打包（rawfile）改造：口径待拍板，详见 `LOCAL-VERSION.md`
- [ ] 纯内置化收尾：现有数据读取链路与设置页仍保留早期网络适配残留，待切换为纯本地读取

## 关联项目

- [blackmusic](https://github.com/180lisilence/blackmusic)：本仓库，客户端主线（`main` 分支）。
- [housemusic](https://github.com/180lisilence/housemusic)：配套数据 / 素材版本仓库（`main` 分支）。
- [heimayun-music-self](https://github.com/180lisilence/heimayun-music-self)：旧仓库冷备份，不再维护。
- [hap-runner-HarmonyOS](https://github.com/180lisilence/hap-runner-HarmonyOS)：加载本 HAP 的安卓宿主运行器。
