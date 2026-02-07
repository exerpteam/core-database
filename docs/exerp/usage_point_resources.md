# usage_point_resources
Operational table for usage point resources records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 6 query files; common companions include [usage_points](usage_points.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `usage_point_center` | Center component of the composite reference to the related usage point record. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `usage_point_id` | Identifier component of the composite reference to the related usage point record. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `resource_order` | Business attribute `resource_order` used by usage point resources workflows and reporting. | `int4` | No | No | - | - |
| `resource_usage` | Business attribute `resource_usage` used by usage point resources workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `gate_center` | Center component of the composite reference to the related gate record. | `int4` | Yes | No | [gates](gates.md) via (`gate_center`, `gate_id` -> `center`, `id`) | - |
| `gate_id` | Identifier component of the composite reference to the related gate record. | `int4` | Yes | No | [gates](gates.md) via (`gate_center`, `gate_id` -> `center`, `id`) | - |
| `check_out` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `handback_check` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `only_accessible` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `print_ticket` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `auto_execution_kiosk` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `shortcut_key` | Business attribute `shortcut_key` used by usage point resources workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `block_unsigned_documents` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `block_incomplete_agreement` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `no_reentry_before_checkout` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `no_check_in` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `exit_previous_attend` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `exit_resource_center` | Center component of the composite reference to the related exit resource record. | `int4` | Yes | No | - | - |
| `exit_resource_id` | Identifier component of the composite reference to the related exit resource record. | `int4` | Yes | No | - | - |
| `block_expired_hc` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `notify_on_access_error` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `enter_attend_duration` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `show_attendance_history` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [usage_points](usage_points.md) (6 query files), [centers](centers.md) (5 query files), [devices](devices.md) (5 query files), [clients](clients.md) (4 query files), [booking_resources](booking_resources.md) (4 query files), [usage_point_action_res_link](usage_point_action_res_link.md) (4 query files).
- FK-linked tables: outgoing FK to [gates](gates.md), [usage_points](usage_points.md); incoming FK from [usage_point_action_res_link](usage_point_action_res_link.md), [usage_point_usages](usage_point_usages.md).
- Second-level FK neighborhood includes: [access_code](access_code.md), [booking_resources](booking_resources.md), [devices](devices.md), [persons](persons.md), [usage_point_sources](usage_point_sources.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
