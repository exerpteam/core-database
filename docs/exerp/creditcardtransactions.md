# creditcardtransactions
Operational table for creditcardtransactions records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 51 query files; common companions include [cashregistertransactions](cashregistertransactions.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `transtime` | Operational field `transtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `account_number` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `int4` | Yes | No | - | - |
| `gl_trans_center` | Center component of the composite reference to the related gl trans record. | `int4` | Yes | No | - | - |
| `gl_trans_id` | Identifier component of the composite reference to the related gl trans record. | `int4` | Yes | No | - | - |
| `gl_trans_subid` | Operational field `gl_trans_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `transaction_id` | Identifier for the related transaction entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `text(2147483647)` | Yes | No | - | - |
| `authorisation_code` | Business attribute `authorisation_code` used by creditcardtransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `card_swiped` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `transaction_state` | Business classification code used in reporting transformations (for example: AUTHORIZED, CAPTURED, ERROR, FAILED). | `int4` | Yes | No | - | - |
| `METHOD` | Operational field `METHOD` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `return_code` | Business attribute `return_code` used by creditcardtransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `return_code_details` | Business attribute `return_code_details` used by creditcardtransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `order_id` | Identifier for the related order entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `recurring_agreement_ref` | Business attribute `recurring_agreement_ref` used by creditcardtransactions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `capture_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_center` | Center component of the composite reference to the related cof payment agreement record. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_id` | Identifier component of the composite reference to the related cof payment agreement record. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_subid` | Business attribute `cof_payment_agreement_subid` used by creditcardtransactions workflows and reporting. | `int4` | Yes | No | - | - |
| `approval_code` | Business attribute `approval_code` used by creditcardtransactions workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `receipt_number` | Business attribute `receipt_number` used by creditcardtransactions workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `invoice_center` | Center component of the composite reference to the related invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Identifier component of the composite reference to the related invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `account_id` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(20)` | Yes | No | - | [accounts](accounts.md) via (`account_id` -> `id`) |
| `is_card_on_file` | Boolean flag indicating whether `card_on_file` applies to this record. | `bool` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |

# Relations
- Commonly used with: [cashregistertransactions](cashregistertransactions.md) (42 query files), [centers](centers.md) (36 query files), [persons](persons.md) (30 query files), [invoices](invoices.md) (28 query files), [invoice_lines_mt](invoice_lines_mt.md) (22 query files), [account_trans](account_trans.md) (21 query files).
- FK-linked tables: outgoing FK to [invoices](invoices.md).
- Second-level FK neighborhood includes: [cashregisters](cashregisters.md), [credit_notes](credit_notes.md), [employees](employees.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [shopping_basket_invoice_link](shopping_basket_invoice_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
