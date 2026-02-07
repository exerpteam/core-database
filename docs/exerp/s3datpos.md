# s3datpos
Operational table for s3datpos records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |
| `linenum` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `transdate` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `debitaccount` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `creditaccount` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `txt` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - |
| `taxcode` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |

# Relations
