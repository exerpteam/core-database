# client_performance_statistics
Operational table for client performance statistics records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `client_id` | Identifier of the related client record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) | `1001` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `statistic_date` | Date for statistic. | `DATE` | No | No | - | - | `2025-01-31` |
| `statistic_hour` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `statistic_minute` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `calls_below_1s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `calls_between_1s_and_3s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `calls_between_3s_and_10s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `calls_above_10s` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `number_of_errors` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `totaltime_calls_below_1s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `totaltime_calls_from_1_to_3s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `totaltime_calls_from_3_to_10s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `total_time_calls_above_10s` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
