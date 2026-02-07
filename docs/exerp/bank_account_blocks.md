# bank_account_blocks
Financial/transactional table for bank account blocks records.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `clearing_house_id` | Identifier of the related clearing house record. | `int4` | No | No | - | - | `1001` |
| `creditor_id` | Identifier of the related creditor record. | `text(2147483647)` | No | No | - | - | `1001` |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `created_by_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - | `101` |
| `created_by_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - | `1001` |
| `reason` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `bank_account_holder` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `bank_regno` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `bank_branch_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `bank_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `bank_accno` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `bank_control_digits` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `iban` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `bic` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `deleted_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `deleted_by_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - | `101` |
| `deleted_by_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - | `1001` |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md).
