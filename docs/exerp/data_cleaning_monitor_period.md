# data_cleaning_monitor_period
Operational table for data cleaning monitor period records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `one_shot` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `agency` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `agency_id` | Identifier of the related agency record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `monitoring_start_time` | Epoch timestamp for monitoring start. | `int8` | No | No | - | - | `1738281600000` |
| `monitoring_stop_time` | Epoch timestamp for monitoring stop. | `int8` | Yes | No | - | - | `1738281600000` |
| `start_data_clean_out_line_id` | Foreign key field linking this record to `data_cleaning_out_line`. | `int4` | Yes | No | [data_cleaning_out_line](data_cleaning_out_line.md) via (`start_data_clean_out_line_id` -> `id`) | - | `1001` |
| `start_data_clean_in_line_id` | Foreign key field linking this record to `data_cleaning_in_line`. | `int4` | Yes | No | [data_cleaning_in_line](data_cleaning_in_line.md) via (`start_data_clean_in_line_id` -> `id`) | - | `1001` |
| `stop_data_clean_out_line_id` | Foreign key field linking this record to `data_cleaning_out_line`. | `int4` | Yes | No | [data_cleaning_out_line](data_cleaning_out_line.md) via (`stop_data_clean_out_line_id` -> `id`) | - | `1001` |
| `stop_data_clean_in_line_id` | Foreign key field linking this record to `data_cleaning_in_line`. | `int4` | Yes | No | [data_cleaning_in_line](data_cleaning_in_line.md) via (`stop_data_clean_in_line_id` -> `id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_out_line](data_cleaning_out_line.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
