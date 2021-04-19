SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseRTLFString]
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
				@ledenable BIT,
				@ledport INT,
				@ledbaud INT,
				@ledfeatures INT,
				@garminenable BIT,
				@garminport INT,
				@garminbaud INT,
				@tachoenable BIT,
				@tachoport INT
--				@tachobaud INT
		
		SELECT @ledenable = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1
		SELECT @ledport = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2
		SELECT @ledbaud = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 3
		SELECT @ledfeatures = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 4
		SELECT @garminenable = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 5
		SELECT @garminport = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 6
		SELECT @garminbaud = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 7
		SELECT @tachoenable = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 8
		SELECT @tachoport = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 9

		IF @ledenable = 1
		BEGIN
			IF @ledport = 1
			BEGIN
				IF dbo.TestBits(@ledfeatures, 1) = 1 AND dbo.TestBits(@ledfeatures, 2) = 1
					SET @com1 = 'LED'
				IF dbo.TestBits(@ledfeatures, 1) = 1 AND dbo.TestBits(@ledfeatures, 2) = 0
					SET @com1 = 'DBD'
			END ELSE 
			IF @ledport = 2	
			BEGIN
				IF dbo.TestBits(@ledfeatures, 1) = 1 AND dbo.TestBits(@ledfeatures, 2) = 1
					SET @com2 = 'LED'
				IF dbo.TestBits(@ledfeatures, 1) = 1 AND dbo.TestBits(@ledfeatures, 2) = 0
					SET @com2 = 'DBD'			
			END
		END
		
		IF @garminenable = 1
		BEGIN
			IF @garminport = 1
			BEGIN
				SET @com1 = 'GAR'
			END ELSE
			IF @garminport = 2
			BEGIN
				SET @com2 = 'GAR'
			END
		END

		IF @tachoenable = 1
		BEGIN
			IF @tachoport = 1
			BEGIN
				SET @com1 = 'TAC'
			END ELSE
			IF @tachoport = 2
			BEGIN
				SET @com2 = 'TAC'
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
