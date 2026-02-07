# booking_privilege_groups
Operational table for booking privilege groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 40 query files; common companions include [centers](centers.md), [booking_resources](booking_resources.md).

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
| `converted_rr_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `frequency_restriction_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `frequency_restriction_value` | Business attribute `frequency_restriction_value` used by booking privilege groups workflows and reporting. | `int4` | Yes | No | - | - |
| `frequency_restriction_unit` | Business attribute `frequency_restriction_unit` used by booking privilege groups workflows and reporting. | `int4` | Yes | No | - | - |
| `frequency_restriction_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `frequency_restr_include_noshow` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (18 query files), [booking_resources](booking_resources.md) (15 query files), [participation_configurations](participation_configurations.md) (14 query files), [activity](activity.md) (13 query files), [booking_resource_groups](booking_resource_groups.md) (13 query files), [booking_privileges](booking_privileges.md) (13 query files).
- FK-linked tables: incoming FK from [booking_privileges](booking_privileges.md), [booking_resources](booking_resources.md), [participation_configurations](participation_configurations.md).
- Second-level FK neighborhood includes: [activity](activity.md), [attends](attends.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [participations](participations.md), [privilege_sets](privilege_sets.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
