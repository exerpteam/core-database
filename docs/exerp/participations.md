# participations
Operational table for participations records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 588 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `configuration` | Identifier of the related participation configurations record used by this row. | `int4` | Yes | No | [participation_configurations](participation_configurations.md) via (`configuration` -> `id`) | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `creation_by_center` | Center component of the composite reference to the related creation by record. | `int4` | Yes | No | [persons](persons.md) via (`creation_by_center`, `creation_by_id` -> `center`, `id`) | - |
| `creation_by_id` | Identifier component of the composite reference to the related creation by record. | `int4` | Yes | No | [persons](persons.md) via (`creation_by_center`, `creation_by_id` -> `center`, `id`) | - |
| `participation_number` | Business attribute `participation_number` used by participations workflows and reporting. | `int4` | Yes | No | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `booking_center` | Center component of the composite reference to the related booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Identifier component of the composite reference to the related booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `participant_center` | Center component of the composite reference to the related participant record. | `int4` | Yes | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `participant_id` | Identifier component of the composite reference to the related participant record. | `int4` | Yes | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `showup_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `showup_interface_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | [participations_showup_interface_type](../master%20tables/participations_showup_interface_type.md) |
| `showup_using_card` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `showup_by_center` | Center component of the composite reference to the related showup by record. | `int4` | Yes | No | [persons](persons.md) via (`showup_by_center`, `showup_by_id` -> `center`, `id`) | - |
| `showup_by_id` | Identifier component of the composite reference to the related showup by record. | `int4` | Yes | No | [persons](persons.md) via (`showup_by_center`, `showup_by_id` -> `center`, `id`) | - |
| `on_waiting_list` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | Yes | No | - | [participations_state](../master%20tables/participations_state.md) |
| `cancelation_reason` | Operational field `cancelation_reason` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | [participations_cancelation_reason](../master%20tables/participations_cancelation_reason.md) |
| `cancelation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancelation_interface_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | [participations_cancelation_interface_type](../master%20tables/participations_cancelation_interface_type.md) |
| `cancelation_by_center` | Center component of the composite reference to the related cancelation by record. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `cancelation_by_id` | Identifier component of the composite reference to the related cancelation by record. | `int4` | Yes | No | [persons](persons.md) via (`cancelation_by_center`, `cancelation_by_id` -> `center`, `id`) | - |
| `user_interface_type` | Classification code describing the user interface type category (for example: API, App, CLIENT, KIOSK). | `int4` | Yes | No | - | [participations_user_interface_type](../master%20tables/participations_user_interface_type.md) |
| `reminder_message_attempted` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `no_show_up_punish_state` | State indicator used to control lifecycle transitions and filtering. | `int4` | Yes | No | - | - |
| `moved_up_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancelation_notified` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `print_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `finish_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `invoice_line_center` | Center component of the composite reference to the related invoice line record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `invoice_line_id` | Identifier component of the composite reference to the related invoice line record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `invoice_line_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoice_line_center`, `invoice_line_id`, `invoice_line_subid` -> `center`, `id`, `subid`) | - |
| `energy_consumption_kcal` | Business attribute `energy_consumption_kcal` used by participations workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `seat_id` | Identifier for the related seat entity used by this record. | `int4` | Yes | No | - | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | Yes | No | - | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | Yes | No | - | - |
| `seat_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | Yes | No | - | - |
| `used_owner_privilege` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `booking_participation_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `reviewed_by_center` | Center component of the composite reference to the related reviewed by record. | `int4` | Yes | No | - | - |
| `reviewed_by_id` | Identifier component of the composite reference to the related reviewed by record. | `int4` | Yes | No | - | - |
| `reviewed_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_checkin_autoshowup` | Business attribute `last_checkin_autoshowup` used by participations workflows and reporting. | `int4` | Yes | No | - | - |
| `tentative_cutoff_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `showup_entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `pickup_by_center` | Center component of the composite reference to the related pickup by record. | `int4` | Yes | No | - | - |
| `pickup_by_id` | Identifier component of the composite reference to the related pickup by record. | `int4` | Yes | No | - | - |
| `dropoff_by_center` | Center component of the composite reference to the related dropoff by record. | `int4` | Yes | No | - | - |
| `dropoff_by_id` | Identifier component of the composite reference to the related dropoff by record. | `int4` | Yes | No | - | - |
| `recurring_participation_key` | Identifier of the related recurring participations record used by this row. | `int4` | Yes | No | [recurring_participations](recurring_participations.md) via (`recurring_participation_key` -> `id`) | - |
| `after_sale_process` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `confirmation_process` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (481 query files), [persons](persons.md) (480 query files), [centers](centers.md) (444 query files), [activity](activity.md) (396 query files), [staff_usage](staff_usage.md) (188 query files), [products](products.md) (187 query files).
- FK-linked tables: outgoing FK to [bookings](bookings.md), [invoice_lines_mt](invoice_lines_mt.md), [participation_configurations](participation_configurations.md), [persons](persons.md), [recurring_participations](recurring_participations.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_privilege_groups](booking_privilege_groups.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
