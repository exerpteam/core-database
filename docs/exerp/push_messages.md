# push_messages
Operational table for push messages records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `receiver_center` | Center component of the composite reference to the related receiver record. | `int4` | No | No | - | - |
| `receiver_id` | Identifier component of the composite reference to the related receiver record. | `int4` | No | No | - | - |
| `template_id` | Identifier for the related template entity used by this record. | `int4` | Yes | No | - | [templates](templates.md) via (`template_id` -> `id`) |
| `template_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `sent_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `push_target_id` | Identifier for the related push target entity used by this record. | `int4` | Yes | No | - | - |
| `subject` | Operational field `subject` used in query filtering and reporting transformations. | `VARCHAR(500)` | Yes | No | - | - |
| `response_code` | Business attribute `response_code` used by push messages workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `error_message` | Business attribute `error_message` used by push messages workflows and reporting. | `VARCHAR(500)` | Yes | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(200)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `s3bucket` | Business attribute `s3bucket` used by push messages workflows and reporting. | `VARCHAR(64)` | Yes | No | - | - |
| `s3key` | Business attribute `s3key` used by push messages workflows and reporting. | `VARCHAR(1024)` | Yes | No | - | - |

# Relations
