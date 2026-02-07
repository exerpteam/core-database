# booking_attend
Operational table for booking attend records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | No | No | - | - |
| `checkin_log_id` | Identifier of the related checkin log record. | `int4` | No | No | - | - |
| `participation_center` | Center part of the reference to related participation data. | `int4` | No | No | - | [participations](participations.md) via (`participation_center`, `participation_id` -> `center`, `id`) |
| `participation_id` | Identifier of the related participation record. | `int4` | No | No | - | - |

# Relations
