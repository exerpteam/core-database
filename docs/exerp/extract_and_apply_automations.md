# extract_and_apply_automations
Operational table for extract and apply automations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(60)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `VARCHAR(200)` | Yes | No | - | - |
| `extract_id` | Identifier for the related extract entity used by this record. | `int4` | No | No | - | [extract](extract.md) via (`extract_id` -> `id`) |
| `apply_step_key` | Business attribute `apply_step_key` used by extract and apply automations workflows and reporting. | `int4` | No | No | - | - |
| `apply_step_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |

# Relations
