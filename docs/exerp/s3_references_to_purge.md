# s3_references_to_purge
Operational table for s3 references to purge records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `s3bucket` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | Yes | - | - |
| `s3key` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | No | Yes | - | - |
| `entity` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | No | - | - |
| `deleted_in_s3` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `deleted_in_db` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
