# integersequences
Operational table for integersequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `name` | Primary key identifier for this record. | `VARCHAR(64)` | No | Yes | - | - |
| `nextseq` | Business attribute `nextseq` used by integersequences workflows and reporting. | `int4` | No | No | - | - |
| `allocincrement` | Business attribute `allocincrement` used by integersequences workflows and reporting. | `int4` | No | No | - | - |

# Relations
