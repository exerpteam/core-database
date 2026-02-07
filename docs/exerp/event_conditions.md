# event_conditions
Operational table for event conditions records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `POSITION` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `event_configuration_id` | Identifier of the related event configuration record. | `int4` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
