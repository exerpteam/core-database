# center_capacities
Operational table for center capacities records in the Exerp schema. It is typically used where it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `checked_in_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `reserved_spots` | Business attribute `reserved_spots` used by center capacities workflows and reporting. | `int4` | No | No | - | - |

# Relations
