SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoDownloadRequest_UpdateResult]
(
	@videoDispatcher VARCHAR(1024),
	@videoDownloadRequestID BIGINT,
	@FileSizeKB FLOAT,
	@DownloadTime INT,
	@WriteTime INT,
	@OperationStart DATETIME,
	@OperationEnd DATETIME
)
AS
	--DECLARE @videoDispatcher VARCHAR(1024)
	--SET @videoDispatcher = 'RTL.VideoDispatcher'
	
	--Mark records for post-processing
	UPDATE dbo.VideoDownloadRequest SET ProcessInd = 1 WHERE ProcessInd = 0 AND VideoDownloadRequestID = @videoDownloadRequestID

	DECLARE @videoId BIGINT
	SELECT @videoId = VideoId FROM dbo.VideoDownloadRequest WHERE ProcessInd = 1 AND VideoDownloadRequestID = @videoDownloadRequestID

	--Update the dbo.Video table to mark the video as stored locally
	UPDATE dbo.CAM_Video SET IsVideoStoredLocally = 1 WHERE VideoId = @videoId

	--Log
	INSERT INTO dbo.VideoDownloadRequestLog
	        ( IncidentId ,
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
	          VideoDispatcher ,
	          UserId ,
	          FileSizeKB ,
	          DownloadTime ,
	          WriteTime ,
	          OperationStart ,
	          OperationEnd
	        )
	SELECT IncidentId ,
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
           @videoDispatcher,
           UserId,
		   @FileSizeKB ,
		   @DownloadTime ,
		   @WriteTime ,
		   @OperationStart ,
		   @OperationEnd
	FROM dbo.VideoDownloadRequest
	WHERE ProcessInd = 1 AND VideoDownloadRequestID = @videoDownloadRequestID

	--Delete the request row
	DELETE FROM dbo.VideoDownloadRequest WHERE ProcessInd = 1 AND VideoDownloadRequestID = @videoDownloadRequestID


GO
