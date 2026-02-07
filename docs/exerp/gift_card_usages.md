# gift_card_usages
Operational table for gift card usages records in the Exerp schema. It is typically used where it appears in approximately 13 query files; common companions include [gift_cards](gift_cards.md), [account_trans](account_trans.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `TIME` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `transaction_center` | Center component of the composite reference to the related transaction record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - |
| `transaction_id` | Identifier component of the composite reference to the related transaction record. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - |
| `transaction_subid` | Identifier of the related account trans record used by this row. | `int4` | Yes | No | [account_trans](account_trans.md) via (`transaction_center`, `transaction_id`, `transaction_subid` -> `center`, `id`, `subid`) | - |
| `gift_card_center` | Center component of the composite reference to the related gift card record. | `int4` | No | No | [gift_cards](gift_cards.md) via (`gift_card_center`, `gift_card_id` -> `center`, `id`) | - |
| `gift_card_id` | Identifier component of the composite reference to the related gift card record. | `int4` | No | No | [gift_cards](gift_cards.md) via (`gift_card_center`, `gift_card_id` -> `center`, `id`) | - |

# Relations
- Commonly used with: [gift_cards](gift_cards.md) (12 query files), [account_trans](account_trans.md) (11 query files), [centers](centers.md) (11 query files), [cashregistertransactions](cashregistertransactions.md) (10 query files), [invoices](invoices.md) (10 query files), [ar_trans](ar_trans.md) (9 query files).
- FK-linked tables: outgoing FK to [account_trans](account_trans.md), [employees](employees.md), [gift_cards](gift_cards.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bill_lines_mt](bill_lines_mt.md), [billlines_vat_at_link](billlines_vat_at_link.md), [bills](bills.md).
