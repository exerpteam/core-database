# booking_seats
Operational table for booking seats records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 8 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `resource_center` | Center part of the reference to related resource data. | `int4` | No | No | - | - | `101` |
| `resource_id` | Identifier of the related resource record. | `int4` | No | No | - | - | `1001` |
| `x` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `y` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |

# Relations
- Commonly used with: [persons](persons.md) (7 query files), [centers](centers.md) (6 query files), [participations](participations.md) (6 query files), [bookings](bookings.md) (5 query files), [activity](activity.md) (3 query files), [booking_resource_configs](booking_resource_configs.md) (2 query files).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
