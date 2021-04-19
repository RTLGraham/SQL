SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Indicator table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_Update]
(

	@IndicatorId int   ,

	@OriginalIndicatorId int   ,

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


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Indicator]
				SET
					[IndicatorId] = @IndicatorId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
					,[HighLow] = @HighLow
					,[Parameter] = @Parameter
					,[Type] = @Type
					,[LastModified] = @LastModified
					,[IndicatorClass] = @IndicatorClass
					,[Rounding] = @Rounding
					,[DisplaySeq] = @DisplaySeq
				WHERE
[IndicatorId] = @OriginalIndicatorId 
				
			


GO
