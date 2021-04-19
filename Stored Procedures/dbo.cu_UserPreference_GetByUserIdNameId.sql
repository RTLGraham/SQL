SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the UserPreference table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[cu_UserPreference_GetByUserIdNameId]
(

	@UserId uniqueidentifier   ,

	@NameId int   
)
AS

--DECLARE @NameId int,
--		@UserId uniqueidentifier

--SET @NameId = 1800
--SET @UserId = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

-- This procedure also receives individual driver users - so need to check if we have a user or a driver
DECLARE @ucount INT,
		@dcount INT
SET @ucount = 0
SET @dcount = 0

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
	SELECT TOP 1 up.UserPreferenceID, up.UserID, up.NameID, up.Value, up.Archived, 1
	FROM [dbo].[UserPreference] up
	WHERE ((up.UserID IS NULL) OR (up.UserID = @UserId))
	AND up.NameID = @NameId
	AND Archived = 0
	ORDER BY UserID DESC
END	

IF @dcount > 0
BEGIN
	SELECT TOP 1 cp.CustomerPreferenceID AS UserPreferenceId, cd.DriverId AS UserId, cp.NameID, cp.Value, cp.Archived, 1
	FROM dbo.CustomerPreference cp
	INNER JOIN dbo.CustomerDriver cd ON cd.CustomerId = cp.CustomerID
	WHERE cd.DriverId = @UserId
	  AND cd.Archived = 0
	  AND cd.EndDate IS NULL	
	  AND cp.NameID = @NameId
	  AND cp.Archived = 0
	ORDER BY cd.DriverId DESC	
END	
GO
