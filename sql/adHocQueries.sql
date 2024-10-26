--- TRAVELERS ---
-- All the travelers with location and preferences
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.DOB,
    t.Demographic_Type,
    t.Sex,
    l.Location_Name AS Location,
    t.Email,
    t.Phone,
    p.Category_Name AS Preference_Name
FROM 
    Dg_Travelers t
JOIN 
    Dg_Locations l ON t.Location_ID = l.Location_ID
JOIN 
    Dg_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Dg_Interest_Categories p ON tp.Preference_ID = p.Category_ID
ORDER BY 
    t.T_ID, p.Category_Name;

--travelers in group
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.Email,
    gm.Group_ID
FROM 
    Dg_Group_Members gm
JOIN 
    Dg_Travelers t ON gm.T_ID = t.T_ID
ORDER BY 
    gm.Group_ID, t.T_ID;

---Travelers preference
SELECT 
    t.T_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    t.Email,
    t.Phone,
    ic.Category_Name AS Preference
FROM 
    Dg_Travelers t
JOIN 
    Dg_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Dg_Interest_Categories ic ON tp.Preference_ID = ic.Category_ID;

---travelers with most bookings
SELECT 
    t.T_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    COUNT(b.Booking_ID) AS Total_Bookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name
ORDER BY 
    Total_Bookings DESC;

--- TRAVELERS QUERIES ENDS ---


--- GROUP QUERIES ---
--group details
SELECT 
    g.Group_ID,
    g.Group_Name,
    g.Group_Type,
    g.Group_Leader_T_ID AS Leader_ID,
    leader.First_Name AS Leader_First_Name,
    leader.Last_Name AS Leader_Last_Name,
    gm.T_ID AS Member_ID,
    member.First_Name AS Member_First_Name,
    member.Last_Name AS Member_Last_Name
FROM 
    Dg_Groups g
JOIN 
    Dg_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
LEFT JOIN 
    Dg_Group_Members gm ON g.Group_ID = gm.Group_ID
LEFT JOIN 
    Dg_Travelers member ON gm.T_ID = member.T_ID
ORDER BY 
    g.Group_ID;

-- Travelers booked as a group
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    g.Group_ID,
    g.Group_Name,
    b.Booking_ID,
    e.Title AS ExperienceTitle
FROM 
    Dg_Travelers t
JOIN 
    Dg_Group_Members gm ON t.T_ID = gm.T_ID
JOIN 
    Dg_Groups g ON gm.Group_ID = g.Group_ID
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
ORDER BY 
    t.T_ID, g.Group_ID;

--Leader and their group members
SELECT 
    g.Group_ID,
    g.Group_Name,
    leader.T_ID AS Leader_ID,
    leader.First_Name AS Leader_First_Name,
    leader.Last_Name AS Leader_Last_Name,
    member.T_ID AS Member_ID,
    member.First_Name AS Member_First_Name,
    member.Last_Name AS Member_Last_Name
FROM 
    Dg_Groups g
JOIN 
    Dg_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
JOIN 
    Dg_Group_Members gm ON g.Group_ID = gm.Group_ID
JOIN 
    Dg_Travelers member ON gm.T_ID = member.T_ID
ORDER BY 
    g.Group_ID, member.T_ID;

--- GROUP QUERIES ENDS ---

--- SERVICE PROVIDER ---

--  service provider details 
SELECT 
    sp.Service_Provider_ID,
    sp.Name,
    sp.Email,
    sp.Phone,
    sp.Bio,
    sp.Street,
    sp.City,
    sp.Zip,
    sp.Country,
    ic.Category_Name AS Activity_Name,
    asch.Available_Date,
    loc.Location_Name AS Schedule_Location,
    st.Start_Time,
    st.End_Time
FROM 
    Dg_Service_Provider sp
LEFT JOIN 
    Dg_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
LEFT JOIN 
    Dg_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
LEFT JOIN 
    Dg_Availability_Schedule asch ON sp.Service_Provider_ID = asch.Service_Provider_ID
LEFT JOIN 
    Dg_Schedule_Locations sl ON asch.Schedule_ID = sl.Schedule_ID
LEFT JOIN 
    Dg_Locations loc ON sl.Location_ID = loc.Location_ID
LEFT JOIN 
    Dg_Schedule_Times st ON asch.Schedule_ID = st.Schedule_ID
ORDER BY 
    sp.Name, ic.Category_Name, asch.Available_Date, st.Start_Time;

--- Service Provider Availability ---
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    L.Location_Name,
    S.Available_Date,
    ST.Start_Time,
    ST.End_Time
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
JOIN 
    Dg_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
JOIN 
    Dg_Locations L ON SL.Location_ID = L.Location_ID
JOIN 
    Dg_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID;

--- Service Provider Experience List
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    E.Experience_ID,
    E.Title AS Experience_Title,
    E.Pricing,
    E.Group_Availability,
    E.Min_Group_Size,
    E.Max_Group_Size
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID;

--Most booked service provider
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    COUNT(B.Booking_ID) AS Bookings_Count
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Dg_Bookings B ON E.Experience_ID = B.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name
ORDER BY 
    Bookings_Count DESC;

---SP by location
SELECT 
    L.Location_Name,
    COUNT(DISTINCT SP.Service_Provider_ID) AS Number_Of_Providers
FROM 
    Dg_Locations L
JOIN 
    Dg_Schedule_Locations SL ON L.Location_ID = SL.Location_ID
JOIN 
    Dg_Availability_Schedule S ON SL.Schedule_ID = S.Schedule_ID
JOIN 
    Dg_Service_Provider SP ON S.Service_Provider_ID = SP.Service_Provider_ID
GROUP BY 
    L.Location_Name;

--- Top-Rated Experiences per Service Provider
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    E.Experience_ID,
    E.Title AS Experience_Title,
    AVG(R.Rating_Value) AS Average_Rating
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Dg_Ratings R ON E.Experience_ID = R.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name, E.Experience_ID, E.Title
HAVING 
    AVG(R.Rating_Value) >= 8;  -- Filter to show only highly rated experiences

--- Service Provider Bookings Overview
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    COUNT(B.Booking_ID) AS Total_Bookings
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Dg_Bookings B ON E.Experience_ID = B.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name;

--- Service Provider Ratings and Feedback
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    AVG(R.Rating_Value) AS Average_Rating,
    COUNT(R.Rating_ID) AS Number_Of_Ratings
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Dg_Ratings R ON E.Experience_ID = R.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name;

---Service Provider Availability Summary
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    L.Location_Name,
    S.Available_Date,
    ST.Start_Time,
    ST.End_Time
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
JOIN 
    Dg_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
JOIN 
    Dg_Locations L ON SL.Location_ID = L.Location_ID
JOIN 
    Dg_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID;

--- Service Provider Details with Offered Activities
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    SP.Email,
    SP.Phone,
    IC.Category_Name AS Activity
FROM 
    Dg_Service_Provider SP
JOIN 
    Dg_Service_Provider_Activities SPA ON SP.Service_Provider_ID = SPA.Service_Provider_ID
JOIN 
    Dg_Interest_Categories IC ON SPA.Activity_ID = IC.Category_ID;




--- SERVICE PROVIDER ENDS ---



--- EXPEREINCE ---


--all expe details
SELECT 
    E.Title AS Experience_Name,
    SP.Name AS Service_Provider_Name,
    T.Tag_Name AS Tag,
    S.Available_Date AS Schedule_Date,
    ST.Start_Time AS Schedule_Start_Time,
    ST.End_Time AS Schedule_End_Time
FROM 
    Dg_Experience E
JOIN 
    Dg_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Dg_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
JOIN 
    Dg_Tags T ON ET.Tag_ID = T.Tag_ID
JOIN 
    Dg_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
JOIN 
    Dg_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
ORDER BY 
    E.Title, T.Tag_Name;

--experience
SELECT 
    E.Experience_ID,
    E.Title AS Experience_Title,
    E.Description AS Experience_Description,
    E.Group_Availability,
    E.Min_Group_Size,
    E.Max_Group_Size,
    E.Pricing,
    T.Tag_Name AS Tag,
    S.Schedule_ID,
    S.Available_Date,
    ST.Start_Time,
    ST.End_Time
FROM 
    Dg_Experience E
LEFT JOIN 
    Dg_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
LEFT JOIN 
    Dg_Tags T ON ET.Tag_ID = T.Tag_ID
LEFT JOIN 
    Dg_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
LEFT JOIN 
    Dg_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
ORDER BY 
    E.Experience_ID, T.Tag_Name;

---Expereince summary 
SELECT 
    E.Experience_ID,
    E.Title,
    E.Description,
    E.Pricing,
    SP.Name AS Service_Provider,
    L.Location_Name AS Location
FROM 
    Dg_Experience E
JOIN 
    Dg_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Dg_Schedule_Locations SL ON E.Schedule_ID = SL.Schedule_ID
JOIN 
    Dg_Locations L ON SL.Location_ID = L.Location_ID;


--expereince tags concat
SELECT 
    E.Title AS Experience_Name,
    SP.Name AS Service_Provider_Name,
    LISTAGG(T.Tag_Name, ', ') WITHIN GROUP (ORDER BY T.Tag_Name) AS Tags,
    S.Available_Date AS Schedule_Date,
    ST.Start_Time AS Schedule_Start_Time,
    ST.End_Time AS Schedule_End_Time
FROM 
    Dg_Experience E
JOIN 
    Dg_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Dg_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
JOIN 
    Dg_Tags T ON ET.Tag_ID = T.Tag_ID
JOIN 
    Dg_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
JOIN 
    Dg_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
GROUP BY 
    E.Title, SP.Name, S.Available_Date, ST.Start_Time, ST.End_Time
ORDER BY 
    E.Title;

---Experiences by Pricing Range
SELECT 
    CASE 
        WHEN Pricing < 50 THEN 'Low'
        WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END AS Price_Range,
    COUNT(e.Experience_ID) AS Number_Of_Experiences
FROM 
    Dg_Experience e
GROUP BY 
    CASE 
        WHEN Pricing < 50 THEN 'Low'
        WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END;

--- EXPERIENCE QUERY ENDS ---



--- BOOKINGS ---

-- Bookings details
SELECT 
    b.Booking_ID,
    b.Traveler_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    b.Experience_ID,
    e.Title AS Experience_Title,
    TO_CHAR(b.Date_Of_Booking, 'YYYY-MM-DD HH24:MI:SS') AS Date_Of_Booking,
    TO_CHAR(b.Experience_Date, 'YYYY-MM-DD') AS Experience_Date,
    b.Amount_Paid,
    bs.Status_Name AS Booking_Status,
    ps.Payment_Status_Name AS Payment_Status,
    bm.Method_Name AS Booking_Method
FROM 
    Dg_Bookings b
JOIN 
    Dg_Travelers t ON b.Traveler_ID = t.T_ID
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
JOIN 
    Dg_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
JOIN 
    Dg_Booking_Methods bm ON b.Booking_Method_ID = bm.Method_ID
ORDER BY 
    b.Date_Of_Booking DESC;


--- Booking and payment status
SELECT 
    B.Booking_ID,
    T.First_Name || ' ' || T.Last_Name AS Traveler_Name,
    E.Title AS Experience_Title,
    B.Experience_Date,
    B.Amount_Paid,
    PS.Payment_Status_Name AS Payment_Status
FROM 
    Dg_Bookings B
JOIN 
    Dg_Travelers T ON B.Traveler_ID = T.T_ID
JOIN 
    Dg_Experience E ON B.Experience_ID = E.Experience_ID
JOIN 
    Dg_Payment_Status PS ON B.Payment_Status_ID = PS.Payment_Status_ID;

--Atleast one booking for a traveler
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(b.Booking_ID) >= 1
ORDER BY 
    NumberOfBookings DESC;

--More than one booking
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(b.Booking_ID) > 1
ORDER BY 
    NumberOfBookings DESC;

--no bookings
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email
FROM 
    Dg_Travelers t
LEFT JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
WHERE 
    b.Booking_ID IS NULL
ORDER BY 
    t.T_ID;

-- Expereince booked by traveler 
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    e.Description AS ExperienceDescription,
    sp.Name AS ServiceProvider,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Experience e
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
GROUP BY 
    e.Experience_ID, e.Title, e.Description, sp.Name
ORDER BY 
    NumberOfBookings DESC;

--Number of expereinces booked for a service provider
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    NumberOfBookings DESC;

--Cancelled bookings
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    COUNT(b.Booking_ID) AS NumberOfCanceledBookings
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Dg_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Cancelled'
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    NumberOfCanceledBookings DESC;

--Traveler cancelled booking
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    COUNT(b.Booking_ID) AS NumberOfCancelledBookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Dg_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Cancelled'
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
ORDER BY 
    NumberOfCancelledBookings DESC;

-- All the traveler who has booked 
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    b.Booking_ID,
    e.Title AS ExperienceTitle,
    sp.Name AS ServiceProvider,
    r.Rating_Value AS Rating,
    TO_CHAR(r.Review_Date_Time, 'YYYY-MM-DD HH24:MI:SS') AS ReviewDate
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
LEFT JOIN 
    Dg_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
ORDER BY 
    t.T_ID, b.Booking_ID;

--- BOOKINGS QUERY ENDS ---



--- RATINGS ---

--Traveler who has reviewed
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(r.Rating_ID) AS NumberOfReviews
FROM 
    Dg_Travelers t
JOIN 
    Dg_Ratings r ON t.T_ID = r.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(r.Rating_ID) >= 1
ORDER BY 
    NumberOfReviews DESC;

--Traveler not reviewd
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
LEFT JOIN 
    Dg_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
WHERE 
    r.Rating_ID IS NULL
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
ORDER BY 
    t.T_ID;



--Traveler reviewd all details
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    b.Booking_ID,
    e.Title AS ExperienceTitle,
    sp.Name AS ServiceProvider,
    r.Rating_Value AS Rating,
    TO_CHAR(r.Review_Date_Time, 'YYYY-MM-DD HH24:MI:SS') AS ReviewDate
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Dg_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Dg_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
ORDER BY 
    t.T_ID, b.Booking_ID;

--Average rating of service provider 
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    AverageRating DESC;

--Average rating for expereinces
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    e.Description AS ExperienceDescription,
    sp.Name AS ServiceProvider,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Dg_Experience e
JOIN 
    Dg_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Dg_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title, e.Description, sp.Name
ORDER BY 
    AverageRating DESC;

---Top-Rated Experiences Lists 
SELECT 
    e.Experience_ID,
    e.Title,
    AVG(r.Rating_Value) AS Average_Rating,
    COUNT(r.Rating_ID) AS Number_Of_Ratings
FROM 
    Dg_Experience e
JOIN 
    Dg_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title
HAVING 
    AVG(r.Rating_Value) >= 8
ORDER BY 
    Average_Rating DESC;

--- RATINGS QUERY ENDS ---




--- ANALYSIS OF BOOKINGS ---

--Total earnings for confimed
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    SUM(b.Amount_Paid) AS TotalEarnings
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Dg_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Confirmed' 
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    TotalEarnings DESC;


-- Total refunded 
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    SUM(b.Amount_Paid) AS TotalRefundedEarnings
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Dg_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
WHERE 
    ps.Payment_Status_Name = 'Refunded'
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    TotalRefundedEarnings DESC;

--Service Provider with most booking
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    COUNT(b.Booking_ID) AS TotalBookings
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
ORDER BY 
    TotalBookings DESC;


--Booking over time
SELECT 
    TO_CHAR(Date_Of_Booking, 'YYYY-MM') AS BookingMonth,
    COUNT(Booking_ID) AS NumberOfBookings
FROM 
    Dg_Bookings
GROUP BY 
    TO_CHAR(Date_Of_Booking, 'YYYY-MM')
ORDER BY 
    BookingMonth;


--Top locations
SELECT 
    l.Location_ID,
    l.Location_Name,
    COUNT(e.Experience_ID) AS NumberOfAvailableExperiences
FROM 
    Dg_Locations l
JOIN 
    Dg_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
JOIN 
    Dg_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
JOIN 
    Dg_Experience e ON s.Schedule_ID = e.Schedule_ID
GROUP BY 
    l.Location_ID, l.Location_Name
ORDER BY 
    NumberOfAvailableExperiences DESC;

--Average Rating by locations
SELECT 
    l.Location_Name,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Dg_Ratings r
JOIN 
    Dg_Experience e ON r.Experience_ID = e.Experience_ID
JOIN 
    Dg_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
JOIN 
    Dg_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
JOIN 
    Dg_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    l.Location_Name
ORDER BY 
    AverageRating DESC;

--Group booking analysis
SELECT 
    gt.Group_Type_Name,
    COUNT(gm.Group_ID) AS NumberOfGroupBookings
FROM 
    Dg_Group_Types gt
JOIN 
    Dg_Groups g ON gt.Group_Type_ID = g.Group_Type_ID
JOIN 
    Dg_Group_Members gm ON g.Group_ID = gm.Group_ID
GROUP BY 
    gt.Group_Type_Name
ORDER BY 
    NumberOfGroupBookings DESC;

--Traveler demographic analysis
SELECT 
    t.Demographic_Type,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.Demographic_Type
ORDER BY 
    NumberOfBookings DESC;

--Refund Rate Analysis
SELECT 
    (COUNT(CASE WHEN b.Payment_Status_ID = 
        (SELECT Payment_Status_ID FROM Dg_Payment_Status WHERE Payment_Status_Name = 'Refunded') 
    THEN 1 END) / COUNT(*)) * 100 AS RefundRate
FROM 
    Dg_Bookings b;

--Locations with most booking
SELECT 
    l.Location_ID,
    l.Location_Name,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Locations l
JOIN 
    Dg_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
JOIN 
    Dg_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
JOIN 
    Dg_Experience e ON s.Schedule_ID = e.Schedule_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    l.Location_ID, l.Location_Name
ORDER BY 
    NumberOfBookings DESC;


--Highest and lowest Ratings
SELECT * FROM (
    SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        AVG(r.Rating_Value) AS AverageRating,
        'Highest' AS RatingType
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
) WHERE ROWNUM = 1

UNION ALL

SELECT * FROM (
    SELECT 
        sp.Service_Provider_ID,
        sp.Name AS ServiceProviderName,
        sp.Email AS ServiceProviderEmail,
        sp.Phone AS ServiceProviderPhone,
        sp.City AS ServiceProviderCity,
        AVG(r.Rating_Value) AS AverageRating,
        'Lowest' AS RatingType
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
) WHERE ROWNUM = 1;


--Top 10 highest and top 10 lowest rated service provider
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


--Most booked Expereince
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Experience e
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title
ORDER BY 
    NumberOfBookings DESC
FETCH FIRST 5 ROWS ONLY;

--Top Travelers
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Dg_Travelers t
JOIN 
    Dg_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name
ORDER BY 
    NumberOfBookings DESC
FETCH FIRST 10 ROWS ONLY;


--Average payment status
SELECT 
    ps.Payment_Status_Name,
    AVG(b.Amount_Paid) AS AverageAmountPaid
FROM 
    Dg_Bookings b
JOIN 
    Dg_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
GROUP BY 
    ps.Payment_Status_Name
ORDER BY 
    AverageAmountPaid DESC;

--- Service preovider Revenue
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS Service_Provider_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Dg_Service_Provider sp
JOIN 
    Dg_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Dg_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name;

---Daily bookings
SELECT 
    TRUNC(b.Date_Of_Booking) AS Booking_Date,
    COUNT(b.Booking_ID) AS Number_Of_Bookings
FROM 
    Dg_Bookings b
GROUP BY 
    TRUNC(b.Date_Of_Booking)
ORDER BY 
    Booking_Date;

--- ANALYSIS QUERY ENDS ---