# inventory
Operational table for inventory records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 36 query files; common companions include [centers](centers.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center` | Identifier of the related centers record used by this row. | `int4` | No | No | [centers](centers.md) via (`center` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `def` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (32 query files), [products](products.md) (27 query files), [persons](persons.md) (22 query files), [account_trans](account_trans.md) (20 query files), [accounts](accounts.md) (20 query files), [ar_trans](ar_trans.md) (20 query files).
- FK-linked tables: outgoing FK to [centers](centers.md); incoming FK from [cashregisters](cashregisters.md), [delivery](delivery.md), [inventory_trans](inventory_trans.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cash_register_log](cash_register_log.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
