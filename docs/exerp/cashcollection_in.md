# cashcollection_in
Financial/transactional table for cashcollection in records. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `cashcollectionservice` | Foreign key field linking this record to `cashcollectionservices`. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `received_date` | Date for received. | `DATE` | No | No | - | - |
| `generated_date` | Date for generated. | `DATE` | Yes | No | - | - |
| `delivery` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `errors` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `filename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `payment_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [cashcollectionservices](cashcollectionservices.md); incoming FK from [cashcollection_requests](cashcollection_requests.md).
- Second-level FK neighborhood includes: [cashcollection_out](cashcollection_out.md), [cashcollectioncases](cashcollectioncases.md), [exchanged_file](exchanged_file.md), [payment_request_specifications](payment_request_specifications.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
