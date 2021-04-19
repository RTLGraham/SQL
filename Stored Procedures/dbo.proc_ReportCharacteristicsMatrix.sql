SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportCharacteristicsMatrix]
    (
		@vid UNIQUEIDENTIFIER,
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
    )
AS 

--DECLARE @vid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @vid = N'64485527-7574-4A75-80E2-9A3657A51284'
--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'
--SET @sdate = '2017-04-10 00:00'
--SET @edate = '2017-04-10 14:59'

DECLARE @lvid UNIQUEIDENTIFIER,
		@luid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME

SET @lvid = @vid
SET @luid = @uid
SET @lsdate = @sdate
SET @ledate = @edate

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @diststr VARCHAR(20),
		@distmult FLOAT,
		@fuelstr VARCHAR(20),
		@fuelmult FLOAT,
		@co2str VARCHAR(20),
		@co2mult FLOAT,
		@liquidstr VARCHAR(20),
		@NumRows INT,
		@NumCols INT,
		@RowIndex INT,
		@ColIndex INT,
		@Colour VARCHAR(10),
		@Config VARCHAR(MAX)

SELECT @liquidstr =[dbo].UserPref(@luid, 201)
SELECT @diststr = [dbo].UserPref(@luid, 203)
SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @fuelstr = [dbo].UserPref(@luid, 205)
SELECT @fuelmult = [dbo].UserPref(@luid, 204)

DECLARE @CellColour TABLE
(
	RowIndex INT,
	ColIndex INT,
	Colour VARCHAR(10)
)

DECLARE @X_Axis TABLE
(
	ColIndex SMALLINT,
	Value VARCHAR(10)
)

DECLARE @Y_Axis TABLE
(
	RowIndex SMALLINT,
	Value VARCHAR(10)
)

-- Select and store the Matrix Configuration
SELECT @NumRows = NumRows, @NumCols = NumCols, @Config = Config
FROM dbo.CharacteristicsMatrix
WHERE CharMatrixId = 1

-- Parse Out the Y-Axis labels
INSERT INTO @Y_Axis (RowIndex, Value)
SELECT Id - 1, Value FROM dbo.Split(@Config, ',')
WHERE Id <= @NumCols
ORDER BY Id

-- Parse out the X-Axis labels
INSERT INTO @X_Axis (ColIndex, Value)
SELECT Id - @NumCols - 1, Value FROM dbo.Split(@Config, ',')
WHERE Id > @NumCols AND Id <= @NumCols + @NumRows
ORDER BY Id

-- Insert the colour strings into the temporary table using the temporary Row Index of 99
INSERT INTO @CellColour (RowIndex, ColIndex, Colour)
SELECT 99, Id - (@NumCols + @NumRows + 1), Value FROM dbo.Split(@Config, ',')
WHERE Id > @NumCols + @NumRows
ORDER BY Id;

-- Now Parse each column value to determine the individual cell colour
SET @RowIndex = 0
WHILE @RowIndex < @NumRows
BEGIN
	
	INSERT INTO @CellColour (RowIndex, ColIndex, Colour)
	SELECT @RowIndex, ColIndex, SUBSTRING(Colour, ColIndex + 1, 1)
	FROM @CellColour
	WHERE RowIndex = 99

	SET @RowIndex = @RowIndex + 1 -- Increment the Row Index

END	

-- Main Report Select
SELECT	v.VehicleId,
		v.Registration,
		cc.RowIndex, 
		cc.ColIndex AS ColumnIndex,
		SUM(cc.Fuel) AS TotalFuel,
		SUM(cc.Distance) AS TotalDistance,
		SUM(cc.TimeVal) AS TotalTime,
		CASE WHEN @fuelmult = 0.1 THEN
			(CASE WHEN SUM(cc.Fuel)=0 THEN NULL ELSE SUM(cc.Fuel) * 100 END / CASE WHEN SUM(cc.Distance) = 0 THEN NULL ELSE SUM(cc.Distance) END) 
		ELSE
			(SUM(cc.Distance) * 1000 / (CASE WHEN SUM(cc.Fuel)=0 THEN NULL ELSE SUM(cc.Fuel) END) * @fuelmult) END AS FuelEcon,
		CASE col.Colour WHEN 1 THEN 'Green' WHEN 2 THEN 'Amber' WHEN 3 THEN 'Red' END AS Colour,
		@fuelstr AS FuelString,
		@diststr AS DistanceString,
		@liquidstr AS LiquidString,
		dbo.TZ_GetTime(@lsdate, DEFAULT, @luid) AS 'CreationDateTime',
		dbo.TZ_GetTime(@ledate, DEFAULT, @luid) AS 'ClosureDateTime'
FROM dbo.Characteristics c
INNER JOIN dbo.Vehicle v ON c.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.CharacteristicsCell cc ON cc.CharId = c.CharId
INNER JOIN @CellColour col ON col.ColIndex = cc.ColIndex AND col.RowIndex = cc.RowIndex
WHERE v.VehicleId = @lvid
  AND c.OpenDateTime BETWEEN @lsdate AND @ledate
  AND c.CloseDateTime BETWEEN @lsdate AND @ledate
  AND c.Archived = 0
GROUP BY v.VehicleId, v.Registration, cc.RowIndex, cc.ColIndex, col.Colour

SELECT *
FROM @Y_Axis

SELECT *
FROM @X_Axis

GO
