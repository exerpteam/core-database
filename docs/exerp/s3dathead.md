# s3dathead
Operational table for s3dathead records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Business attribute `journalkey` used by s3dathead workflows and reporting. | `VARCHAR(30)` | No | No | - | - |
| `YEAR` | Operational field `YEAR` used in query filtering and reporting transformations. | `VARCHAR(4)` | Yes | No | - | - |
| `MONTH` | Operational field `MONTH` used in query filtering and reporting transformations. | `VARCHAR(2)` | Yes | No | - | - |
| `DAY` | Operational field `DAY` used in query filtering and reporting transformations. | `VARCHAR(2)` | Yes | No | - | - |
| `kindofdata` | Business attribute `kindofdata` used by s3dathead workflows and reporting. | `VARCHAR(10)` | Yes | No | - | - |
| `dateinserted` | Business attribute `dateinserted` used by s3dathead workflows and reporting. | `VARCHAR(10)` | Yes | No | - | - |
| `timeinserted` | Business attribute `timeinserted` used by s3dathead workflows and reporting. | `VARCHAR(8)` | Yes | No | - | - |
| `daterec` | Business attribute `daterec` used by s3dathead workflows and reporting. | `VARCHAR(10)` | Yes | No | - | - |
| `timerec` | Business attribute `timerec` used by s3dathead workflows and reporting. | `VARCHAR(8)` | Yes | No | - | - |
| `sora` | Business attribute `sora` used by s3dathead workflows and reporting. | `VARCHAR(1)` | Yes | No | - | - |
| `costcenter` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(15)` | Yes | No | - | - |
| `journaltxt` | Business attribute `journaltxt` used by s3dathead workflows and reporting. | `VARCHAR(30)` | Yes | No | - | - |
| `journalnum` | Business attribute `journalnum` used by s3dathead workflows and reporting. | `VARCHAR(21)` | Yes | No | - | - |
| `countpos` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |

# Relations
