# crt_art_link
Bridge table that links related entities for crt art link relationships. It is typically used where it appears in approximately 3 query files; common companions include [account_trans](account_trans.md), [ar_trans](ar_trans.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `crt_center` | Foreign key field linking this record to `cashregistertransactions`. | `int4` | No | Yes | [cashregistertransactions](cashregistertransactions.md) via (`crt_center`, `crt_id`, `crt_subid` -> `center`, `id`, `subid`) | - |
| `crt_id` | Foreign key field linking this record to `cashregistertransactions`. | `int4` | No | Yes | [cashregistertransactions](cashregistertransactions.md) via (`crt_center`, `crt_id`, `crt_subid` -> `center`, `id`, `subid`) | - |
| `crt_subid` | Foreign key field linking this record to `cashregistertransactions`. | `int4` | No | Yes | [cashregistertransactions](cashregistertransactions.md) via (`crt_center`, `crt_id`, `crt_subid` -> `center`, `id`, `subid`) | - |
| `art_center` | Foreign key field linking this record to `ar_trans`. | `int4` | No | Yes | [ar_trans](ar_trans.md) via (`art_center`, `art_id`, `art_subid` -> `center`, `id`, `subid`) | - |
| `art_id` | Foreign key field linking this record to `ar_trans`. | `int4` | No | Yes | [ar_trans](ar_trans.md) via (`art_center`, `art_id`, `art_subid` -> `center`, `id`, `subid`) | - |
| `art_subid` | Foreign key field linking this record to `ar_trans`. | `int4` | No | Yes | [ar_trans](ar_trans.md) via (`art_center`, `art_id`, `art_subid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [account_trans](account_trans.md) (3 query files), [ar_trans](ar_trans.md) (3 query files), [art_match](art_match.md) (3 query files), [cashregistertransactions](cashregistertransactions.md) (3 query files), [invoices](invoices.md) (3 query files), [persons](persons.md) (3 query files).
- FK-linked tables: outgoing FK to [ar_trans](ar_trans.md), [cashregistertransactions](cashregistertransactions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [art_match](art_match.md), [bills](bills.md), [cashregisterreports](cashregisterreports.md), [cashregisters](cashregisters.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md).
