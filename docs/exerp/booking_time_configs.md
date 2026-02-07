# booking_time_configs
Configuration table for booking time configs behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 16 query files; common companions include [activity](activity.md), [activity_group](activity_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `book_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_start_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `book_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_stop_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `book_cancel_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_cancel_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_cancel_stop_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `book_cancel_stop_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_start_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_stop_staff_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_stop_staff_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_stop_staff_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_stop_cus_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_stop_cus_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_stop_cus_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_stop_staff_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_stop_staff_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_stop_staff_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_stop_staff_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_stop_cus_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_start_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_stop_staff_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_stop_staff_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_stop_staff_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_showup_stop_cus_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_stop_cus_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_stop_cus_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `waitinglist_run_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `waitinglist_run_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `waitinglist_run_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `normal_misuse_id` | Identifier of the related normal misuse record. | `text(2147483647)` | Yes | No | - | - |
| `waiting_misuse_id` | Identifier of the related waiting misuse record. | `text(2147483647)` | Yes | No | - | - |
| `part_recurrence_in_past_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_recurrence_in_past_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_recurrence_in_past_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_rec_in_past_requiredrole` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `showup_membercard` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `showup_membercard_requiredrole` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `booking_time_configs` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `allow_auto_showup` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `part_cancel_sanc_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_sanc_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_cancel_sanc_start_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `part_cancel_sanc_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `head_count_window_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `head_count_window_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `head_count_window_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `threshold_percentage` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `threshold_action` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `review_part_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `review_part_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `review_part_stop_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `flag_substitution_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `flag_substitution_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `flag_substitution_start_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `flag_substitution_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `flag_substitution_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `flag_substitution_stop_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `program_cancel_stop_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_cancel_stop_round` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `program_cancel_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_cancel_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_signup_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_signup_round` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `program_signup_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_signup_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `book_stop_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_showup_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_communication_stop_round` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `part_communication_stop_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `part_communication_stop_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_latest_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_latest_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_latest_start_round` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `program_latest_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_early_start_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_early_start_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_early_start_round` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `program_early_start_role` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `stop_sanction_window_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `stop_sanction_window_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `stop_sanction_window_round` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [activity](activity.md) (14 query files), [activity_group](activity_group.md) (12 query files), [colour_groups](colour_groups.md) (12 query files), [activity_resource_configs](activity_resource_configs.md) (11 query files), [booking_resource_groups](booking_resource_groups.md) (11 query files), [activity_staff_configurations](activity_staff_configurations.md) (9 query files).
- FK-linked tables: incoming FK from [activity](activity.md), [booking_program_types](booking_program_types.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_program_levels](booking_program_levels.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_programs](booking_programs.md), [bookings](bookings.md), [participation_configurations](participation_configurations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
