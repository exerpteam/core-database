# inventory
Operational table for inventory records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 36 query files; common companions include [centers](centers.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `center` | Foreign key field linking this record to `centers`. | `int4` | No | No | [centers](centers.md) via (`center` -> `id`) | - | `101` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `def` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [centers](centers.md) (32 query files), [products](products.md) (27 query files), [persons](persons.md) (22 query files), [account_trans](account_trans.md) (20 query files), [accounts](accounts.md) (20 query files), [ar_trans](ar_trans.md) (20 query files).
- FK-linked tables: outgoing FK to [centers](centers.md); incoming FK from [cashregisters](cashregisters.md), [delivery](delivery.md), [inventory_trans](inventory_trans.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
