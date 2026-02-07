# booking_program_type_activity
Operational table for booking program type activity records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `booking_program_type_id` | Foreign key field linking this record to `booking_program_types`. | `int4` | No | No | [booking_program_types](booking_program_types.md) via (`booking_program_type_id` -> `id`) | - | `1001` |
| `activity_id` | Foreign key field linking this record to `activity`. | `int4` | No | No | [activity](activity.md) via (`activity_id` -> `id`) | - | `1001` |
| `product_global_id` | Identifier of the related product global record. | `VARCHAR(30)` | Yes | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `VARCHAR(10)` | No | No | - | - | `1` |

# Relations
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_program_types](booking_program_types.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_levels](booking_program_levels.md), [booking_programs](booking_programs.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
