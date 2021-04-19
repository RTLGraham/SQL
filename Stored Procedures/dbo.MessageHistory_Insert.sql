SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the MessageHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_Insert]
(

	@MessageId int    OUTPUT,

	@MessageText nvarchar (1024)  ,

	@Lat float   ,

	@SafeNameLong float   ,

	@ReverseGeocode nvarchar (255)  ,

	@Date datetime   ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[MessageHistory]
					(
					[MessageText]
					,[Lat]
					,[Long]
					,[ReverseGeocode]
					,[Date]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@MessageText
					,@Lat
					,@SafeNameLong
					,@ReverseGeocode
					,@Date
					,@LastModified
					,@Archived
					)
				
				-- Get the identity value
				SET @MessageId = SCOPE_IDENTITY()
									
							
			


GO
