# booking_partic_counts_cache
Intermediate/cache table used to accelerate booking partic counts cache processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `booking_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) |
| `booking_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `showups` | Business attribute `showups` used by booking partic counts cache workflows and reporting. | `int4` | No | No | - | - |
| `on_normal_list` | Business attribute `on_normal_list` used by booking partic counts cache workflows and reporting. | `int4` | No | No | - | - |
| `on_waiting_list` | Operational field `on_waiting_list` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `participating` | Business attribute `participating` used by booking partic counts cache workflows and reporting. | `int4` | Yes | No | - | - |
| `seats_booked` | Business attribute `seats_booked` used by booking partic counts cache workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
