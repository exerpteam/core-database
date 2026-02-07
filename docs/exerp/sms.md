# sms
Operational table for sms records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 90 query files; common companions include [persons](persons.md), [person_ext_attrs](person_ext_attrs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `reference_id` | Identifier for the related reference entity used by this record. | `int4` | Yes | No | - | - |
| `message_center` | Center component of the composite reference to the related message record. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - |
| `message_id` | Identifier component of the composite reference to the related message record. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - |
| `message_sub_id` | Identifier of the related messages record used by this row. | `int4` | Yes | No | [messages](messages.md) via (`message_center`, `message_id`, `message_sub_id` -> `center`, `id`, `subid`) | - |
| `ack_code` | Business attribute `ack_code` used by sms workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `ack_text` | Business attribute `ack_text` used by sms workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (72 query files), [person_ext_attrs](person_ext_attrs.md) (69 query files), [centers](centers.md) (64 query files), [subscriptions](subscriptions.md) (41 query files), [products](products.md) (35 query files), [messages](messages.md) (34 query files).
- FK-linked tables: outgoing FK to [messages](messages.md); incoming FK from [sms_splits](sms_splits.md).
- Second-level FK neighborhood includes: [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [persons](persons.md), [templates](templates.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
