# bookings
Operational table for bookings records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 608 query files; common companions include [participations](participations.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `stoptime` | Operational field `stoptime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | [persons](persons.md) via (`creator_center`, `creator_id` -> `center`, `id`) | - |
| `activation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `activation_by_center` | Center component of the composite reference to the related activation by record. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - |
| `activation_by_id` | Identifier component of the composite reference to the related activation by record. | `int4` | Yes | No | [persons](persons.md) via (`activation_by_center`, `activation_by_id` -> `center`, `id`) | - |
| `cancelation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancellation_reason` | Business attribute `cancellation_reason` used by bookings workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `cancelation_by_center` | Center component of the composite reference to the related cancelation by record. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `cancelation_by_id` | Identifier component of the composite reference to the related cancelation by record. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `conflict` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `last_participation_seq` | Business attribute `last_participation_seq` used by bookings workflows and reporting. | `int4` | Yes | No | - | - |
| `queue_run_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `queue_run_by_center` | Center component of the composite reference to the related queue run by record. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - |
| `queue_run_by_id` | Identifier component of the composite reference to the related queue run by record. | `int4` | Yes | No | [persons](persons.md) via (`queue_run_by_center`, `queue_run_by_id` -> `center`, `id`) | - |
| `class_capacity` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `waiting_list_capacity` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `maximum_sub_staff_usages` | Business attribute `maximum_sub_staff_usages` used by bookings workflows and reporting. | `int4` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `activity` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`activity` -> `id`) | - |
| `main_booking_center` | Center component of the composite reference to the related main booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - |
| `main_booking_id` | Identifier component of the composite reference to the related main booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`main_booking_center`, `main_booking_id` -> `center`, `id`) | - |
| `recurrence_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `recurrence_data` | Business attribute `recurrence_data` used by bookings workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `recurrence_end` | Business attribute `recurrence_end` used by bookings workflows and reporting. | `DATE` | Yes | No | - | - |
| `recurrence_for` | Business attribute `recurrence_for` used by bookings workflows and reporting. | `DATE` | Yes | No | - | - |
| `recurrence_at_planned` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `colour_group_id` | Identifier for the related colour group entity used by this record. | `int4` | Yes | No | - | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) |
| `booking_program_id` | Identifier of the related booking programs record used by this row. | `int4` | Yes | No | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(200)` | Yes | No | - | - |
| `deadline_showup_percentage` | Business attribute `deadline_showup_percentage` used by bookings workflows and reporting. | `int4` | Yes | No | - | - |
| `available_for_substitution` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `one_off_cancellation` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `min_age` | Business attribute `min_age` used by bookings workflows and reporting. | `int4` | Yes | No | - | - |
| `max_age` | Business attribute `max_age` used by bookings workflows and reporting. | `int4` | Yes | No | - | - |
| `min_age_strict` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `not_shown_notification_sent` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `streaming_id` | Identifier for the related streaming entity used by this record. | `VARCHAR(2000)` | Yes | No | - | - |
| `additional_info` | Business attribute `additional_info` used by bookings workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `main_preparation_booking_id` | Identifier component of the composite reference to the related main preparation booking record. | `int4` | Yes | No | - | - |
| `main_preparation_booking_center` | Center component of the composite reference to the related main preparation booking record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [participations](participations.md) (481 query files), [activity](activity.md) (476 query files), [persons](persons.md) (476 query files), [centers](centers.md) (467 query files), [staff_usage](staff_usage.md) (250 query files), [activity_group](activity_group.md) (204 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [centers](centers.md), [persons](persons.md); incoming FK from [booking_change](booking_change.md), [booking_program_standby](booking_program_standby.md), [booking_resource_usage](booking_resource_usage.md), [bookings](bookings.md), [participations](participations.md), [staff_usage](staff_usage.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_program_types](booking_program_types.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
