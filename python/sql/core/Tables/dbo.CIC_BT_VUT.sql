CREATE TABLE [dbo].[CIC_BT_VUT]
(
[BT_VUT_ID] [int] NOT NULL IDENTITY(1, 1),
[GUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CIC_BT_VUT_GUID] DEFAULT (newid()),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[VUT_ID] [int] NOT NULL,
[Capacity] [smallint] NOT NULL,
[FundedCapacity] [smallint] NULL,
[Vacancy] [smallint] NULL,
[HoursPerDay] [decimal] (6, 1) NULL,
[DaysPerWeek] [decimal] (6, 1) NULL,
[WeeksPerYear] [decimal] (6, 1) NULL,
[FullTimeEquivalent] [decimal] (6, 1) NULL,
[WaitList] [bit] NULL,
[WaitListDate] [smalldatetime] NULL,
[MODIFIED_DATE] [smalldatetime] NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_VUT] ON [dbo].[CIC_BT_VUT] ([BT_VUT_ID], [GUID], [NUM]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [CK_CIC_BT_VUT_Capacity] CHECK (([Capacity]>=(0)))
GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [CK_CIC_BT_VUT_Vacancy] CHECK (([Vacancy] IS NULL OR [Vacancy]>=(0)))
GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [CK_CIC_BT_VUT_WaitList] CHECK (([WaitListDate] IS NULL OR [WaitList]=(1)))
GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [PK_CIC_BT_VUT] PRIMARY KEY CLUSTERED  ([BT_VUT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [FK_CIC_BT_VUT_CIC_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CIC_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_VUT] ADD CONSTRAINT [FK_CIC_BT_VUT_CIC_Vacancy_UnitType] FOREIGN KEY ([VUT_ID]) REFERENCES [dbo].[CIC_Vacancy_UnitType] ([VUT_ID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_VUT] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_VUT] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_VUT] TO [cioc_login_role]
GO
