
-- Query 1: Top Monthly Demographic, Location, and Activity by Bookings
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

-- Query 2: Customer Retention and Loyalty Analysis
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

-- Query 3: Expereince diversity Analysis using rollup
SELECT 
    l.Location_Name AS Destination,
    ic.Category_Name AS Experience_Category,
    COUNT(e.Experience_ID) AS Total_Experiences
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    ROLLUP (l.Location_Name, ic.Category_Name)
ORDER BY 
    Destination, Experience_Category;

-- Query 4: Confirmed Bookings Lacking Ratings with Traveler's Total Booking Count
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
      -- Check if there is no rating for this specific booking's experience
      SELECT 1
      FROM Fall24_S003_T8_Ratings r
      WHERE r.Traveler_ID = t.T_ID
        AND r.Experience_ID = b.Experience_ID
  )
ORDER BY Total_Bookings, t.T_ID, b.Booking_ID;

-- Query 5: Quarterly and Yearly Booking and Revenue Analysis by Location
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
ORDER BY 
    Year DESC, Quarter DESC, Total_Bookings DESC;

-- Query 6: Experience Distribution by Location and Category with Totals
SELECT
    l.Location_Name AS Destination,
    ic.Category_Name AS Experience_Category,
    COUNT(e.Experience_ID) AS Total_Experiences
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    CUBE (l.Location_Name, ic.Category_Name);

-- Query 7: Seasonal trends and spendings
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

-- Query 8: Top 10 service provider based on weightage(70& to rating and remaining 30% to total bookings)
-- Score=(Average Rating×0.7)+((Total Bookings/Max Total Bookings)​×10×0.3)
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
    ProviderWithSingleLocation loc ON rp.Service_Provider_ID = loc.Service_Provider_ID AND loc.LocationRank = 1  -- Only first location
WHERE 
    rp.Rank <= 10
ORDER BY 
    rp.Score DESC;

-- Query 9: Adventure-Seeking Travelers and Their Booked Experiences with Service Providers
SELECT 
    T.First_Name || ' ' || T.Last_Name AS Traveler_Name,
    T.Email AS Traveler_Email,
    SP.Name AS Service_Provider_Name,
    E.Title AS Experience_Title,
    C.Category_Name AS Category
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
    OR C.Category_Name LIKE '%Camping%' 
    OR C.Category_Name LIKE '%Mountain%' 
    OR C.Category_Name LIKE '%Skiing%'
ORDER BY 
    T.Last_Name, T.First_Name;
