# gates
Operational table for gates records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 5 query files; common companions include [centers](centers.md), [devices](devices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `device_id` | Identifier of the related devices record used by this row. | `int4` | Yes | No | [devices](devices.md) via (`device_id` -> `id`) | - |
| `device_sub_id` | Identifier for the related device sub entity used by this record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (4 query files), [devices](devices.md) (4 query files), [clients](clients.md) (3 query files), [usage_point_resources](usage_point_resources.md) (3 query files), [usage_points](usage_points.md) (3 query files), [booking_resources](booking_resources.md) (2 query files).
- FK-linked tables: outgoing FK to [devices](devices.md); incoming FK from [usage_point_resources](usage_point_resources.md).
- Second-level FK neighborhood includes: [clients](clients.md), [usage_point_action_res_link](usage_point_action_res_link.md), [usage_point_sources](usage_point_sources.md), [usage_point_usages](usage_point_usages.md), [usage_points](usage_points.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
