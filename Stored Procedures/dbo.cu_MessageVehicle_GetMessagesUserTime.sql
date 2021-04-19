SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cu_MessageVehicle_GetMessagesUserTime]
(
	@uid UNIQUEIDENTIFIER,
	@offsetDays INT
)
AS
BEGIN
	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@offsetDays INT
	--SET @uid = N'8DA18520-50CA-402F-AE8E-6015B443B92C'
	--SET @offsetDays = 2
	
	DECLARE @since DATETIME
	SET @since = DATEADD(DAY, @offsetDays * -1, GETDATE())
	
	/* Get all new messages from all vehicles */
	SELECT mv.MessageId, v.VehicleId, v.Registration, mv.TimeSent, mh.MessageText
	FROM dbo.MessageVehicle mv
		LEFT OUTER JOIN dbo.MessageHistory mh ON mv.MessageId = mh.MessageId
		RIGHT OUTER JOIN dbo.UserGroup ug ON ug.UserId = @uid AND ug.Archived = 0
		RIGHT OUTER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId AND g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0
		RIGHT OUTER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = gd.EntityDataId AND mv.VehicleId = v.VehicleId
	WHERE mv.UserId IS NULL	
		AND mv.LastModified > @since
END

GO
