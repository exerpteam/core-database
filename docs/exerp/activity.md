# activity
Operational table for activity records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 548 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `availability` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - | `Sample value` |
| `activity_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `activity_group_id` | Identifier of the related activity group record. | `int4` | Yes | No | - | [activity_group](activity_group.md) via (`activity_group_id` -> `id`) | `1001` |
| `colour_group_id` | Identifier of the related colour group record. | `int4` | Yes | No | - | [colour_groups](colour_groups.md) via (`colour_group_id` -> `id`) | `1001` |
| `creation_privilege_group_id` | Identifier of the related creation privilege group record. | `int4` | Yes | No | - | - | `1001` |
| `duration_list` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `description_mime_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `description_mime_document` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `max_participants` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `max_waiting_list_participants` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `requires_planning` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `allow_name_override` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `allow_recurring_bookings` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `maximum_sub_staff_usages` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `override_resource_configs` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `override_staff_configs` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `override_participation_configs` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `override_time_config` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `time_config_id` | Foreign key field linking this record to `booking_time_configs`. | `int4` | Yes | No | [booking_time_configs](booking_time_configs.md) via (`time_config_id` -> `id`) | - | `1001` |
| `sub_staff_usage_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `energy_consumption_kcal_hour` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `lessons` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `age_group_id` | Identifier of the related age group record. | `int4` | Yes | No | - | [age_groups](age_groups.md) via (`age_group_id` -> `id`) | `1001` |
| `course_type_id` | Identifier of the related course type record. | `int4` | Yes | No | - | - | `1001` |
| `course_level_id` | Identifier of the related course level record. | `int4` | Yes | No | - | - | `1001` |
| `seat_booking_support_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `headcount_manual_adjustment` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `available_from` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `available_to` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `course_schedule_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `print_showup_receipt` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `allow_overlapping_bookings` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `age_restriction_on_bookings` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `allow_multiple_camps` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `enable_streaming_id` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `documentation_setting_id` | Identifier of the related documentation setting record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) | `1001` |
| `additional_info` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `set_up_activity_id` | Identifier of the related set up activity record. | `int4` | Yes | No | - | - | `1001` |
| `set_up_mandatory` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `dismantling_activity_id` | Identifier of the related dismantling activity record. | `int4` | Yes | No | - | - | `1001` |
| `dismantling_mandatory` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |

# Relations
- Commonly used with: [bookings](bookings.md) (476 query files), [persons](persons.md) (415 query files), [centers](centers.md) (401 query files), [participations](participations.md) (396 query files), [staff_usage](staff_usage.md) (232 query files), [activity_group](activity_group.md) (231 query files).
- FK-linked tables: outgoing FK to [booking_time_configs](booking_time_configs.md); incoming FK from [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Second-level FK neighborhood includes: [booking_change](booking_change.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_standby](booking_program_standby.md), [booking_program_types](booking_program_types.md), [booking_resource_usage](booking_resource_usage.md), [centers](centers.md), [participations](participations.md), [persons](persons.md), [recurring_participations](recurring_participations.md), [semesters](semesters.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
