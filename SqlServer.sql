CREATE database mydatabase;
GO
USE mydatabase;
GO

CREATE TABLE [dbo].[Person] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [FirstName]      NVARCHAR (50)  NOT NULL,
    [HireDate]       DATETIME2 (7)  NULL,
    [LastName]       NVARCHAR (50)  NOT NULL,
    [EnrollmentDate] DATETIME2 (7)  NULL,
    [Discriminator]  NVARCHAR (128) DEFAULT (N'Instructor') NOT NULL,
    CONSTRAINT [PK_Instructor] PRIMARY KEY CLUSTERED ([ID] ASC)
);

GO

CREATE TABLE [dbo].[Department] (
    [DepartmentID] INT           IDENTITY (1, 1) NOT NULL,
    [Budget]       MONEY         NOT NULL,
    [InstructorID] INT           NULL,
    [Name]         NVARCHAR (50) NULL,
    [StartDate]    DATETIME2 (7) NOT NULL,
    [RowVersion]   ROWVERSION    NOT NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([DepartmentID] ASC),
    CONSTRAINT [FK_Department_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [dbo].[Person] ([ID])
);

GO

CREATE TABLE [dbo].[Course] (
    [CourseID]     INT           NOT NULL,
    [Credits]      INT           NOT NULL,
    [Title]        NVARCHAR (50) NULL,
    [DepartmentID] INT           DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([CourseID] ASC),
    CONSTRAINT [FK_Course_Department_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [dbo].[Department] ([DepartmentID]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_Course_DepartmentID]
    ON [dbo].[Course]([DepartmentID] ASC);

CREATE TABLE [dbo].[CourseAssignment] (
    [CourseID]     INT NOT NULL,
    [InstructorID] INT NOT NULL,
    CONSTRAINT [PK_CourseAssignment] PRIMARY KEY CLUSTERED ([CourseID] ASC, [InstructorID] ASC),
    CONSTRAINT [FK_CourseAssignment_Course_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [dbo].[Course] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_CourseAssignment_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [dbo].[Person] ([ID]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_CourseAssignment_InstructorID]
    ON [dbo].[CourseAssignment]([InstructorID] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_Department_InstructorID]
    ON [dbo].[Department]([InstructorID] ASC);

CREATE TABLE [dbo].[Enrollment] (
    [EnrollmentID] INT IDENTITY (1, 1) NOT NULL,
    [CourseID]     INT NOT NULL,
    [Grade]        INT NULL,
    [StudentID]    INT NOT NULL,
    CONSTRAINT [PK_Enrollment] PRIMARY KEY CLUSTERED ([EnrollmentID] ASC),
    CONSTRAINT [FK_Enrollment_Course_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [dbo].[Course] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Enrollment_Person_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Person] ([ID]) ON DELETE CASCADE
);
GO



GO
CREATE NONCLUSTERED INDEX [IX_Enrollment_CourseID]
    ON [dbo].[Enrollment]([CourseID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Enrollment_StudentID]
    ON [dbo].[Enrollment]([StudentID] ASC);


CREATE TABLE [dbo].[OfficeAssignment] (
    [InstructorID] INT           NOT NULL,
    [Location]     NVARCHAR (50) NULL,
    CONSTRAINT [PK_OfficeAssignment] PRIMARY KEY CLUSTERED ([InstructorID] ASC),
    CONSTRAINT [FK_OfficeAssignment_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [dbo].[Person] ([ID]) ON DELETE CASCADE
);

GO
