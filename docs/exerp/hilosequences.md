# hilosequences
Operational table for hilosequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `sequencename` | Primary key identifier for this record. | `VARCHAR(50)` | No | Yes | - | - |
| `highvalues` | Business attribute `highvalues` used by hilosequences workflows and reporting. | `int4` | No | No | - | - |

# Relations
