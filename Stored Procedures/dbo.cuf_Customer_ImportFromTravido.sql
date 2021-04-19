SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_ImportFromTravido]
(
	@new_cname NVARCHAR(100), 
	@new_pid VARCHAR(20), 
	@new_pun VARCHAR(20)
)
AS		
	--DECLARE @new_cname NVARCHAR(100), 
	--		@new_pid VARCHAR(20), 
	--		@new_pun VARCHAR(20)
	
	--SELECT	@new_cname =	'NG Transport',
	--		@new_pid =		'319',  
	--		@new_pun =		'NGTRANSPORTAPI'

	DECLARE @new_cid UNIQUEIDENTIFIER, @new_ppw VARCHAR(20), @new_lid NVARCHAR(100), @new_uid UNIQUEIDENTIFIER, @new_uun NVARCHAR(100), @new_upw NVARCHAR(100),
		@old_cid UNIQUEIDENTIFIER, @old_uid UNIQUEIDENTIFIER, @old_pid INT, @dd_name VARCHAR(100), @itsvts VARCHAR(200)

	SELECT	@new_cid = NEWID(), @new_uid = NEWID(), @new_upw = [dbo].[GeneratePassword](8), @new_lid = '1'

	SET @itsvts = 'ITS'
	SELECT TOP 1 @dd_name = c.DataDispatcher
	FROM dbo.Project p
		INNER JOIN dbo.Customer c ON c.CustomerId = p.CustomerId
		INNER JOIN dbo.CustomerVehicle cv ON cv.CustomerId = c.CustomerId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = cv.VehicleId
	WHERE c.Name NOT LIKE '%default%' AND v.Archived = 0 AND c.Archived = 0 and c.DataDispatcher LIKE '%Cloud%' AND c.DataDispatcher != 'RTL.DataDispatcher.Cloud'
	GROUP BY c.DataDispatcher
	ORDER BY COUNT(*) ASC

	SELECT  @new_uun =		@new_pid + '_Admin'
	SELECT  @new_ppw =		@new_pun + '1!'

	SELECT @old_cid = CustomerId FROM dbo.Customer WHERE Name = 'Polaris Services Ltd'
	SELECT @old_uid = UserId FROM dbo.[User] WHERE Name = 'PS_Admin'
	SELECT @old_pid = ProjectId FROM dbo.Project WHERE Project = '7050'

	-- 'Creating customer...'
		INSERT INTO dbo.Customer( CustomerId ,Name ,LastOperation ,Archived ,OverSpeedPercent ,OverSpeedHighPercent, Addr4, DataDispatcher)
		VALUES  ( @new_cid ,@new_cname , GETDATE() , 0 , CASE WHEN @itsvts = 'ITS' THEN 0 ELSE NULL END, CASE WHEN @itsvts = 'ITS' THEN 10 ELSE NULL END, @itsvts, @dd_name)

	-- 'Adding customer preferences...'
		INSERT INTO dbo.CustomerPreference( CustomerPreferenceID ,CustomerID ,NameID ,Value ,Archived)
		SELECT NEWID(), @new_cid, NameID ,Value ,Archived
		FROM dbo.CustomerPreference
		WHERE CustomerID = @old_cid

	-- 'Creating admin user...'
		INSERT INTO dbo.[User]( UserID ,Name ,Password ,Archived ,Email ,CustomerID)
		VALUES  ( @new_uid , @new_uun, @new_upw, 0, 'scott@intelligent-telematics.co.uk', @new_cid)

	-- 'Adding admin user preferences...'
		INSERT INTO dbo.UserPreference( UserPreferenceID ,UserID ,NameID ,Value ,Archived)
		SELECT NEWID(), @new_uid, NameID ,Value ,Archived
		FROM dbo.UserPreference
		WHERE UserID = @old_uid	

	-- 'Creating new project...'
		INSERT INTO dbo.Project( Project ,CustomerId ,ApiUrl ,ApiUser ,ApiPassword ,LastIncidentId ,Archived ,LastOperation)
		VALUES  ( @new_pid , @new_cid , N'https://travido.info/api/v1/' , @new_pun, @new_ppw, @new_lid, 0, GETDATE())
		INSERT INTO Gopher.dbo.CAM_Project( ProjectId ,ApiUrl ,ApiUser ,ApiPassword ,LastNewDataId ,Archived, DataDispatcher)
		VALUES  ( @new_pid , N'https://travido.info' , @new_pun, @new_ppw, @new_lid, 1, @dd_name)
		
	EXECUTE [dbo].[cuf_Customer_PostCreateScript] @new_cid

GO
