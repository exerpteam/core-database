# client_performance_statistics
Operational table for client performance statistics records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `client_id` | Identifier of the related client record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `statistic_date` | Date for statistic. | `DATE` | No | No | - | - |
| `statistic_hour` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `statistic_minute` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `calls_below_1s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `calls_between_1s_and_3s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `calls_between_3s_and_10s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `calls_above_10s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `number_of_errors` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `totaltime_calls_below_1s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `totaltime_calls_from_1_to_3s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `totaltime_calls_from_3_to_10s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `total_time_calls_above_10s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
