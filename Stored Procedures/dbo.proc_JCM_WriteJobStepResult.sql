SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <02/05/2016>
-- Description:	<Used by RTL.DataDispatcher to insert job results parsed out from the job file>
-- =============================================
CREATE PROCEDURE [dbo].[proc_JCM_WriteJobStepResult]
	@jobStepId INT,
	@nameId INT,
	@value NVARCHAR(MAX),
	@isReq BIT
AS
BEGIN
	SET NOCOUNT OFF;

	INSERT INTO dbo.JCM_JobStepResult
	        ( JobStepId ,
	          NameId ,
	          Value ,
	          IsReq ,
	          Archived ,
	          LastOperation
	        )
	VALUES  ( @jobStepId , -- JobStepId - int
	          @nameId , -- NameId - int
	          @value , -- Value - nvarchar(max)
	          @isReq , -- IsReq - bit
	          0 , -- Archived - bit
	          GETDATE()  -- LastOperation - smalldatetime
	        )
END

GO
