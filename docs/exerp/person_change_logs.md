# person_change_logs
Stores historical/log records for person changes events and changes. It is typically used where it appears in approximately 126 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | - | - |
| `previous_entry_id` | Identifier for the related previous entry entity used by this record. | `int4` | Yes | No | - | - |
| `change_source` | Business attribute `change_source` used by person change logs workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `change_attribute` | Operational field `change_attribute` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `new_value` | Operational field `new_value` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `login_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (119 query files), [centers](centers.md) (81 query files), [person_ext_attrs](person_ext_attrs.md) (67 query files), [subscriptions](subscriptions.md) (51 query files), [products](products.md) (39 query files), [account_receivables](account_receivables.md) (33 query files).
