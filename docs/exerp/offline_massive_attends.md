# offline_massive_attends
Operational table for offline massive attends records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Center part of the reference to related person data. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | No | No | - | - | `1001` |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `resource_center` | Center part of the reference to related resource data. | `int4` | No | No | - | - | `101` |
| `resource_id` | Identifier of the related resource record. | `int4` | No | No | - | - | `1001` |
| `identity_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
