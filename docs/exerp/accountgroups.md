# accountgroups
Financial/transactional table for accountgroups records. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
