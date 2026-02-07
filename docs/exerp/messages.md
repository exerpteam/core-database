# messages
Operational table for messages records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 67 query files; common companions include [persons](persons.md), [sms](sms.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `deliverycode` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `delivery_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `deliverymethod` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `templatetype` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `templateid` | Foreign key field linking this record to `templates`. | `int4` | Yes | No | [templates](templates.md) via (`templateid` -> `id`) | - | `42` |
| `senderid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sendercenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sender_ext_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `senttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `earliest_delivery_time` | Epoch timestamp for earliest delivery. | `int8` | Yes | No | - | - | `1738281600000` |
| `receivedtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `expiretime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `subject` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `message_type_id` | Identifier of the related message type record. | `int4` | Yes | No | - | - | `1001` |
| `delivered_by_center` | Center part of the reference to related delivered by data. | `int4` | Yes | No | - | - | `101` |
| `delivered_by_id` | Identifier of the related delivered by record. | `int4` | Yes | No | - | - | `1001` |
| `invoice_line_center` | Center part of the reference to related invoice line data. | `int4` | Yes | No | - | - | `101` |
| `invoice_line_id` | Identifier of the related invoice line record. | `int4` | Yes | No | - | - | `1001` |
| `invoice_line_subid` | Sub-identifier for related invoice line detail rows. | `int4` | Yes | No | - | - | `1` |
| `use_work_address` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `REFERENCE` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `receiver_address_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `sender_address_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `payload` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `payload_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `messagecategory` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `s3bucket` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `s3key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [persons](persons.md) (40 query files), [sms](sms.md) (34 query files), [centers](centers.md) (31 query files), [person_ext_attrs](person_ext_attrs.md) (26 query files), [account_receivables](account_receivables.md) (20 query files), [subscriptions](subscriptions.md) (19 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [templates](templates.md); incoming FK from [message_attachments](message_attachments.md), [messages_of_todos](messages_of_todos.md), [sms](sms.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
