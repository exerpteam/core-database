# message_attachments
Operational table for message attachments records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `message_center` | Foreign key field linking this record to `messages`. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - | `101` |
| `message_id` | Foreign key field linking this record to `messages`. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `message_subid` | Foreign key field linking this record to `messages`. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - | `1` |
| `attachment_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `attachment_mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `attachment_filename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `s3bucket` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `s3key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- FK-linked tables: outgoing FK to [messages](messages.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [sms](sms.md), [templates](templates.md).
