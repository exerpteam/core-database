# preferred_centers
Operational table for preferred centers records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `person_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `preferred_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |

# Relations
