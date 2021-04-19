SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Indicator table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_Insert]
(

	@IndicatorId int   ,

	@Name varchar (100)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@HighLow bit   ,

	@Parameter varchar (50)  ,

	@Type varchar (2)  ,

	@LastModified datetime   ,
	
	@IndicatorClass	CHAR(1),
	@Rounding SMALLINT,
	@DisplaySeq SMALLINT
)
AS


				
				INSERT INTO [dbo].[Indicator]
					(
					[IndicatorId]
					,[Name]
					,[Description]
					,[Archived]
					,[HighLow]
					,[Parameter]
					,[Type]
					,[LastModified]
					,[IndicatorClass]
					,[Rounding]
					,[DisplaySeq]
					)
				VALUES
					(
					@IndicatorId
					,@Name
					,@Description
					,@Archived
					,@HighLow
					,@Parameter
					,@Type
					,@LastModified
					,@IndicatorClass
					,@Rounding
					,@DisplaySeq
					)
				
									
							
			


GO
