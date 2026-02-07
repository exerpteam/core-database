# timers
Operational table for timers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `timerid` | Text field containing descriptive or reference information. | `VARCHAR(80)` | No | Yes | - | - | `Sample value` |
| `targetid` | Text field containing descriptive or reference information. | `VARCHAR(250)` | No | Yes | - | - | `Sample value` |
| `initialdate` | Table field used by operational and reporting workloads. | `timestamptz` | No | No | - | - | `Sample` |
| `nextdate` | Table field used by operational and reporting workloads. | `timestamptz` | Yes | No | - | - | `N/A` |
| `timerinterval` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `instancepk` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
