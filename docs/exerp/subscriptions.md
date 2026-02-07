# subscriptions
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 2562 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `sub_state` | Detailed sub-state code refining the main state. | `int4` | Yes | No | - | - |
| `subscriptiontype_center` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`) | - |
| `subscriptiontype_id` | Foreign key field linking this record to `products`. | `int4` | Yes | No | [products](products.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`) | - |
| `owner_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `binding_end_date` | Date for binding end. | `DATE` | Yes | No | - | - |
| `binding_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `individual_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `subscription_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `start_date` | Date when the record becomes effective. | `DATE` | Yes | No | - | - |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - |
| `end_date_auto_binding_end_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `billed_until_date` | Date for billed until. | `DATE` | Yes | No | - | - |
| `refmain_center` | Center part of the reference to related refmain data. | `int4` | Yes | No | - | - |
| `refmain_id` | Identifier of the related refmain record. | `int4` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `creator_center` | Center part of the reference to related creator data. | `int4` | Yes | No | - | - |
| `creator_id` | Identifier of the related creator record. | `int4` | Yes | No | - | - |
| `orig_creator_center` | Center part of the reference to related orig creator data. | `int4` | Yes | No | - | - |
| `orig_creator_id` | Identifier of the related orig creator record. | `int4` | Yes | No | - | - |
| `saved_free_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `saved_free_months` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `invoiceline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`)<br>[invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`)<br>[invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `adminfee_invoiceline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `transferred_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`transferred_center`, `transferred_id` -> `center`, `id`) | - |
| `transferred_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`transferred_center`, `transferred_id` -> `center`, `id`) | - |
| `sub_comment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `extended_to_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`extended_to_center`, `extended_to_id` -> `center`, `id`) | - |
| `extended_to_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`extended_to_center`, `extended_to_id` -> `center`, `id`) | - |
| `renewal_reminder_sent` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `renewal_policy_override` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `campaign_code_id` | Foreign key field linking this record to `campaign_codes`. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |
| `is_price_update_excluded` | Boolean flag indicating whether price update excluded applies. | `bool` | Yes | No | - | - |
| `startup_free_period_id` | Foreign key field linking this record to `startup_campaign`. | `int4` | Yes | No | [startup_campaign](startup_campaign.md) via (`startup_free_period_id` -> `id`) | - |
| `stup_free_period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `stup_free_period_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `stup_free_period_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `stup_freep_extends_binding` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `changed_to_center` | Center part of the reference to related changed to data. | `int4` | Yes | No | - | - |
| `changed_to_id` | Identifier of the related changed to record. | `int4` | Yes | No | - | - |
| `change_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `payment_agreement_center` | Center part of the reference to related payment agreement data. | `int4` | Yes | No | - | [payment_agreements](payment_agreements.md) via (`payment_agreement_center`, `payment_agreement_id` -> `center`, `id`) |
| `payment_agreement_id` | Identifier of the related payment agreement record. | `int4` | Yes | No | - | - |
| `payment_agreement_subid` | Sub-identifier for related payment agreement detail rows. | `int4` | Yes | No | - | - |
| `last_edit_time` | Epoch timestamp of the most recent user/system edit. | `int8` | Yes | No | - | - |
| `is_change_restricted` | Boolean flag indicating whether change restricted applies. | `bool` | No | No | - | - |
| `reassigned_center` | Center part of the reference to related reassigned data. | `int4` | Yes | No | - | - |
| `reassigned_id` | Identifier of the related reassigned record. | `int4` | Yes | No | - | - |
| `rec_clipcard_clips` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Center part of the reference to related buyoutfeeproduct data. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_id` | Identifier of the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `assigned_staff_center` | Center part of the reference to related assigned staff data. | `int4` | Yes | No | - | - |
| `assigned_staff_id` | Identifier of the related assigned staff record. | `int4` | Yes | No | - | - |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `reassigned_time` | Epoch timestamp for reassigned. | `int8` | Yes | No | - | - |
| `family_id` | Foreign key field linking this record to `families`. | `int4` | Yes | No | [families](families.md) via (`family_id` -> `id`) | - |

# Relations
- Commonly used with: [persons](persons.md) (2204 query files), [products](products.md) (1846 query files), [centers](centers.md) (1599 query files), [subscriptiontypes](subscriptiontypes.md) (1321 query files), [person_ext_attrs](person_ext_attrs.md) (984 query files), [subscription_price](subscription_price.md) (794 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [centers](centers.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [startup_campaign](startup_campaign.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md); incoming FK from [clipcards](clipcards.md), [recurring_participations](recurring_participations.md), [subscription_addon](subscription_addon.md), [subscription_blocked_period](subscription_blocked_period.md), [subscription_change](subscription_change.md), [subscription_freeze_period](subscription_freeze_period.md), [subscription_price](subscription_price.md), [subscription_reduced_period](subscription_reduced_period.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscription_sales](subscription_sales.md), [subscriptionperiodparts](subscriptionperiodparts.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
