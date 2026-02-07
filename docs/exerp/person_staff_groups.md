# person_staff_groups
People-related master or relationship table for person staff groups data. It is typically used where it appears in approximately 71 query files; common companions include [persons](persons.md), [staff_groups](staff_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `staff_group_id` | Foreign key field linking this record to `staff_groups`. | `int4` | No | No | [staff_groups](staff_groups.md) via (`staff_group_id` -> `id`) | - | `1001` |
| `salary` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `commissionable` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [persons](persons.md) (68 query files), [staff_groups](staff_groups.md) (59 query files), [centers](centers.md) (47 query files), [activity](activity.md) (46 query files), [bookings](bookings.md) (44 query files), [staff_usage](staff_usage.md) (44 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [staff_groups](staff_groups.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity_staff_configurations](activity_staff_configurations.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md).
