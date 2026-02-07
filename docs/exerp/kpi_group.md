# kpi_group
Operational table for kpi group records in the Exerp schema. It is typically used where lifecycle state codes are present.

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
| `override_roles` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- FK-linked tables: incoming FK from [kpi_field_group](kpi_field_group.md), [kpi_group_and_role_link](kpi_group_and_role_link.md).
- Second-level FK neighborhood includes: [kpi_fields](kpi_fields.md), [roles](roles.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
