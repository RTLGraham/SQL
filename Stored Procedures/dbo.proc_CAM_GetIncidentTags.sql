SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_CAM_GetIncidentTags]
(
	@incidentId BIGINT
)
AS
	--DECLARE @incidentId BIGINT
		

	--SET @incidentId = 18198


	SET NOCOUNT ON;

	SELECT IncidentTagId ,
           IncidentId ,
           TagId ,
           LastModified ,
           Archived
	FROM dbo.CAM_IncidentTag
	WHERE IncidentId = @incidentId
		AND Archived = 0
	ORDER BY LastModified DESC

GO
