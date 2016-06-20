CREATE TABLE [dbo].[VOL_Opportunity]
(
[OP_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_Opportunity_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_Opportunity_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[VNUM_Agency] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[VNUM_Number] [int] NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[RECORD_OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DISPLAY_UNTIL] [smalldatetime] NULL,
[APPLICATION_DEADLINE] [smalldatetime] NULL,
[EMAIL_UPDATE_DATE] [smalldatetime] NULL,
[END_DATE] [smalldatetime] NULL,
[LIABILITY_INSURANCE] [bit] NULL,
[MINIMUM_HOURS] [decimal] (5, 2) NULL,
[MINIMUM_HOURS_PER] [int] NULL,
[MIN_AGE] [decimal] (5, 2) NULL,
[MAX_AGE] [decimal] (5, 2) NULL,
[NO_UPDATE_EMAIL] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_NO_UPDATE_EMAIL] DEFAULT ((0)),
[NUM_NEEDED_TOTAL] [smallint] NULL,
[OSSD] [bit] NULL,
[POLICE_CHECK] [bit] NULL,
[REQUEST_DATE] [smalldatetime] NULL,
[SCH_M_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_M_Morning] DEFAULT ((0)),
[SCH_M_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_M_Afternoon] DEFAULT ((0)),
[SCH_M_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_M_Evening] DEFAULT ((0)),
[SCH_TU_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_T_Morning] DEFAULT ((0)),
[SCH_TU_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_T_Afternoon] DEFAULT ((0)),
[SCH_TU_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_T_Evening] DEFAULT ((0)),
[SCH_W_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_W_Morning] DEFAULT ((0)),
[SCH_W_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_W_Afternoon] DEFAULT ((0)),
[SCH_W_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_W_Evening] DEFAULT ((0)),
[SCH_TH_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_TH_Morning] DEFAULT ((0)),
[SCH_TH_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_TH_Afternoon] DEFAULT ((0)),
[SCH_TH_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_TH_Evening] DEFAULT ((0)),
[SCH_F_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_F_Morning] DEFAULT ((0)),
[SCH_F_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_F_Afternoon] DEFAULT ((0)),
[SCH_F_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_F_Evening] DEFAULT ((0)),
[SCH_ST_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_ST_Morning] DEFAULT ((0)),
[SCH_ST_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_ST_Afternoon] DEFAULT ((0)),
[SCH_ST_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_ST_Evening] DEFAULT ((0)),
[SCH_SN_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_SN_Morning] DEFAULT ((0)),
[SCH_SN_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_SN_Afternoon] DEFAULT ((0)),
[SCH_SN_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_SCH_SN_Evening] DEFAULT ((0)),
[START_DATE_FIRST] [smalldatetime] NULL,
[START_DATE_LAST] [smalldatetime] NULL,
[UPDATE_EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[FBKEY] [char] (6) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_VOL_Opportunity_FBKEY] DEFAULT (CONVERT([varchar](MAX),[Crypt_Gen_Random]((3)),(2)))
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_MemberIDVNUMDISPLAYUNTIL] ON [dbo].[VOL_Opportunity] ([MemberID], [VNUM], [DISPLAY_UNTIL]) ON [PRIMARY]



ALTER TABLE [dbo].[VOL_Opportunity] ADD 
CONSTRAINT [PK_VOL_Opportunity] PRIMARY KEY CLUSTERED  ([VNUM]) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_VNUMInclMemberID] ON [dbo].[VOL_Opportunity] ([VNUM]) INCLUDE ([MemberID]) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_OP_ID] ON [dbo].[VOL_Opportunity] ([OP_ID]) ON [PRIMARY]

GO
CREATE TRIGGER [dbo].[tr_VOL_Opportunity_iu] ON [dbo].[VOL_Opportunity]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 25-Sep-2014
	Action:	NO ACTION REQUIRED
*/

IF UPDATE (MODIFIED_DATE) BEGIN
	UPDATE vod
		SET	MODIFIED_DATE=i.MODIFIED_DATE,
			MODIFIED_BY=i.MODIFIED_BY
	FROM VOL_Opportunity_Description vod
	INNER JOIN Inserted i
		ON vod.VNUM=i.VNUM
	WHERE vod.MODIFIED_DATE < i.MODIFIED_DATE
END

IF UPDATE (VNUM) BEGIN
	UPDATE vo
		SET VNUM_Agency=SUBSTRING(vo.VNUM,3,3),
			VNUM_Number=CAST(RIGHT(vo.VNUM,LEN(vo.VNUM)-5) AS int)
	FROM VOL_Opportunity vo
	LEFT JOIN Inserted i
		ON vo.VNUM=i.VNUM
	WHERE i.VNUM IS NOT NULL OR vo.VNUM_Agency IS NULL OR vo.VNUM_Number IS NULL
END

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[VOL_Opportunity] ADD CONSTRAINT [FK_VOL_Opportunity_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Opportunity] ADD CONSTRAINT [FK_VOL_Opportunity_VOL_MinHoursPer] FOREIGN KEY ([MINIMUM_HOURS_PER]) REFERENCES [dbo].[VOL_MinHoursPer] ([HPER_ID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[VOL_Opportunity] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Opportunity_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Opportunity] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Opportunity_GBL_Agency] FOREIGN KEY ([RECORD_OWNER]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[VOL_Opportunity] NOCHECK CONSTRAINT [FK_VOL_Opportunity_GBL_Agency]
GO
GRANT SELECT ON  [dbo].[VOL_Opportunity] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[VOL_Opportunity] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Opportunity] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Opportunity] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Opportunity] TO [cioc_vol_search_role]
GO
