# center_ext_attrs
Operational table for center ext attrs records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 76 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `center_id` | Foreign key field linking this record to `centers`. | `int4` | No | No | [centers](centers.md) via (`center_id` -> `id`) | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `txt_value` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mime_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mime_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `last_edit_time` | Epoch timestamp of the most recent user/system edit. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [centers](centers.md) (69 query files), [persons](persons.md) (54 query files), [products](products.md) (38 query files), [product_group](product_group.md) (32 query files), [invoice_lines_mt](invoice_lines_mt.md) (29 query files), [invoices](invoices.md) (28 query files).
- FK-linked tables: outgoing FK to [centers](centers.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
