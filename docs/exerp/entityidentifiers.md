# entityidentifiers
Operational table for entityidentifiers records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 312 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `idmethod` | Operational field `idmethod` used in query filtering and reporting transformations. | `int4` | No | No | - | [entityidentifiers_idmethod](../master%20tables/entityidentifiers_idmethod.md) |
| `IDENTITY` | Operational field `IDENTITY` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `cached` | Business attribute `cached` used by entityidentifiers workflows and reporting. | `int8` | Yes | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `int4` | No | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `entitystatus` | State indicator used to control lifecycle transitions and filtering. | `int4` | No | No | - | [entityidentifiers_entitystatus](../master%20tables/entityidentifiers_entitystatus.md) |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | Yes | No | - | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | Yes | No | - | - |
| `invoiceline_subid` | Operational field `invoiceline_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `assign_employee_center` | Center component of the composite reference to the related assign employee record. | `int4` | Yes | No | - | - |
| `assign_employee_id` | Identifier component of the composite reference to the related assign employee record. | `int4` | Yes | No | - | - |
| `block_employee_center` | Center component of the composite reference to the related block employee record. | `int4` | Yes | No | - | - |
| `block_employee_id` | Identifier component of the composite reference to the related block employee record. | `int4` | Yes | No | - | - |
| `sub_idmethod` | Business attribute `sub_idmethod` used by entityidentifiers workflows and reporting. | `int4` | Yes | No | - | - |
| `source_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (256 query files), [centers](centers.md) (210 query files), [person_ext_attrs](person_ext_attrs.md) (180 query files), [subscriptions](subscriptions.md) (159 query files), [products](products.md) (141 query files), [subscriptiontypes](subscriptiontypes.md) (106 query files).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
