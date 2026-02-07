# usage_point_action_res_link
Bridge table that links related entities for usage point action res link relationships. It is typically used where it appears in approximately 4 query files; common companions include [booking_resources](booking_resources.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `action_center` | Foreign key field linking this record to `usage_point_resources`. | `int4` | No | Yes | [usage_point_resources](usage_point_resources.md) via (`action_center`, `action_id` -> `center`, `id`) | - | `101` |
| `action_id` | Foreign key field linking this record to `usage_point_resources`. | `int4` | No | Yes | [usage_point_resources](usage_point_resources.md) via (`action_center`, `action_id` -> `center`, `id`) | - | `1001` |
| `resource_center` | Foreign key field linking this record to `booking_resources`. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`resource_center`, `resource_id` -> `center`, `id`) | - | `101` |
| `resource_id` | Foreign key field linking this record to `booking_resources`. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`resource_center`, `resource_id` -> `center`, `id`) | - | `1001` |

# Relations
- Commonly used with: [booking_resources](booking_resources.md) (4 query files), [centers](centers.md) (4 query files), [devices](devices.md) (4 query files), [usage_point_resources](usage_point_resources.md) (4 query files), [usage_point_sources](usage_point_sources.md) (4 query files), [usage_points](usage_points.md) (4 query files).
- FK-linked tables: outgoing FK to [booking_resources](booking_resources.md), [usage_point_resources](usage_point_resources.md).
- Second-level FK neighborhood includes: [attends](attends.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [gates](gates.md), [usage_point_usages](usage_point_usages.md), [usage_points](usage_points.md).
