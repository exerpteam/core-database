# substitution_cases
Operational table for substitution cases records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `booking_center` | Center part of the reference to related booking data. | `int4` | Yes | No | - | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | `101` |
| `booking_id` | Identifier of the related booking record. | `int4` | Yes | No | - | - | `1001` |
| `closed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `absentee_center` | Center part of the reference to related absentee data. | `int4` | Yes | No | - | - | `101` |
| `absentee_id` | Identifier of the related absentee record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
