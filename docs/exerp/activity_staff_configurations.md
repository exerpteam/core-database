# activity_staff_configurations
Configuration table for activity staff configurations behavior and defaults. It is typically used where it appears in approximately 59 query files; common companions include [activity](activity.md), [staff_groups](staff_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `activity_id` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `excluzive` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `staff_group_id` | Identifier of the related staff groups record used by this row. | `int4` | Yes | No | [staff_groups](staff_groups.md) via (`staff_group_id` -> `id`) | - |
| `minimum_staffs` | Business attribute `minimum_staffs` used by activity staff configurations workflows and reporting. | `int4` | No | No | - | - |
| `maximum_staffs` | Business attribute `maximum_staffs` used by activity staff configurations workflows and reporting. | `int4` | No | No | - | - |
| `staff_anonymity` | Business attribute `staff_anonymity` used by activity staff configurations workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `parent_activity_id` | Identifier of the related activity record used by this row. | `int4` | Yes | No | [activity](activity.md) via (`parent_activity_id` -> `id`) | - |

# Relations
- Commonly used with: [activity](activity.md) (58 query files), [staff_groups](staff_groups.md) (51 query files), [activity_group](activity_group.md) (48 query files), [persons](persons.md) (39 query files), [bookings](bookings.md) (38 query files), [staff_usage](staff_usage.md) (38 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [staff_groups](staff_groups.md); incoming FK from [staff_usage](staff_usage.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md), [person_staff_groups](person_staff_groups.md), [persons](persons.md).
