 SELECT
    c.name as Center,
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "1_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "1_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "1_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "1_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "1_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 1
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "1_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "2_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "2_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "2_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "2_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "2_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 2
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "2_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "3_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "3_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "3_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "3_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "3_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 3
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "3_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "4_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "4_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "4_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "4_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "4_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 4
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "4_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "5_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "5_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "5_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "5_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "5_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 5
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "5_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "6_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "6_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "6_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "6_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "6_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 6
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "6_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "7_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "7_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "7_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "7_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "7_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 7
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "7_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "8_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "8_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "8_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "8_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "8_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 8
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "8_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "9_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "9_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "9_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "9_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "9_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 9
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "9_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "10_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "10_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "10_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "10_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "10_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 10
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "10_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "11_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "11_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "11_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "11_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "11_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 11
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "11_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "12_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "12_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "12_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "12_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "12_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 12
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "12_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "13_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "13_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "13_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "13_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "13_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 13
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "13_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "14_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "14_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "14_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "14_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "14_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 14
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "14_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "15_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "15_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "15_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "15_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "15_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 15
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "15_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "16_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "16_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "16_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "16_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "16_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 16
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "16_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "17_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "17_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "17_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "17_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "17_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 17
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "17_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "18_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "18_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "18_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "18_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "18_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 18
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "18_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "19_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "19_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "19_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "19_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "19_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 19
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "19_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "20_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "20_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "20_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "20_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "20_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 20
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "20_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "21_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "21_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "21_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "21_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "21_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 21
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "21_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "22_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "22_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "22_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "22_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "22_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 22
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "22_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "23_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "23_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "23_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "23_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "23_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 23
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "23_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "24_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "24_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "24_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "24_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "24_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 24
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "24_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "25_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "25_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "25_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "25_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "25_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "25_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 25
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "26_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 26
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "26_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "27_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "27_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "27_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "27_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "27_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 27
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "27_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "28_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "28_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "28_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "28_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "28_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 28
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "28_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "29_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "29_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "29_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "29_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "29_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 29
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "29_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "30_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "30_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "30_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "30_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "30_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 30
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "30_Total New_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "31_Net Gain_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 604
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "31_Net Gain_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "31_Total Cancel_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 618
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "31_Total Cancel_2014",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2013
             THEN kd.value
         END) AS "31_Total New_2013",
     SUM(
         CASE
             WHEN kd.FIELD = 615
                 AND extract(DAY FROM kd.FOR_DATE) = 31
                 AND extract(YEAR FROM kd.FOR_DATE) = 2014
             THEN kd.value
         END) AS "31_615_2014"
         FROM
             KPI_DATA kd
             left join CENTERS c on kd.center = c.id
         WHERE
             kd.FIELD IN (615,618,604)
             AND extract(MONTH FROM kd.FOR_DATE) = extract(MONTH FROM CAST($$check_month$$ AS DATE))
 GROUP BY
     c.name
