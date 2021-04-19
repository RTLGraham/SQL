SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[SplitRFID]
	(
		@List nvarchar(MAX),
		@EventId BIGINT,
		@SplitOn nvarchar(5),
		@SplitOnSmall nvarchar(1)
	)  
	RETURNS @RtnValue table 
	(
		
		Id int identity(1,1),
		EventId BIGINT,
		RageId NVARCHAR(100),
		AntennaId NVARCHAR(50)
	) 
	AS  
	BEGIN 

--DECLARE @List NVARCHAR(MAX),
--		@EventId BIGINT,
--		@SplitOn NVARCHAR(5),
--		@SplitOnSmall NVARCHAR(1)

--DECLARE @RtnValue TABLE 
--	(
		
--		Id INT IDENTITY(1,1),
--		EventId BIGINT,
--		RageId NVARCHAR(100),
--		AntennaId NVARCHAR(50)
--	) 
--SET @List = '000000000000001001000385:12:::000000000000001001000296:2:::000000000000001001000300:3'
--SET @SplitOn = ':::'
--SET @SplitOnSmall = ':'
--SET @EventId = 999


		DECLARE @tmp TABLE 
		(
			
			Id INT IDENTITY(1,1),
			EventId BIGINT,
			RageId NVARCHAR(100),
			AntennaId NVARCHAR(50)
		) 
		WHILE (CHARINDEX(@SplitOn,@List)>0)
		BEGIN

			INSERT INTO @tmp (EventId, RageId, AntennaId)
			SELECT @EventId, Value = LTRIM(RTRIM(SUBSTRING(@List,1,CHARINDEX(@SplitOn,@List)-1))), NULL

			SET @List = SUBSTRING(@List,CHARINDEX(@SplitOn,@List)+LEN(@SplitOn),LEN(@List))
		END

		INSERT INTO @tmp (EventId, RageId, AntennaId)
		SELECT @EventId, RageId = LTRIM(RTRIM(@List)), NULL

		INSERT INTO @RtnValue (EventId, RageId, AntennaId)
		SELECT  EventId,
				LTRIM(RTRIM(SUBSTRING(RageId,1,CHARINDEX(@SplitOnSmall,RageId)-1))) AS RageId,
				SUBSTRING(RageId,CHARINDEX(@SplitOnSmall,RageId)+LEN(@SplitOnSmall),LEN(RageId)) AS AntennaId
		FROM @tmp	
		
		--SELECT * FROM @RtnValue
		RETURN
	END

GO
