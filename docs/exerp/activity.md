# activity
Operational table for activity records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 548 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `availability` | Operational field `availability` used in query filtering and reporting transformations. | `VARCHAR(2000)` | Yes | No | - | - |
| `activity_type` | Classification code describing the activity type category (for example: CAMP_PROGRAM, ChildCare, Class, General). | `int4` | No | No | - | - |
| `activity_group_id` | Identifier for the related activity group entity used by this record. | `int4` | Yes | No | - | [activity_group](activity_group.md) via (`activity_group_id` -> `id`) |
| `colour_group_id` | Identifier for the related colour group entity used by this record. | `int4` | Yes | No | - | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) |
| `creation_privilege_group_id` | Identifier for the related creation privilege group entity used by this record. | `int4` | Yes | No | - | - |
| `duration_list` | Business attribute `duration_list` used by activity workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `description_mime_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `description_mime_document` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `max_participants` | Operational field `max_participants` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `max_waiting_list_participants` | Business attribute `max_waiting_list_participants` used by activity workflows and reporting. | `int4` | Yes | No | - | - |
| `requires_planning` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `allow_name_override` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `allow_recurring_bookings` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `maximum_sub_staff_usages` | Business attribute `maximum_sub_staff_usages` used by activity workflows and reporting. | `int4` | Yes | No | - | - |
| `override_resource_configs` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_staff_configs` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_participation_configs` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_time_config` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `time_config_id` | Identifier of the related booking time configs record used by this row. | `int4` | Yes | No | [booking_time_configs](booking_time_configs.md) via (`time_config_id` -> `id`) | - |
| `sub_staff_usage_interval` | Business attribute `sub_staff_usage_interval` used by activity workflows and reporting. | `int4` | Yes | No | - | - |
| `energy_consumption_kcal_hour` | Business attribute `energy_consumption_kcal_hour` used by activity workflows and reporting. | `int4` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `lessons` | Business attribute `lessons` used by activity workflows and reporting. | `int4` | Yes | No | - | - |
| `age_group_id` | Identifier for the related age group entity used by this record. | `int4` | Yes | No | - | [age_groups](age_groups.md) via (`age_group_id` -> `id`) |
| `course_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `course_level_id` | Identifier for the related course level entity used by this record. | `int4` | Yes | No | - | - |
| `seat_booking_support_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `headcount_manual_adjustment` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `available_from` | Business attribute `available_from` used by activity workflows and reporting. | `DATE` | Yes | No | - | - |
| `available_to` | Business attribute `available_to` used by activity workflows and reporting. | `DATE` | Yes | No | - | - |
| `course_schedule_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `print_showup_receipt` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `allow_overlapping_bookings` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `age_restriction_on_bookings` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `allow_multiple_camps` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `enable_streaming_id` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `documentation_setting_id` | Identifier for the related documentation setting entity used by this record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) |
| `additional_info` | Business attribute `additional_info` used by activity workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `set_up_activity_id` | Identifier for the related set up activity entity used by this record. | `int4` | Yes | No | - | - |
| `set_up_mandatory` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `dismantling_activity_id` | Identifier for the related dismantling activity entity used by this record. | `int4` | Yes | No | - | - |
| `dismantling_mandatory` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (476 query files), [persons](persons.md) (415 query files), [centers](centers.md) (401 query files), [participations](participations.md) (396 query files), [staff_usage](staff_usage.md) (232 query files), [activity_group](activity_group.md) (231 query files).
- FK-linked tables: outgoing FK to [booking_time_configs](booking_time_configs.md); incoming FK from [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Second-level FK neighborhood includes: [booking_change](booking_change.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_standby](booking_program_standby.md), [booking_program_types](booking_program_types.md), [booking_resource_usage](booking_resource_usage.md), [centers](centers.md), [participations](participations.md), [persons](persons.md), [recurring_participations](recurring_participations.md), [semesters](semesters.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
