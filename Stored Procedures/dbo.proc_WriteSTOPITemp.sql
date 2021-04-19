SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteSTOPITemp]
    @stopiid INT OUTPUT,
    @eid BIGINT,
    @text VARCHAR(1500),
    @depid INT
AS 
    INSERT  INTO dbo.STOPITemp
            (
              [Text],
              LastOperation,
              Archived,
              CustomerIntId,
              EventId
            )
    VALUES  (
              @text,
              GETDATE(),
              1,
              @depid,
              @eid
            )

    SET @stopiid = SCOPE_IDENTITY()


GO
