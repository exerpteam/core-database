# extract_and_apply_automations
Operational table for extract and apply automations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(60)` | No | No | - | - |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `extract_id` | Identifier of the related extract record. | `int4` | No | No | - | [EXTRACT](EXTRACT.md) via (`extract_id` -> `id`) |
| `apply_step_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `apply_step_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
