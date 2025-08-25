# redo_boilerplate

Note: A gentle reminder that this package is generating files according to my preference, you can clone the repo and make your own, I will probably keep on imporving according to my choices.

A Dart CLI that scaffolds Flutter boilerplate (architecture folders, constants, networking, and themes) into an existing or new project.

## Features
- Interactive or non-interactive (-y) initialization
- Choose architecture: clean or mvvm
- Always generates constants subtree (failures, navigator, networking with Dio)
- Adds dependencies (dio, pretty_dio_logger)
- Generates themes under `lib/constants/theme` and seed `app/app.dart`, `main.dart`

## Installation

Option A) Global (run from any project)
```bash
dart pub global activate redo_boilerplate
# On Windows PowerShell, ensure global pub cache bin is on PATH (once):
$env:Path += ";$HOME\AppData\Local\Pub\Cache\bin"
# To persist it:
setx PATH "$($env:Path);$HOME\AppData\Local\Pub\Cache\bin"
```

Option B) As a dev dependency (per-project)
```yaml
dev_dependencies:
  redo_boilerplate: ^1.0.0
```
Then:
```bash
flutter pub get   # or: dart pub get
```

## Usage
Global usage (recommended):
```bash
# Scaffold into current project (note: -d requires a path, use . for current)
redo_boiler init -y -d .

# Interactive mode (you will be prompted)
redo_boiler init -d .

# Scaffold into a specific directory
redo_boiler init -y -d path/to/app
```

Via dev dependency (no global install):
```bash
# In your app project root
dart run redo_boilerplate:redo_boiler init -y -d .

# Or interactive
dart run redo_boilerplate:redo_boiler init -d .
```

## Flags
- `-y, --yes`: Accept defaults (non-interactive)
- `-d, --dir <path>`: Target directory for scaffolding (use `.` for current)

## Output summary
- `lib/constants/**` (failures, navigator, networking, theme, api_endpoints)
- `lib/app/app.dart`
- `lib/main.dart`
- Architecture-specific directories under `lib/src/**`

## Example
See `example/USAGE.md` for usage notes.

## Changelog
See [CHANGELOG.md](CHANGELOG.md).

## License
MIT © 2025 Aashista Karki
