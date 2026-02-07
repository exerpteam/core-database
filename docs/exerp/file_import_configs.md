# file_import_configs
Configuration table for file import configs behavior and defaults. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `service` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `agency` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `target_id` | Foreign key field linking this record to `sftp_targets`. | `int4` | No | No | [sftp_targets](sftp_targets.md) via (`target_id` -> `id`) | - |
| `source` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - |
| `filename_pattern` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `VARCHAR(20)` | No | No | - | - |
| `quick_file_process` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [sftp_targets](sftp_targets.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
