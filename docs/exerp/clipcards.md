# clipcards
Operational table for clipcards records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 463 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [clipcardtypes](clipcardtypes.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [clipcardtypes](clipcardtypes.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `clips_left` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `clips_initial` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `finished` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `cancelled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `invoiceline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `refmain_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`refmain_center`, `refmain_id` -> `center`, `id`) | - |
| `refmain_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`refmain_center`, `refmain_id` -> `center`, `id`) | - |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `valid_until` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `cancellation_time` | Epoch timestamp for cancellation. | `int8` | Yes | No | - | - |
| `blocking_time` | Epoch timestamp for blocking. | `int8` | Yes | No | - | - |
| `overdue_since` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `assigned_staff_group` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `assigned_staff_center` | Center part of the reference to related assigned staff data. | `int4` | Yes | No | - | - |
| `assigned_staff_id` | Identifier of the related assigned staff record. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `cc_comment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `creditline_center` | Center part of the reference to related creditline data. | `int4` | Yes | No | - | - |
| `creditline_id` | Identifier of the related creditline record. | `int4` | Yes | No | - | - |
| `creditline_subid` | Sub-identifier for related creditline detail rows. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_center` | Center part of the reference to related transfer from clipcard data. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_id` | Identifier of the related transfer from clipcard record. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_subid` | Sub-identifier for related transfer from clipcard detail rows. | `int4` | Yes | No | - | - |
| `recurring_participation_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `booking_program_id` | Identifier of the related booking program record. | `int4` | Yes | No | - | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) |
| `booking_program_activity_id` | Identifier of the related booking program activity record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (387 query files), [products](products.md) (376 query files), [centers](centers.md) (343 query files), [invoices](invoices.md) (179 query files), [subscriptions](subscriptions.md) (173 query files), [person_ext_attrs](person_ext_attrs.md) (148 query files).
- FK-linked tables: outgoing FK to [clipcardtypes](clipcardtypes.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [subscriptions](subscriptions.md); incoming FK from [card_clip_usages](card_clip_usages.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [campaign_codes](campaign_codes.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
