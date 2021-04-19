SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseCTCDString]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		Website VARCHAR(3)
	)
	AS  
	BEGIN 
	
--		DECLARE @eventdatastring VARCHAR(1024)
--		SET @eventdatastring = '0,1,19200,255,1,2,9600,1,1,0'
--	
--		DECLARE @parsedata TABLE 
--		(
--			Website VARCHAR(3)
--		)
	
		DECLARE @Website VARCHAR(3),
				@ipport VARCHAR(50)
				
		SELECT @ipport = VALUE
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2 

		SELECT @Website = CASE @ipport
						WHEN '82.71.196.93:12030' THEN 'NST'
						WHEN '82.71.196.93:12045' THEN 'RUK'
						WHEN '82.71.196.93:12035' THEN 'RUS'
						WHEN '82.71.196.93:12011' THEN 'SKY'
						WHEN '82.71.196.93:12022' THEN 'FLS'
						WHEN '77.86.28.55:97' THEN 'FMG'
						ELSE NULL
					  END
  
		-- Populate the result table
		INSERT INTO @parsedata (Website)
		VALUES  (@Website)

		RETURN
--		SELECT *
--		FROM @parsedata
		
	END

GO
