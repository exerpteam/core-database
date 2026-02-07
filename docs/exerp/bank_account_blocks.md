# bank_account_blocks
Financial/transactional table for bank account blocks records.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `clearing_house_id` | Identifier for the related clearing house entity used by this record. | `int4` | No | No | - | - |
| `creditor_id` | Identifier for the related creditor entity used by this record. | `text(2147483647)` | No | No | - | - |
| `created_at` | Business attribute `created_at` used by bank account blocks workflows and reporting. | `int8` | No | No | - | - |
| `created_by_center` | Center component of the composite reference to the related created by record. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `created_by_id` | Identifier component of the composite reference to the related created by record. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `bank_account_holder` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `bank_regno` | Operational field `bank_regno` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_branch_no` | Operational field `bank_branch_no` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_name` | Business attribute `bank_name` used by bank account blocks workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_accno` | Operational field `bank_accno` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_control_digits` | Business attribute `bank_control_digits` used by bank account blocks workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `iban` | Operational field `iban` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bic` | Operational field `bic` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `deleted_at` | Business attribute `deleted_at` used by bank account blocks workflows and reporting. | `int8` | Yes | No | - | - |
| `deleted_by_center` | Center component of the composite reference to the related deleted by record. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |
| `deleted_by_id` | Identifier component of the composite reference to the related deleted by record. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md).
