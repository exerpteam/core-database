# cashcollection_requests
Financial/transactional table for cashcollection requests records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 39 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `req_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `req_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `req_delivery` | Operational field `req_delivery` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `file_out` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`file_out` -> `id`) | - |
| `xfr_delivery` | Identifier of the related cashcollection in record used by this row. | `int4` | Yes | No | [cashcollection_in](cashcollection_in.md) via (`xfr_delivery` -> `id`) | - |
| `payment_request_center` | Center component of the composite reference to the related payment request record. | `int4` | Yes | No | - | [payment_requests](payment_requests.md) via (`payment_request_center`, `payment_request_id` -> `center`, `id`) |
| `payment_request_id` | Identifier component of the composite reference to the related payment request record. | `int4` | Yes | No | - | - |
| `payment_request_subid` | Business attribute `payment_request_subid` used by cashcollection requests workflows and reporting. | `int4` | Yes | No | - | - |
| `prscenter` | Center component of the composite reference to the related prs record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - |
| `prsid` | Identifier component of the composite reference to the related prs record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - |
| `prssubid` | Identifier of the related payment request specifications record used by this row. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (35 query files), [account_receivables](account_receivables.md) (28 query files), [persons](persons.md) (25 query files), [ar_trans](ar_trans.md) (13 query files), [payment_request_specifications](payment_request_specifications.md) (13 query files), [payment_requests](payment_requests.md) (12 query files).
- FK-linked tables: outgoing FK to [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md), [exchanged_file](exchanged_file.md), [payment_request_specifications](payment_request_specifications.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [ar_trans](ar_trans.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashcollectionservices](cashcollectionservices.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
