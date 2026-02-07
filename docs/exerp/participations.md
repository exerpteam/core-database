# participations
Operational table for participations records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 588 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `configuration` | Foreign key field linking this record to `participation_configurations`. | `int4` | Yes | No | [participation_configurations](participation_configurations.md) via (`configuration` -> `id`) | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `creation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creation_by_center`, `creation_by_id` -> `center`, `id`) | - |
| `creation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`creation_by_center`, `creation_by_id` -> `center`, `id`) | - |
| `participation_number` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `start_time` | Epoch timestamp for start. | `int8` | Yes | No | - | - |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - |
| `booking_center` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `participant_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `participant_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `showup_time` | Epoch timestamp for showup. | `int8` | Yes | No | - | - |
| `showup_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `showup_using_card` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `showup_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`showup_by_center`, `showup_by_id` -> `center`, `id`) | - |
| `showup_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`showup_by_center`, `showup_by_id` -> `center`, `id`) | - |
| `on_waiting_list` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | Yes | No | - | - |
| `cancelation_reason` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `cancelation_time` | Epoch timestamp for cancelation. | `int8` | Yes | No | - | - |
| `cancelation_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cancelation_by_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `cancelation_by_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `user_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `reminder_message_attempted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `no_show_up_punish_state` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `moved_up_time` | Epoch timestamp for moved up. | `int8` | Yes | No | - | - |
| `cancelation_notified` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `print_time` | Epoch timestamp for print. | `int8` | Yes | No | - | - |
| `finish_time` | Epoch timestamp for finish. | `int8` | Yes | No | - | - |
| `invoice_line_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `invoice_line_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `invoice_line_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `energy_consumption_kcal` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `seat_id` | Identifier of the related seat record. | `int4` | Yes | No | - | - |
| `owner_center` | Center part of the reference to related owner data. | `int4` | Yes | No | - | - |
| `owner_id` | Identifier of the related owner record. | `int4` | Yes | No | - | - |
| `seat_state` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `used_owner_privilege` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `booking_participation_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `reviewed_by_center` | Center part of the reference to related reviewed by data. | `int4` | Yes | No | - | - |
| `reviewed_by_id` | Identifier of the related reviewed by record. | `int4` | Yes | No | - | - |
| `reviewed_time` | Epoch timestamp for reviewed. | `int8` | Yes | No | - | - |
| `last_checkin_autoshowup` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `tentative_cutoff_time` | Epoch timestamp for tentative cutoff. | `int8` | Yes | No | - | - |
| `showup_entry_time` | Epoch timestamp for showup entry. | `int8` | Yes | No | - | - |
| `pickup_by_center` | Center part of the reference to related pickup by data. | `int4` | Yes | No | - | - |
| `pickup_by_id` | Identifier of the related pickup by record. | `int4` | Yes | No | - | - |
| `dropoff_by_center` | Center part of the reference to related dropoff by data. | `int4` | Yes | No | - | - |
| `dropoff_by_id` | Identifier of the related dropoff by record. | `int4` | Yes | No | - | - |
| `recurring_participation_key` | Foreign key field linking this record to `recurring_participations`. | `int4` | Yes | No | [recurring_participations](recurring_participations.md) via (`recurring_participation_key` -> `id`) | - |
| `after_sale_process` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `confirmation_process` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (481 query files), [persons](persons.md) (480 query files), [centers](centers.md) (444 query files), [activity](activity.md) (396 query files), [staff_usage](staff_usage.md) (188 query files), [products](products.md) (187 query files).
- FK-linked tables: outgoing FK to [bookings](bookings.md), [invoice_lines_mt](invoice_lines_mt.md), [participation_configurations](participation_configurations.md), [persons](persons.md), [recurring_participations](recurring_participations.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
