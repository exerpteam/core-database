# public_messages
Operational table for public messages records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `created_by_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - | `101` |
| `created_by_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`created_by_center`, `created_by_id` -> `center`, `id`) | - | `1001` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `subject` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `body` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `important` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `deleted_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `deleted_by_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - | `101` |
| `deleted_by_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`deleted_by_center`, `deleted_by_id` -> `center`, `id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md); incoming FK from [public_messages_person](public_messages_person.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
