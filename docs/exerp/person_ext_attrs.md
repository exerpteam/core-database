# person_ext_attrs
People-related master or relationship table for person ext attrs data. It is typically used where change-tracking timestamps are available; it appears in approximately 1908 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `personcenter` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `personid` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | Yes | - | - | `Example Name` |
| `txtvalue` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `last_edit_time` | Epoch timestamp of the most recent user/system edit. | `int8` | Yes | No | - | - | `1738281600000` |
| `encrypted_value` | Text field containing descriptive or reference information. | `VARCHAR(400)` | Yes | No | - | - | `Sample value` |
| `encryption_time` | Epoch timestamp for encryption. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [persons](persons.md) (1802 query files), [centers](centers.md) (1210 query files), [subscriptions](subscriptions.md) (984 query files), [products](products.md) (924 query files), [subscriptiontypes](subscriptiontypes.md) (526 query files), [account_receivables](account_receivables.md) (475 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
