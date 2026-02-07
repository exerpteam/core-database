# s3datpos
Operational table for s3datpos records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Business attribute `journalkey` used by s3datpos workflows and reporting. | `VARCHAR(30)` | No | No | - | - |
| `linenum` | Business attribute `linenum` used by s3datpos workflows and reporting. | `int4` | No | No | - | - |
| `transdate` | Business attribute `transdate` used by s3datpos workflows and reporting. | `VARCHAR(10)` | Yes | No | - | - |
| `debitaccount` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(10)` | Yes | No | - | - |
| `creditaccount` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(10)` | Yes | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `txt` | Business attribute `txt` used by s3datpos workflows and reporting. | `VARCHAR(30)` | Yes | No | - | - |
| `taxcode` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(10)` | Yes | No | - | - |

# Relations
