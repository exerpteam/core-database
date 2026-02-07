# booking_time_configs
Configuration table for booking time configs behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 16 query files; common companions include [activity](activity.md), [activity_group](activity_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `book_start_value` | Business attribute `book_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_start_unit` | Business attribute `book_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_start_round` | Business attribute `book_start_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `book_start_role` | Business attribute `book_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_stop_value` | Business attribute `book_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_stop_unit` | Business attribute `book_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_stop_round` | Business attribute `book_stop_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `book_cancel_stop_value` | Business attribute `book_cancel_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_cancel_stop_unit` | Business attribute `book_cancel_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_cancel_stop_round` | Business attribute `book_cancel_stop_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `book_cancel_stop_role` | Business attribute `book_cancel_stop_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_start_value` | Business attribute `part_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_start_unit` | Business attribute `part_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_start_round` | Business attribute `part_start_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_start_role` | Business attribute `part_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_stop_staff_value` | Business attribute `part_stop_staff_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_stop_staff_unit` | Business attribute `part_stop_staff_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_stop_staff_round` | Business attribute `part_stop_staff_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_stop_cus_value` | Business attribute `part_stop_cus_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_stop_cus_unit` | Business attribute `part_stop_cus_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_stop_cus_round` | Business attribute `part_stop_cus_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_stop_staff_value` | Business attribute `part_cancel_stop_staff_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_stop_staff_unit` | Business attribute `part_cancel_stop_staff_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_stop_staff_round` | Business attribute `part_cancel_stop_staff_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_stop_staff_role` | Business attribute `part_cancel_stop_staff_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_value` | Business attribute `part_cancel_stop_cus_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_unit` | Business attribute `part_cancel_stop_cus_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_round` | Business attribute `part_cancel_stop_cus_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_start_value` | Business attribute `part_showup_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_start_unit` | Business attribute `part_showup_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_start_round` | Business attribute `part_showup_start_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_stop_staff_value` | Business attribute `part_showup_stop_staff_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_stop_staff_unit` | Business attribute `part_showup_stop_staff_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_stop_staff_round` | Business attribute `part_showup_stop_staff_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_stop_cus_value` | Business attribute `part_showup_stop_cus_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_stop_cus_unit` | Business attribute `part_showup_stop_cus_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_stop_cus_round` | Business attribute `part_showup_stop_cus_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `waitinglist_run_value` | Business attribute `waitinglist_run_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `waitinglist_run_unit` | Business attribute `waitinglist_run_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `waitinglist_run_round` | Business attribute `waitinglist_run_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `normal_misuse_id` | Identifier for the related normal misuse entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `waiting_misuse_id` | Identifier for the related waiting misuse entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `part_recurrence_in_past_value` | Business attribute `part_recurrence_in_past_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_recurrence_in_past_unit` | Business attribute `part_recurrence_in_past_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_recurrence_in_past_round` | Business attribute `part_recurrence_in_past_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_rec_in_past_requiredrole` | Business attribute `part_rec_in_past_requiredrole` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `showup_membercard` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `showup_membercard_requiredrole` | Business attribute `showup_membercard_requiredrole` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `booking_time_configs` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `allow_auto_showup` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `part_cancel_sanc_start_value` | Business attribute `part_cancel_sanc_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_sanc_start_unit` | Business attribute `part_cancel_sanc_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_cancel_sanc_start_round` | Business attribute `part_cancel_sanc_start_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_sanc_start_role` | Business attribute `part_cancel_sanc_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `head_count_window_value` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `head_count_window_unit` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `head_count_window_round` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `threshold_percentage` | Business attribute `threshold_percentage` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `threshold_action` | Business attribute `threshold_action` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `review_part_stop_value` | Business attribute `review_part_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `review_part_stop_unit` | Business attribute `review_part_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `review_part_stop_round` | Business attribute `review_part_stop_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `flag_substitution_start_value` | Business attribute `flag_substitution_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `flag_substitution_start_unit` | Business attribute `flag_substitution_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `flag_substitution_start_round` | Business attribute `flag_substitution_start_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `flag_substitution_stop_value` | Business attribute `flag_substitution_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `flag_substitution_stop_unit` | Business attribute `flag_substitution_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `flag_substitution_stop_round` | Business attribute `flag_substitution_stop_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `program_cancel_stop_role` | Business attribute `program_cancel_stop_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_cancel_stop_round` | Business attribute `program_cancel_stop_round` used by booking time configs workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `program_cancel_stop_unit` | Business attribute `program_cancel_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_cancel_stop_value` | Business attribute `program_cancel_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_signup_role` | Business attribute `program_signup_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_signup_round` | Business attribute `program_signup_round` used by booking time configs workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `program_signup_unit` | Business attribute `program_signup_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_signup_value` | Business attribute `program_signup_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `book_stop_role` | Business attribute `book_stop_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_showup_start_role` | Business attribute `part_showup_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_communication_stop_round` | Business attribute `part_communication_stop_round` used by booking time configs workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `part_communication_stop_unit` | Business attribute `part_communication_stop_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `part_communication_stop_value` | Business attribute `part_communication_stop_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_latest_start_value` | Business attribute `program_latest_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_latest_start_unit` | Business attribute `program_latest_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_latest_start_round` | Business attribute `program_latest_start_round` used by booking time configs workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `program_latest_start_role` | Business attribute `program_latest_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_early_start_value` | Business attribute `program_early_start_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_early_start_unit` | Business attribute `program_early_start_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `program_early_start_round` | Business attribute `program_early_start_round` used by booking time configs workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `program_early_start_role` | Business attribute `program_early_start_role` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `stop_sanction_window_value` | Business attribute `stop_sanction_window_value` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `stop_sanction_window_unit` | Business attribute `stop_sanction_window_unit` used by booking time configs workflows and reporting. | `int4` | Yes | No | - | - |
| `stop_sanction_window_round` | Business attribute `stop_sanction_window_round` used by booking time configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (14 query files), [activity_group](activity_group.md) (12 query files), [colour_groups](colour_groups.md) (12 query files), [activity_resource_configs](activity_resource_configs.md) (11 query files), [booking_resource_groups](booking_resource_groups.md) (11 query files), [activity_staff_configurations](activity_staff_configurations.md) (9 query files).
- FK-linked tables: incoming FK from [activity](activity.md), [booking_program_types](booking_program_types.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_levels](booking_program_levels.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
