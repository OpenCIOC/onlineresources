CREATE TABLE [dbo].[CIC_GeneralHeading_Group]
(
[GroupID] [int] NOT NULL IDENTITY(1, 1),
[PB_ID] [int] NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_GeneralHeading_Group_DisplayOrder] DEFAULT ((0)),
[IconNameFull] [varchar] (65) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Group] ADD CONSTRAINT [PK_CIC_GeneralHeading_Group] PRIMARY KEY CLUSTERED  ([GroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_GeneralHeading_Group] ADD CONSTRAINT [FK_CIC_GeneralHeading_Group_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID])
GO
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Group] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_GeneralHeading_Group] TO [cioc_login_role]
GO
