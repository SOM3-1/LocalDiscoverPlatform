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
Top Monthly Demographic, Location, and Activity by Bookings                                                                                                                                                                                                                                                                                       
 YEAR      MONTH DEMOGRAPHIC_TYPE                                   LOCATION_NAME   ACTIVITY_CATEGORY                                                                                    TOTAL_BOOKINGS
----- ---------- -------------------------------------------------- --------------- ---------------------------------------------------------------------------------------------------- --------------
 2025          1 Senior Citizen                                     Jersey City     Food andDrink                                                                                                     2
 2024         12 Senior Citizen                                     Madison         Scuba Diving                                                                                                      2
 2024         11 Senior Citizen                                     Memphis         Music Festival                                                                                                    3
 2024         10 Senior Citizen                                     Mesa            Road Trip                                                                                                         3
 2024          9 Senior Citizen                                     Wichita         Yoga Retreat                                                                                                      2
 2024          8 Group                                              Honolulu        Sailing                                                                                                           3
 2024          7 Group                                              Chandler        Skiing                                                                                                            2
 2024          6 Senior Citizen                                     Norfolk         Cruise                                                                                                            3
 2024          5 Group                                              Baton Rouge     Beach                                                                                                             3
 2024          4 Senior Citizen                                     St. Louis       Sailing                                                                                                           3
 2024          3 Senior Citizen                                     Las Vegas       Shopping                                                                                                          2
 2024          2 Senior Citizen                                     Washington      Adventure                                                                                                         3
 2024          1 Senior Citizen                                     Oakland         Golfing                                                                                                           2
 2023         12 Senior Citizen                                     Spokane         Sailing                                                                                                           1
 2023         11 Senior Citizen                                     Albuquerque     Wildlife Safari                                                                                                   2
 2023         10 Student                                            Chula Vista     Adventure                                                                                                         1

16 rows selected.
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
TRAVELER_I TRAVELER_NAME        REPEAT_BOOKINGS AVERAGE_SPEND
---------- -------------------- --------------- -------------
T00281     Rhonda Skinner                     4       2599.77

T00608     Alexander Perez                    4       2400.12

T00340     Steven Salazar                     3       4089.77

T00597     Todd Gray                          3       3403.41

T00676     Jennifer Bass                      3       3375.90

T00957     Mark James                         3       2395.80

T00050     Lacey Kelley                       3       2242.82

T00725     Michael Henry                      3       2100.55

T00907     Jennifer Long                      3       1991.16

T00819     John Perry                         3       1914.13


10 rows selected. 
*/

-- Query 3: Experience Diversity Analysis Using Rollup
-- This query provides an analysis of booking distribution across different locations. It counts the total bookings for each location, including subtotals for each location and a grand total across all locations. This enables a clear view of how bookings are spread geographically, helping to identify popular locations based on booking volume.

SET PAGESIZE 1000
SET LINESIZE 120
TTITLE LEFT "Booking Distribution by Location with Totals"
COLUMN Destination FORMAT A16
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



-- Booking Distribution by Location with Totals     
-- DESTINATION      TOTAL_BOOKINGS
-- ---------------- --------------
-- Albuquerque                  12
-- Anaheim                       1
-- Anchorage                     1
-- Arlington                    11
-- Atlanta                       8
-- Austin                        1
-- Bakersfield                   4
-- Baton Rouge                   6
-- Boise                         7
-- Boston                        4
-- Buffalo                       1
-- Chandler                      2
-- Charlotte                     5
-- Chicago                       2
-- Chula Vista                   4
-- Cincinnati                    2
-- Cleveland                    16
-- Colorado Springs              5
-- Columbus                      3
-- Corpus Christi                5
-- Denver                        3
-- Des Moines                    4
-- Detroit                       2
-- El Paso                       5
-- Fayetteville                 15
-- Fontana                       1
-- Fort Wayne                   12
-- Fort Worth                    0
-- Fremont                       0
-- Fresno                       13
-- Garland                       7
-- Gilbert                      11
-- Glendale                      1
-- Hialeah                       5
-- Honolulu                     11
-- Houston                       7
-- Indianapolis                  6
-- Irvine                        9
-- Irving                       12
-- Jacksonville                  2
-- Jersey City                  18
-- Kansas City                   5
-- Laredo                       15
-- Las Vegas                     2
-- Lexington                     6
-- Los Angeles                   3
-- Louisville                    4
-- Madison                      19
-- Memphis                      15
-- Mesa                          4
-- Miami                         9
-- Milwaukee                     0
-- Minneapolis                   1
-- Modesto                       9
-- Moreno Valley                 7
-- Nashville                     7
-- New Orleans                   4
-- New York                      1
-- Newark                        0
-- Norfolk                      16
-- North Las Vegas               5
-- Oakland                      24
-- Oklahoma City                12
-- Orlando                       4
-- Philadelphia                  0
-- Phoenix                       2
-- Pittsburgh                    3
-- Plano                         2
-- Portland                      2
-- Raleigh                       1
-- Reno                          9
-- Riverside                     1
-- Sacramento                   10
-- Saint Paul                    4
-- San Antonio                   1
-- San Bernardino                3
-- San Diego                     2
-- San Francisco                 2
-- San Jose                      6
-- Santa Ana                    12
-- Santa Clarita                16
-- Scottsdale                    8
-- Seattle                       1
-- Spokane                       6
-- St. Louis                    22
-- St. Petersburg                6
-- Stockton                      6
-- Tacoma                        2
-- Tampa                         3
-- Toledo                        8
-- Tucson                        7
-- Tulsa                         7
-- Virginia Beach                1
-- Washington                   20
-- Wichita                       9
-- Winston-Salem                 2
--                             600
-- 97 rows selected. 



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
COLUMN Email FORMAT A32
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


-- Confirmed Bookings Without Ratings and Travelers Total Booking Count                                                                                                                                                                                                                                       
-- T_ID       FIRST_NAME      LAST_NAME       TOTAL_BOOKINGS EMAIL                            BOOKING_ID EXPERIENCE EXPERIENCE_TITLE                         DATE_OF_BOOKING                     EXPERIENCE_DATE           AMOUNT_PAID
-- ---------- --------------- --------------- -------------- -------------------------------- ---------- ---------- ---------------------------------------- ----------------------------------- ------------------------- -----------
-- T00009     Melissa         Jackson                      2 stevenclay@example.com           B15765     E00192     Sailing Escape                           22-JUN-24 08.49.07.000000000 PM     23-JUN-24                     5320.40
-- T00009     Melissa         Jackson                      2 stevenclay@example.com           B49620     E00402     Unforgettable Road Trip Trip             01-AUG-24 08.17.02.000000000 AM     21-AUG-24                     2513.95
-- T00142     Robert          Horn                         2 fergusonchristopher@example.com  B33446     E00447     Exciting Mountain Adventure              19-NOV-24 05.54.14.000000000 PM     15-DEC-24                     4692.75
-- T00142     Robert          Horn                         2 fergusonchristopher@example.com  B90958     E00112     Unforgettable Nightlife Trip             26-DEC-24 04.55.06.000000000 PM     05-JAN-25                     4250.71
-- T00243     Frank           Warren                       2 kristinajones@example.net        B21260     E00308     Exciting Wildlife Safari Adventure       29-OCT-24 02.40.31.000000000 PM     18-NOV-24                     2558.70
-- T00243     Frank           Warren                       2 kristinajones@example.net        B33352     E00457     Guided Shopping Experience               22-NOV-24 09.50.44.000000000 AM     22-DEC-24                     1268.82
-- T00828     Steven          Osborn                       2 evanskaren@example.com           B20966     E00253     Ultimate Shopping Experience             30-AUG-24 02.51.32.000000000 AM     21-SEP-24                     2409.03
-- T00828     Steven          Osborn                       2 evanskaren@example.com           B72547     E00142     Desert Safari Escape                     06-DEC-23 05.10.54.000000000 AM     09-DEC-23                     3265.82
-- T00006     Mark            Mccann                       1 huffmegan@example.org            B85595     E00087     Guided Sailing Experience                30-DEC-23 09.16.41.000000000 PM     27-JAN-24                     4930.67
-- T00020     Sean            Randall                      1 pbyrd@example.com                B22597     E00318     Cruise Discovery Tour                    02-DEC-24 04.06.02.000000000 AM     20-DEC-24                     2580.19
-- T00033     Kyle            Johnston                     1 nicholsmichelle@example.net      B17440     E00458     Unforgettable Art andCraft Trip          25-JUL-24 12.02.09.000000000 AM     22-AUG-24                     2296.70
-- T00042     James           Webster                      1 gwendolynthomas@example.net      B65991     E00046     Unforgettable Hiking Trip                21-OCT-24 03.36.19.000000000 PM     25-OCT-24                      395.89
-- T00048     Kathleen        Velazquez                    1 whitelindsay@example.net         B39585     E00412     City Tour Exploration Journey            03-NOV-24 09.01.37.000000000 PM     24-NOV-24                     5272.94
-- T00052     Angela          Smith                        1 david57@example.org              B41577     E00107     Ultimate Spa andWellness Experience      22-DEC-24 04.35.23.000000000 PM     03-JAN-25                     3583.75
-- T00063     Christopher     Vincent                      1 kevinscott@example.org           B98923     E00223     Ultimate Sports Events Experience        05-JAN-25 08.38.39.000000000 PM     20-JAN-25                     3415.27
-- T00067     Stephanie       Alvarado                     1 phillip28@example.com            B35571     E00372     Guided Desert Safari Experience          11-MAY-24 08.02.10.000000000 PM     21-MAY-24                     1642.84
-- T00080     Karen           Miller                       1 maria22@example.org              B10429     E00183     Unforgettable Spa andWellness Trip       14-FEB-24 08.07.15.000000000 AM     08-MAR-24                     2520.89
-- T00094     Karen           Johnson                      1 kirsten71@example.com            B77492     E00346     Historical Sites Discovery Tour          18-JAN-24 02.15.15.000000000 PM     04-FEB-24                     3911.55
-- T00099     Jane            Parker                       1 wclark@example.com               B16797     E00155     Road Trip Discovery Tour                 13-DEC-24 04.50.59.000000000 PM     03-JAN-25                     3423.70
-- T00103     Joseph          Davis                        1 uwhite@example.com               B17242     E00345     Skiing Exploration Journey               16-APR-24 03.04.23.000000000 AM     01-MAY-24                     1037.70
-- T00122     James           Miller                       1 robert40@example.com             B71033     E00095     Unforgettable Scuba Diving Trip          06-DEC-24 10.15.40.000000000 PM     30-DEC-24                     4914.51
-- T00128     Kevin           Williams                     1 qjordan@example.org              B51509     E00179     Unforgettable Road Trip Trip             18-JUN-24 09.42.00.000000000 AM     16-JUL-24                      822.18
-- T00141     Kristine        Johnson                      1 rogersrhonda@example.org         B85364     E00064     Ultimate Spa andWellness Experience      01-DEC-24 12.27.43.000000000 AM     04-DEC-24                     2766.17
-- T00144     Jason           Cox                          1 rmorris@example.org              B45187     E00109     Unforgettable Sailing Trip               20-MAY-24 05.35.52.000000000 AM     12-JUN-24                     4336.99
-- T00146     Kevin           Farley                       1 christopherboyd@example.net      B30131     E00244     Ultimate Cultural Experience Experience  21-DEC-24 06.13.46.000000000 AM     28-DEC-24                     2505.54
-- T00157     Reginald        Bautista                     1 xhaynes@example.net              B68056     E00022     Historical Sites Exploration Journey     06-MAY-24 10.28.07.000000000 PM     10-MAY-24                     4449.73
-- T00160     Michael         Elliott                      1 cpalmer@example.org              B29697     E00112     Unforgettable Nightlife Trip             06-DEC-24 04.49.26.000000000 AM     05-JAN-25                     4250.71
-- T00176     Kevin           Miller                       1 anne73@example.com               B08401     E00060     Guided Sailing Experience                15-JUN-24 08.07.11.000000000 AM     16-JUN-24                     1016.42
-- T00189     Zachary         Hanna                        1 tammy06@example.org              B92278     E00056     Unforgettable Wildlife Safari Trip       12-SEP-24 08.25.18.000000000 PM     19-SEP-24                      523.91
-- T00208     Angela          Pierce                       1 kwilson@example.net              B40797     E00357     Unforgettable Yoga Retreat Trip          11-DEC-24 04.26.21.000000000 PM     16-DEC-24                     2351.50
-- T00222     Stephen         Williams                     1 justin29@example.com             B99888     E00379     Unforgettable Spa andWellness Trip       27-NOV-23 01.53.31.000000000 PM     05-DEC-23                     5245.44
-- T00228     Stephen         Lee                          1 crawfordhenry@example.com        B76928     E00416     Beach Discovery Tour                     15-DEC-24 11.16.40.000000000 PM     04-JAN-25                     4321.70
-- T00251     Joseph          Arnold                       1 kellytravis@example.org          B22084     E00188     Sports Events Discovery Tour             22-DEC-24 12.54.15.000000000 AM     02-JAN-25                      708.88
-- T00252     Kimberly        Clark                        1 asmith@example.net               B25173     E00173     Photography Discovery Tour               02-MAY-24 07.23.09.000000000 AM     29-MAY-24                     4356.84
-- T00255     Charles         Baker                        1 cclark@example.org               B83010     E00407     Skiing Discovery Tour                    09-JUL-24 06.25.10.000000000 AM     02-AUG-24                     2245.52
-- T00268     Natasha         Ryan                         1 daniel75@example.org             B84603     E00053     Unforgettable Scuba Diving Trip          08-MAY-24 01.12.55.000000000 AM     06-JUN-24                     1863.75
-- T00271     Gregory         Murphy                       1 meganmeza@example.net            B57021     E00061     Ultimate Golfing Experience              10-DEC-24 12.50.02.000000000 AM     27-DEC-24                     2747.04
-- T00294     Nicole          Price                        1 anthony18@example.net            B23380     E00282     Unforgettable Nightlife Trip             22-NOV-24 09.11.38.000000000 AM     09-DEC-24                     2031.06
-- T00314     Joshua          Mitchell                     1 hudsonjames@example.com          B44714     E00172     Unforgettable Road Trip Trip             19-OCT-24 03.13.17.000000000 PM     02-NOV-24                     5448.88
-- T00318     Jennifer        Brown                        1 gilbertdenise@example.org        B07274     E00088     Unforgettable Music Festival Trip        09-SEP-24 11.09.06.000000000 AM     06-OCT-24                      307.12
-- T00321     Natasha         Chung                        1 sarah52@example.com              B13767     E00267     Skiing Escape                            13-FEB-24 05.59.34.000000000 AM     22-FEB-24                     2999.05
-- T00324     Luis            Russell                      1 lortega@example.org              B22440     E00288     Wildlife Safari Escape                   13-OCT-24 07.48.44.000000000 PM     03-NOV-24                     5068.77
-- T00339     Randall         Harvey                       1 eramos@example.net               B36551     E00257     Cruise Discovery Tour                    22-MAY-24 07.17.20.000000000 AM     13-JUN-24                     2434.88
-- T00358     Anthony         White                        1 stephanietucker@example.net      B17258     E00124     Guided Desert Safari Experience          26-NOV-23 09.18.10.000000000 AM     15-DEC-23                     1003.68
-- T00361     Susan           Farmer                       1 eric09@example.net               B04526     E00493     Beach Exploration Journey                17-APR-24 08.50.27.000000000 PM     03-MAY-24                     4080.84
-- T00369     Sarah           Hernandez                    1 charlescheryl@example.org        B39255     E00375     Art andCraft Escape                      30-NOV-24 11.29.52.000000000 AM     01-DEC-24                     3483.18
-- T00378     Rachel          Hanson                       1 camposchristy@example.com        B32630     E00054     Spa andWellness Discovery Tour           20-NOV-23 07.16.41.000000000 AM     06-DEC-23                     5346.28
-- T00386     Joseph          Clark                        1 johnsonjason@example.net         B30980     E00059     Exciting Sports Events Adventure         01-FEB-24 04.26.31.000000000 PM     04-FEB-24                     3378.97
-- T00387     Robert          Obrien                       1 daniel70@example.org             B34828     E00319     Ultimate Hiking Experience               22-NOV-24 09.14.04.000000000 AM     10-DEC-24                     3059.47
-- T00388     Donald          Frey                         1 deancheryl@example.com           B22726     E00143     Ultimate Skiing Experience               26-NOV-24 04.43.36.000000000 PM     18-DEC-24                     4086.54
-- T00416     Michelle        Morales                      1 thomasrichardson@example.org     B23818     E00165     Ultimate Golfing Experience              30-NOV-24 09.31.11.000000000 AM     19-DEC-24                     4182.64
-- T00419     Stephen         Cox                          1 xwalker@example.net              B01719     E00162     Ultimate City Tour Experience            07-MAR-24 08.00.15.000000000 AM     12-MAR-24                     1384.60
-- T00423     Sheila          Horn                         1 steven03@example.com             B81537     E00031     City Tour Escape                         04-JAN-25 06.43.12.000000000 AM     21-JAN-25                     3171.64
-- T00432     Debra           Hoffman                      1 falvarez@example.org             B04575     E00145     Ultimate Camping Experience              05-DEC-24 11.09.18.000000000 PM     04-JAN-25                      707.88
-- T00485     Christopher     Sanders                      1 jennifertaylor@example.org       B21746     E00349     Exciting Art andCraft Adventure          09-NOV-24 06.27.05.000000000 AM     30-NOV-24                      582.15
-- T00495     Rose            Mcdowell                     1 zachary11@example.net            B39410     E00137     Ultimate Nightlife Experience            23-OCT-24 03.31.48.000000000 PM     15-NOV-24                     5413.73
-- T00502     Alyssa          Perry                        1 andrea06@example.net             B95037     E00008     Exciting Sports Events Adventure         05-DEC-24 12.06.29.000000000 PM     06-DEC-24                     4560.16
-- T00528     Erin            Simmons                      1 foxjennifer@example.org          B81349     E00433     Exciting Scuba Diving Adventure          23-NOV-24 12.14.46.000000000 PM     10-DEC-24                     5273.66
-- T00531     Charles         Gonzalez                     1 huberamanda@example.org          B67314     E00037     Scuba Diving Escape                      20-NOV-24 01.57.54.000000000 PM     26-NOV-24                      990.92
-- T00540     Lance           Floyd                        1 ericdominguez@example.org        B58769     E00007     Ultimate Photography Experience          16-AUG-24 07.47.29.000000000 AM     21-AUG-24                     3964.90
-- T00566     Jamie           Barnes                       1 wesley39@example.com             B87157     E00149     Exciting Spa andWellness Adventure       25-JAN-24 06.31.57.000000000 PM     13-FEB-24                      520.59
-- T00571     Kimberly        Wright                       1 jennifer51@example.net           B90889     E00460     Yoga Retreat Discovery Tour              27-JAN-24 03.51.58.000000000 PM     16-FEB-24                     5270.85
-- T00585     Sandy           Carroll                      1 william00@example.org            B70938     E00405     Sports Events Escape                     25-DEC-24 05.11.54.000000000 AM     26-DEC-24                      758.56
-- T00589     Diane           Mcdonald                     1 conleyjared@example.net          B34648     E00356     Unforgettable Nightlife Trip             26-AUG-24 01.30.00.000000000 PM     08-SEP-24                     4625.41
-- T00623     Gabriela        Stafford                     1 stephaniehill@example.net        B04245     E00203     Food andDrink Exploration Journey        15-JAN-24 01.39.03.000000000 AM     25-JAN-24                     4452.83
-- T00636     Jessica         Kelly                        1 meghan18@example.net             B19735     E00264     Exciting Food andDrink Adventure         19-AUG-24 11.48.32.000000000 PM     28-AUG-24                     4981.74
-- T00639     Michael         Williams                     1 woodwardholly@example.com        B18432     E00108     Unforgettable Cultural Experience Trip   30-AUG-24 09.24.35.000000000 PM     25-SEP-24                     4051.62
-- T00640     Marissa         Fernandez                    1 marshmarilyn@example.net         B37727     E00386     Ultimate City Tour Experience            05-DEC-24 07.13.08.000000000 AM     06-DEC-24                     1078.43
-- T00644     Barbara         Williams                     1 veronica54@example.com           B11166     E00131     Guided Scuba Diving Experience           11-MAR-24 07.23.48.000000000 PM     02-APR-24                     1056.47
-- T00649     Brittany        Lucas                        1 emilyjohnson@example.org         B08836     E00207     Yoga Retreat Exploration Journey         23-OCT-24 04.37.03.000000000 AM     19-NOV-24                      819.04
-- T00698     Jeffrey         Raymond                      1 catherineatkins@example.org      B75551     E00197     Guided Road Trip Experience              05-JUN-24 06.25.18.000000000 PM     25-JUN-24                     2533.88
-- T00703     Wendy           Clements                     1 hthompson@example.net            B14737     E00044     Photography Exploration Journey          27-DEC-24 08.55.30.000000000 AM     31-DEC-24                     1797.24
-- T00708     Joseph          Hall                         1 micheal53@example.com            B37267     E00158     Guided Skiing Experience                 14-DEC-24 06.48.28.000000000 PM     19-DEC-24                     1201.82
-- T00738     Teresa          Walker                       1 youngnicholas@example.net        B37846     E00177     Camping Exploration Journey              30-NOV-24 07.46.25.000000000 AM     10-DEC-24                     3026.09
-- T00789     Tracy           Stone                        1 rachel27@example.com             B84661     E00473     Photography Discovery Tour               01-MAR-24 11.34.46.000000000 AM     21-MAR-24                      905.61
-- T00793     Latoya          Perez                        1 gwalters@example.org             B21505     E00467     Historical Sites Discovery Tour          17-DEC-24 11.03.16.000000000 PM     03-JAN-25                     2833.74
-- T00803     Angela          Aguilar                      1 brandon57@example.net            B28095     E00133     Unforgettable Wildlife Safari Trip       27-NOV-24 07.18.32.000000000 AM     21-DEC-24                     1850.29
-- T00818     Thomas          Villanueva                   1 connie32@example.com             B68678     E00393     Unforgettable Art andCraft Trip          09-AUG-24 12.40.01.000000000 AM     23-AUG-24                     2511.06
-- T00823     Danielle        James                        1 anthonylong@example.net          B10735     E00044     Photography Exploration Journey          27-DEC-24 08.26.17.000000000 AM     31-DEC-24                     1797.24
-- T00831     Stephanie       Contreras                    1 qanderson@example.com            B91114     E00210     Guided Road Trip Experience              31-OCT-24 03.20.37.000000000 AM     22-NOV-24                     2205.35
-- T00850     Jason           Valenzuela                   1 juan87@example.org               B16372     E00190     Adventure Discovery Tour                 30-OCT-23 06.56.47.000000000 PM     14-NOV-23                     1533.76
-- T00851     Christopher     Terry                        1 xvelazquez@example.com           B03146     E00388     Shopping Escape                          08-JAN-25 04.30.46.000000000 PM     09-JAN-25                     3739.51
-- T00857     Kimberly        Webb                         1 swilliams@example.org            B77705     E00391     Historical Sites Discovery Tour          15-NOV-24 10.38.36.000000000 AM     29-NOV-24                     4017.96
-- T00867     Christopher     Jones                        1 christiewalton@example.com       B30698     E00477     Guided Cruise Experience                 02-DEC-24 04.01.52.000000000 AM     16-DEC-24                      801.63
-- T00882     Phillip         Hayes                        1 kathrynmadden@example.org        B16806     E00020     Spa andWellness Escape                   13-DEC-24 04.46.35.000000000 PM     03-JAN-25                     2949.66
-- T00884     Daniel          Reyes                        1 alvaradochristopher@example.org  B27386     E00427     Exciting Skiing Adventure                28-NOV-24 09.38.39.000000000 PM     22-DEC-24                     5422.66
-- T00917     Whitney         Walker                       1 pamelastokes@example.org         B12486     E00115     Guided Golfing Experience                12-MAR-24 01.50.43.000000000 AM     19-MAR-24                     2975.73
-- T00941     Victoria        Schmidt                      1 erincollins@example.net          B20015     E00372     Guided Desert Safari Experience          07-MAY-24 04.10.30.000000000 PM     21-MAY-24                     1642.84
-- T00992     Steven          Kim                          1 mark60@example.com               B44148     E00426     Cultural Experience Exploration Journey  05-AUG-24 03.12.00.000000000 PM     14-AUG-24                     5294.43
-- T00997     Alexis          Ramirez                      1 jasonbrooks@example.org          B90112     E00208     Unforgettable Camping Trip               05-JAN-25 06.43.37.000000000 PM     20-JAN-25                      901.04

-- 90 rows selected. 


-- Query 5: Quarterly and Yearly Booking and Revenue Analysis by Location
-- This query provides an analysis of bookings and revenue by location across different quarters and years, giving insights into seasonal trends and revenue performance by location.

SET PAGESIZE 1000
SET LINESIZE 120

TTITLE LEFT "Quarterly and Yearly Booking and Revenue Analysis by Location"

COLUMN Year FORMAT 9999
COLUMN Quarter FORMAT A8
COLUMN Location_Name FORMAT A16
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

-- Quarterly and Yearly Booking and Revenue Analysis by Location                                                          
--  YEAR QUARTER  LOCATION_NAME    TOTAL_BOOKINGS TOTAL_REVENUE
-- ----- -------- ---------------- -------------- -------------
--  2025 1        Madison                       2       5390.51
--  2025 1        Cleveland                     2       3556.18
--  2025 1        Des Moines                    2       4155.51
--  2025 1        Jersey City                   2       9860.03
--  2025 1        Arlington                     2       7862.09
--  2025 1        Washington                    1       1813.90
--  2025 1        Sacramento                    1       3525.67
--  2025 1        Reno                          1       3739.51
--  2025 1        Boston                        1       3415.27
--  2025 1        Santa Ana                     1        614.04
--  2024 4        Memphis                       9      21084.79
--  2024 4        Cleveland                     8      21488.43
--  2024 4        St. Louis                     7       8903.35
--  2024 4        Jersey City                   6      22413.25
--  2024 4        Madison                       6      25926.13
--  2024 4        Gilbert                       5      14590.72
--  2024 4        North Las Vegas               5      19923.05
--  2024 4        Toledo                        5      12621.15
--  2024 4        Oakland                       5      17817.64
--  2024 4        Kansas City                   5       7121.32
--  2024 4        Fort Wayne                    5      11261.27
--  2024 4        Tucson                        5       9067.98
--  2024 4        Santa Clarita                 5      17414.31
--  2024 4        Garland                       5      18091.51
--  2024 4        Miami                         5      13709.69
--  2024 4        Irvine                        5       8154.04
--  2024 4        Laredo                        4      15097.30
--  2024 4        Honolulu                      4      15728.16
--  2024 4        Oklahoma City                 4       5905.97
--  2024 4        Fayetteville                  4      17447.72
--  2024 4        Modesto                       3        902.65
--  2024 4        Tulsa                         3       6241.41
--  2024 4        Denver                        3       6093.19
--  2024 4        Sacramento                    3       1722.81
--  2024 4        Fresno                        3       5428.68
--  2024 4        St. Petersburg                3       9264.19
--  2024 4        Nashville                     3      12707.39
--  2024 4        Norfolk                       3       3765.63
--  2024 4        Pittsburgh                    3       3381.54
--  2024 4        Stockton                      3      10256.32
--  2024 4        Arlington                     3      13949.30
--  2024 4        Charlotte                     3      12662.08
--  2024 4        Lexington                     3       6533.49
--  2024 4        Santa Ana                     3       1842.13
--  2024 4        San Jose                      3      14087.30
--  2024 4        Bakersfield                   2       6026.86
--  2024 4        Boston                        2       6830.54
--  2024 4        Columbus                      2      10359.12
--  2024 4        Albuquerque                   2       7253.72
--  2024 4        Houston                       2       4755.76
--  2024 4        Washington                    2       6992.07
--  2024 4        Tampa                         2       2463.77
--  2024 4        Irving                        2       2499.56
--  2024 4        Orlando                       2       3594.47
--  2024 4        New Orleans                   2       8727.00
--  2024 4        Phoenix                       2        351.85
--  2024 4        Mesa                          2       8308.54
--  2024 4        Hialeah                       2       4189.80
--  2024 4        Louisville                    2       4533.55
--  2024 4        El Paso                       2       5065.29
--  2024 4        Jacksonville                  2        557.46
--  2024 4        Los Angeles                   2       4690.15
--  2024 4        Atlanta                       1       4560.16
--  2024 4        Wichita                       1       4434.73
--  2024 4        Scottsdale                    1       4539.66
--  2024 4        Cincinnati                    1       3026.09
--  2024 4        San Bernardino                1       5002.45
--  2024 4        Des Moines                    1       2558.70
--  2024 4        Moreno Valley                 1       1069.23
--  2024 4        Chula Vista                   1       1034.45
--  2024 4        San Diego                     1       3072.00
--  2024 4        Tacoma                        1       4067.55
--  2024 3        Oakland                       6      20492.27
--  2024 3        Irving                        5      21620.75
--  2024 3        Reno                          5      16922.59
--  2024 3        St. Louis                     4      12597.63
--  2024 3        Santa Clarita                 4      10998.48
--  2024 3        Fresno                        4      12718.61
--  2024 3        Wichita                       3       5909.92
--  2024 3        Boise                         3      13388.66
--  2024 3        Scottsdale                    3      15883.30
--  2024 3        Jersey City                   2       5022.12
--  2024 3        Washington                    2       4462.60
--  2024 3        Chandler                      2       4491.04
--  2024 3        Laredo                        1       2677.83
--  2024 3        Indianapolis                  1       2465.12
--  2024 3        Sacramento                    1       1268.55
--  2024 3        Irvine                        1        523.91
--  2024 3        Honolulu                      1       4354.89
--  2024 3        Oklahoma City                 1       5244.32
--  2024 3        Austin                        1       2296.70
--  2024 3        Tampa                         1        475.17
--  2024 3        Norfolk                       1       2505.07
--  2024 3        Orlando                       1       2210.64
--  2024 3        Corpus Christi                1       3966.72
--  2024 2        Laredo                        5       9774.57
--  2024 2        Atlanta                       5      18920.69
--  2024 2        Fayetteville                  4      15070.89
--  2024 2        Baton Rouge                   4      17427.34
--  2024 2        Colorado Springs              4      15042.41
--  2024 2        Norfolk                       4      10639.71
--  2024 2        Gilbert                       3       8239.62
--  2024 2        Fort Wayne                    3      10177.15
--  2024 2        Santa Ana                     3       8937.51
--  2024 2        St. Louis                     3       6864.70
--  2024 2        Garland                       2       4419.98
--  2024 2        Sacramento                    2      10238.40
--  2024 2        Washington                    2       9307.77
--  2024 2        Lexington                     2      10640.81
--  2024 2        San Jose                      2       2178.62
--  2024 2        Raleigh                       1       3744.63
--  2024 2        Fresno                        1        561.73
--  2024 2        Buffalo                       1       4336.99
--  2024 2        Chicago                       1       4080.84
--  2024 2        Albuquerque                   1       1044.98
--  2024 2        Cincinnati                    1        453.92
--  2024 2        Nashville                     1        236.82
--  2024 2        Boise                         1       2111.77
--  2024 2        Irving                        1        822.18
--  2024 2        Irvine                        1       2512.92
--  2024 2        Moreno Valley                 1       3447.84
--  2024 2        Mesa                          1       4937.63
--  2024 2        Scottsdale                    1       3462.86
--  2024 1        Oakland                       5      12019.80
--  2024 1        Norfolk                       5       8439.76
--  2024 1        Madison                       4      10719.26
--  2024 1        Modesto                       4       7775.94
--  2024 1        Washington                    4      15661.37
--  2024 1        Fayetteville                  3       6373.43
--  2024 1        Jersey City                   3       8387.70
--  2024 1        Spokane                       3      12402.07
--  2024 1        Indianapolis                  3       8193.13
--  2024 1        Gilbert                       2       6571.77
--  2024 1        Nashville                     2       5594.90
--  2024 1        Wichita                       2       7226.85
--  2024 1        Plano                         2       7155.58
--  2024 1        St. Petersburg                2       6929.98
--  2024 1        Portland                      1       2082.20
--  2024 1        Las Vegas                     1       1798.96
--  2024 1        Fresno                        1        124.74
--  2024 1        Saint Paul                    1        905.61
--  2024 1        Houston                       1       5376.90
--  2024 1        Honolulu                      1        520.59
--  2024 1        Los Angeles                   1       2453.06
--  2024 1        Tulsa                         1        850.03
--  2024 1        San Jose                      1       1898.79
--  2024 1        Orlando                       1       1932.24
--  2024 1        San Bernardino                1       2999.05
--  2024 1        Fort Wayne                    1       2707.74
--  2024 1        Santa Ana                     1        814.88
--  2024 1        Winston-Salem                 1       1603.12
--  2023 4        Albuquerque                   6      23275.16
--  2023 4        Chula Vista                   3       7128.48
--  2023 4        Cleveland                     3      13980.33
--  2023 4        Santa Clarita                 3       3011.05
--  2023 4        Honolulu                      2       1327.00
--  2023 4        Saint Paul                    2       8065.70
--  2023 4        Anchorage                     1       1397.54
--  2023 4        Virginia Beach                1       1839.74
--  2023 4        Scottsdale                    1       3975.16
--  2023 4        Fontana                       1       2914.46
--  2023 4        Seattle                       1       2123.13
--  2023 4        Houston                       1       2623.50
--  2023 4        Stockton                      1       4412.66
--  2023 4        Spokane                       1       4930.67

-- 165 rows selected. 



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

--  Result:
-- BOOKING_YEAR BOOKING_SEASON            TOTAL_BOOKINGS AVG_SPENDING TOTAL_SPENDING
-- ------------ ------------------------- -------------- ------------ --------------
--         2025 Holiday Season                        63      1829.66      115268.31
--         2024 Fall Event Season                     73      1577.29      115142.17
--         2024 Holiday Season                       442      1809.30      799708.65
--         2024 Regular Season                       736      2039.58     1501132.20
--         2024 Spring Festival Season                44      2159.87       95034.45
--         2023 Fall Event Season                      3      1533.76        4601.29
--         2023 Holiday Season                        43      2152.13       92541.68
--         2023 Regular Season                        41      2652.79      108764.35

-- 8 rows selected.


-- Query 7: Top 10 Service Providers Based on Weighted Score
-- This query identifies the top 10 service providers based on a weighted scoring system. The score is calculated by giving a 70% weight to the average rating and a 30% weight to the number of bookings, allowing a balanced view of quality and popularity.

SET PAGESIZE 1000
SET LINESIZE 150
TTITLE LEFT "Top 10 Service Providers Based on Weighted Score"
COLUMN Service_Provider_ID FORMAT A15
COLUMN Service_Provider_Name FORMAT A35
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


-- Top 10 Service Providers Based on Weighted Score                                                                                                     
-- SERVICE_PROVIDE SERVICE_PROVIDER_NAME               LOCATION             AVERAGE_RATING TOTAL_BOOKINGS    SCORE
-- --------------- ----------------------------------- -------------------- -------------- -------------- --------
-- SP00177         Perez, Weber and Ellis              Honolulu                       7.43             14     7.67
-- SP00102         Dominguez, Bailey and Hanson        Virginia Beach                 9.90              4     7.64
-- SP00035         Diaz PLC                            Winston-Salem                  7.80             12     7.58
-- SP00086         Ward LLC                            St. Louis                      9.40              5     7.46
-- SP00023         Wheeler, Tucker and Mitchell        San Jose                       8.46              8     7.33
-- SP00166         Gutierrez, Davis and Brown          San Bernardino                 8.93              6     7.31
-- SP00218         Smith, Chang and Prince             New Orleans                    9.90              2     7.28
-- SP00164         Miller Inc                          Houston                        9.28              4     7.20
-- SP00252         Carter, Gardner and Villarreal      Norfolk                        7.43             11     7.14
-- SP00051         Kemp Ltd                            Chula Vista                    9.40              3     7.11

-- 10 rows selected. 


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
    C.Category_Name LIKE '%Adventure%'
ORDER BY 
    T.Last_Name, T.First_Name, SP.Name;

/*
TRAVELER_NAME                                                                                         TRAVELER_EMAIL                                     SERVICE_PROVIDER_NAME                                                                                EXPERIENCE_TITLE                                                                                     CATEGORY                                                                                            
----------------------------------------------------------------------------------------------------- -------------------------------------------------- ---------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------
Erin Bailey                                                                                           ypeterson@example.net                              Krueger-Wong                                                                                         Guided Adventure Experience                                                                          Adventure                                                                                           
Reginald Bautista                                                                                     xhaynes@example.net                                Wheeler, Tucker and Mitchell                                                                         Historical Sites Exploration Journey                                                                 Adventure                                                                                           
Marissa Carr                                                                                          matthew15@example.net                              Lopez, Carney and Spencer                                                                            Adventure Exploration Journey                                                                        Adventure                                                                                           
                                                                                                                                                         Stewart LLC                                                                                          Guided Shopping Experience                                                                           Adventure                                                                                           
Wendy Clements                                                                                        hthompson@example.net                              Thomas, Collier and Wright                                                                           Photography Exploration Journey                                                                      Adventure                                                                                           
Kristin Faulkner                                                                                      jenniferwatts@example.net                          Gonzales Group                                                                                       Desert Safari Escape                                                                                 Adventure                                                                                           
Steve Fisher                                                                                          ugarner@example.org                                Bowman-Garrett                                                                                       Guided Yoga Retreat Experience                                                                       Adventure                                                                                           
Michael Fry                                                                                           devin15@example.org                                Harris Ltd                                                                                           Exciting Nightlife Adventure                                                                         Adventure                                                                                           
Haley Holden                                                                                          jimmy99@example.com                                Hunter, Moreno and Jenkins                                                                           Spa andWellness Discovery Tour                                                                       Adventure                                                                                           
                                                                                                                                                         Mccullough LLC                                                                                       Camping Exploration Journey                                                                          Adventure                                                                                           
Kenneth Hunt                                                                                          haaskatrina@example.org                            Hogan, Norris and Ryan                                                                               Exciting Scuba Diving Adventure                                                                      Adventure                                                                                           
                                                                                                                                                         Wheeler, Tucker and Mitchell                                                                         Skiing Exploration Journey                                                                           Adventure                                                                                           
Diane Jackson                                                                                         xtaylor@example.net                                Smith Ltd                                                                                            Shopping Exploration Journey                                                                         Adventure                                                                                           
Jason James                                                                                           deleonjack@example.com                             Perry, Ware and Harrell                                                                              Ultimate Golfing Experience                                                                          Adventure                                                                                           
Janet Jones                                                                                           gdominguez@example.net                             Caldwell-Mueller                                                                                     Cultural Experience Escape                                                                           Adventure                                                                                           
                                                                                                                                                         David-Estrada                                                                                        Unforgettable Cultural Experience Trip                                                               Adventure                                                                                           
Katherine Kent                                                                                        alicia98@example.org                               Kemp Ltd                                                                                             Nightlife Discovery Tour                                                                             Adventure                                                                                           
Dillon Leach                                                                                          tarmstrong@example.org                             Herman LLC                                                                                           Nightlife Discovery Tour                                                                             Adventure                                                                                           
Hannah Logan                                                                                          sfranklin@example.org                              Cantrell-Hill                                                                                        Sports Events Escape                                                                                 Adventure                                                                                           
Brittany Lucas                                                                                        emilyjohnson@example.org                           Brock-Boone                                                                                          Yoga Retreat Exploration Journey                                                                     Adventure                                                                                           
Christina Lyons                                                                                       melissa07@example.org                              Patel-Carlson                                                                                        Unforgettable Music Festival Trip                                                                    Adventure                                                                                           
Melinda Martin                                                                                        baileyrobert@example.com                           Leon and Sons                                                                                        Exciting Cruise Adventure                                                                            Adventure                                                                                           
Virginia Martinez                                                                                     wellis@example.net                                 Barnett Ltd                                                                                          Guided Sports Events Experience                                                                      Adventure                                                                                           
                                                                                                                                                         Robles, Randall and Pearson                                                                          Guided Sports Events Experience                                                                      Adventure                                                                                           
Gregory Murphy                                                                                        meganmeza@example.net                              Spencer, Gibson and Moreno                                                                           Ultimate Golfing Experience                                                                          Adventure                                                                                           
Logan Padilla                                                                                         ubowman@example.net                                Ferguson, Ortiz and Morgan                                                                           Exciting Art andCraft Adventure                                                                      Adventure                                                                                           
                                                                                                                                                         Lloyd, Richards and Gonzalez                                                                         Unforgettable Wildlife Safari Trip                                                                   Adventure                                                                                           
Jean Peterson                                                                                         valenciamichael@example.org                        Harris Ltd                                                                                           Guided Sailing Experience                                                                            Adventure                                                                                           
                                                                                                                                                         Stafford, Simmons and Parks                                                                          Exciting Photography Adventure                                                                       Adventure                                                                                           
Jeffrey Raymond                                                                                       catherineatkins@example.org                        Price-Cook                                                                                           Guided Road Trip Experience                                                                          Adventure                                                                                           
Emily Robbins                                                                                         raymond67@example.org                              Rodriguez, Thompson and Evans                                                                        Ultimate Wildlife Safari Experience                                                                  Adventure                                                                                           
Sharon Roman                                                                                          angelagoodwin@example.com                          Davis Inc                                                                                            Exciting Spa andWellness Adventure                                                                   Adventure                                                                                           
                                                                                                                                                         Duran, Wheeler and Walker                                                                            Beach Discovery Tour                                                                                 Adventure                                                                                           
Susan Russell                                                                                         derekcruz@example.com                              Perez PLC                                                                                            Food andDrink Discovery Tour                                                                         Adventure                                                                                           
Juan Scott                                                                                            johnburton@example.com                             Hill, Diaz and Stewart                                                                               Unforgettable Mountain Trip                                                                          Adventure                                                                                           
Michael Turner                                                                                        ktucker@example.org                                Davis-Gregory                                                                                        Music Festival Exploration Journey                                                                   Adventure                                                                                           
Christopher Vincent                                                                                   kevinscott@example.org                             Williams-Wells                                                                                       Ultimate Sports Events Experience                                                                    Adventure                                                                                           
Teresa Walker                                                                                         youngnicholas@example.net                          Farmer-Garcia                                                                                        Camping Exploration Journey                                                                          Adventure                                                                                           
Whitney Walker                                                                                        pamelastokes@example.org                           Jones Ltd                                                                                            Guided Golfing Experience                                                                            Adventure                                                                                           
Susan Ward                                                                                            stevenwelch@example.net                            Spencer, Gibson and Moreno                                                                           Ultimate Golfing Experience                                                                          Adventure                                                                                           
                                                                                                                                                         Stewart LLC                                                                                          Unforgettable Yoga Retreat Trip                                                                      Adventure                                                                                           
Karen Williams                                                                                        lyonseric@example.com                              Cantrell-Hill                                                                                        Guided Skiing Experience                                                                             Adventure                                                                                           

42 rows selected.  
*/