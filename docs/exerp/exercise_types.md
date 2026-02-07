# exercise_types
Operational table for exercise types records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `image` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `descr` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `available` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [training_program_exercises](training_program_exercises.md).
- Second-level FK neighborhood includes: [training_programs](training_programs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
