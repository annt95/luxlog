# Contributing to Luxlog

## Getting Started

```bash
# Clone and install dependencies
git clone <repo-url>
cd luxlog
flutter pub get

# Generate Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# Run the app (web)
flutter run -d chrome --web-renderer canvaskit
```

## Project Structure

```
lib/
├── app/              # Router, theme
├── core/             # Config, error types, services (Supabase, logging, analytics)
├── features/         # Feature modules (auth, discover, feed, gallery, etc.)
│   └── <feature>/
│       ├── data/         # Repositories
│       ├── presentation/ # Screens and widgets
│       └── providers/    # Riverpod providers
├── shared/           # Shared models, constants, widgets
```

## Architecture

- **State Management**: Riverpod 2 with `riverpod_generator` for code-gen providers
- **Routing**: GoRouter with ShellRoute for bottom nav
- **Backend**: Supabase (Auth, Database, Storage, Realtime)
- **UI**: Custom dark theme ("Obsidian Gold"), glassmorphism patterns

## Coding Conventions

- **Providers**: Use `@riverpod` annotation for generated providers. Manual `FutureProvider` / `StateNotifier` for simple cases.
- **Error Handling**: All repository methods throw typed exceptions (`NetworkException`, `AuthException`, `ValidationException`, `StorageException`).
- **Naming**: Dart standard — `camelCase` variables, `PascalCase` classes, `snake_case` file names.
- **Tests**: Place in `test/` mirroring `lib/` structure. Target 60%+ coverage.

## Security Guidelines

- File uploads: Only allow `jpg`, `jpeg`, `png`, `gif`, `webp`, `heic`
- Comments: Max 1000 characters, reject empty
- Tags: Max 30 per photo, max 50 characters each
- Search: 300ms debounce, 200 character limit
- Self-follow prevention enforced at repository level

## Running Tests

```bash
# Unit tests
flutter test

# With coverage
flutter test --coverage

# E2E tests (requires running app)
cd e2e && npx playwright test
```

## Deployment

The app deploys to Vercel as a Flutter web app with CanvasKit renderer.
See `vercel.json` and `vercel-build.sh` for configuration.
