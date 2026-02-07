# card_clip_usages
Operational table for card clip usages records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 89 query files; common companions include [clipcards](clipcards.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `clips` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `REF` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `card_center` | Foreign key field linking this record to `clipcards`. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `card_id` | Foreign key field linking this record to `clipcards`. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `card_subid` | Foreign key field linking this record to `clipcards`. | `int4` | Yes | No | [clipcards](clipcards.md) via (`card_center`, `card_id`, `card_subid` -> `center`, `id`, `subid`) | - |
| `clipcard_usage_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cancellation_timestamp` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `activation_timestamp` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `creditline_center` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |
| `creditline_id` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |
| `creditline_subid` | Foreign key field linking this record to `credit_note_lines_mt`. | `int4` | Yes | No | [credit_note_lines_mt](credit_note_lines_mt.md) via (`creditline_center`, `creditline_id`, `creditline_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [clipcards](clipcards.md) (83 query files), [products](products.md) (70 query files), [centers](centers.md) (62 query files), [persons](persons.md) (59 query files), [invoices](invoices.md) (44 query files), [invoice_lines_mt](invoice_lines_mt.md) (43 query files).
- FK-linked tables: outgoing FK to [clipcards](clipcards.md), [credit_note_lines_mt](credit_note_lines_mt.md), [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
