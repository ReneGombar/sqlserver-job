/*
Schema for Users Table
	! Unique username function will only work if INSERTING a single VALUE into the table
	! If INSERTING multiple values the inserted temporary table is not iterated through when udf is searching for matches
*/



--CREATE DATABASE law_enforcement;
--CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'strong_password';
--GO

--USE law_enforcement;
--GO

/*create master key for encrypting passwords column*/

CREATE TABLE users(
	id INT NOT NULL											-- id of the user 
	IDENTITY (1,1)											-- id is auto incremented
	PRIMARY KEY,											-- id is a primary key 	
	fname VARCHAR(100) NOT NULL,							-- first name is required
	mname VARCHAR(100) ,									-- middle name is not required -> it can be NULL
	lname VARCHAR(100) NOT NULL,							-- last name is required
	username VARCHAR(50) NOT NULL UNIQUE,					-- username is generated with a udf on a insert trigger
	status VARCHAR(20) DEFAULT ('established') NOT NULL,	-- this can be established, active, disabled
	password VARCHAR(100) NOT NULL ,						-- password is required, NOT ENCRYPTED YET
	created DATETIME DEFAULT GETDATE() NOT NULL,			-- created saves the creation time of the user
	validated DATETIME,										-- validation time is for keeping track of user account validation
);
GO


/* User Defined Function GenerateUniqueUsername */
	-- function takes 4 parameters: first name, middle name, last name , random float
	-- function begins by generating a fallback form of a new username in @username variable
	-- then it checks the first form for a match in the table, if match is found -> check if second form match -> check if third form 
	-- if all three forms of the username already exist ( not probable! ) then the function will return the fallback form of the username

CREATE FUNCTION dbo.GenerateUniqueUsername (@first_name VARCHAR(50), @middle_name VARCHAR(50), @last_name VARCHAR(50), @randomNum FLOAT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @username VARCHAR(50);
	DECLARE @temp_username VARCHAR(50);
    DECLARE @count INT;
	
	/* create a fallback username by combining 1st letter of fname + 6 letters of lname and a 3 digit random number */
	SET @username = LEFT(@first_name, 1) + LEFT(@last_name, 6) + LEFT(CAST( @randomNum * 1000 AS VARCHAR(20)),3);

	/* create the first form of the username by combining 1st letter of fname + 6 letters of lname */
    SET @temp_username = LEFT(@first_name, 1) + LEFT(@last_name, 6);
    
    /* check if the first form of the username already exists in the table */
    SELECT @count = COUNT(*) FROM users WHERE username = @temp_username;
	
    IF @count = 0 SET @username = @temp_userName;		-- if no match was found assign the the first form to the username 

	ELSE	--if a match was found in the table go into else statement otherwise skip else statement
    BEGIN
        
		/* create the second form of the username by combining 6 letters of lname + 1st letter of fname */
		SET @temp_username = LEFT(@last_name, 6) + LEFT(@first_name, 1);
        
        /* check if the second form of the username already exists in the table */
        SELECT @count = COUNT(*) FROM users WHERE username = @temp_username;
        
        IF @count = 0 SET @username = @temp_userName;	-- if no match was found assign the the second form to the username 

        ELSE	--if a match was found in the table go into else statement otherwise skip else statement
        BEGIN
			
			/* the third form uses the optional middle name so we need to check if it is defined first */
			/* the third form of the username combines 1st letter of fname + 1st letter of mname ( or 'x') + 6 letters of lname */
			IF @middle_name IS NULL
				SET @temp_username = LEFT(@first_name, 1) + 'x' + LEFT(@last_name, 6); --if middle name is NULL use 'x'
			ELSE 
				SET @temp_username = LEFT(@first_name, 1) + LEFT(@middle_name,1) + LEFT(@last_name, 6);
            
            /* check if the second form of the username already exists in the table */
            SELECT @count = COUNT(*) FROM users WHERE username = @temp_username;
            
            IF @count = 0 SET @username = @temp_username; -- if no match was found assign the the third form to the username 
        END
    END
	RETURN @userName -- returns the unique username
END;

GO

/* Create a trigger for the INSERT Event on the users table */
	/* !!! what if a user changed their last name ? Should the username be updated when the users last name is updated ?  */
CREATE TRIGGER InsertUserWithUsername
ON users
INSTEAD OF INSERT
AS
BEGIN
	/* insert fname, mname, lname, username = return value from function, password */
    INSERT INTO users (fname, mname , lname, username, password)
    SELECT fname ,mname, lname, LOWER(dbo.GenerateUniqueUsername(fname, mname , lname, RAND())), password -- call udf with 4 arguments
    FROM inserted;		-- inserted is a temporary table created with last inserted value
END;
GO

