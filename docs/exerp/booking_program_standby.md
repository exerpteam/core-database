# booking_program_standby
Operational table for booking program standby records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `participant_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `participant_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `created_by_employee_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`created_by_employee_center`, `created_by_employee_id` -> `center`, `id`) | - |
| `created_by_employee_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`created_by_employee_center`, `created_by_employee_id` -> `center`, `id`) | - |
| `start_booking_center` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`start_booking_center`, `start_booking_id` -> `center`, `id`) | - |
| `start_booking_id` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`start_booking_center`, `start_booking_id` -> `center`, `id`) | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - |
| `creation_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cancelation_time` | Epoch timestamp for cancelation. | `int8` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [bookings](bookings.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_programs](booking_programs.md), [booking_resource_usage](booking_resource_usage.md), [booking_restrictions](booking_restrictions.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md).
