# message_attachments
Operational table for message attachments records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `message_center` | Center component of the composite reference to the related message record. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_id` | Identifier component of the composite reference to the related message record. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `message_subid` | Identifier of the related messages record used by this row. | `int4` | No | No | [messages](messages.md) via (`message_center`, `message_id`, `message_subid` -> `center`, `id`, `subid`) | - |
| `attachment_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `attachment_mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `attachment_filename` | Business attribute `attachment_filename` used by message attachments workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket` | Business attribute `s3bucket` used by message attachments workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key` | Business attribute `s3key` used by message attachments workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [messages](messages.md).
- Second-level FK neighborhood includes: [messages_of_todos](messages_of_todos.md), [persons](persons.md), [sms](sms.md), [templates](templates.md).
