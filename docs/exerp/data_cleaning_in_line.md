# data_cleaning_in_line
Operational table for data cleaning in line records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `data_cleaning_in_id` | Identifier of the related data cleaning in record used by this row. | `int4` | No | No | [data_cleaning_in](data_cleaning_in.md) via (`data_cleaning_in_id` -> `id`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `line_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `line_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `address_is_protected` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `rejects_advertising` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `first_name` | Operational field `first_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `middle_name` | Business attribute `middle_name` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `last_name` | Operational field `last_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `address_1` | Business attribute `address_1` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `address_2` | Business attribute `address_2` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `address_3` | Business attribute `address_3` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `zip_code` | Business attribute `zip_code` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `zip_name` | Business attribute `zip_name` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `country` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `home_phone` | Operational field `home_phone` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `mobile_phone` | Operational field `mobile_phone` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `email_address` | Business attribute `email_address` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `birthday` | Business attribute `birthday` used by data cleaning in line workflows and reporting. | `DATE` | Yes | No | - | - |
| `sex` | Operational field `sex` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `status_date` | State indicator used to control lifecycle transitions and filtering. | `DATE` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | Yes | No | - | - |
| `new_ssn` | Business attribute `new_ssn` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `agency_id` | Identifier for the related agency entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `co_name` | Business attribute `co_name` used by data cleaning in line workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [data_cleaning_in](data_cleaning_in.md), [persons](persons.md); incoming FK from [data_cleaning_monitor_period](data_cleaning_monitor_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
