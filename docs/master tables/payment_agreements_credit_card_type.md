# payment_agreements.credit_card_type
Maps code values from `payment_agreements.credit_card_type` to human-readable labels using mappings found in `queries/redshift/public` and `queries/extracts`.

# Structure
|id|name|data type|table reference|
|---|---|---|---|
|1|VISA|integer|[payment_agreements](../exerp/payment_agreements.md)|
|2|MASTERCARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|3|MAESTRO|integer|[payment_agreements](../exerp/payment_agreements.md)|
|4|DANKORT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|5|AMERICANEXPRESS|integer|[payment_agreements](../exerp/payment_agreements.md)|
|6|DINERSCLUB|integer|[payment_agreements](../exerp/payment_agreements.md)|
|7|JCB|integer|[payment_agreements](../exerp/payment_agreements.md)|
|8|SPARBANKEN|integer|[payment_agreements](../exerp/payment_agreements.md)|
|9|SHELL|integer|[payment_agreements](../exerp/payment_agreements.md)|
|10|NORSKHYDROUNOX|integer|[payment_agreements](../exerp/payment_agreements.md)|
|11|OKQ8|integer|[payment_agreements](../exerp/payment_agreements.md)|
|12|PREEM|integer|[payment_agreements](../exerp/payment_agreements.md)|
|13|STATOIL|integer|[payment_agreements](../exerp/payment_agreements.md)|
|14|STATOILROUTEX|integer|[payment_agreements](../exerp/payment_agreements.md)|
|15|VOLVO|integer|[payment_agreements](../exerp/payment_agreements.md)|
|16|VISAELECTRON|integer|[payment_agreements](../exerp/payment_agreements.md)|
|17|VISA CREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|18|BT TEST HOST|integer|[payment_agreements](../exerp/payment_agreements.md)|
|19|TIME|integer|[payment_agreements](../exerp/payment_agreements.md)|
|20|SOLO|integer|[payment_agreements](../exerp/payment_agreements.md)|
|21|LASER|integer|[payment_agreements](../exerp/payment_agreements.md)|
|22|LTF|integer|[payment_agreements](../exerp/payment_agreements.md)|
|23|CAF|integer|[payment_agreements](../exerp/payment_agreements.md)|
|24|CREATION|integer|[payment_agreements](../exerp/payment_agreements.md)|
|25|CLYDESDALE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|26|BHS GOLD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|27|MOTHERCARE CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|28|BURTON MENSWEAR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|29|BA AIRPLUS|integer|[payment_agreements](../exerp/payment_agreements.md)|
|30|EDC|integer|[payment_agreements](../exerp/payment_agreements.md)|
|31|VISA DEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|32|POSTCARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|33|JELMOLI BONUS CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|34|EC|integer|[payment_agreements](../exerp/payment_agreements.md)|
|35|V PAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|36|BEEPTIFY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|37|EXTERNAL DEVICE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|38|INTERAC|integer|[payment_agreements](../exerp/payment_agreements.md)|
|39|DISCOVER|integer|[payment_agreements](../exerp/payment_agreements.md)|
|40|UNIONPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|41|ALLSTAR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|42|ARCADIA GROUP CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|43|FCUK CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|44|MASTERCARD DEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|45|IKEA HOME CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|46|HFC STORE CARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|47|ACCEL|integer|[payment_agreements](../exerp/payment_agreements.md)|
|48|AFFN|integer|[payment_agreements](../exerp/payment_agreements.md)|
|49|ALIPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|50|BCMC|integer|[payment_agreements](../exerp/payment_agreements.md)|
|51|CARNETDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|52|CARTEBANCAIRE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|53|CABAL|integer|[payment_agreements](../exerp/payment_agreements.md)|
|54|CODENSA|integer|[payment_agreements](../exerp/payment_agreements.md)|
|55|CU24|integer|[payment_agreements](../exerp/payment_agreements.md)|
|56|EFTPOS_AUSTRALIA|integer|[payment_agreements](../exerp/payment_agreements.md)|
|57|ELOCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|58|INTERLINK|integer|[payment_agreements](../exerp/payment_agreements.md)|
|59|NARANIA|integer|[payment_agreements](../exerp/payment_agreements.md)|
|60|NYCE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|61|PULSE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|62|SHAZAM_PINLESS|integer|[payment_agreements](../exerp/payment_agreements.md)|
|63|STAR|integer|[payment_agreements](../exerp/payment_agreements.md)|
|64|VIAS|integer|[payment_agreements](../exerp/payment_agreements.md)|
|65|WAREHOUSE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|66|MCCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|67|MCSTANDARDCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|68|MCSTANDARDDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|69|MCPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|70|MCPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|71|MCSUPERPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|72|MCSUPERPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|73|MCCOMMERCIALCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|74|MCCOMMERCIALDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|75|MCCOMMERCIALPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|76|MCCOMMERCIALPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|77|MCCORPORATECREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|78|MCCORPORATEDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|79|MCPURCHASINGCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|80|MCPURCHASINGDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|81|MCFLEETCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|82|MCFLEETDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|83|MCPRO|integer|[payment_agreements](../exerp/payment_agreements.md)|
|84|MC_APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|85|MC_ANDROIDPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|86|BIJCARD|integer|[payment_agreements](../exerp/payment_agreements.md)|
|87|VISASTANDARDCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|88|VISASTANDARDDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|89|VISAPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|90|VISAPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|91|VISASUPERPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|92|VISASUPERPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|93|VISACOMMERCIALCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|94|VISACOMMERCIALDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|95|VISACOMMERCIALPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|96|VISACOMMERCIALPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|97|VISACOMMERCIALSUPERPREMIUMCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|98|VISACOMMERCIALSUPERPREMIUMDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|99|VISACORPORATECREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|100|VISACORPORATEDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|101|VISAPURCHASINGCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|102|VISAPURCHASINGDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|103|VISAFLEETCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|104|VISAFLEETDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|105|VISADANKORT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|106|VISAPROPREITARY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|107|VISA_APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|108|VISA_ANDROIDPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|109|AMEX_APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|110|BOLETOBANCARIO_SANTANDER|integer|[payment_agreements](../exerp/payment_agreements.md)|
|111|DINERS_APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|112|DIRECTEBANKING|integer|[payment_agreements](../exerp/payment_agreements.md)|
|113|DISCOVER_APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|114|DOTPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|115|IDEALBN|integer|[payment_agreements](../exerp/payment_agreements.md)|
|116|IDEALING|integer|[payment_agreements](../exerp/payment_agreements.md)|
|117|IDEALRABOBANK|integer|[payment_agreements](../exerp/payment_agreements.md)|
|118|PAYPAL|integer|[payment_agreements](../exerp/payment_agreements.md)|
|119|SEPADIRECTDEBIT_AUTHCAP|integer|[payment_agreements](../exerp/payment_agreements.md)|
|120|DEPADIRECTDEBIT_RECEIVED|integer|[payment_agreements](../exerp/payment_agreements.md)|
|121|CUPCREDIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|122|CUPDEBIT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|123|CARD ON FILE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|124|MADA|integer|[payment_agreements](../exerp/payment_agreements.md)|
|125|APPLEPAY|integer|[payment_agreements](../exerp/payment_agreements.md)|
|126|PAYWITHGOOGLE|integer|[payment_agreements](../exerp/payment_agreements.md)|
|127|TWINT|integer|[payment_agreements](../exerp/payment_agreements.md)|
|128|ACH|integer|[payment_agreements](../exerp/payment_agreements.md)|
|129|PAYBYBANK|integer|[payment_agreements](../exerp/payment_agreements.md)|
|1000|OTHER|integer|[payment_agreements](../exerp/payment_agreements.md)|
