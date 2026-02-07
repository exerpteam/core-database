# booking_partic_counts_cache
Intermediate/cache table used to accelerate booking partic counts cache processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `booking_center` | Center part of the reference to related booking data. | `int4` | No | Yes | - | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) |
| `booking_id` | Identifier of the related booking record. | `int4` | No | Yes | - | - |
| `showups` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `on_normal_list` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `on_waiting_list` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `participating` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `seats_booked` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
