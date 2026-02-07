# accountingperiods
Financial/transactional table for accountingperiods records. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `opened` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `endtime` | Operational field `endtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [centers](centers.md); incoming FK from [account_trans](account_trans.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
