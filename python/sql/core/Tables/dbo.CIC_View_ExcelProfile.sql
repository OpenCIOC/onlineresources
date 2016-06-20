CREATE TABLE [dbo].[CIC_View_ExcelProfile]
(
[VT_PF_ID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[ProfileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ExcelProfile] ADD CONSTRAINT [PK_CIC_View_ExcelProfile] PRIMARY KEY CLUSTERED  ([VT_PF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ExcelProfile] ADD CONSTRAINT [FK_CIC_View_ExcelProfile_GBL_ExcelProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_ExcelProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_ExcelProfile] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_ExcelProfile_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_View_ExcelProfile] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_View_ExcelProfile] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View_ExcelProfile] TO [cioc_login_role]
GO
