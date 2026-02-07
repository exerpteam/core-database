# data_cleaning_in_line
Operational table for data cleaning in line records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `data_cleaning_in_id` | Foreign key field linking this record to `data_cleaning_in`. | `int4` | No | No | [data_cleaning_in](data_cleaning_in.md) via (`data_cleaning_in_id` -> `id`) | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `line_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `line_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `address_is_protected` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `rejects_advertising` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `first_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `middle_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `last_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `address_1` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `address_2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `address_3` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `zip_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `zip_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `country` | Country code linked to the record. | `text(2147483647)` | Yes | No | - | - | `SE` |
| `home_phone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mobile_phone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `email_address` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `member@example.com` |
| `birthday` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `sex` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `F` |
| `status_date` | Date for status. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | Yes | No | - | - | `1` |
| `new_ssn` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `agency_id` | Identifier of the related agency record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `co_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_in](data_cleaning_in.md), [persons](persons.md); incoming FK from [data_cleaning_monitor_period](data_cleaning_monitor_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
