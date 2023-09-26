INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345'),
			('Johny','Big','Cash','12345'),
			('Rick','Dee','Strassman','12345'),
			('Anton','Fred','Germain','12345'),
			('Andy','Cat','Bell','12345')
			;

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('Andy','Cat','Bell','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('Andy','Cat','Bell','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('Andy','Cat','Bell','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('Andy','Cat','Bell','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345');

INSERT INTO law.users(fName,mName,lName,password)
	VALUES ('James',NULL,'Harden','12345');
GO

INSERT INTO law.agencies (county,town,street,zip)
	VALUES	('Windsor','Windsor','12 Main ST','05433'),
			('Windsor','Buffallo','9 Buff Hill ST','05433'),
			('Windsor','Windall','10 Socks ST','05433'),
			('Washington','Montpelier','144 State  ST','05303-3333'),
			('Washington','Barre','17 Berlin Road','05453'),
			('Chittenden','Burlington','211 Park ST','05401'),
			('Chittenden','Winooski','22 Church ST','05404'),
			('Addison','Addison','66 Main St','05202'),
			('Addison','Monkton','77 Pass Hill Road','054322')

INSERT INTO law.UserInAgency (UserID, AgencyID)
	VALUES 	
			(1,7),
			(2,2),
			(3,4),
			(3,5),
			(4,4),
			(4,5),
			(5,9),
			(6,8),
			(7,8),
			(8,9),
			(9,1),
			(10,1),
			(11,3),
			(12,3),
			(13,2),
			(14,7)
			