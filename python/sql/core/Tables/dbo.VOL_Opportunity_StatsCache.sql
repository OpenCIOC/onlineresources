CREATE TABLE [dbo].[VOL_Opportunity_StatsCache]
(
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MemberID] [int] NOT NULL,
[CMP_USAGE_COUNT_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_VOL_Opportunity_StatsCache_CMP_USAGE_COUNT_DATE] DEFAULT (getdate()),
[CMP_USAGE_COUNT] [int] NOT NULL CONSTRAINT [DF_VOL_Opportunity_StatsCache_CMP_USAGE_COUNT] DEFAULT ((0)),
[CMP_USAGE_COUNT_P] [int] NOT NULL CONSTRAINT [DF_VOL_Opportunity_StatsCache_CMP_USAGE_COUNT_P] DEFAULT ((0)),
[CMP_USAGE_COUNT_S] [int] NOT NULL CONSTRAINT [DF_VOL_Opportunity_StatsCache_CMP_USAGE_COUNT_S] DEFAULT ((0))
) ON [PRIMARY]
ALTER TABLE [dbo].[VOL_Opportunity_StatsCache] ADD 
CONSTRAINT [PK_VOL_Opportunity_StatsCache] PRIMARY KEY CLUSTERED  ([VNUM], [MemberID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VOL_Opportunity_StatsCache] ADD CONSTRAINT [FK_VOL_Opportunity_StatsCache_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Opportunity_StatsCache] ADD CONSTRAINT [FK_VOL_Opportunity_StatsCache_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
