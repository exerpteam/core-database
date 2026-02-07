# staff_usage
People-related master or relationship table for staff usage data. It is typically used where lifecycle state codes are present; it appears in approximately 254 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `booking_center` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - | `101` |
| `booking_id` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - | `1001` |
| `configuration` | Foreign key field linking this record to `activity_staff_configurations`. | `int4` | Yes | No | [activity_staff_configurations](activity_staff_configurations.md) via (`configuration` -> `id`) | - | `42` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `stoptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `conflict` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `salary` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `parent_booking_center` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - | `101` |
| `parent_booking_id` | Foreign key field linking this record to `bookings`. | `int4` | Yes | No | [bookings](bookings.md) via (`parent_booking_center`, `parent_booking_id` -> `center`, `id`) | - | `1001` |
| `available_for_substitution` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `available_for_subst_time` | Epoch timestamp for available for subst. | `int8` | Yes | No | - | - | `1738281600000` |
| `original_staff_center` | Center part of the reference to related original staff data. | `int4` | Yes | No | - | - | `101` |
| `original_staff_id` | Identifier of the related original staff record. | `int4` | Yes | No | - | - | `1001` |
| `cancellation_time` | Epoch timestamp for cancellation. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [bookings](bookings.md) (250 query files), [persons](persons.md) (244 query files), [activity](activity.md) (232 query files), [centers](centers.md) (209 query files), [participations](participations.md) (188 query files), [activity_group](activity_group.md) (116 query files).
- FK-linked tables: outgoing FK to [activity_staff_configurations](activity_staff_configurations.md), [bookings](bookings.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
