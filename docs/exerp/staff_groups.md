# staff_groups
People-related master or relationship table for staff groups data. It is typically used where lifecycle state codes are present; it appears in approximately 90 query files; common companions include [persons](persons.md), [person_staff_groups](person_staff_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `default_salary` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `old_activity_type_id` | Identifier of the related old activity type record. | `int4` | Yes | No | - | - | `1001` |
| `external_reference` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Sample value` |
| `commissionable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [persons](persons.md) (60 query files), [person_staff_groups](person_staff_groups.md) (59 query files), [activity](activity.md) (53 query files), [activity_staff_configurations](activity_staff_configurations.md) (51 query files), [activity_group](activity_group.md) (44 query files), [centers](centers.md) (44 query files).
- FK-linked tables: incoming FK from [activity_staff_configurations](activity_staff_configurations.md), [person_staff_groups](person_staff_groups.md).
- Second-level FK neighborhood includes: [activity](activity.md), [persons](persons.md), [staff_usage](staff_usage.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
