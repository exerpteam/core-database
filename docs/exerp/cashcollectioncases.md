# cashcollectioncases
Financial/transactional table for cashcollectioncases records. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 448 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `personcenter` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `personid` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - | `42` |
| `ar_center` | Foreign key field linking this record to `account_receivables`. | `int4` | Yes | No | [account_receivables](account_receivables.md) via (`ar_center`, `ar_id` -> `center`, `id`) | - | `101` |
| `ar_id` | Foreign key field linking this record to `account_receivables`. | `int4` | Yes | No | [account_receivables](account_receivables.md) via (`ar_center`, `ar_id` -> `center`, `id`) | - | `1001` |
| `closed` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `successfull` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `HOLD` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cc_agency_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `cc_agency_update_source` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `cc_agency_update_time` | Epoch timestamp for cc agency update. | `int8` | Yes | No | - | - | `1738281600000` |
| `cashcollectionservice` | Foreign key field linking this record to `cashcollectionservices`. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - | `42` |
| `ext_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `startdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | No | No | - | - | `2025-01-31` |
| `currentstep` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `currentstep_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `currentstep_date` | Date for currentstep. | `DATE` | No | No | - | - | `2025-01-31` |
| `nextstep_date` | Date for nextstep. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `nextstep_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `settings` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `missingpayment` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `below_minimum_age` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `start_datetime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `closed_datetime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [persons](persons.md) (386 query files), [centers](centers.md) (289 query files), [subscriptions](subscriptions.md) (272 query files), [account_receivables](account_receivables.md) (271 query files), [products](products.md) (197 query files), [person_ext_attrs](person_ext_attrs.md) (188 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [cashcollectionservices](cashcollectionservices.md), [persons](persons.md); incoming FK from [cashcollection_requests](cashcollection_requests.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [ar_trans](ar_trans.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollection_in](cashcollection_in.md), [cashcollection_out](cashcollection_out.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
