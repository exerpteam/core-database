# booking_program_types
Operational table for booking program types records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 7 query files; common companions include [booking_programs](booking_programs.md), [bookings](bookings.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `VARCHAR(10)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `VARCHAR(2000)` | Yes | No | - | - |
| `time_config_id` | Identifier of the related booking time configs record used by this row. | `int4` | Yes | No | [booking_time_configs](booking_time_configs.md) via (`time_config_id` -> `id`) | - |
| `age_group_id` | Identifier for the related age group entity used by this record. | `int4` | Yes | No | - | [age_groups](age_groups.md) via (`age_group_id` -> `id`) |
| `single_days_booking_enabled` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `single_days_from_unit` | Business attribute `single_days_from_unit` used by booking program types workflows and reporting. | `int4` | Yes | No | - | - |
| `single_days_from_value` | Business attribute `single_days_from_value` used by booking program types workflows and reporting. | `int4` | Yes | No | - | - |
| `availability` | Operational field `availability` used in query filtering and reporting transformations. | `VARCHAR(2000)` | Yes | No | - | - |
| `definition_key` | Operational field `definition_key` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `override_name` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_age_group_id` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_single_days_config` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `full_camp_product_global_id` | Identifier for the related full camp product global entity used by this record. | `VARCHAR(30)` | Yes | No | - | - |
| `documentation_setting_id` | Identifier for the related documentation setting entity used by this record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) |
| `standby_list_size` | Business attribute `standby_list_size` used by booking program types workflows and reporting. | `int4` | Yes | No | - | - |
| `available_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `override_available_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [booking_programs](booking_programs.md) (5 query files), [bookings](bookings.md) (4 query files), [centers](centers.md) (4 query files), [participations](participations.md) (4 query files), [persons](persons.md) (4 query files), [activity](activity.md) (4 query files).
- FK-linked tables: outgoing FK to [booking_time_configs](booking_time_configs.md); incoming FK from [booking_program_levels](booking_program_levels.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md).
- Second-level FK neighborhood includes: [activity](activity.md), [booking_program_skills](booking_program_skills.md), [bookings](bookings.md), [recurring_participations](recurring_participations.md), [semesters](semesters.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
