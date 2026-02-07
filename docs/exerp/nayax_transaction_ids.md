# nayax_transaction_ids
Operational table for nayax transaction ids records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `transaction_id` | Identifier of the related transaction record. | `int8` | No | Yes | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |

# Relations
