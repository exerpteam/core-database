# booking_resource_configs
Configuration table for booking resource configs behavior and defaults. It is typically used where change-tracking timestamps are available; it appears in approximately 46 query files; common companions include [booking_resources](booking_resources.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `booking_resource_center` | Foreign key field linking this record to `booking_resources`. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - | `101` |
| `booking_resource_id` | Foreign key field linking this record to `booking_resources`. | `int4` | No | Yes | [booking_resources](booking_resources.md) via (`booking_resource_center`, `booking_resource_id` -> `center`, `id`) | - | `1001` |
| `group_id` | Foreign key field linking this record to `booking_resource_groups`. | `int4` | No | Yes | [booking_resource_groups](booking_resource_groups.md) via (`group_id` -> `id`) | - | `1001` |
| `availability` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `maximum_participations` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `business_starttimes` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `other_starttimes` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) | `1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [booking_resources](booking_resources.md) (40 query files), [centers](centers.md) (32 query files), [activity](activity.md) (27 query files), [booking_resource_groups](booking_resource_groups.md) (23 query files), [booking_resource_usage](booking_resource_usage.md) (21 query files), [bookings](bookings.md) (21 query files).
- FK-linked tables: outgoing FK to [booking_resource_groups](booking_resource_groups.md), [booking_resources](booking_resources.md).
- Second-level FK neighborhood includes: [attends](attends.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_resource_usage](booking_resource_usage.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
