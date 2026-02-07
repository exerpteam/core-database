# art_match
Bridge table that links related entities for art match relationships. It is typically used where it appears in approximately 172 query files; common companions include [ar_trans](ar_trans.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `art_paying_center` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - | `101` |
| `art_paying_id` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `art_paying_subid` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - | `1` |
| `art_paid_center` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - | `101` |
| `art_paid_id` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `art_paid_subid` | Foreign key field linking this record to `ar_trans`. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - | `1` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `cancelled_time` | Epoch timestamp for cancelled. | `int8` | Yes | No | - | - | `1738281600000` |
| `used_rule` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- Commonly used with: [ar_trans](ar_trans.md) (171 query files), [centers](centers.md) (137 query files), [persons](persons.md) (129 query files), [account_receivables](account_receivables.md) (125 query files), [invoices](invoices.md) (80 query files), [account_trans](account_trans.md) (79 query files).
- FK-linked tables: outgoing FK to [ar_trans](ar_trans.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashregistertransactions](cashregistertransactions.md), [crt_art_link](crt_art_link.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md).
