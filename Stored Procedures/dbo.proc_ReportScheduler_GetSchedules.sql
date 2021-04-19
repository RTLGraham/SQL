SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportScheduler_GetSchedules]
AS
	SET NOCOUNT ON

	DECLARE @rsaid INT,
			@reportscheduleid INT,
			@reportid UNIQUEIDENTIFIER,
			@periodtypeid INT,
			@uid UNIQUEIDENTIFIER,
			@paramstring NVARCHAR(MAX),
			@rdl NVARCHAR(MAX),
			@rdlpath NVARCHAR(MAX),
			@rdlcustomsuffix NVARCHAR(25),
			@customrdl NVARCHAR(MAX),
			@widgettypeid INT,
			@newline CHAR(2),
			@success BIT,
			@exportformat VARCHAR(30),
			@description NVARCHAR(200),
			@emailto NVARCHAR(400),
			@emailcc NVARCHAR(400),
			@emailbcc NVARCHAR(400),
			@emailsubject NVARCHAR(255),
			@sDate DATETIME,
			@eDate DATETIME,
			@parameter NVARCHAR(MAX)
	
	SET @newline = CHAR(13) + CHAR(10)

	DECLARE @schedules TABLE
	(
		IsOnDemandReport BIT,
		ReportScheduleId INT,
		ReportScheduleActivityId INT,
		RDL NVARCHAR(MAX),
		Exportformat NVARCHAR(30), 
		Description NVARCHAR(200), 
		Emailto NVARCHAR(400), 
		Emailcc NVARCHAR(400), 
		Emailbcc NVARCHAR(400), 
		Emailsubject NVARCHAR(255), 
		Paramstring NVARCHAR(MAX)
	)
 
	DECLARE @Params TABLE
	(
		ParameterId INT NOT NULL,
		Seq INT NOT NULL,
		ParameterTypeId INT,
		Name VARCHAR(255) NOT NULL,
		Value NVARCHAR(MAX) NULL
	)
	
	DECLARE @ParamsOnDemand TABLE
	(
		ParameterId INT NOT NULL,
		Value NVARCHAR(MAX) NULL
	)

	DECLARE @Exception TABLE
	(
		ExceptionName VARCHAR(MAX),
		ExceptionDetail VARCHAR(MAX)
	)

	-- Step 1: Mark all due reports as 'In Progress'
	UPDATE dbo.ReportScheduleActivity
	SET Status = 1
	WHERE Status = 0
	AND ScheduleDateTime <= GETUTCDATE()

	UPDATE dbo.ReportOnDemand
	SET Status = 1
	WHERE Status = 0
	  AND Archived = 0

	DECLARE data_cur CURSOR FAST_FORWARD FOR
		SELECT	rsa.ReportScheduleActivityId, 
				rsa.ReportScheduleId, 
				r.ReportId,
				rs.UserId, 
				rs.ReportPeriodTypeId,
				rdl.RDL,
				r.RDLPath,
				CustomRDLSuffix,
				r.WidgetTypeId,
				rs.ExportFormat,
				rs.Description,
				rs.RecipientsTo,
				rs.RecipientsCC,
				rs.RecipientsBCC,
				rs.EmailSubject
		FROM dbo.ReportScheduleActivity rsa
			INNER JOIN dbo.ReportSchedule rs ON rsa.ReportScheduleId = rs.ReportScheduleId
			INNER JOIN dbo.Report r ON rs.ReportId = r.ReportId
			INNER JOIN dbo.ReportRDL rdl ON rs.ReportRDLId = rdl.ReportRDLId
			WHERE Status = 1
			ORDER BY rsa.ScheduleDateTime ASC

	-- Step 2: Process each scheduled report in turn
	OPEN data_cur
	FETCH NEXT FROM data_cur INTO	@rsaid, @reportscheduleid, @reportid, @uid, @periodtypeid, @rdl, @rdlpath,
									@rdlcustomsuffix, @widgettypeid, @exportformat, @description, @emailto, @emailcc,
									@emailbcc, @emailsubject
	WHILE @@fetch_status = 0
	BEGIN

		SET @customrdl = NULL -- initialise
			
		-- Check for Custom RDL
		SELECT @customrdl = Value
		FROM dbo.UserPreference up
		WHERE Nameid = CASE @widgettypeid	
						WHEN 3 THEN 173
						WHEN 4 THEN 155
						--WHEN 34 THEN 158
					  END
		  AND UserID = @uid
		  AND Archived = 0
		
		-- Now set the full path and RDL
		IF @customrdl IS NULL
			SET @rdl = @rdlpath + @rdl
		ELSE
			SET @rdl = @rdlpath + @customrdl + ISNULL(@rdlcustomsuffix,'')
		
		-- Determine parameter list
		DELETE FROM @Params

		INSERT INTO @Params (ParameterId, Seq, ParameterTypeId, Name)
		SELECT ReportParameterId, Seq, ReportParameterTypeId, Name
		FROM dbo.ReportParameter rp
		WHERE rp.ReportId = @reportid
		  AND rp.Archived = 0
		  
		UPDATE @Params
		SET Value = CASE WHEN rsp.Value = '' THEN NULL ELSE rsp.Value END
		FROM @Params p
		INNER JOIN dbo.ReportScheduleParameter rsp ON p.ParameterId = rsp.ReportParameterId
		WHERE rsp.ReportScheduleId = @reportscheduleid
		
		-- Calculate start and end dates
		UPDATE @Params
		SET Value = dbo.TZ_GetTime(CONVERT(CHAR(19), dbo.GetScheduledStartDate(@periodtypeid, @uid), 120), DEFAULT, @uid)
		WHERE ParameterTypeId = 17
		
		UPDATE @Params
		SET Value = dbo.TZ_GetTime(CONVERT(CHAR(19), dbo.GetScheduledEndDate(@periodtypeid, @uid), 120), DEFAULT, @uid)
		WHERE ParameterTypeId = 18
		
		-- Build the parameter string
		SET @paramstring = ''
		IF (SELECT COUNT(*) FROM @Params) > 0
		BEGIN
			SELECT @paramstring = COALESCE(@paramstring + @newline,'') + Name + '|' + ISNULL(Value, 'NULL')
			FROM @Params
			ORDER BY Seq
		END
		
		INSERT INTO @schedules
			    (   IsOnDemandReport,
					ReportScheduleId,
				    ReportScheduleActivityId ,
			        RDL ,
			        Exportformat ,
			        Description ,
			        Emailto ,
			        Emailcc ,
			        Emailbcc ,
			        Emailsubject ,
			        Paramstring
			    )
		VALUES  (   0,
					@reportscheduleid, -- ReportScheduleId - int
					@rsaid , -- ReportScheduleActivityId - int
			        @rdl , -- RDL - nvarchar(max)
			        @exportformat , -- Exportformat - nvarchar(30)
			        @description , -- Description - nvarchar(200)
			        @emailto , -- Emailto - nvarchar(400)
			        @emailcc , -- Emailcc - nvarchar(400)
			        @emailbcc , -- Emailbcc - nvarchar(400)
			        @emailsubject , -- Emailsubject - nvarchar(255)
			        @paramstring  -- Paramstring - nvarchar(max)
			    )
		
		FETCH NEXT FROM data_cur INTO	@rsaid, @reportscheduleid, @reportid, @uid, @periodtypeid, @rdl, @rdlpath,
										@rdlcustomsuffix, @widgettypeid, @exportformat, @description, @emailto, @emailcc,
										@emailbcc, @emailsubject
	END
	CLOSE data_cur
	DEALLOCATE data_cur


	-- Step 3: Process each OnDemand Report in turn (where a UserId is present - indicating manually requested report
	DECLARE data_cur CURSOR FAST_FORWARD FOR
		SELECT	rod.ReportOnDemandId, 
				rod.ReportId,
				rod.UserId, 
				rdl.RDL,
				r.RDLPath,
				r.CustomRDLSuffix,
				r.WidgetTypeId,
				rod.ExportFormat,
				rod.Description,
				rod.Emailto,
				rod.Emailcc,
				rod.Emailbcc,
				rod.EmailSubject,
				rod.Paramstring,
				rod.StartDate,
				rod.EndDate
		FROM dbo.ReportOnDemand	rod
			INNER JOIN dbo.Report r ON rod.ReportId = r.ReportId
			INNER JOIN dbo.ReportRDL rdl ON rdl.ReportId = rod.ReportId
			WHERE rod.Status = 1
			  AND rod.Archived = 0
			  AND rod.UserId IS NOT NULL	

	OPEN data_cur
	FETCH NEXT FROM data_cur INTO	@reportscheduleid, @reportid, @uid, @rdl, @rdlpath,
									@rdlcustomsuffix, @widgettypeid, @exportformat, @description, @emailto, @emailcc,
									@emailbcc, @emailsubject, @paramstring, @sDate, @eDate
	WHILE @@fetch_status = 0
	BEGIN

		SET @customrdl = NULL -- initialise

		-- Check for Custom RDL
		SELECT @customrdl = Value
		FROM dbo.UserPreference up
		WHERE Nameid = CASE @widgettypeid	
						WHEN 3 THEN 173
						WHEN 4 THEN 155
						--WHEN 34 THEN 158
					  END
		  AND UserID = @uid
		  AND Archived = 0
		
		-- Now set the full path and RDL
		IF @customrdl IS NULL
			SET @rdl = @rdlpath + @rdl
		ELSE
			SET @rdl = @rdlpath + @customrdl + ISNULL(@rdlcustomsuffix,'')
		
		-- Determine parameter list
		DELETE FROM @Params

		INSERT INTO @Params (ParameterId, Seq, ParameterTypeId, Name)
		SELECT ReportParameterId, Seq, ReportParameterTypeId, Name
		FROM dbo.ReportParameter rp
		WHERE rp.ReportId = @reportid
		  AND rp.Archived = 0

		-- Take start and end dates from values provided in ReportOnDemand table
		UPDATE @Params
		SET Value = @sDate
		WHERE ParameterTypeId = 17
		
		UPDATE @Params
		SET Value = @eDate
		WHERE ParameterTypeId = 18
		
		-- Identify params provided from OnDemand table
		DECLARE TCursor CURSOR FAST_FORWARD READ_ONLY
		FOR
		SELECT VALUE FROM dbo.Split(@paramstring, @newline)

		OPEN TCursor
		FETCH NEXT FROM TCursor INTO @parameter

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @ParamsOnDemand (ParameterId, Value)
			VALUES  ( LEFT(@parameter,CHARINDEX('|',@parameter)-1), -- ReportParameterId
					  RIGHT(@parameter,LEN(@parameter)-CHARINDEX('|', @parameter))  -- Value
					)
	
			FETCH NEXT FROM TCursor INTO @parameter
		END

		CLOSE TCursor
		DEALLOCATE TCursor	

		-- Update the @Params table to include the values from OnDemand
		UPDATE @Params
		SET Value = pod.Value
		FROM @Params p
		INNER JOIN @ParamsOnDemand pod ON pod.ParameterId = p.ParameterId		
		
		-- Rebuild the parameter string
		SET @paramstring = ''
		IF (SELECT COUNT(*) FROM @Params) > 0
		BEGIN
			SELECT @paramstring = COALESCE(@paramstring + @newline,'') + Name + '|' + ISNULL(Value, 'NULL')
			FROM @Params
			ORDER BY Seq
		END

		INSERT INTO @schedules
			    (   IsOnDemandReport,
					ReportScheduleId,
				    ReportScheduleActivityId ,
			        RDL ,
			        Exportformat ,
			        Description ,
			        Emailto ,
			        Emailcc ,
			        Emailbcc ,
			        Emailsubject ,
			        Paramstring
			    )
		VALUES  (   1,
					@reportscheduleid, -- ReportScheduleId - int
					NULL , -- ReportScheduleActivityId - int
			        @rdl , -- RDL - nvarchar(max)
			        @exportformat , -- Exportformat - nvarchar(30)
			        @description , -- Description - nvarchar(200)
			        @emailto , -- Emailto - nvarchar(400)
			        @emailcc , -- Emailcc - nvarchar(400)
			        @emailbcc , -- Emailbcc - nvarchar(400)
			        @emailsubject , -- Emailsubject - nvarchar(255)
			        @paramstring  -- Paramstring - nvarchar(max)
			    )

		FETCH NEXT FROM data_cur INTO	@reportscheduleid, @reportid, @uid, @rdl, @rdlpath,
										@rdlcustomsuffix, @widgettypeid, @exportformat, @description, @emailto, @emailcc,
										@emailbcc, @emailsubject, @paramstring, @sDate, @eDate
	END	
	CLOSE data_cur
	DEALLOCATE data_cur

	-- Step 4: Return the full list of reports to be processed by the dispatcher
	SELECT	s.IsOnDemandReport,
			s.ReportScheduleId,
			s.ReportScheduleActivityId ,
			s.RDL ,
			s.Exportformat ,
			s.Description ,
			s.Emailto ,
			s.Emailcc ,
			s.Emailbcc ,
			s.Emailsubject ,
			s.Paramstring
	FROM @schedules s
	UNION
	SELECT 1 AS IsOnDemandReport,
		   o.ReportOnDemandId AS ReportScheduleId,
           NULL AS ReportScheduleActivityId ,
           o.RDL ,
           o.Exportformat ,
           o.Description ,
           o.Emailto ,
           o.Emailcc ,
           o.Emailbcc ,
           o.Emailsubject ,
           o.Paramstring
	FROM dbo.ReportOnDemand o
	WHERE o.Status = 1 
	  AND o.UserId IS NULL	-- add any automated OnDemand Reports



GO
