# booking_program_type_activity
Operational table for booking program type activity records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `booking_program_type_id` | Identifier of the related booking program types record used by this row. | `int4` | No | No | [booking_program_types](booking_program_types.md) via (`booking_program_type_id` -> `id`) | - |
| `activity_id` | Identifier of the related activity record used by this row. | `int4` | No | No | [activity](activity.md) via (`activity_id` -> `id`) | - |
| `product_global_id` | Identifier for the related product global entity used by this record. | `VARCHAR(30)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_program_types](booking_program_types.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_levels](booking_program_levels.md), [booking_programs](booking_programs.md), [booking_time_configs](booking_time_configs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
