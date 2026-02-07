# credit_notes
Operational table for credit notes records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 324 query files; common companions include [invoices](invoices.md), [persons](persons.md).

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
| `control_code` | Business attribute `control_code` used by credit notes workflows and reporting. | `VARCHAR(500)` | Yes | No | - | - |
| `invoice_center` | Center component of the composite reference to the related invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Identifier component of the composite reference to the related invoice record. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `auditedbycenter` | Center component of the composite reference to the related auditedby record. | `int4` | Yes | No | [employees](employees.md) via (`auditedbycenter`, `auditedbyid` -> `center`, `id`) | - |
| `auditedbyid` | Identifier component of the composite reference to the related auditedby record. | `int4` | Yes | No | [employees](employees.md) via (`auditedbycenter`, `auditedbyid` -> `center`, `id`) | - |
| `canceltype` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `cash` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `fiscal_reference` | Business attribute `fiscal_reference` used by credit notes workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `fiscal_export_token` | Business attribute `fiscal_export_token` used by credit notes workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `clearance_status` | State indicator used to control lifecycle transitions and filtering. | `VARCHAR(20)` | No | No | - | - |

# Relations
- Commonly used with: [invoices](invoices.md) (288 query files), [persons](persons.md) (274 query files), [centers](centers.md) (259 query files), [products](products.md) (250 query files), [ar_trans](ar_trans.md) (190 query files), [account_receivables](account_receivables.md) (156 query files).
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md), [employees](employees.md), [invoices](invoices.md), [persons](persons.md); incoming FK from [credit_note_lines_mt](credit_note_lines_mt.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
