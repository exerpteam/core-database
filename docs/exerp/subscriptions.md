# subscriptions
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 2562 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | [subscriptions_state](../master%20tables/subscriptions_state.md) |
| `sub_state` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AWAITING ACTIVATION, AWAITING_ACTIVATION, AwaitingActivation). | `int4` | Yes | No | - | [subscriptions_sub_state](../master%20tables/subscriptions_sub_state.md) |
| `subscriptiontype_center` | Center component of the composite reference to the subscription type. | `int4` | Yes | No | [products](products.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`) | - |
| `subscriptiontype_id` | Identifier component of the composite reference to the subscription type. | `int4` | Yes | No | [products](products.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscriptiontype_center`, `subscriptiontype_id` -> `center`, `id`) | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | Yes | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `binding_end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `binding_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `individual_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `subscription_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `end_date_auto_binding_end_date` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `billed_until_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `refmain_center` | Center component of the composite reference to the related refmain record. | `int4` | Yes | No | - | - |
| `refmain_id` | Identifier component of the composite reference to the related refmain record. | `int4` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `orig_creator_center` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `orig_creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `saved_free_days` | Business attribute `saved_free_days` used by subscriptions workflows and reporting. | `int4` | No | No | - | - |
| `saved_free_months` | Business attribute `saved_free_months` used by subscriptions workflows and reporting. | `int4` | Yes | No | - | - |
| `invoiceline_center` | Center component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`)<br>[invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_id` | Identifier component of the composite reference to the related invoiceline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`)<br>[invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `adminfee_invoiceline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`invoiceline_center`, `invoiceline_id`, `adminfee_invoiceline_subid` -> `center`, `id`, `subid`) | - |
| `transferred_center` | Center component of the composite reference to the related transferred record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`transferred_center`, `transferred_id` -> `center`, `id`) | - |
| `transferred_id` | Identifier component of the composite reference to the related transferred record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`transferred_center`, `transferred_id` -> `center`, `id`) | - |
| `sub_comment` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `extended_to_center` | Center component of the composite reference to the related extended to record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`extended_to_center`, `extended_to_id` -> `center`, `id`) | - |
| `extended_to_id` | Identifier component of the composite reference to the related extended to record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`extended_to_center`, `extended_to_id` -> `center`, `id`) | - |
| `renewal_reminder_sent` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `renewal_policy_override` | Business attribute `renewal_policy_override` used by subscriptions workflows and reporting. | `int4` | Yes | No | - | - |
| `campaign_code_id` | Identifier of the related campaign codes record used by this row. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |
| `is_price_update_excluded` | Boolean flag indicating whether `price_update_excluded` applies to this record. | `bool` | Yes | No | - | - |
| `startup_free_period_id` | Identifier of the related startup campaign record used by this row. | `int4` | Yes | No | [startup_campaign](startup_campaign.md) via (`startup_free_period_id` -> `id`) | - |
| `stup_free_period_unit` | Business attribute `stup_free_period_unit` used by subscriptions workflows and reporting. | `int4` | Yes | No | - | - |
| `stup_free_period_value` | Business attribute `stup_free_period_value` used by subscriptions workflows and reporting. | `int4` | Yes | No | - | - |
| `stup_free_period_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `stup_freep_extends_binding` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `changed_to_center` | Center component of the composite reference to the related changed to record. | `int4` | Yes | No | - | - |
| `changed_to_id` | Identifier component of the composite reference to the related changed to record. | `int4` | Yes | No | - | - |
| `change_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `payment_agreement_center` | Center component of the composite reference to the payment agreement. | `int4` | Yes | No | - | [payment_agreements](payment_agreements.md) via (`payment_agreement_center`, `payment_agreement_id` -> `center`, `id`) |
| `payment_agreement_id` | Identifier component of the composite reference to the payment agreement. | `int4` | Yes | No | - | - |
| `payment_agreement_subid` | Business attribute `payment_agreement_subid` used by subscriptions workflows and reporting. | `int4` | Yes | No | - | - |
| `last_edit_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `is_change_restricted` | Boolean flag indicating whether `change_restricted` applies to this record. | `bool` | No | No | - | - |
| `reassigned_center` | Center component of the composite reference to the related reassigned record. | `int4` | Yes | No | - | - |
| `reassigned_id` | Identifier component of the composite reference to the related reassigned record. | `int4` | Yes | No | - | - |
| `rec_clipcard_clips` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Center component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_id` | Identifier component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | - | - |
| `assigned_staff_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `assigned_staff_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `installment_plan_id` | Identifier of the related installment plans record used by this row. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `reassigned_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `family_id` | Identifier of the related families record used by this row. | `int4` | Yes | No | [families](families.md) via (`family_id` -> `id`) | - |

# Relations
- Commonly used with: [persons](persons.md) (2204 query files), [products](products.md) (1846 query files), [centers](centers.md) (1599 query files), [subscriptiontypes](subscriptiontypes.md) (1321 query files), [person_ext_attrs](person_ext_attrs.md) (984 query files), [subscription_price](subscription_price.md) (794 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [centers](centers.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [startup_campaign](startup_campaign.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md); incoming FK from [clipcards](clipcards.md), [recurring_participations](recurring_participations.md), [subscription_addon](subscription_addon.md), [subscription_blocked_period](subscription_blocked_period.md), [subscription_change](subscription_change.md), [subscription_freeze_period](subscription_freeze_period.md), [subscription_price](subscription_price.md), [subscription_reduced_period](subscription_reduced_period.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscription_sales](subscription_sales.md), [subscriptionperiodparts](subscriptionperiodparts.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [add_on_product_definition](add_on_product_definition.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
