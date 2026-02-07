# vat_types
Operational table for vat types records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 111 query files; common companions include [accounts](accounts.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`accountcenter`, `accountid` -> `center`, `id`) | - | `42` |
| `accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`accountcenter`, `accountid` -> `center`, `id`) | - | `42` |
| `rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `orig_rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |

# Relations
- Commonly used with: [accounts](accounts.md) (95 query files), [persons](persons.md) (85 query files), [centers](centers.md) (82 query files), [products](products.md) (65 query files), [account_trans](account_trans.md) (59 query files), [invoices](invoices.md) (59 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md); incoming FK from [account_trans](account_trans.md), [account_vat_type_link](account_vat_type_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
