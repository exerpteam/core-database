# data_cleaning_in_line
Operational table for data cleaning in line records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `data_cleaning_in_id` | Foreign key field linking this record to `data_cleaning_in`. | `int4` | No | No | [data_cleaning_in](data_cleaning_in.md) via (`data_cleaning_in_id` -> `id`) | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `line_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `line_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `address_is_protected` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `rejects_advertising` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `first_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `middle_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `last_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address_1` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address_2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address_3` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `zip_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `zip_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `country` | Country code linked to the record. | `text(2147483647)` | Yes | No | - | - |
| `home_phone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `mobile_phone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `email_address` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `birthday` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `sex` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `status_date` | Date for status. | `DATE` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | Yes | No | - | - |
| `new_ssn` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `agency_id` | Identifier of the related agency record. | `text(2147483647)` | Yes | No | - | - |
| `co_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_in](data_cleaning_in.md), [persons](persons.md); incoming FK from [data_cleaning_monitor_period](data_cleaning_monitor_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
