# client_performance_statistics
Operational table for client performance statistics records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `client_id` | Identifier for the related client entity used by this record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `statistic_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `statistic_hour` | Business attribute `statistic_hour` used by client performance statistics workflows and reporting. | `int4` | No | No | - | - |
| `statistic_minute` | Business attribute `statistic_minute` used by client performance statistics workflows and reporting. | `int4` | No | No | - | - |
| `calls_below_1s` | Business attribute `calls_below_1s` used by client performance statistics workflows and reporting. | `int4` | Yes | No | - | - |
| `calls_between_1s_and_3s` | Business attribute `calls_between_1s_and_3s` used by client performance statistics workflows and reporting. | `int4` | Yes | No | - | - |
| `calls_between_3s_and_10s` | Business attribute `calls_between_3s_and_10s` used by client performance statistics workflows and reporting. | `int4` | Yes | No | - | - |
| `calls_above_10s` | Business attribute `calls_above_10s` used by client performance statistics workflows and reporting. | `int4` | Yes | No | - | - |
| `number_of_errors` | Business attribute `number_of_errors` used by client performance statistics workflows and reporting. | `int4` | Yes | No | - | - |
| `totaltime_calls_below_1s` | Business attribute `totaltime_calls_below_1s` used by client performance statistics workflows and reporting. | `int8` | Yes | No | - | - |
| `totaltime_calls_from_1_to_3s` | Business attribute `totaltime_calls_from_1_to_3s` used by client performance statistics workflows and reporting. | `int8` | Yes | No | - | - |
| `totaltime_calls_from_3_to_10s` | Business attribute `totaltime_calls_from_3_to_10s` used by client performance statistics workflows and reporting. | `int8` | Yes | No | - | - |
| `total_time_calls_above_10s` | Business attribute `total_time_calls_above_10s` used by client performance statistics workflows and reporting. | `int8` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
