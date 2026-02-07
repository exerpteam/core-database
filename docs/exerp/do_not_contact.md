# do_not_contact
Operational table for do not contact records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `target` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `creation_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `target_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `source` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `origin_file` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `deletion_file` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `creation_date` | Date for creation. | `DATE` | Yes | No | - | - |
| `deletion_date` | Date for deletion. | `DATE` | Yes | No | - | - |
| `creation_employee_center` | Center part of the reference to related creation employee data. | `int4` | Yes | No | - | - |
| `creation_employee_id` | Identifier of the related creation employee record. | `int4` | Yes | No | - | - |
| `deletion_employee_center` | Center part of the reference to related deletion employee data. | `int4` | Yes | No | - | - |
| `deletion_employee_id` | Identifier of the related deletion employee record. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
