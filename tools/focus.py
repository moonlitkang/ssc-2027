#!/usr/bin/env python3
"""Bring a window to the front.

Usage:
    python tools/focus.py                 # list every visible window
    python tools/focus.py Codemagic       # focus the first title match
    python tools/focus.py 9004            # focus by process id

Why this exists: alt+tab cycles instead of targeting, and WScript.Shell is
blocked by the machine's security policy, so user32 is called directly.
"""
import sys
import ctypes
from ctypes import wintypes

u32 = ctypes.windll.user32

WNDENUMPROC = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)

u32.EnumWindows.argtypes = [WNDENUMPROC, wintypes.LPARAM]
u32.IsWindowVisible.argtypes = [wintypes.HWND]
u32.GetWindowTextLengthW.argtypes = [wintypes.HWND]
u32.GetWindowTextW.argtypes = [wintypes.HWND, wintypes.LPWSTR, ctypes.c_int]
u32.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
u32.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
u32.SetForegroundWindow.argtypes = [wintypes.HWND]
u32.BringWindowToTop.argtypes = [wintypes.HWND]
u32.GetForegroundWindow.restype = wintypes.HWND
u32.GetWindowThreadProcessId.restype = wintypes.DWORD
u32.AttachThreadInput.argtypes = [wintypes.DWORD, wintypes.DWORD, wintypes.BOOL]
u32.keybd_event.argtypes = [wintypes.BYTE, wintypes.BYTE, wintypes.DWORD, ctypes.c_void_p]
u32.SetWindowPos.argtypes = [
    wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int,
    ctypes.c_int, ctypes.c_int, ctypes.c_uint,
]

VK_MENU = 0x12
KEYEVENTF_KEYUP = 0x0002


def force_foreground(hwnd):
    """Windows only lets the process that owns the foreground window change it.

    A synthetic ALT tap clears that lock for the calling process; if it still
    refuses, attach to the foreground thread's input queue and try again.
    """
    u32.keybd_event(VK_MENU, 0, 0, None)
    u32.SetForegroundWindow(hwnd)
    u32.keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, None)

    if u32.GetForegroundWindow() == hwnd:
        return True

    foreground = u32.GetForegroundWindow()
    target_thread = u32.GetWindowThreadProcessId(foreground, None)
    this_thread = ctypes.windll.kernel32.GetCurrentThreadId()
    u32.AttachThreadInput(this_thread, target_thread, True)
    u32.BringWindowToTop(hwnd)
    u32.SetForegroundWindow(hwnd)
    u32.AttachThreadInput(this_thread, target_thread, False)

    return u32.GetForegroundWindow() == hwnd


def visible_windows():
    out = []

    def callback(hwnd, _):
        if not u32.IsWindowVisible(hwnd):
            return True
        length = u32.GetWindowTextLengthW(hwnd)
        if length == 0:
            return True
        buffer = ctypes.create_unicode_buffer(length + 1)
        u32.GetWindowTextW(hwnd, buffer, length + 1)
        pid = wintypes.DWORD()
        u32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
        out.append((hwnd, pid.value, buffer.value))
        return True

    u32.EnumWindows(WNDENUMPROC(callback), 0)
    return out


def main():
    windows = visible_windows()

    if len(sys.argv) < 2:
        for hwnd, pid, title in windows:
            print(f"{pid}\t{hwnd}\t{title}")
        return

    needle = sys.argv[1]
    matches = [
        w for w in windows
        if w[2] == needle or str(w[1]) == needle or needle.lower() in w[2].lower()
    ]
    if not matches:
        print("no match")
        sys.exit(1)

    hwnd, pid, title = matches[0]
    SW_RESTORE = 9
    SW_MAXIMIZE = 3
    HWND_TOP = 0
    SWP_NOSIZE = 0x0001
    SWP_NOMOVE = 0x0002
    SWP_SHOWWINDOW = 0x0040

    # SW_RESTORE un-maximises a maximised window, which silently shrank the
    # browser on every focus call. Keep it maximised if it already was.
    if u32.IsZoomed(hwnd):
        u32.ShowWindow(hwnd, SW_MAXIMIZE)
    else:
        u32.ShowWindow(hwnd, SW_RESTORE)
    u32.SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0,
                     SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW)
    ok = force_foreground(hwnd)
    print(f"{'focused' if ok else 'FAILED to focus'} {pid}: {title}")
    if not ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
