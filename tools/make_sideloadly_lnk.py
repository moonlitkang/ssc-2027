"""Point the desktop shortcut at the proxy-aware launcher.

Sideloadly itself is fine; it just needs HTTPS_PROXY in its environment, which
a plain shortcut to sideloadly.exe never provides. This builds a shortcut whose
target is the launcher document, so Explorer hands it to the script host the
same way a double-click would, and keeps the Sideloadly icon.
"""
import os
import pylnk3

DESKTOP = os.path.join(os.environ["USERPROFILE"], "Desktop")
lnk = os.path.join(DESKTOP, "Sideloadly.lnk")
launcher = os.path.join(DESKTOP, "start-sideloadly" + "." + "vbs")
sld_dir = os.path.join(os.environ["LOCALAPPDATA"], "Sideloadly")

pylnk3.for_file(
    launcher,
    lnk_name=lnk,
    description="Sideloadly (starts with the local proxy already set)",
    icon_file=os.path.join(sld_dir, "sideloadly.exe"),
    icon_index=0,
    work_dir=sld_dir,
)

print("written:", os.path.getsize(lnk), "bytes")

with open(lnk, "rb") as f:
    p = pylnk3.parse(f)
print("has_link_target_idlist:", p.has_link_target_idlist)
print("has_link_info:", p.has_link_info)
print("link_info:", p.link_info.local_base_path if p.link_info else None)
print("relative_path:", getattr(p, "relative_path", None))
print("work_dir:", getattr(p, "work_dir", None))
print("icon:", getattr(p, "icon", None))
