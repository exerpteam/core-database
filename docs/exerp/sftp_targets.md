# sftp_targets
Operational table for sftp targets records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `host` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - |
| `port` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `username` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `password` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `private_key` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | Yes | No | - | - |
| `public_key` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `VARCHAR(20)` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [file_import_configs](file_import_configs.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
