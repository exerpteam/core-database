# training_program_exercises
Operational table for training program exercises records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trainingprogram_center` | Center component of the composite reference to the related trainingprogram record. | `int4` | No | No | [training_programs](training_programs.md) via (`trainingprogram_center`, `trainingprogram_id` -> `center`, `id`) | - |
| `trainingprogram_id` | Identifier component of the composite reference to the related trainingprogram record. | `int4` | No | No | [training_programs](training_programs.md) via (`trainingprogram_center`, `trainingprogram_id` -> `center`, `id`) | - |
| `exercisetype_center` | Center component of the composite reference to the related exercisetype record. | `int4` | No | No | [exercise_types](exercise_types.md) via (`exercisetype_center`, `exercisetype_id` -> `center`, `id`) | - |
| `exercisetype_id` | Identifier component of the composite reference to the related exercisetype record. | `int4` | No | No | [exercise_types](exercise_types.md) via (`exercisetype_center`, `exercisetype_id` -> `center`, `id`) | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `VARCHAR(240)` | No | No | - | - |
| `prioroty` | Business attribute `prioroty` used by training program exercises workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [exercise_types](exercise_types.md), [training_programs](training_programs.md).
- Second-level FK neighborhood includes: [employees](employees.md), [persons](persons.md).
