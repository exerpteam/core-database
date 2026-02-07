# vat_types
Operational table for vat types records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 111 query files; common companions include [accounts](accounts.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `accountcenter` | Center component of the composite reference to the related account record. | `int4` | Yes | No | [accounts](accounts.md) via (`accountcenter`, `accountid` -> `center`, `id`) | - |
| `accountid` | Identifier component of the composite reference to the related account record. | `int4` | Yes | No | [accounts](accounts.md) via (`accountcenter`, `accountid` -> `center`, `id`) | - |
| `rate` | Operational field `rate` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `orig_rate` | Business attribute `orig_rate` used by vat types workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [accounts](accounts.md) (95 query files), [persons](persons.md) (85 query files), [centers](centers.md) (82 query files), [products](products.md) (65 query files), [account_trans](account_trans.md) (59 query files), [invoices](invoices.md) (59 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md); incoming FK from [account_trans](account_trans.md), [account_vat_type_link](account_vat_type_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_vat_type_group](account_vat_type_group.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_line_vat_at_link](credit_note_line_vat_at_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
