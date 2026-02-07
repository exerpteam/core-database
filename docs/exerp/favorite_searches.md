# favorite_searches
Operational table for favorite searches records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | No | No | - | - |
| `person_center` | Center part of the reference to related person data. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | No | No | - | - |
| `mimetype` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | No | - | - |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - |

# Relations
