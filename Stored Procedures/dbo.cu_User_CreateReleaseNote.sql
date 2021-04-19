SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cu_User_CreateReleaseNote]
(
	@UserId UNIQUEIDENTIFIER,
	@AssemblyVersion VARCHAR(20),
	@Name NVARCHAR(MAX),
	@Description NVARCHAR(MAX),
	@ReleaseDate DATETIME,
	@FileExtension VARCHAR(10),
	@FilePayload IMAGE
)
AS 
	
	INSERT INTO dbo.ReleaseNote
	        ( AssemblyVersion ,
	          Name ,
	          Description ,
	          ReleaseDate ,
	          FileExtension ,
	          FilePayload ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( 
			@AssemblyVersion,
			@Name,
			@Description,
			@ReleaseDate,
			@FileExtension,
			@FilePayload,
			GETDATE(),
			0
	        )

GO
