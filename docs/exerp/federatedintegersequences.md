# federatedintegersequences
Operational table for federatedintegersequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `name` | Primary key component used to uniquely identify this record. | `VARCHAR(32)` | No | Yes | - | - |
| `allocincrement` | Business attribute `allocincrement` used by federatedintegersequences workflows and reporting. | `int4` | No | No | - | - |
| `nextseq` | Business attribute `nextseq` used by federatedintegersequences workflows and reporting. | `int4` | No | No | - | - |

# Relations
