# clearinghouse_cred_receivers
Operational table for clearinghouse cred receivers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `clearinghouse` | Identifier of the related clearinghouse creditors record used by this row. | `int4` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `creditor_id` | Identifier of the related clearinghouse creditors record used by this row. | `VARCHAR(16)` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `receiver_clearinghouse` | Identifier of the related clearinghouse creditors record used by this row. | `int4` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`receiver_clearinghouse`, `receiver_creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `receiver_creditor_id` | Identifier of the related clearinghouse creditors record used by this row. | `VARCHAR(16)` | No | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`receiver_clearinghouse`, `receiver_creditor_id` -> `clearinghouse`, `creditor_id`) | - |

# Relations
- FK-linked tables: outgoing FK to [clearinghouse_creditors](clearinghouse_creditors.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [centers](centers.md), [clearinghouses](clearinghouses.md), [payment_agreements](payment_agreements.md), [payment_requests](payment_requests.md).
