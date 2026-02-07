# card_clip_usages
Operational table for card clip usages records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 89 query files; common companions include [clipcards](clipcards.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `TIME` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `clips` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `card_center` | Center component of the composite reference to the related card record. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `card_id` | Identifier component of the composite reference to the related card record. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `card_subid` | Identifier of the related clipcards record used by this row. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `clipcard_usage_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `cancellation_timestamp` | Business attribute `cancellation_timestamp` used by card clip usages workflows and reporting. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `activation_timestamp` | Monetary value used in financial calculation, settlement, or reporting. | `int8` | Yes | No | - | - |
| `creditline_center` | Center component of the composite reference to the related creditline record. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |
| `creditline_id` | Identifier component of the composite reference to the related creditline record. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |
| `creditline_subid` | Identifier of the related credit note lines mt record used by this row. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [clipcards](clipcards.md) (83 query files), [products](products.md) (70 query files), [centers](centers.md) (62 query files), [persons](persons.md) (59 query files), [invoices](invoices.md) (44 query files), [invoice_lines_mt](invoice_lines_mt.md) (43 query files).
- FK-linked tables: outgoing FK to [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
