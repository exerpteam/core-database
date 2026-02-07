# do_not_contact
Operational table for do not contact records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `target` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `creation_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `target_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `source` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `origin_file` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `deletion_file` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `creation_date` | Date for creation. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `deletion_date` | Date for deletion. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `creation_employee_center` | Center part of the reference to related creation employee data. | `int4` | Yes | No | - | - | `101` |
| `creation_employee_id` | Identifier of the related creation employee record. | `int4` | Yes | No | - | - | `1001` |
| `deletion_employee_center` | Center part of the reference to related deletion employee data. | `int4` | Yes | No | - | - | `101` |
| `deletion_employee_id` | Identifier of the related deletion employee record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
