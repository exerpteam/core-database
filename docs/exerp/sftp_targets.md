# sftp_targets
Operational table for sftp targets records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Example Name` |
| `host` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Sample value` |
| `port` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `username` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Example Name` |
| `password` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Sample value` |
| `private_key` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | Yes | No | - | - | `Sample value` |
| `public_key` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | Yes | No | - | - | `Sample value` |
| `status` | Lifecycle status code for the record. | `VARCHAR(20)` | No | No | - | - | `1` |

# Relations
- FK-linked tables: incoming FK from [file_import_configs](file_import_configs.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
