# todos
Operational table for todos records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 6 query files; common companions include [persons](persons.md), [todocomments](todocomments.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `todo_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `assignedtocenter` | Center component of the composite reference to the related assignedto record. | `int4` | No | No | [persons](persons.md) via (`assignedtocenter`, `assignedtoid` -> `center`, `id`) | - |
| `assignedtoid` | Identifier component of the composite reference to the related assignedto record. | `int4` | No | No | [persons](persons.md) via (`assignedtocenter`, `assignedtoid` -> `center`, `id`) | - |
| `creatorcenter` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | [persons](persons.md) via (`creatorcenter`, `creatorid` -> `center`, `id`) | - |
| `creatorid` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | [persons](persons.md) via (`creatorcenter`, `creatorid` -> `center`, `id`) | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `deadline` | Business attribute `deadline` used by todos workflows and reporting. | `int8` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | No | No | - | - |
| `subject` | Operational field `subject` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `personcenter` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `personid` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `todo_group_id` | Identifier of the related todo groups record used by this row. | `int4` | Yes | No | [todo_groups](todo_groups.md) via (`todo_group_id` -> `id`) | - |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [todocomments](todocomments.md) (5 query files), [todo_groups](todo_groups.md) (3 query files), [centers](centers.md) (2 query files), [progress](progress.md) (2 query files), [participations](participations.md) (2 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [todo_groups](todo_groups.md); incoming FK from [messages_of_todos](messages_of_todos.md), [todocomments](todocomments.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
