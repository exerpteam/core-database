# cashcollection_out
Financial/transactional table for cashcollection out records. It is typically used where lifecycle state codes are present; it appears in approximately 4 query files; common companions include [cashcollection_requests](cashcollection_requests.md), [cashcollectioncases](cashcollectioncases.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `cashcollectionservice` | Foreign key field linking this record to `cashcollectionservices`. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - | `42` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `generated_date` | Date for generated. | `DATE` | No | No | - | - | `2025-01-31` |
| `sent_date` | Date for sent. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `amount_req` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `nb_req` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `delivery` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [cashcollection_requests](cashcollection_requests.md) (4 query files), [cashcollectioncases](cashcollectioncases.md) (3 query files), [account_receivables](account_receivables.md) (2 query files), [payment_request_specifications](payment_request_specifications.md) (2 query files), [ar_trans](ar_trans.md) (2 query files).
- FK-linked tables: outgoing FK to [cashcollectionservices](cashcollectionservices.md).
- Second-level FK neighborhood includes: [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
