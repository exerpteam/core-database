# messages
Operational table for messages records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 67 query files; common companions include [persons](persons.md), [sms](sms.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `deliverycode` | Business attribute `deliverycode` used by messages workflows and reporting. | `int4` | No | No | - | - |
| `delivery_ref` | Business attribute `delivery_ref` used by messages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `deliverymethod` | Business attribute `deliverymethod` used by messages workflows and reporting. | `int4` | No | No | - | - |
| `templatetype` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `templateid` | Identifier of the related templates record used by this row. | `int4` | Yes | No | [templates](templates.md) via (`templateid` -> `id`) | - |
| `senderid` | Identifier component of the composite reference to the related sender record. | `int4` | Yes | No | - | - |
| `sendercenter` | Center component of the composite reference to the related sender record. | `int4` | Yes | No | - | - |
| `sender_ext_ref` | Business attribute `sender_ext_ref` used by messages workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `senttime` | Operational field `senttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `earliest_delivery_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `receivedtime` | Business attribute `receivedtime` used by messages workflows and reporting. | `int8` | Yes | No | - | - |
| `expiretime` | Business attribute `expiretime` used by messages workflows and reporting. | `int8` | Yes | No | - | - |
| `subject` | Operational field `subject` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `message_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `delivered_by_center` | Center component of the composite reference to the related delivered by record. | `int4` | Yes | No | - | - |
| `delivered_by_id` | Identifier component of the composite reference to the related delivered by record. | `int4` | Yes | No | - | - |
| `invoice_line_center` | Center component of the composite reference to the related invoice line record. | `int4` | Yes | No | - | - |
| `invoice_line_id` | Identifier component of the composite reference to the related invoice line record. | `int4` | Yes | No | - | - |
| `invoice_line_subid` | Business attribute `invoice_line_subid` used by messages workflows and reporting. | `int4` | Yes | No | - | - |
| `use_work_address` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `REFERENCE` | Operational field `REFERENCE` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `receiver_address_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `sender_address_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `payload` | Business attribute `payload` used by messages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `payload_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `messagecategory` | Business attribute `messagecategory` used by messages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket` | Business attribute `s3bucket` used by messages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key` | Business attribute `s3key` used by messages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (40 query files), [sms](sms.md) (34 query files), [centers](centers.md) (31 query files), [person_ext_attrs](person_ext_attrs.md) (26 query files), [account_receivables](account_receivables.md) (20 query files), [subscriptions](subscriptions.md) (19 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [templates](templates.md); incoming FK from [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [sms](sms.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
