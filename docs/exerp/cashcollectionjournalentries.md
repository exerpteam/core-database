# cashcollectionjournalentries
Financial/transactional table for cashcollectionjournalentries records. It is typically used where rows are center-scoped; it appears in approximately 9 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `creationtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `step` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `journalentry_id` | Foreign key field linking this record to `journalentries`. | `int4` | Yes | No | [journalentries](journalentries.md) via (`journalentry_id` -> `id`) | - | `1001` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (9 query files), [persons](persons.md) (9 query files), [centers](centers.md) (8 query files), [account_receivables](account_receivables.md) (7 query files), [account_trans](account_trans.md) (2 query files), [ar_trans](ar_trans.md) (2 query files).
- FK-linked tables: outgoing FK to [cashcollectioncases](cashcollectioncases.md), [employees](employees.md), [journalentries](journalentries.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollection_requests](cashcollection_requests.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
