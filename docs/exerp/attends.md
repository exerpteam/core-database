# attends
Operational table for attends records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 219 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `attend_using_card` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `booking_resource_center` | Center component of the composite reference to the related booking resource record. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `booking_resource_id` | Identifier component of the composite reference to the related booking resource record. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `origin` | Business attribute `origin` used by attends workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (179 query files), [centers](centers.md) (149 query files), [booking_resources](booking_resources.md) (115 query files), [subscriptions](subscriptions.md) (89 query files), [products](products.md) (77 query files), [person_ext_attrs](person_ext_attrs.md) (68 query files).
- FK-linked tables: outgoing FK to [booking_resources](booking_resources.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
