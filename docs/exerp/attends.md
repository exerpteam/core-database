# attends
Operational table for attends records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 219 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - | `1738281600000` |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - | `1738281600000` |
| `attend_using_card` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `booking_resource_center` | Foreign key field linking this record to `booking_resources`. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - | `101` |
| `booking_resource_id` | Foreign key field linking this record to `booking_resources`. | `int4` | No | No | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | `101` |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - | `1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `origin` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [persons](persons.md) (179 query files), [centers](centers.md) (149 query files), [booking_resources](booking_resources.md) (115 query files), [subscriptions](subscriptions.md) (89 query files), [products](products.md) (77 query files), [person_ext_attrs](person_ext_attrs.md) (68 query files).
- FK-linked tables: outgoing FK to [booking_resources](booking_resources.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
