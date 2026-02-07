# participation_configurations
Configuration table for participation configurations behavior and defaults. It is typically used where it appears in approximately 26 query files; common companions include [activity](activity.md), [activity_group](activity_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `activity_id` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `excluzive` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `ordinal` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `min_participants_at_creation` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `max_participants_at_creation` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `minimum_showups` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `max_participants_absolute` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `max_participants_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `access_group_id` | Foreign key field linking this record to `booking_privilege_groups`. | `int4` | Yes | No | [booking_privilege_groups](booking_privilege_groups.md) via (`access_group_id` -> `id`) | - |
| `owner_participation` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `participate_in_all_recurring` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `privilege_at_showup_client` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `privilege_at_showup_kiosk` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `privilege_at_showup_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (25 query files), [activity_group](activity_group.md) (18 query files), [colour_groups](colour_groups.md) (15 query files), [booking_privilege_groups](booking_privilege_groups.md) (14 query files), [activity_staff_configurations](activity_staff_configurations.md) (11 query files), [activity_resource_configs](activity_resource_configs.md) (9 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_privilege_groups](booking_privilege_groups.md); incoming FK from [participations](participations.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_privileges](booking_privileges.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_resources](booking_resources.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md).
