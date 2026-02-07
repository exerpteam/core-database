# state_change_log
Stores historical/log records for state change events and changes. It is typically used where rows are center-scoped; it appears in approximately 634 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `KEY` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | No | No | - | - |
| `subid` | Sub-identifier used for child rows within a parent key. | `int4` | Yes | No | - | - |
| `entry_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `stateid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `sub_state` | Detailed sub-state code refining the main state. | `int4` | Yes | No | - | - |
| `entry_start_time` | Epoch timestamp for entry start. | `int8` | No | No | - | - |
| `entry_end_time` | Epoch timestamp for entry end. | `int8` | Yes | No | - | - |
| `book_start_time` | Epoch timestamp for book start. | `int8` | No | No | - | - |
| `book_end_time` | Epoch timestamp for book end. | `int8` | Yes | No | - | - |
| `had_report_role` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |

# Relations
- Commonly used with: [persons](persons.md) (508 query files), [subscriptions](subscriptions.md) (498 query files), [centers](centers.md) (425 query files), [products](products.md) (389 query files), [subscriptiontypes](subscriptiontypes.md) (382 query files), [relatives](relatives.md) (226 query files).
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
