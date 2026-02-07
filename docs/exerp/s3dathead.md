# s3dathead
Operational table for s3dathead records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |
| `YEAR` | Text field containing descriptive or reference information. | `VARCHAR(4)` | Yes | No | - | - |
| `MONTH` | Text field containing descriptive or reference information. | `VARCHAR(2)` | Yes | No | - | - |
| `DAY` | Text field containing descriptive or reference information. | `VARCHAR(2)` | Yes | No | - | - |
| `kindofdata` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `dateinserted` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `timeinserted` | Text field containing descriptive or reference information. | `VARCHAR(8)` | Yes | No | - | - |
| `daterec` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `timerec` | Text field containing descriptive or reference information. | `VARCHAR(8)` | Yes | No | - | - |
| `sora` | Text field containing descriptive or reference information. | `VARCHAR(1)` | Yes | No | - | - |
| `costcenter` | Text field containing descriptive or reference information. | `VARCHAR(15)` | Yes | No | - | - |
| `journaltxt` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - |
| `journalnum` | Text field containing descriptive or reference information. | `VARCHAR(21)` | Yes | No | - | - |
| `countpos` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
