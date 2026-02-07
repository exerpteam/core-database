# booking_programs
Operational table for booking programs records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 13 query files; common companions include [activity](activity.md), [bookings](bookings.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `startdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - |
| `stopdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `activity` | Foreign key field linking this record to `activity`. | `int4` | Yes | No | [activity](activity.md) via (`activity` -> `id`) | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `waiting_list_capacity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `program_type_id` | Foreign key field linking this record to `booking_program_types`. | `int4` | Yes | No | [booking_program_types](booking_program_types.md) via (`program_type_id` -> `id`) | - |
| `cached_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cached_earliest_time` | Epoch timestamp for cached earliest. | `int4` | Yes | No | - | - |
| `cached_latest_time` | Epoch timestamp for cached latest. | `int4` | Yes | No | - | - |
| `semester_id` | Foreign key field linking this record to `semesters`. | `int4` | Yes | No | [semesters](semesters.md) via (`semester_id` -> `id`) | - |

# Relations
- Commonly used with: [activity](activity.md) (10 query files), [bookings](bookings.md) (10 query files), [participations](participations.md) (10 query files), [persons](persons.md) (10 query files), [centers](centers.md) (9 query files), [journalentries](journalentries.md) (5 query files).
- FK-linked tables: outgoing FK to [activity](activity.md), [booking_program_types](booking_program_types.md), [semesters](semesters.md); incoming FK from [bookings](bookings.md), [recurring_participations](recurring_participations.md).
- Second-level FK neighborhood includes: [activity_resource_configs](activity_resource_configs.md), [activity_staff_configurations](activity_staff_configurations.md), [booking_change](booking_change.md), [booking_program_levels](booking_program_levels.md), [booking_program_standby](booking_program_standby.md), [booking_program_type_activity](booking_program_type_activity.md), [booking_resource_usage](booking_resource_usage.md), [booking_time_configs](booking_time_configs.md), [centers](centers.md), [installment_plans](installment_plans.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
