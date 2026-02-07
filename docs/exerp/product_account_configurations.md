# product_account_configurations
Configuration table for product account configurations behavior and defaults. It is typically used where it appears in approximately 171 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `product_account_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `sales_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `expenses_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `refund_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `write_off_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `defer_rev_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `inventory_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `defer_lia_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(30)` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (148 query files), [centers](centers.md) (127 query files), [accounts](accounts.md) (126 query files), [product_group](product_group.md) (103 query files), [invoices](invoices.md) (80 query files), [persons](persons.md) (73 query files).
- FK-linked tables: incoming FK from [masterproductregister](masterproductregister.md), [product_group](product_group.md), [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [centers](centers.md), [client_profiles](client_profiles.md), [clipcardtypes](clipcardtypes.md), [colour_groups](colour_groups.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [frequent_products_item](frequent_products_item.md).
