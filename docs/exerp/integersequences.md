# integersequences
Operational table for integersequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | Yes | - | - |
| `nextseq` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `allocincrement` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
