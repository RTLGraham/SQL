SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_GetAttachmentByAttachmentId] 
	@attachmentId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT AttachmentId
      ,DiagnosticsId
      ,FName
      ,Description
      ,Url
      ,BucketName
      ,AttachmentTypeId
      ,Archived
      ,LastOperation
  FROM [dbo].[Attachment] Where AttachmentId = @attachmentId

END

GO
