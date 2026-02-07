# training_program_exercises
Operational table for training program exercises records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trainingprogram_center` | Foreign key field linking this record to `training_programs`. | `int4` | No | No | [training_programs](training_programs.md) via (`trainingprogram_center`, `trainingprogram_id` -> `center`, `id`) | - |
| `trainingprogram_id` | Foreign key field linking this record to `training_programs`. | `int4` | No | No | [training_programs](training_programs.md) via (`trainingprogram_center`, `trainingprogram_id` -> `center`, `id`) | - |
| `exercisetype_center` | Foreign key field linking this record to `exercise_types`. | `int4` | No | No | [exercise_types](exercise_types.md) via (`exercisetype_center`, `exercisetype_id` -> `center`, `id`) | - |
| `exercisetype_id` | Foreign key field linking this record to `exercise_types`. | `int4` | No | No | [exercise_types](exercise_types.md) via (`exercisetype_center`, `exercisetype_id` -> `center`, `id`) | - |
| `coment` | Text field containing descriptive or reference information. | `VARCHAR(240)` | No | No | - | - |
| `prioroty` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [exercise_types](exercise_types.md), [training_programs](training_programs.md).
- Second-level FK neighborhood includes: [employees](employees.md), [persons](persons.md).
