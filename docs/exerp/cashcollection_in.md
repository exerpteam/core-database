# cashcollection_in
Financial/transactional table for cashcollection in records. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `cashcollectionservice` | Foreign key field linking this record to `cashcollectionservices`. | `int4` | Yes | No | [cashcollectionservices](cashcollectionservices.md) via (`cashcollectionservice` -> `id`) | - | `42` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `received_date` | Date for received. | `DATE` | No | No | - | - | `2025-01-31` |
| `generated_date` | Date for generated. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `delivery` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `errors` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `filename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `payment_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [cashcollectionservices](cashcollectionservices.md); incoming FK from [cashcollection_requests](cashcollection_requests.md).
- Second-level FK neighborhood includes: [cashcollection_out](cashcollection_out.md), [cashcollectioncases](cashcollectioncases.md), [exchanged_file](exchanged_file.md), [payment_request_specifications](payment_request_specifications.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
