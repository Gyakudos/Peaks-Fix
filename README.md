# Peaks Fix

Repair Shop OS

Custom built using vibe coding, I made it to manage my shop repair tickets inventory, reports (allows three reports, Intake, Technical, and Client Release) it allows for photos to be added via qr code on any phone. Allows for customer database to be built, and also keep track of returning clients. Keeping track of repairs for each customer.

Current version is only meant for windows, I will make more versions as I continue development. Planned versions Android, iOS, and Mac Current only runs locally, cloud support will be added in the future.
Doesn't have a calendar yet, this will come in the future. Both for keeping track of the repairs, and warranty end periods automatically within software per device.

Local-first: one SQLite file on the machine, no server, no accounts, no cloud.

## Status

Early but usable. The Windows shell, ticket intake, device catalog and Report 2
bench log work end to end. The client report and remaining tabs are still being
built.

**Working**

- **Windows shell** — persisted window geometry, centered first launch, custom
  Flutter title bar, tray icon and single instance.
- **Five tabs** — Tickets (default), Customers, Merch, Parts, Settings, shown as
  a rail on wide windows and a bottom bar on narrow ones.
- **Tickets board** — `In the shop` and `Finished`, with a real intake form.
- **Intake** — customer name/phone/email, category → brand → model, optional
  model number, serial or **No serial number sticker** (which issues a
  shop-applied `PFS-` serial), fault, and a shop tag issued in the same
  transaction. A single Joy-Con adds a **Left / Right** selector, and the side
  travels with the ticket. Find returning customers by phone or email and
  reuse their saved device records.
- **Customers** — searchable customer profiles with editable contact details
  and notes, owned devices, and repair-ticket history.
- **Device catalog** — 7 categories, including Vacuum with common Dyson, Kirby,
  Dirt Devil and Shark models, plus General Electronics for unlisted devices;
  seeded additively so upgrades never wipe shop edits.
- **Report 1 checklist** — per-device photo templates (3DS gets its own five
  shots; Vacuum gets Front, Back and Charge Port; General Electronics gets
  generic device shots labeled with its device name), previewed at intake and
  copied onto the ticket. Windows supports QR phone capture for all checklists,
  and tickets can add labeled optional photos.
- **Report 1 notes** — a condition field for scratches, cracks, stickers and
  missing parts. It saves itself onto the ticket as you type, alongside the
  photos.
- **Report 2 bench log** — after Report 1 is complete, add ordered notes and
  photos, including several photos attached to one note. The entries copy into
  the editable Report 3 draft; later bench edits update untouched draft entries
  without overwriting customer wording or photo-inclusion choices.
- **Phone capture** — on the shop PC, **Capture with phone** shows a QR code;
  scan it with a phone on the same Wi-Fi and shoot the Report 1 slots straight
  into the open ticket. Photos land as thumbnails on the PC as they arrive.
- **Local data** — drift/SQLite with versioned, in-place migrations.

**Next**

- Structured Report 2 tests, findings, estimates and contact log; Report 3
  summary, warranty page and printing.
- Merch and Settings beyond their placeholders.

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

Captured photos are files beside the database, not blobs:

```text
%APPDATA%\com.example\vola_fix\photos\ticket_<id>\
```

Each Report 1 slot has one file at a time. Retaking a shot writes a new file
and removes the older one, so the database only ever stores the current path.
Back up the whole `com.example\vola_fix` folder to keep tickets and photos
together.

## Phone capture

1. Open a ticket, expand **Intake / cosmetic**, and press **Capture with phone**.
2. Scan the QR with the phone camera (or type the address shown).
3. Tap each slot on the phone; the PC counter and thumbnails update as photos
   land.

The PC starts a small HTTP server bound to its LAN address and stops it when
the dialog closes. The link carries a random one-time token and is not
reachable from the internet. Photos are downscaled on the phone before upload
and accepted only as JPEG, PNG or WebP up to 12 MB.

If the phone cannot load the page:

- Both devices must be on the same Wi-Fi, not guest Wi-Fi with client isolation.
- Allow `vola_fix.exe` through **Windows Defender Firewall** for private
  networks the first time Windows asks. If the prompt was dismissed, add the
  rule in Windows Security → Firewall & network protection.
- VPNs and virtual adapters can take over the route; disconnect them or use
  **New link** after changing networks.


## Layout

```text
lib/
  app.dart                  tab shell (rail / bottom bar)
  main.dart                 startup, window shell, seeding
  data/                     drift schema, seeding, repositories, photo templates,
                            photo files and the local capture server
  features/
    tickets/                board, ticket page, shared widgets
    capture/                QR dialog and phone pairing
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
