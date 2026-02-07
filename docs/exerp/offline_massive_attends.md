# offline_massive_attends
Operational table for offline massive attends records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | - | - |
| `TIMESTAMP` | Operational field `TIMESTAMP` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `resource_center` | Center component of the composite reference to the related resource record. | `int4` | No | No | - | - |
| `resource_id` | Identifier component of the composite reference to the related resource record. | `int4` | No | No | - | - |
| `identity_method` | Business attribute `identity_method` used by offline massive attends workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
