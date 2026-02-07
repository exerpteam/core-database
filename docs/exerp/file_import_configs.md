# file_import_configs
Configuration table for file import configs behavior and defaults. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Example Name` |
| `service` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Sample value` |
| `agency` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `target_id` | Foreign key field linking this record to `sftp_targets`. | `int4` | No | No | [sftp_targets](sftp_targets.md) via (`target_id` -> `id`) | - | `1001` |
| `source` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - | `Sample value` |
| `filename_pattern` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - | `Sample value` |
| `status` | Lifecycle status code for the record. | `VARCHAR(20)` | No | No | - | - | `1` |
| `quick_file_process` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- FK-linked tables: outgoing FK to [sftp_targets](sftp_targets.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
