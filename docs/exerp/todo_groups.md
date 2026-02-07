# todo_groups
Operational table for todo groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [persons](persons.md), [todocomments](todocomments.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `comments` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (3 query files), [todocomments](todocomments.md) (3 query files), [todos](todos.md) (3 query files), [participations](participations.md) (2 query files).
- FK-linked tables: incoming FK from [todos](todos.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [todocomments](todocomments.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
