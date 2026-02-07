# integersequences
Operational table for integersequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | Yes | - | - | `Example Name` |
| `nextseq` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `allocincrement` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
