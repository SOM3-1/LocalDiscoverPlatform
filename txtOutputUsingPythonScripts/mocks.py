# preferences.py

preference_options = [
    'Beach', 'Mountain', 'City Tour', 'Adventure', 'Cruise', 'Hiking', 'Cultural Experience', 'Food andDrink',
    'Wildlife Safari', 'Historical Sites', 'Nightlife', 'Shopping', 'Spa andWellness', 'Sports Events', 'Road Trip',
    'Camping', 'Photography', 'Music Festival', 'Art andCraft', 'Yoga Retreat', 'Sailing', 'Desert Safari',
    'Skiing', 'Scuba Diving', 'Golfing'
]

city_names = [
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", 
    "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco", 
    "Indianapolis", "Seattle", "Denver", "Washington", "Boston", "El Paso", "Nashville", "Detroit", "Oklahoma City", 
    "Portland", "Las Vegas", "Memphis", "Louisville", "Baltimore", "Milwaukee", "Albuquerque", "Tucson", 
    "Fresno", "Sacramento", "Kansas City", "Mesa", "Atlanta", "Omaha", "Colorado Springs", "Raleigh", 
    "Miami", "Virginia Beach", "Oakland", "Minneapolis", "Tulsa", "Arlington", "Tampa", "New Orleans", 
    "Wichita", "Cleveland", "Bakersfield", "Anaheim", "Honolulu", "Santa Ana", "Riverside", 
    "Corpus Christi", "Lexington", "Henderson", "Stockton", "Saint Paul", "Cincinnati", "St. Louis", "Pittsburgh", 
    "Greensboro", "Anchorage", "Plano", "Lincoln", "Orlando", "Irvine", "Newark", "Durham", "Chula Vista", 
    "Toledo", "Fort Wayne", "St. Petersburg", "Laredo", "Jersey City", "Chandler", "Madison", "Lubbock", 
    "Scottsdale", "Reno", "Buffalo", "Gilbert", "Glendale", "North Las Vegas", "Winston-Salem", "Chesapeake", 
    "Norfolk", "Fremont", "Garland", "Irving", "Hialeah", "Richmond", "Boise", "Spokane", "Baton Rouge", 
    "Tacoma", "San Bernardino", "Modesto", "Fontana", "Des Moines", "Moreno Valley", "Santa Clarita", "Fayetteville", 
]

city_names_old = [
    "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", 
    "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco", 
    "Indianapolis", "Seattle", "Denver", "Washington", "Boston", "El Paso", "Nashville", "Detroit", "Oklahoma City", 
    "Portland", "Las Vegas", "Memphis", "Louisville", "Baltimore", "Milwaukee", "Albuquerque", "Tucson", 
    "Fresno", "Sacramento", "Kansas City", "Mesa", "Atlanta", "Omaha", "Colorado Springs", "Raleigh", 
    "Miami", "Virginia Beach", "Oakland", "Minneapolis", "Tulsa", "Arlington", "Tampa", "New Orleans", 
    "Wichita", "Cleveland", "Bakersfield", "Anaheim", "Honolulu", "Santa Ana", "Riverside", 
    "Corpus Christi", "Lexington", "Henderson", "Stockton", "Saint Paul", "Cincinnati", "St. Louis", "Pittsburgh", 
    "Greensboro", "Anchorage", "Plano", "Lincoln", "Orlando", "Irvine", "Newark", "Durham", "Chula Vista", 
    "Toledo", "Fort Wayne", "St. Petersburg", "Laredo", "Jersey City", "Chandler", "Madison", "Lubbock", 
    "Scottsdale", "Reno", "Buffalo", "Gilbert", "Glendale", "North Las Vegas", "Winston-Salem", "Chesapeake", 
    "Norfolk", "Fremont", "Garland", "Irving", "Hialeah", "Richmond", "Boise", "Spokane", "Baton Rouge", 
    "Tacoma", "San Bernardino", "Modesto", "Fontana", "Des Moines", "Moreno Valley", "Santa Clarita", "Fayetteville", 
    "Birmingham", "Oxnard", "Rochester", "Port St. Lucie", "Grand Rapids", "Huntsville", "Salt Lake City", 
    "Frisco", "Yonkers", "Amarillo", "Huntington Beach", "McKinney", "Montgomery", "Augusta", 
    "Aurora", "Akron", "Little Rock", "Tempe", "Overland Park", "Grand Prairie", "Tallahassee", "Cape Coral", 
    "Mobile", "Knoxville", "Shreveport", "Worcester", "Ontario", "Vancouver", "Sioux Falls", "Chattanooga", 
    "Brownsville", "Fort Lauderdale", "Providence", "Newport News", "Rancho Cucamonga", "Santa Rosa", 
    "Peoria", "Oceanside", "Elk Grove", "Salem", "Pembroke Pines", "Eugene", "Garden Grove", "Cary", 
    "Fort Collins", "Corona", "Springfield", "Jackson", "Alexandria", "Hayward", "Clarksville", "Lakewood", 
    "Lancaster", "Salinas", "Palmdale", "Hollywood", "Macon", "Sunnyvale", 
    "Pomona", "Killeen", "Escondido", "Pasadena", "Naperville", "Bellevue", "Joliet",
    "Midland", "Rockford", "Paterson", "Savannah", "Bridgeport", "Torrance", "McAllen", "Syracuse", 
    "Surprise", "Denton", "Roseville", "Thornton", "Miramar", "Mesquite", "Olathe", "Dayton", 
    "Carrollton", "Waco", "Orange", "Fullerton", "Charleston", "West Valley City", "Visalia", "Hampton", 
    "Gainesville", "Warren", "Coral Springs", "Cedar Rapids", "Round Rock", "Sterling Heights", "Kent", 
    "Columbia", "Santa Clara", "New Haven", "Stamford", "Concord", "Elizabeth", "Athens", "Thousand Oaks", 
    "Lafayette", "Simi Valley", "Topeka", "Norman", "Fargo", "Wilmington", "Abilene", "Odessa", 
    "Pearland", "Victorville", "Hartford", "Vallejo", "Allentown", "Berkeley", "Richardson", "Arvada", 
    "Ann Arbor", "Cambridge", "Sugar Land", "Lansing", "Evansville", "College Station", 
    "Fairfield", "Clearwater", "Beaumont", "Independence", "Provo", "West Jordan", "Murfreesboro", 
    "Palm Bay", "El Monte", "Carlsbad", "North Charleston", "Temecula", "Clovis",
    "Meridian", "Westminster", "Costa Mesa", "High Point", "Manchester", "Pueblo", "Lakeland", 
    "Pompano Beach", "West Palm Beach", "Antioch", "Everett", "Downey", "Lowell", "Centennial", 
    "Elgin", "Broken Arrow", "Miami Gardens", "Billings", "Jurupa Valley", 
    "Sandy Springs", "Gresham", "Lewisville", "Hillsboro", "Ventura", "Greeley", "Inglewood", 
    "Waterbury", "League City", "Santa Maria", "Tyler", "Davie", "Daly City", "Boulder", 
    "Allen", "West Covina", "Sparks", "Wichita Falls", "Green Bay", "San Mateo", "Norwalk", 
    "Rialto", "Las Cruces", "Chico", "El Cajon", "Burbank", "South Bend", "Renton", "Vista", 
    "Davenport", "Edinburg", "Tuscaloosa", "Carmel", "Spokane Valley", "San Angelo", "Vacaville", 
    "Clinton"
]

group_types = [
    'Family',
    'Friends',
    'Corporate Team',
    'Adventure',
    'Social',
    'Fitness',
    'Hiking',
    'Cultural',
    'Wellness',
    'Photography',
    'Cooking',
    'Music',
    'Art',
    'Travel',
    'Gaming',
    'Volunteering',
    'Outdoor',
    'Networking'
]

experience_categories = [
    "Hiking Adventure",
    "Wine Tasting Tour",
    "City Sightseeing",
    "Cultural Heritage Tour",
    "Cooking Class",
    "Art Workshop",
    "Yoga Retreat",
    "Snorkeling Trip",
    "Mountain Biking",
    "Beach Relaxation",
    "Wildlife Safari",
    "Historical Landmark Visit",
    "Photography Expedition",
    "Kayaking Excursion",
    "Meditation Retreat",
    "Gastronomy Experience",
    "Rock Climbing",
    "Music Festival",
    "Dance Workshop",
    "Stargazing Experience"
]

experience_tags = [
    'Relaxation', 'Adventure', 'Family', 'Outdoor', 'Culture', 'Luxury', 'Food', 'Fitness',
    'Art', 'Music', 'History', 'Nature', 'Wellness', 'Nightlife', 'Shopping', 'Sports',
    'Photography', 'Festival', 'Social', 'Exploration', 'Learning', 'Health', 'Leisure',
    'Thrill', 'Travel', 'Beach', 'Mountain', 'City', 'Yoga', 'Meditation', 'Wildlife',
    'Camping', 'Road Trip', 'Water Sports', 'Cruise'
]

booking_methods = [
    'Online', 'Phone', 'In-Person', 'Travel Agent', 'Mobile App'
]

booking_statuses = [
    'Confirmed', 'Cancelled', 'Pending',
]

payment_statuses = [
    'Pending', 'Completed', 'Failed', 'Refunded'
]