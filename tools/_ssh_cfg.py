# -*- coding: utf-8 -*-
"""部署凭据加载（入库，不含任何真实凭据）。

取值顺序：
  1. 环境变量 MUSIC_SSH_HOST / MUSIC_SSH_USER / MUSIC_SSH_PWD
  2. 同目录 deploy.local.env（KEY=VALUE，该文件已在 .gitignore 中，不入库）
  3. 占位符 example.com / root / changeme

deploy.local.env 示例（本地保存，勿提交）：
  MUSIC_SSH_HOST=你的服务器地址
  MUSIC_SSH_USER=root
  MUSIC_SSH_PWD=你的密码
"""
import os
from pathlib import Path


def get_credentials():
    env_file = Path(__file__).with_name("deploy.local.env")
    if env_file.exists():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())
    host = os.environ.get("MUSIC_SSH_HOST", "example.com")
    user = os.environ.get("MUSIC_SSH_USER", "root")
    pwd = os.environ.get("MUSIC_SSH_PWD", "changeme")
    return host, user, pwd
