# bookings
Operational table for bookings records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 608 query files; common companions include [participations](participations.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `stoptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `creator_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `creator_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `activation_time` | Epoch timestamp for activation. | `int8` | Yes | No | - | - |
| `activation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - |
| `activation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - |
| `cancelation_time` | Epoch timestamp for cancelation. | `int8` | Yes | No | - | - |
| `cancellation_reason` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `cancelation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `cancelation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `conflict` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `last_participation_seq` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `queue_run_time` | Epoch timestamp for queue run. | `int8` | Yes | No | - | - |
| `queue_run_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - |
| `queue_run_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - |
| `class_capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `waiting_list_capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `maximum_sub_staff_usages` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `activity` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`activity` -> `id`) | - |
| `main_booking_center` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - |
| `main_booking_id` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - |
| `recurrence_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `recurrence_data` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `recurrence_end` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `recurrence_for` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `recurrence_at_planned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `colour_group_id` | Identifier of the related colour group record. | `int4` | Yes | No | - | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) |
| `booking_program_id` | Foreign key field linking this record to `booking_programs`. | `int4` | Yes | No | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) | - |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(200)` | Yes | No | - | - |
| `deadline_showup_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `available_for_substitution` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `one_off_cancellation` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `min_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `max_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `min_age_strict` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `not_shown_notification_sent` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `streaming_id` | Identifier of the related streaming record. | `VARCHAR(2000)` | Yes | No | - | - |
| `additional_info` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `main_preparation_booking_id` | Identifier of the related main preparation booking record. | `int4` | Yes | No | - | - |
| `main_preparation_booking_center` | Center part of the reference to related main preparation booking data. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [participations](participations.md) (481 query files), [activity](activity.md) (476 query files), [persons](persons.md) (476 query files), [centers](centers.md) (467 query files), [staff_usage](staff_usage.md) (250 query files), [activity_group](activity_group.md) (204 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [centers](centers.md), [persons](persons.md); incoming FK from [booking_change](booking_change.md), [booking_program_standby](booking_program_standby.md), [booking_resource_usage](booking_resource_usage.md), [bookings](bookings.md), [participations](participations.md), [staff_usage](staff_usage.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_program_types](booking_program_types.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
