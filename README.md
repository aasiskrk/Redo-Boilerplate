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

```bash
  dev_dependencies:
    redo_boilerplate: ^1.0.0
```

```bash
dart pub global activate redo_boilerplate
```

## Usage
```bash
# In current project
redo_boiler init

# Non-interactive defaults (clean architecture)
redo_boiler init -y

# Scaffold into a specific directory
redo_boiler init -d path/to/app
```

If using without global activation:
```bash
dart run redo_boiler init -y -d .
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
