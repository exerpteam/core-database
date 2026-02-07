# booking_resource_perspective
Operational table for booking resource perspective records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `center_key` | Business attribute `center_key` used by booking resource perspective workflows and reporting. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `resource_keys` | Business attribute `resource_keys` used by booking resource perspective workflows and reporting. | `text(2147483647)` | No | No | - | - |

# Relations
