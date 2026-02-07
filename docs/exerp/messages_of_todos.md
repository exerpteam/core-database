# messages_of_todos
Operational table for messages of todos records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `message_center` | Foreign key field linking this record to `messages`. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_id` | Foreign key field linking this record to `messages`. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_subid` | Foreign key field linking this record to `messages`. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [messages](messages.md), [todos](todos.md).
- Second-level FK neighborhood includes: [message_attachments](message_attachments.md), [persons](persons.md), [sms](sms.md), [templates](templates.md), [todo_groups](todo_groups.md), [todocomments](todocomments.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
