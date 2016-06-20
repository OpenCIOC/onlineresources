CREATE TABLE [dbo].[CIC_SecurityLevel_EditAgency]
(
[SL_ID] [int] NOT NULL,
[AgencyCode] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditAgency] ADD CONSTRAINT [CK_CIC_SecurityLevel_EditAgency] CHECK (([AgencyCode] like '[A-Z][A-Z][A-Z]'))
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditAgency] ADD CONSTRAINT [PK_CIC_SecurityLevel_EditAgency] PRIMARY KEY CLUSTERED  ([SL_ID], [AgencyCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditAgency] WITH NOCHECK ADD CONSTRAINT [FK_CIC_SecurityLevel_EditAgency_GBL_Agency] FOREIGN KEY ([AgencyCode]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditAgency] ADD CONSTRAINT [FK_CIC_SecurityLevel_EditAgency_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_EditAgency] NOCHECK CONSTRAINT [FK_CIC_SecurityLevel_EditAgency_GBL_Agency]
GO
