# privilege_set_groups
Operational table for privilege set groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 16 query files; common companions include [privilege_sets](privilege_sets.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `role_id` | Identifier of the related role record. | `int4` | Yes | No | - | [roles](roles.md) via (`role_id` -> `id`) |

# Relations
- Commonly used with: [privilege_sets](privilege_sets.md) (16 query files), [privilege_grants](privilege_grants.md) (13 query files), [masterproductregister](masterproductregister.md) (11 query files), [companyagreements](companyagreements.md) (10 query files), [products](products.md) (8 query files), [persons](persons.md) (7 query files).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
