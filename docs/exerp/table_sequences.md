# table_sequences
Operational table for table sequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | Yes | - | - | `Example Name` |
| `VALUE` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
