# s3dathead
Operational table for s3dathead records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `YEAR` | Text field containing descriptive or reference information. | `VARCHAR(4)` | Yes | No | - | - | `Sample value` |
| `MONTH` | Text field containing descriptive or reference information. | `VARCHAR(2)` | Yes | No | - | - | `Sample value` |
| `DAY` | Text field containing descriptive or reference information. | `VARCHAR(2)` | Yes | No | - | - | `Sample value` |
| `kindofdata` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `dateinserted` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `timeinserted` | Text field containing descriptive or reference information. | `VARCHAR(8)` | Yes | No | - | - | `Sample value` |
| `daterec` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `timerec` | Text field containing descriptive or reference information. | `VARCHAR(8)` | Yes | No | - | - | `Sample value` |
| `sora` | Text field containing descriptive or reference information. | `VARCHAR(1)` | Yes | No | - | - | `Sample value` |
| `costcenter` | Text field containing descriptive or reference information. | `VARCHAR(15)` | Yes | No | - | - | `Sample value` |
| `journaltxt` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - | `Sample value` |
| `journalnum` | Text field containing descriptive or reference information. | `VARCHAR(21)` | Yes | No | - | - | `Sample value` |
| `countpos` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
