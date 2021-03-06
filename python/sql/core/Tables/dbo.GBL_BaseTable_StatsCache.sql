CREATE TABLE [dbo].[GBL_BaseTable_StatsCache]
(
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MemberID] [int] NOT NULL,
[CMP_USAGE_COUNT_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_BaseTable_StatsCache_CMP_USAGE_COUNT_DATE] DEFAULT (getdate()),
[CMP_USAGE_COUNT] [int] NOT NULL CONSTRAINT [DF_GBL_BaseTable_StatsCache_CMP_USAGE_COUNT] DEFAULT ((0)),
[CMP_USAGE_COUNT_P] [int] NOT NULL CONSTRAINT [DF_GBL_BaseTable_StatsCache_CMP_USAGE_COUNT_P] DEFAULT ((0)),
[CMP_USAGE_COUNT_S] [int] NOT NULL CONSTRAINT [DF_GBL_BaseTable_StatsCache_CMP_USAGE_COUNT_S] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BaseTable_StatsCache] ADD CONSTRAINT [PK_GBL_BaseTable_StatsCache] PRIMARY KEY CLUSTERED  ([NUM], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BaseTable_StatsCache] ADD CONSTRAINT [FK_GBL_BaseTable_StatsCache_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
