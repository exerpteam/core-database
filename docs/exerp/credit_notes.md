# credit_notes
Operational table for credit notes records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 324 query files; common companions include [invoices](invoices.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `trans_time` | Epoch timestamp for trans. | `int8` | No | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `cashregister_center` | Foreign key field linking this record to `cashregisters`. | `int4` | Yes | No | [cashregisters](cashregisters.md) via (`cashregister_center`, `cashregister_id` -> `center`, `id`) | - |
| `cashregister_id` | Foreign key field linking this record to `cashregisters`. | `int4` | Yes | No | [cashregisters](cashregisters.md) via (`cashregister_center`, `cashregister_id` -> `center`, `id`) | - |
| `paysessionid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `transferred` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `payer_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`payer_center`, `payer_id` -> `center`, `id`) | - |
| `payer_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`payer_center`, `payer_id` -> `center`, `id`) | - |
| `receipt_id` | Identifier of the related receipt record. | `int4` | Yes | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `control_device_id` | Identifier of the related control device record. | `text(2147483647)` | Yes | No | - | - |
| `control_code` | Text field containing descriptive or reference information. | `VARCHAR(500)` | Yes | No | - | - |
| `invoice_center` | Foreign key field linking this record to `invoices`. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `invoice_id` | Foreign key field linking this record to `invoices`. | `int4` | Yes | No | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `auditedbycenter` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`auditedbycenter`, `auditedbyid` -> `center`, `id`) | - |
| `auditedbyid` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`auditedbycenter`, `auditedbyid` -> `center`, `id`) | - |
| `canceltype` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cash` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `fiscal_reference` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `fiscal_export_token` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `clearance_status` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - |

# Relations
- Commonly used with: [invoices](invoices.md) (288 query files), [persons](persons.md) (274 query files), [centers](centers.md) (259 query files), [products](products.md) (250 query files), [ar_trans](ar_trans.md) (190 query files), [account_receivables](account_receivables.md) (156 query files).
- FK-linked tables: outgoing FK to [cashregisters](cashregisters.md), [employees](employees.md), [invoices](invoices.md), [persons](persons.md); incoming FK from [credit_note_lines_mt](credit_note_lines_mt.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
