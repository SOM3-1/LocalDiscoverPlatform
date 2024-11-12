--Query 1: Top Monthly Demographic, Location, and Activity by Bookings
-- This query identifies the most popular activity for each demographic group at various locations every month, based on the highest number of bookings. The purpose is to see which activities attract the most bookings per demographic, location, and month.

SET PAGESIZE 1000
SET LINESIZE 340
TTITLE LEFT "Top Monthly Demographic, Location, and Activity by Bookings"
COLUMN "Year" FORMAT A40
COLUMN "Month" FORMAT A40
COLUMN "Demographic_Type" FORMAT A40
COLUMN "Location_Name" FORMAT A40
COLUMN "Activity_Category" FORMAT A40
COLUMN "Total_Bookings" FORMAT 99999
SELECT 
    Year,
    Month,
    Demographic_Type,
    Location_Name,
    Activity_Category,
    Total_Bookings
FROM (
    SELECT 
        EXTRACT(YEAR FROM b.Date_Of_Booking) AS Year,
        EXTRACT(MONTH FROM b.Date_Of_Booking) AS Month,
        t.Demographic_Type,
        l.Location_Name,
        ic.Category_Name AS Activity_Category,
        COUNT(b.Booking_ID) AS Total_Bookings,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM b.Date_Of_Booking), EXTRACT(MONTH FROM b.Date_Of_Booking)
                           ORDER BY COUNT(b.Booking_ID) DESC) AS Row_Num
    FROM 
        Fall24_S003_T8_Bookings b
    JOIN 
        Fall24_S003_T8_Travelers t ON b.Traveler_ID = t.T_ID
    JOIN 
        Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
    JOIN 
        Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
    GROUP BY 
        EXTRACT(YEAR FROM b.Date_Of_Booking), 
        EXTRACT(MONTH FROM b.Date_Of_Booking),
        t.Demographic_Type,
        l.Location_Name,
        ic.Category_Name
) 
WHERE 
    Row_Num = 1
ORDER BY 
    Year desc, Month desc;


/* 
Result:
-- YEAR      MONTH DEMOGRAPHIC_TYPE      LOCATION_NAME   ACTIVITY_CATEGORY      TOTAL_BOOKINGS
-- ---------- ---------- ------------------ ------------------- ------------------------- --------------
-- 2024      9        Senior Citizen       Lexington        Music Festival          2
-- 2024      8        Group                Lexington        Music Festival          2
-- 2024      7        Couple               Lexington        Music Festival          1
-- 2024      6        Senior Citizen       Plano            Sports Events           1
-- 2024      5        Senior Citizen       Lexington        Art and Craft           4
-- 2024      4        Senior Citizen       Lexington        Art and Craft           1
-- 2024      3        Senior Citizen       Lexington        Historical Sites        1
-- 2024      2        Couple               Lexington        Adventure               1
-- 2024      1        Senior Citizen       Plano            Road Trip               1
-- 2023      11       Couple               Lexington        Sports Events           1
-- 10 rows selected.
*/

--Query 2: Customer Retention and Loyalty Analysis
-- This query analyzes customer retention by identifying travelers who have made multiple bookings and calculating their average spending. The goal is to understand which customers are the most loyal (based on repeat bookings) and gauge their average spending levels.

SET PAGESIZE 1000
SET LINESIZE 100

TTITLE LEFT "Customer Retention and Loyalty Analysis"

COLUMN Traveler_ID FORMAT A10
COLUMN Traveler_Name FORMAT A20
COLUMN Repeat_Bookings FORMAT 9999
COLUMN Average_Spend FORMAT 99999.99
SELECT 
    t.T_ID AS Traveler_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    COUNT(DISTINCT b.Booking_ID) AS Repeat_Bookings,
    ROUND(AVG(b.Amount_Paid), 2) AS Average_Spend
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
WHERE 
    b.Booking_Status_ID = (SELECT Status_ID FROM Fall24_S003_T8_Booking_Status WHERE Status_Name = 'Confirmed') 
    AND b.Amount_Paid > 0  
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name
HAVING 
    COUNT(b.Booking_ID) > 1
ORDER BY 
    Repeat_Bookings DESC,
    Average_Spend DESC FETCH first 10 rows only;

/*
Result:
-- TRAVELER_ID    TRAVELER_NAME             REPEAT_BOOKINGS    AVERAGE_SPEND
-- --------------  ------------------------- ------------------ -------------
-- T00036         Sarah Williams            6                   1540.18
-- T00021         James Thomas              3                   2512.64
-- T00017         Mario Wood                3                   1857.82
-- T00013         David Tran                3                   1745.45
-- T00027         Andrea Garcia             2                   3722.31
-- T00022         Veronica Owen             2                   3534.07
-- T00020         Sonya Phillips            2                   3107.89
-- T00040         Steven Sparks             2                   2582.89
-- T00037         Erin Watson               2                   2240.07
-- T00041         Tammy Garza               2                   907.07
-- 10 rows selected.
*/

-- Query 3: Experience Diversity Analysis Using Rollup
-- This query provides an analysis of booking distribution across different locations. It counts the total bookings for each location, including subtotals for each location and a grand total across all locations. This enables a clear view of how bookings are spread geographically, helping to identify popular locations based on booking volume.

SET PAGESIZE 1000
SET LINESIZE 120
TTITLE LEFT "Booking Distribution by Location with Totals"
COLUMN Destination FORMAT A15
COLUMN Total_Bookings FORMAT 99999

SELECT 
    l.Location_Name AS Destination,
    COUNT(b.Booking_ID) AS Total_Bookings
FROM 
    Fall24_S003_T8_Locations l
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
JOIN 
    Fall24_S003_T8_Experience e ON sl.Schedule_ID = e.Schedule_ID
LEFT JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    ROLLUP (l.Location_Name)
ORDER BY 
    Destination;


/*
Result:
-- DESTINATION         EXPERIENCE_CATEGORY            TOTAL_EXPERIENCES
-- ------------------- -------------------------------- -----------------
-- Lexington           Adventure                       2
-- Lexington           Art and Craft                   5
-- Lexington           Beach                           1
-- Lexington           Cultural Experience             3
-- Lexington           Desert Safari                   4
-- Lexington           Food and Drink                  4
-- Lexington           Golfing                         3
-- Lexington           Hiking                          1
-- Lexington           Historical Sites                5
-- Lexington           Mountain                        3
-- Lexington           Music Festival                  6
-- Lexington           Nightlife                       1
-- Lexington           Photography                     3
-- Lexington           Road Trip                       2
-- Lexington           Sailing                         3
-- Lexington           Scuba Diving                    3
-- Lexington           Shopping                        4
-- Lexington           Skiing                          3
-- Lexington           Spa and Wellness                2
-- Lexington           Sports Events                   3
-- Lexington           Wildlife Safari                 3
-- Lexington           Yoga Retreat                    1
-- Plano               Adventure                       2
-- Plano               Art and Craft                   1
-- Plano               Camping                         3
-- Plano               Cultural Experience             1
-- Plano               Desert Safari                   2
-- Plano               Golfing                         1
-- Plano               Mountain                        2
-- Plano               Music Festival                  1
-- Plano               Photography                     1
-- Plano               Road Trip                       3
-- Plano               Sailing                         1
-- Plano               Scuba Diving                    1
-- Plano               Shopping                        2
-- Plano               Skiing                          2
-- Plano               Spa and Wellness                3
-- Plano               Sports Events                   3
-- Plano               Yoga Retreat                    1
--                         Total                         95
-- 42 rows selected.
*/


-- Query 4: Confirmed Bookings Without Ratings and Traveler's Total Booking Count
-- This query retrieves confirmed bookings that lack a rating, along with the total number of bookings for each traveler.
-- It helps identify customers who have experienced a service but have not provided feedback.
SET PAGESIZE 1000
SET LINESIZE 300
TTITLE LEFT "Confirmed Bookings Without Ratings and Travelers Total Booking Count"
COLUMN T_ID FORMAT A10
COLUMN First_Name FORMAT A15
COLUMN Last_Name FORMAT A15
COLUMN Total_Bookings FORMAT 9999
COLUMN Email FORMAT A28
COLUMN Booking_ID FORMAT A10
COLUMN Experience_ID FORMAT A10
COLUMN Experience_Title FORMAT A40
COLUMN Date_Of_Booking FORMAT A35
COLUMN Experience_Date FORMAT A25
COLUMN Amount_Paid FORMAT 999999.99
SELECT t.T_ID,
       t.First_Name,
       t.Last_Name,
       COUNT(b.Booking_ID) OVER(PARTITION BY t.T_ID) AS Total_Bookings,
       t.Email,
       b.Booking_ID,
       b.Experience_ID,
       e.Title AS Experience_Title,
       b.Date_Of_Booking,
       b.Experience_Date,
       b.Amount_Paid
FROM Fall24_S003_T8_Travelers t
JOIN Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE bs.Status_Name = 'Confirmed'
  AND NOT EXISTS (
      SELECT 1
      FROM Fall24_S003_T8_Ratings r
      WHERE r.Traveler_ID = b.Traveler_ID
        AND r.Experience_ID = b.Experience_ID
  )
  AND NOT EXISTS (
      SELECT 1
      FROM Fall24_S003_T8_Bookings b_inner
      JOIN Fall24_S003_T8_Booking_Status bs_inner ON b_inner.Booking_Status_ID = bs_inner.Status_ID
      WHERE b_inner.Traveler_ID = t.T_ID
        AND bs_inner.Status_Name = 'Confirmed'
        AND EXISTS (
            SELECT 1
            FROM Fall24_S003_T8_Ratings r_inner
            WHERE r_inner.Traveler_ID = b_inner.Traveler_ID
              AND r_inner.Experience_ID = b_inner.Experience_ID
        )
  )
ORDER BY Total_Bookings DESC, t.T_ID, b.Booking_ID;


/*
T_ID       FIRST_NAME      LAST_NAME  TOTAL_BOOKINGS EMAIL                        BOOKING_ID EXPERIENCE EXPERIENCE_TITLE                         DATE_OF_BOOKING                     EXPERIENCE_DATE AMOUNT_PAID
---------- --------------- ---------- -------------- ---------------------------- ---------- ---------- ---------------------------------------- ----------------------------------- --------------- -----------
T00017     Mario           Wood                    3 nicolelloyd@example.net      B00015     E00041     Exciting Desert Safari Adventure         26-MAY-24 06.53.47.000000000 AM     15-JUN-24            989.10
T00017     Mario           Wood                    3 nicolelloyd@example.net      B00021     E00002     Guided Scuba Diving Experience           01-JUL-24 12.00.00.000000000 AM     19-DEC-24           1500.00
T00017     Mario           Wood                    3 nicolelloyd@example.net      B00032     E00015     Scuba Diving Discovery Tour              10-AUG-24 12.00.00.000000000 AM     19-DEC-24           2650.00
T00020     Sonya           Phillips                2 leediana@example.net         B00001     E00022     Unforgettable Desert Safari Trip         18-MAY-24 01.04.27.000000000 AM     15-JUN-24           3315.77
T00020     Sonya           Phillips                2 leediana@example.net         B00022     E00004     Nightlife Escape                         01-MAY-24 12.00.00.000000000 AM     19-DEC-24           2900.00
T00022     Veronica        Owen                    2 nancyweeks@example.org       B00006     E00031     Guided Scuba Diving Experience           17-MAY-24 01.01.24.000000000 PM     15-JUN-24           3868.13
T00022     Veronica        Owen                    2 nancyweeks@example.org       B00024     E00007     Ultimate Scuba Diving Experience         20-JUN-24 12.00.00.000000000 AM     19-DEC-24           3200.00
T00027     Andrea          Garcia                  2 philip44@example.net         B00007     E00040     Guided Scuba Diving Experience           08-SEP-24 07.15.16.000000000 PM     14-SEP-24           4744.61
T00027     Andrea          Garcia                  2 philip44@example.net         B00026     E00009     Ultimate Nightlife Experience            15-JAN-24 12.00.00.000000000 AM     19-DEC-24           2700.00
T00037     Erin            Watson                  2 sara40@example.org           B00004     E00010     Unforgettable Scuba Diving Trip          20-AUG-24 09.25.09.000000000 PM     14-SEP-24           2180.14
T00037     Erin            Watson                  2 sara40@example.org           B00028     E00011     Exciting Desert Safari Adventure         01-MAR-24 12.00.00.000000000 AM     19-DEC-24           2300.00
T00040     Steven          Sparks                  2 patrickramsey@example.org    B00002     E00022     Unforgettable Desert Safari Trip         31-MAY-24 10.24.13.000000000 AM     15-JUN-24           3315.77
T00040     Steven          Sparks                  2 patrickramsey@example.org    B00029     E00012     Desert Safari Discovery Tour             30-MAY-24 12.00.00.000000000 AM     19-DEC-24           1850.00
T00002     Allison         Jensen                  1 benjaminstewart@example.com  B00014     E00002     Guided Scuba Diving Experience           19-AUG-24 03.43.52.000000000 AM     14-SEP-24            529.40
T00004     Andrew          Taylor                  1 matthewnelson@example.net    B00048     E00049     Ultimate Desert Safari Experience        25-MAY-24 10.40.19.000000000 PM     15-JUN-24            108.52
T00008     Stephen         Howell                  1 wallaceadam@example.com      B00018     E00016     Desert Safari Discovery Tour             28-MAY-24 08.21.50.000000000 PM     15-JUN-24           1066.68
T00018     Travis          Lewis                   1 xwhite@example.net           B00046     E00001     Scuba Diving Escape                      26-AUG-24 04.05.50.000000000 PM     14-SEP-24           1869.68
T00035     Taylor          Sanders                 1 rwilson@example.org          B00047     E00049     Ultimate Desert Safari Experience        25-MAY-24 10.40.19.000000000 PM     15-JUN-24            108.52
T00042     Erika           Johns                   1 melissahill@example.org      B00045     E00001     Scuba Diving Escape                      26-AUG-24 04.05.50.000000000 PM     14-SEP-24           1869.68

19 rows selected
*/


-- Query 5: Quarterly and Yearly Booking and Revenue Analysis by Location
-- This query provides an analysis of bookings and revenue by location across different quarters and years, giving insights into seasonal trends and revenue performance by location.

SET PAGESIZE 1000
SET LINESIZE 120

TTITLE LEFT "Quarterly and Yearly Booking and Revenue Analysis by Location"

COLUMN Year FORMAT 9999
COLUMN Quarter FORMAT A8
COLUMN Location_Name FORMAT A15
COLUMN Total_Bookings FORMAT 99999
COLUMN Total_Revenue FORMAT 9999999.99


SELECT 
    EXTRACT(YEAR FROM b.Date_Of_Booking) AS Year,
    TO_CHAR(b.Date_Of_Booking, 'Q') AS Quarter,
    l.Location_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(COALESCE(b.Amount_Paid, 0)) AS Total_Revenue
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
JOIN 
    Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Confirmed'
GROUP BY 
    CUBE (EXTRACT(YEAR FROM b.Date_Of_Booking), TO_CHAR(b.Date_Of_Booking, 'Q'), l.Location_Name)
HAVING 
    EXTRACT(YEAR FROM b.Date_Of_Booking) IS NOT NULL 
    AND TO_CHAR(b.Date_Of_Booking, 'Q') IS NOT NULL
    AND l.Location_Name IS NOT NULL
ORDER BY 
    Year DESC, Quarter DESC, Total_Bookings DESC;

/*

Result:
YEAR QUARTER  LOCATION_NAME   TOTAL_BOOKINGS TOTAL_REVENUE
----- -------- --------------- -------------- -------------
 2024 3        Lexington                   12      24978.57
 2024 3        Plano                        4       6578.86
 2024 2        Lexington                   14      22844.37
 2024 2        Plano                        2       5600.00
 2024 1        Lexington                    4       7330.00
 2024 1        Plano                        1       2700.00
 2023 4        Lexington                    1        108.52

7 rows selected. 

*/



-- Query 6: Seasonal Trends and Spendings Analysis
-- This query provides insights into seasonal booking trends and spending patterns, categorizing each booking into different seasons (Holiday, Spring Festival, Fall Event, and Regular) based on the month. The analysis focuses on total bookings, average spending, and total spending for each season.

SET PAGESIZE 1000
SET LINESIZE 120
TTITLE LEFT "Seasonal Trends and Spendings Analysis"
COLUMN Booking_Year FORMAT 9999
COLUMN Booking_Season FORMAT A25
COLUMN Total_Bookings FORMAT 9999
COLUMN Avg_Spending FORMAT 99999.99
COLUMN Total_Spending FORMAT 9999999.99
SELECT 
    EXTRACT(YEAR FROM b.Date_Of_Booking) AS Booking_Year,
    CASE 
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) IN (12, 1) THEN 'Holiday Season'        
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) = 4 THEN 'Spring Festival Season'       
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) = 10 THEN 'Fall Event Season'           
        ELSE 'Regular Season'
    END AS Booking_Season,
    COUNT(b.Booking_ID) AS Total_Bookings,
    AVG(b.Amount_Paid) AS Avg_Spending,
    SUM(b.Amount_Paid) AS Total_Spending
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
GROUP BY 
    EXTRACT(YEAR FROM b.Date_Of_Booking),
    CASE 
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) IN (12, 1) THEN 'Holiday Season'
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) = 4 THEN 'Spring Festival Season'
        WHEN EXTRACT(MONTH FROM b.Date_Of_Booking) = 10 THEN 'Fall Event Season'
        ELSE 'Regular Season'
    END
ORDER BY 
    Booking_Year DESC, Booking_Season;

-- Result:
-- BOOKING_YEAR   BOOKING_SEASON          TOTAL_BOOKINGS   AVG_SPENDING   TOTAL_SPENDING
-- -------------  ----------------------  ---------------  --------------  --------------
-- 2024           Holiday Season          4                1350            5400
-- 2024           Regular Season         91               1686.61659      153482.11
-- 2024           Spring Festival Season  4                1650            6600
-- 2023           Regular Season          2                108.52          217.04


-- Query 7: Top 10 Service Providers Based on Weighted Score
-- This query identifies the top 10 service providers based on a weighted scoring system. The score is calculated by giving a 70% weight to the average rating and a 30% weight to the number of bookings, allowing a balanced view of quality and popularity.

SET PAGESIZE 1000
SET LINESIZE 150
TTITLE LEFT "Top 10 Service Providers Based on Weighted Score"
COLUMN Service_Provider_ID FORMAT A15
COLUMN Service_Provider_Name FORMAT A25
COLUMN Location FORMAT A20
COLUMN Average_Rating FORMAT 9999.99
COLUMN Total_Bookings FORMAT 9999
COLUMN Score FORMAT 9999.99
WITH ServiceProviderRatings AS (
    SELECT 
        e.Service_Provider_ID,
        AVG(r.Rating_Value) AS Average_Rating,
        COUNT(b.Booking_ID) AS Total_Bookings
    FROM 
        Fall24_S003_T8_Experience e
    LEFT JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    LEFT JOIN 
        Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
    GROUP BY 
        e.Service_Provider_ID
    HAVING 
        AVG(r.Rating_Value) IS NOT NULL
        AND COUNT(b.Booking_ID) > 1
),
MaxBookings AS (
    SELECT 
        MAX(Total_Bookings) AS Max_Total_Bookings
    FROM 
        ServiceProviderRatings
),
RankedProviders AS (
    SELECT 
        sp.Service_Provider_ID,
        sp.Average_Rating,
        sp.Total_Bookings,
        (sp.Average_Rating * 0.7) + ((sp.Total_Bookings / mb.Max_Total_Bookings) * 10 * 0.3) AS Score,
        DENSE_RANK() OVER (
            ORDER BY (sp.Average_Rating * 0.7) + ((sp.Total_Bookings / mb.Max_Total_Bookings) * 10 * 0.3) DESC
        ) AS Rank
    FROM 
        ServiceProviderRatings sp,
        MaxBookings mb
),
ProviderWithSingleLocation AS (
    SELECT 
        sch.Service_Provider_ID,
        loc.Location_Name,
        ROW_NUMBER() OVER (PARTITION BY sch.Service_Provider_ID ORDER BY loc.Location_Name) AS LocationRank
    FROM 
        Fall24_S003_T8_Availability_Schedule sch
    JOIN 
        Fall24_S003_T8_Schedule_Locations sl ON sch.Schedule_ID = sl.Schedule_ID
    JOIN 
        Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
)
SELECT 
    rp.Service_Provider_ID,
    sp.Name AS Service_Provider_Name,
    loc.Location_Name AS Location,
    rp.Average_Rating,
    rp.Total_Bookings,
    rp.Score
FROM 
    RankedProviders rp
JOIN 
    Fall24_S003_T8_Service_Provider sp ON rp.Service_Provider_ID = sp.Service_Provider_ID
LEFT JOIN 
    ProviderWithSingleLocation loc ON rp.Service_Provider_ID = loc.Service_Provider_ID AND loc.LocationRank = 1 
WHERE 
    rp.Rank <= 10
ORDER BY 
    rp.Score DESC;


-- Result:
-- SERVICE_PROVIDER_ID   SERVICE_PROVIDER_NAME                                   LOCATION     AVERAGE_RATING   TOTAL_BOOKINGS   SCORE
-- -------------------  ------------------------------------------              ------------  --------------   --------------
-- SP00019              Hernandez, Mendez and Collins                          Fremont        7.2               6                8.04
-- SP00035              Young Inc                                              Columbus       9.4               2                7.58
-- SP00005              Johnson Inc                                            Fontana        7.2               4                7.04
-- SP00018              Carter PLC                                             Durham         7.5               2                6.25
-- SP00001              Rodriguez, Johnson and Burke                           Lexington     3.7               3                4.09
-- SP00033              Sandoval-Scott                                         Chesapeake    4.3               2                4.01

-- 6 rows selected.

-- Query 8: Adventure-Seeking Travelers and Their Booked Experiences with Service Providers
-- This query identifies travelers interested in adventure-related experiences and lists the specific experiences they have booked along with the associated service providers. It includes travelers with preferences for categories like "Adventure," "Camping," "Mountain," and "Skiing," giving insights into their adventure-seeking behavior.

SET PAGESIZE 1000
SET LINESIZE 250
BREAK ON Traveler_Name SKIP 1
COLUMN Traveler_Name FORMAT A30
COLUMN Traveler_Email FORMAT A30
COLUMN Service_Provider_Name FORMAT A30
COLUMN Experience_Title FORMAT A40
COLUMN Category FORMAT A20

SELECT 
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY T.T_ID ORDER BY SP.Name) = 1 
         THEN T.First_Name || ' ' || T.Last_Name 
         ELSE '' 
    END AS Traveler_Name,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY T.T_ID ORDER BY SP.Name) = 1 
         THEN T.Email 
         ELSE '' 
    END AS Traveler_Email,
    SP.Name AS Service_Provider_Name,
    E.Title AS Experience_Title,
    INITCAP(C.Category_Name) AS Category
FROM 
    Fall24_S003_T8_Travelers T
JOIN 
    Fall24_S003_T8_Traveler_Preferences TP ON T.T_ID = TP.T_ID
JOIN 
    Fall24_S003_T8_Interest_Categories C ON TP.Preference_ID = C.Category_ID
JOIN 
    Fall24_S003_T8_Bookings B ON T.T_ID = B.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience E ON B.Experience_ID = E.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
WHERE 
    C.Category_Name LIKE '%Adventure%' OR 
    C.Category_Name LIKE '%Camping%' OR 
    C.Category_Name LIKE '%Mountain%' OR 
    C.Category_Name LIKE '%Skiing%'
ORDER BY 
    T.Last_Name, T.First_Name, SP.Name;

/*
-- Result:
TRAVELER_NAME                  TRAVELER_EMAIL                 SERVICE_PROVIDER_NAME          EXPERIENCE_TITLE                         CATEGORY            
------------------------------ ------------------------------ ------------------------------ ---------------------------------------- --------------------
Manuel Chung                   cherylchase@example.net        Johnson Inc                    Unforgettable Scuba Diving Trip          Mountain            

Tammy Garza                    lecatherine@example.com        Mcclure, Dennis and Gillespie  Unforgettable Nightlife Trip             Camping             

                                                              Young Inc                      Scuba Diving Discovery Tour              Camping             

Allison Jensen                 benjaminstewart@example.com    Ford-Carr                      Guided Scuba Diving Experience           Mountain            

Travis Lewis                   xwhite@example.net             Hutchinson LLC                 Desert Safari Escape                     Mountain            

                                                              Rodriguez, Johnson and Burke   Scuba Diving Escape                      Mountain            

Patricia Moore                 wuemily@example.com            Hernandez, Mendez and Collins  Ultimate Desert Safari Experience        Adventure           

Sonya Phillips                 leediana@example.net           Black and Sons                 Exciting Scuba Diving Adventure          Adventure           

                                                              Hendricks, Rhodes and Lee      Unforgettable Desert Safari Trip         Adventure           

                                                              Marsh-Grant                    Nightlife Escape                         Adventure           

Taylor Sanders                 rwilson@example.org            Ford-Carr                      Guided Scuba Diving Experience           Adventure           

                                                              Hernandez, Mendez and Collins  Ultimate Desert Safari Experience        Adventure           

James Thomas                   madisonmclaughlin@example.com  Carter PLC                     Exciting Nightlife Adventure             Adventure           

                                                              Johnson Inc                    Unforgettable Scuba Diving Trip          Adventure           

                                                              Rowe PLC                       Desert Safari Exploration Journey        Adventure           

                                                              Smith, Reynolds and Hill       Unforgettable Scuba Diving Trip          Adventure           


16 rows selected. 
*/