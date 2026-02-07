# center_capacities
Operational table for center capacities records in the Exerp schema. It is typically used where it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `checked_in_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `reserved_spots` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
