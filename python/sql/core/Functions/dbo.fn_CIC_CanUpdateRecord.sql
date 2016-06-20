
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_CanUpdateRecord](
	@NUM varchar(8),
	@User_ID int,
	@ViewType int,
	@LangID smallint,
	@Today smalldatetime
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 07-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnVal int,
		@MemberID int,
		@RecordMemberID int,
		@RecordOwner char(3),
		@RT_ID int

SELECT @MemberID=MemberID
	FROM CIC_View vw
WHERE ViewType=@ViewType

SELECT	@RecordOwner=bt.RECORD_OWNER, @RT_ID=cbt.RECORD_TYPE, @RecordMemberID=bt.MemberID
	FROM GBL_BaseTable bt
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
WHERE bt.NUM=@NUM

SELECT @returnVal = CASE
		/* User is Inactive (Fail) */
		WHEN Inactive=1 THEN 0
		/* Record is not in Current View (Fail) */
		WHEN dbo.fn_CIC_RecordInView(@NUM,@ViewType,@LangID,0,@Today)<>1 THEN 0
		/* Current View is not an Editorial View (Fail) */
		WHEN NOT (
			s.EditByViewList=0
			OR (s.EditByViewList IS NULL AND s.ViewType=@ViewType)
			OR (s.EditByViewList=1 AND @ViewType IN (SELECT ViewType FROM CIC_SecurityLevel_EditView WHERE SL_ID=s.SL_ID))
			) THEN 0
		/* Record does not belong to Member and editing Shared Record not allowed (Fail) */
		WHEN @RecordMemberID<>@MemberID
			AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
				AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanUpdateRecords=1)
			) THEN 0
		/* Not allowed to edit this language */
		WHEN @RecordMemberID<>@MemberID
			AND EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
					AND (
						EXISTS(SELECT * FROM dbo.GBL_SharingProfile_EditLang el WHERE el.ProfileID=bts.ProfileID)
						AND NOT EXISTS(SELECT * FROM dbo.GBL_SharingProfile_EditLang el WHERE el.ProfileID=bts.ProfileID AND el.LangID=@LangID)
					)
			) THEN -2
		/* User is SuperUser (Pass) */
		WHEN SuperUser=1 THEN 1
		/* User can update any in View (Pass) or User can update records by given Agency */
		WHEN CanEditRecord=2
			OR (CanEditRecord=1 AND u.Agency=@RecordOwner)
			OR (CanEditRecord=3 AND @RecordOwner IN (SELECT AgencyCode FROM CIC_SecurityLevel_EditAgency WHERE SL_ID=s.SL_ID))
			THEN CASE
				/* Not allowed to edit this language */
				WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=s.SL_ID)
					AND NOT EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=s.SL_ID AND RT_ID=@RT_ID) THEN -1
				/* Not allowed to edit this record type */
				WHEN EXISTS(SELECT * FROM dbo.CIC_SecurityLevel_EditLang el WHERE el.SL_ID=s.SL_ID)
					AND NOT EXISTS(SELECT * FROM dbo.CIC_SecurityLevel_EditLang el WHERE el.SL_ID=s.SL_ID AND el.LangID=@LangID)
					THEN -2
				ELSE 1
			END
		/* Anything Else (Fail) */
		ELSE 0
		END
	FROM GBL_Users u
	INNER JOIN CIC_SecurityLevel s
		ON u.SL_ID_CIC = s.SL_ID
WHERE [User_ID] = @User_ID

IF @returnVal IS NULL SET @returnVal = 0

RETURN @returnVal

END





GO

GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdateRecord] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdateRecord] TO [cioc_login_role]
GO
