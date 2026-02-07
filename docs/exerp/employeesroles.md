# employeesroles
People-related master or relationship table for employeesroles data. It is typically used where rows are center-scoped; it appears in approximately 108 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [employees](employees.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [employees](employees.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `roleid` | Foreign key field linking this record to `roles`. | `int4` | No | No | [roles](roles.md) via (`roleid` -> `id`) | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |

# Relations
- Commonly used with: [employees](employees.md) (106 query files), [persons](persons.md) (104 query files), [roles](roles.md) (100 query files), [centers](centers.md) (59 query files), [person_ext_attrs](person_ext_attrs.md) (57 query files), [areas](areas.md) (22 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [roles](roles.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
