# change_logs
Stores historical/log records for changes events and changes. It is typically used where it appears in approximately 4 query files; common companions include [employeesroles](employeesroles.md), [extract](extract.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `service_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - |
| `source_primary` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `source_secondary` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `text_value_before` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `text_value_after` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `blob_type_before` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `blob_type_after` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `blob_value_before` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `blob_value_after` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [employeesroles](employeesroles.md) (4 query files), [extract](extract.md) (4 query files), [roles](roles.md) (4 query files), [centers](centers.md) (3 query files), [employees](employees.md) (3 query files), [event_type_config](event_type_config.md) (3 query files).
