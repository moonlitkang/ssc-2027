#!/usr/bin/env python3
"""SSC 提交前自检。用法：
    python tools/precheck.py <项目目录或 .zip> [--zip]
示例：
    python tools/precheck.py ThirdRow.swiftpm
    python tools/precheck.py ThirdRow.swiftpm --zip     # 打包并校验 25MB

退出码 0 = 全部通过；1 = 有 FAIL。只依赖标准库。
"""
import sys, os, re, zipfile, io

CJK = re.compile(r'[\u4e00-\u9fff]')
FULLWIDTH = re.compile(r'[\u3000-\u303f\uff01-\uff60]')
NET = [
    (re.compile(r'\bURLSession\b'), 'URLSession（联网调用）'),
    (re.compile(r'https?://(?!.*\.(png|jpg|jpeg|heic|mp3|m4a|wav|caf|json|ttf|otf)\b)'), '硬编码 URL'),
    (re.compile(r'\bWKWebView\b'), 'WKWebView'),
    (re.compile(r'\bNWConnection\b|\bimport Network\b'), 'Network 框架'),
    (re.compile(r'\bAlamofire\b|\bFirebase\b'), '第三方网络依赖'),
]
SKIP_DIRS = {'.git', '.build', 'build', 'dist', 'DerivedData', '__MACOSX', '.swiftpm-build'}
MAX_ZIP = 25 * 1024 * 1024
results = []


def add(level, name, detail):
    results.append((level, name, detail))


def walk(root):
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in dns if d not in SKIP_DIRS]
        for fn in fns:
            yield os.path.join(dp, fn)


def check_text(path, rel, text):
    for i, line in enumerate(text.splitlines(), 1):
        if CJK.search(line):
            add('FAIL', '英文规范', f'{rel}:{i} 含中文 -> {line.strip()[:60]}')
        elif FULLWIDTH.search(line) and not path.endswith('.swift'):
            add('WARN', '英文规范', f'{rel}:{i} 含全角标点')
        for rx, label in NET:
            if rx.search(line):
                add('FAIL', '离线运行', f'{rel}:{i} {label}')
                break


def check_tree(root):
    name = os.path.basename(os.path.abspath(root).rstrip('/\\'))
    if name.endswith('.swiftpm'):
        add('PASS', '包结构', f'目录名合规：{name}')
    else:
        add('FAIL', '包结构', f'目录名须以 .swiftpm 结尾，当前：{name}')

    pkg = os.path.join(root, 'Package.swift')
    if not os.path.isfile(pkg):
        add('FAIL', '包结构', '缺 Package.swift')
    else:
        src = open(pkg, encoding='utf-8', errors='replace').read()
        add('PASS', '包结构', 'Package.swift 存在')
        if '.iOSApplication' in src:
            add('PASS', '包结构', '声明为 iOS App（.iOSApplication）')
        else:
            add('FAIL', '包结构', 'Package.swift 未使用 .iOSApplication，Swift Playgrounds 能否识别存疑')
        m = re.search(r'\.iOS\("?([\d.]+)"?\)', src)
        if m:
            v = m.group(1)
            add('PASS' if float(v.split('.')[0]) >= 16 else 'FAIL', '包结构', f'最低 iOS 版本 {v}（需 16+，测试机为 iOS 16.7）')
        if CJK.search(src):
            add('FAIL', '英文规范', 'Package.swift 含中文')

    swifts = [f for f in walk(root) if f.endswith('.swift')]
    add('PASS' if swifts else 'FAIL', '源码', f'Swift 文件 {len(swifts)} 个')

    total, big = 0, []
    for f in walk(root):
        s = os.path.getsize(f)
        total += s
        if s > 500 * 1024:
            big.append((s, os.path.relpath(f, root)))
    for s, rel in sorted(big, reverse=True):
        add('WARN', '体积', f'{rel} 单文件 {s/1024/1024:.2f}MB，考虑压缩')
    add('PASS' if total < MAX_ZIP * 0.8 else 'WARN', '体积', f'原始总大小 {total/1024/1024:.2f}MB（ZIP 上限 25MB）')

    for f in swifts + [x for x in walk(root) if x.endswith('.md')]:
        rel = os.path.relpath(f, root)
        try:
            check_text(f, rel, open(f, encoding='utf-8', errors='replace').read())
        except Exception as e:
            add('WARN', '读取', f'{rel}: {e}')

    if not any(os.path.basename(f).lower() == 'ai_usage.md' for f in walk(root)):
        add('FAIL', '合规', '缺 AI_USAGE.md（规则要求披露 AI 使用情况）')
    else:
        add('PASS', '合规', 'AI_USAGE.md 存在')
    if not any(os.path.basename(f).lower() == 'readme.md' for f in walk(root)):
        add('WARN', '合规', '缺 README.md（建议写明创意、用法、素材授权）')


def check_zip(path):
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        size = os.path.getsize(path)
        add('PASS' if size <= MAX_ZIP else 'FAIL', '体积', f'ZIP {size/1024/1024:.2f}MB / 上限 25MB')
        bad = [n for n in names if '.DS_Store' in n or '__MACOSX' in n]
        add('PASS' if not bad else 'WARN', '打包', f'无系统垃圾文件' if not bad else f'含 {len(bad)} 个系统文件')
        roots = {n.split('/')[0] for n in names}
        add('PASS' if len(roots) == 1 else 'WARN', '打包',
            f'顶层单一目录：{list(roots)[0]}' if len(roots) == 1 else f'顶层有 {len(roots)} 项，建议只保留一个 .swiftpm 目录')
        if not any(n.startswith(tuple(roots)) and n.endswith('Package.swift') for n in names):
            add('FAIL', '打包', 'ZIP 内找不到 Package.swift')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    do_zip = '--zip' in sys.argv
    if not args:
        print(__doc__)
        sys.exit(2)
    target = args[0]
    print(f'\n=== SSC 提交前自检：{target} ===\n')

    if target.lower().endswith('.zip'):
        check_zip(target)
    elif os.path.isdir(target):
        check_tree(target)
        if do_zip:
            dist = os.path.join(os.path.dirname(os.path.abspath(target.rstrip('/\\'))), 'dist')
            os.makedirs(dist, exist_ok=True)
            out = os.path.join(dist, os.path.basename(os.path.abspath(target.rstrip('/\\'))) + '.zip')
            root = os.path.abspath(target.rstrip('/\\'))
            with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
                for dp, dns, fns in os.walk(root):
                    dns[:] = [d for d in dns if d not in SKIP_DIRS]
                    for fn in fns:
                        full = os.path.join(dp, fn)
                        z.write(full, os.path.join(os.path.basename(root), os.path.relpath(full, root)))
            check_zip(out)
            print(f'    -> 打包完成：{out}')
    else:
        print(f'路径不存在：{target}')
        sys.exit(2)

    order = {'FAIL': 0, 'WARN': 1, 'PASS': 2}
    results.sort(key=lambda r: order[r[0]])
    icon = {'PASS': '[ OK ]', 'WARN': '[WARN]', 'FAIL': '[FAIL]'}
    for lv, name, detail in results:
        print(f'{icon[lv]} {name:<8} {detail}')

    fails = sum(1 for r in results if r[0] == 'FAIL')
    warns = sum(1 for r in results if r[0] == 'WARN')
    print(f'\n--- 结果：{fails} 个 FAIL / {warns} 个 WARN / {len(results)} 项检查 ---')
    print('--- 人工确认项（脚本查不了）---')
    print('  [ ] 从启动到结束是否 3 分钟内自然完成？')
    print('  [ ] 断网（飞行模式）后是否一切正常？')
    print('  [ ] 界面里是否还有任何中文？')
    print('  [ ] 是否找过至少 3 个陌生人试玩，看完他们卡在哪？')
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()
