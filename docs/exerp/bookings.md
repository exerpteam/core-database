# bookings
Operational table for bookings records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 608 query files; common companions include [participations](participations.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `stoptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - | `1738281600000` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `creator_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `101` |
| `creator_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - | `1001` |
| `activation_time` | Epoch timestamp for activation. | `int8` | Yes | No | - | - | `1738281600000` |
| `activation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - | `101` |
| `activation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - | `1001` |
| `cancelation_time` | Epoch timestamp for cancelation. | `int8` | Yes | No | - | - | `1738281600000` |
| `cancellation_reason` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `cancelation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - | `101` |
| `cancelation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `conflict` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `last_participation_seq` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `queue_run_time` | Epoch timestamp for queue run. | `int8` | Yes | No | - | - | `1738281600000` |
| `queue_run_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - | `101` |
| `queue_run_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - | `1001` |
| `class_capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `waiting_list_capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `maximum_sub_staff_usages` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `activity` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`activity` -> `id`) | - | `42` |
| `main_booking_center` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - | `101` |
| `main_booking_id` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - | `1001` |
| `recurrence_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `recurrence_data` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `recurrence_end` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `recurrence_for` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `recurrence_at_planned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `101` |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - | `1001` |
| `colour_group_id` | Identifier of the related colour group record. | `int4` | Yes | No | - | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) | `1001` |
| `booking_program_id` | Foreign key field linking this record to `booking_programs`. | `int4` | Yes | No | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(200)` | Yes | No | - | - | `EXT-1001` |
| `deadline_showup_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `available_for_substitution` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `one_off_cancellation` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `min_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `max_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `min_age_strict` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `not_shown_notification_sent` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `streaming_id` | Identifier of the related streaming record. | `VARCHAR(2000)` | Yes | No | - | - | `1001` |
| `additional_info` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `main_preparation_booking_id` | Identifier of the related main preparation booking record. | `int4` | Yes | No | - | - | `1001` |
| `main_preparation_booking_center` | Center part of the reference to related main preparation booking data. | `int4` | Yes | No | - | - | `101` |

# Relations
- Commonly used with: [participations](participations.md) (481 query files), [activity](activity.md) (476 query files), [persons](persons.md) (476 query files), [centers](centers.md) (467 query files), [staff_usage](staff_usage.md) (250 query files), [activity_group](activity_group.md) (204 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [centers](centers.md), [persons](persons.md); incoming FK from [booking_change](booking_change.md), [booking_program_standby](booking_program_standby.md), [booking_resource_usage](booking_resource_usage.md), [bookings](bookings.md), [participations](participations.md), [staff_usage](staff_usage.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_program_types](booking_program_types.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
