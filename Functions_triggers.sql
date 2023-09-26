/* User Defined Function GenerateUniqueUsername 
	 function takes 4 parameters: first name, middle name, last name , random float
	 function begins by generating a fallback form of a new username in @username variable with a random 3 digit number
	 then it checks the first form for a match in the users table, if match is found -> check if second form match -> check if third form 
	 UPDATE: 
		 in each round of checking, If the username was not found in the Users Table, we need to check if it is in the deletedUsers table
			--if it is NOT FOUND in the deletedUsers table than ACCEPT the new username 
			--if it is FOUND in the deletedUsers:
								-- If the DeletionDate was over a year ago -> ACCEPT the username and remove it from the deletedUsers table 
								-- If if the Deletion date is less than a year ago -> continue searching for other forms of username
	 if all three forms of the username already exist ( not probable! ) then the function will return the fallback form of the username
*/

CREATE FUNCTION law.GenerateUniqueUsername (@first_name VARCHAR(50), @middle_name VARCHAR(50), @last_name VARCHAR(50), @randomNum FLOAT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @username VARCHAR(50);
	DECLARE @temp_username VARCHAR(50);
    DECLARE @exists_in_users INT;
	DECLARE @deleted_less_than_a_year_ago INT;
	
	/* create a FALLBACK username by combining 1st letter of fname + 6 letters of lname and a 3 digit random number (this might include 'x') */
	SET @username = LEFT(@first_name, 1) + LEFT(@last_name, 6) + LEFT(REPLACE ( CAST( @randomNum * 1000 AS VARCHAR(20)),'.','x'),3);

	/* create the FIRST form of the username by combining 1st letter of fname + 6 letters of lname */
    SET @temp_username = LEFT(@first_name, 1) + LEFT(@last_name, 6);
    
    /* check if the FIRST form of the username already exists in the table */
    SELECT @exists_in_users = COUNT(*) FROM law.Users WHERE username = @temp_username;
	SELECT @deleted_less_than_a_year_ago = COUNT(*) FROM law.DeletedUsernames WHERE deleted_username = @temp_username AND DATEDIFF (month, deletion_date, GETDATE()) <= 12;
    
	IF @exists_in_users = 0 AND @deleted_less_than_a_year_ago = 0  SET @username = @temp_userName;		-- if no match was found assign the the first form to the username 

	ELSE	--if a match was found in the table go into else statement otherwise skip else statement
    BEGIN
        
		/* create the second form of the username by combining 6 letters of lname + 1st letter of fname */
		SET @temp_username = LEFT(@last_name, 6) + LEFT(@first_name, 1);
        
        /* check if the second form of the username already exists in the table */
        SELECT @exists_in_users = COUNT(*) FROM law.Users WHERE username = @temp_username;
        SELECT @deleted_less_than_a_year_ago = COUNT(*) FROM law.DeletedUsernames WHERE deleted_username = @temp_username AND DATEDIFF (month, deletion_date, GETDATE()) <= 12;
    
		IF @exists_in_users = 0 AND @deleted_less_than_a_year_ago = 0  SET @username = @temp_userName;		-- if no match was found assign the the first form to the username 

        ELSE	--if a match was found in the table go into else statement otherwise skip else statement
        BEGIN
			
			/* the third form uses the optional middle name so we need to check if it is defined first */
			/* the third form of the username combines 1st letter of fname + 1st letter of mname ( or 'x') + 6 letters of lname */
			IF @middle_name IS NULL
				SET @temp_username = LEFT(@first_name, 1) + 'x' + LEFT(@last_name, 6); --if middle name is NULL use 'x'
			ELSE 
				SET @temp_username = LEFT(@first_name, 1) + LEFT(@middle_name,1) + LEFT(@last_name, 6);
            
            /* check if the second form of the username already exists in the table */
            SELECT @exists_in_users = COUNT(*) FROM law.Users WHERE username = @temp_username;
            SELECT @deleted_less_than_a_year_ago = COUNT(*) FROM law.DeletedUsernames WHERE deleted_username = @temp_username AND DATEDIFF (month, deletion_date, GETDATE()) <= 12;
    
			IF @exists_in_users = 0 AND @deleted_less_than_a_year_ago = 0  SET @username = @temp_userName;		-- if no match was found assign the the first form to the username 

        END
    END
	RETURN @userName -- returns the unique username
END;

GO

/* Create a trigger for the INSERT Event on the users table */
	/* !!! what if a user changed their last name ? Should the username be updated when the users last name is updated ?  */
CREATE TRIGGER InsertUserWithUsername ON law.Users
INSTEAD OF INSERT
AS
BEGIN
	/* insert fname, mname, lname, username = return value from function, password */
    INSERT INTO users (fname, mname , lname, username, password)
    SELECT fname ,mname, lname, LOWER(law.GenerateUniqueUsername(fname, mname , lname, RAND())), password -- call udf with 4 arguments
    FROM inserted;		-- inserted is a temporary table created with last inserted value
END;
GO

/* Create a trigger for when a user is deleted, Dleted username is added to the deleted_usernames table */
CREATE TRIGGER AfterUserDelete ON law.Users
AFTER DELETE
AS
BEGIN
    DECLARE @deleted_username VARCHAR(50);
	DECLARE @deletion_date DATE;
	SET @deletion_date = GETDATE();
    
	SELECT @deleted_username = DELETED.username FROM DELETED;	--retrieve the deleted username from the deleted temp table
    INSERT INTO law.DeletedUsernames (deleted_username, deletion_date) VALUES (@deleted_username, @deletion_date);
END;
GO

/* Create a trigger on Status update on a user in Users table. Also record the Representatives info that did the Validationa*/
CREATE TRIGGER AccountValidation ON law.Users
AFTER UPDATE
AS
IF (UPDATE (status))
BEGIN
    DECLARE @validator VARCHAR(50);	-- user that did the validation
	DECLARE @validation_date DATE;	--date of validation
	DECLARE @validated_account INT;	--userID of the account validated
	
	SET @validator = SUSER_NAME();
	SET @validation_date = GETDATE();
	SELECT @validated_account = userID from updated
    
	INSERT INTO law.AccountValidations (validatorID, validated_userID, validation_date) VALUES (@validator, @validated_account, @validation_date);
END;
GO

