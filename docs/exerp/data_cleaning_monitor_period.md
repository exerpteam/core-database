# data_cleaning_monitor_period
Operational table for data cleaning monitor period records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `one_shot` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `agency` | Business attribute `agency` used by data cleaning monitor period workflows and reporting. | `int4` | Yes | No | - | - |
| `agency_id` | Identifier for the related agency entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `monitoring_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `monitoring_stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `start_data_clean_out_line_id` | Identifier of the related data cleaning out line record used by this row. | `int4` | Yes | No | [data_cleaning_out_line](data_cleaning_out_line.md) via (`start_data_clean_out_line_id` -> `id`) | - |
| `start_data_clean_in_line_id` | Identifier of the related data cleaning in line record used by this row. | `int4` | Yes | No | [data_cleaning_in_line](data_cleaning_in_line.md) via (`start_data_clean_in_line_id` -> `id`) | - |
| `stop_data_clean_out_line_id` | Identifier of the related data cleaning out line record used by this row. | `int4` | Yes | No | [data_cleaning_out_line](data_cleaning_out_line.md) via (`stop_data_clean_out_line_id` -> `id`) | - |
| `stop_data_clean_in_line_id` | Identifier of the related data cleaning in line record used by this row. | `int4` | Yes | No | [data_cleaning_in_line](data_cleaning_in_line.md) via (`stop_data_clean_in_line_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_out_line](data_cleaning_out_line.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
