# staff_usage
People-related master or relationship table for staff usage data. It is typically used where lifecycle state codes are present; it appears in approximately 254 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `booking_center` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `configuration` | Foreign key field linking this record to `activity_staff_configurations`. | `int4` | Yes | No | [activity_staff_configurations](activity_staff_configurations.md) via (`configuration` -> `id`) | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `stoptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `conflict` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `salary` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `parent_booking_center` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |
| `parent_booking_id` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - |
| `available_for_substitution` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `available_for_subst_time` | Epoch timestamp for available for subst. | `int8` | Yes | No | - | - |
| `original_staff_center` | Center part of the reference to related original staff data. | `int4` | Yes | No | - | - |
| `original_staff_id` | Identifier of the related original staff record. | `int4` | Yes | No | - | - |
| `cancellation_time` | Epoch timestamp for cancellation. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (250 query files), [persons](persons.md) (244 query files), [activity](activity.md) (232 query files), [centers](centers.md) (209 query files), [participations](participations.md) (188 query files), [activity_group](activity_group.md) (116 query files).
- FK-linked tables: outgoing FK to [activity_staff_configurations](activity_staff_configurations.md), [bookings](bookings.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
