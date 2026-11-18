# -*- coding: utf-8 -*-
"""黑马云音乐 交付前校验：包清单 / 版本与 API 级别 / 资源引用 / 路由页面 / 模块导入。"""
import os, re, json, sys, zipfile

ROOT = r"E:\2026music"
ETS = os.path.join(ROOT, "entry", "src", "main", "ets")
RES = os.path.join(ROOT, "entry", "src", "main", "resources", "base")
HAP = os.path.join(ROOT, "entry", "build", "default", "outputs", "default", "entry-default-unsigned.hap")
HAP_RELEASE = os.path.join(ROOT, "entry", "build", "default", "outputs", "default", "entry-default-signed.hap")
PAGES_JSON = os.path.join(RES, "profile", "main_pages.json")

ok = True
lines = []


def check(cond, msg):
    global ok
    lines.append(("PASS  " if cond else "FAIL  ") + msg)
    if not cond:
        ok = False


def ets_files():
    out = []
    for base, _, files in os.walk(ETS):
        for f in files:
            if f.endswith(".ets"):
                out.append(os.path.join(base, f))
    return out


# 1. 源码模块
files = ets_files()
check(len(files) >= 8, "模块文件数量：%d 个 .ets" % len(files))

# 2. 导入解析
bad_imports = []
for f in files:
    src = open(f, encoding="utf-8").read()
    for m in re.finditer(r"from\s+'(\.[^']+)'", src):
        rel = m.group(1)
        target = os.path.normpath(os.path.join(os.path.dirname(f), rel))
        if not os.path.exists(target + ".ets"):
            bad_imports.append((os.path.relpath(f, ROOT), rel))
check(not bad_imports, "本地模块导入全部可解析" + ("" if not bad_imports else "：%s" % bad_imports))

# 3. 资源引用
media_dir = os.path.join(RES, "media")
media_names = {os.path.splitext(n)[0] for n in os.listdir(media_dir)}
refs = set()
for f in files:
    src = open(f, encoding="utf-8").read()
    refs.update(re.findall(r"\$r\('app\.media\.([A-Za-z0-9_]+)'\)", src))
missing = sorted(r for r in refs if r not in media_names)
check(not missing, "app.media 引用 %d 项，全部存在" % len(refs) + ("" if not missing else "：缺失 %s" % missing))

# 4. 路由页面
pages = json.load(open(PAGES_JSON, encoding="utf-8"))["src"]
entry_pages = []
for f in files:
    src = open(f, encoding="utf-8").read()
    if "@Entry" in src:
        entry_pages.append("pages/" + os.path.splitext(os.path.basename(f))[0])
check(set(entry_pages) == set(pages), "路由页面注册一致：%s" % pages)

routed = set()
for f in files:
    src = open(f, encoding="utf-8").read()
    routed.update(re.findall(r"url:\s*'(pages/[A-Za-z0-9_]+)'", src))
check(routed.issubset(set(pages)), "代码内跳转目标均已注册：%s" % sorted(routed))

# 5. HAP 清单
if not os.path.exists(HAP):
    check(False, "未找到 HAP：%s" % HAP)
else:
    zf = zipfile.ZipFile(HAP)
    module = json.loads(zf.read("module.json").decode("utf-8"))
    app = module["app"]
    mod = module["module"]
    check(app["versionName"] == "6.0.0", "versionName = %s" % app["versionName"])
    check(app["versionCode"] == 6000000, "versionCode = %d" % app["versionCode"])
    check(app["bundleName"] == "com.heima.cloudmusic", "bundleName = %s" % app["bundleName"])
    check(app["minAPIVersion"] == 60000020, "minAPIVersion = %d（HarmonyOS 6.0.0 / API 20）" % app["minAPIVersion"])
    check(app["targetAPIVersion"] == 60000020, "targetAPIVersion = %d" % app["targetAPIVersion"])
    check(app["compileSdkVersion"].startswith("26.0.0"), "compileSdkVersion = %s" % app["compileSdkVersion"])
    check(mod["deviceTypes"] == ["phone", "tablet"], "deviceTypes = %s" % mod["deviceTypes"])
    check(mod["mainElement"] == "EntryAbility", "mainElement = %s" % mod["mainElement"])
    perms = [p["name"] for p in mod.get("requestPermissions", [])]
    check("ohos.permission.INTERNET" in perms, "权限声明：%s" % perms)

    entries = set(zf.namelist())
    hap_media = {os.path.splitext(os.path.basename(n))[0] for n in entries if "/media/" in n}
    miss_in_hap = sorted(r for r in refs if r not in hap_media)
    check(not miss_in_hap, "HAP 内媒体资源 %d 项，覆盖全部引用" % len(hap_media)
          + ("" if not miss_in_hap else "：缺失 %s" % miss_in_hap))
    check("ets/modules.abc" in entries, "ArkTS 字节码：ets/modules.abc（%d 字节）" % zf.getinfo("ets/modules.abc").file_size)
    check("resources.index" in entries, "资源索引：resources.index")
    check(all("resources/base/media/" + n + ".svg" in entries or "resources/base/media/" + n + ".jpg" in entries
              or "resources/base/media/" + n + ".png" in entries for n in refs), "图标/封面资源格式完整")
    zf.close()

# 6. 输出
lines.append("")
lines.append("结果：" + ("全部通过" if ok else "存在未通过项"))
report = "\n".join(lines)
print(report)
os.makedirs(os.path.join(ROOT, "dist"), exist_ok=True)
open(os.path.join(ROOT, "dist", "verification-report.txt"), "w", encoding="utf-8").write(report + "\n")
sys.exit(0 if ok else 1)
