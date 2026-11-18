# -*- coding: utf-8 -*-
"""在 nginx 的 IP server 块里插入 /music/ 反向代理，然后 nginx -t && reload。"""
import sys
import paramiko
from _ssh_cfg import get_credentials

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HOST, USER, PWD = get_credentials()
CONF = "/www/server/panel/vhost/nginx/blog2.1.conf"
MARKER = "server_name %s;" % HOST
BLOCK = """
    # 黑马云音乐 API（由 pm2 托管，本地 3102）
    location ^~ /music/ {
        proxy_pass http://127.0.0.1:3102/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 30s;
        proxy_http_version 1.1;
    }
"""

cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
cli.connect(HOST, 22, USER, PWD, timeout=20, allow_agent=False, look_for_keys=False)
sftp = cli.open_sftp()

with sftp.open(CONF, "r") as f:
    content = f.read().decode("utf-8")

if "/music/" in content:
    print("已存在 /music/ 配置，跳过插入")
else:
    lines = content.splitlines(keepends=True)
    out, inserted = [], False
    for ln in lines:
        out.append(ln)
        if (not inserted) and MARKER in ln:
            out.append(BLOCK)
            inserted = True
    if not inserted:
        print("没找到标记行，未修改")
        sys.exit(1)
    with sftp.open(CONF + ".bak-heimamusic", "w") as f:
        f.write(content)
    with sftp.open(CONF, "w") as f:
        f.write("".join(out))
    print("已插入 /music/ 反代，备份：%s.bak-heimamusic" % CONF)

sftp.close()

for cmd in ("/www/server/nginx/sbin/nginx -t",
            "/www/server/nginx/sbin/nginx -s reload",
            "sleep 1; curl -s -m 5 http://127.0.0.1/music/health",
            "curl -s -m 5 http://%s/music/swiper | head -c 260" % HOST):
    stdin, stdout, stderr = cli.exec_command(cmd, timeout=40)
    o = stdout.read().decode("utf-8", "replace").strip()
    e = stderr.read().decode("utf-8", "replace").strip()
    print("===== $ " + cmd)
    if o:
        print(o[:1500])
    if e:
        print("[stderr] " + e[:1500])

cli.close()
