# federatedintegersubsequences
Operational table for federatedintegersubsequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `name` | Primary key component used to uniquely identify this record. | `VARCHAR(32)` | No | Yes | - | - |
| `seq` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `subname` | Primary key component used to uniquely identify this record. | `VARCHAR(32)` | No | Yes | - | - |
| `allocincrement` | Business attribute `allocincrement` used by federatedintegersubsequences workflows and reporting. | `int4` | No | No | - | - |
| `nextsubseq` | Business attribute `nextsubseq` used by federatedintegersubsequences workflows and reporting. | `int4` | No | No | - | - |

# Relations
