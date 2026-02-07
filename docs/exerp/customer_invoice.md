# customer_invoice
Financial/transactional table for customer invoice records. It is typically used where it appears in approximately 13 query files; common companions include [invoices](invoices.md), [invoice_lines_mt](invoice_lines_mt.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `reference_sub_id` | Identifier for the related reference sub entity used by this record. | `int4` | Yes | No | - | - |
| `reference_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `invoice_reference` | Business attribute `invoice_reference` used by customer invoice workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `issued_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | No | No | - | - |
| `created_by_emp_center` | Center component of the composite reference to the related created by emp record. | `int4` | No | No | - | - |
| `created_by_emp_id` | Identifier component of the composite reference to the related created by emp record. | `int4` | No | No | - | - |
| `formatted_doc_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `formatted_doc_mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_id`, `person_center` -> `id`, `center`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_id`, `person_center` -> `id`, `center`) | - |

# Relations
- Commonly used with: [invoices](invoices.md) (13 query files), [invoice_lines_mt](invoice_lines_mt.md) (12 query files), [persons](persons.md) (11 query files), [person_ext_attrs](person_ext_attrs.md) (10 query files), [centers](centers.md) (9 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (8 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
