/* Database creation and initial setup*/

CREATE DATABASE law_enforcement;
GO

USE law_enforcement;
GO

CREATE SCHEMA law;
GO

/*create master key for encrypting passwords column*/
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'strong_password';
GO
