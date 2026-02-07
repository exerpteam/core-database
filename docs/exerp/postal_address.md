# postal_address
Operational table for postal address records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `postal_code_id` | Foreign key field linking this record to `postal_code`. | `int4` | Yes | No | [postal_code](postal_code.md) via (`postal_code_id` -> `id`) | - |
| `postal_area_id` | Foreign key field linking this record to `postal_area`. | `int4` | Yes | No | [postal_area](postal_area.md) via (`postal_area_id` -> `id`) | - |
| `co_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `street_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `street_number` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `address_line_1` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `address_line_2` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |
| `address_line_3` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [postal_area](postal_area.md), [postal_code](postal_code.md); incoming FK from [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [payment_accounts](payment_accounts.md), [postal_code_area_mapping](postal_code_area_mapping.md).
