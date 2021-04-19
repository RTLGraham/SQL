SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_WriteSCAMVideoIn] @video VARCHAR(1024),@acc VARCHAR(1024), @stime DATETIME, @etime DATETIME, @videostatus INT=NULL, @projectid VARCHAR(20)=NULL
AS
BEGIN

	INSERT INTO dbo.SCAM_VideoIn
	        (Video,
	         Acc,
	         Stime,
	         Etime,
	         VideoStatus,
	         ProjectId,
	         ProcessInd
	        )
	VALUES  (@video, 
	         @acc, 
	         @stime, 
	         @etime, 
	         @videostatus, 
	         @projectid, 
	         0  
	        )

END	









GO
