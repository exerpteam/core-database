# clearinghouse_cred_receivers
Operational table for clearinghouse cred receivers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `clearinghouse` | Foreign key field linking this record to `clearinghouse_creditors`. | `int4` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - | `42` |
| `creditor_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `VARCHAR(16)` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - | `1001` |
| `receiver_clearinghouse` | Foreign key field linking this record to `clearinghouse_creditors`. | `int4` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`receiver_clearinghouse`, `receiver_creditor_id` -> `clearinghouse`, `creditor_id`) | - | `42` |
| `receiver_creditor_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `VARCHAR(16)` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`receiver_clearinghouse`, `receiver_creditor_id` -> `clearinghouse`, `creditor_id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [clearinghouse_creditors](clearinghouse_creditors.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clearinghouses](clearinghouses.md), [payment_agreements](payment_agreements.md), [payment_requests](payment_requests.md).
