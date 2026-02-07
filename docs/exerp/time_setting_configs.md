# time_setting_configs
Configuration table for time setting configs behavior and defaults.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `VALUE` | Operational field `VALUE` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `unit` | Operational field `unit` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `ROUND` | Operational field `ROUND` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |

# Relations
