# person_staff_groups
People-related master or relationship table for person staff groups data. It is typically used where it appears in approximately 71 query files; common companions include [persons](persons.md), [staff_groups](staff_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `staff_group_id` | Identifier of the related staff groups record used by this row. | `int4` | No | No | [staff_groups](staff_groups.md) via (`staff_group_id` -> `id`) | - |
| `salary` | Operational field `salary` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `commissionable` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (68 query files), [staff_groups](staff_groups.md) (59 query files), [centers](centers.md) (47 query files), [activity](activity.md) (46 query files), [bookings](bookings.md) (44 query files), [staff_usage](staff_usage.md) (44 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [staff_groups](staff_groups.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity_staff_configurations](activity_staff_configurations.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md).
