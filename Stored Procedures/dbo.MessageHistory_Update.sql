SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the MessageHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_Update]
(

	@MessageId int   ,

	@MessageText nvarchar (1024)  ,

	@Lat float   ,

	@SafeNameLong float   ,

	@ReverseGeocode nvarchar (255)  ,

	@Date datetime   ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[MessageHistory]
				SET
					[MessageText] = @MessageText
					,[Lat] = @Lat
					,[Long] = @SafeNameLong
					,[ReverseGeocode] = @ReverseGeocode
					,[Date] = @Date
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[MessageId] = @MessageId 
				
			


GO
