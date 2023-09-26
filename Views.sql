/* View to see username association with Agency */
CREATE VIEW law.UserInAgencyView AS
SELECT
    law.Users.username,
    law.Agencies.County,
	law.Agencies.Town
FROM law.Users 
	JOIN law.UserInAgency ON law.Users.userID = law.UserInAgency.UserID
	JOIN law.Agencies ON law.UserInAgency.AgencyID = law.Agencies.AgencyID