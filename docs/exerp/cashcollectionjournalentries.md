# cashcollectionjournalentries
Financial/transactional table for cashcollectionjournalentries records. It is typically used where rows are center-scoped; it appears in approximately 9 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `creationtime` | Operational field `creationtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `step` | Operational field `step` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `journalentry_id` | Identifier of the related journalentries record used by this row. | `int4` | Yes | No | [journalentries](journalentries.md) via (`journalentry_id` -> `id`) | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (9 query files), [persons](persons.md) (9 query files), [centers](centers.md) (8 query files), [account_receivables](account_receivables.md) (7 query files), [account_trans](account_trans.md) (2 query files), [ar_trans](ar_trans.md) (2 query files).
- FK-linked tables: outgoing FK to [cashcollectioncases](cashcollectioncases.md), [employees](employees.md), [journalentries](journalentries.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollection_requests](cashcollection_requests.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
