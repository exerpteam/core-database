# federatedintegersequences
Operational table for federatedintegersequences records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(32)` | No | Yes | - | - |
| `allocincrement` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `nextseq` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
