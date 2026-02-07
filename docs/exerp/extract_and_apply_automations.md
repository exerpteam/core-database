# extract_and_apply_automations
Operational table for extract and apply automations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(60)` | No | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `extract_id` | Identifier of the related extract record. | `int4` | No | No | - | [EXTRACT](EXTRACT.md) via (`extract_id` -> `id`) | `1001` |
| `apply_step_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `apply_step_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
