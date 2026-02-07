# startup_campaign_subscription
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 10 query files; common companions include [startup_campaign](startup_campaign.md), [area_centers](area_centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `startup_campaign` | Identifier of the related startup campaign record used by this row. | `int4` | Yes | No | [startup_campaign](startup_campaign.md) via (`startup_campaign` -> `id`) | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `text(2147483647)` | No | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [startup_campaign](startup_campaign.md) (10 query files), [area_centers](area_centers.md) (9 query files), [areas](areas.md) (9 query files), [centers](centers.md) (9 query files), [privilege_grants](privilege_grants.md) (9 query files), [product_group](product_group.md) (9 query files).
- FK-linked tables: outgoing FK to [startup_campaign](startup_campaign.md).
- Second-level FK neighborhood includes: [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
