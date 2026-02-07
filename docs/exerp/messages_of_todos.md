# messages_of_todos
Operational table for messages of todos records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [todos](todos.md) via (`center`, `id` -> `center`, `id`) | - |
| `message_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |

# Relations
- FK-linked tables: outgoing FK to [messages](messages.md), [todos](todos.md).
- Second-level FK neighborhood includes: [message_attachments](message_attachments.md), [persons](persons.md), [sms](sms.md), [templates](templates.md), [todo_groups](todo_groups.md), [todocomments](todocomments.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
