# substitution_cases
Operational table for substitution cases records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `booking_center` | Center component of the composite reference to the related booking record. | `int4` | Yes | No | - | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) |
| `booking_id` | Identifier component of the composite reference to the related booking record. | `int4` | Yes | No | - | - |
| `closed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `absentee_center` | Center component of the composite reference to the related absentee record. | `int4` | Yes | No | - | - |
| `absentee_id` | Identifier component of the composite reference to the related absentee record. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
