# cashcollectioncases
Financial/transactional table for cashcollectioncases records. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 448 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `personcenter` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `personid` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `ar_center` | Center component of the composite reference to the related ar record. | `int4` | Yes | No | [account_receivables](account_receivables.md) via (`ar_center`, `ar_id` -> `center`, `id`) | - |
| `ar_id` | Identifier component of the composite reference to the related ar record. | `int4` | Yes | No | [account_receivables](account_receivables.md) via (`ar_center`, `ar_id` -> `center`, `id`) | - |
| `closed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `successfull` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `HOLD` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cc_agency_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `cc_agency_update_source` | Business attribute `cc_agency_update_source` used by cashcollectioncases workflows and reporting. | `int4` | Yes | No | - | - |
| `cc_agency_update_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cashcollectionservice` | Identifier of the related cashcollectionservices record used by this row. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - |
| `ext_ref` | Business attribute `ext_ref` used by cashcollectioncases workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `startdate` | Operational field `startdate` used in query filtering and reporting transformations. | `DATE` | No | No | - | - |
| `currentstep` | Operational field `currentstep` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `currentstep_type` | Classification code describing the currentstep type category (for example: BLOCK, Blocked, CASHCOLLECTION, CLOSE). | `int4` | No | No | - | [cashcollectioncases_currentstep_type](../master%20tables/cashcollectioncases_currentstep_type.md) |
| `currentstep_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `nextstep_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `nextstep_type` | Classification code describing the nextstep type category (for example: BLOCK, CASHCOLLECTION, CLOSE, MESSAGE). | `int4` | Yes | No | - | [cashcollectioncases_nextstep_type](../master%20tables/cashcollectioncases_nextstep_type.md) |
| `settings` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `missingpayment` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `below_minimum_age` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `start_datetime` | Operational field `start_datetime` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `closed_datetime` | Operational field `closed_datetime` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (386 query files), [centers](centers.md) (289 query files), [subscriptions](subscriptions.md) (272 query files), [account_receivables](account_receivables.md) (271 query files), [products](products.md) (197 query files), [person_ext_attrs](person_ext_attrs.md) (188 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [cashcollectionservices](cashcollectionservices.md), [persons](persons.md); incoming FK from [cashcollection_requests](cashcollection_requests.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [ar_trans](ar_trans.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollection_in](cashcollection_in.md), [cashcollection_out](cashcollection_out.md), [centers](centers.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
