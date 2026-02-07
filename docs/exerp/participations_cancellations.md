# participations_cancellations
Operational table for participations cancellations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `participation_center` | Center part of the reference to related participation data. | `int4` | No | Yes | - | [participations](participations.md) via (`participation_center`, `participation_id` -> `center`, `id`) | `101` |
| `participation_id` | Identifier of the related participation record. | `int4` | No | Yes | - | - | `1001` |
| `cancellation_processed_time` | Epoch timestamp for cancellation processed. | `int8` | Yes | No | - | - | `1738281600000` |
| `cancellation_processed_result` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
