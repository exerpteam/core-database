# art_match
Bridge table that links related entities for art match relationships. It is typically used where it appears in approximately 172 query files; common companions include [ar_trans](ar_trans.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `art_paying_center` | Center component of the composite reference to the related art paying record. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - |
| `art_paying_id` | Identifier component of the composite reference to the related art paying record. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - |
| `art_paying_subid` | Identifier of the related ar trans record used by this row. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paying_center`, `art_paying_id`, `art_paying_subid` -> `center`, `id`, `subid`) | - |
| `art_paid_center` | Center component of the composite reference to the related art paid record. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - |
| `art_paid_id` | Identifier component of the composite reference to the related art paid record. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - |
| `art_paid_subid` | Identifier of the related ar trans record used by this row. | `int4` | No | No | [ar_trans](ar_trans.md) via (`art_paid_center`, `art_paid_id`, `art_paid_subid` -> `center`, `id`, `subid`) | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `cancelled_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `used_rule` | Business attribute `used_rule` used by art match workflows and reporting. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [ar_trans](ar_trans.md) (171 query files), [centers](centers.md) (137 query files), [persons](persons.md) (129 query files), [account_receivables](account_receivables.md) (125 query files), [invoices](invoices.md) (80 query files), [account_trans](account_trans.md) (79 query files).
- FK-linked tables: outgoing FK to [ar_trans](ar_trans.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashregistertransactions](cashregistertransactions.md), [crt_art_link](crt_art_link.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md).
