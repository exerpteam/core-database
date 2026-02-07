# staff_groups
People-related master or relationship table for staff groups data. It is typically used where lifecycle state codes are present; it appears in approximately 90 query files; common companions include [persons](persons.md), [person_staff_groups](person_staff_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `default_salary` | Business attribute `default_salary` used by staff groups workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `old_activity_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `external_reference` | Business attribute `external_reference` used by staff groups workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `commissionable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (60 query files), [person_staff_groups](person_staff_groups.md) (59 query files), [activity](activity.md) (53 query files), [activity_staff_configurations](activity_staff_configurations.md) (51 query files), [activity_group](activity_group.md) (44 query files), [centers](centers.md) (44 query files).
- FK-linked tables: incoming FK from [activity_staff_configurations](activity_staff_configurations.md), [person_staff_groups](person_staff_groups.md).
- Second-level FK neighborhood includes: [activity](activity.md), [persons](persons.md), [staff_usage](staff_usage.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
