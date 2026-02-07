# preferred_centers
Operational table for preferred centers records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `person_center` | Center part of the reference to related person data. | `int4` | No | Yes | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | No | Yes | - | - |
| `preferred_center` | Center part of the reference to related preferred data. | `int4` | No | Yes | - | - |

# Relations
