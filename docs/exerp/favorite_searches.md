# favorite_searches
Operational table for favorite searches records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier for this record. | `int4` | No | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(200)` | No | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |

# Relations
