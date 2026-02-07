# invoice_sales_employee
Financial/transactional table for invoice sales employee records. It is typically used where it appears in approximately 27 query files; common companions include [employees](employees.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `invoice_id` | Identifier component of the composite reference to the related invoice record. | `int4` | No | No | - | - |
| `invoice_center` | Center component of the composite reference to the related invoice record. | `int4` | No | No | - | [invoices](invoices.md) via (`invoice_center`, `invoice_id` -> `center`, `id`) |
| `sales_employee_id` | Identifier component of the composite reference to the sales staff member. | `int4` | No | No | - | - |
| `sales_employee_center` | Center component of the composite reference to the sales staff member. | `int4` | No | No | - | - |
| `change_employee_id` | Identifier component of the composite reference to the staff member performing the change. | `int4` | No | No | - | - |
| `change_employee_center` | Center component of the composite reference to the staff member performing the change. | `int4` | No | No | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [employees](employees.md) (27 query files), [persons](persons.md) (27 query files), [centers](centers.md) (19 query files), [products](products.md) (19 query files), [invoice_lines_mt](invoice_lines_mt.md) (16 query files), [invoices](invoices.md) (15 query files).
