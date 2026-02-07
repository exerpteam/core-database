# cashcollection_out
Financial/transactional table for cashcollection out records. It is typically used where lifecycle state codes are present; it appears in approximately 4 query files; common companions include [cashcollection_requests](cashcollection_requests.md), [cashcollectioncases](cashcollectioncases.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `cashcollectionservice` | Identifier of the related cashcollectionservices record used by this row. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `generated_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `sent_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `amount_req` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `nb_req` | Business attribute `nb_req` used by cashcollection out workflows and reporting. | `int4` | No | No | - | - |
| `delivery` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [cashcollection_requests](cashcollection_requests.md) (4 query files), [cashcollectioncases](cashcollectioncases.md) (3 query files), [account_receivables](account_receivables.md) (2 query files), [payment_request_specifications](payment_request_specifications.md) (2 query files), [ar_trans](ar_trans.md) (2 query files).
- FK-linked tables: outgoing FK to [cashcollectionservices](cashcollectionservices.md).
- Second-level FK neighborhood includes: [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
