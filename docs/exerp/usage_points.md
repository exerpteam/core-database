# usage_points
Operational table for usage points records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 11 query files; common companions include [centers](centers.md), [clients](clients.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `all_clients` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `all_kiosks` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (10 query files), [clients](clients.md) (8 query files), [booking_resources](booking_resources.md) (8 query files), [usage_point_resources](usage_point_resources.md) (6 query files), [devices](devices.md) (5 query files), [usage_point_sources](usage_point_sources.md) (5 query files).
- FK-linked tables: incoming FK from [access_code](access_code.md), [usage_point_resources](usage_point_resources.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [clients](clients.md), [devices](devices.md), [gates](gates.md), [usage_point_action_res_link](usage_point_action_res_link.md), [usage_point_usages](usage_point_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
