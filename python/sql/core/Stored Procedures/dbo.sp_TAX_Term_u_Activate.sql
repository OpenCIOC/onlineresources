SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_TAX_Term_u_Activate]
	@Code [varchar](21),
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Active bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@TermObjectName nvarchar(100),
		@MemberObjectName nvarchar(100),
		@CodeObjectName nvarchar(100)

SET @TermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Term')
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')
SET @CodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Code')

/* Identify errors that will prevent the record from being updated */
IF @Code IS NULL BEGIN
	SET @Error = 4
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TermObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM TAX_Term WHERE Code = @Code) BEGIN
	SET @Error = 3 -- no record with ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @TermObjectName)
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- no record with ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
/* Term cannot be activated */
END ELSE IF @Active=1 AND (
		(
			@MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Code=@Code AND tm.Active=1)
		)
		OR (
			@MemberID IS NULL
			AND NOT EXISTS(SELECT * FROM TAX_Term tm
				WHERE tm.Code=@Code
					AND tm.CdLvl > 1
					AND (
						EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND Active=1)
						OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND Active=1)
						OR (
							NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1) 
							AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
						)
					)
				)
			)
		) BEGIN
	SET @Error = 22
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Active'), @TermObjectName)
/* Term cannot be deactivated */
END ELSE IF @Active=0 AND (
		(
			@MemberID IS NOT NULL
			AND EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN CIC_BT_TAX tl
							ON tlt.BT_TAX_ID=tl.BT_TAX_ID
						INNER JOIN GBL_BaseTable bt
							ON tl.NUM=bt.NUM
								AND (bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID))
					WHERE Code=@Code)
		)
		OR (
			@MemberID IS NULL
			AND EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=@Code)
				OR NOT EXISTS(SELECT * FROM TAX_Term tm
					WHERE (
						tm.CdLvl = 6
						OR NOT EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code)
						OR EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND NOT Active=1)
						OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND NOT Active=1)
					)
				)
			)
		) BEGIN
	SET @Error = 22
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Active'), @TermObjectName)
/* Term cannot be Rolled-up */
END ELSE IF @Active IS NULL AND (
		@MemberID IS NOT NULL
		OR NOT EXISTS(SELECT * FROM TAX_Term tm
			WHERE tm.Code=@Code
				AND (
					NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
					AND EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
					AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1)
				)
			)
		) BEGIN
	SET @Error = 22
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Roll-up Term'), @TermObjectName)
/* No problems exists that will prevent the addtion / updating of this record, so insert / update the entry */
END ELSE BEGIN
	/* Update activation */
	IF @MemberID IS NULL BEGIN
		UPDATE TAX_Term SET
			Active			= @Active,
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
		WHERE Code=@Code
	END ELSE BEGIN
		IF @Active=0 BEGIN
			DELETE FROM TAX_Term_ActivationByMember WHERE MemberID=@MemberID AND Code=@Code 
		END ELSE BEGIN
			INSERT INTO TAX_Term_ActivationByMember (MemberID, Code)
				SELECT @MemberID, @Code
				WHERE NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE MemberID=@MemberID AND Code=@Code)
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

SELECT * FROM dbo.fn_TAX_Term_Activation_rst(@MemberID,@Code,0)
UNION SELECT * FROM dbo.fn_TAX_Term_Activation_rst(@MemberID,(SELECT ParentCode FROM TAX_Term WHERE Code=@Code),0)
UNION SELECT * FROM dbo.fn_TAX_Term_Activation_rst(@MemberID,@Code,1)
ORDER BY Code

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_u_Activate] TO [cioc_login_role]
GO
