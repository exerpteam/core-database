# extract_group
Operational table for extract group records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [extract](extract.md), [extract_group_link](extract_group_link.md).

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
| `override_roles` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [extract](extract.md) (5 query files), [extract_group_link](extract_group_link.md) (5 query files), [extract_usage](extract_usage.md) (4 query files).
- FK-linked tables: incoming FK from [extract_group_and_role_link](extract_group_and_role_link.md), [extract_group_link](extract_group_link.md).
- Second-level FK neighborhood includes: [extract](extract.md), [roles](roles.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
