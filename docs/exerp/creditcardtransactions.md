# creditcardtransactions
Operational table for creditcardtransactions records in the Exerp schema. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 51 query files; common companions include [cashregistertransactions](cashregistertransactions.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `transtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `account_number` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `gl_trans_center` | Center part of the reference to related gl trans data. | `int4` | Yes | No | - | - |
| `gl_trans_id` | Identifier of the related gl trans record. | `int4` | Yes | No | - | - |
| `gl_trans_subid` | Sub-identifier for related gl trans detail rows. | `int4` | Yes | No | - | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `transaction_id` | Identifier of the related transaction record. | `text(2147483647)` | Yes | No | - | - |
| `expiration_date` | Date for expiration. | `text(2147483647)` | Yes | No | - | - |
| `authorisation_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `card_swiped` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `transaction_state` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `METHOD` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `return_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `return_code_details` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `order_id` | Identifier of the related order record. | `text(2147483647)` | Yes | No | - | - |
| `recurring_agreement_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `capture_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_center` | Center part of the reference to related cof payment agreement data. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_id` | Identifier of the related cof payment agreement record. | `int4` | Yes | No | - | - |
| `cof_payment_agreement_subid` | Sub-identifier for related cof payment agreement detail rows. | `int4` | Yes | No | - | - |
| `approval_code` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `receipt_number` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `invoice_center` | Foreign key field linking this record to `invoices`. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Foreign key field linking this record to `invoices`. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `account_id` | Identifier of the related account record. | `VARCHAR(20)` | Yes | No | - | [accounts](accounts.md) via (`account_id` -> `id`) |
| `is_card_on_file` | Boolean flag indicating whether card on file applies. | `bool` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | No | No | - | - |

# Relations
- Commonly used with: [cashregistertransactions](cashregistertransactions.md) (42 query files), [centers](centers.md) (36 query files), [persons](persons.md) (30 query files), [invoices](invoices.md) (28 query files), [invoice_lines_mt](invoice_lines_mt.md) (22 query files), [account_trans](account_trans.md) (21 query files).
- FK-linked tables: outgoing FK to [invoices](invoices.md).
- Second-level FK neighborhood includes: [cashregisters](cashregisters.md), [credit_notes](credit_notes.md), [employees](employees.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [shopping_basket_invoice_link](shopping_basket_invoice_link.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
