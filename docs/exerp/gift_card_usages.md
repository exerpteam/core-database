# gift_card_usages
Operational table for gift card usages records in the Exerp schema. It is typically used where it appears in approximately 13 query files; common companions include [gift_cards](gift_cards.md), [account_trans](account_trans.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `transaction_center` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - | `101` |
| `transaction_id` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `transaction_subid` | Foreign key field linking this record to `account_trans`. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - | `1` |
| `gift_card_center` | Foreign key field linking this record to `gift_cards`. | `int4` | No | No | [gift_cards](gift_cards.md) via (`gift_card_center`, `gift_card_id` -> `center`, `id`) | - | `101` |
| `gift_card_id` | Foreign key field linking this record to `gift_cards`. | `int4` | No | No | [gift_cards](gift_cards.md) via (`gift_card_center`, `gift_card_id` -> `center`, `id`) | - | `1001` |

# Relations
- Commonly used with: [gift_cards](gift_cards.md) (12 query files), [account_trans](account_trans.md) (11 query files), [centers](centers.md) (11 query files), [cashregistertransactions](cashregistertransactions.md) (10 query files), [invoices](invoices.md) (10 query files), [ar_trans](ar_trans.md) (9 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [employees](employees.md), [gift_cards](gift_cards.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bills](bills.md).
