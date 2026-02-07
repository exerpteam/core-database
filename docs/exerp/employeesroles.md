# employeesroles
People-related master or relationship table for employeesroles data. It is typically used where rows are center-scoped; it appears in approximately 108 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [employees](employees.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [employees](employees.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `roleid` | Identifier of the related roles record used by this row. | `int4` | No | No | [roles](roles.md) via (`roleid` -> `id`) | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [employees](employees.md) (106 query files), [persons](persons.md) (104 query files), [roles](roles.md) (100 query files), [centers](centers.md) (59 query files), [person_ext_attrs](person_ext_attrs.md) (57 query files), [areas](areas.md) (22 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [roles](roles.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
