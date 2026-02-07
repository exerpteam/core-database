# booking_resource_groups
Operational table for booking resource groups records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 37 query files; common companions include [booking_resource_configs](booking_resource_configs.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `old_room_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [booking_resource_configs](booking_resource_configs.md) (23 query files), [activity](activity.md) (22 query files), [activity_resource_configs](activity_resource_configs.md) (20 query files), [booking_resources](booking_resources.md) (19 query files), [centers](centers.md) (18 query files), [activity_group](activity_group.md) (17 query files).
- FK-linked tables: incoming FK from [booking_resource_configs](booking_resource_configs.md).
- Second-level FK neighborhood includes: [booking_resources](booking_resources.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
