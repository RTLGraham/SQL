SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_GetMaintenanceUsersByGroup]
(
	@groupid UNIQUEIDENTIFIER
)
AS

--DECLARE @groupid UNIQUEIDENTIFIER
--SET @groupid = N'B9F602B1-6D45-4B46-9B54-19D066D491AA'

SELECT  u.UserID,
		u.Name,
		u.FirstName,
		u.Surname
FROM dbo.[User] u
INNER JOIN dbo.GroupDetail gd ON u.UserID = gd.EntityDataId
WHERE gd.GroupId = @groupid


GO
