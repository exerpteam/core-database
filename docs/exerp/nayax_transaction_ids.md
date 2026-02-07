# nayax_transaction_ids
Operational table for nayax transaction ids records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `transaction_id` | Identifier of the related transaction record. | `int8` | No | Yes | - | - | `1001` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |

# Relations
