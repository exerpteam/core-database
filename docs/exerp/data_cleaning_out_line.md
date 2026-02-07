# data_cleaning_out_line
Operational table for data cleaning out line records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `data_cleaning_out_id` | Identifier of the related data cleaning out record used by this row. | `int4` | No | No | [data_cleaning_out](data_cleaning_out.md) via (`data_cleaning_out_id` -> `id`) | - |
| `line_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `line_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_out](data_cleaning_out.md), [persons](persons.md); incoming FK from [data_cleaning_monitor_period](data_cleaning_monitor_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
