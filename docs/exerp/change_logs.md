# change_logs
Stores historical/log records for changes events and changes. It is typically used where it appears in approximately 4 query files; common companions include [employeesroles](employeesroles.md), [extract](extract.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `int4` | No | No | - | - |
| `service_name` | Business attribute `service_name` used by change logs workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `source_primary` | Business attribute `source_primary` used by change logs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `source_secondary` | Business attribute `source_secondary` used by change logs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `text_value_before` | Business attribute `text_value_before` used by change logs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `text_value_after` | Business attribute `text_value_after` used by change logs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `blob_type_before` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `blob_type_after` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `blob_value_before` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `blob_value_after` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [employeesroles](employeesroles.md) (4 query files), [extract](extract.md) (4 query files), [roles](roles.md) (4 query files), [centers](centers.md) (3 query files), [employees](employees.md) (3 query files), [event_type_config](event_type_config.md) (3 query files).
