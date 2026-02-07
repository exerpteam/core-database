# s3_references_to_purge
Operational table for s3 references to purge records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `s3bucket` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | Yes | - | - | `Sample value` |
| `s3key` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | No | Yes | - | - | `Sample value` |
| `entity` | Text field containing descriptive or reference information. | `VARCHAR(64)` | No | No | - | - | `Sample value` |
| `deleted_in_s3` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `deleted_in_db` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - | `1` |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
