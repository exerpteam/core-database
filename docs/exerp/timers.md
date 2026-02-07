# timers
Operational table for timers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `timerid` | Primary key component used to uniquely identify this record. | `VARCHAR(80)` | No | Yes | - | - |
| `targetid` | Primary key component used to uniquely identify this record. | `VARCHAR(250)` | No | Yes | - | - |
| `initialdate` | Business attribute `initialdate` used by timers workflows and reporting. | `timestamptz` | No | No | - | - |
| `nextdate` | Business attribute `nextdate` used by timers workflows and reporting. | `timestamptz` | Yes | No | - | - |
| `timerinterval` | Business attribute `timerinterval` used by timers workflows and reporting. | `int8` | Yes | No | - | - |
| `instancepk` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `info` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
