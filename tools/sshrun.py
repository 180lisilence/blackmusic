# -*- coding: utf-8 -*-
"""SSH 执行器：连接部署服务器，跑命令并打印输出（控制台统一 UTF-8）。凭据见 _ssh_cfg。"""
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

import paramiko
from _ssh_cfg import get_credentials

HOST, USER, PWD = get_credentials()


def run(cmds, timeout=40):
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(HOST, port=22, username=USER, password=PWD, timeout=20,
                allow_agent=False, look_for_keys=False)
    out_all = []
    for c in cmds:
        stdin, stdout, stderr = cli.exec_command(c, timeout=timeout)
        out = stdout.read().decode("utf-8", "replace")
        err = stderr.read().decode("utf-8", "replace")
        out_all.append((c, out.strip(), err.strip()))
    cli.close()
    return out_all


if __name__ == "__main__":
    for c, out, err in run(sys.argv[1:]):
        print("===== $ " + c)
        if out:
            print(out[:4000])
        if err:
            print("[stderr] " + err[:1200])
