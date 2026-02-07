# substitution_person_cases
People-related master or relationship table for substitution person cases data. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `substitute_center` | Center part of the reference to related substitute data. | `int4` | Yes | No | - | - |
| `substitute_id` | Identifier of the related substitute record. | `int4` | Yes | No | - | - |
| `e_mailed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `sms_ed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `mobiled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `phoned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `answer` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
