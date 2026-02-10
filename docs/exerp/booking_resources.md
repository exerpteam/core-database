# booking_resources
Operational table for booking resources records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 214 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `attendable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `show_calendar` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `attend_privilege_id` | Identifier of the related booking privilege groups record used by this row. | `int4` | Yes | No | [booking_privilege_groups](booking_privilege_groups.md) via (`attend_privilege_id` -> `id`) | - |
| `attend_availability` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `vertices` | Business attribute `vertices` used by booking resources workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `override_center_opening_hours` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `sex_restriction` | Business attribute `sex_restriction` used by booking resources workflows and reporting. | `int4` | No | No | - | - |
| `age_restriction_type` | Classification code describing the age restriction type category (for example: BETWEEN, LESS THAN, LESS THEN, MORE THAN). | `int4` | No | No | - | [booking_resources_age_restriction_type](../master%20tables/booking_resources_age_restriction_type.md) |
| `age_restriction_value` | Business attribute `age_restriction_value` used by booking resources workflows and reporting. | `int4` | No | No | - | - |
| `ext_attr_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `availability_staff` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `instructor_x` | Business attribute `instructor_x` used by booking resources workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `instructor_y` | Business attribute `instructor_y` used by booking resources workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `attend_availability_period_id` | Identifier for the related attend availability period entity used by this record. | `int4` | Yes | No | - | - |
| `staff_availability_period_id` | Identifier for the related staff availability period entity used by this record. | `int4` | Yes | No | - | - |
| `api_ignore__check_in` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `api_check_out` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `age_restriction_min_value` | Business attribute `age_restriction_min_value` used by booking resources workflows and reporting. | `int4` | Yes | No | - | - |
| `age_restriction_max_value` | Business attribute `age_restriction_max_value` used by booking resources workflows and reporting. | `int4` | Yes | No | - | - |
| `webname` | Business attribute `webname` used by booking resources workflows and reporting. | `VARCHAR(1024)` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (168 query files), [persons](persons.md) (124 query files), [attends](attends.md) (115 query files), [activity](activity.md) (81 query files), [bookings](bookings.md) (79 query files), [booking_resource_usage](booking_resource_usage.md) (62 query files).
- FK-linked tables: outgoing FK to [booking_privilege_groups](booking_privilege_groups.md); incoming FK from [attends](attends.md), [booking_resource_configs](booking_resource_configs.md), [booking_resource_usage](booking_resource_usage.md), [usage_point_action_res_link](usage_point_action_res_link.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [booking_privileges](booking_privileges.md), [booking_resource_groups](booking_resource_groups.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md), [persons](persons.md), [usage_point_resources](usage_point_resources.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
