"""Copy reviewed text source from the fixed Token Studio origin; never execute fetched code."""
import datetime, hashlib, json, pathlib, re, urllib.request
SOURCE = 'https://token.orqubic.com/development/token-studio-source.json'
DEST = pathlib.Path('live-sources/token-studio')
def validate(data):
    if data.get('schemaVersion') != 1 or data.get('project') != 'orqube-token-studio' or data.get('scope') != 'sanitized-text-source':
        raise ValueError('Unexpected source identity')
    files = data['files']
    if not 1 <= len(files) <= 500:
        raise ValueError('Unexpected file count')
    seen = set()
    for f in files:
        name, content = f['path'], f['content']
        p = pathlib.PurePosixPath(name)
        if not isinstance(content, str) or '\x00' in content or '\\' in name or p.is_absolute() or any(x in ('.', '..', '.git') for x in name.split('/')) or name in seen:
            raise ValueError('Unsafe source path or content')
        if name not in ('package.json', 'package-lock.json', 'OPERATIONS_KO.md') and (p.parts[0] not in ('public', 'worker', 'src', 'contracts', 'scripts', 'tests') or p.suffix not in ('.js', '.mjs', '.css', '.html', '.json', '.sol', '.md', '.py', '.yml')):
            raise ValueError('Source outside approved scope')
        if re.search(r'AIza[0-9A-Za-z_-]{30,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----', content) or 'orqube-576e7' in content:
            raise ValueError('Operational setting or key in archive')
        if hashlib.sha256(content.encode()).hexdigest() != f['sha256']:
            raise ValueError('Source checksum mismatch')
        seen.add(name)
    index = [{'path': f['path'], 'sha256': f['sha256']} for f in files]
    checksum = hashlib.sha256(json.dumps(index, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()
    if checksum != data.get('contentHash'):
        raise ValueError('Manifest checksum mismatch')
    return files

def synchronize(data):
    files = validate(data)
    stamp = DEST / 'SOURCE_MANIFEST.json'
    if stamp.exists() and json.loads(stamp.read_text()).get('contentHash') == data['contentHash']:
        print('Token Studio source unchanged')
        return
    # Validate all paths before touching existing files. Only this dedicated mirror is changed.
    if DEST.is_symlink():
        raise ValueError('Mirror root must not be a symlink')
    for existing in DEST.rglob('*') if DEST.exists() else []:
        if existing.is_symlink():
            raise ValueError('Mirror contains a symlink')
    wanted = {f['path'] for f in files}
    for existing in DEST.rglob('*') if DEST.exists() else []:
        if existing.is_file() and existing.relative_to(DEST).as_posix() not in wanted and existing != stamp:
            existing.unlink()
    for f in files:
        target = DEST / f['path']
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(f['content'], encoding='utf-8')
    metadata = {k: v for k, v in data.items() if k != 'files'}
    metadata['files'] = [{k: f[k] for k in ('path', 'sha256')} for f in files]
    metadata['sourceUrl'] = SOURCE
    metadata['observedAt'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    stamp.write_text(json.dumps(metadata, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    date = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).date().isoformat()
    folder = pathlib.Path('worklogs/sites') / date
    folder.mkdir(parents=True, exist_ok=True)
    (folder / (data['contentHash']+'.json')).write_text(json.dumps(metadata, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print('Token Studio source synchronized:', len(files), 'files', data['contentHash'])

if __name__ == '__main__':
    with urllib.request.urlopen(urllib.request.Request(SOURCE, headers={'User-Agent': 'ORQUBE-Development-Archive/1'}), timeout=45) as response:
        if response.geturl() != SOURCE:
            raise ValueError('Unexpected source redirect')
        payload = response.read(10_000_001)
    if len(payload) > 10_000_000:
        raise ValueError('Source archive too large')
    synchronize(json.loads(payload))
