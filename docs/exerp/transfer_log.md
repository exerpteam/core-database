# transfer_log
Stores historical/log records for transfer events and changes. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `entity_id` | Identifier of the related entity record. | `int4` | No | No | - | - | `1001` |
| `entry_start_time` | Epoch timestamp for entry start. | `int8` | No | No | - | - | `1738281600000` |
| `entry_end_time` | Epoch timestamp for entry end. | `int8` | Yes | No | - | - | `1738281600000` |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | `101` |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
