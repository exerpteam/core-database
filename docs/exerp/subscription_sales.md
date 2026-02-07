# subscription_sales
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 368 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `101` |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `1001` |
| `owner_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `company_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`company_center`, `company_id` -> `center`, `id`) | - | `101` |
| `company_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`company_center`, `company_id` -> `center`, `id`) | - | `1001` |
| `subscription_type_center` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`) | - | `101` |
| `subscription_type_id` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`) | - | `1001` |
| `subscription_type_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `1` |
| `price_new` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_new_sponsored` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_new_discount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_initial` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_initial_sponsored` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_initial_discount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_period` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `price_admin_fee` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_admin_fee_sponsored` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_admin_fee_discount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `credited` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `binding_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `start_date` | Date when the record becomes effective. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `sales_date` | Date for sales. | `DATE` | No | No | - | - | `2025-01-31` |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `subscription_center` | Foreign key field linking this record to `centers`. | `int4` | Yes | No | [centers](centers.md) via (`subscription_center` -> `id`)<br>[subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `101` |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `1001` |
| `cancellation_date` | Date for cancellation. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `termination_date` | Date for termination. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `cancellation_employee_center` | Center part of the reference to related cancellation employee data. | `int4` | Yes | No | - | - | `101` |
| `cancellation_employee_id` | Identifier of the related cancellation employee record. | `int4` | Yes | No | - | - | `1001` |
| `price_prorata` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_prorata_sponsored` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `price_prorata_discount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `contract_excluding_sponsor` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `contract_including_sponsor` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `contract_sponsored` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `signatures_completed_time` | Epoch timestamp for signatures completed. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [persons](persons.md) (347 query files), [subscriptions](subscriptions.md) (323 query files), [products](products.md) (315 query files), [centers](centers.md) (253 query files), [subscriptiontypes](subscriptiontypes.md) (248 query files), [person_ext_attrs](person_ext_attrs.md) (185 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [employees](employees.md), [persons](persons.md), [products](products.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
