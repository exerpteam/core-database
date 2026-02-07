 WITH
     prod AS
     (
         SELECT
             pr.CENTER,
             pr.ID,
             (
                 CASE
                     WHEN pr.GLOBALID = 'LOYALTY_PLAT_RETAIL_40_1USAGE'
                     THEN 'Platinum'
                     WHEN pr.GLOBALID = 'LOYALTY_GOLD_RETAIL_40_1USAGE'
                     THEN 'Gold'
                     WHEN pr.GLOBALID = 'LOYALTY_SILV_RETAIL_40_1USAGE'
                     THEN 'Silver'
                     ELSE 'Blue'
                 END) AS pr_type,
             pr.GLOBALID
         FROM
             PRODUCTS pr
         WHERE
             pr.GLOBALID IN ('LOYALTY_PLAT_RETAIL_40_1USAGE',
                             'LOYALTY_GOLD_RETAIL_40_1USAGE',
                             'LOYALTY_SILV_RETAIL_40_1USAGE',
                             'LOYALTY_BLUE_RETAIL_40_1USAGE')
         AND pr.BLOCKED = 0
     )
 SELECT
     -- p.center,
     -- count(*)
     CASE
         WHEN p.center IN (156,573,442,611,230,299)
         THEN 1
         WHEN p.center IN (212,418,552,133,729,650)
         THEN 2
         WHEN p.center IN (509,266,237,236,261,584)
         THEN 3
         WHEN p.center IN (218,213,214,425,255,270)
         THEN 4
         WHEN p.center IN (511,510,223,186,718,625)
         THEN 5
         WHEN p.center IN (410,166,256,560,142,534)
         THEN 6
         WHEN p.center IN (157,557,263,726,436,604)
         THEN 7
         WHEN p.center IN (222,724,253,167,555,500)
         THEN 8
         WHEN p.center IN (147,104,162,260,422,801)
         THEN 9
         WHEN p.center IN (512,432,437,732,421,541)
         THEN 10
         WHEN p.center IN (149,731,567,411,616,620)
         THEN 11
         WHEN p.center IN (433,423,163,610,434,705)
         THEN 12
         WHEN p.center IN (210,161,182,721,735,189)
         THEN 13
         WHEN p.center IN (531,428,563,514,603,267)
         THEN 14
         WHEN p.center IN (208,551,521,101,717,629)
         THEN 15
         WHEN p.center IN (148,258,538,171,532,269)
         THEN 16
         WHEN p.center IN (431,262,572,714,558,802)
         THEN 17
         WHEN p.center IN (216,415,713,592,703,613)
         THEN 18
         WHEN p.center IN (146,219,533,561,215,617)
         THEN 19
         WHEN p.center IN (517,116,738,605,593,254)
         THEN 20
         WHEN p.center IN (513,114,539,589,710,537)
         THEN 21
         WHEN p.center IN (209,506,741,131,426,507)
         THEN 22
         WHEN p.center IN (575,549,727,586,723,185)
         THEN 23
         WHEN p.center IN (412,530,730,550,725,231)
         THEN 24
         WHEN p.center IN (562,504,577,587,576,622)
         THEN 25
         WHEN p.center IN (220,221,187,740,183,252)
         THEN 26
         WHEN p.center IN (152,516,566,568,424,615)
         THEN 27
         WHEN p.center IN (217,106,234,722,736,743)
         THEN 28
         WHEN p.center IN (556,536,207,132,614,232,499)
         THEN 29
         WHEN p.center IN (206,420,739,591,569,594,623)
         THEN 30
         WHEN p.center IN (564,414,588,413,596,612,419)
         THEN 31
         WHEN p.center IN (508,543,583,574,651,427,400)
         THEN 32
         WHEN p.center IN (607,178,728,416,417,202,799)
         THEN 33
         WHEN p.center IN (130,715,545,606,188,619,100)
         THEN 34
         WHEN p.center IN (251,438,529,554,227,579,268)
         THEN 35
         WHEN p.center IN (158,233,737,733,235,618,700)
         THEN 36
         WHEN p.center IN (429,544,540,501,240,578,744)
         THEN 37
         WHEN p.center IN (154,430,173,184,742,226,609)
         THEN 38
         WHEN p.center IN (582,224,547,585,205,435,652)
         THEN 39
         WHEN p.center IN (522,548,580,515,172,716,608)
         THEN 40
         ELSE 1000
     END            AS Threadgroup,
     p.center       AS personCenter,
     p.id           AS personId,
     --pea.txtvalue,
     prod.center    AS productCenter,
     prod.id        AS productId,
     --prod.globalid,
     1              AS quantity,
     'CASH_ACCOUNT' AS paymentMethod
 FROM
     persons p
 JOIN
     person_ext_attrs pea
 ON
     pea.personcenter = p.center
 AND pea.personid = p.id
 AND pea.name = 'UNBROKENMEMBERSHIPGROUPALL'
 JOIN
     prod
 ON
     prod.center = p.center
 AND prod.pr_type = pea.txtvalue
 WHERE
     p.status IN (1,3)
 AND p.persontype NOT IN (2,8)
 ORDER BY
 Threadgroup,
 personcenter
