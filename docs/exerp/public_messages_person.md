# public_messages_person
People-related master or relationship table for public messages person data.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [public_messages](public_messages.md) via (`id` -> `id`) | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `delivered` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `delivered_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `delivery_code` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `READ` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `read_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deleted_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md), [public_messages](public_messages.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
