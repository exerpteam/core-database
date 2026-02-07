# s3datpos
Operational table for s3datpos records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `journalkey` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `linenum` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `transdate` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `debitaccount` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `creditaccount` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `txt` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - | `Sample value` |
| `taxcode` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |

# Relations
