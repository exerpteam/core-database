# todocomments
Operational table for todocomments records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 5 query files; common companions include [persons](persons.md), [todos](todos.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `employeecenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `employeeid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `comment_time` | Epoch timestamp for comment. | `int8` | No | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `ACTION` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [todos](todos.md) (5 query files), [todo_groups](todo_groups.md) (3 query files), [centers](centers.md) (2 query files), [progress](progress.md) (2 query files), [participations](participations.md) (2 query files).
- FK-linked tables: outgoing FK to [todos](todos.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [todo_groups](todo_groups.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
