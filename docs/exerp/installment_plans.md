# installment_plans
Operational table for installment plans records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 35 query files; common companions include [products](products.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `ip_config_id` | Foreign key field linking this record to `installment_plan_configs`. | `int4` | No | No | [installment_plan_configs](installment_plan_configs.md) via (`ip_config_id` -> `id`) | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - |
| `installements_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `end_date` | Date when the record ends or expires. | `DATE` | No | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `collect_agreement_center` | Center part of the reference to related collect agreement data. | `int4` | Yes | No | - | - |
| `collect_agreement_id` | Identifier of the related collect agreement record. | `int4` | Yes | No | - | - |
| `collect_agreement_subid` | Sub-identifier for related collect agreement detail rows. | `int4` | Yes | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(300)` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `single_booking_date` | Date for single booking. | `DATE` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (29 query files), [invoices](invoices.md) (26 query files), [account_receivables](account_receivables.md) (24 query files), [clipcards](clipcards.md) (24 query files), [centers](centers.md) (24 query files), [ar_trans](ar_trans.md) (23 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [installment_plan_configs](installment_plan_configs.md), [persons](persons.md); incoming FK from [ar_trans](ar_trans.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_lines_mt](credit_note_lines_mt.md), [invoice_lines_mt](invoice_lines_mt.md), [recurring_participations](recurring_participations.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [art_match](art_match.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
