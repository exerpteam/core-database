# person_change_logs
Stores historical/log records for person changes events and changes. It is typically used where it appears in approximately 126 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Center part of the reference to related person data. | `int4` | No | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | No | No | - | - | `1001` |
| `previous_entry_id` | Identifier of the related previous entry record. | `int4` | Yes | No | - | - | `1001` |
| `change_source` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `change_attribute` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `new_value` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | `101` |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - | `1001` |
| `login_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [persons](persons.md) (119 query files), [centers](centers.md) (81 query files), [person_ext_attrs](person_ext_attrs.md) (67 query files), [subscriptions](subscriptions.md) (51 query files), [products](products.md) (39 query files), [account_receivables](account_receivables.md) (33 query files).
