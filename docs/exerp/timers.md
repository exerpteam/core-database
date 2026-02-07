# timers
Operational table for timers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `timerid` | Text field containing descriptive or reference information. | `VARCHAR(80)` | No | Yes | - | - |
| `targetid` | Text field containing descriptive or reference information. | `VARCHAR(250)` | No | Yes | - | - |
| `initialdate` | Table field used by operational and reporting workloads. | `timestamptz` | No | No | - | - |
| `nextdate` | Table field used by operational and reporting workloads. | `timestamptz` | Yes | No | - | - |
| `timerinterval` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `instancepk` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `info` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
