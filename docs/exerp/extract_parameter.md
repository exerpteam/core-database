# extract_parameter
Operational table for extract parameter records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `EXTRACT` | Foreign key field linking this record to `extract`. | `int4` | Yes | No | [extract](extract.md) via (`EXTRACT` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `label` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `default_value_text_value` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `default_value_mime_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `default_value_mime_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [extract](extract.md).
- Second-level FK neighborhood includes: [extract_group_link](extract_group_link.md), [extract_usage](extract_usage.md), [roles](roles.md).
