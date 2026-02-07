# invoice_sales_employee
Financial/transactional table for invoice sales employee records. It is typically used where it appears in approximately 27 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `invoice_id` | Identifier of the related invoice record. | `int4` | No | No | - | - |
| `invoice_center` | Center part of the reference to related invoice data. | `int4` | No | No | - | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) |
| `sales_employee_id` | Identifier of the related sales employee record. | `int4` | No | No | - | - |
| `sales_employee_center` | Center part of the reference to related sales employee data. | `int4` | No | No | - | - |
| `change_employee_id` | Identifier of the related change employee record. | `int4` | No | No | - | - |
| `change_employee_center` | Center part of the reference to related change employee data. | `int4` | No | No | - | - |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [employees](employees.md) (27 query files), [persons](persons.md) (27 query files), [centers](centers.md) (19 query files), [products](products.md) (19 query files), [invoice_lines_mt](invoice_lines_mt.md) (16 query files), [invoices](invoices.md) (15 query files).
