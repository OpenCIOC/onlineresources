CREATE TABLE [dbo].[STP_Member_ListForeignAgency]
(
[MemberID] [int] NOT NULL,
[AgencyID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Member_ListForeignAgency] ADD CONSTRAINT [PK_STP_Member_ListForeignAgency] PRIMARY KEY CLUSTERED  ([MemberID], [AgencyID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Member_ListForeignAgency] ADD CONSTRAINT [FK_STP_Member_ListForeignAgency_GBL_Agency] FOREIGN KEY ([AgencyID]) REFERENCES [dbo].[GBL_Agency] ([AgencyID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[STP_Member_ListForeignAgency] ADD CONSTRAINT [FK_STP_Member_ListForeignAgency_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
