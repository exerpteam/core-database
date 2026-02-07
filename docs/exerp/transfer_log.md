# transfer_log
Stores historical/log records for transfer events and changes. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `entity_id` | Identifier for the related entity entity used by this record. | `int4` | No | No | - | - |
| `entry_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `entry_end_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
