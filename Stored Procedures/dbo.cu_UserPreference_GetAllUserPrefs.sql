SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_UserPreference_GetAllUserPrefs]
(
	@UserId UNIQUEIDENTIFIER
)
AS
--DECLARE @UserId UNIQUEIDENTIFIER
--SET @UserId = N'026F5C32-B297-42ED-892A-5796BDD43EF2' --Air
--SET @UserId = N'65157504-BE98-45E5-8079-8CD2200F0503' --Beaver
--SET @userId = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba' -- Nestle

DECLARE @ucount INT,
		@dcount INT
SET @ucount = 0
SET @dcount = 0

DECLARE @userPrefs TABLE
(
	UserPreferenceId UNIQUEIDENTIFIER,
	UserId UNIQUEIDENTIFIER,
	NameId int,
	Value nvarchar(255)
)


SELECT @ucount = COUNT(*)
FROM dbo.[User]
WHERE UserID = @UserId AND Archived = 0

IF @ucount = 0
BEGIN
	SELECT @dcount = COUNT(*)
	FROM dbo.Driver
	WHERE DriverId = @UserId AND Archived = 0
END	

IF @ucount > 0
BEGIN
	INSERT INTO @userPrefs
	SELECT up.UserPreferenceID, up.UserID, up.NameID, up.Value
	FROM [dbo].[UserPreference] up
	WHERE ((up.UserId = @UserId) OR (up.UserId IS NULL))
	AND Archived = 0
	ORDER BY NameId DESC
END


IF @dcount > 0
BEGIN
	INSERT INTO @userPrefs	
	SELECT cp.CustomerPreferenceID AS UserPreferenceId, cd.DriverId AS UserId, cp.NameID, cp.Value
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = cp.CustomerID
	WHERE cd.DriverId = @UserId
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  --AND cp.NameID = @NameId
	  AND cp.Archived = 0
	ORDER BY cd.DriverId DESC	
END	

SELECT UserPreferenceId ,
       UserId ,
       NameId ,
       Value 
FROM @userPrefs up
GO
