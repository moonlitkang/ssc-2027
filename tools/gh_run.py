#!/usr/bin/env python3
"""Trigger the build, wait for it, and pull the artifacts down.

The token is read from the Windows credential manager through git, never from
a file and never printed. Everything else here is plain REST.

    python tools/gh_run.py dispatch [phases]
    python tools/gh_run.py watch
    python tools/gh_run.py logs [run_id]
    python tools/gh_run.py artifacts [run_id]
"""
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
import zipfile
import io

OWNER = "moonlitkang"
REPO = "ssc-2027"
WORKFLOW = "build.yml"
API = "https://api.github.com"

PROXY = os.environ.get("GH_PROXY") or "http://127.0.0.1:1081"


def token():
    p = subprocess.run(
        ["C:/Program Files/Git/bin/git.exe", "credential", "fill"],
        input="protocol=https\nhost=github.com\n\n",
        capture_output=True, text=True, timeout=30,
    )
    for line in p.stdout.splitlines():
        if line.startswith("password="):
            return line.split("=", 1)[1]
    raise SystemExit("no stored github credential")


TOKEN = token()


def call(method, path, body=None, raw=False, retries=3):
    url = path if path.startswith("http") else API + path
    data = json.dumps(body).encode() if body is not None else None
    for attempt in range(retries):
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", "Bearer " + TOKEN)
        req.add_header("Accept", "application/vnd.github+json")
        req.add_header("X-GitHub-Api-Version", "2022-11-28")
        if data:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                payload = r.read()
                return payload if raw else (json.loads(payload) if payload else None)
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "replace")[:400]
            if e.code in (502, 503) and attempt + 1 < retries:
                time.sleep(2)
                continue
            raise SystemExit(f"HTTP {e.code} on {method} {path}\n{detail}")
        except (urllib.error.URLError, TimeoutError):
            if attempt + 1 < retries:
                time.sleep(2)
                continue
            raise


def latest_run():
    runs = call("GET", f"/repos/{OWNER}/{REPO}/actions/workflows/{WORKFLOW}/runs?per_page=1")
    return runs["workflow_runs"][0] if runs["workflow_runs"] else None


def cmd_dispatch(phases):
    body = {"ref": "main"}
    if phases:
        body["inputs"] = {"phases": phases}
    call("POST", f"/repos/{OWNER}/{REPO}/actions/workflows/{WORKFLOW}/dispatches", body)
    print("dispatched")
    for _ in range(20):
        time.sleep(3)
        run = latest_run()
        if run and run["status"] in ("queued", "in_progress"):
            print(f"run {run['id']} {run['status']}")
            return
    print("dispatched, no run visible yet")


def cmd_watch():
    run = latest_run()
    if not run:
        raise SystemExit("no runs")
    rid = run["id"]
    print(f"run {rid} {run['html_url']}")
    last = None
    while True:
        run = call("GET", f"/repos/{OWNER}/{REPO}/actions/runs/{rid}")
        jobs = call("GET", f"/repos/{OWNER}/{REPO}/actions/runs/{rid}/jobs")["jobs"]
        line = f"{run['status']}/{run['conclusion']}"
        steps = []
        for j in jobs:
            for s in j["steps"]:
                if s["status"] != "completed" or s["conclusion"] != "success":
                    steps.append(f"{j['name']}:{s['name']}={s['status']}/{s['conclusion']}")
        msg = line + " | " + "; ".join(steps[:3])
        if msg != last:
            print(time.strftime("%H:%M:%S"), msg, flush=True)
            last = msg
        if run["status"] == "completed":
            print("conclusion:", run["conclusion"])
            return rid
        time.sleep(15)


def cmd_logs(rid=None):
    if not rid:
        rid = latest_run()["id"]
    jobs = call("GET", f"/repos/{OWNER}/{REPO}/actions/runs/{rid}/jobs")["jobs"]
    out = []
    for j in jobs:
        try:
            # Same redirect problem as the artifacts: the log blob is served
            # from storage that rejects a request carrying a GitHub token.
            blob = download(f"/repos/{OWNER}/{REPO}/actions/jobs/{j['id']}/logs")
        except SystemExit as e:
            out.append(f"--- {j['name']}: no log ({e})")
            continue
        except urllib.error.HTTPError as e:
            out.append(f"--- {j['name']}: no log (HTTP {e.code})")
            continue
        out.append(f"===== {j['name']} =====")
        out.append(blob.decode("utf-8", "replace"))
    text = "\n".join(out)
    path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "_log.txt")
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"wrote {path} ({len(text)} chars)")


def download(url, retries=3):
    """Artifact zips and job logs redirect to blob storage, and Azure rejects a
    request that arrives with a GitHub bearer token attached. So this one follows
    redirects without the Authorization header."""
    if not url.startswith("http"):
        url = API + url
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url)
            req.add_header("Authorization", "Bearer " + TOKEN)
            opener = urllib.request.build_opener(_StripAuthOnRedirect())
            with opener.open(req, timeout=120) as r:
                return r.read()
        except (urllib.error.URLError, TimeoutError):
            if attempt + 1 < retries:
                time.sleep(2)
                continue
            raise


class _StripAuthOnRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new = super().redirect_request(req, fp, code, msg, headers, newurl)
        if new is not None:
            for h in ("Authorization", "authorization"):
                new.headers.pop(h, None)
            new.unredirected_hdrs.pop("Authorization", None)
        return new


def cmd_artifacts(rid=None):
    if not rid:
        rid = latest_run()["id"]
    arts = call("GET", f"/repos/{OWNER}/{REPO}/actions/runs/{rid}/artifacts")["artifacts"]
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for a in arts:
        blob = download(a["archive_download_url"])
        dest = os.path.join(root, "dist")
        os.makedirs(dest, exist_ok=True)
        with zipfile.ZipFile(io.BytesIO(blob)) as z:
            names = z.namelist()
            z.extractall(dest)
        print(f"{a['name']}: {a['size_in_bytes']} bytes -> {dest} {names}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "watch"
    arg = sys.argv[2] if len(sys.argv) > 2 else None
    if cmd == "dispatch":
        cmd_dispatch(arg)
    elif cmd == "watch":
        cmd_watch()
    elif cmd == "logs":
        cmd_logs(arg)
    elif cmd == "artifacts":
        cmd_artifacts(arg)
    else:
        raise SystemExit(__doc__)
