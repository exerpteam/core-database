# centers
Operational table for centers records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 3999 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `shortname` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `startupdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `phone_number` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `fax_number` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `email` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `member@example.com` |
| `org_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `address1` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `address2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `address3` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `country` | Foreign key field linking this record to `countries`. | `text(2147483647)` | Yes | No | [countries](countries.md) via (`country` -> `id`)<br>[zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - | `SE` |
| `zipcode` | Foreign key field linking this record to `zipcodes`. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - | `12345` |
| `latitude` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `longitude` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `center_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `city` | Foreign key field linking this record to `zipcodes`. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - | `Sample value` |
| `org_code2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `web_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `website_url` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `manager_center` | Center part of the reference to related manager data. | `int4` | Yes | No | - | - | `101` |
| `manager_id` | Identifier of the related manager record. | `int4` | Yes | No | - | - | `1001` |
| `asst_manager_center` | Center part of the reference to related asst manager data. | `int4` | Yes | No | - | - | `101` |
| `asst_manager_id` | Identifier of the related asst manager record. | `int4` | Yes | No | - | - | `1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `time_zone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `facility_url` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `STATE` | State code representing the current processing state. | `VARCHAR(60)` | Yes | No | - | - | `1` |

# Relations
- Commonly used with: [persons](persons.md) (3073 query files), [products](products.md) (1880 query files), [subscriptions](subscriptions.md) (1599 query files), [person_ext_attrs](person_ext_attrs.md) (1210 query files), [account_receivables](account_receivables.md) (1024 query files), [subscriptiontypes](subscriptiontypes.md) (927 query files).
- FK-linked tables: outgoing FK to [countries](countries.md), [zipcodes](zipcodes.md); incoming FK from [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md), [delivery_lines_mt](delivery_lines_mt.md), [inventory](inventory.md), [invoice_lines_mt](invoice_lines_mt.md), [kpi_data](kpi_data.md), [licenses](licenses.md), [persons](persons.md), [products](products.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [vending_machine](vending_machine.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accounts](accounts.md), [activity](activity.md), [areas](areas.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
