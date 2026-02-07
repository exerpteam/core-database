# cashcollection_in
Financial/transactional table for cashcollection in records. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `cashcollectionservice` | Identifier of the related cashcollectionservices record used by this row. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `received_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `generated_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `delivery` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `errors` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `filename` | Business attribute `filename` used by cashcollection in workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `total_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `payment_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [cashcollectionservices](cashcollectionservices.md); incoming FK from [cashcollection_requests](cashcollection_requests.md).
- Second-level FK neighborhood includes: [cashcollection_out](cashcollection_out.md), [cashcollectioncases](cashcollectioncases.md), [exchanged_file](exchanged_file.md), [payment_request_specifications](payment_request_specifications.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
