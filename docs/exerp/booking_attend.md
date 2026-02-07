# booking_attend
Operational table for booking attend records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier for this record. | `int4` | No | No | - | - |
| `checkin_log_id` | Identifier for the related checkin log entity used by this record. | `int4` | No | No | - | - |
| `participation_center` | Center component of the composite reference to the related participation record. | `int4` | No | No | - | [participations](participations.md) via (`participation_center`, `participation_id` -> `center`, `id`) |
| `participation_id` | Identifier component of the composite reference to the related participation record. | `int4` | No | No | - | - |

# Relations
