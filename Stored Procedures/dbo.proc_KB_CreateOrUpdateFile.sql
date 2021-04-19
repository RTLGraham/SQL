SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_CreateOrUpdateFile]
	@fileName VARCHAR(MAX),
	@description VARCHAR(MAX),
	@durationSecs INT,
	@url VARCHAR(1024),
	@bucketName VARCHAR(MAX),
	@fileTypeId SMALLINT,
	@ext VARCHAR(50),
	@acknowledge BIT,
	@uid UNIQUEIDENTIFIER,
	@fileIdCustom VARCHAR(65),
	@fileId INT = NULL
AS
BEGIN
	IF(@fileId IS NULL)
	BEGIN
	INSERT INTO dbo.KB_File
	        ( FName ,
	          Description ,
	          CustomerId ,
	          DurationSecs ,
	          Url ,
	          BucketName ,
	          FileTypeId ,
	          Ext ,
	          Acknowledge ,
	          Archived ,
	          LastOperation,
			  FileIdCustom
	        )
	SELECT @fileName, @description, u.CustomerID, @durationSecs, @url, @bucketName, @fileTypeId, @ext, @acknowledge, 0, GETDATE(),@fileIdCustom
	FROM dbo.[User] u
	WHERE u.UserID = @uid

	SELECT CAST(SCOPE_IDENTITY() AS INT)  AS fileId	
	END ELSE
	BEGIN
		UPDATE dbo.KB_File
		SET FName = @fileName,
		Description = @description,
		Acknowledge  = @acknowledge
		WHERE FileId = @fileId
		SELECT @fileId
	END

END	


GO
