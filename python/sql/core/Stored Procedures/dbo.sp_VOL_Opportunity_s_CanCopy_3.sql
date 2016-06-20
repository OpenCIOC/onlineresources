SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_s_CanCopy_3]
	@VNUM varchar(10),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM VOL_View
WHERE ViewType=@ViewType

DECLARE @SQLSelect nvarchar(max)		

SELECT	@SQLSelect = COALESCE(@SQLSelect + ', ','') + dbo.fn_VOL_FieldOption_Display(
			NULL,
			@ViewType,
			fo.FieldID,
			fo.FieldName,
			CASE WHEN NOT EXISTS(SELECT * FROM VOL_OP_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
			fo.DisplayFM,
			fo.FormFieldType,
			fo.EquivalentSource,
			fod.CheckboxOnText,
			fod.CheckboxOffText,
			1
		)
		FROM VOL_FieldOption fo
		LEFT JOIN VOL_FieldOption_Description fod
			ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
		WHERE	(CanUseUpdate = 1)
				AND FieldName NOT IN ('NUM','RECORD_OWNER','NON_PUBLIC','POSITION_TITLE')
				AND EXISTS(SELECT * FROM VOL_View_UpdateField uf
					WHERE (uf.ViewType = @ViewType)	AND fo.FieldID = uf.FieldID
)

IF @SQLSelect IS NOT NULL BEGIN
	EXEC ('SELECT ' + @SQLSelect + ' FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM
		AND vod.LangID=@@LANGID
	WHERE vo.VNUM=''' + @VNUM + '''')
END ELSE BEGIN
	SELECT VNUM FROM VOL_Opportunity WHERE 0=1
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_s_CanCopy_3] TO [cioc_login_role]
GO
