SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseRTLVString]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		Com1 VARCHAR(3),
		Com2 VARCHAR(3)
	)
	AS  
	BEGIN 
	
--		DECLARE @eventdatastring VARCHAR(1024)
--		SET @eventdatastring = '0,1,19200,255,1,2,9600,1,1,0'
--	
--		DECLARE @parsedata TABLE 
--		(
--			Com1 VARCHAR(3),
--			Com2 VARCHAR(3)
--		)
	
		DECLARE @com1 VARCHAR(3),
				@com2 VARCHAR(3),
				@ss1enable BIT,
				@ss1port INT

		SELECT @ss1enable = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1
		SELECT @ss1port = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2

		IF @ss1enable = 1
		BEGIN
			IF @ss1port = 1
			BEGIN
				SET @com2 = 'SS1'  -- SS1 is always on COM2 at the moment
			END ELSE
			IF @ss1port = 2
			BEGIN
				SET @com2 = 'SS1'
			END
		END
  
		-- Populate the result table
		INSERT INTO @parsedata (Com1, Com2)
		VALUES  (@Com1, @Com2)

		RETURN
--		SELECT *
--		FROM @parsedata
		
	END

GO
