# sms
Operational table for sms records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 90 query files; common companions include [persons](persons.md), [person_ext_attrs](person_ext_attrs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `reference_id` | Identifier of the related reference record. | `int4` | Yes | No | - | - | `1001` |
| `message_center` | Foreign key field linking this record to `messages`. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - | `101` |
| `message_id` | Foreign key field linking this record to `messages`. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - | `1001` |
| `message_sub_id` | Foreign key field linking this record to `messages`. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - | `1001` |
| `ack_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `ack_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |

# Relations
- Commonly used with: [persons](persons.md) (72 query files), [person_ext_attrs](person_ext_attrs.md) (69 query files), [centers](centers.md) (64 query files), [subscriptions](subscriptions.md) (41 query files), [products](products.md) (35 query files), [messages](messages.md) (34 query files).
- FK-linked tables: outgoing FK to [messages](messages.md); incoming FK from [sms_splits](sms_splits.md).
- Second-level FK neighborhood includes: [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [persons](persons.md), [templates](templates.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
