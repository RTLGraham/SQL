SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseCFGString]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		Version VARCHAR(12),
		Website VARCHAR(3),
		Network VARCHAR(3),
		Com1 VARCHAR(3),
		Com2 VARCHAR(3),
		CanType VARCHAR(3), 
		Options VARCHAR(26), 
		TestVersion VARCHAR(32)
	)
	AS  
	BEGIN 
	
--		DECLARE @eventdatastring VARCHAR(1024)
--		SET @eventdatastring = 'NST_SWC_NON_SS1_MB5_CDE_TSTR3_1_4_99'
--	
--		DECLARE @parsedata TABLE 
--		(
--			Version VARCHAR(12),
--			Website VARCHAR(3),
--			Network VARCHAR(3),
--			Com1 VARCHAR(3),
--			Com2 VARCHAR(3),
--			CanType VARCHAR(3), 
--			Options VARCHAR(26), 
--			TestVersion VARCHAR(32)
--		)
	
		IF ISNULL(LEN(@eventdatastring),0) >= 26 -- We have received a potentially valid CFG string
		BEGIN
	
			DECLARE @Version VARCHAR(12),
					@Website VARCHAR(3),
					@Network VARCHAR(3),
					@Com1 VARCHAR(3),
					@Com2 VARCHAR(3),
					@CanType VARCHAR(3), 
					@Options VARCHAR(26), 
					@TestVersion VARCHAR(32)
		
			-- Identify Fixed length fields first
			SELECT @Website = SUBSTRING(@eventdatastring,1,3)
			SELECT @Network = SUBSTRING(@eventdatastring,5,3)
			SELECT @Com1 = SUBSTRING(@eventdatastring,9,3)
			SELECT @Com2 = SUBSTRING(@eventdatastring,13,3)
			SELECT @CanType = SUBSTRING(@eventdatastring,17,3)	   

			-- Now check for presence of Options
			IF SUBSTRING(@eventdatastring, 21,1) != 'T' AND SUBSTRING(@eventdatastring, 21,1) NOT LIKE '[0-9]'
			BEGIN
				-- Parse until next underscore character
				SELECT @Options = SUBSTRING(@eventdatastring, 21, CHARINDEX('_', @eventdatastring, 21) - 21)
			END

			-- Now check for Test Version String
			IF SUBSTRING(@eventdatastring, 21 + ISNULL(LEN(@Options)+1, 0) ,1) = 'T'
			BEGIN
				-- Parse until next underscore character
				SELECT @TestVersion = SUBSTRING(@eventdatastring, 21 + ISNULL(LEN(@Options)+1, 0), CHARINDEX('_', @eventdatastring, 21 + ISNULL(LEN(@Options)+1, 0)) - (21 + ISNULL(LEN(@Options)+1, 0)))
			END
			
			-- Finally get the version number
			SELECT @Version = RIGHT(@eventdatastring, LEN(@eventdatastring) - 20 - ISNULL(LEN(@Options)+1,0) - ISNULL(LEN(@TestVersion)+1,0))
			  
			-- Populate the result table
			INSERT INTO @parsedata (Version, Website, Network, Com1, Com2, CanType, Options, TestVersion)
			VALUES  (@Version, @Website, @Network, @Com1, @Com2, @CanType, @Options, @TestVersion)
		END
		
		RETURN
--		SELECT * FROM @parsedata
		
	END

GO
