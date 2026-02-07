 SELECT
     center, id, persons.LASTNAME, persons.ADDRESS1, persons.ADDRESS2, persons.ZIPCODE, persons.CITY FROM
     persons
 WHERE
     persons.SEX = 'C'
     AND persons.LASTNAME IN ('Acta ASA','Advokatfirma DLA Piper DA','Advokatfirma Ræder DA','Advokatfirmaet Schjødt AS',
     'Advokatfirmaet Selmer DA','Affecto Norway AS','AGA AS','Alliance Arkitekter','Alliero Holding AS',
     'Amesto Business Partner As','Anticimex AS','Arcusgruppen BIL','Arkwright Norway AS',
     'Astrazeneca AS Sport&fritid B.I.L','Augustin Hotel','Auster Salonger AS','Auto-trio AS','Barnehage Gruppen AS',
     'Beijer Electronics','Bekk Consulting AS','Betonmast Anlegg AS','Bibliotekenes It-senter AS','Biotec Pharmacon ASA'
     ,'BIS Industrier AS','BNP Paribas','Bull & Co. Advokatfirma AS','Bølgen Og Moi AS Avd Stavanger',
     'Carrier Refrigeration Norway AS','Cochs Pensjonat AS','Coloplast Norge AS','Confirmit','Deli De Luca Norge',
     'Det Norske Teatret Att/tone Therese Lindquist','Dugg Frisører Avd. Frogner Og Grynerløkka,hagen Og Trønsdal AS',
     'E.merck AB','Elkjøp Nordic AS','Erik Arnesen Helsfyr AS','Fana Sparebank BIL','Forlagssentralen ANS',
     'Forskningsstiftelsen Fafo','Gard AS','Hafslund Nett AS','Handicare AS','Hjellnes Consult AS','Holeglass',
     'Holte Byggsafe AS','HSH - Handels- Og Servicenæringens Hovedorganisasjon',
     'Høgskolen I Akershus, HIAK (ansatte), Fakturamottak','Høgskolen I Bergen','Imitch Bragernes','Infotjenester',
     'Jernbanens Sparebank','Jordan AS','Kamstrup EMS AS','Kavli','Klipperiet Hår Og Sminkeverksted AS',
     'Kluge Advokatfirmaet ANS','Know IT Objectnet AS','Kone AS','Lindab AS','Lyberg & Partnere','Macks Ølbryggeri AS',
     'Making Waves AS','MAN Last Og Buss AS Avd. Skårer','McCann World Group','MEC','Mitsui & Co Norway','Mnemonic AS',
     'Moelven Nordia AS','MSC Norway AS','Nemo Engineering AS','Nessco-gruppen AS','Nettpartner Region Oslo',
     'Nextgen Tel V/b.l.','NKI Bedriftsidrettslag V/niels Christian Moe','Norges Musikkkorps Forbund ( Bergen)',
     'Norges Røde Kors BIL V/ Jorunn Jensen','Norgesgruppen HR Tjenester AS','Norsk Folkemuseum','Norske Selskab',
     'Opera Software AS','Ortopediteknikk AS','Oslo Kino AS, Hvitt Partoutkort','Oslo Patentkontor AS','Petrol BIL',
     'Philips Norge AS','Pon Equipment As','Pon Power As','Premiere Global Services','Rieber & Sønn BIL','Riksteatret',
     'Scandpower AS','Schlumberger Bedriftsidrettslag Stavanger','Schlumberger Information Solutions',
     'Schneider Electric Buildings Norway AS','Siemens AS Healthcare','Skan Kontroll','SKF Norge AS','Snap Drive AS',
     'Solli Sykehus','Spama AS','SPT Group AS','Steinar Groland V/ Ife Bil','Steria AS','Sylinder As',
     'Sølvpilen Bedriftsidrettslag','Tamrotor Marine Compressors','Tarantell AS','Tendenz Hårpleie AS',
     'Texas Instruments Norway AS','Tomter FUS Barnehage AS','TONO','Total E&P Norge AS','Transocean AS',
     'Tårnsvalen Familebarnehage AS','Unifeeder AS','Verdane Capital Advisors','Visit Oslo','Voksenopplæringsforbundet',
     'Westerngeco Manufacturing Bergen')
