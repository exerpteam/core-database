# data_cleaning_out_line
Operational table for data cleaning out line records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `data_cleaning_out_id` | Foreign key field linking this record to `data_cleaning_out`. | `int4` | No | No | [data_cleaning_out](data_cleaning_out.md) via (`data_cleaning_out_id` -> `id`) | - |
| `line_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `line_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_out](data_cleaning_out.md), [persons](persons.md); incoming FK from [data_cleaning_monitor_period](data_cleaning_monitor_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
