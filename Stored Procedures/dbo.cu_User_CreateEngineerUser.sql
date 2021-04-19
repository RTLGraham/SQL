SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_CreateEngineerUser]
(
	@new_name NVARCHAR(100), 
	@new_pass VARCHAR(20), 
	@new_first VARCHAR(20), 
	@new_last VARCHAR(20)
)
AS		
	--DECLARE @new_name NVARCHAR(100), 
	--		@new_pass VARCHAR(20), 
	--		@new_first VARCHAR(20), 
	--		@new_last VARCHAR(20)

	--SELECT	@new_name = 'dmitrijseng',
	--		@new_pass = 'eng69',
	--		@new_first = 'Dmitrijs',
	--		@new_last = 'Jurins'

	DECLARE @input VARBINARY(64)
	SET @input = HASHBYTES('SHA2_512', 'hash'+CAST(@new_name as VARCHAR(512))+'salt'+CAST(@new_pass as VARCHAR(50))+'pepper')

	DECLARE @new_uid UNIQUEIDENTIFIER,
			@count INT

	SET @count = 0
	SELECT @count = COUNT(*)
	FROM dbo.[User]
	WHERE Name = @new_name AND Password = @new_pass

	IF @count = 0
	BEGIN
		SET @new_uid = NEWID()

		INSERT INTO dbo.[User]
				( UserID ,
				  Name ,
				  Password ,
				  Archived ,
				  Email ,
				  Location ,
				  FirstName ,
				  Surname ,
				  CustomerID ,
				  ExpiryDate ,
				  PasswordHash
				)
		VALUES  ( @new_uid , -- UserID - uniqueidentifier
				  @new_name , -- Name - varchar(512)
				  '',--@new_pass , -- Password - varchar(50)
				  0 , -- Archived - bit
				  'engineer@user' , -- Email - varchar(512)
				  NULL , -- Location - nvarchar(max)
				  @new_first , -- FirstName - nvarchar(128)
				  @new_last , -- Surname - nvarchar(128)
				  NULL , -- CustomerID - uniqueidentifier
				  NULL,  -- ExpiryDate - datetime
				  @input
				)

		INSERT INTO dbo.UserPreference
				( UserPreferenceID ,
				  UserID ,
				  NameID ,
				  Value ,
				  Archived
				)
		VALUES  ( NEWID() , -- UserPreferenceID - uniqueidentifier
				  @new_uid , -- UserID - uniqueidentifier
				  715 , -- NameID - int
				  N'1' , -- Value - nvarchar(max)
				  0  -- Archived - bit
				)
	END
	ELSE BEGIN
		PRINT 'Error: user already exist'
	END

GO
