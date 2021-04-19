SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_DepotTime_RS]
	@uid      UNIQUEIDENTIFIER,
    @gids     NVARCHAR(MAX),
    @dids     NVARCHAR(MAX),
    @sdate    DATETIME,
    @edate    DATETIME,
	@vch	  BIT,
	@other	  BIT,
	@exclude  BIT	
AS
	SET NOCOUNT ON;

	--DECLARE	@uid      UNIQUEIDENTIFIER,
	--		@gids     NVARCHAR(MAX),
	--		@dids     NVARCHAR(MAX),
	--		@sdate    DATETIME,
	--		@edate    DATETIME,
	--	@vch	  BIT,
	--	@other	  BIT,
	--	@exclude  BIT	
	
	--SET @dids = N'1B5600D4-85AE-4A78-B071-2EE555EB3300,BB3428A6-B8A5-4E7A-A081-99806369285F,35D56626-A2B0-445B-81E8-D744B0C4D3CF,8E1599F9-6B40-4618-A763-51DF2AE45D33,2717171E-55E3-448F-8247-AD28A14BE218,C246B423-566E-4515-85F7-86483E18E53D'
	--SET @gids = N'5C3153C6-FA67-471B-8008-3122D35CFEED,D495FAA3-6BA0-44B2-A5FB-275A052253E7,3A316860-0C95-469A-A1DA-241F6DC995FD'--NULL--N'1B5600D4-85AE-4A78-B071-2EE555EB3300,843EEAB8-EC94-4923-8327-402B09F64F1F,5E9679AC-1B6F-4700-97E8-53BB46B0BC01,0D572BAC-D832-4D53-A192-7F7C56E1D37B,98E7ECE2-6AA1-41D9-BAA9-8B9CAB5D5FD2,983AEB57-6600-42C3-BA24-8D307F5AD57F,BB3428A6-B8A5-4E7A-A081-99806369285F,071410D1-1B88-40E7-8D81-ADE51D9683E9,26C8A9B2-2EB9-49A1-8C8D-DFBA04C697C3,0071EDE5-3222-4A5F-A00C-EB679C17B6FC,51D84E06-84FB-451C-8A02-F86F0219C39A'
	--SET @sdate = '2016-10-24 00:00'
	--SET @edate = '2016-10-24 23:59'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
	--SET @vch = 0
	--SET @other = 1
	--SET @exclude = 0

	DECLARE @results TABLE
	(
		RecordNr INT,
		AssetName NVARCHAR(MAX),
		DriverType NVARCHAR(MAX),
		AssetGroupID UNIQUEIDENTIFIER,
		AssetID UNIQUEIDENTIFIER,
		AssetType INT,
		Route INT,
		Morning INT,
		Afternoon INT,
		TelematTime INT,
		KRONOSTime INT,
		OtherJob INT,
		TelematTotal INT,
		Total INT,
		KRONOSArrival DATETIME,
		GeofenceLeave DATETIME,
		GeofenceEnter DATETIME,
		KRONOSDepart DATETIME
	)

	INSERT INTO @results
			( RecordNr ,
			AssetName ,
			DriverType ,
			AssetGroupID ,
			AssetID ,
			AssetType ,
			Route ,
			Morning ,
			Afternoon ,
			TelematTime ,
			KRONOSTime ,
			OtherJob ,
			TelematTotal ,
			Total ,
			KRONOSArrival ,
			GeofenceLeave ,
			GeofenceEnter ,
			KRONOSDepart
	        )
	EXECUTE [dbo].[proc_Report_DepotTime] 
	   @uid
	  ,@gids
	  ,@dids
	  ,@sdate
	  ,@edate
	  ,@vch
	  ,@other
	  ,@exclude


	SELECT 
			CASE AssetType
				WHEN 0 THEN NULL
				WHEN 1 THEN AssetID
				WHEN 2 THEN AssetGroupID
				ELSE NULL
			END AS GroupId,
			CASE AssetType
				WHEN 0 THEN NULL
				WHEN 1 THEN NULL
				WHEN 2 THEN AssetID
				ELSE NULL
			END AS AssetId,
			AssetName ,
			DriverType ,
			AssetType ,
			Route ,
			Morning ,
			Afternoon ,
			TelematTime ,
			KRONOSTime ,
			OtherJob ,
			TelematTotal ,
			Total,
			KRONOSArrival ,
			GeofenceLeave ,
			GeofenceEnter ,
			KRONOSDepart
	FROM @results
	ORDER BY GroupId, AssetId

GO
