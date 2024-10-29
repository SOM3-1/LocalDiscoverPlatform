-- Query 1: Total Revenue per Service Provider and Experience Category
SELECT 
    sp.Service_Provider_ID,
    ic.Category_Name AS Experience_Category,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Dg_Bookings b
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Dg_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Dg_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
GROUP BY ROLLUP (sp.Service_Provider_ID, ic.Category_Name);

-- Query 2: Total Bookings and Revenue by Service Provider and Month
SELECT 
    sp.Service_Provider_ID,
    sp.City AS Service_Provider_City,
    TO_CHAR(b.Date_Of_Booking, 'YYYY-MM') AS Booking_Month,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Dg_Bookings b
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
WHERE 
    sp.City LIKE '%est%'  -- Adjust this to any pattern as needed
GROUP BY 
    sp.Service_Provider_ID, sp.City, TO_CHAR(b.Date_Of_Booking, 'YYYY-MM')
ORDER BY 
    Total_Revenue DESC;

-- Query 3: Top 5 Most Booked Experiences with Location Details
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    l.Location_Name,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Experience e
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Dg_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Dg_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    e.Experience_ID, e.Title, l.Location_Name
ORDER BY 
    NumberOfBookings DESC
FETCH FIRST 5 ROWS ONLY;

-- Query 4: Average Rating per Service Provider with Minimum 5 Ratings
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS Service_Provider_Name,
    AVG(r.Rating_Value) AS Average_Rating
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
HAVING 
    COUNT(r.Rating_ID) > 5
ORDER BY 
    Average_Rating DESC;

-- Query 5: Total Earnings by Service Provider and Experience Category with ROLLUP
SELECT 
    sp.Service_Provider_ID,
    ic.Category_Name AS Experience_Category,
    SUM(b.Amount_Paid) AS Total_Earnings
FROM 
    Dg_Bookings b
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Dg_Service_Provider_Activities spa ON spa.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Dg_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
GROUP BY 
    ROLLUP (sp.Service_Provider_ID, ic.Category_Name);

-- Query 6: Total Bookings and Revenue by Month and Location with CUBE
SELECT 
    EXTRACT(MONTH FROM b.Date_Of_Booking) AS Month,
    l.Location_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Dg_Bookings b
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Schedule_Locations sl ON e.Schedule_ID = sl.Schedule_ID
JOIN 
    Dg_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY CUBE (EXTRACT(MONTH FROM b.Date_Of_Booking), l.Location_Name)
ORDER BY 
    Total_Bookings DESC;

-- Query 7: Service Providers Offering All Categories
SELECT 
    sp.Service_Provider_ID,
    sp.Name,
    COUNT(DISTINCT spa.Activity_ID) AS Categories_Covered
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Service_Provider_Activities spa ON spa.Service_Provider_ID = sp.Service_Provider_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
HAVING 
    COUNT(DISTINCT spa.Activity_ID) >= 4
ORDER BY 
    Categories_Covered DESC;

-- Query 8: Average Rating per Experience and Overall Average Rating per Traveler
SELECT 
    t.T_ID AS Traveler_ID,
    e.Experience_ID,
    e.Title AS Experience_Title,
    AVG(r.Rating_Value) AS Average_Rating,
    AVG(AVG(r.Rating_Value)) OVER (PARTITION BY t.T_ID) AS Overall_Average_Rating
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Dg_Ratings r ON b.Experience_ID = r.Experience_ID
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
GROUP BY 
    t.T_ID, e.Experience_ID, e.Title
    ORDER BY Overall_Average_Rating DESC;

-- Query 9: Top 10 Highest and Lowest Rated Service Providers
SELECT * FROM (
    SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        AVG(r.Rating_Value) AS AverageRating,
        'Top 10 Highest' AS RatingCategory
    FROM 
        Dg_Service_Provider sp
    JOIN 
        Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Dg_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        AverageRating DESC
) WHERE ROWNUM <= 10

UNION ALL

SELECT * FROM (
    SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        AVG(r.Rating_Value) AS AverageRating,
        'Top 10 Lowest' AS RatingCategory
    FROM 
        Dg_Service_Provider sp
    JOIN 
        Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Dg_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        AverageRating ASC
) WHERE ROWNUM <= 10;
