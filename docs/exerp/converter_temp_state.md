# converter_temp_state
Intermediate/cache table used to accelerate converter temp state processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entitytype` | Text field containing descriptive or reference information. | `VARCHAR(40)` | No | No | - | - |
| `oldid` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | No | - | - |
| `newcenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `newid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `newsubid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `datatype` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - |
| `lastupdated` | Table field used by operational and reporting workloads. | `TIMESTAMP` | No | No | - | - |

# Relations
