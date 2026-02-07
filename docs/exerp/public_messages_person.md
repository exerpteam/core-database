# public_messages_person
People-related master or relationship table for public messages person data.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [public_messages](public_messages.md) via (`id` -> `id`) | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `person_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `delivered` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `delivered_at` | Business attribute `delivered_at` used by public messages person workflows and reporting. | `int8` | No | No | - | - |
| `delivery_code` | Business attribute `delivery_code` used by public messages person workflows and reporting. | `int4` | No | No | - | - |
| `READ` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `read_at` | Business attribute `read_at` used by public messages person workflows and reporting. | `int8` | No | No | - | - |
| `deleted` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `deleted_at` | Business attribute `deleted_at` used by public messages person workflows and reporting. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md), [public_messages](public_messages.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
