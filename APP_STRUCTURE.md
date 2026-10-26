# App structure

## Tabs (5)

| # | Tab | Contains |
| --- | --- | --- |
| 1 | **Tickets** | Default screen. Job board grouped by status, plus the *New repair* button. |
| 2 | **Customers** | Contact records, devices owned, repair and merch history. |
| 3 | **Merch** | Retail products and variants, quick sell + cart, stock and sales. |
| 4 | **Parts** | Repair components, consumed from tickets. |
| 5 | **Settings** | Shop info, ticket numbering, device catalog, backup. |

Deliberately **not** tabs:

- **New repair** — a button on the Tickets page that opens the intake form.
- **Devices** — a device is recorded on the ticket. The catalog that feeds the
  pickers (categories, brands, models, service templates) lives in Settings.
- **Reports** — three per-ticket documents; see `REPORTS.md`.

## Layout

One destination list (`lib/shell/shop_destination.dart`) drives both navs:

- **Wide (>= 900 px, i.e. any normal Windows window):** `NavigationRail`.
- **Narrow (Android, small Windows window):** `NavigationBar` with all 5 items.

The Windows title bar is rendered by Flutter above the navigator
(`lib/app.dart`), so pushed routes such as intake never cover the window
buttons.

## Solo operator assumptions

The shop is run by one person, so the app is built for one pair of hands:

- No staff accounts, roles, assignments or handoffs. The author on a report is
  stamped from the shop name in Settings (editable), which also means adding
  accounts later needs no data migration.
- Status changes are **never blocked**. Missing information is surfaced as a
  badge, not a gate — a solo shop works out of order.
- Report 2 is optional for simple jobs (see `REPORTS.md`).
- Everything autosaves as a draft.

## Ticket status pipeline

`Received → Diagnosing → Awaiting approval → Awaiting parts → In repair →
Testing → Ready → Picked up`, plus `Closed` (declined / unrepairable) and
`Cancelled`.

Payment state is tracked separately, so "ready for pickup" and "unpaid" can
both be true.

## Merch vs Parts

Separate tables on purpose:

- **Parts** are internal consumables attached to a ticket: cost, supplier,
  stock, consumed during a repair.
- **Merch** is customer-facing retail: variants (size/colour), SKU/barcode, and
  sales that happen independently of any ticket.

Merging them would corrupt both stock counts and revenue reporting.

## Data

- Local SQLite through `drift`; the file is `vola_fix.sqlite` in the app support
  directory (`%APPDATA%\com.example\vola_fix` on Windows). Deliberately not in
  Documents, so it never syncs to OneDrive or gets moved by accident.
- Seeded on first launch: five device categories (Consoles, Retro consoles,
  Portable Consoles, Handheld PCs, Controllers) with 77 pickable models, 12
  services, and settings (shop name, `VF` ticket prefix, `G` tag prefix,
  90-day warranty default and terms). Seeding is additive and matched by name:
  later launches only add rows that are missing, so shop edits, custom models
  and added categories survive, and an existing database never needs to be wiped
  to gain a new model.
- The catalog is **family-based**: one `PSP` row rather than four revisions.
  The revision (`PSP-3000`, `New 3DS XL`) is typed into the ticket's **model
  number** field and travels with it to the reports. Retired rows are hidden
  (`is_active = 0`) rather than deleted, so old tickets keep resolving the model
  they were booked under.
- Schema is versioned and migrated on open: v2 added `tickets.device_variant`
  for that model number, v3 added the Report 1 photo-checklist tables and a
  template key on models and tickets, so upgrading in place never loses data.
- Report 1 checklists are **templates per device family** (`hinged`, `slab`,
  `console`, `pc`, `controller`) stored in `photo_templates` /
  `photo_template_slots`. At intake the chosen family is resolved from the
  model, and its slots are copied into `ticket_photo_slots` on the ticket. A
  later template edit therefore never rewrites an open job, and each ticket can
  gain its own captured photo paths.
- Ticket numbers come from a stored counter (`VF-000001`), so they are never
  reused even if a ticket is deleted.
- Shop tags are random nine-digit numbers (`G-482913057`), recorded permanently
  and never issued twice; two stickers per tag, one outside the device and one
  inside.
- A customer record needs **name, phone and email**; the intake form refuses to
  save without them. Returning customers are matched by name (case-insensitive)
  and their phone/email are updated to whatever the newest job supplies.

## Current state

- **Shell** — done: persisted window geometry, custom Flutter title bar, tray
  icon, single instance, rail/bottom-bar navigation.
- **Data** — drift/SQLite, seeded catalog, ticket numbering, shop tags.
- **Tickets** — real board, working intake (saves a ticket and issues its tag)
  and a ticket page where the status can be moved. Intake previews the Report 1
  photo checklist for the selected device, and the ticket keeps its own copy.
- **Reports** — specified in `REPORTS.md`, including the client report's
  warranty page. Report 1's device-specific shot list is stored per ticket;
  photo capture and the report editors are next.
- **Customers, Merch, Parts, Settings** — still placeholders.
