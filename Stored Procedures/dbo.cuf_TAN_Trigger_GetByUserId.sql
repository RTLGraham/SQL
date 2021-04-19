SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TAN_Trigger table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[cuf_TAN_Trigger_GetByUserId]
(

	@uid uniqueidentifier   
)
AS
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'F2822F58-5811-4150-8D96-61B95BE001D4'
	
	 
	DECLARE @cid UNIQUEIDENTIFIER
	SELECT TOP 1 @cid = CustomerId FROM dbo.[User] WHERE UserID = @uid

	SELECT	t.TriggerId,
			t.TriggerTypeId,
			t.Name,
			t.[Description],
			t.[Disabled],
			t.Archived,
			t.LastOperation,
			t.CustomerId,
			t.CreatedBy,
			u.Name AS CreatedByName,
			t.[Count],
			CASE WHEN t.CreatedBy = @uid THEN 0 ELSE 1 END AS IsReadOnly
	FROM dbo.TAN_Trigger t
		INNER JOIN dbo.[User] u ON t.CreatedBy = u.UserID
	WHERE t.CustomerId = @cid
		AND t.Archived = 0	
	ORDER BY t.Name
	
	SELECT @@ROWCOUNT

	--SELECT
	--	[TriggerId],
	--	[TriggerTypeId],
	--	[Name],
	--	[Description],
	--	[Disabled],
	--	[Archived],
	--	[LastOperation],
	--	[CustomerId],
	--	[CreatedBy],
	--	[Count]
	--FROM
	--	[dbo].[TAN_Trigger]
	--WHERE
	--	[CreatedBy] = @uid
	--				AND
	--			Archived = 0
                            
                            
					
			




GO
