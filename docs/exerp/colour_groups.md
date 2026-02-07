# colour_groups
Operational table for colour groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 37 query files; common companions include [activity](activity.md), [activity_group](activity_group.md).

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
| `colour` | Business attribute `colour` used by colour groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `old_colour_code_id` | Identifier for the related old colour code entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (35 query files), [activity_group](activity_group.md) (25 query files), [bookings](bookings.md) (18 query files), [centers](centers.md) (16 query files), [participation_configurations](participation_configurations.md) (15 query files), [activity_resource_configs](activity_resource_configs.md) (12 query files).
- FK-linked tables: incoming FK from [product_group](product_group.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [client_profiles](client_profiles.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductregister](masterproductregister.md), [product_account_configurations](product_account_configurations.md), [product_and_product_group_link](product_and_product_group_link.md), [products](products.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
