SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetGHIDs_Copy]
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@User_ID int,
	@ViewType int,
	@IdList varchar(max),
	@PB_ID int,
	@SynchPBID int,
	@RecordsAffected int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 09-Oct-2013
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @tmpGHIDs TABLE(
	GH_ID int NOT NULL PRIMARY KEY,
	CopyGHID int NOT NULL
)

DECLARE @tmpNUMs TABLE(
	NUM varchar(8) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY 
)

IF NOT EXISTS(SELECT * FROM CIC_Publication WHERE (MemberID=@MemberID OR MemberID IS NULL) AND PB_ID=@PB_ID) BEGIN
	SET @PB_ID = NULL
END
IF NOT EXISTS(SELECT * FROM CIC_Publication WHERE (MemberID=@MemberID OR MemberID IS NULL) AND PB_ID=@SynchPBID) BEGIN
	SET @SynchPBID = NULL
END

IF @PB_ID IS NOT NULL AND @SynchPBID IS NOT NULL BEGIN

	INSERT INTO @tmpGHIDs
		SELECT DISTINCT gh.GH_ID, gh2.GH_ID
		FROM CIC_Publication pb
		INNER JOIN CIC_GeneralHeading gh
			ON pb.PB_ID=gh.PB_ID
		INNER JOIN CIC_GeneralHeading_Name ghn
			ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY LangID)
		INNER JOIN CIC_GeneralHeading_Name ghn2
			ON ghn.Name=ghn2.Name AND ghn.LangID=ghn2.LangID
		INNER JOIN CIC_GeneralHeading gh2
			ON ghn2.GH_ID=gh2.GH_ID AND gh2.PB_ID=@PB_ID AND gh2.Used=1
		WHERE pb.PB_ID=@SynchPBID
			AND gh.Used=1

	INSERT INTO @tmpNUMs
		SELECT DISTINCT tm.ItemID
		FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
			INNER JOIN CIC_BT_PB pb
				ON tm.ItemID=pb.NUM COLLATE Latin1_General_100_CI_AI
			INNER JOIN CIC_BT_PB pb2
				ON pb.NUM=pb2.NUM
		WHERE pb.PB_ID=@PB_ID
			AND pb2.PB_ID=@SynchPBID
			AND dbo.fn_CIC_CanUpdatePub(pb.NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1

	DELETE @tmpNUMs 
		FROM @tmpNUMs tm
		WHERE NOT (
			EXISTS(SELECT *
				FROM CIC_BT_PB_GH gh
				INNER JOIN @tmpGHIDs tmg
					ON gh.GH_ID=tmg.GH_ID
				WHERE tm.NUM=gh.NUM_Cache
					AND NOT EXISTS(SELECT *
					FROM CIC_BT_PB_GH gh2
					WHERE gh2.NUM_Cache=tm.NUM
						AND gh2.GH_ID=tmg.CopyGHID)
			)
			OR
			EXISTS(SELECT *
				FROM CIC_BT_PB_GH gh
				INNER JOIN @tmpGHIDs tmg
					ON gh.GH_ID=tmg.CopyGHID
				WHERE tm.NUM=gh.NUM_Cache
					AND NOT EXISTS(SELECT *
					FROM CIC_BT_PB_GH gh2
					WHERE gh2.NUM_Cache=tm.NUM
						AND gh2.GH_ID=tmg.GH_ID)
			)
		)

	DELETE gh
		FROM CIC_BT_PB_GH gh
		INNER JOIN @tmpNUMs tm
			ON gh.NUM_Cache=tm.NUM
		INNER JOIN @tmpGHIDs tmg
			ON gh.GH_ID=CopyGHID
		WHERE NOT EXISTS(SELECT *
			FROM CIC_BT_PB pb2
			INNER JOIN CIC_BT_PB_GH gh2
				ON pb2.BT_PB_ID=gh2.BT_PB_ID
			WHERE pb2.NUM=tm.NUM
				AND pb2.PB_ID=@SynchPBID
				AND gh2.GH_ID=tmg.GH_ID)

	INSERT INTO CIC_BT_PB_GH (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			BT_PB_ID,
			GH_ID,
			NUM_Cache
		) SELECT
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			pb.BT_PB_ID,
			tmg.CopyGHID,
			tm.NUM
		FROM @tmpNUMs tm
		INNER JOIN CIC_BT_PB pb
			ON tm.NUM=pb.NUM
		INNER JOIN CIC_BT_PB pb2
			ON tm.NUM=pb2.NUM
		INNER JOIN CIC_BT_PB_GH gh2
			ON pb2.BT_PB_ID=gh2.BT_PB_ID
		INNER JOIN @tmpGHIDs tmg
			ON gh2.GH_ID=tmg.GH_ID
		WHERE pb.PB_ID=@PB_ID
			AND pb2.PB_ID=@SynchPBID
			AND NOT EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE BT_PB_ID=pb.BT_PB_ID AND GH_ID=tmg.CopyGHID)

	SELECT @RecordsAffected = COUNT(*) FROM @tmpNUMs
END ELSE BEGIN
	SET @RecordsAffected = 0
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetGHIDs_Copy] TO [cioc_login_role]
GO
