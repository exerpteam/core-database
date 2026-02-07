# exercise_types
Operational table for exercise types records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `image` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `descr` | Business attribute `descr` used by exercise types workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `available` | Operational field `available` used in query filtering and reporting transformations. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [training_program_exercises](training_program_exercises.md).
- Second-level FK neighborhood includes: [training_programs](training_programs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
