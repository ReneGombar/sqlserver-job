/*Schema for users
	! Unique username function will only work if INSERTING a single VALUE into the table
	! If INSERTING multiple values the inserted temporary table is not iterated through when udf is searching for matches
*/
CREATE TABLE law.Users(
	userID INT NOT NULL										-- id of the user 
	IDENTITY (1,1)											-- id is auto incremented
	PRIMARY KEY,											-- id is a primary key 	
	fname VARCHAR(100) NOT NULL,							-- first name is required
	mname VARCHAR(100) ,									-- middle name is not required -> it can be NULL
	lname VARCHAR(100) NOT NULL,							-- last name is required
	username VARCHAR(50) NOT NULL UNIQUE,					-- username is generated with a udf on a insert trigger
	status VARCHAR(20) DEFAULT ('established') NOT NULL,	-- this can be established, active, disabled
	password VARCHAR(100) NOT NULL ,						-- password is required, NOT ENCRYPTED YET
	created DATE DEFAULT GETDATE() NOT NULL,				-- created saves the creation time of the user
	validated DATE,											-- validation date is for keeping track of user account validation
);
GO

/*Schema for Agencies Table*/
CREATE TABLE law.Agencies (
    AgencyID INT NOT NULL									-- id of the agency 
	IDENTITY (1,1)											-- id is auto incremented
	PRIMARY KEY,											-- id is a primary key 	
    County VARCHAR (100) NOT NULL,							-- ex: 'Addison'
    Town VARCHAR (100) NOT NULL,							-- ex: 'Monkton'
	Street VARCHAR (100) NOT NULL,							-- ex: '32 Main St'
	zip VARCHAR (20) NOT NULL,								-- ex: '05443' or '05443-9999'
	AD_identity VARCHAR (100) NOT NULL UNIQUE,				-- unique AD identifier
);
GO

/*Challenge questions lookup table*/
CREATE TABLE law.Questions (
	UserID INT,
	Question VARCHAR(255),
	Answer VARCHAR (255),
	FOREIGN KEY (UserID) REFERENCES law.User(userID)
);


/*Look up schema for user assosiation with multiple agencies Many-to-Many */
CREATE TABLE law.UserInAgency (
    UserID INT NOT NULL,											
    AgencyID INT NOT NULL,
	IsRepresentative BIT,											-- bit value (0,1,NULL) to indicate that the user is a Representative of that Agency											
    FOREIGN KEY (UserID) REFERENCES law.Users(UserID),				--UserID references the users ID in the users table
    FOREIGN KEY (AgencyID) REFERENCES law.Agencies(AgencyID)		--AgnecyID references the agency ID in the agency table
);
GO

/*Look up table for Platform Identification by ID */
CREATE TABLE law.Platforms (
	PlatformID INT NOT NULL									-- id of the platform
	IDENTITY (1,1)											-- id is auto incremented
	PRIMARY KEY,
	pName VARCHAR (100),									-- name of the platform
	pDescription VARCHAR (255),								-- description of the platform 
);
GO

/*Schema For each Agencies platform access credentials*/
	-- every user assing to an Agency will have automatic access to that agency's assigned platform access credentials
CREATE TABLE law.AgencyPlatformAccess (
	apaID INT NOT NULL										-- id for the relationship between 
	IDENTITY (1,1)											-- id is auto incremented
	PRIMARY KEY,
	AgencyID INT,								-- ID of the agency that is connected with this platform cred info
	PlatformID INT,								-- ID of the platform general info in the Platforms table
	Creds VARCHAR (255)							-- SPECIFIC ACCESS CREDENTIAL for accessing this Agencies Platform
	FOREIGN KEY (AgencyID) REFERENCES law.Agencies(AgencyID),
	FOREIGN KEY (PlatformID) REFERENCES law.Platforms(PlatformID)
);
GO

/* Special User ACCESS table for users from other agencies requesting access to a different Agencies Platform*/
CREATE TABLE law.UserSpecialAccess (
	UserID INT,						-- user ID that has special Access to a different platform
	accessToPlatform INT,			-- Id of the Agency TO PLatform access credentials
	FOREIGN KEY (UserID) REFERENCES law.Users(UserID),
	FOREIGN KEY (accessToPlatform) REFERENCES law.AgencyPlatformAccess(apaID),
);
GO

/* Verification table contains the Representative ID which did the validation, Validated Account, Date of validation*/
CREATE TABLE law.AccountValidations (
	validatorID INT,											-- Represenetatives ID that did the validation
	validated_userID INT,										-- UserID whos account was validated
	validation_date DATE,										-- Date of the Account Validation
	FOREIGN KEY (validatorID) REFERENCES law.Users(UserID),
	FOREIGN KEY (validated_userID) REFERENCES law.Users(UserID)
);


/* Schema for deleted usernames with dates table*/
CREATE TABLE law.DeletedUsernames (
    deleted_username VARCHAR(50) NOT NULL,						-- username that was deleted
    deletion_date DATE NOT NULL,								-- date of the deletion
);
GO