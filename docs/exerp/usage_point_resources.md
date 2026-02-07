# usage_point_resources
Operational table for usage point resources records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 6 query files; common companions include [usage_points](usage_points.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `usage_point_center` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `usage_point_id` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `resource_order` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `resource_usage` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `gate_center` | Foreign key field linking this record to `gates`. | `int4` | Yes | No | [gates](gates.md) via (`gate_center`, `gate_id` -> `center`, `id`) | - |
| `gate_id` | Foreign key field linking this record to `gates`. | `int4` | Yes | No | [gates](gates.md) via (`gate_center`, `gate_id` -> `center`, `id`) | - |
| `check_out` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `handback_check` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `only_accessible` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `print_ticket` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `auto_execution_kiosk` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `shortcut_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `block_unsigned_documents` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `block_incomplete_agreement` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `no_reentry_before_checkout` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `no_check_in` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `exit_previous_attend` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `exit_resource_center` | Center part of the reference to related exit resource data. | `int4` | Yes | No | - | - |
| `exit_resource_id` | Identifier of the related exit resource record. | `int4` | Yes | No | - | - |
| `block_expired_hc` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `notify_on_access_error` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `enter_attend_duration` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `show_attendance_history` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [usage_points](usage_points.md) (6 query files), [centers](centers.md) (5 query files), [devices](devices.md) (5 query files), [clients](clients.md) (4 query files), [booking_resources](booking_resources.md) (4 query files), [usage_point_action_res_link](usage_point_action_res_link.md) (4 query files).
- FK-linked tables: outgoing FK to [gates](gates.md), [usage_points](usage_points.md); incoming FK from [usage_point_action_res_link](usage_point_action_res_link.md), [usage_point_usages](usage_point_usages.md).
- Second-level FK neighborhood includes: [access_code](access_code.md), [booking_resources](booking_resources.md), [devices](devices.md), [persons](persons.md), [usage_point_sources](usage_point_sources.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
