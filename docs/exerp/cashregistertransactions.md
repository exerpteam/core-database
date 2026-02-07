# cashregistertransactions
Financial/transactional table for cashregistertransactions records. It is typically used where rows are center-scoped; it appears in approximately 218 query files; common companions include [centers](centers.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [cashregisters](cashregisters.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [cashregisters](cashregisters.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `crttype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `transtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `crcenter` | Foreign key field linking this record to `cashregisterreports`. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `crid` | Foreign key field linking this record to `cashregisterreports`. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `crsubid` | Foreign key field linking this record to `cashregisterreports`. | `int4` | Yes | No | [cashregisterreports](cashregisterreports.md) via (`crcenter`, `crid`, `crsubid` -> `center`, `id`, `subid`) | - |
| `gltranscenter` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `gltransid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `gltranssubid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`gltranscenter`, `gltransid`, `gltranssubid` -> `center`, `id`, `subid`) | - |
| `artranscenter` | Foreign key field linking this record to `ar_trans`. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `artransid` | Foreign key field linking this record to `ar_trans`. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `artranssubid` | Foreign key field linking this record to `ar_trans`. | `int4` | Yes | No | [ar_trans](ar_trans.md) via (`artranscenter`, `artransid`, `artranssubid` -> `center`, `id`, `subid`) | - |
| `aptranscenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `aptransid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `aptranssubid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `billcenter` | Foreign key field linking this record to `bills`. | `int4` | Yes | No | [bills](bills.md) via (`billcenter`, `billid` -> `center`, `id`) | - |
| `billid` | Foreign key field linking this record to `bills`. | `int4` | Yes | No | [bills](bills.md) via (`billcenter`, `billid` -> `center`, `id`) | - |
| `paysessionid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `customercenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `customerid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cr_action` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `config_payment_method_id` | Identifier of the related config payment method record. | `int4` | Yes | No | - | - |
| `marker` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |

# Relations
- Commonly used with: [centers](centers.md) (175 query files), [invoices](invoices.md) (161 query files), [persons](persons.md) (156 query files), [ar_trans](ar_trans.md) (130 query files), [products](products.md) (126 query files), [account_receivables](account_receivables.md) (97 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [ar_trans](ar_trans.md), [bills](bills.md), [cashregisterreports](cashregisterreports.md), [cashregisters](cashregisters.md), [employees](employees.md), [installment_plans](installment_plans.md); incoming FK from [crt_art_link](crt_art_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [art_match](art_match.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [booking_change](booking_change.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
