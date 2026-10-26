# Reports

Three reports per ticket. They are snapshots of the same job taken at
different moments, not separate documents to maintain. All three are filled by
the same operator — the shop is currently one person — so they are styled as
stages, not staff roles.

## Report 1 — Intake / cosmetic

Produced by the **New repair** wizard, so the checklist is never typed twice.
Purpose: liability and a baseline for the client report.

- Device identity: category → brand → model, serial/IMEI, accessories received,
  and the **shop tag** issued at intake (`G-482913057`).
- Serial field plus a **`No serial number sticker` checkbox** — the single
  switch for "there is nothing readable on this unit". Checking it generates a
  shop-applied serial (`PFS-482913057`), fills the now-disabled serial field with
  it, and stores it on the ticket. A serial is therefore never blank by accident:
  it was either typed from the factory sticker, or the shop issued one. The tag
  is still issued as well, because every device gets one.
- Cosmetic checklist by area: screen, bezel, front shell, back shell, corners,
  ports, buttons, hinge/stand, vents.
- Condition scale: `good / scuffed / scratched / cracked / missing`.
- **Required photos — 5 slots, in this order.** The last slot is always the
  serial / shop-tag shot; the first four depend on the **device family**, which
  is picked from the category + model at intake. The intake form previews the
  list before saving, and the ticket stores its own copy, so editing a template
  later never rewrites a job that is already open.

  | Family | Shots 1–4 |
  | --- | --- |
  | **Hinged handheld** (3DS, DS, GBA SP) | Top screen (closed) · Back (closed) · Charger port · Open (both screens) |
  | **Slab handheld** (PSP, Game Boy) | Front · Back · Top edge · Bottom edge |
  | **Home console** (PS5, Xbox, retro consoles) | Front · Back · Left side · Right side |
  | **Handheld PC** (Steam Deck, ROG Ally) | Front · Back · Left edge · Right edge |
  | **Controller** | Front · Back · Top edge · Battery bay |

  Every family ends with **slot 5 — Serial / IMEI label**: the original
  sticker, or a shop-applied label when the original is missing or illegible.

  On a **Nintendo 3DS**, for example, the checklist is: `Top screen (closed)`,
  `Back (closed)`, `Charger port`, `Open (both screens)`, `Serial label`.

  Each slot is a labelled tile; tapping it opens the camera (Android) or file
  picker (Windows). Retaking replaces the slot rather than adding a duplicate.
  A counter shows `4 of 5 required`.
- **Checklists seeded today:** `hinged`, `slab`, `console`, `pc`, `controller`
  (five templates, 25 slots). A free-text device booked under a category uses
  that category's family; a catalog model can override its family in the
  database without a schema change.
- **Older jobs** created before checklists existed show `no photo slots` rather
  than being retro-fitted, because the shop may have already changed what it
  photographs.
- **Optional extra shots**, added beyond the five: powered on, damage close-up,
  accessories included, repair progress.
- Every photo is timestamped and stored on the ticket. Extras can be marked
  client-visible for report 3; the five required shots default to visible.
- Pre-existing faults noted (e.g. "screen already cracked").
- **Serial handling.** Capture the factory serial/IMEI when it is readable.
  When the sticker is missing, worn or illegible, tick **No serial number
  sticker** rather than leaving the field blank. The checkbox is the explicit
  record that the unit never had a readable label, so nobody later assumes it
  was forgotten.

  Every device also gets a **shop tag** at intake, whatever the serial says:
  a random nine-digit number, e.g. `G-482913057` (prefix configurable in
  Settings). Two stickers are printed with the same tag — one on the outside of
  the device, one inside the shell/battery bay. The tag is what identifies the
  unit at pickup, in the workshop and on the client report.

  - A tag is **written once and never reused**. Issued tags are kept in the
    database permanently, so a tag from a closed or deleted ticket can never
    come back on a different device.
  - The number is random rather than sequential, so it reveals nothing about
    how many jobs the shop has done.
  - If a sticker is lost or damaged, issue a **replacement tag**; the old number
    is retired but stays on record.
  - Slot 5 is photographed with the tag on the device (plus the factory label
    if one exists).
- **No customer signature** and no acknowledgement step — checklist + photos
  only.
- **Saving is never blocked:** a draft can be saved with fewer than five
  photos. Marking report 1 **Final** requires all five slots filled, and the
  ticket shows an incomplete-photos badge until then.

## Report 2 — Technical

Internal. Drives the estimate. Optional for simple jobs.

- Header: ticket number, shop tag and device, so the bench matches paper to
  hardware at a glance.
- Complaint (carried from report 1).
- Tests performed and results.
- Findings: multiple entries, each with area, symptom, cause, severity and
  proposed fix.
- Diagnosis summary.
- Parts required, linked to the Parts table: quantity, cost/price, in stock or
  ETA.
- Labour estimate and total; what happens if declined.
- Risks ("board-level repair may be needed", "data loss possible").
- **Customer contact log:** method, timestamp, outcome
  (`contacted / approved / declined / no answer`). Quick buttons rather than a
  form.

### Simple jobs

A "quick job" toggle collapses report 2 to a short note generated from the
complaint and the service performed. A battery swap does not need a full
diagnosis document.

## Report 3 — Client report

The customer-facing deliverable. **Auto-filled** from reports 1 and 2, with an
editable plain-language summary; staff never retype the job. It prints as **two
pages**: the job summary, then the warranty page.

### Page 1 — Job summary

- What was found, in plain language.
- What was done: services and parts replaced (no cost or margin).
- Before/after photos flagged client-visible.
- Final price, deposits, balance due.
- Collection info: ready date, shop hours, ticket number and **shop tag**.
- Outcome: repaired / unrepairable / declined / no fault found.

### Page 2 — Warranty info

The page the customer keeps after the repair is forgotten, so it repeats the
job rather than assuming page 1 is still around.

- **Cover block** — what is warranted, and until when:
  - length in days (default 90, set in Settings)
  - start date = completion/pickup, not the day the report was drafted
  - expiry date printed as a plain date, not just "90 days"
  - the shop tag and ticket number, so the page stands alone.
- **What we found and did** — the diagnostic information from report 2,
  projected: the findings that were repaired, each rewritten in customer
  language (symptom → cause → fix), with no severity scores, internal notes,
  supplier names, cost or margin.
- **Photos** — the client-visible set: intake before shots paired with
  completion after shots, captioned. Photos marked internal never reach this
  page, and the pairing is by slot (left side before → left side after).
- **What is covered** — the services performed and parts fitted, taken from the
  ticket's line items.
- **What is not covered** — editable terms, seeded with defaults: accidental or
  liquid damage, tampering or third-party repairs, normal wear, software and
  account problems, data loss.
- **How to claim** — bring the device with this page; the shop tag identifies
  it. Shop contact details from Settings.
- **Void conditions** — the shop tag/serial label must still be on the device;
  a removed or replaced tag voids cover.

The warranty block is stored on the report (`warranty_days`,
`warranty_start_at`, `warranty_terms`), so a sent report keeps the terms it was
issued with. Changing the default in Settings never rewrites history.

Excluded from every page: supplier names, cost/margin, internal notes, staff
remarks, other customers.

## Identity on every report

All three reports carry the same two identifiers in the header, so any printed
page leads back to exactly one unit:

| | Printed as |
| --- | --- |
| Ticket number | `PF-000123` |
| Serial (factory) | `XKW1000123` |
| Serial (shop-applied) | `PFS-482913057` |
| Shop tag | `G-482913057` |

- The shop tag is the one stuck on the device, outside and inside, so it is the
  fastest way to match paper to hardware — and it still works when the factory
  serial is gone.
- When a factory serial exists it is printed next to the tag. When the sticker
  is missing, the report prints the shop-applied `PFS-` serial the intake form
  generated — never a blank that looks like an oversight.
- The shop-applied serial is written on the device's intake label and cannot be
  guessed from the ticket number, so it is safe to quote to a customer.
- The tag is **stored on the report revision**, not looked up live, so a sent
  report keeps the tag it was issued with even if the sticker is later replaced.
- The client report repeats the tag beside the collection details, so the
  customer can match it against the sticker at pickup.

## Rules

| | Report 1 | Report 2 | Report 3 |
| --- | --- | --- | --- |
| Audience | Internal + goods receipt | Internal | Customer |
| Created | Intake | Diagnosis | Completion |
| Status | Draft → Final | Draft → Final | Draft → Sent |
| Suggested ticket state | Received | Awaiting approval | Ready |

- **Immutable once sent.** Marking report 3 as Sent/Printed freezes a snapshot;
  later edits create revision 2 with a timestamp, so a customer's copy cannot
  change silently.
- **Soft gates.** Missing information shows a badge on the ticket ("no photos",
  "estimate not approved"); it never blocks a status change.
- **Author recorded, not enforced.** One field, defaulted to the shop name.

## Data model (planned)

- `ticket_reports` — ticket, kind (`intake` / `technical` / `client`), status,
  author, revision, created/updated/finalized timestamps, and the `shopTag`
  printed on that revision.
- `report_cosmetic_items` — report, area, condition, note.
- `report_findings` — report, area, symptom, cause, severity, fix.
- `report_contact_log` — report, timestamp, method, outcome, note.
- `ticket_photos` — ticket, slot (left/right/front/back/serial/extra), stage
  (intake / repair / completion), path, caption, `visible_to_client`.
- Client report stores only its overrides (summary, warranty days, warranty
  start, warranty terms, outcome); the rest is projected from the ticket.

## UI placement

Ticket detail shows a **Reports** card with three collapsible/expandable rows —
stage, status chip, last updated — plus Print/Share per report. The ticket
board shows a small marker when a report is still a draft.

Printing the client report produces both pages (job summary + warranty) as one
document, so the customer leaves with a single stapled sheet set.
