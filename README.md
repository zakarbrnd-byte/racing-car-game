# Lane Rush

A Flutter vertical-scrolling racing game with a car selection screen and endless road obstacles.

## Features

- **Car selection** — swipe through three cars (Premium 32, MSCH Speeder, Blue Hyper)
- **Endless race** — the road scrolls automatically; steer left/right to dodge obstacles
- **Obstacles** — cones, barriers, and oil slicks spawn with rising difficulty
- **Score & speed HUD** — survive longer to climb the scoreboard

## Run locally

```bash
flutter pub get
flutter run -d chrome   # or any connected device
```

## Test & analyze

```bash
flutter analyze
flutter test
```

## Play in Chrome

After merge to `main`, GitHub Actions deploys the web build to GitHub Pages:

**https://zakarbrnd-byte.github.io/racing-car-game/**

> One-time setup: repo **Settings → Pages → Source: GitHub Actions**.

## GitHub Actions

CI runs on every push/PR to `main`:

1. `flutter analyze`
2. `flutter test`
3. `flutter build web --release`
4. Deploy to **GitHub Pages** (push to `main` only)
