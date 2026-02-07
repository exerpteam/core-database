# campaign_codes
Operational table for campaign codes records in the Exerp schema. It is typically used where it appears in approximately 139 query files; common companions include [privilege_usages](privilege_usages.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `campaign_id` | Identifier of the related campaign record. | `int4` | Yes | No | - | - | `1001` |
| `campaign_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `code` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - | `1738281600000` |
| `usage_time` | Epoch timestamp for usage. | `int8` | Yes | No | - | - | `1738281600000` |
| `usage_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- Commonly used with: [privilege_usages](privilege_usages.md) (120 query files), [products](products.md) (111 query files), [subscriptions](subscriptions.md) (104 query files), [persons](persons.md) (92 query files), [centers](centers.md) (85 query files), [startup_campaign](startup_campaign.md) (82 query files).
- FK-linked tables: incoming FK from [campaign_code_usages](campaign_code_usages.md), [privilege_usages](privilege_usages.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [privilege_grants](privilege_grants.md), [products](products.md), [recurring_participations](recurring_participations.md), [startup_campaign](startup_campaign.md).
