SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParsePassengerCount]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		DoorsOpenSeconds INT,
		A0DeltaIn INT,
		A0DeltaOut INT,
		A1DeltaIn INT,
		A1DeltaOut INT,
		A2DeltaIn INT,
		A2DeltaOut INT,
		A0AbsIn INT,
		A0AbsOut INT,
		A1AbsIn INT,
		A1AbsOut INT,
		A2AbsIn INT,
		A2AbsOut INT
	)
	AS  
	BEGIN 
	
--	DECLARE	@eventdatastring VARCHAR(1024)
--			SET @eventdatastring = '180,4,6,10,8,12,4,1234,2345,3456,4567,5678,6789'
--			
--	DECLARE @parsedata TABLE (DoorsOpenSeconds INT,A0DeltaIn INT,A0DeltaOut INT,A1DeltaIn INT,A1DeltaOut INT,A2DeltaIn INT,A2DeltaOut INT,A0AbsIn INT,A0AbsOut INT,A1AbsIn INT,A1AbsOut INT,A2AbsIn INT,A2AbsOut INT)
	
	DECLARE @DoorsOpenSeconds INT,
			@A0DeltaIn INT,
			@A0DeltaOut INT,
			@A1DeltaIn INT,
			@A1DeltaOut INT,
			@A2DeltaIn INT,
			@A2DeltaOut INT,
			@A0AbsIn INT,
			@A0AbsOut INT,
			@A1AbsIn INT,
			@A1AbsOut INT,
			@A2AbsIn INT,
			@A2AbsOut INT

		SELECT @DoorsOpenSeconds = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1
		SELECT @A0DeltaIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2
		SELECT @A0DeltaOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 3
		SELECT @A1DeltaIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 4
		SELECT @A1DeltaOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 5
		SELECT @A2DeltaIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 6
		SELECT @A2DeltaOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 7
		SELECT @A0AbsIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 8
		SELECT @A0AbsOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 9
		SELECT @A1AbsIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 10
		SELECT @A1AbsOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 11
		SELECT @A2AbsIn = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 12
		SELECT @A2AbsOut = Value
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 13
  
		-- Populate the result table
		INSERT INTO @parsedata (DoorsOpenSeconds,A0DeltaIn,A0DeltaOut,A1DeltaIn,A1DeltaOut,A2DeltaIn,A2DeltaOut,A0AbsIn,A0AbsOut,A1AbsIn,A1AbsOut,A2AbsIn,A2AbsOut)
		VALUES  (@DoorsOpenSeconds,@A0DeltaIn,@A0DeltaOut,@A1DeltaIn,@A1DeltaOut,@A2DeltaIn,@A2DeltaOut,@A0AbsIn,@A0AbsOut,@A1AbsIn,@A1AbsOut,@A2AbsIn,@A2AbsOut)

		RETURN
--		SELECT *
--		FROM @parsedata
		
	END

GO
