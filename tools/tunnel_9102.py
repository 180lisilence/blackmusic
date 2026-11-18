# -*- coding: utf-8 -*-
"""本地端口转发：PC:9102 -> SSH -> 服务器 127.0.0.1:3102（供 adb reverse 给手机用）"""
import socket
import threading
import paramiko
from _ssh_cfg import get_credentials

HOST, USER, PWD = get_credentials()
LOCAL_PORT = 9102
REMOTE = ("127.0.0.1", 3102)

transport = None


def ensure_transport():
    global transport
    if transport is None or not transport.is_active():
        cli = paramiko.SSHClient()
        cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        cli.connect(HOST, 22, USER, PWD, timeout=20, allow_agent=False, look_for_keys=False)
        transport = cli.get_transport()
    return transport


def pump(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            dst.sendall(data)
    except Exception:
        pass
    finally:
        try:
            dst.close()
        except Exception:
            pass
        try:
            src.close()
        except Exception:
            pass


def handle(conn):
    try:
        t = ensure_transport()
        chan = t.open_channel("direct-tcpip", REMOTE, conn.getpeername())
    except Exception as e:
        print("tunnel failed:", e)
        conn.close()
        return
    threading.Thread(target=pump, args=(conn, chan), daemon=True).start()
    threading.Thread(target=pump, args=(chan, conn), daemon=True).start()


def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", LOCAL_PORT))
    srv.listen(50)
    print("forwarding 127.0.0.1:%d -> %s:%d" % (LOCAL_PORT, REMOTE[0], REMOTE[1]), flush=True)
    while True:
        conn, addr = srv.accept()
        print('ACCEPT', addr, flush=True)
        threading.Thread(target=handle, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    main()


