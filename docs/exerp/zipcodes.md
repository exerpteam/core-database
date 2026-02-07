# zipcodes
Operational table for zipcodes records in the Exerp schema. It is typically used where it appears in approximately 147 query files; common companions include [persons](persons.md), [person_ext_attrs](person_ext_attrs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `country` | Primary key component used to uniquely identify this record. | `VARCHAR(2)` | No | Yes | [countries](countries.md) via (`country` -> `id`) | - |
| `zipcode` | Primary key component used to uniquely identify this record. | `VARCHAR(8)` | No | Yes | - | - |
| `city` | Primary key component used to uniquely identify this record. | `VARCHAR(60)` | No | Yes | - | - |
| `county` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `province` | Operational field `province` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (133 query files), [person_ext_attrs](person_ext_attrs.md) (101 query files), [centers](centers.md) (86 query files), [relatives](relatives.md) (84 query files), [subscriptions](subscriptions.md) (74 query files), [products](products.md) (68 query files).
- FK-linked tables: outgoing FK to [countries](countries.md); incoming FK from [centers](centers.md), [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md).
