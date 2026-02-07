# template_signatures
Intermediate/cache table used to accelerate template signatures processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `template_id` | Identifier of the related template record. | `int4` | No | No | - | [templates](templates.md) via (`template_id` -> `id`) |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `reason` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `position_left` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `position_top` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `width` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `height` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `page` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
