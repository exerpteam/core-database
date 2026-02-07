# booking_program_types
Operational table for booking program types records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 7 query files; common companions include [booking_programs](booking_programs.md), [bookings](bookings.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(10)` | Yes | No | - | - |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - |
| `time_config_id` | Foreign key field linking this record to `booking_time_configs`. | `int4` | Yes | No | [booking_time_configs](booking_time_configs.md) via (`time_config_id` -> `id`) | - |
| `age_group_id` | Identifier of the related age group record. | `int4` | Yes | No | - | [age_groups](age_groups.md) via (`age_group_id` -> `id`) |
| `single_days_booking_enabled` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `single_days_from_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `single_days_from_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `availability` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - |
| `definition_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `override_name` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `override_age_group_id` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `override_single_days_config` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `full_camp_product_global_id` | Identifier of the related full camp product global record. | `VARCHAR(30)` | Yes | No | - | - |
| `documentation_setting_id` | Identifier of the related documentation setting record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) |
| `standby_list_size` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `override_available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [booking_programs](booking_programs.md) (5 query files), [bookings](bookings.md) (4 query files), [centers](centers.md) (4 query files), [participations](participations.md) (4 query files), [persons](persons.md) (4 query files), [activity](activity.md) (4 query files).
- FK-linked tables: outgoing FK to [booking_time_configs](booking_time_configs.md); incoming FK from [booking_program_levels](booking_program_levels.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md).
- Second-level FK neighborhood includes: [activity](activity.md), [booking_program_skills](booking_program_skills.md), [bookings](bookings.md), [recurring_participations](recurring_participations.md), [semesters](semesters.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
