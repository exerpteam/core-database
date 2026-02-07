# person_ext_attrs
People-related master or relationship table for person ext attrs data. It is typically used where change-tracking timestamps are available; it appears in approximately 1908 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `personcenter` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `personid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `name` | Primary key component used to uniquely identify this record. | `VARCHAR(50)` | No | Yes | - | - |
| `txtvalue` | Operational field `txtvalue` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `last_edit_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `encrypted_value` | Business attribute `encrypted_value` used by person ext attrs workflows and reporting. | `VARCHAR(400)` | Yes | No | - | - |
| `encryption_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (1802 query files), [centers](centers.md) (1210 query files), [subscriptions](subscriptions.md) (984 query files), [products](products.md) (924 query files), [subscriptiontypes](subscriptiontypes.md) (526 query files), [account_receivables](account_receivables.md) (475 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
