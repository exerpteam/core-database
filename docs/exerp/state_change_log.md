# state_change_log
Stores historical/log records for state change events and changes. It is typically used where rows are center-scoped; it appears in approximately 634 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `KEY` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Identifier for this record. | `int4` | No | No | - | - |
| `subid` | Operational field `subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `entry_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [state_change_log_entry_type](../master%20tables/state_change_log_entry_type.md) |
| `stateid` | State indicator used to control lifecycle transitions and filtering. | `int4` | No | No | - | [state_change_log_stateid](../master%20tables/state_change_log_stateid.md) |
| `sub_state` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AWAITING ACTIVATION, AWAITING_ACTIVATION, AwaitingActivation). | `int4` | Yes | No | - | [state_change_log_sub_state](../master%20tables/state_change_log_sub_state.md) |
| `entry_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `entry_end_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `book_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `book_end_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `had_report_role` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |

# Relations
- Commonly used with: [persons](persons.md) (508 query files), [subscriptions](subscriptions.md) (498 query files), [centers](centers.md) (425 query files), [products](products.md) (389 query files), [subscriptiontypes](subscriptiontypes.md) (382 query files), [relatives](relatives.md) (226 query files).
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
