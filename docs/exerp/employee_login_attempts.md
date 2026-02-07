# employee_login_attempts
Stores historical/log records for employeein attempts events and changes. It is typically used where it appears in approximately 3 query files; common companions include [employees](employees.md), [person_ext_attrs](person_ext_attrs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `employee_center` | Center part of the reference to related employee data. | `int4` | No | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | `101` |
| `employee_id` | Identifier of the related employee record. | `int4` | No | No | - | - | `1001` |
| `client_instance` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `success` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `ignore` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [employees](employees.md) (3 query files), [person_ext_attrs](person_ext_attrs.md) (2 query files).
