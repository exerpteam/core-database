# jbm_tx
Operational table for jbm tx records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Identifier for the related node entity used by this record. | `int4` | Yes | No | - | - |
| `transaction_id` | Primary key identifier for this record. | `int8` | No | Yes | - | - |
| `branch_qual` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `format_id` | Identifier for the related format entity used by this record. | `int4` | Yes | No | - | - |
| `global_txid` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
