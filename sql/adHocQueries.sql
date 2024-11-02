--- TRAVELERS ---
-- Query: All Travelers with Location and Preferences - VW_Fall24_S003_T8_TRAVELERS_LOCATION_PREFERENCES
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
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Locations l ON t.Location_ID = l.Location_ID
JOIN 
    Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Fall24_S003_T8_Interest_Categories p ON tp.Preference_ID = p.Category_ID
ORDER BY 
    t.T_ID, p.Category_Name;

-- Query: All Travelers in Groups - VW_Fall24_S003_T8_TRAVELERS_IN_GROUPS
SELECT 
    t.T_ID,
    t.First_Name,
    t.Last_Name,
    t.Email,
    gm.Group_ID
FROM 
    Fall24_S003_T8_Group_Members gm
JOIN 
    Fall24_S003_T8_Travelers t ON gm.T_ID = t.T_ID
ORDER BY 
    gm.Group_ID, t.T_ID;

--- Query: All Traveler Preferences - VW_Fall24_S003_T8_TRAVELER_PREFERENCES
SELECT 
    t.T_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    t.Email,
    t.Phone,
    ic.Category_Name AS Preference
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON tp.Preference_ID = ic.Category_ID;

--- Query: Travelers with the Most Bookings - VW_Fall24_S003_T8_TRAVELERS_MOST_BOOKINGS
SELECT 
    t.T_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    COUNT(b.Booking_ID) AS Total_Bookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name
ORDER BY 
    Total_Bookings DESC;

--- TRAVELERS QUERIES ENDS ---


--- GROUP QUERIES ---
-- Query: Group Details with Leader and Member Information - VW_Fall24_S003_T8_GROUP_DETAILS_LEADER_MEMBER
SELECT 
    g.Group_ID,
    g.Group_Name,
    gt.Group_Type_Name AS Group_Type,
    g.Group_Leader_T_ID AS Leader_ID,
    leader.First_Name || ' ' || leader.Last_Name AS Leader_Full_Name,
    LISTAGG(member.First_Name || ' ' || member.Last_Name, ', ') WITHIN GROUP (ORDER BY member.Last_Name) AS Member_Full_Names
FROM 
    Fall24_S003_T8_Groups g
JOIN 
    Fall24_S003_T8_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
LEFT JOIN 
    Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
LEFT JOIN 
    Fall24_S003_T8_Travelers member ON gm.T_ID = member.T_ID
JOIN
    Fall24_S003_T8_Group_Types gt ON g.Group_Type_ID = gt.Group_Type_ID
GROUP BY 
    g.Group_ID,
    g.Group_Name,
    gt.Group_Type_Name,
    g.Group_Leader_T_ID,
    leader.First_Name || ' ' || leader.Last_Name
ORDER BY 
    g.Group_ID;

-- Query: Travelers Booked as Part of a Group Experience - VW_Fall24_S003_T8_TRAVELERS_GROUP_BOOKINGS
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    g.Group_ID,
    g.Group_Name,
    b.Booking_ID,
    e.Title AS ExperienceTitle
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Group_Members gm ON t.T_ID = gm.T_ID
JOIN 
    Fall24_S003_T8_Groups g ON gm.Group_ID = g.Group_ID
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
ORDER BY 
    t.T_ID, g.Group_ID;

-- Query: Group Leaders and Their Members - VW_Fall24_S003_T8_GROUP_LEADERS_MEMBERS
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
    Fall24_S003_T8_Groups g
JOIN 
    Fall24_S003_T8_Travelers leader ON g.Group_Leader_T_ID = leader.T_ID
JOIN 
    Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
JOIN 
    Fall24_S003_T8_Travelers member ON gm.T_ID = member.T_ID
ORDER BY 
    g.Group_ID, member.T_ID;

--- GROUP QUERIES ENDS ---

--- SERVICE PROVIDER ---

-- Query: Service Provider Full Details with Schedule and Activities - VW_Fall24_S003_T8_SERVICE_PROVIDER_FULL_DETAILS
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
    Fall24_S003_T8_Service_Provider sp
LEFT JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
LEFT JOIN 
    Fall24_S003_T8_Availability_Schedule asch ON sp.Service_Provider_ID = asch.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON asch.Schedule_ID = sl.Schedule_ID
LEFT JOIN 
    Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
LEFT JOIN 
    Fall24_S003_T8_Schedule_Times st ON asch.Schedule_ID = st.Schedule_ID
ORDER BY 
    sp.Name, ic.Category_Name, asch.Available_Date, st.Start_Time;

--- Query: Service Provider Availability by Location and Date - VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_BY_LOCATION_DATE
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    L.Location_Name,
    S.Available_Date,
    ST.Start_Time,
    ST.End_Time
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID
JOIN 
    Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID;

--- Query: List of Experiences Offered by Each Service Provider - VW_Fall24_S003_T8_SERVICE_PROVIDER_EXPERIENCES_LIST
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
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID;

-- Query: Most Booked Service Providers - VW_Fall24_S003_T8_MOST_BOOKED_SERVICE_PROVIDERS
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    COUNT(B.Booking_ID) AS Bookings_Count
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings B ON E.Experience_ID = B.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name
ORDER BY 
    Bookings_Count DESC;

--- Query: Service Providers by Location - VW_Fall24_S003_T8_SERVICE_PROVIDER_BY_LOCATION
SELECT 
    L.Location_Name,
    COUNT(DISTINCT SP.Service_Provider_ID) AS Number_Of_Providers
FROM 
    Fall24_S003_T8_Locations L
JOIN 
    Fall24_S003_T8_Schedule_Locations SL ON L.Location_ID = SL.Location_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule S ON SL.Schedule_ID = S.Schedule_ID
JOIN 
    Fall24_S003_T8_Service_Provider SP ON S.Service_Provider_ID = SP.Service_Provider_ID
GROUP BY 
    L.Location_Name;

--- Query: Top-Rated Experiences per Service Provider - VW_Fall24_S003_T8_SERVICE_PROVIDER_TOP_RATED_EXPERIENCES
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    E.Experience_ID,
    E.Title AS Experience_Title,
    AVG(R.Rating_Value) AS Average_Rating
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings R ON E.Experience_ID = R.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name, E.Experience_ID, E.Title
HAVING 
    AVG(R.Rating_Value) >= 8;  -- Filter to show only highly rated experiences

--- Query: Service Provider Bookings Overview - VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKINGS_OVERVIEW
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    COUNT(B.Booking_ID) AS Total_Bookings
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings B ON E.Experience_ID = B.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name;

--- Query: Service Provider Ratings and Feedback Overview - VW_Fall24_S003_T8_SERVICE_PROVIDER_RATINGS_FEEDBACK_OVERVIEW
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    AVG(R.Rating_Value) AS Average_Rating,
    COUNT(R.Rating_ID) AS Number_Of_Ratings
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Experience E ON SP.Service_Provider_ID = E.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings R ON E.Experience_ID = R.Experience_ID
GROUP BY 
    SP.Service_Provider_ID, SP.Name;

--- Query: Service Provider Availability Summary by Date and Location - VW_Fall24_S003_T8_SERVICE_PROVIDER_AVAILABILITY_SUMMARY
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    L.Location_Name,
    S.Available_Date,
    ST.Start_Time,
    ST.End_Time
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Availability_Schedule S ON SP.Service_Provider_ID = S.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations SL ON S.Schedule_ID = SL.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID
JOIN 
    Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID;

--- Query: Service Provider Details with Offered Activities - VW_Fall24_S003_T8_SERVICE_PROVIDER_DETAILS_WITH_ACTIVITIES
SELECT 
    SP.Service_Provider_ID,
    SP.Name AS Service_Provider_Name,
    SP.Email,
    SP.Phone,
    IC.Category_Name AS Activity
FROM 
    Fall24_S003_T8_Service_Provider SP
JOIN 
    Fall24_S003_T8_Service_Provider_Activities SPA ON SP.Service_Provider_ID = SPA.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories IC ON SPA.Activity_ID = IC.Category_ID;

--- SERVICE PROVIDER ENDS ---



--- EXPEREINCE ---

-- Query: Detailed Experience Information with Provider, Tags, and Schedule - VW_Fall24_S003_T8_EXPERIENCE_DETAILS_PROVIDER_TAGS_SCHEDULE
SELECT 
    E.Title AS Experience_Name,
    SP.Name AS Service_Provider_Name,
    T.Tag_Name AS Tag,
    S.Available_Date AS Schedule_Date,
    ST.Start_Time AS Schedule_Start_Time,
    ST.End_Time AS Schedule_End_Time
FROM 
    Fall24_S003_T8_Experience E
JOIN 
    Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
JOIN 
    Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
JOIN 
    Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
ORDER BY 
    E.Title, T.Tag_Name;

-- Query: Complete Experience Details with Tags and Schedule - VW_Fall24_S003_T8_EXPERIENCE_COMPLETE_DETAILS_TAGS_SCHEDULE
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
    Fall24_S003_T8_Experience E
LEFT JOIN 
    Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
LEFT JOIN 
    Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
LEFT JOIN 
    Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
LEFT JOIN 
    Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
ORDER BY 
    E.Experience_ID, T.Tag_Name;

--- Query: Experience Summary with Provider and Location - VW_Fall24_S003_T8_EXPERIENCE_SUMMARY_PROVIDER_LOCATION
SELECT 
    E.Experience_ID,
    E.Title,
    E.Description,
    E.Pricing,
    SP.Name AS Service_Provider,
    L.Location_Name AS Location
FROM 
    Fall24_S003_T8_Experience E
JOIN 
    Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations SL ON E.Schedule_ID = SL.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations L ON SL.Location_ID = L.Location_ID;


-- Query: Experience Details with Concatenated Tags - VW_Fall24_S003_T8_EXPERIENCE_DETAILS_CONCATENATED_TAGS
SELECT 
    E.Title AS Experience_Name,
    SP.Name AS Service_Provider_Name,
    LISTAGG(T.Tag_Name, ', ') WITHIN GROUP (ORDER BY T.Tag_Name) AS Tags,
    S.Available_Date AS Schedule_Date,
    ST.Start_Time AS Schedule_Start_Time,
    ST.End_Time AS Schedule_End_Time
FROM 
    Fall24_S003_T8_Experience E
JOIN 
    Fall24_S003_T8_Service_Provider SP ON E.Service_Provider_ID = SP.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Experience_Tags ET ON E.Experience_ID = ET.Experience_ID
JOIN 
    Fall24_S003_T8_Tags T ON ET.Tag_ID = T.Tag_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule S ON E.Schedule_ID = S.Schedule_ID
JOIN 
    Fall24_S003_T8_Schedule_Times ST ON S.Schedule_ID = ST.Schedule_ID
GROUP BY 
    E.Title, SP.Name, S.Available_Date, ST.Start_Time, ST.End_Time
ORDER BY 
    E.Title;

--- Query: Experiences Count by Pricing Range - VW_Fall24_S003_T8_EXPERIENCE_COUNT_BY_PRICING_RANGE
SELECT 
    CASE 
        WHEN Pricing < 50 THEN 'Low'
        WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END AS Price_Range,
    COUNT(e.Experience_ID) AS Number_Of_Experiences
FROM 
    Fall24_S003_T8_Experience e
GROUP BY 
    CASE 
        WHEN Pricing < 50 THEN 'Low'
        WHEN Pricing BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END;

--- EXPERIENCE QUERY ENDS ---



--- BOOKINGS ---

-- Query: Detailed Booking Information with Traveler, Experience, and Status - VW_Fall24_S003_T8_BOOKING_DETAILS_TRAVELER_EXPERIENCE_STATUS
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
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Travelers t ON b.Traveler_ID = t.T_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
JOIN 
    Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
JOIN 
    Fall24_S003_T8_Booking_Methods bm ON b.Booking_Method_ID = bm.Method_ID
ORDER BY 
    b.Date_Of_Booking DESC;


--- Query: Booking and Payment Status for Travelers - VW_Fall24_S003_T8_BOOKING_PAYMENT_STATUS_TRAVELERS
SELECT 
    B.Booking_ID,
    T.First_Name || ' ' || T.Last_Name AS Traveler_Name,
    E.Title AS Experience_Title,
    B.Experience_Date,
    B.Amount_Paid,
    PS.Payment_Status_Name AS Payment_Status
FROM 
    Fall24_S003_T8_Bookings B
JOIN 
    Fall24_S003_T8_Travelers T ON B.Traveler_ID = T.T_ID
JOIN 
    Fall24_S003_T8_Experience E ON B.Experience_ID = E.Experience_ID
JOIN 
    Fall24_S003_T8_Payment_Status PS ON B.Payment_Status_ID = PS.Payment_Status_ID;

-- Query: Travelers with At Least One Booking - VW_Fall24_S003_T8_TRAVELERS_WITH_AT_LEAST_ONE_BOOKING
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(b.Booking_ID) >= 1
ORDER BY 
    NumberOfBookings DESC;

-- Query: Travelers with Multiple Bookings - VW_Fall24_S003_T8_TRAVELERS_WITH_MULTIPLE_BOOKINGS
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(b.Booking_ID) > 1
ORDER BY 
    NumberOfBookings DESC;

-- Query: Travelers with No Bookings - VW_Fall24_S003_T8_TRAVELERS_WITH_NO_BOOKINGS
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email
FROM 
    Fall24_S003_T8_Travelers t
LEFT JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
WHERE 
    b.Booking_ID IS NULL
ORDER BY 
    t.T_ID;

-- Query: Experiences Booked by Each Traveler - VW_Fall24_S003_T8_EXPERIENCES_BOOKED_BY_TRAVELER
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    e.Description AS ExperienceDescription,
    sp.Name AS ServiceProvider,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
GROUP BY 
    e.Experience_ID, e.Title, e.Description, sp.Name
ORDER BY 
    NumberOfBookings DESC;

-- Query: Number of Experiences Booked for Each Service Provider - VW_Fall24_S003_T8_SERVICE_PROVIDER_BOOKED_EXPERIENCES_COUNT
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    NumberOfBookings DESC;

-- Query: Service Providers with Canceled Bookings - VW_Fall24_S003_T8_SERVICE_PROVIDERS_WITH_CANCELED_BOOKINGS
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    COUNT(b.Booking_ID) AS NumberOfCanceledBookings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Cancelled'
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    NumberOfCanceledBookings DESC;

-- Query: Travelers with Canceled Bookings - VW_Fall24_S003_T8_TRAVELERS_WITH_CANCELED_BOOKINGS
SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    t.Email AS TravelerEmail,
    COUNT(b.Booking_ID) AS NumberOfCancelledBookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Cancelled'
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
ORDER BY 
    NumberOfCancelledBookings DESC;

-- Query: All Travelers Who Have Booked an Experience - VW_Fall24_S003_T8_TRAVELERS_BOOKED_EXPERIENCE
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
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
ORDER BY 
    t.T_ID, b.Booking_ID;

--- BOOKINGS QUERY ENDS ---



--- RATINGS ---

-- Query: Travelers Who Have Submitted Reviews - VW_Fall24_S003_T8_TRAVELERS_WITH_REVIEWS
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email, 
    COUNT(r.Rating_ID) AS NumberOfReviews
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Ratings r ON t.T_ID = r.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
HAVING 
    COUNT(r.Rating_ID) >= 1
ORDER BY 
    NumberOfReviews DESC;

-- Query: Travelers with No Reviews Submitted - VW_Fall24_S003_T8_TRAVELERS_WITH_NO_REVIEWS
SELECT 
    t.T_ID, 
    t.First_Name, 
    t.Last_Name, 
    t.Email
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
LEFT JOIN 
    Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
WHERE 
    r.Rating_ID IS NULL
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name, t.Email
ORDER BY 
    t.T_ID;



-- Query: Detailed Review Information for Each Traveler - VW_Fall24_S003_T8_TRAVELER_REVIEW_DETAILS
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
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings r ON b.Traveler_ID = r.Traveler_ID AND b.Experience_ID = r.Experience_ID
ORDER BY 
    t.T_ID, b.Booking_ID;

-- Query: Average Rating for Each Service Provider - VW_Fall24_S003_T8_SERVICE_PROVIDER_AVERAGE_RATING
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    AverageRating DESC;

-- Query: Average Rating for Each Experience - VW_Fall24_S003_T8_EXPERIENCE_AVERAGE_RATING
SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    e.Description AS ExperienceDescription,
    sp.Name AS ServiceProvider,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title, e.Description, sp.Name
ORDER BY 
    AverageRating DESC;

--- Query: Top-Rated Experiences List - VW_Fall24_S003_T8_TOP_RATED_EXPERIENCES_LIST
SELECT 
    e.Experience_ID,
    e.Title,
    AVG(r.Rating_Value) AS Average_Rating,
    COUNT(r.Rating_ID) AS Number_Of_Ratings
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title
HAVING 
    AVG(r.Rating_Value) >= 8
ORDER BY 
    Average_Rating DESC;

--- RATINGS QUERY ENDS ---


--- ANALYSIS OF BOOKINGS ---

-- Query: Total Earnings for Confirmed Bookings by Service Provider - VW_Fall24_S003_T8_TOTAL_EARNINGS_CONFIRMED
SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    SUM(b.Amount_Paid) AS TotalEarnings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Fall24_S003_T8_Booking_Status bs ON b.Booking_Status_ID = bs.Status_ID
WHERE 
    bs.Status_Name = 'Confirmed' 
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    TotalEarnings DESC;


-- Query: Total Refunded Amount by Service Provider - VW_Fall24_S003_T8_TOTAL_REFUNDED_AMOUNT

SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    sp.Email AS ServiceProviderEmail,
    sp.Phone AS ServiceProviderPhone,
    sp.City AS ServiceProviderCity,
    SUM(b.Amount_Paid) AS TotalRefundedEarnings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
JOIN 
    Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
WHERE 
    ps.Payment_Status_Name = 'Refunded'
GROUP BY 
    sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
ORDER BY 
    TotalRefundedEarnings DESC;

-- Query: Service Provider with the Most Bookings - VW_Fall24_S003_T8_SERVICE_PROVIDER_MOST_BOOKINGS

SELECT 
    sp.Service_Provider_ID,
    sp.Name AS ServiceProviderName,
    COUNT(b.Booking_ID) AS TotalBookings
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
ORDER BY 
    TotalBookings DESC;


-- Query: Monthly Booking Volume - VW_Fall24_S003_T8_MONTHLY_BOOKING_VOLUME

SELECT 
    TO_CHAR(Date_Of_Booking, 'YYYY-MM') AS BookingMonth,
    COUNT(Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Bookings
GROUP BY 
    TO_CHAR(Date_Of_Booking, 'YYYY-MM')
ORDER BY 
    BookingMonth;


-- Query: Top Locations by Available Experiences - VW_Fall24_S003_T8_TOP_LOCATIONS_AVAILABLE_EXPERIENCES

SELECT 
    l.Location_ID,
    l.Location_Name,
    COUNT(e.Experience_ID) AS NumberOfAvailableExperiences
FROM 
    Fall24_S003_T8_Locations l
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
JOIN 
    Fall24_S003_T8_Experience e ON s.Schedule_ID = e.Schedule_ID
GROUP BY 
    l.Location_ID, l.Location_Name
ORDER BY 
    NumberOfAvailableExperiences DESC;

-- Query: Average Rating by Location - VW_Fall24_S003_T8_AVERAGE_RATING_BY_LOCATION

SELECT 
    l.Location_Name,
    AVG(r.Rating_Value) AS AverageRating
FROM 
    Fall24_S003_T8_Ratings r
JOIN 
    Fall24_S003_T8_Experience e ON r.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations l ON sl.Location_ID = l.Location_ID
GROUP BY 
    l.Location_Name
ORDER BY 
    AverageRating DESC;

-- Query: Group Booking Analysis by Type - VW_Fall24_S003_T8_GROUP_BOOKING_ANALYSIS

SELECT 
    gt.Group_Type_Name,
    COUNT(gm.Group_ID) AS NumberOfGroupBookings
FROM 
    Fall24_S003_T8_Group_Types gt
JOIN 
    Fall24_S003_T8_Groups g ON gt.Group_Type_ID = g.Group_Type_ID
JOIN 
    Fall24_S003_T8_Group_Members gm ON g.Group_ID = gm.Group_ID
GROUP BY 
    gt.Group_Type_Name
ORDER BY 
    NumberOfGroupBookings DESC;

-- Query: Traveler Demographic Booking Analysis - VW_Fall24_S003_T8_TRAVELER_DEMOGRAPHIC_ANALYSIS

SELECT 
    t.Demographic_Type,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.Demographic_Type
ORDER BY 
    NumberOfBookings DESC;

-- Query: Overall Refund Rate Analysis - VW_Fall24_S003_T8_REFUND_RATE_ANALYSIS

SELECT 
    (COUNT(CASE WHEN b.Payment_Status_ID = 
        (SELECT Payment_Status_ID FROM Fall24_S003_T8_Payment_Status WHERE Payment_Status_Name = 'Refunded') 
    THEN 1 END) / COUNT(*)) * 100 AS RefundRate
FROM 
    Fall24_S003_T8_Bookings b;

-- Query: Locations with the Most Bookings - VW_Fall24_S003_T8_LOCATIONS_MOST_BOOKINGS

SELECT 
    l.Location_ID,
    l.Location_Name,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Locations l
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON l.Location_ID = sl.Location_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule s ON sl.Schedule_ID = s.Schedule_ID
JOIN 
    Fall24_S003_T8_Experience e ON s.Schedule_ID = e.Schedule_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    l.Location_ID, l.Location_Name
ORDER BY 
    NumberOfBookings DESC;


-- Query: Service Provider with Highest and Lowest Ratings - VW_Fall24_S003_T8_HIGHEST_LOWEST_RATED_SERVICE_PROVIDERS

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
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
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
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        AverageRating ASC
) WHERE ROWNUM = 1;


-- Query: Top 10 Highest and Lowest Rated Service Providers - VW_Fall24_S003_T8_TOP_10_RATED_SERVICE_PROVIDERS

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
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
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
        Fall24_S003_T8_Service_Provider sp
    JOIN 
        Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
    JOIN 
        Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
    GROUP BY 
        sp.Service_Provider_ID, sp.Name, sp.Email, sp.Phone, sp.City
    ORDER BY 
        AverageRating ASC
) WHERE ROWNUM <= 10;


-- Query: Most Booked Experiences - VW_Fall24_S003_T8_MOST_BOOKED_EXPERIENCES

SELECT 
    e.Experience_ID,
    e.Title AS ExperienceTitle,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    e.Experience_ID, e.Title
ORDER BY 
    NumberOfBookings DESC
FETCH FIRST 5 ROWS ONLY;

-- Query: Top 10 Travelers by Booking Volume - VW_Fall24_S003_T8_TOP_10_TRAVELERS_BOOKINGS

SELECT 
    t.T_ID AS TravelerID,
    t.First_Name || ' ' || t.Last_Name AS TravelerName,
    COUNT(b.Booking_ID) AS NumberOfBookings
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
GROUP BY 
    t.T_ID, t.First_Name, t.Last_Name
ORDER BY 
    NumberOfBookings DESC
FETCH FIRST 10 ROWS ONLY;

-- Query: Average Amount Paid by Payment Status - VW_Fall24_S003_T8_AVERAGE_AMOUNT_PAID_BY_PAYMENT_STATUS

SELECT 
    ps.Payment_Status_Name,
    AVG(b.Amount_Paid) AS AverageAmountPaid
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Payment_Status ps ON b.Payment_Status_ID = ps.Payment_Status_ID
GROUP BY 
    ps.Payment_Status_Name
ORDER BY 
    AverageAmountPaid DESC;

-- Query: Total Revenue by Service Provider - VW_Fall24_S003_T8_TOTAL_REVENUE_BY_SERVICE_PROVIDER

SELECT 
    sp.Service_Provider_ID,
    sp.Name AS Service_Provider_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    SUM(b.Amount_Paid) AS Total_Revenue
FROM 
    Fall24_S003_T8_Service_Provider sp
JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name;

-- Query: Daily Booking Volume - VW_Fall24_S003_T8_DAILY_BOOKING_VOLUME

SELECT 
    TRUNC(b.Date_Of_Booking) AS Booking_Date,
    COUNT(b.Booking_ID) AS Number_Of_Bookings
FROM 
    Fall24_S003_T8_Bookings b
GROUP BY 
    TRUNC(b.Date_Of_Booking)
ORDER BY 
    Booking_Date;

--- ANALYSIS QUERY ENDS ---

--Goals 

-- Query: Guide Engagement and Support Needs - VW_Fall24_S003_T8_GUIDE_SUPPORT_NEEDS

SELECT 
    sp.Service_Provider_ID,
    sp.Name AS Service_Provider_Name,
    COUNT(b.Booking_ID) AS Booking_Count,
    AVG(r.Rating_Value) AS Average_Rating
FROM 
    Fall24_S003_T8_Service_Provider sp
LEFT JOIN 
    Fall24_S003_T8_Experience e ON sp.Service_Provider_ID = e.Service_Provider_ID
LEFT JOIN 
    Fall24_S003_T8_Bookings b ON e.Experience_ID = b.Experience_ID
LEFT JOIN 
    Fall24_S003_T8_Ratings r ON e.Experience_ID = r.Experience_ID
GROUP BY 
    sp.Service_Provider_ID, sp.Name
HAVING 
    COUNT(b.Booking_ID) < 10 OR AVG(r.Rating_Value) < 3.0;


--- Query: Quarterly Revenue Breakdown by Experience Category, Destination, and Service Provider - VW_Fall24_S003_T8_QUARTERLY_REVENUE_BREAKDOWN
SELECT 
    EXTRACT(YEAR FROM b.Date_Of_Booking) AS Year,
    TO_CHAR(b.Date_Of_Booking, 'Q') AS Quarter,
    ic.Category_Name AS Experience_Category,
    loc.Location_Name AS Destination,
    sp.Name AS Service_Provider,
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
    Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
GROUP BY 
    EXTRACT(YEAR FROM b.Date_Of_Booking),
    TO_CHAR(b.Date_Of_Booking, 'Q'),
    ic.Category_Name,
    loc.Location_Name,
    sp.Name;

-- Query: Monthly Booking Trends by Experience Category and Traveler Demographics - VW_Fall24_S003_T8_MONTHLY_BOOKING_TRENDS

SELECT 
    EXTRACT(MONTH FROM b.Date_Of_Booking) AS Month,
    ic.Category_Name AS Experience_Category,
    COUNT(b.Booking_ID) AS Booking_Count,
    t.Demographic_Type AS Traveler_Demographic
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
JOIN 
    Fall24_S003_T8_Travelers t ON b.Traveler_ID = t.T_ID
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
GROUP BY 
    EXTRACT(MONTH FROM b.Date_Of_Booking),
    ic.Category_Name,
    t.Demographic_Type;

-- Query: Repeat Travelers with Preferences - VW_Fall24_S003_T8_REPEAT_TRAVELERS_PREFERENCES

SELECT 
    t.T_ID AS Traveler_ID,
    t.First_Name || ' ' || t.Last_Name AS Traveler_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,
    LISTAGG(ic.Category_Name, ', ') WITHIN GROUP (ORDER BY ic.Category_Name) AS Preferences
FROM 
    Fall24_S003_T8_Travelers t
JOIN 
    Fall24_S003_T8_Bookings b ON t.T_ID = b.Traveler_ID
JOIN 
    Fall24_S003_T8_Traveler_Preferences tp ON t.T_ID = tp.T_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON tp.Preference_ID = ic.Category_ID
GROUP BY 
    t.T_ID,
    t.First_Name,
    t.Last_Name
HAVING 
    COUNT(b.Booking_ID) > 1;

-- Query: Experience Diversity by Category and Location - VW_Fall24_S003_T8_EXPERIENCE_DIVERSITY

SELECT 
    ic.Category_Name AS Experience_Category,
    loc.Location_Name AS Location,
    COUNT(e.Experience_ID) AS Experience_Count
FROM 
    Fall24_S003_T8_Experience e
JOIN 
    Fall24_S003_T8_Service_Provider sp ON e.Service_Provider_ID = sp.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Service_Provider_Activities spa ON sp.Service_Provider_ID = spa.Service_Provider_ID
JOIN 
    Fall24_S003_T8_Interest_Categories ic ON spa.Activity_ID = ic.Category_ID
JOIN 
    Fall24_S003_T8_Availability_Schedule s ON e.Schedule_ID = s.Schedule_ID
JOIN 
    Fall24_S003_T8_Schedule_Locations sl ON s.Schedule_ID = sl.Schedule_ID
JOIN 
    Fall24_S003_T8_Locations loc ON sl.Location_ID = loc.Location_ID
GROUP BY 
    ic.Category_Name,
    loc.Location_Name;

-- Query: Monthly Booking Count by Experience - VW_Fall24_S003_T8_MONTHLY_BOOKING_COUNT_BY_EXPERIENCE

SELECT 
    EXTRACT(MONTH FROM b.Experience_Date) AS Month,
    COUNT(b.Booking_ID) AS Booking_Count,
    e.Title AS Experience_Title
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
GROUP BY 
    EXTRACT(MONTH FROM b.Experience_Date),
    e.Title
ORDER BY 
    Booking_Count DESC;

-- Query: Average Days Between Booking and Experience Date by Title - VW_Fall24_S003_T8_AVG_DAYS_BETWEEN_BOOKING_EXPERIENCE

SELECT 
    AVG(TRUNC(b.Experience_Date) - TRUNC(b.Date_Of_Booking)) AS Avg_Days_Between_Booking,
    e.Title AS Experience_Title
FROM 
    Fall24_S003_T8_Bookings b
JOIN 
    Fall24_S003_T8_Experience e ON b.Experience_ID = e.Experience_ID
GROUP BY 
    e.Title;
