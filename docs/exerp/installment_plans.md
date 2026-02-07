# installment_plans
Operational table for installment plans records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 35 query files; common companions include [products](products.md), [invoices](invoices.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `ip_config_id` | Identifier of the related installment plan configs record used by this row. | `int4` | No | No | [installment_plan_configs](installment_plan_configs.md) via (`ip_config_id` -> `id`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `installements_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `collect_agreement_center` | Center component of the composite reference to the related collect agreement record. | `int4` | Yes | No | - | - |
| `collect_agreement_id` | Identifier component of the composite reference to the related collect agreement record. | `int4` | Yes | No | - | - |
| `collect_agreement_subid` | Business attribute `collect_agreement_subid` used by installment plans workflows and reporting. | `int4` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(300)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `single_booking_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (29 query files), [invoices](invoices.md) (26 query files), [account_receivables](account_receivables.md) (24 query files), [clipcards](clipcards.md) (24 query files), [centers](centers.md) (24 query files), [ar_trans](ar_trans.md) (23 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [installment_plan_configs](installment_plan_configs.md), [persons](persons.md); incoming FK from [ar_trans](ar_trans.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_lines_mt](credit_note_lines_mt.md), [invoice_lines_mt](invoice_lines_mt.md), [recurring_participations](recurring_participations.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [art_match](art_match.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
