SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_TAX_Term_ActivationFix]
	@MemberID int,
	@MODIFIED_BY varchar(50),
	@InactivateUnused bit,
	@IncludeShared bit,
	@RollupLowLevelTerms bit,
	@ExcludeYBranch bit,
	@RecommendActivations bit,
	@ExecuteChanges bit,
	@InactivateRollupIDList varchar(max),
	@RecommendActivationIDList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 05-Jun-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @GlobalActivation TABLE (
	Code varchar(21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	PreferredTerm bit NOT NULL DEFAULT(0),
	NewActivation int NULL
)

DECLARE @LocalActivation TABLE (
	Code varchar(21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	PreferredTerm bit NOT NULL DEFAULT(0),
	NewActivation bit NOT NULL
)

DECLARE @RecommendActivation TABLE (
	Code varchar(21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	PreferredTerm bit NOT NULL DEFAULT(0)
)

/* Fix Global activations for used Terms */
INSERT INTO @GlobalActivation (Code, PreferredTerm, NewActivation)
SELECT tm.Code, tm.PreferredTerm, 1
	FROM TAX_Term tm
WHERE (tm.Active=0 OR tm.Active IS NULL)
	AND EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.Code=tm.Code)

/* Fix local activations for locally-used Terms */
IF @MemberID IS NOT NULL BEGIN
	INSERT INTO @LocalActivation(Code, PreferredTerm, NewActivation)
	SELECT DISTINCT tlt.Code, tm.PreferredTerm, 1
		FROM GBL_BaseTable bt
		INNER JOIN CIC_BT_TAX tl
			ON bt.NUM=tl.NUM
		INNER JOIN CIC_BT_TAX_TM tlt
			ON tl.BT_TAX_ID=tlt.BT_TAX_ID
		INNER JOIN TAX_Term tm
			ON tlt.Code=tm.Code
		WHERE (
				bt.MemberID=@MemberID
				OR (@IncludeShared=1 AND EXISTS(SELECT *
						FROM GBL_BT_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
						WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
			)
			AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE MemberID=@MemberID AND Code=tlt.Code)
END

/* Inactivate unused branch portions where other parts of the branch are used */
IF @InactivateUnused=1 BEGIN
	/* Global activation */
	IF @MemberID IS NULL BEGIN

		/* Inactivate higher-level terms not in use */
		MERGE INTO @GlobalActivation ga
		USING (
				SELECT tm.Code, tm.PreferredTerm, 0 AS NewActivation
					FROM TAX_Term tm
				WHERE tm.Active=1
					AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.Code=tm.Code)
					AND EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.Code
								AND tmpl.ParentCode=tm.Code
						)
					AND NOT EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.ParentCode
								AND tmpl.Code=tm.Code
						)
					AND (@ExcludeYBranch=0 OR tm.CdLvl1<>'Y')
				) nt
			ON nt.Code=ga.Code
		WHEN MATCHED AND (ga.NewActivation<>nt.NewActivation OR ga.NewActivation IS NULL)
			THEN UPDATE SET ga.NewActivation=nt.NewActivation
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (Code, PreferredTerm, NewActivation)
				VALUES (nt.Code, nt.PreferredTerm, nt.NewActivation)
			;
		
		/* Roll-up or inactivate lower-level terms not in use */
		MERGE INTO @GlobalActivation ga
		USING (
				SELECT tm.Code, tm.PreferredTerm, CASE WHEN @RollupLowLevelTerms=1 THEN NULL ELSE 0 END AS NewActivation
					FROM TAX_Term tm
				WHERE tm.Active=1
					AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM tlt WHERE tlt.Code=tm.Code)
					AND EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.ParentCode
								AND tmpl.Code=tm.Code
						)
					AND NOT EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.Code
								AND tmpl.ParentCode=tm.Code
						)
					AND (@ExcludeYBranch=0 OR tm.CdLvl1<>'Y')
				) nt
			ON nt.Code=ga.Code
		WHEN MATCHED AND (nt.NewActivation<>ga.NewActivation OR (nt.NewActivation IS NULL AND ga.NewActivation IS NOT NULL) OR (nt.NewActivation IS NOT NULL AND ga.NewActivation IS NULL))
			THEN UPDATE SET ga.NewActivation=nt.NewActivation
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (Code, PreferredTerm, NewActivation)
				VALUES (nt.Code, nt.PreferredTerm, nt.NewActivation)
			;

	/* Local activation */
	END ELSE BEGIN
		MERGE INTO @LocalActivation la
		USING (
			SELECT tac.Code, tm.PreferredTerm, 0 AS NewActivation
				FROM TAX_Term_ActivationByMember tac
				INNER JOIN TAX_Term tm
					ON tac.Code=tm.Code
			WHERE tac.MemberID=@MemberID
				AND (@ExcludeYBranch=0 OR tm.CdLvl1<>'Y')
				AND NOT EXISTS(SELECT *
					FROM GBL_BaseTable bt
					INNER JOIN CIC_BT_TAX tl
						ON bt.NUM=tl.NUM
					INNER JOIN CIC_BT_TAX_TM tlt
						ON tl.BT_TAX_ID=tlt.BT_TAX_ID AND tlt.Code=tac.Code
					WHERE (
							bt.MemberID=@MemberID
							OR (@IncludeShared=1 AND EXISTS(SELECT *
									FROM GBL_BT_SharingProfile pr
									INNER JOIN GBL_SharingProfile shp
										ON pr.ProfileID=shp.ProfileID
											AND shp.Active=1
									WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
							)
						)
				)
				AND CASE WHEN EXISTS(SELECT *
						FROM GBL_BaseTable bt
						INNER JOIN CIC_BT_TAX tl
							ON bt.NUM=tl.NUM
						INNER JOIN CIC_BT_TAX_TM tlt
							ON tl.BT_TAX_ID=tlt.BT_TAX_ID
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.Code
								AND tmpl.ParentCode=tm.Code
						WHERE (
								bt.MemberID=@MemberID
								OR (@IncludeShared=1 AND EXISTS(SELECT *
										FROM GBL_BT_SharingProfile pr
										INNER JOIN GBL_SharingProfile shp
											ON pr.ProfileID=shp.ProfileID
												AND shp.Active=1
										WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
								)
							)
						) THEN 1 ELSE 0 END
					+ CASE WHEN EXISTS(SELECT *
						FROM GBL_BaseTable bt
						INNER JOIN CIC_BT_TAX tl
							ON bt.NUM=tl.NUM
						INNER JOIN CIC_BT_TAX_TM tlt
							ON tl.BT_TAX_ID=tlt.BT_TAX_ID
						INNER JOIN TAX_Term_ParentList tmpl
							ON tlt.Code=tmpl.ParentCode
								AND tmpl.Code=tm.Code
						WHERE (
								bt.MemberID=@MemberID
								OR (@IncludeShared=1 AND EXISTS(SELECT *
										FROM GBL_BT_SharingProfile pr
										INNER JOIN GBL_SharingProfile shp
											ON pr.ProfileID=shp.ProfileID
												AND shp.Active=1
										WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
								)
							)
						) THEN 1 ELSE 0 END
					= 1
				) nt
			ON nt.Code=la.Code
		WHEN MATCHED AND (nt.NewActivation<>la.NewActivation)
			THEN UPDATE SET la.NewActivation=nt.NewActivation
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (Code, PreferredTerm, NewActivation)
				VALUES (nt.Code, nt.PreferredTerm, nt.NewActivation)
			;
	END
END

/* Fix Global "Window" problem */
MERGE INTO @GlobalActivation ga
USING (SELECT tm.Code, tm.PreferredTerm, 1 AS NewActivation
			FROM TAX_Term tm
		WHERE (tm.Active=0 OR tm.Active IS NULL)
			/* There is a higher-level active Term */
			AND EXISTS(SELECT *
					FROM TAX_Term tmx
				WHERE (tmx.Active=1 OR EXISTS(SELECT * FROM @GlobalActivation ga2 WHERE ga2.Code=tmx.Code AND ga2.NewActivation=1))
					AND NOT EXISTS(SELECT * FROM @GlobalActivation ga2 WHERE ga2.Code=tmx.Code AND (ga2.NewActivation=0 OR ga2.NewActivation IS NULL))
					AND tmx.Code IN (SELECT ParentCode FROM TAX_Term_ParentList WHERE Code=tm.Code))
			/* There is a lower-level active Term */
			AND EXISTS(SELECT *
					FROM TAX_Term tmx
				WHERE (tmx.Active=1 OR EXISTS(SELECT * FROM @GlobalActivation ga2 WHERE ga2.Code=tmx.Code AND ga2.NewActivation=1))
					AND NOT EXISTS(SELECT * FROM @GlobalActivation ga2 WHERE ga2.Code=tmx.Code AND (ga2.NewActivation=0 OR ga2.NewActivation IS NULL))
					AND tmx.Code IN (SELECT Code FROM TAX_Term_ParentList WHERE ParentCode=tm.Code))
		) nt
	ON nt.Code=ga.Code
WHEN MATCHED AND (ga.NewActivation<>nt.NewActivation OR ga.NewActivation IS NULL)
	THEN UPDATE SET ga.NewActivation = nt.NewActivation
WHEN NOT MATCHED BY TARGET
	THEN INSERT (Code, PreferredTerm, NewActivation)
		VALUES (nt.Code, nt.PreferredTerm, nt.NewActivation)
	;

/* Remove local activations for Globally-inactive Terms */
IF @MemberID IS NOT NULL BEGIN
	MERGE INTO @LocalActivation la
	USING (SELECT tac.Code, tm.PreferredTerm, 0 AS NewActivation
				FROM TAX_Term_ActivationByMember tac
				INNER JOIN TAX_Term tm
					ON tac.Code=tm.Code
			WHERE tac.MemberID=@MemberID
				AND (
					NOT EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Active=1 AND tm.Code=tac.Code)
					OR EXISTS(SELECT * FROM @GlobalActivation ga WHERE ga.Code=tac.Code AND (ga.NewActivation=0 OR ga.NewActivation IS NULL))
				)
				AND NOT EXISTS(SELECT * FROM @GlobalActivation ga WHERE ga.Code=tac.Code AND ga.NewActivation=1)
			) nt
		ON nt.Code=la.Code
	WHEN MATCHED AND la.NewActivation<>nt.NewActivation
		THEN UPDATE SET la.NewActivation=nt.NewActivation
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (Code, PreferredTerm, NewActivation)
			VALUES (nt.Code, nt.PreferredTerm, nt.NewActivation)
	;
END

/* Remove "changes" that aren't */
IF @MemberID IS NOT NULL BEGIN
	DELETE la
		FROM @LocalActivation la
	WHERE NewActivation=0
		AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=la.Code AND MemberID=@MemberID)

	DELETE la
		FROM @LocalActivation la
	WHERE NewActivation=1
		AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=la.Code AND MemberID=@MemberID)
END

DELETE ga
	FROM @GlobalActivation ga
	INNER JOIN TAX_Term tm
		ON ga.Code=tm.Code
			AND (tm.Active=ga.NewActivation OR (tm.Active IS NULL AND ga.NewActivation IS NULL))

/* Identify branches that have no activations at all */
IF @RecommendActivations=1 BEGIN
	IF @MemberID IS NULL BEGIN
		INSERT INTO @RecommendActivation (Code, PreferredTerm)
		SELECT tm.Code, tm.PreferredTerm
			FROM TAX_Term tm 
		WHERE (tm.Active=0 OR tm.Active IS NULL)
			AND tm.CdLvl > 2
			AND NOT EXISTS(SELECT * FROM @GlobalActivation ga WHERE (ga.Code LIKE tm.Code + '%' OR tm.Code LIKE ga.Code + '%'))
			AND NOT EXISTS(SELECT * FROM TAX_Term tmx WHERE tmx.Active=1 AND tmx.CdLvl1=tm.CdLvl1 AND tmx.CdLvl2=tm.CdLvl2 AND (tmx.Code LIKE tm.Code + '%' OR tm.Code LIKE tmx.Code + '%'))
	END ELSE BEGIN
		INSERT INTO @RecommendActivation (Code, PreferredTerm)
		SELECT tm.Code, tm.PreferredTerm
			FROM TAX_Term tm
			LEFT JOIN TAX_Term_ActivationByMember tac
				ON tm.Code=tac.Code AND tac.MemberID=@MemberID
		WHERE tac.Code IS NULL
			AND tm.Active=1
			AND tm.CdLvl>2
			AND NOT EXISTS(SELECT * FROM @LocalActivation la WHERE (la.Code LIKE tm.Code + '%' OR tm.Code LIKE la.Code + '%'))
			AND NOT EXISTS(SELECT * FROM TAX_Term tmx INNER JOIN TAX_Term_ActivationByMember tacx ON tacx.Code=tmx.Code AND tacx.MemberID=@MemberID WHERE tmx.CdLvl1=tm.CdLvl1 AND tmx.CdLvl2=tm.CdLvl2 AND (tmx.Code LIKE tm.Code + '%' OR tm.Code LIKE tmx.Code + '%'))
	END
END

/* Return list of proposed changes */
IF @ExecuteChanges=0 BEGIN
	SELECT ga.*, ISNULL(tmd.AltTerm,tmd.Term) AS Term
		FROM @GlobalActivation ga
		INNER JOIN TAX_Term_Description tmd
			ON ga.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tmd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	ORDER BY ga.NewActivation DESC, ga.Code

	IF @MemberID IS NOT NULL BEGIN
		SELECT la.*, ISNULL(tmd.AltTerm,tmd.Term) AS Term
			FROM @LocalActivation la
			INNER JOIN TAX_Term_Description tmd
				ON la.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tmd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		ORDER BY la.NewActivation DESC, la.Code
	END

	SELECT ra.*, ISNULL(tmd.AltTerm,tmd.Term) AS Term
		FROM @RecommendActivation ra
		INNER JOIN TAX_Term_Description tmd
			ON ra.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tmd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	ORDER BY ra.Code
END ELSE BEGIN
	/* Process Mandatory Activations */
	UPDATE tm
		SET Active=ga.NewActivation
	FROM TAX_Term tm
	INNER JOIN @GlobalActivation ga
		ON tm.Code=ga.Code
	WHERE ga.NewActivation=1
	
	IF @MemberID IS NOT NULL BEGIN
		INSERT INTO TAX_Term_ActivationByMember (Code, MemberID)
		SELECT Code, @MemberID
			FROM @LocalActivation la
		WHERE la.NewActivation=1
			AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=la.Code AND MemberID=@MemberID)
	END

	/* Process Recommended Deactivations */
	IF @InactivateUnused=1 BEGIN
		IF @MemberID IS NULL BEGIN
			DELETE ga
				FROM @GlobalActivation ga
			WHERE (ga.NewActivation=0 OR ga.NewActivation IS NULL)
				AND NOT EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@InactivateRollupIDList,',') conf WHERE conf.ItemID=ga.Code COLLATE Latin1_General_100_CI_AI)
				
			UPDATE tm
				SET Active=ga.NewActivation
			FROM TAX_Term tm
			INNER JOIN @GlobalActivation ga
				ON tm.Code=ga.Code
			WHERE ga.NewActivation<>1

			DELETE tac
				FROM TAX_Term_ActivationByMember tac
			WHERE NOT EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Code=tac.Code AND tm.Active=1)
		END ELSE BEGIN
			DELETE la
				FROM @LocalActivation la
			WHERE (la.NewActivation=0)
				AND NOT EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@InactivateRollupIDList,',') conf WHERE conf.ItemID=la.Code COLLATE Latin1_General_100_CI_AI)
				
			DELETE tac
				FROM TAX_Term_ActivationByMember tac
			WHERE tac.MemberID=@MemberID
				AND EXISTS(SELECT * FROM @LocalActivation la WHERE la.Code=tac.Code AND la.NewActivation=0)
		END
	END
	
	/* Process Recommended Activations */
	IF @RecommendActivations=1 BEGIN
		DELETE ra
			FROM @RecommendActivation ra
		WHERE NOT EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@RecommendActivationIDList,',') conf WHERE conf.ItemID=ra.Code COLLATE Latin1_General_100_CI_AI)
		
		IF @MemberID IS NULL BEGIN
			UPDATE tm
				SET Active=1
			FROM TAX_Term tm
			INNER JOIN @RecommendActivation ra
				ON tm.Code=ra.Code
		END ELSE BEGIN
			INSERT INTO TAX_Term_ActivationByMember (Code, MemberID)
			SELECT Code, @MemberID
				FROM @RecommendActivation ra
			WHERE NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember tac WHERE tac.Code=ra.Code AND tac.MemberID=@MemberID)
		END
	END
	
	/* Synchronize a local activation in one-member database */
	IF @MemberID IS NULL AND (SELECT COUNT(*) FROM STP_Member WHERE Active=1)=1 BEGIN
		DECLARE @TmpMemberID int
		SELECT TOP 1 @TmpMemberID=MemberID FROM STP_Member WHERE Active=1
		
		MERGE INTO TAX_Term_ActivationByMember tac
		USING (SELECT Code FROM TAX_Term WHERE Active=1) nt
			ON nt.Code=tac.Code AND tac.MemberID=@TmpMemberID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (Code, MemberID) VALUES (nt.Code, @TmpMemberID)
		WHEN NOT MATCHED BY SOURCE AND tac.MemberID=@TmpMemberID THEN
			DELETE
			;
	END
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_ActivationFix] TO [cioc_login_role]
GO
