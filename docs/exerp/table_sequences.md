# table_sequences
Operational table for table sequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `name` | Primary key identifier for this record. | `VARCHAR(64)` | No | Yes | - | - |
| `VALUE` | Operational field `VALUE` used in query filtering and reporting transformations. | `int4` | No | No | - | - |

# Relations
