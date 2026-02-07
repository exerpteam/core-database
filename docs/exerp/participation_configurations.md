# participation_configurations
Configuration table for participation configurations behavior and defaults. It is typically used where it appears in approximately 26 query files; common companions include [activity](activity.md), [activity_group](activity_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `activity_id` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `excluzive` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `ordinal` | Business attribute `ordinal` used by participation configurations workflows and reporting. | `int4` | No | No | - | - |
| `min_participants_at_creation` | Business attribute `min_participants_at_creation` used by participation configurations workflows and reporting. | `int4` | No | No | - | - |
| `max_participants_at_creation` | Business attribute `max_participants_at_creation` used by participation configurations workflows and reporting. | `int4` | Yes | No | - | - |
| `minimum_showups` | Business attribute `minimum_showups` used by participation configurations workflows and reporting. | `int4` | No | No | - | - |
| `max_participants_absolute` | Business attribute `max_participants_absolute` used by participation configurations workflows and reporting. | `int4` | Yes | No | - | - |
| `max_participants_percentage` | Business attribute `max_participants_percentage` used by participation configurations workflows and reporting. | `int4` | Yes | No | - | - |
| `access_group_id` | Identifier of the related booking privilege groups record used by this row. | `int4` | Yes | No | [booking_privilege_groups](booking_privilege_groups.md) via (`access_group_id` -> `id`) | - |
| `owner_participation` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `participate_in_all_recurring` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `privilege_at_showup_client` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `privilege_at_showup_kiosk` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `privilege_at_showup_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (25 query files), [activity_group](activity_group.md) (18 query files), [colour_groups](colour_groups.md) (15 query files), [booking_privilege_groups](booking_privilege_groups.md) (14 query files), [activity_staff_configurations](activity_staff_configurations.md) (11 query files), [activity_resource_configs](activity_resource_configs.md) (9 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_privilege_groups](booking_privilege_groups.md); incoming FK from [participations](participations.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_privileges](booking_privileges.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_resources](booking_resources.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md).
