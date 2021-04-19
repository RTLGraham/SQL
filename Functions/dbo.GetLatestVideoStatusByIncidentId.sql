SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetLatestVideoStatusByIncidentId]
(
	@incidentId BIGINT,
	@cameraNr INT
)
RETURNS INT
AS
BEGIN
	DECLARE @status INT
	SET @status = 0

	SELECT TOP 1 @status = VideoStatus
	FROM dbo.CAM_Video v
	WHERE v.IncidentId = @incidentId AND v.CameraNumber = @cameraNr
	ORDER BY v.LastOperation DESC
    
	RETURN @status
END


GO
