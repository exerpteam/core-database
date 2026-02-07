# aggregated_transactions
Operational table for aggregated transactions records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 80 query files; common companions include [account_trans](account_trans.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `book_date` | Date for book. | `DATE` | No | No | - | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `debit_account_external_id` | Identifier of the related debit account external record. | `text(2147483647)` | Yes | No | - | - |
| `credit_account_external_id` | Identifier of the related credit account external record. | `text(2147483647)` | Yes | No | - | - |
| `vat_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `debit_vat_account_external_id` | Identifier of the related debit vat account external record. | `text(2147483647)` | Yes | No | - | - |
| `credit_vat_account_external_id` | Identifier of the related credit vat account external record. | `text(2147483647)` | Yes | No | - | - |
| `vat_rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `vat_external_id` | Identifier of the related vat external record. | `text(2147483647)` | Yes | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `info_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `gl_export_batch_id` | Foreign key field linking this record to `gl_export_batches`. | `int4` | Yes | No | [gl_export_batches](gl_export_batches.md) via (`gl_export_batch_id` -> `id`) | - |

# Relations
- Commonly used with: [account_trans](account_trans.md) (39 query files), [centers](centers.md) (36 query files), [persons](persons.md) (29 query files), [extract](extract.md) (26 query files), [ar_trans](ar_trans.md) (22 query files), [account_receivables](account_receivables.md) (17 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [gl_export_batches](gl_export_batches.md); incoming FK from [account_trans](account_trans.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [accounts](accounts.md), [area_centers](area_centers.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
