# access_code
Operational table for access code records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `access_code` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `usage_point_center` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - | `101` |
| `usage_point_id` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - | `1001` |
| `access_time` | Epoch timestamp for access. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- FK-linked tables: outgoing FK to [usage_points](usage_points.md).
- Second-level FK neighborhood includes: [usage_point_resources](usage_point_resources.md), [usage_point_sources](usage_point_sources.md).
