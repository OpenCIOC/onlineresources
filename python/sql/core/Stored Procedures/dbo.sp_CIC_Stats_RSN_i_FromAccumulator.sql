SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Stats_RSN_i_FromAccumulator]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @tmpdeleted table (
	[MemberID] [int] NOT NULL,
	[AccessDate] [datetime] NOT NULL,
	[IPAddress] [varchar](20) COLLATE Latin1_General_100_CI_AI NULL,
	[RSN] [int] NULL,
	[LangID] [smallint] NOT NULL,
	[User_ID] [int] NULL,
	[ViewType] [int] NULL,
	[API] [bit] NOT NULL,
	[NUM] [varchar](8) COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @LASTCOUNT int
SET @LASTCOUNT = 10000

WHILE @LASTCOUNT = 10000 BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		DELETE TOP (10000) FROM dbo.CIC_Stats_RSN_Accumulator
		OUTPUT Deleted.MemberID,
			   Deleted.AccessDate,
			   Deleted.IPAddress,
			   Deleted.RSN,
			   Deleted.LangID,
			   Deleted.User_ID,
			   Deleted.ViewType,
			   Deleted.API,
			   Deleted.NUM
		INTO @tmpdeleted

		INSERT INTO dbo.CIC_Stats_RSN
				(MemberID,
				 AccessDate,
				 IPAddress,
				 RSN,
				 LangID,
				 User_ID,
				 ViewType,
				 API,
				 NUM
				)
		SELECT MemberID,
			   AccessDate,
			   IPAddress,
			   RSN,
			   LangID,
			   User_ID,
			   ViewType,
			   API,
			   NUM
		FROM @tmpdeleted

		SELECT @LASTCOUNT=COUNT(*) FROM @tmpdeleted

		DELETE FROM @tmpdeleted

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 BEGIN
			ROLLBACK TRANSACTION
		END
		SET @LASTCOUNT = 0
	END CATCH

END


GO
