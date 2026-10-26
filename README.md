# Vola Fix

Repair-shop management for consoles, retro hardware, portable consoles and
handheld PCs. Flutter desktop app for Windows, with an Android build for the
bench and the counter.

Local-first: one SQLite file on the machine, no server, no accounts, no cloud.

## Status

Early but usable. The Windows shell, ticket intake and the device catalog work
end to end. Report editors and the remaining tabs are still being built.

**Working**

- **Windows shell** — persisted window geometry, centered first launch, custom
  Flutter title bar, tray icon and single instance.
- **Five tabs** — Tickets (default), Customers, Merch, Parts, Settings, shown as
  a rail on wide windows and a bottom bar on narrow ones.
- **Tickets board** — `In the shop` and `Finished`, with a real intake form.
- **Intake** — customer name/phone/email, category → brand → model, optional
  model number, serial or **No serial number sticker**, fault, and a shop tag
  issued in the same transaction.
- **Device catalog** — 5 categories, 77 pickable models and 12 services, seeded
  additively so upgrades never wipe shop edits.
- **Report 1 checklist** — per-device photo templates (3DS gets its own five
  shots; PSP gets the slab set), previewed at intake and copied onto the ticket.
- **Local data** — drift/SQLite with versioned, in-place migrations.

**Next**

- Report 1 photo capture, report 2 editor, report 3 two-page editor/printer.
- Customers, Merch, Parts and Settings beyond their placeholders.

## Requirements

- Flutter **3.47.8** stable (Dart 3.13), or a compatible newer stable release.
- **Windows:** Windows 10/11 and Visual Studio 2022 Build Tools with
  *Desktop development with C++*.
- **Android:** Android SDK, JDK 17+ (this project is built with JDK 21).

## Run

```powershell
flutter pub get
flutter run -d windows
```

For Android, connect a device or start an emulator and run `flutter run`.

## Build

```powershell
# After changing the drift schema:
dart run build_runner build --delete-conflicting-outputs

flutter build windows --release
flutter build apk --release
```

- Windows: `build\windows\x64\runner\Release\vola_fix.exe`
- Android: `build\app\outputs\flutter-apk\app-release.apk`

The APK is currently signed with the debug key so it installs for testing. Add
your own keystore before distributing it, and change the placeholder
`applicationId` (`com.example.vola_fix`) and the `com.example` package in
`windows/runner/Runner.rc` if you plan to publish.

## Data

The database lives in the app support directory, never in Documents, so it
cannot be picked up by OneDrive:

```text
%APPDATA%\com.example\vola_fix\vola_fix.sqlite
```

To start over, close the app and delete that file (and any `-wal`/`-shm`
companions). Migrations run in place, so normal upgrades do not need this.

## Layout

```text
lib/
  app.dart                  tab shell (rail / bottom bar)
  main.dart                 startup, window shell, seeding
  data/                     drift schema, seeding, repositories, photo templates
  features/
    tickets/                board, ticket page, shared widgets
    repairs/                intake form
    customers/ merch/ parts/ settings/
  window/                   Windows-only shell: title bar, tray, single instance
test/                       widget and label tests
```

## Docs

- [`APP_STRUCTURE.md`](APP_STRUCTURE.md) — tabs, data model, seeding, catalog.
- [`REPORTS.md`](REPORTS.md) — the three per-ticket reports and their rules.
- [`WINDOWS_SHELL.md`](WINDOWS_SHELL.md) — window placement, title bar, tray and
  single-instance behaviour.

## Design notes

- The shop is run by one person, so the three reports are **stages of one job**
  rather than handoffs between staff. Nothing is locked behind a role, and
  status changes are badges, not gates.
- The device catalog is **family-based**: one `PSP` row, with the revision
  (`PSP-3000`) typed into the model-number field. Retired rows are hidden rather
  than deleted so old tickets still resolve their original model.
- A shop tag (`G-482913057`) is written once and never reused. Two stickers are
  printed per tag, one outside the device and one inside.
