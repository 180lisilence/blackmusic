# HAP 运行器（Android 通用宿主）· 说明

## 一、APK 在哪

```
E:\2026music\android-host\dist\HapRunner-1.1.0-debug.apk      （29 KB，通用运行器）
```

已经装到你手机上（包名 `com.haprunner`，桌面名称「**HAP 运行器**」）。
测试用 HAP 也推到手机了：`/sdcard/Download/HeimaMusic-6.0.0.hap`。

## 二、它是什么

一个**与项目无关的通用运行器**：不内置任何应用，只做「选 HAP → 解析 → 解包 → 运行」。

| 能力 | 说明 |
| --- | --- |
| 任意 HAP 导入 | 点「选择 HAP 文件」走系统文件管理器（SAF，`ACTION_OPEN_DOCUMENT`）；也可在文件管理器里对 .hap 用「打开方式 → HAP 运行器」（已注册 VIEW intent） |
| **自动找 HAP** | 启动即扫全盘：Android 11+ 有「所有文件访问」时直扫 `/sdcard`（含 Download/Documents/微信目录等），无权限时降级扫公开目录 + MediaStore，再不行可「添加扫描目录」用 SAF 授权任意文件夹；结果去重后列出，点「运行」直接跑 |
| 通用解析 | 读 `module.json`：bundleName / versionName / versionCode / minAPIVersion / targetAPIVersion / module / mainElement / abilities / pages / deviceTypes / permissions；读 `ets/modules.abc` 头（Panda 字节码 + 版本）；统计资源项 |
| 自动解包 | 解到 `files/arkui-x/<bundleName>/<module>/`，含 `module.json`、`resources.index`、`resources/`、`ets/modules.abc` —— 即 ArkUI-X 运行时要求的目录布局 |
| 运行 | 运行时齐备时，按 `bundleName:moduleName:abilityName:` 拉起 `HapHostActivity`（StageActivity 子类）；未齐备时弹出精确缺失清单 |
| 管理 | 列表按时间排序，可查看详情、删除；导入记录保存在应用私有目录 |

## 三、兼容性（本轮新增）

### 3.1 Android 侧（APK）

| 项 | 值 | 说明 |
| --- | --- | --- |
| minSdkVersion | **21（Android 5.0）** | 实测 APK：`minSdkVersion:'21'` |
| targetSdkVersion | 31 | 与测试机 Android 12 对齐 |
| compileSdkVersion | 35 | 编译用 android-35 |
| ABI | 无原生库依赖 → **arm64-v8a / armeabi-v7a / x86 / x86_64 全可装** | 接入运行时后按 `jniLibs/arm64-v8a` 等目录分 ABI |
| 界面 | 全部用 `android.app.Activity` + 原生 View | 不依赖 AndroidX/Compose，老系统无兼容空洞 |
| 存储 | 全程应用私有目录 + SAF（`ACTION_OPEN_DOCUMENT`） | Android 5～16 的分区存储都适用，不需要存储权限 |
| 状态栏/导航栏 | `setStatusBarColor`（API 21+） | 5.0 起可用 |

### 3.2 HAP 侧（包格式兼容）

| 场景 | 支持 |
| --- | --- |
| Stage 模型（`module.json`） | ✓ 解析 app/module、abilities、pages、deviceTypes、requestPermissions |
| FA 模型（`config.json`，旧版 HAP） | ✓ 解析 app.version、minAPIVersion、module.abilities/reqPermissions |
| 无 `module.json`/`config.json` | 判为非法包并提示 |
| 大小/线程 | 流式解包（16 KB 缓冲），大包不爆内存 |
| 来源 | 文件管理器（content://）、应用内 `file://`、其他 App「打开方式/分享」送入 |

### 3.3 单包兼容性判定（列表里每个 HAP 都会显示）

1. `minAPIVersion > 设备 API` → **不兼容**（并显示要求值）；
2. `deviceTypes` 不含 `phone` → **设备类型不匹配**；
3. 缺 ArkUI-X 运行时 → **可解析 / 可解包**；
4. 运行时齐备 → **可运行**。

### 3.5 自动发现（本轮新增，不用手动翻目录）

| 能力 | 说明 |
| --- | --- |
| 启动自动扫描 | 打开 App 即在后台线程扫，扫到就列在最上方 |
| Android 11+ 全盘直扫 | 授予「所有文件访问」（`MANAGE_EXTERNAL_STORAGE`）后遍历 `/storage/emulated/0`，深度 10 层、上限 2 万文件，跳过隐藏目录 |
| Android 10 及以下 | 申请 `READ_EXTERNAL_STORAGE` 后同样直扫公开目录 |
| 无任何权限 | 降级为：应用可见目录 + Download/Documents + `MediaStore.Files` 查询（`%​.hap`） |
| 授权任意目录 | 「添加扫描目录」→ SAF 目录树，持久化后每次扫描都递归进去（`DocumentsContract`） |
| 去重 | 按「文件名 + 大小」去重，同一份 HAP 在多处只出现一次；应用私有副本不参与扫描 |
| 结果操作 | 每条结果两个按钮：**运行**（导入→解析→解包→拉起）/ **仅导入** |

实测（你的手机，已授权全盘）：

```
I HAPRUNNER: scan found 1
I HAPRUNNER: scan: /storage/emulated/0/Download/HeimaMusic-6.0.0.hap  1313711B
```

### 3.6 本轮真机实测

```
package: name='com.haprunner' versionCode='2' versionName='1.1.0'
minSdkVersion:'21'  targetSdkVersion:'31'  compileSdkVersion='35'

# Stage 模型 HAP
I HAPRUNNER: view-intent imported HeimaMusic.hap bundle=com.heima.cloudmusic module=entry ability=EntryAbility
# FA 模型 HAP（另造的 test-fa.hap）
I HAPRUNNER: view-intent imported test-fa.hap bundle=com.demo.fa module=entry ability=com.demo.fa.MainAbility
```

设备：`NTN-AN20 / Android 12（API 31）/ arm64-v8a,armeabi-v7a,armeabi`。

解包落地（Stage HAP 实测）：

```
files/haps/HeimaMusic.hap                     ← 导入副本
files/arkui-x/com.heima.cloudmusic/entry/
        ├── module.json
        ├── resources.index
        ├── ets/modules.abc
        └── resources/…                        ← ArkUI-X 布局就绪
```

## 四、关键事实：HAP 不能被 Android 直接“安装执行”

- HAP 里的 `ets/modules.abc` 是 ArkTS/方舟字节码，Android 没有方舟 VM，也没有 ArkUI 渲染栈，`adb install x.hap` 永远失败；
- 唯一能让 ArkTS 页面在 Android 上真实渲染的机制是 **ArkUI-X**：它把 ArkUI 引擎编译成 `libarkui_android.so`，配 `arkui_android_adapter.jar`（`StageApplication` / `StageActivity`）+ `systemres` 框架资源，从 `assets/arkui-x/<module>/` 读取 abc 与资源，把 Activity 生命周期映射到 Ability；
- 本机 **没有** ArkUI-X 运行时二进制（DevEco 只带 `[ArkUI-X]` 工程模板），匿名下载渠道也取不到：
  `POST https://repo.harmonyos.com/sdkmanager/crossPlatform/getSdkList` 在未登录时返回 `[]`；
  GitHub / Gitee 均无预编译 SDK 发布。

## 五、让「运行」真正生效（三条路，脚本已备好）

1. **（推荐）装 ArkUI-X SDK 后重打包**
   DevEco Studio → SDK Manager 安装 ArkUI-X SDK（需登录华为账号），然后：

   ```powershell
   cd E:\2026music\android-host
   .\build.ps1 -ArkuiXSdk "D:\你的路径\arkui-x" -Install -Launch
   ```

   脚本会自动做：拷 `arkui_android_adapter.jar` → `libs/`、`android-arm64/*.so`（含 plugins）→ `jniLibs/arm64-v8a/`、
   `systemres` → `assets/arkui-x/`，并把 `host-runtime/com/haprunner/HapHostActivity.java`（`extends StageActivity`）
   一起编进来。之后运行器点「运行」即按 HAP 的 `bundle:module:ability` 拉起真实 ArkTS 页面。

2. **源码自建运行时**
   `gitee.com/arkui-x`（`repo init -u git@gitee.com:arkui-x/manifest.git -b ArkUI-X-5.0.1-Release`），Linux/NDK 编译出 Android arm64 运行时。
   注意：ArkUI-X 5.0.1 配套 API 13，我们 HAP 是 API 20（SDK 26 编译），需选与 SDK 26 对齐的 ArkUI-X 版本，或把应用改到对应 SDK 重编。

3. **带运行时的第三方发行版**
   把其 `lib/arm64-v8a/*.so` + adapter jar 放进 `libs/`、`jniLibs/`，同样用 `.\build.ps1`（不加 `-ArkuiXSdk`，手工放好后直接构建）。

## 六、工程结构

```
android-host/
├─ AndroidManifest.xml                 包名 com.haprunner，VIEW intent 接管 .hap
├─ src/com/haprunner/
│  ├─ MainActivity.java                选择/列表/详情/运行/删除
│  ├─ HapPackage.java                  通用 HAP 解析（module.json / abc / 资源）
│  ├─ HapStore.java                    导入（SAF + file:// + content://）、历史、删除
│  └─ RuntimeProbe.java                运行时探测（jar / so / 宿主 Activity）
├─ host-runtime/com/haprunner/
│  └─ HapHostActivity.java             extends StageActivity（带 SDK 时才编入）
├─ res/, keys/debug.keystore
├─ build.ps1                           纯命令行构建（aapt2 + javac + d8 + zipalign + apksigner）
└─ dist/HapRunner-1.1.0-debug.apk
```

## 七、参考（前人实现，已核对）

- ArkUI-X 官方文档：`https://gitee.com/arkui-x/docs`
  - `quick-start/start-with-ability-on-android.md`（StageApplication / StageActivity / instanceName 规则）
  - `quick-start/package-structure-guide.md`（Android 工程与 `assets/arkui-x` 目录规范）
- Android 版 HAP 解析器：`westinyang/hap-viewer-android`（★26，证明「文件管理器选 HAP」这条交互可行）
- HAP 模式运行时补丁：`WeiguangTWK/ArkUI-X-AOSP-Layer-Patch`（说明要跑**原生 HAP**需在运行时侧打补丁）
