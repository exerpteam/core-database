# booking_privilege_groups
Operational table for booking privilege groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 40 query files; common companions include [centers](centers.md), [booking_resources](booking_resources.md).

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
| `converted_rr_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `frequency_restr_include_noshow` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [centers](centers.md) (18 query files), [booking_resources](booking_resources.md) (15 query files), [participation_configurations](participation_configurations.md) (14 query files), [activity](activity.md) (13 query files), [booking_resource_groups](booking_resource_groups.md) (13 query files), [booking_privileges](booking_privileges.md) (13 query files).
- FK-linked tables: incoming FK from [booking_privileges](booking_privileges.md), [booking_resources](booking_resources.md), [participation_configurations](participation_configurations.md).
- Second-level FK neighborhood includes: [activity](activity.md), [attends](attends.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [participations](participations.md), [privilege_sets](privilege_sets.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
