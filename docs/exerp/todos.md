# todos
Operational table for todos records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 6 query files; common companions include [persons](persons.md), [todocomments](todocomments.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `todo_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `assignedtocenter` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`assignedtocenter`, `assignedtoid` -> `center`, `id`) | - | `42` |
| `assignedtoid` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`assignedtocenter`, `assignedtoid` -> `center`, `id`) | - | `42` |
| `creatorcenter` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creatorcenter`, `creatorid` -> `center`, `id`) | - | `42` |
| `creatorid` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creatorcenter`, `creatorid` -> `center`, `id`) | - | `42` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - | `1738281600000` |
| `deadline` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - | `1` |
| `subject` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `personcenter` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `personid` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `todo_group_id` | Foreign key field linking this record to `todo_groups`. | `int4` | Yes | No | [todo_groups](todo_groups.md) via (`todo_group_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [todocomments](todocomments.md) (5 query files), [todo_groups](todo_groups.md) (3 query files), [centers](centers.md) (2 query files), [progress](progress.md) (2 query files), [participations](participations.md) (2 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [todo_groups](todo_groups.md); incoming FK from [messages_of_todos](messages_of_todos.md), [todocomments](todocomments.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
