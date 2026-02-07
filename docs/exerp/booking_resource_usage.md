# booking_resource_usage
Operational table for booking resource usage records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 69 query files; common companions include [bookings](bookings.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `booking_resource_center` | Center component of the composite reference to the related booking resource record. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `booking_resource_id` | Identifier component of the composite reference to the related booking resource record. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `booking_center` | Center component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Identifier component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `configuration` | Identifier of the related activity resource configs record used by this row. | `int4` | Yes | No | [activity_resource_configs](activity_resource_configs.md) via (`configuration` -> `id`) | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `stoptime` | Operational field `stoptime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | No | No | - | - |
| `conflict` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `parent_booking_center` | Center component of the composite reference to the related parent booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |
| `parent_booking_id` | Identifier component of the composite reference to the related parent booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |

# Relations
- Commonly used with: [bookings](bookings.md) (67 query files), [activity](activity.md) (63 query files), [booking_resources](booking_resources.md) (62 query files), [centers](centers.md) (57 query files), [participations](participations.md) (49 query files), [activity_group](activity_group.md) (47 query files).
- FK-linked tables: outgoing FK to [activity_resource_configs](activity_resource_configs.md), [booking_resources](booking_resources.md), [bookings](bookings.md).
- Second-level FK neighborhood includes: [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_configs](booking_resource_configs.md), [centers](centers.md), [participations](participations.md), [persons](persons.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
