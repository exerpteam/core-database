# todocomments
Operational table for todocomments records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 5 query files; common companions include [persons](persons.md), [todos](todos.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | - | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | - | - |
| `comment_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `ACTION` | Operational field `ACTION` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [todos](todos.md) (5 query files), [todo_groups](todo_groups.md) (3 query files), [centers](centers.md) (2 query files), [progress](progress.md) (2 query files), [participations](participations.md) (2 query files).
- FK-linked tables: outgoing FK to [todos](todos.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [todo_groups](todo_groups.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
