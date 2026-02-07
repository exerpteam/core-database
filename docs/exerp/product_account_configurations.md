# product_account_configurations
Configuration table for product account configurations behavior and defaults. It is typically used where it appears in approximately 171 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `product_account_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `sales_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `expenses_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `refund_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `write_off_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `defer_rev_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `inventory_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `defer_lia_account_globalid` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (148 query files), [centers](centers.md) (127 query files), [accounts](accounts.md) (126 query files), [product_group](product_group.md) (103 query files), [invoices](invoices.md) (80 query files), [persons](persons.md) (73 query files).
- FK-linked tables: incoming FK from [masterproductregister](masterproductregister.md), [product_group](product_group.md), [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [centers](centers.md), [client_profiles](client_profiles.md), [clipcardtypes](clipcardtypes.md), [colour_groups](colour_groups.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [frequent_products_item](frequent_products_item.md).
