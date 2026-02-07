# invoices
Financial/transactional table for invoices records. It is typically used where rows are center-scoped; it appears in approximately 897 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `trans_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `cashregister_center` | Center component of the composite reference to the related cashregister record. | `int4` | Yes | No | [cashregisters](cashregisters.md) via (`cashregister_center`, `cashregister_id` -> `center`, `id`) | - |
| `cashregister_id` | Identifier component of the composite reference to the related cashregister record. | `int4` | Yes | No | [cashregisters](cashregisters.md) via (`cashregister_center`, `cashregister_id` -> `center`, `id`) | - |
| `paysessionid` | Operational field `paysessionid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `transferred` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `payer_center` | Center component of the composite reference to the related payer record. | `int4` | Yes | No | [persons](persons.md) via (`payer_center`, `payer_id` -> `center`, `id`) | - |
| `payer_id` | Identifier component of the composite reference to the related payer record. | `int4` | Yes | No | [persons](persons.md) via (`payer_center`, `payer_id` -> `center`, `id`) | - |
| `receipt_id` | Identifier for the related receipt entity used by this record. | `int4` | Yes | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `control_device_id` | Identifier for the related control device entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `control_code` | Business attribute `control_code` used by invoices workflows and reporting. | `VARCHAR(500)` | Yes | No | - | - |
| `cash` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `sponsor_invoice_center` | Center component of the composite reference to the related sponsor invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`sponsor_invoice_center`, `sponsor_invoice_id` -> `center`, `id`) | - |
| `sponsor_invoice_id` | Identifier component of the composite reference to the related sponsor invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`sponsor_invoice_center`, `sponsor_invoice_id` -> `center`, `id`) | - |
| `print_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `fiscal_reference` | Business attribute `fiscal_reference` used by invoices workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `fiscal_export_token` | Business attribute `fiscal_export_token` used by invoices workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `clearance_status` | State indicator used to control lifecycle transitions and filtering. | `VARCHAR(20)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (727 query files), [products](products.md) (718 query files), [centers](centers.md) (644 query files), [invoice_lines_mt](invoice_lines_mt.md) (412 query files), [ar_trans](ar_trans.md) (362 query files), [account_receivables](account_receivables.md) (317 query files).
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md), [employees](employees.md), [invoices](invoices.md), [persons](persons.md); incoming FK from [credit_notes](credit_notes.md), [creditcardtransactions](creditcardtransactions.md), [invoice_lines_mt](invoice_lines_mt.md), [invoices](invoices.md), [shopping_basket_invoice_link](shopping_basket_invoice_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
