# cashcollection_requests
Financial/transactional table for cashcollection requests records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 39 query files; common companions include [cashcollectioncases](cashcollectioncases.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [cashcollectioncases](cashcollectioncases.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `req_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `req_date` | Date for req. | `DATE` | No | No | - | - | `2025-01-31` |
| `req_delivery` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `file_out` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`file_out` -> `id`) | - | `42` |
| `xfr_delivery` | Foreign key field linking this record to `cashcollection_in`. | `int4` | Yes | No | [cashcollection_in](cashcollection_in.md) via (`xfr_delivery` -> `id`) | - | `42` |
| `payment_request_center` | Center part of the reference to related payment request data. | `int4` | Yes | No | - | [payment_requests](payment_requests.md) via (`payment_request_center`, `payment_request_id` -> `center`, `id`) | `101` |
| `payment_request_id` | Identifier of the related payment request record. | `int4` | Yes | No | - | - | `1001` |
| `payment_request_subid` | Sub-identifier for related payment request detail rows. | `int4` | Yes | No | - | - | `1` |
| `prscenter` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - | `42` |
| `prsid` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - | `42` |
| `prssubid` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`prscenter`, `prsid`, `prssubid` -> `center`, `id`, `subid`) | - | `42` |

# Relations
- Commonly used with: [cashcollectioncases](cashcollectioncases.md) (35 query files), [account_receivables](account_receivables.md) (28 query files), [persons](persons.md) (25 query files), [ar_trans](ar_trans.md) (13 query files), [payment_request_specifications](payment_request_specifications.md) (13 query files), [payment_requests](payment_requests.md) (12 query files).
- FK-linked tables: outgoing FK to [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md), [exchanged_file](exchanged_file.md), [payment_request_specifications](payment_request_specifications.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [ar_trans](ar_trans.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashcollectionservices](cashcollectionservices.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
