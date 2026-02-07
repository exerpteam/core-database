# template_signatures
Intermediate/cache table used to accelerate template signatures processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `template_id` | Identifier for the related template entity used by this record. | `int4` | No | No | - | [templates](templates.md) via (`template_id` -> `id`) |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `position_left` | Business attribute `position_left` used by template signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `position_top` | Business attribute `position_top` used by template signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `width` | Business attribute `width` used by template signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `height` | Business attribute `height` used by template signatures workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `page` | Business attribute `page` used by template signatures workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
