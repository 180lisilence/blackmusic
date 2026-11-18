# -*- coding: utf-8 -*-
"""SFTP 递归上传本地目录到服务器。"""
import os
import sys
import paramiko
from _ssh_cfg import get_credentials

HOST, USER, PWD = get_credentials()


def upload(local_dir, remote_dir):
    cli = paramiko.SSHClient()
    cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    cli.connect(HOST, 22, USER, PWD, timeout=20, allow_agent=False, look_for_keys=False)
    sftp = cli.open_sftp()

    def ensure(rd):
        parts = rd.strip("/").split("/")
        cur = ""
        for p in parts:
            cur += "/" + p
            try:
                sftp.stat(cur)
            except IOError:
                sftp.mkdir(cur)

    ensure(remote_dir)
    count = 0
    for base, _, files in os.walk(local_dir):
        rel = os.path.relpath(base, local_dir)
        rdir = remote_dir if rel == "." else remote_dir + "/" + rel.replace("\\", "/")
        ensure(rdir)
        for f in files:
            lp = os.path.join(base, f)
            rp = rdir + "/" + f
            sftp.put(lp, rp)
            count += 1
    sftp.close()
    cli.close()
    print("uploaded", count, "files ->", remote_dir)


if __name__ == "__main__":
    upload(sys.argv[1], sys.argv[2])
