# entityidentifiers
Operational table for entityidentifiers records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 312 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `idmethod` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `IDENTITY` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `cached` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `ref_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - |
| `ref_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `entitystatus` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - |
| `invoiceline_center` | Center part of the reference to related invoiceline data. | `int4` | Yes | No | - | - |
| `invoiceline_id` | Identifier of the related invoiceline record. | `int4` | Yes | No | - | - |
| `invoiceline_subid` | Sub-identifier for related invoiceline detail rows. | `int4` | Yes | No | - | - |
| `assign_employee_center` | Center part of the reference to related assign employee data. | `int4` | Yes | No | - | - |
| `assign_employee_id` | Identifier of the related assign employee record. | `int4` | Yes | No | - | - |
| `block_employee_center` | Center part of the reference to related block employee data. | `int4` | Yes | No | - | - |
| `block_employee_id` | Identifier of the related block employee record. | `int4` | Yes | No | - | - |
| `sub_idmethod` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `source_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (256 query files), [centers](centers.md) (210 query files), [person_ext_attrs](person_ext_attrs.md) (180 query files), [subscriptions](subscriptions.md) (159 query files), [products](products.md) (141 query files), [subscriptiontypes](subscriptiontypes.md) (106 query files).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
