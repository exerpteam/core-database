# booking_resource_groups
Operational table for booking resource groups records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 37 query files; common companions include [booking_resource_configs](booking_resource_configs.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `old_room_type_id` | Identifier of the related old room type record. | `int4` | Yes | No | - | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [booking_resource_configs](booking_resource_configs.md) (23 query files), [activity](activity.md) (22 query files), [activity_resource_configs](activity_resource_configs.md) (20 query files), [booking_resources](booking_resources.md) (19 query files), [centers](centers.md) (18 query files), [activity_group](activity_group.md) (17 query files).
- FK-linked tables: incoming FK from [booking_resource_configs](booking_resource_configs.md).
- Second-level FK neighborhood includes: [booking_resources](booking_resources.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
