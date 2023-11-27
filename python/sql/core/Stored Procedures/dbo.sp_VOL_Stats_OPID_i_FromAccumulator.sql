SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Stats_OPID_i_FromAccumulator]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 11-Mar-2014
	Action: TESTING REQUIRED
*/


DECLARE @tmpdeleted TABLE (
	[MemberID] [int] NOT NULL,
	[AccessDate] [datetime] NOT NULL,
	[IPAddress] [varchar](20) COLLATE Latin1_General_100_CI_AI NULL,
	[OP_ID] [int] NULL,
	[LangID] [smallint] NOT NULL,
	[User_ID] [int] NULL,
	[ViewType] [int] NULL,
	[API] [bit] NOT NULL,
	[VNUM] [varchar](10) COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @LASTCOUNT int
SET @LASTCOUNT = 10000

WHILE @LASTCOUNT = 10000 BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		DELETE TOP (10000) FROM dbo.VOL_Stats_OPID_Accumulator
		OUTPUT Deleted.MemberID,
			   Deleted.AccessDate,
			   Deleted.IPAddress,
			   Deleted.OP_ID,
			   Deleted.LangID,
			   Deleted.User_ID,
			   Deleted.ViewType,
			   Deleted.API,
			   Deleted.VNUM
		INTO @tmpdeleted

		INSERT INTO dbo.VOL_Stats_OPID
				(MemberID,
				 AccessDate,
				 IPAddress,
				 OP_ID,
				 LangID,
				 User_ID,
				 ViewType,
				 API,
				 VNUM
				)
		SELECT MemberID,
			   AccessDate,
			   IPAddress,
			   OP_ID,
			   LangID,
			   User_ID,
			   ViewType,
			   API,
			   VNUM
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
