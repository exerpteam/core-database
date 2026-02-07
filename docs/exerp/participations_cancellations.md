# participations_cancellations
Operational table for participations cancellations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `participation_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | [participations](participations.md) via (`participation_center`, `participation_id` -> `center`, `id`) |
| `participation_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `cancellation_processed_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancellation_processed_result` | Business attribute `cancellation_processed_result` used by participations cancellations workflows and reporting. | `int4` | No | No | - | - |

# Relations
