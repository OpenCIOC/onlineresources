SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_CIC_CanUpdatePub](
	@NUM varchar(8),
	@PB_ID int,
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
	Checked on: 04-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnVal int,
		@MemberID int,
		@CanSeeNonPublicPub bit,
		@LimitedView bit,
		@ViewPBID int,
		@RecordOwner char(3),
		@RT_ID int

SELECT @MemberID=MemberID, @CanSeeNonPublicPub=CanSeeNonPublicPub, @LimitedView=LimitedView, @ViewPBID=PB_ID
	FROM CIC_View vw
WHERE ViewType=@ViewType

SELECT	@RecordOwner=bt.RECORD_OWNER, @RT_ID=cbt.RECORD_TYPE
	FROM GBL_BaseTable bt
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
WHERE bt.NUM=@NUM

SELECT @returnVal = CASE
		/* User Is Inactive (Fail) */
		WHEN Inactive=1 THEN 0
		/* This is not the User's View or a View the can see (Fail) */
		WHEN @ViewType<>s.ViewType AND NOT EXISTS(SELECT * FROM CIC_View_Recurse WHERE ViewType=s.ViewType AND CanSee=@ViewType) THEN 0
		/* Limited View and not the User's View or Publication (Fail) */
		WHEN @LimitedView=1 AND (@ViewType<>s.ViewType OR @ViewPBID<>@PB_ID) THEN 0
		/* Record Is Not In View (Fail) */
		WHEN dbo.fn_CIC_RecordInView(@NUM,@ViewType,@LangID,0,@Today)<>1 THEN 0
		/* Record Does Not Belong to Member and Editing Pubs for Shared Record Not Allowed */
		WHEN (SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)<>@MemberID
			AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=@NUM AND ShareMemberID_Cache=@MemberID
				AND EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE shp.ProfileID=bts.ProfileID AND shp.CanUpdatePubs=1)
			) THEN 0
		/* User Cannot Update Publications (Fail) */
		WHEN CanUpdatePubs = 0 THEN 0
		/* Publication not available to this Member (Fail) */
		WHEN NOT EXISTS(SELECT * FROM CIC_Publication pb
			WHERE pb.PB_ID=@PB_ID
				AND (
					pb.MemberID=@MemberID
					OR (pb.MemberID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=pb.PB_ID AND pbi.MemberID=@MemberID))
				)
				AND (
					@LimitedView=1
					OR @CanSeeNonPublicPub=1
					OR (@CanSeeNonPublicPub=0 AND pb.NonPublic=0)
					OR (@CanSeeNonPublicPub IS NULL AND EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=pb.PB_ID))
				)
			) THEN 0
		/* Anything Else (Pass) */
		ELSE 1
		END
	FROM GBL_Users u
	INNER JOIN CIC_SecurityLevel s
		ON u.SL_ID_CIC = s.SL_ID
WHERE [User_ID] = @User_ID

RETURN @returnVal

END




GO
GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdatePub] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_CanUpdatePub] TO [cioc_login_role]
GO
