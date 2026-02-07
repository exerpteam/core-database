# postal_address
Operational table for postal address records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `postal_code_id` | Identifier of the related postal code record used by this row. | `int4` | Yes | No | [postal_code](postal_code.md) via (`postal_code_id` -> `id`) | - |
| `postal_area_id` | Identifier of the related postal area record used by this row. | `int4` | Yes | No | [postal_area](postal_area.md) via (`postal_area_id` -> `id`) | - |
| `co_name` | Business attribute `co_name` used by postal address workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `street_name` | Business attribute `street_name` used by postal address workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `street_number` | Business attribute `street_number` used by postal address workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `address_line_1` | Business attribute `address_line_1` used by postal address workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `address_line_2` | Business attribute `address_line_2` used by postal address workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `address_line_3` | Business attribute `address_line_3` used by postal address workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [postal_area](postal_area.md), [postal_code](postal_code.md); incoming FK from [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [payment_accounts](payment_accounts.md), [postal_code_area_mapping](postal_code_area_mapping.md).
