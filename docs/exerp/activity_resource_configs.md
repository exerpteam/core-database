# activity_resource_configs
Configuration table for activity resource configs behavior and defaults. It is typically used where it appears in approximately 25 query files; common companions include [activity](activity.md), [booking_resource_groups](booking_resource_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `activity_id` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `booking_resource_group_id` | Identifier for the related booking resource group entity used by this record. | `int4` | Yes | No | - | [booking_resource_groups](booking_resource_groups.md) via (`booking_resource_group_id` -> `id`) |
| `parent_activity_key` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`parent_activity_key` -> `id`) | - |
| `resource_group_selection` | Business attribute `resource_group_selection` used by activity resource configs workflows and reporting. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (24 query files), [booking_resource_groups](booking_resource_groups.md) (20 query files), [activity_group](activity_group.md) (18 query files), [centers](centers.md) (14 query files), [colour_groups](colour_groups.md) (12 query files), [booking_resource_configs](booking_resource_configs.md) (12 query files).
- FK-linked tables: outgoing FK to [activity](activity.md); incoming FK from [booking_resource_usage](booking_resource_usage.md).
- Second-level FK neighborhood includes: [activity_staff_configurations](activity_staff_configurations.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_resources](booking_resources.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
