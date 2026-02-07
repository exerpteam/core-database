# substitution_person_cases
People-related master or relationship table for substitution person cases data. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `substitute_center` | Center component of the composite reference to the related substitute record. | `int4` | Yes | No | - | - |
| `substitute_id` | Identifier component of the composite reference to the related substitute record. | `int4` | Yes | No | - | - |
| `e_mailed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `sms_ed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `mobiled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `phoned` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `answer` | Business attribute `answer` used by substitution person cases workflows and reporting. | `int4` | No | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
