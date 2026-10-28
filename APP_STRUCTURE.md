# App structure

## Tabs (9)

| # | Tab | Contains |
| --- | --- | --- |
| 1 | **Tickets** | Default screen. Job board grouped by status, plus the *New repair* button. |
| 2 | **Closed Tickets** | Paid jobs that have been closed, with a **Reopen** action for warranty work. |
| 3 | **Checkout** | Ready tickets: bill lines, merchandise, payment and closing. |
| 4 | **Calendar** | Monthly view of drop-off, technician start, parts arrival, customer contact and pickup dates. |
| 5 | **Customers** | Contact records, devices owned, repair and merch history. |
| 6 | **Merch** | Retail stock list: add, edit and remove items with SKU, stock, cost and price. |
| 7 | **Parts** | Repair components with stock and committed quantities, consumed from tickets. |
| 8 | **Financial** | Revenue, separate parts and merchandise trackers, profit, tracked hours and estimated pay per staff member. |
| 9 | **Settings** | Staff directory and time clock, markup, device catalog, shop settings. |

Deliberately **not** tabs:

- **New repair** — a button on the Tickets page that opens the intake form.
- **Devices** — owned-device records live under each customer and link to all
  matching repair tickets. The category / brand / model catalog that feeds
  intake remains in Settings.
- **Reports** — three per-ticket documents; see `REPORTS.md`.

## Layout

One destination list (`lib/shell/shop_destination.dart`) drives both navs:

- **Wide (>= 900 px, i.e. any normal Windows window):** `NavigationRail`.
- **Narrow (Android, small Windows window):** `NavigationBar` with all 9 items.

Checkout and Closed Tickets show a live count on their tab icon; Financial
shows the all-time net estimate in a compact badge. Each of those pages repeats
the figure in its header, where Financial follows the selected period.

The Windows title bar is rendered by Flutter above the navigator
(`lib/app.dart`), so pushed routes such as intake never cover the window
buttons.

## Solo operator assumptions

The shop is run by one person, so the app is built for one pair of hands:

- Staff is a lightweight directory, not a permission system: each person has a
  name, job, active flag and optional hourly pay. Staff can sign in to a shared
  time clock, and each person has their own hours and assigned-ticket views.
  There are no accounts, roles, assignments or handoffs, and report completion
  is still a stage of one job.
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

- **Parts** are internal consumables attached to a ticket: cost, stock, and
  consumed during a repair. Each part records a **description**, its **Vendor
  ID** (where it is purchased) and **Vendor SKU** (the exact item ordered),
  alongside its own internal SKU and storage location. Shop SKUs use the
  `000-000` format and are assigned automatically when left blank. The **Parts
  Invoice** picker searches by either SKU or part name. A part can be marked as
  a **single item** or a **bulk purchase**; bulk parts store the quantity and
  total cost, and the cost per item is calculated from them. Each part card
  also shows **Committed**, the quantity open tickets still need. Adding a part
  to a ticket does not touch **Inventory** (on-hand); **closing the ticket
  deducts the fitted parts from Inventory and logs a movement**. Each ticket
  line remembers how much it has already consumed
  (`ticket_items.consumed_quantity`), so reopening a closed job for warranty
  does not deduct the same part again — only parts added for the second visit
  are taken out when it closes. Inventory never goes below zero; a shortfall is
  written into the movement note. **Stock** is the minimum level and is edited
  separately in the part dialog.
- **Merch** is customer-facing retail: a flat stock list with its own
  `000-000` SKU sequence, category, description, location, stock, cost and
  retail price. The Merch page mirrors the Parts page layout. Merchandise sold
  through Checkout records its cost and price on the ticket line, so retail
  revenue stays independent of any repair ticket while still feeding the
  Financial trackers. Size/colour variants remain a future addition.

Merging them would corrupt both stock counts and revenue reporting.

## Data

- Local SQLite through `drift`; the file is `vola_fix.sqlite` in the app support
  directory (`%APPDATA%\com.example\vola_fix` on Windows). Deliberately not in
  Documents, so it never syncs to OneDrive or gets moved by accident.
- Seeded on first launch: five device categories (Consoles, Retro consoles,
  Portable Consoles, Handheld PCs, Controllers) with 78 pickable models, 12
  services, and settings (shop name, `PF` ticket prefix, `PFS` shop-serial
  prefix, `G` tag prefix, 90-day warranty default and terms, 5% GST on, 7% PST
  off). Each device category also carries the warranty period it offers on
  Report 3. Seeding is
  additive and matched by name:
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
  template key on models and tickets, v4 added `device_models.sort_order`, and
  v5 added `tickets.device_side` for devices booked one half at a time, then v6
  added `tickets.intake_notes` for the Report 1 condition notes. Upgrading in
  place never loses data.
- Schema v12 adds Drop Off, Technician Start, Parts Arrive and Customer
  Contacted dates to tickets; the existing pickup date is reused. Old tickets
  use their creation date for Drop Off. The Calendar tab shows all five
  milestones, and each report section uses the same saved ticket dates.
- Schema v13 adds `tickets.report2_completed_at` and `report3_completed_at`.
  Report 1 completion already unlocked Report 2; completing Report 3 also moves
  the ticket to **Ready** so it appears in Checkout.
- Schema v14 adds `tickets.gst_cents` and `pst_cents`, the tax snapshot written
  when a paid ticket closes. Invoices calculate GST/PST on the discounted
  subtotal; settings store the enabled flags and rates in basis points (500 =
  5%). The first-run seed turns GST on at 5% and leaves PST off at 7%.
- Schema v15 adds `parts.vendor_id` and `parts.vendor_sku`, so inventory parts
  remember where they were purchased and the vendor's catalogue SKU. It also
  adds the purchase type, bulk quantity and bulk total used to calculate the
  per-item cost of a bulk lot.
- Schema v16 adds `parts.description` and assigns a `000-000` SKU to every part
  that did not have one, starting after the highest existing formatted SKU.
  Hand-written SKUs are preserved.
- Schema v17 adds `device_categories.warranty_days`, the warranty period each
  category offers on Report 3. It defaults to 90 days, so existing categories
  pick up the shop default without touching their other settings.
- Schema v18 adds `merch_products.sku`, `location`, `stock`, `cost_cents` and
  `price_cents`, so the Merch page can list retail stock like the Parts page.
  Merchandise SKUs use their own `000-000` sequence and do not consume part
  numbers.
- Schema v19 adds `ticket_items.consumed_quantity`, the amount of each part line
  already taken out of stock when its ticket closed. Tickets that were already
  closed at upgrade time are marked fully consumed so their stock is not changed
  retroactively.
- Schema v20 adds `parts.reorder_level` as the minimum stock threshold.
  `parts.stock` remains the on-hand inventory count; it is only deducted when a
  ticket is closed. Both fields can be edited from the part dialog.
- Report 3 **warranty coverage** resolves its default from the ticket's device
  category (`device_categories.warranty_days`), falling back to the shop's
  `warranty_days` setting and its `warranty_terms`. The per-ticket length and
  terms are stored on the client `ticket_reports` row. Completing Report 3
  stamps `warranty_start_at` and freezes the days/terms; reopening clears only
  the start date. Saved customer devices read the latest completed Report 3
  warranty for that device, so a later repair shows the newer cover.
- **Financial** is calculated from existing records, not a separate ledger.
  Revenue is each closed ticket's invoice subtotal minus its saved discount and
  before tax; cost is the recorded `ticket_items.unit_cost_cents` for parts and
  merchandise. Parts and merchandise also keep separate sold/cost/profit and
  margin trackers. Each line group's revenue is its subtotal minus a
  proportional share of the invoice discount, allocated to the cent, so parts
  revenue + merchandise revenue + services revenue always equals total revenue.
  GST and PST are reported separately from the stored snapshots,
  so later rate changes do not rewrite old tickets. Gross profit is revenue
  minus that cost, and net profit is an
  estimate after subtracting tracked staff time × hourly rate. Labour lines
  carry no cost, so staff pay is not double-counted. The period chips filter
  both closed tickets (by close date) and shifts (clipped to the period); the
  tab opens on **This month** with a **Yearly view** button.
- **Reopen** on a closed ticket sends it back to the board in a chosen active
  status (default **In repair**). Reports, invoice lines and payments stay
  attached; because the status is no longer `closed`, the ticket leaves the
  Financial totals until it is closed again.
- A **single Joy-Con** is a catalog row of its own (`Joy-Con (single)`), and
  intake asks **Left / Right** as a follow-up. The side is stored on the ticket
  (`device_side`) and shown on the board and the ticket page. A pair remains one
  device and asks nothing.
- The picker follows the catalog's **own order**, not the alphabet:
  `device_models.sort_order` keeps `DualShock 1 → 2 → 3 → 4 → DualSense 5` and
  puts newer hardware first (`PlayStation 5` before `PlayStation 4`). Anything
  added outside the seed list is parked after the seeded models for its brand.
- Report 1 checklists are **templates per device family** (`hinged`, `slab`,
  `console`, `pc`, `controller`, `vacuum`, `general_electronics`) stored in `photo_templates` /
  `photo_template_slots`. At intake the chosen family is resolved from the
  model, and its slots are copied into `ticket_photo_slots` on the ticket. A
  later template edit therefore never rewrites an open job, and each ticket can
  gain its own captured photo paths.
- Vacuum tickets require only Front, Back and Charge Port. The ticket page can
  add labeled optional slots; these accept phone or local photo uploads and do
  not block Report 1 completion.
- General Electronics is available for devices outside the specialized
  categories and uses the standard unlisted-device, model-number, serial, and
  fault fields. Its general photo checklist is labeled with the entered device
  name rather than “Home console”.
- On Windows, **Capture with phone** is available for any Report 1 checklist,
  including Vacuum and General Electronics.
- Report 1 photo **files** live under
  `%APPDATA%\com.example\vola_fix\photos\ticket_<id>\`; the database stores only
  the current path and capture time on `ticket_photo_slots`. Every capture gets
  a new file name, so a retake cannot be served from Flutter's image cache, and
  the older file for that slot is deleted once the new one is safely written.
- Report 1 **condition notes** are `tickets.intake_notes`, a nullable text field.
  The ticket page debounces typing by 800 ms, saves on focus loss, and flushes
  on dispose, so a solo operator never has to press Save. Whitespace-only text
  is stored as null rather than an empty string.
- **Phone capture** is a short-lived local HTTP server
  (`lib/data/capture_server.dart`) opened from the ticket page. It binds to the
  PC's LAN IPv4 address, puts a random 24-byte token in the URL, and serves only
  `/c/<token>/` routes: the phone page, status, the current photo, and
  per-slot uploads. The server closes with the dialog, and a 30-minute timer is
  a backstop if the window is left open.
  - Uploads are checked by declared MIME type, magic bytes and a 12 MB cap; a
    slot number outside the ticket's checklist is refused. The phone page
    downscales to a 2000 px JPEG before sending, so a 48 MP photo does not
    cross the Wi-Fi at full size.
  - The phone page uses `<input type="file" capture="environment">` rather than
    `getUserMedia`, because phone browsers only grant camera access on HTTPS or
    localhost, while this link is plain HTTP on the LAN.
  - The PC dialog watches the same `ticket_photo_slots` stream as the ticket
    page, so progress and thumbnails update live without polling SQLite.
  - Only Report 1 photos are in scope today. The server is ticket-shaped
    (slots, saver callback) so phone intake can reuse it later.
- Ticket numbers come from a stored counter (`PF-000001`), so they are never
  reused even if a ticket is deleted.
- When the factory sticker is missing, intake ticks **No serial number sticker**
  and the app issues a shop-applied serial (`PFS-482913057`): random nine digits,
  checked against every stored serial, saved in `tickets.serial` with
  `serial_missing = true`. A ticket can never be missing a sticker and a serial
  at the same time.
- Shop tags are random nine-digit numbers (`G-482913057`), recorded permanently
  and never issued twice; two stickers per tag, one outside the device and one
  inside.
- A customer record needs **name, phone and email** for repair intake.
  Customers can be selected by phone or email; the newest ticket updates their
  contact details while preserving profile notes.
- Each customer device stores its catalog model or free-text name, variant,
  side, and serial. Intake can reuse a saved device; a serial match also links
  future repair tickets to that device. Existing ticket device records are
  migrated into the customer device registry. The customer page shows each
  device's latest warranty, or **No warranty on file**.

## Current state

- **Shell** — done: persisted window geometry, custom Flutter title bar, tray
  icon, single instance, rail/bottom-bar navigation.
- **Data** — drift/SQLite, seeded console, handheld, controller and vacuum
  catalog, ticket numbering, shop tags and
  shop-applied serials.
- **Tickets** - real board, working intake (saves a ticket and issues its tag)
  and a ticket page where the status can be moved. Closed tickets can be
  **reopened** for warranty work without losing their reports or payments.
  Intake previews the Report 1 photo checklist for the selected device, and the
  ticket keeps its own copy.
- **Report 1 photos** — the shop PC shows a QR, the phone fills slots over the
  LAN, and captured shots appear as tappable thumbnails on the ticket.
- **Report 1 notes** — a per-ticket condition box that saves itself while
  typing, for scratches, cracks, stickers and missing parts.
- **Reports** — Report 2 has an ordered internal bench log for notes and photos.
  Entries sync into an editable Report 3 draft while unedited content stays
  linked. Report 2 and Report 3 each have **Complete** and **Reopen** controls;
  completing Report 3 confirms, freezes its warranty coverage and sends the
  ticket to Checkout. Structured estimates, client-report printing and the
  remaining Report 3 projections remain to be built; see `REPORTS.md`.
- **Customers** — searchable and editable profiles with devices, their latest
  warranty, and repair history. Intake can select existing customers and
  devices.
- **Merch** — retail stock list with its own SKUs, stock, cost and calculated
  retail price, laid out like the Parts page. **Settings** is live: staff
  directory and time clock, parts/merch markup, shop values and the device
  catalog, including each category's warranty period.
- **Staff** — directory with inline edit (name, job, active, hourly pay), a
  shared sign-in/time clock, per-person tracked hours and estimated pay, and a
  per-person list of tickets assigned on any report stage.
- **Financial** — closed-ticket revenue, separate parts and merchandise
  trackers, gross profit, tracked
  staff hours and pay, and a net profit estimate, with All time / This month /
  Last 30 days / This year filters.
