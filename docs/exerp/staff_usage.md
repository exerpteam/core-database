# staff_usage
People-related master or relationship table for staff usage data. It is typically used where lifecycle state codes are present; it appears in approximately 254 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `booking_center` | Center component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Identifier component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `configuration` | Identifier of the related activity staff configurations record used by this row. | `int4` | Yes | No | [activity_staff_configurations](activity_staff_configurations.md) via (`configuration` -> `id`) | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `stoptime` | Operational field `stoptime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `conflict` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `salary` | Operational field `salary` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | Yes | No | - | - |
| `parent_booking_center` | Center component of the composite reference to the related parent booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |
| `parent_booking_id` | Identifier component of the composite reference to the related parent booking record. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |
| `available_for_substitution` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `available_for_subst_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `original_staff_center` | Center component of the composite reference to the related original staff record. | `int4` | Yes | No | - | - |
| `original_staff_id` | Identifier component of the composite reference to the related original staff record. | `int4` | Yes | No | - | - |
| `cancellation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (250 query files), [persons](persons.md) (244 query files), [activity](activity.md) (232 query files), [centers](centers.md) (209 query files), [participations](participations.md) (188 query files), [activity_group](activity_group.md) (116 query files).
- FK-linked tables: outgoing FK to [activity_staff_configurations](activity_staff_configurations.md), [bookings](bookings.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
