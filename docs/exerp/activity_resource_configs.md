# activity_resource_configs
Configuration table for activity resource configs behavior and defaults. It is typically used where it appears in approximately 25 query files; common companions include [activity](activity.md), [booking_resource_groups](booking_resource_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `activity_id` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `booking_resource_group_id` | Identifier of the related booking resource group record. | `int4` | Yes | No | - | [booking_resource_groups](booking_resource_groups.md) via (`booking_resource_group_id` -> `id`) |
| `parent_activity_key` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`parent_activity_key` -> `id`) | - |
| `resource_group_selection` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (24 query files), [booking_resource_groups](booking_resource_groups.md) (20 query files), [activity_group](activity_group.md) (18 query files), [centers](centers.md) (14 query files), [colour_groups](colour_groups.md) (12 query files), [booking_resource_configs](booking_resource_configs.md) (12 query files).
- FK-linked tables: outgoing FK to [activity](activity.md); incoming FK from [booking_resource_usage](booking_resource_usage.md).
- Second-level FK neighborhood includes: [activity_staff_configurations](activity_staff_configurations.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_resources](booking_resources.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
