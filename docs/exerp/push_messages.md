# push_messages
Operational table for push messages records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `receiver_center` | Center part of the reference to related receiver data. | `int4` | No | No | - | - | `101` |
| `receiver_id` | Identifier of the related receiver record. | `int4` | No | No | - | - | `1001` |
| `template_id` | Identifier of the related template record. | `int4` | Yes | No | - | [templates](templates.md) via (`template_id` -> `id`) | `1001` |
| `template_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sent_time` | Epoch timestamp for sent. | `int8` | No | No | - | - | `1738281600000` |
| `push_target_id` | Identifier of the related push target record. | `int4` | Yes | No | - | - | `1001` |
| `subject` | Text field containing descriptive or reference information. | `VARCHAR(500)` | Yes | No | - | - | `Sample value` |
| `response_code` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Sample value` |
| `error_message` | Text field containing descriptive or reference information. | `VARCHAR(500)` | Yes | No | - | - | `Sample value` |
| `mimetype` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `s3bucket` | Text field containing descriptive or reference information. | `VARCHAR(64)` | Yes | No | - | - | `Sample value` |
| `s3key` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | Yes | No | - | - | `Sample value` |

# Relations
