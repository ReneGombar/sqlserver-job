/* Individual INSERT, UPDATE, DELETE query examples */
-- delete a USER from a specific Agency based on username and Town matches (AgencyID is important )
	-- 1. Check if the user is only in one agency
	-- 2. Delete the UserID to AgencyID relationship from UserInAgency table based on exact UserID and AgencyId match
	-- 3. If the userID is not associated with any other Aency  -> delete the User from the Users table

DELETE law.UserInAgency FROM law.UserInAgency
	JOIN law.Users ON law.UserInAgency.UserID = law.Users.UserID
	JOIN law.Agencies ON law.UserInAgency.AgencyID = law.Agencies.AgencyID
	WHERE law.Users.username = 'rstrass' AND law.Agencies.Town = 'Barre'

DELETE Users FROM law.Users
	WHERE law.Users.username = 'jbell' OR law.Users.username = 'bellj'

/* Create a new relationsip between an existing user and a existing agency based on username and town*/
INSERT INTO law.UserInAgency (UserID, AgencyID) 
	SELECT law.Users.userID , law.Agencies.AgencyID FROM law.Users
	JOIN law.Agencies ON law.Agencies.town = 'Winooski'
	WHERE law.Users.username = 'rstrass'

/* list all towns where the users is asociated with , match by username */
SELECT law.Users.UserID, law.UserInAgency.AgencyID , law.Users.username, law.Agencies.Town FROM law.UserInAgency
	JOIN law.Users ON law.UserInAgency.UserID = law.Users.UserID
	JOIN law.Agencies ON law.UserInAgency.AgencyID = law.Agencies.AgencyID
	WHERE law.Users.username = 'rstrass'

-- list all users by county and town
SELECT law.agencies.County, law.agencies.town, law.UserInAgency.UserID, law.users.username FROM law.agencies 
LEFT JOIN law.UserInAgency ON law.agencies.AgencyID = law.UserInAgency.AgencyID
JOIN law.users ON law.UserInAgency.UserID = law.users.userID
ORDER BY  law.agencies.County;
GO 

/* Create a new user and automatically assign them to the agency that created them*/
INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('John','Arthur','Bell','12345');
INSERT INTO law.UserInAgency (UserID, AgencyID) 
	SELECT law.Users.userID , law.Agencies.AgencyID FROM law.Users
	JOIN law.Agencies ON law.Agencies.town = 'Winooski'
	WHERE law.Users.username = (
						SELECT law.Users.username FROM inserted
						)
GO