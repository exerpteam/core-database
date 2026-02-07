# usage_points
Operational table for usage points records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 11 query files; common companions include [centers](centers.md), [clients](clients.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `all_clients` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `all_kiosks` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [centers](centers.md) (10 query files), [clients](clients.md) (8 query files), [booking_resources](booking_resources.md) (8 query files), [usage_point_resources](usage_point_resources.md) (6 query files), [devices](devices.md) (5 query files), [usage_point_sources](usage_point_sources.md) (5 query files).
- FK-linked tables: incoming FK from [access_code](access_code.md), [usage_point_resources](usage_point_resources.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [clients](clients.md), [devices](devices.md), [gates](gates.md), [usage_point_action_res_link](usage_point_action_res_link.md), [usage_point_usages](usage_point_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
