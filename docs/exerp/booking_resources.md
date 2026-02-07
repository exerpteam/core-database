# booking_resources
Operational table for booking resources records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 214 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `attendable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `show_calendar` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `attend_privilege_id` | Foreign key field linking this record to `booking_privilege_groups`. | `int4` | Yes | No | [booking_privilege_groups](booking_privilege_groups.md) via (`attend_privilege_id` -> `id`) | - | `1001` |
| `attend_availability` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `vertices` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `override_center_opening_hours` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `sex_restriction` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `age_restriction_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `age_restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `ext_attr_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `availability_staff` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `instructor_x` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `instructor_y` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `attend_availability_period_id` | Identifier of the related attend availability period record. | `int4` | Yes | No | - | - | `1001` |
| `staff_availability_period_id` | Identifier of the related staff availability period record. | `int4` | Yes | No | - | - | `1001` |
| `api_ignore__check_in` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `api_check_out` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `age_restriction_min_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `age_restriction_max_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `webname` | Text field containing descriptive or reference information. | `VARCHAR(1024)` | Yes | No | - | - | `Example Name` |

# Relations
- Commonly used with: [centers](centers.md) (168 query files), [persons](persons.md) (124 query files), [attends](attends.md) (115 query files), [activity](activity.md) (81 query files), [bookings](bookings.md) (79 query files), [booking_resource_usage](booking_resource_usage.md) (62 query files).
- FK-linked tables: outgoing FK to [booking_privilege_groups](booking_privilege_groups.md); incoming FK from [attends](attends.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [booking_privileges](booking_privileges.md), [booking_resource_groups](booking_resource_groups.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md), [persons](persons.md), [usage_point_resources](usage_point_resources.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
