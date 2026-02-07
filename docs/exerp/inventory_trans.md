# inventory_trans
Operational table for inventory trans records in the Exerp schema. It is typically used where it appears in approximately 21 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `inventory` | Identifier of the related inventory record used by this row. | `int4` | No | No | [inventory](inventory.md) via (`inventory` -> `id`) | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `product_center` | Center component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Identifier component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `book_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `had_report_role` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `unit_value` | Business attribute `unit_value` used by inventory trans workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `remaining` | Operational field `remaining` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Operational field `ref_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `source_id` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`source_id` -> `id`) | - |
| `first_source_id` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`first_source_id` -> `id`) | - |
| `last_write_off_id` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`last_write_off_id` -> `id`) | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `balance_quantity` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | No | No | - | - |
| `balance_value` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `account_trans_center` | Center component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Identifier component of the composite reference to the related account trans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [products](products.md) (18 query files), [centers](centers.md) (16 query files), [inventory](inventory.md) (12 query files), [persons](persons.md) (6 query files), [product_group](product_group.md) (6 query files), [delivery](delivery.md) (6 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [employees](employees.md), [inventory](inventory.md), [inventory_trans](inventory_trans.md), [products](products.md); incoming FK from [inventory_trans](inventory_trans.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bills](bills.md).
