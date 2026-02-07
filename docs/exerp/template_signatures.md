# template_signatures
Intermediate/cache table used to accelerate template signatures processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `template_id` | Identifier of the related template record. | `int4` | No | No | - | [templates](templates.md) via (`template_id` -> `id`) | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `reason` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `position_left` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `position_top` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `width` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `height` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `page` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
