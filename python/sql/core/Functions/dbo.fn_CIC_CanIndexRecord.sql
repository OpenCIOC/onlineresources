SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_CanIndexRecord](
	@NUM varchar(8),
	@User_ID int,
	@ViewType int,
	@LangID smallint,
	@Today smalldatetime
)
RETURNS bit WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 09-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnVal int,
		@MemberID int,
		@BTMemberID int,
		@RecordOwner char(3),
		@RT_ID int

SELECT	@BTMemberID=bt.MemberID, @RecordOwner=bt.RECORD_OWNER, @RT_ID=cbt.RECORD_TYPE
	FROM GBL_BaseTable bt
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
WHERE bt.NUM=@NUM

SELECT @MemberID=MemberID
	FROM CIC_View vw
WHERE ViewType=@ViewType

SELECT @returnVal = CASE
		/* This is not the User's View (Fail) */
		WHEN @ViewType <> s.ViewType THEN 0
		/* User Is Inactive (Fail) */
		WHEN Inactive=1 THEN 0
		/* Record Is Not In View (Fail) */
		WHEN dbo.fn_CIC_RecordInView(@NUM,@ViewType,@LangID,0,@Today)<>1 THEN 0
		/* Record Does Not Belong to Member
			or Editing Shared Record Not Allowed 
			or Taxonomy Field not Shared */
		WHEN @BTMemberID<>@MemberID
			AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
				AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanUpdateRecords=1)
				AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf INNER JOIN GBL_FieldOption fo ON shpf.FieldID=fo.FieldID AND fo.FieldName='TAXONOMY' WHERE shpf.ProfileID=bts.ProfileID)
			) THEN 0
		/* User Is SuperUser (Pass) */
		WHEN SuperUser=1 THEN 1
		/* User Can Update Any In View (Pass) Or User Can Update Records They Own */
		WHEN CanIndexTaxonomy=2 OR (CanIndexTaxonomy=1 AND Agency=@RecordOwner)
			THEN CASE
				WHEN NOT EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=s.SL_ID) THEN 1
				WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=s.SL_ID AND RT_ID=@RT_ID) THEN 1
				ELSE -1
			END
		/* Anything Else (Fail) */
		ELSE 0
		END
	FROM GBL_Users u
	INNER JOIN CIC_SecurityLevel s
		ON u.SL_ID_CIC = s.SL_ID
WHERE [User_ID] = @User_ID

RETURN ISNULL(@returnVal,0)

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_CanIndexRecord] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_CanIndexRecord] TO [cioc_login_role]
GO
