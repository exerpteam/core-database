# aggregated_transactions
Operational table for aggregated transactions records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 80 query files; common companions include [account_trans](account_trans.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `book_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `debit_account_external_id` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `credit_account_external_id` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `vat_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `debit_vat_account_external_id` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `credit_vat_account_external_id` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `vat_rate` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `vat_external_id` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `info_type` | Classification code describing the info type category (for example: API, AR, ARReason, CashRegister). | `int4` | No | No | - | - |
| `info` | Operational field `info` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `gl_export_batch_id` | Identifier of the related gl export batches record used by this row. | `int4` | Yes | No | [gl_export_batches](gl_export_batches.md) via (`gl_export_batch_id` -> `id`) | - |

# Relations
- Commonly used with: [account_trans](account_trans.md) (39 query files), [centers](centers.md) (36 query files), [persons](persons.md) (29 query files), [extract](extract.md) (26 query files), [ar_trans](ar_trans.md) (22 query files), [account_receivables](account_receivables.md) (17 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [gl_export_batches](gl_export_batches.md); incoming FK from [account_trans](account_trans.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [area_centers](area_centers.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
