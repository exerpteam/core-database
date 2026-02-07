# todo_groups
Operational table for todo groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files; common companions include [persons](persons.md), [todocomments](todocomments.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `comments` | Business attribute `comments` used by todo groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (3 query files), [todocomments](todocomments.md) (3 query files), [todos](todos.md) (3 query files), [participations](participations.md) (2 query files).
- FK-linked tables: incoming FK from [todos](todos.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [todocomments](todocomments.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
