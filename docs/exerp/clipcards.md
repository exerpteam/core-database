# clipcards
Operational table for clipcards records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 463 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [clipcardtypes](clipcardtypes.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [clipcardtypes](clipcardtypes.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `clips_left` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `clips_initial` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `finished` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `cancelled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `refmain_center` | Center component of the composite reference to the related refmain record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`refmain_center`, `refmain_id` -> `center`, `id`) | - |
| `refmain_id` | Identifier component of the composite reference to the related refmain record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`refmain_center`, `refmain_id` -> `center`, `id`) | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `valid_until` | Operational field `valid_until` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `cancellation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `blocking_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `overdue_since` | Business attribute `overdue_since` used by clipcards workflows and reporting. | `int8` | Yes | No | - | - |
| `assigned_staff_group` | Reference component identifying the staff member assigned to handle the record. | `int4` | Yes | No | - | - |
| `assigned_staff_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `assigned_staff_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cc_comment` | Business attribute `cc_comment` used by clipcards workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `creditline_center` | Center component of the composite reference to the related creditline record. | `int4` | Yes | No | - | - |
| `creditline_id` | Identifier component of the composite reference to the related creditline record. | `int4` | Yes | No | - | - |
| `creditline_subid` | Business attribute `creditline_subid` used by clipcards workflows and reporting. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_center` | Center component of the composite reference to the related transfer from clipcard record. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_id` | Identifier component of the composite reference to the related transfer from clipcard record. | `int4` | Yes | No | - | - |
| `transfer_from_clipcard_subid` | Business attribute `transfer_from_clipcard_subid` used by clipcards workflows and reporting. | `int4` | Yes | No | - | - |
| `recurring_participation_key` | Business attribute `recurring_participation_key` used by clipcards workflows and reporting. | `int4` | Yes | No | - | - |
| `booking_program_id` | Identifier for the related booking program entity used by this record. | `int4` | Yes | No | - | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) |
| `booking_program_activity_id` | Identifier for the related booking program activity entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (387 query files), [products](products.md) (376 query files), [centers](centers.md) (343 query files), [invoices](invoices.md) (179 query files), [subscriptions](subscriptions.md) (173 query files), [person_ext_attrs](person_ext_attrs.md) (148 query files).
- FK-linked tables: outgoing FK to [clipcardtypes](clipcardtypes.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [subscriptions](subscriptions.md); incoming FK from [card_clip_usages](card_clip_usages.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [bundle_campaign_usages](bundle_campaign_usages.md), [campaign_codes](campaign_codes.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
