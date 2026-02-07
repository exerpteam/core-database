# activity_group
Operational table for activity group records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 239 query files; common companions include [activity](activity.md), [bookings](bookings.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `old_activity_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `public_participation` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bookable_in_kiosk` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bookable_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bookable_via_api` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bookable_via_mobile_api` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bookable_on_frontdesk_app` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `create_booking_role` | Business attribute `create_booking_role` used by activity group workflows and reporting. | `int4` | Yes | No | - | - |
| `edit_booking_role` | Business attribute `edit_booking_role` used by activity group workflows and reporting. | `int4` | Yes | No | - | - |
| `cancel_booking_role` | Business attribute `cancel_booking_role` used by activity group workflows and reporting. | `int4` | Yes | No | - | - |
| `handle_multiple_bookings_role` | Business attribute `handle_multiple_bookings_role` used by activity group workflows and reporting. | `int4` | Yes | No | - | - |
| `override_description` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `bytea` | Yes | No | - | - |
| `showup_by_qrcode` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `showup_by_mobile_api` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `supports_substitution_flag` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `wait_list_cap_perc` | Business attribute `wait_list_cap_perc` used by activity group workflows and reporting. | `int4` | Yes | No | - | - |
| `override_wait_list_cap_perc` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `indicate_new_members` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `parent_activity_group_id` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [activity_group](activity_group.md) via (`parent_activity_group_id` -> `id`) | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(50)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |

# Relations
- Commonly used with: [activity](activity.md) (231 query files), [bookings](bookings.md) (204 query files), [persons](persons.md) (185 query files), [participations](participations.md) (177 query files), [centers](centers.md) (170 query files), [staff_usage](staff_usage.md) (116 query files).
- FK-linked tables: outgoing FK to [activity_group](activity_group.md); incoming FK from [activity_group](activity_group.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
