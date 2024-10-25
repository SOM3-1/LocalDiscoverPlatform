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

--service provider
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

--group
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

--eader and their group members
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


--tags concat
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

--Bookings
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

--TRaveler not reviewd
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


--Top 10 highest anf top 10 lowest rated service provider
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

--Grooup booking analysis
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
