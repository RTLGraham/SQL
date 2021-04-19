SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseRTLKString]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		Can VARCHAR(3)
	)
	AS  
	BEGIN 
	
--		DECLARE @eventdatastring VARCHAR(1024)
--		SET @eventdatastring = '0,1,19200,255,1,2,9600,1,1,0'
--	
--		DECLARE @parsedata TABLE 
--		(
--			Can VARCHAR(3)
--		)
	
		DECLARE @can VARCHAR(3),
				@cantype TINYINT

		SELECT @cantype = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1

		SELECT @can = CASE @cantype
						WHEN 0 THEN 'FM2'
						WHEN 1 THEN 'MB5'
						WHEN 2 THEN 'FM5'
						WHEN 3 THEN 'MB1'
						WHEN 4 THEN 'GPS'
						WHEN 5 THEN 'SPR'
						WHEN 6 THEN 'GRT'
						ELSE NULL
					  END
  
		-- Populate the result table
		INSERT INTO @parsedata (Can)
		VALUES  (@can)

		RETURN
--		SELECT *
--		FROM @parsedata
		
	END

GO
