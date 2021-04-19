SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_KB_WriteDriverHistory] (@did UNIQUEIDENTIFIER, @fileid INT, @datetime DATETIME=NULL, @duration INT=NULL, @assessdatetime DATETIME=NULL, @isAssessed BIT=NULL)
AS
BEGIN

	--DECLARE @did UNIQUEIDENTIFIER,
	--		@fileid INT,
	--		@datetime DATETIME,
	--		@duration INT
	--SET @did = N'70277752-9849-E111-A26E-001C23C37503'
	--SET @fileid = 1
	--SET @datetime = GETUTCDATE()
	--SET @duration = 15

	INSERT INTO dbo.KB_DriverHistory
	        (DriverIntId,
	         FileId,
	         AccessDateTime,
	         ViewedDuration,
	         LastOperation
	        )
	SELECT	d.DriverIntId,
			@fileid,
			@datetime,
			@duration,
			GETDATE()
	FROM dbo.Driver d
	WHERE d.DriverId = @did

END	
GO
