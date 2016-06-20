CREATE TABLE [dbo].[GBL_ExcelProfile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_ExcelProfile_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_ExcelProfile_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[Domain] [tinyint] NOT NULL,
[ColumnHeaders] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile] ADD CONSTRAINT [CK_GBL_ExcelProfile] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_ExcelProfile] ADD CONSTRAINT [PK_GBL_ExcelProfile] PRIMARY KEY CLUSTERED  ([ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile] ADD CONSTRAINT [FK_GBL_ExcelProfile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_ExcelProfile] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_ExcelProfile] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_ExcelProfile] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_ExcelProfile] TO [cioc_login_role]
GO
