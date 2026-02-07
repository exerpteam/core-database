# employee_login_attempts
Stores historical/log records for employeein attempts events and changes. It is typically used where it appears in approximately 3 query files; common companions include [employees](employees.md), [person_ext_attrs](person_ext_attrs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | - | - |
| `client_instance` | Business attribute `client_instance` used by employee login attempts workflows and reporting. | `int4` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `success` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `ignore` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [employees](employees.md) (3 query files), [person_ext_attrs](person_ext_attrs.md) (2 query files).
