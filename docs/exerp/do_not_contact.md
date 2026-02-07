# do_not_contact
Operational table for do not contact records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `target` | Operational field `target` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `creation_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `target_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `source` | Operational field `source` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `origin_file` | Business attribute `origin_file` used by do not contact workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `deletion_file` | Business attribute `deletion_file` used by do not contact workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `creation_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `deletion_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `creation_employee_center` | Center component of the composite reference to the related creation employee record. | `int4` | Yes | No | - | - |
| `creation_employee_id` | Identifier component of the composite reference to the related creation employee record. | `int4` | Yes | No | - | - |
| `deletion_employee_center` | Center component of the composite reference to the related deletion employee record. | `int4` | Yes | No | - | - |
| `deletion_employee_id` | Identifier component of the composite reference to the related deletion employee record. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
