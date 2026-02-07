# offline_massive_attends
Operational table for offline massive attends records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `person_center` | Center part of the reference to related person data. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | No | No | - | - |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `resource_center` | Center part of the reference to related resource data. | `int4` | No | No | - | - |
| `resource_id` | Identifier of the related resource record. | `int4` | No | No | - | - |
| `identity_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
