# hilosequences
Operational table for hilosequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `sequencename` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | Yes | - | - |
| `highvalues` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
