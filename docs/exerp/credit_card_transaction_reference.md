# credit_card_transaction_reference
Operational table for credit card transaction reference records in the Exerp schema. It is typically used where it appears in approximately 2 query files; common companions include [cashregistertransactions](cashregistertransactions.md), [credit_note_lines_mt](credit_note_lines_mt.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `invoice_payment_session_id` | Identifier of the related invoice payment session record. | `int4` | No | No | - | - | `1001` |
| `transaction_reference` | Table field used by operational and reporting workloads. | `json` | No | No | - | - | `Sample` |

# Relations
- Commonly used with: [cashregistertransactions](cashregistertransactions.md) (2 query files), [credit_note_lines_mt](credit_note_lines_mt.md) (2 query files), [credit_notes](credit_notes.md) (2 query files), [creditcardtransactions](creditcardtransactions.md) (2 query files), [invoices](invoices.md) (2 query files), [persons](persons.md) (2 query files).
