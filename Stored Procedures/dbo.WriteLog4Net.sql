SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WriteLog4Net]
(

	@log_date datetime,
	@thread nvarchar(255), 
	@log_level nvarchar(50),
	@logger nvarchar(255),
	@message nvarchar(4000),
	@exception nvarchar(2000)
)
AS 

	INSERT INTO [dbo].[Log4NetLog]
           ([Date]
           ,[Thread]
           ,[Level]
           ,[Logger]
           ,[Message]
           ,[Exception])
     VALUES
           (@log_date
           ,@thread
           ,@log_level
           ,@logger
           ,@message
           ,@exception)

GO
