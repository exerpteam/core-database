# cashregistertransactions
Financial/transactional table for cashregistertransactions records. It is typically used where rows are center-scoped; it appears in approximately 218 query files; common companions include [centers](centers.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [cashregisters](cashregisters.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [cashregisters](cashregisters.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `crttype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `transtime` | Operational field `transtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `crcenter` | Center component of the composite reference to the related cr record. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `crid` | Identifier component of the composite reference to the related cr record. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `crsubid` | Identifier of the related cashregisterreports record used by this row. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `gltranscenter` | Center component of the composite reference to the related gltrans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `gltransid` | Identifier component of the composite reference to the related gltrans record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `gltranssubid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `artranscenter` | Center component of the composite reference to the related artrans record. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `artransid` | Identifier component of the composite reference to the related artrans record. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `artranssubid` | Identifier of the related ar trans record used by this row. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `aptranscenter` | Center component of the composite reference to the related aptrans record. | `int4` | Yes | No | - | - |
| `aptransid` | Identifier component of the composite reference to the related aptrans record. | `int4` | Yes | No | - | - |
| `aptranssubid` | Business attribute `aptranssubid` used by cashregistertransactions workflows and reporting. | `int4` | Yes | No | - | - |
| `billcenter` | Center component of the composite reference to the related bill record. | `int4` | Yes | No | [bills](bills.md) via (`billcenter`, `billid` -> `center`, `id`) | - |
| `billid` | Identifier component of the composite reference to the related bill record. | `int4` | Yes | No | [bills](bills.md) via (`billcenter`, `billid` -> `center`, `id`) | - |
| `paysessionid` | Operational field `paysessionid` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `customercenter` | Center component of the composite reference to the related customer record. | `int4` | Yes | No | - | - |
| `customerid` | Identifier component of the composite reference to the related customer record. | `int4` | Yes | No | - | - |
| `cr_action` | Business attribute `cr_action` used by cashregistertransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `config_payment_method_id` | Identifier for the related config payment method entity used by this record. | `int4` | Yes | No | - | - |
| `marker` | Business attribute `marker` used by cashregistertransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `installment_plan_id` | Identifier of the related installment plans record used by this row. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |

# Relations
- Commonly used with: [centers](centers.md) (175 query files), [invoices](invoices.md) (161 query files), [persons](persons.md) (156 query files), [ar_trans](ar_trans.md) (130 query files), [products](products.md) (126 query files), [account_receivables](account_receivables.md) (97 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [ar_trans](ar_trans.md), [bills](bills.md), [cashregisterreports](cashregisterreports.md), [cashregisters](cashregisters.md), [employees](employees.md), [installment_plans](installment_plans.md); incoming FK from [crt_art_link](crt_art_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [art_match](art_match.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [booking_change](booking_change.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
