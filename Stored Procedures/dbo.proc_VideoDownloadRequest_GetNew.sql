SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoDownloadRequest_GetNew]
(
	@videoDispatcher VARCHAR(1024)
)
AS
	--DECLARE @videoDispatcher VARCHAR(1024)
	--SET @videoDispatcher = 'RTL.VideoDispatcher'

	--Mark records for processing
	UPDATE dbo.VideoDownloadRequest SET ProcessInd = 0 WHERE ProcessInd IS NULL AND VideoDispatcher = @videoDispatcher

	SELECT VideoDownloadRequestID ,
           IncidentId ,
           ApiEventId ,
           ApiMetadataId ,
           VideoId ,
           ApiVideoId ,
           ApiStartTime ,
           ApiEndTime ,
           ApiUrl ,
           ApiUser ,
           ApiPassword ,
           RequestDate ,
           ProcessInd ,
           VideoDispatcher ,
           UserId
	FROM dbo.VideoDownloadRequest
	WHERE ProcessInd = 0 AND VideoDispatcher = @videoDispatcher
	ORDER BY RequestDate


GO
