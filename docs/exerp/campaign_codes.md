# campaign_codes
Operational table for campaign codes records in the Exerp schema. It is typically used where it appears in approximately 139 query files; common companions include [privilege_usages](privilege_usages.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `campaign_id` | Identifier for the related campaign entity used by this record. | `int4` | Yes | No | - | - |
| `campaign_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `code` | Operational field `code` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `usage_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `usage_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [privilege_usages](privilege_usages.md) (120 query files), [products](products.md) (111 query files), [subscriptions](subscriptions.md) (104 query files), [persons](persons.md) (92 query files), [centers](centers.md) (85 query files), [startup_campaign](startup_campaign.md) (82 query files).
- FK-linked tables: incoming FK from [campaign_code_usages](campaign_code_usages.md), [privilege_usages](privilege_usages.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [privilege_grants](privilege_grants.md), [products](products.md), [recurring_participations](recurring_participations.md), [startup_campaign](startup_campaign.md).
