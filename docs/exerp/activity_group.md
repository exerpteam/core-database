# activity_group
Operational table for activity group records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 239 query files; common companions include [activity](activity.md), [bookings](bookings.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `old_activity_type_id` | Identifier of the related old activity type record. | `int4` | Yes | No | - | - |
| `public_participation` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bookable_in_kiosk` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bookable_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bookable_via_api` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bookable_via_mobile_api` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `bookable_on_frontdesk_app` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `create_booking_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `edit_booking_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cancel_booking_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `handle_multiple_bookings_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `override_description` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `description` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `showup_by_qrcode` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `showup_by_mobile_api` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `supports_substitution_flag` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `wait_list_cap_perc` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `override_wait_list_cap_perc` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `indicate_new_members` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `parent_activity_group_id` | Foreign key field linking this record to `activity_group`. | `int4` | Yes | No | [activity_group](activity_group.md) via (`parent_activity_group_id` -> `id`) | - |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(50)` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |

# Relations
- Commonly used with: [activity](activity.md) (231 query files), [bookings](bookings.md) (204 query files), [persons](persons.md) (185 query files), [participations](participations.md) (177 query files), [centers](centers.md) (170 query files), [staff_usage](staff_usage.md) (116 query files).
- FK-linked tables: outgoing FK to [activity_group](activity_group.md); incoming FK from [activity_group](activity_group.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
