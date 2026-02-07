# converter_entity_state
Operational table for converter entity state records in the Exerp schema. It is typically used where it appears in approximately 39 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entitytype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(40)` | No | No | - | - |
| `oldentityid` | Business attribute `oldentityid` used by converter entity state workflows and reporting. | `VARCHAR(255)` | No | No | - | - |
| `newentitycenter` | Center component of the composite reference to the related newentity record. | `int4` | No | No | - | - |
| `newentityid` | Identifier component of the composite reference to the related newentity record. | `int4` | No | No | - | - |
| `newentitysubid` | Business attribute `newentitysubid` used by converter entity state workflows and reporting. | `int4` | Yes | No | - | - |
| `writername` | Business attribute `writername` used by converter entity state workflows and reporting. | `VARCHAR(40)` | No | No | - | - |
| `lastupdated` | Business attribute `lastupdated` used by converter entity state workflows and reporting. | `TIMESTAMP` | No | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (37 query files), [subscriptions](subscriptions.md) (29 query files), [products](products.md) (22 query files), [person_ext_attrs](person_ext_attrs.md) (20 query files), [subscriptiontypes](subscriptiontypes.md) (18 query files), [subscription_price](subscription_price.md) (14 query files).
