# booking_resource_configs
Configuration table for booking resource configs behavior and defaults. It is typically used where change-tracking timestamps are available; it appears in approximately 46 query files; common companions include [booking_resources](booking_resources.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `booking_resource_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `booking_resource_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - |
| `group_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [booking_resource_groups](booking_resource_groups.md) via (`group_id` -> `id`) | - |
| `availability` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `maximum_participations` | Business attribute `maximum_participations` used by booking resource configs workflows and reporting. | `int4` | Yes | No | - | - |
| `business_starttimes` | Business attribute `business_starttimes` used by booking resource configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `other_starttimes` | Business attribute `other_starttimes` used by booking resource configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [booking_resources](booking_resources.md) (40 query files), [centers](centers.md) (32 query files), [activity](activity.md) (27 query files), [booking_resource_groups](booking_resource_groups.md) (23 query files), [booking_resource_usage](booking_resource_usage.md) (21 query files), [bookings](bookings.md) (21 query files).
- FK-linked tables: outgoing FK to [booking_resource_groups](booking_resource_groups.md), [booking_resources](booking_resources.md).
- Second-level FK neighborhood includes: [attends](attends.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_resource_usage](booking_resource_usage.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
