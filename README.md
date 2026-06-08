# Zeta Idle

A Flutter-based idle RPG prototype for Android.

## Project Setup

1. Install Flutter and add it to your PATH.
2. Open `zeta_idle_app` in VS Code.
3. Run `flutter pub get`.
4. Use `flutter run` to launch on an Android device or emulator.

## Project Structure

- `lib/main.dart` — app entrypoint and navigation
- `lib/services/game_state.dart` — core progression state and business logic
- `lib/models/` — hero, upgrades, and daily challenge data models
- `lib/data/game_data.dart` — initial upgrade and challenge definitions
- `lib/screens/` — home, campaign, endless, and daily mode user interfaces
- `lib/widgets/` — reusable UI components
- `assets/` — placeholder for future art, audio, and save data

## Implemented systems

- Hero progression with XP, leveling, and stat growth
- Campaign stage system with difficulty and progression
- Idle progress accumulation and reward collection
- Upgrade purchases with cost scaling and stat effects
- Daily challenge completion system
- Local save/load support via shared preferences
- Cloud save/auth placeholders for future integration

## Next steps

- Replace placeholder visuals with pixel art and themed UI
- Implement real cloud save backend and authentication
- Add enemy difficulty scaling, campaign milestones, and boss fights
- Add audio, analytics, and Android build configuration

## New Features

- Turn-based battle system with enemy stages and combat log
- Local save/load and stubbed Firebase cloud sync
- Audio service placeholder for future sound integration
- New battle route and campaign-to-battle flow

## Firebase Notes

This scaffold now includes `firebase_core`, `firebase_auth`, and `cloud_firestore` dependencies. Add your Firebase configuration files for Android and iOS to enable cloud save.
