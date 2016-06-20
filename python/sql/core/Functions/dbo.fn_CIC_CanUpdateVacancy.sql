SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_CanUpdateVacancy](
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
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 22-Apr-2015
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
			s.VacancyEditByViewList=0
			OR (s.VacancyEditByViewList IS NULL AND s.ViewType=@ViewType)
			OR (s.VacancyEditByViewList=1 AND @ViewType IN (SELECT ViewType FROM CIC_SecurityLevel_VacancyEditView WHERE SL_ID=s.SL_ID))
			) THEN 0
		/* Record does not belong to Member (Fail) */
		WHEN @RecordMemberID<>@MemberID THEN 0
		/* User is SuperUser (Pass) */
		WHEN SuperUser=1 THEN 1
		/* User can update any in View (Pass) or User can update records by given Agency */
		WHEN CanEditVacancy=2
			OR (CanEditVacancy=1 AND u.Agency=@RecordOwner)
			OR (CanEditVacancy=3 AND @RecordOwner IN (SELECT AgencyCode FROM CIC_SecurityLevel_VacancyEditAgency WHERE SL_ID=s.SL_ID))
			THEN 1
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
GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdateVacancy] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdateVacancy] TO [cioc_login_role]
GO
