SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_DriverFolderLink]
	@driverGroupId UNIQUEIDENTIFIER,
	@folderId INT
AS
BEGIN

	INSERT INTO dbo.KB_DriverGroupFolder ( DriverGroupId, FolderId )
	VALUES  ( @driverGroupId, @folderId )

END	


GO
