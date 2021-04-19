SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseRTLWString]
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
				@sidenable BIT,
				@sidport INT

		SELECT @sidenable = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1
		SELECT @sidport = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2

		IF @sidenable = 1
		BEGIN
			IF @sidport = 1
			BEGIN
				SET @com1 = 'SID'
			END ELSE
			IF @sidport = 2
			BEGIN
				SET @com2 = 'SID'
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
