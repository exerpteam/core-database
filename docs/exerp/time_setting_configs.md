# time_setting_configs
Configuration table for time setting configs behavior and defaults.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `VALUE` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `ROUND` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
