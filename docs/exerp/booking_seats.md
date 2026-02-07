# booking_seats
Operational table for booking seats records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 8 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `resource_center` | Center part of the reference to related resource data. | `int4` | No | No | - | - |
| `resource_id` | Identifier of the related resource record. | `int4` | No | No | - | - |
| `x` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `y` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (7 query files), [centers](centers.md) (6 query files), [participations](participations.md) (6 query files), [bookings](bookings.md) (5 query files), [activity](activity.md) (3 query files), [booking_resource_configs](booking_resource_configs.md) (2 query files).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
