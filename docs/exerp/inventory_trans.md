# inventory_trans
Operational table for inventory trans records in the Exerp schema. It is typically used where it appears in approximately 21 query files; common companions include [products](products.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `inventory` | Foreign key field linking this record to `inventory`. | `int4` | No | No | [inventory](inventory.md) via (`inventory` -> `id`) | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `product_center` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `book_time` | Epoch timestamp for book. | `int8` | No | No | - | - |
| `had_report_role` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `unit_value` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `remaining` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `ref_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Sub-identifier for related ref detail rows. | `int4` | Yes | No | - | - |
| `source_id` | Foreign key field linking this record to `inventory_trans`. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`source_id` -> `id`) | - |
| `first_source_id` | Foreign key field linking this record to `inventory_trans`. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`first_source_id` -> `id`) | - |
| `last_write_off_id` | Foreign key field linking this record to `inventory_trans`. | `int4` | Yes | No | [inventory_trans](inventory_trans.md) via (`last_write_off_id` -> `id`) | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `balance_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `balance_value` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `account_trans_center` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_id` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |
| `account_trans_subid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`account_trans_center`, `account_trans_id`, `account_trans_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [products](products.md) (18 query files), [centers](centers.md) (16 query files), [inventory](inventory.md) (12 query files), [persons](persons.md) (6 query files), [product_group](product_group.md) (6 query files), [delivery](delivery.md) (6 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [employees](employees.md), [inventory](inventory.md), [inventory_trans](inventory_trans.md), [products](products.md); incoming FK from [inventory_trans](inventory_trans.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bills](bills.md).
