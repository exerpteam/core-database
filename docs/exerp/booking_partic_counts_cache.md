# booking_partic_counts_cache
Intermediate/cache table used to accelerate booking partic counts cache processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `booking_center` | Center part of the reference to related booking data. | `int4` | No | Yes | - | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | `101` |
| `booking_id` | Identifier of the related booking record. | `int4` | No | Yes | - | - | `1001` |
| `showups` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `on_normal_list` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `on_waiting_list` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `participating` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `seats_booked` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
