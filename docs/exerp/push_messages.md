# push_messages
Operational table for push messages records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `receiver_center` | Center part of the reference to related receiver data. | `int4` | No | No | - | - |
| `receiver_id` | Identifier of the related receiver record. | `int4` | No | No | - | - |
| `template_id` | Identifier of the related template record. | `int4` | Yes | No | - | [templates](templates.md) via (`template_id` -> `id`) |
| `template_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sent_time` | Epoch timestamp for sent. | `int8` | No | No | - | - |
| `push_target_id` | Identifier of the related push target record. | `int4` | Yes | No | - | - |
| `subject` | Text field containing descriptive or reference information. | `VARCHAR(500)` | Yes | No | - | - |
| `response_code` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `error_message` | Text field containing descriptive or reference information. | `VARCHAR(500)` | Yes | No | - | - |
| `mimetype` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `s3bucket` | Text field containing descriptive or reference information. | `VARCHAR(64)` | Yes | No | - | - |
| `s3key` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | Yes | No | - | - |

# Relations
