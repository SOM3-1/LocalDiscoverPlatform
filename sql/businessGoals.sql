-- Query 1: Total Revenue per Service Provider and Experience Category
SELECT 
    sp.Service_Provider_ID,
    ic.Category_Name AS Experience_Category,
    l.Location_Name AS Destination,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    sp.Service_Provider_ID, ic.Category_Name, l.Location_Name
HAVING 
    SUM(b.Amount_Paid) > 0
ORDER BY 
    Total_Revenue DESC
FETCH FIRST 10 ROWS ONLY;

-- Query 2: Top Monthly Demographic, Location, and Activity by Bookings
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

-- Query 3: Guide/Business Performance Metrics
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS Guide_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    AVG(r.Rating_Value) AS Average_Rating,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
LEFT JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
HAVING 
    COUNT(b.Booking_ID) > 0 
ORDER BY 
    Total_Bookings DESC,
    Average_Rating DESC,
    Total_Revenue DESC
FETCH FIRST 10 ROWS ONLY;

-- Query 4: Customer Retention and Loyalty Analysis

SELECT 
    t.T_ID AS Traveler_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    ic.Category_Name AS Preference_Category,
    COUNT(b.Booking_ID) AS Repeat_Bookings,
    ROUND(AVG(b.Amount_Paid), 2) AS Average_Spend
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON e.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
WHERE 
    b.Booking_Status_ID = (SELECT Status_ID FROM Fall24_S003_T8_Booking_Status WHERE Status_Name = 'Confirmed') 
    AND b.Amount_Paid > 0  -- Only include non-zero payments
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, ic.Category_Name
HAVING 
    COUNT(b.Booking_ID) > 1  -- Focus on repeat customers
ORDER BY 
    Repeat_Bookings DESC,
    Average_Spend DESC;

-- Query 5: Expereince quality
SELECT 
    sp.Service_Provider_ID,
    ic.Category_Name AS Experience_Category,
    SUM(b.Amount_Paid) AS Total_Revenue,
    AVG(r.Rating_Value) AS Average_Rating
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
LEFT JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
GROUP BY 
    sp.Service_Provider_ID, ic.Category_Name
HAVING 
    SUM(b.Amount_Paid) > 0  -- Only providers with bookings
ORDER BY 
    Total_Revenue DESC
FETCH FIRST 10 ROWS ONLY;

-- Query 6: Location with most bookings
SELECT 
    l.Location_Name AS Destination,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    l.Location_Name
ORDER BY 
    Total_Bookings DESC, Total_Revenue DESC
FETCH FIRST 10 ROWS ONLY;

-- Query 7: Epereince diversity Analysis using rollup
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

-- Query 8: Seasonal trends and spendings

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


-- Query 9: Time Between Booking and Experience Date
SELECT 
    t.T_ID AS Traveler_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    AVG(EXTRACT(DAY FROM (b.Experience_Date - b.Date_Of_Booking))) AS Avg_Planning_Days,
    MIN(EXTRACT(DAY FROM (b.Experience_Date - b.Date_Of_Booking))) AS Min_Planning_Days,
    MAX(EXTRACT(DAY FROM (b.Experience_Date - b.Date_Of_Booking))) AS Max_Planning_Days
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name || ' ' || t.Last_Name
ORDER BY 
    Avg_Planning_Days DESC;

-- Query 10: Guide Engagement and Support Needs
SELECT 
    sp.Name AS Guide_Name,
    ic.Category_Name AS Activity_Category,
    AVG(r.Rating_Value) AS Avg_Rating,
    COUNT(r.Rating_ID) AS Total_Ratings,
    COUNT(CASE WHEN r.Rating_Value < 5 THEN 1 END) AS Low_Ratings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Name, ic.Category_Name
HAVING 
    AVG(r.Rating_Value) < 6 OR COUNT(CASE WHEN r.Rating_Value < 5 THEN 1 END) > 0
ORDER BY 
    Avg_Rating ASC, Low_Ratings DESC;
