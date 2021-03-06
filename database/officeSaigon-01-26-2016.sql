USE [OfficeSaigon]
GO
/****** Object:  User [huuphu]    Script Date: 1/25/2016 5:02:39 PM ******/
CREATE USER [huuphu] FOR LOGIN [huuphu] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Schema [app]    Script Date: 1/25/2016 5:02:39 PM ******/
CREATE SCHEMA [app]
GO
/****** Object:  Schema [core]    Script Date: 1/25/2016 5:02:39 PM ******/
CREATE SCHEMA [core]
GO
/****** Object:  Schema [res]    Script Date: 1/25/2016 5:02:39 PM ******/
CREATE SCHEMA [res]
GO
/****** Object:  Schema [rpt]    Script Date: 1/25/2016 5:02:39 PM ******/
CREATE SCHEMA [rpt]
GO
/****** Object:  StoredProcedure [app].[usp_ActionArea]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-05
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" ParentID="1" Code="" Name="" ManagerEmployeeID="1" BackColor=""/>
CREATE PROCEDURE [app].[usp_ActionArea]
	@InputValue XML,
	@OuputValue XML = NULL OUTPUT 
AS
BEGIN
	DECLARE 		@ID						int, 		@ParentID				int, 		@Code					nvarchar(50), 		@Name					nvarchar(256), 		@ManagerEmployeeID		int, 		@BackColor				varchar(10), 		@Status					int, 		@Action					varchar(100),		@ReturnMsg				varchar(100)='OK',		@ReturnResult			int,		@UserID					int,		@IDs					varchar(max)
	SELECT 		@ID						= T.i.value('@ID[1]','int'),		@ParentID				= T.i.value('@ParentID[1]','int'),		@Code					= T.i.value('@Code[1]','nvarchar(50)'),		@Name					= T.i.value('@Name[1]','nvarchar(256)'),		@ManagerEmployeeID		= T.i.value('@ManagerEmployeeID[1]','int'),		@BackColor				= T.i.value('@BackColor[1]','varchar(10)'),		@Status					= T.i.value('@Status[1]','int'),		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 		@UserID					= T.i.value('@UserID[1]','int'),		@Action					= T.i.value('@Action[1]','varchar(50)')	FROM @InputValue.nodes('RequestParams') T(i)
	IF(@Action ='UPDATE')
	BEGIN
		UPDATE app.Area		SET		ParentID				= @ParentID,		Code					= @Code,		Name					= @Name,		ManagerEmployeeID		= @ManagerEmployeeID,		BackColor				= @BackColor,		LastUpdatedDateTime		= GETDATE(),		LastUpdatedBy			= @UserID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO app.Area(			ParentID,			Code,			Name,			ManagerEmployeeID,			BackColor,			CreatedBy)
		VALUES(			@ParentID,			@Code,			@Name,			@ManagerEmployeeID,			@BackColor,			@UserID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE app.Area
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETEMULTI')
	BEGIN
		UPDATE app.Area
		SET Status				= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE EXISTS(SELECT 1 FROM core.tvf_DTO_MAR_GetListFromString(@IDs) WHERE Item = ID)
		SET @ReturnResult = 1
	END
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [app].[usp_ActionDepartment]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-03
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Description=""/>
CREATE PROCEDURE [app].[usp_ActionDepartment]
	@InputValue xml
AS
BEGIN
	DECLARE 
		@ID						int, 
		@Code					varchar(50), 
		@Name					nvarchar(256), 
		@Description			nvarchar(512), 
		@Status					int, 
		@Action					varchar(100),
		@ReturnMsg				varchar(100)='OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max)

	SELECT 
		@ID						= T.i.value('@ID[1]','int'),
		@Code					= T.i.value('@Code[1]','varchar(50)'),
		@Name					= T.i.value('@Name[1]','nvarchar(256)'),
		@Description			= T.i.value('@Description[1]','nvarchar(512)'),
		@Status					= T.i.value('@Status[1]','int'),
		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 
		@UserID					= T.i.value('@UserID[1]','int'),
		@Action					= T.i.value('@Action[1]','varchar(50)')
	FROM @InputValue.nodes('RequestParams') T(i)
	IF(@Action ='UPDATE')
	BEGIN
		UPDATE app.Department
		SET
		Code					= @Code,
		Name					= @Name,
		Description				= @Description,
		LastUpdatedDateTime		= GETDATE(),
		LastUpdatedBy			= @UserID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO app.Department(
			Code,
			Name,
			Description,
			CreatedBy)
		VALUES(
			@Code,
			@Name,
			@Description,
			@UserID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE app.Department
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETEMULTI')
	BEGIN
		UPDATE app.Department
		SET Status				= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE EXISTS(SELECT 1 FROM core.tvf_DTO_MAR_GetListFromString(@IDs) WHERE Item = ID)
		SET @ReturnResult = 1
	END
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [app].[usp_ActionEmployee]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-05
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Alias="" Email="" Phone="" Address="" Position="1" DepartmentID="1"/>
CREATE PROCEDURE [app].[usp_ActionEmployee]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
	
AS
BEGIN
	DECLARE 
		@ID						int, 
		@Code					varchar(50), 
		@Name					nvarchar(256), 
		@Alias					nvarchar(256), 
		@Email					varchar(100), 
		@Phone					varchar(20), 
		@Address				nvarchar(256), 
		@PositionID				int, 
		@DepartmentID			int, 
		@Status					int, 
		@Action					varchar(100),
		@ReturnMsg				varchar(100)='OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max)

	SELECT 
		@ID						= T.i.value('@ID[1]','int'),
		@Code					= T.i.value('@Code[1]','varchar(50)'),
		@Name					= T.i.value('@Name[1]','nvarchar(256)'),
		@Alias					= T.i.value('@Alias[1]','nvarchar(256)'),
		@Email					= T.i.value('@Email[1]','varchar(100)'),
		@Phone					= T.i.value('@Phone[1]','varchar(20)'),
		@Address				= T.i.value('@Address[1]','nvarchar(256)'),
		@PositionID				= T.i.value('@PositionID[1]','int'),
		@DepartmentID			= T.i.value('@DepartmentID[1]','int'),
		@Status					= T.i.value('@Status[1]','int'),
		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 
		@UserID					= T.i.value('@UserID[1]','int'),
		@Action					= T.i.value('@Action[1]','varchar(50)')
	FROM @InputValue.nodes('RequestParams') T(i)
	IF(@Action ='UPDATE')
	BEGIN
		UPDATE app.Employee
		SET
		Code					= @Code,
		Name					= @Name,
		Alias					= @Alias,
		Email					= @Email,
		Phone					= @Phone,
		Address					= @Address,
		PositionID				= @PositionID,
		DepartmentID			= @DepartmentID,
		LastUpdatedDateTime		= GETDATE(),
		LastUpdatedBy			= @UserID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO app.Employee(
			Code,
			Name,
			Alias,
			Email,
			Phone,
			Address,
			PositionID,
			DepartmentID,
			CreatedBy)
		VALUES(
			@Code,
			@Name,
			@Alias,
			@Email,
			@Phone,
			@Address,
			@PositionID,
			@DepartmentID,
			@UserID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE app.Employee
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [app].[usp_ActionPosition]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-05
-- Description:	<Description,,>
-- =============================================
-- [app].[usp_ActionPosition] '<InputValue UserID="0" /><RequestParams ID="0"  Name="phu"  Code=""  Description="phu"  Status="0"  Sys_ViewID="4"  Action="INSERT" />'
CREATE PROCEDURE [app].[usp_ActionPosition]
	@InputValue XML,
	@OutputValue XML = NULL output
AS
BEGIN
	DECLARE 
		@ID						int, 
		@Code					varchar(50), 
		@Name					nvarchar(256), 
		@Description			nvarchar(512), 
		@Status					int, 
		@Action					varchar(100),
		@ReturnMsg				varchar(100)='OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max)

	SELECT 
		@ID						= T.i.value('@ID[1]','int'),
		@Code					= T.i.value('@Code[1]','varchar(50)'),
		@Name					= T.i.value('@Name[1]','nvarchar(256)'),
		@Description			= T.i.value('@Description[1]','nvarchar(512)'),
		@Status					= T.i.value('@Status[1]','int'),
		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 
		@UserID					= T.i.value('@UserID[1]','int'),
		@Action					= T.i.value('@Action[1]','varchar(50)')
	FROM @InputValue.nodes('RequestParams') T(i)
	

	IF(@Action ='UPDATE')
	BEGIN
		UPDATE app.Position
		SET
		Code					= @Code,
		Name					= @Name,
		Description				= @Description,
		LastUpdatedDateTime		= GETDATE(),
		LastUpdatedBy			= @UserID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO app.Position(
			Code,
			Name,
			Description,
			CreatedBy)
		VALUES(
			@Code,
			@Name,
			@Description,
			@UserID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE app.Position
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [app].[usp_Area_GetArea]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Area_GetArea] null
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Area_GetArea]
	@InputValue XML 
AS
BEGIN
	
	SELECT RowNumber = ROW_NUMBER() OVER (ORDER BY ISNULL(PA.Code +'.','') + A.Code), *
		,ManagerEmployeeName = E.Name
		,ParentName = PA.Name
		--,ZOrderName = ISNULL(PA.Code +'.','') + A.Code
	FROM app.Area A WITH(NOLOCK)
		LEFT JOIN app.Employee E WITH(NOLOCK) ON A.ManagerEmployeeID = E.ID
		LEFT JOIN app.Area PA WITH(NOLOCK) ON A.ParentID = PA.ID
	WHERE A.Status =0
	ORDER BY RowNumber
END

GO
/****** Object:  StoredProcedure [app].[usp_Area_GetLocation]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Area_GetLocation] '<RequestParams CityID="2" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Area_GetLocation]
	@InputValue XML 
AS
BEGIN
	DECLARE @CityID int
	
	SELECT @CityID = T.i.value('@CityID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	
	
	SELECT [ID]
      ,[Code]
      ,[Name]
	FROM [app].[District]
	WHERE Status >=0 AND CityID=@CityID
	ORDER BY [Index] asc

	SELECT [ID]
      ,[Code]
      ,[Name],
	  DistrictID
	FROM [app].[ward]
	WHERE Status >=0 --AND CityID=@CityID
	ORDER BY [DistrictID] asc
END

GO
/****** Object:  StoredProcedure [app].[usp_Area_GetParentArea]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Area_GetParentArea]
	@InputValue XML 
AS
BEGIN
	SELECT ID =0,Code='...',Name='...'
	UNION
	SELECT ID,Code,Name
	FROM app.Area WITH(NOLOCK)
	WHERE ParentID IS NULL OR ParentID = 0
END

GO
/****** Object:  StoredProcedure [app].[usp_GetDataDefination]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Project_GetProject] '<RequestParams ProjectID="1" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_GetDataDefination]
	@InputValue XML 
AS
BEGIN
	DECLARE @TypeCode NVARCHAR(256)
	
	SELECT @TypeCode = T.i.value('@Code[1]','NVARCHAR(256)')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	
	
	SELECT P.Name,P.Value
	FROM [core].[DataDefination] P
	WHERE P.Status >=0 AND p.TypeCode=@TypeCode
	ORDER BY p.[Index] asc
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Inf_GetInterfaceFunction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Area_GetArea] null
--[app].[usp_Inf_GetInterfaceFunction] '<InputValue UserID="2" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Inf_GetInterfaceFunction]
	@InputValue XML 
AS
BEGIN
	DECLARE @UserID INT,@IsManager INT =0,@EmployeeID int
	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)
	
	SELECT @IsManager = CASE WHEN E.PositionID =1 THEN 1 ELSE 0 END
		,@EmployeeID = U.EmployeeID
	FROM core.UserList U
		LEFT JOIN app.Employee E ON U.EmployeeID = E.ID
	WHERE U.ID = @UserID
	
	--SET @UserID = 2
	
	SELECT I.*,UV.IsView,UV.IsInsert,UV.IsUpdate,UV.IsDelete,UV.IsSpecial,IsManager = @IsManager
	FROM core.InterfaceFunction I
		LEFT JOIN core.UserView UV ON UV.UserID = @UserID AND UV.IsView =1 AND I.viewID = UV.ViewID
			WHERE I.Status =0 AND (UV.Status =0 OR I.ID IN (SELECT I.ParentID
								FROM core.InterfaceFunction I
									JOIN core.UserView UV ON UV.UserID = @UserID 
									AND UV.IsView =1 AND I.viewID = UV.ViewID)
									)
	ORDER BY I.ZOrder
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_ActionProject]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from app.ProjectStep where ProjectID = 52
--exec [app].[usp_Project_ActionProject] '<RequestParams Action="INSERT" AgenName="" AgenAddress="" AreaID="1" AgenPhone="" AgenContactName="" ApprovedBy="1" AreaManagerID="1" AttachedPhoto="1" CompetitorName="" ComplitionDate="" DealerType="1" EstimatedAnnualTurnover="1" HadCCM="1" HadCompetitorShopsign="1" IsCCM="1" IsShopsign="1" MasterDealerName="" NumberOfShelf="1" NumberOfShopsign="1" RequestedBy="1" RequisitionDate="" ShopsignPlacement="1" ShopsignSize=""/>'


-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-17
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" AgenName="" AgenAddress="" AreaID="1" AgenPhone="" AgenContactName="" ApprovedBy="1" AreaManagerID="1" AttachedPhoto="1" CompetitorName="" ComplitionDate="" DealerType="1" EstimatedAnnualTurnover="1" HadCCM="1" HadCompetitorShopsign="1" IsCCM="1" IsShopsign="1" MasterDealerName="" NumberOfShelf="1" NumberOfShopsign="1" RequestedBy="1" RequisitionDate="" ShopsignPlacement="1" ShopsignSize=""/>
CREATE PROCEDURE [app].[usp_Project_ActionProject]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE 
		@ID						int, 
		@AgentName				nvarchar(256), 
		@AgentAddress			nvarchar(512), 
		@AreaID					int, 
		@AgentPhone				nvarchar(50), 
		@AgentContactName		nvarchar(256), 
		@ApprovedBy				int, 
		@AreaManagerID			int, 
		@AttachedPhoto			int, 
		@CompetitorName			nvarchar(256), 
		@ComplitionDate			date, 
		@DealerType				int, 
		@EstimatedAnnualTurnover NUMERIC(18,0), 
		@HadCCM					int, 
		@HadCompetitorShopsign	int, 
		@IsCCM					int, 
		@RequestObjects			int, 
		@RequestOther			nvarchar(512), 
		@MasterDealerName		nvarchar(256), 
		@NumberOfShelf			int, 
		@NumberOfShopsign		int, 
		@RequestedBy			int, 
		@RequestedByName		NVARCHAR(256),
		@RequisitionDate		date, 
		@ShopsignPlacement		int, 
		@ShopsignSize			varchar(50), 
		@Status					int, 
		@Action					varchar(100),
		@ReturnMsg				varchar(100)='OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max),
		@StepConfigID			int

	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)
	
	SELECT 
		@ID						= T.i.value('@ID[1]','int'),
		@AgentName				= T.i.value('@AgentName[1]','nvarchar(256)'),
		@AgentAddress			= T.i.value('@AgentAddress[1]','nvarchar(512)'),
		@AreaID					= T.i.value('@AreaID[1]','int'),
		@AgentPhone				= T.i.value('@AgentPhone[1]','nvarchar(50)'),
		@AgentContactName		= T.i.value('@AgentContactName[1]','nvarchar(256)'),
		@ApprovedBy				= T.i.value('@ApprovedBy[1]','int'),
		@AreaManagerID			= T.i.value('@AreaManagerID[1]','int'),
		@AttachedPhoto			= T.i.value('@AttachedPhoto[1]','int'),
		@CompetitorName			= T.i.value('@CompetitorName[1]','nvarchar(256)'),
		@ComplitionDate			= T.i.value('@ComplitionDate[1]','date'),
		@DealerType				= T.i.value('@DealerType[1]','int'),
		@EstimatedAnnualTurnover= CASE WHEN T.i.value('@EstimatedAnnualTurnover[1]','varchar(1)') >'' THEN T.i.value('@EstimatedAnnualTurnover[1]','numeric(18,0)') ELSE 0 END,
		@HadCCM					= T.i.value('@HadCCM[1]','int'),
		@HadCompetitorShopsign	= T.i.value('@HadCompetitorShopsign[1]','int'),
		@IsCCM					= T.i.value('@IsCCM[1]','int'),
		@RequestObjects			= T.i.value('@RequestObjects[1]','int'),
		@RequestOther			= T.i.value('@RequestOther[1]','nvarchar(512)'),
		@MasterDealerName		= T.i.value('@MasterDealerName[1]','nvarchar(256)'),
		@NumberOfShelf			= T.i.value('@NumberOfShelf[1]','int'),
		@NumberOfShopsign		= T.i.value('@NumberOfShopsign[1]','int'),
		@RequestedBy			= T.i.value('@RequestedBy[1]','int'),
		@RequestedByName		= T.i.value('@RequestedByName[1]','nvarchar(256)'),
		@RequisitionDate		= T.i.value('@RequisitionDate[1]','date'),
		@ShopsignPlacement		= T.i.value('@ShopsignPlacement[1]','int'),
		@ShopsignSize			= T.i.value('@ShopsignSize[1]','varchar(50)'),
		@Status					= T.i.value('@Status[1]','int'),
		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 
		@Action					= T.i.value('@Action[1]','varchar(50)'),
		@StepConfigID			= T.i.value('@StepConfigID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	IF(@Action ='UPDATE')
	BEGIN
		UPDATE app.Project
		SET
		AgentName				= @AgentName,
		AgentAddress				= @AgentAddress,
		AreaID					= @AreaID,
		AgentPhone				= @AgentPhone,
		AgentContactName			= @AgentContactName,
		ApprovedBy				= @ApprovedBy,
		AreaManagerID			= @AreaManagerID,
		AttachedPhoto			= @AttachedPhoto,
		CompetitorName			= @CompetitorName,
		ComplitionDate			= @ComplitionDate,
		DealerType				= @DealerType,
		EstimatedAnnualTurnover	= @EstimatedAnnualTurnover,
		HadCCM					= @HadCCM,
		HadCompetitorShopsign	= @HadCompetitorShopsign,
		IsCCM					= @IsCCM,
		RequestObjects			= @RequestObjects,
		RequestOther			= @RequestOther,
		MasterDealerName		= @MasterDealerName,
		NumberOfShelf			= @NumberOfShelf,
		NumberOfShopsign		= @NumberOfShopsign,
		RequestedBy				= @RequestedBy,
		RequestedByName			= @RequestedByName,
		RequisitionDate			= CASE WHEN @RequisitionDate >'1900-01-01' THEN @RequisitionDate ELSE NULL END,
		ShopsignPlacement		= @ShopsignPlacement,
		ShopsignSize			= @ShopsignSize,
		LastUpdatedDateTime		= GETDATE(),
		LastUpdatedBy			= @UserID,
		StepConfigID			= @StepConfigID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO app.Project(
			AgentName,
			AgentAddress,
			AreaID,
			AgentPhone,
			AgentContactName,
			ApprovedBy,
			AreaManagerID,
			AttachedPhoto,
			CompetitorName,
			ComplitionDate,
			DealerType,
			EstimatedAnnualTurnover,
			HadCCM,
			HadCompetitorShopsign,
			IsCCM,
			RequestObjects,
			RequestOther,
			MasterDealerName,
			NumberOfShelf,
			NumberOfShopsign,
			RequestedBy,
			RequestedByName,
			RequisitionDate,
			ShopsignPlacement,
			ShopsignSize,
			CreatedBy,
			StepConfigID)
		VALUES(
			@AgentName,
			@AgentAddress,
			@AreaID,
			@AgentPhone,
			@AgentContactName,
			@ApprovedBy,
			@AreaManagerID,
			@AttachedPhoto,
			@CompetitorName,
			@ComplitionDate,
			@DealerType,
			@EstimatedAnnualTurnover,
			@HadCCM,
			@HadCompetitorShopsign,
			@IsCCM,
			@RequestObjects,
			@RequestOther,
			@MasterDealerName,
			@NumberOfShelf,
			@NumberOfShopsign,
			@RequestedBy,
			@RequestedByName,
			@RequisitionDate,
			@ShopsignPlacement,
			@ShopsignSize,
			@UserID,
			@StepConfigID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE app.Project
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETEMULTI')
	BEGIN
		UPDATE app.Project
		SET Status				= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE EXISTS(SELECT 1 FROM core.tvf_DTO_MAR_GetListFromString(@IDs) WHERE Item = ID)
		SET @ReturnResult = 1
	END
	ELSE IF(@Action ='UPDATE::STEPCOMPLETE')
	BEGIN
		EXEC [app].[usp_Project_ActionProjectStep_SetComplete] @InputValue,@OutputValue OUTPUT
		EXEC core.usp_ParseResultOutput @ResultOutput = @OutputValue, -- xml
	    @LanguageID = 0 -- int
		RETURN
	END
	ELSE IF(@Action ='UPDATE::REJECT')
	BEGIN
		EXEC [app].[usp_Project_ActionProjectStep_Reject] @InputValue,@OutputValue OUTPUT
		EXEC core.usp_ParseResultOutput @ResultOutput = @OutputValue, -- xml
	    @LanguageID = 0 -- int
		RETURN
	END
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	
	IF( @Action IN ('INSERT','UPDATE'))
	BEGIN
	 
		SET @Inputvalue.modify('replace value of (/RequestParams/@ID)[1] with sql:variable("@ID")')

		SET @Inputvalue.modify('insert attribute ID {sql:variable("@ID")} 
										 into (descendant::RequestParams[not(@ID)])[1]')
		--print 'Input Step::' + cast(@InputValue as nvarchar(1000))
		EXEC [app].[usp_Project_ActionProjectStep] @InputValue,@OutputValue OUTPUT
		EXEC [app].[usp_Project_ActionProjectStep_GenerateIntendDate] @InputValue,@OutputValue OUTPUT
	END
	
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
	
	IF(@ReturnResult >0 AND @Action IN ('INSERT','UPDATE'))
	BEGIN	
		SET @InputValue = '<RequestParams ProjectID="' +CONVERT(varchar(10),@ReturnResult)+ '"/>'
		EXEC [app].[usp_Project_GetProject] @InputValue
	END
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_ActionProjectStep]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-03
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Description=""/><RequestParams ><Steps><Step StepNumber="1" /></Steps></RequestParams>
CREATE PROCEDURE [app].[usp_Project_ActionProjectStep]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE @ProjectID INT,@Action VARCHAR(20)
	
	SELECT @ProjectID = T.i.value('@ID[1]','int')
		,@Action = T.i.value('@Action[1]','varchar(20)')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	
	
	IF(@ProjectID IS NULL OR @ProjectID =0)
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="INVALID_PROJECT" />'
		RETURN
	END
	
	--Insert step con thieu
	INSERT INTO app.ProjectStep
	        ( 
				ProjectID ,
				StepNumber 
	        )
	SELECT @ProjectID,[Index]
	FROM core.DataDefination
	WHERE TypeCode='PROJECTSTEP'
		AND [Index] NOT IN (SELECT StepNumber FROM app.ProjectStep WHERE ProjectID = @ProjectID)
	ORDER BY [Index]
	
	-- Update Step 1, Request Date lay tu tren project neu ko truyen
	UPDATE PS
	SET IntendStartDate		= CASE WHEN I.IntendStartDate > '1900-01-01' THEN I.IntendStartDate ELSE NULL END 
		,EmployeeID			= I.EmployeeID
		,IntendEndDate		= CASE WHEN I.IntendEndDate > '1900-01-01' THEN I.IntendEndDate ELSE NULL END
		,StartDate			= CASE WHEN I.StartDate > '1900-01-01' THEN I.StartDate ELSE NULL END
		,CompleteDate		= CASE WHEN I.CompleteDate > '1900-01-01' THEN I.CompleteDate ELSE NULL END
		,PartnerName		= I.PartnerName
		,PartnerEmail		= I.PartnerEmail
	FROM app.ProjectStep PS
		JOIN (SELECT StepNumber		= T.i.value('@StepNumber[1]','int')
				,EmployeeID			= T.i.value('@EmployeeID[1]','int')
				,IntendStartDate	= T.i.value('@IntendStartDate[1]','date')
				,IntendEndDate		= T.i.value('@IntendEndDate[1]','date')
				,StartDate			= T.i.value('@StartDate[1]','date')
				,CompleteDate		= T.i.value('@CompleteDate[1]','date')
				,PartnerName		= T.i.value('@PartnerName[1]','nvarchar(256)')
				,PartnerEmail		= T.i.value('@PartnerEmail[1]','nvarchar(256)')
		     FROM @InputValue.nodes('RequestParams/Steps/Step') T(i)) I 
		     ON I.StepNumber = PS.StepNumber
	WHERE PS.ProjectID = @ProjectID 
	
	SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_ActionProjectStep_GenerateIntendDate]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-03
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Description=""/><RequestParams ><Steps><Step StepNumber="1" /></Steps></RequestParams>
CREATE PROCEDURE [app].[usp_Project_ActionProjectStep_GenerateIntendDate]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE @ProjectID INT
	,@Action VARCHAR(20),@StepConfigID int
	
	SELECT @ProjectID = T.i.value('@ID[1]','int')
		,@Action = T.i.value('@Action[1]','varchar(20)')
		,@StepConfigID = T.i.value('@StepConfigID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
		
	IF(@ProjectID IS NULL OR @ProjectID =0)
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="INVALID_PROJECT" />'
		RETURN
	END
	
	IF(@StepConfigID IS NULL OR @StepConfigID =0) 
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="INVALID_STEPCONFIG" />'
		RETURN
	END
	
	
	--Insert step con thieu
	INSERT INTO app.ProjectStep
	        ( 
				ProjectID ,
				StepNumber 
	        )
	SELECT @ProjectID,[Index]
	FROM core.DataDefination
	WHERE TypeCode='PROJECTSTEP'
		AND [Index] NOT IN (SELECT StepNumber FROM app.ProjectStep WHERE ProjectID = @ProjectID)
	ORDER BY [Index]
	
	DECLARE @RequestDate DATE,@IntendStartDate DATE,@IntendEndDate DATE,@StepNumber INT =1
	
	SELECT @RequestDate = ISNULL( RequisitionDate ,GETDATE())
	FROM app.Project WITH(NOLOCK)
	WHERE ID = @ProjectID
	
	IF(@RequestDate <= '1901-01-01') SET @RequestDate = GETDATE()
	
	
	SELECT @RequestDate = ISNULL(IntendStartDate,@RequestDate)
	FROM app.ProjectStep WITH(NOLOCK)
	WHERE ProjectID = @ProjectID AND StepNumber = 1
	
	SET @IntendStartDate = @RequestDate
	
	WHILE(@StepNumber <=6)
	BEGIN
		--PRINT '@StepNumber:' + CONVERT(VARCHAR(10),@StepNumber)
		SELECT @IntendEndDate = DATEADD(DAY,IntendDays-1,@IntendStartDate)
		FROM app.StepConfigDetail WITH(NOLOCK)
		WHERE StepConfigID = @StepConfigID AND StepNumber = @StepNumber
		
		UPDATE app.ProjectStep
		SET IntendStartDate = ISNULL(IntendStartDate, @IntendStartDate)
			,IntendEndDate = ISNULL(IntendEndDate, @IntendEndDate)
		WHERE ProjectID = @ProjectID
			AND StepNumber = @StepNumber
		
		SET @StepNumber = @StepNumber +1
		SET @IntendStartDate = DATEADD(DAY,1,@IntendEndDate)
	END
	
	SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_ActionProjectStep_Reject]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-03
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Description=""/><RequestParams ><Steps><Step StepNumber="1" /></Steps></RequestParams>
CREATE PROCEDURE [app].[usp_Project_ActionProjectStep_Reject]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE @ProjectID INT,@Action VARCHAR(50),@LoginEmployeeID INT,@UserID int
	DECLARE @StepNumber INT,@RejectNote NVARCHAR(256)
	
	SELECT @ProjectID = T.i.value('@ProjectID[1]','int')
		,@Action = T.i.value('@Action[1]','varchar(50)')
		,@StepNumber = T.i.value('@StepNumber[1]','int')
		,@RejectNote = T.i.value('@RejectNote[1]','nvarchar(256)')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)
	
	---------------------- VALIDATE ----------------------
	IF(@ProjectID IS NULL OR @ProjectID =0)
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="INVALID_PROJECT" />'
		RETURN
	END
	
	SELECT @LoginEmployeeID = EmployeeID
	FROM core.UserList  WITH(NOLOCK)
	WHERE ID = @UserID
	--User la manager thi duoc update tat ca
	--User cua step nao thi set complete cho step do thoi
	
	------------------------------------------------------
	--Insert step con thieu
	INSERT INTO app.ProjectStep
	        ( 
				ProjectID ,
				StepNumber 
	        )
	SELECT @ProjectID,[Index]
	FROM core.DataDefination
	WHERE TypeCode='PROJECTSTEP'
		AND [Index] NOT IN (SELECT StepNumber FROM app.ProjectStep WHERE ProjectID = @ProjectID)
	ORDER BY [Index]
	
	-- Cac step truoc phai complete het
	IF(EXISTS(SELECT 1 FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber > @StepNumber AND Status =1))
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="SS_STEP_AFTER_COMPLETED" />'
		RETURN
	END
	
	-- Update Step 1, Request Date lay tu tren project neu ko truyen
	
	UPDATE PS
	SET RejectDate		= GETDATE()
		,RejectNote    = I.RejectNote
		,Status = 2
	FROM app.ProjectStep PS
		JOIN (SELECT StepNumber		= T.i.value('@StepNumber[1]','int')
				,EmployeeID			= T.i.value('@EmployeeID[1]','int')
				,RejectNote			= T.i.value('@RejectNote[1]','nvarchar(256)')
				,IntendEndDate		= T.i.value('@IntendEndDate[1]','date')
				,CompleteDate		= T.i.value('@CompleteDate[1]','date')
				,PartnerName		= T.i.value('@PartnerName[1]','nvarchar(256)')
				,PartnerEmail		= T.i.value('@PartnerEmail[1]','nvarchar(256)')
		     FROM @InputValue.nodes('RequestParams') T(i)) I 
		     ON I.StepNumber = PS.StepNumber
	WHERE PS.ProjectID = @ProjectID 
	
	DECLARE @EmployeeEmail VARCHAR(256)
	SELECT @EmployeeEmail = E.Email
	FROM app.ProjectStep PS
		LEFT JOIN app.Employee E ON ps.EmployeeID = E.ID
	WHERE ProjectID = @ProjectID AND StepNumber = @StepNumber
	
	IF(@EmployeeEmail >'')
	BEGIN
		-- Data co email
		CREATE TABLE #EmailData(
			AgentName NVARCHAR(200),
			RejectDateDay VARCHAR(20),
			RejectDateMonth VARCHAR(20),
			RejectDateYear VARCHAR(20),
			RejectNote NVARCHAR(512)
		)
		INSERT INTO #EmailData(AgentName,RejectDateDay,RejectDateMonth,RejectDateYear,RejectNote)
		SELECT P.AgentName
			,RejectDateDay = DAY(PS.RejectDate)
			,RejectDateMonth = MONTH(PS.RejectDate)
			,RejectDateYear = YEAR(PS.RejectDate)
			,RejectNote = PS.RejectNote
		FROM app.ProjectStep PS
			JOIN app.Project P ON P.ID = PS.ProjectID
		WHERE ProjectID = @ProjectID AND StepNumber = @StepNumber
		
		DECLARE @MailTemplateBody NVARCHAR(max),@MailTemplateSubj NVARCHAR(256)
		EXEC [res].[usp_Email_LoadTemplate] 'SHOPSIGN_STEP_REJECTED'
				,@MailTemplateSubj OUTPUT
				,@MailTemplateBody OUTPUT
		DROP TABLE #EmailData
		--SET @MailTemplateBody =N'[Step] in Project [Project] Rejected: [Note]'
		--SET @MailTemplateSubj =N'Your step rejected'
		
		--SELECT @MailTemplateBody = REPLACE(@MailTemplateBody,'[Project]',AgentName)
		--FROM app.Project 
		--WHERE ID = @ProjectID
		
		--SELECT @MailTemplateBody = REPLACE(@MailTemplateBody,'[Step]',dbo.DataDefinitionName('PROJECTSTEP',@StepNumber))
		--SELECT @MailTemplateBody = REPLACE(@MailTemplateBody,'[Note]',@RejectNote)
		
		EXEC core.usp_Sys_SendEmail @To = @EmployeeEmail, -- varchar(256)
		    @Subject = @MailTemplateSubj, -- nvarchar(256)
		    @Body = @MailTemplateBody -- nvarchar(256)
		
	END
	
	SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
	
	
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_ActionProjectStep_SetComplete]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-03
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" Code="" Name="" Description=""/><RequestParams ><Steps><Step StepNumber="1" /></Steps></RequestParams>
CREATE PROCEDURE [app].[usp_Project_ActionProjectStep_SetComplete]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE @ProjectID INT,@Action VARCHAR(50),@LoginEmployeeID INT,@UserID INT,@StepNumber int
	
	SELECT @ProjectID = T.i.value('@ProjectID[1]','int')
		,@Action = T.i.value('@Action[1]','varchar(50)')
		,@StepNumber = T.i.value('@StepNumber[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)
	
	---------------------- VALIDATE ----------------------
	IF(@ProjectID IS NULL OR @ProjectID =0)
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="INVALID_PROJECT" />'
		RETURN
	END
	
	------------------------------------------------------
	--Insert step con thieu
	INSERT INTO app.ProjectStep
	        ( 
				ProjectID ,
				StepNumber 
	        )
	SELECT @ProjectID,[Index]
	FROM core.DataDefination
	WHERE TypeCode='PROJECTSTEP'
		AND [Index] NOT IN (SELECT StepNumber FROM app.ProjectStep WHERE ProjectID = @ProjectID)
	ORDER BY [Index]
	
	-- Kiem tra ngay
	IF(EXISTS(SELECT 1 FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber = @StepNumber 
		AND (IntendStartDate IS NULL 
			OR IntendEndDate IS NULL
			OR StartDate IS NULL
			OR IntendEndDate < IntendStartDate
			) ))
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="SS_STEP_DATE_INVALID" />'
		RETURN
	END
	-- Cac step truoc phai complete het
	IF(EXISTS(SELECT 1 FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber < @StepNumber AND Status !=1))
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="SS_PRESTEP_PENDING" />'
		RETURN
	END
	
	SELECT @LoginEmployeeID = EmployeeID
	FROM core.UserList  WITH(NOLOCK)
	WHERE ID = @UserID
	--User la manager thi duoc update tat ca
	--User cua step nao thi set complete cho step do thoi
	
	
	
	-- Update Step 1, Request Date lay tu tren project neu ko truyen
	UPDATE PS
	SET CompleteDate		= GETDATE()
		,Status =1
	FROM app.ProjectStep PS
		JOIN (SELECT StepNumber		= T.i.value('@StepNumber[1]','int')
				,EmployeeID			= T.i.value('@EmployeeID[1]','int')
				,IntendStartDate	= T.i.value('@IntendStartDate[1]','date')
				,IntendEndDate		= T.i.value('@IntendEndDate[1]','date')
				,CompleteDate		= T.i.value('@CompleteDate[1]','date')
				,PartnerName		= T.i.value('@PartnerName[1]','nvarchar(256)')
				,PartnerEmail		= T.i.value('@PartnerEmail[1]','nvarchar(256)')
		     FROM @InputValue.nodes('RequestParams') T(i)) I 
		     ON I.StepNumber = PS.StepNumber
	WHERE PS.ProjectID = @ProjectID 
	
	SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
	
	
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_GetProject]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Project_GetProject] '<RequestParams ProjectID="1" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Project_GetProject]
	@InputValue XML 
AS
BEGIN
	DECLARE @ProjectID INT,@FromDate DATE,@ToDate DATE,@TextFilter NVARCHAR(256)
	
	SELECT @ProjectID = T.i.value('@ProjectID[1]','int')
		,@FromDate = T.i.value('@FromDate[1]','date')
		,@ToDate = T.i.value('@ToDate[1]','date')
		,@TextFilter = T.i.value('@TextFilter[1]','NVARCHAR(256)')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	IF(@FromDate IS NULL) SET @FromDate ='1900-01-01'
	IF(@ToDate IS NULL OR @ToDate <='1900-01-01') SET @ToDate = DATEADD(y,10,GETDATE())
	IF(@TextFilter IS null) SET @TextFilter = ''
	
	SELECT P.[ID]
      ,P.[AgentName]
      ,P.[AgentAddress]
      ,P.[AreaID]
      ,[AreaName] = A.Name
      ,P.[AgentPhone]
      ,P.[AgentContactName]
      ,P.[ApprovedBy]
      ,P.[AreaManagerID]
      ,AreaManagerName = E.Name
      ,P.[AttachedPhoto]
      ,P.[CompetitorName]
      ,P.[ComplitionDate]
      ,P.[DealerType]
      ,[DealerTypeName] = dbo.DataDefinitionName('DEALER_TYPE',[DealerType])
      ,P.[EstimatedAnnualTurnover]
      ,P.[HadCCM]
      ,HadCCMName = dbo.DataDefinitionName('BOOLEAN_YESNO',[HadCCM])
      ,P.[HadCompetitorShopsign]
      ,HadCompetitorShopsignName = dbo.DataDefinitionName('BOOLEAN_YESNO',HadCompetitorShopsign)
      ,P.[IsCCM]
      ,IsCCMName = dbo.DataDefinitionName('BOOLEAN_YESNO',[IsCCM])
      ,P.RequestObjects
      ,P.RequestOther
      --,[IsShopsignName] = dbo.DataDefinitionName('BOOLEAN_YESNO',[IsShopsign])
      ,P.[MasterDealerName]
      ,P.[NumberOfShelf]
      ,P.[NumberOfShopsign]
      ,P.[RequestedBy]
      ,P.RequestedByName
      ,P.[RequisitionDate]
      ,P.[ShopsignPlacement]
      ,ShopsignPlacementName = dbo.DataDefinitionName('SHOPSIGNPLACEMENT',[ShopsignPlacement])
      ,P.[ShopsignSize]
      ,P.[Status]
      ,[DisplayStatus] =  CONVERT(VARCHAR(10),ISNULL((SELECT COUNT(1) FROM app.ProjectStep PS WHERE PS.ProjectID = P.ID AND Status =1),0))
					+'/6' 
      ,P.[CreatedDateTime]
      ,P.StepConfigID
	FROM app.Project P WITH(NOLOCK) 
		LEFT JOIN app.Area A ON P.AreaID = A.ID
		LEFT JOIN app.Employee E ON P.AreaManagerID = E.ID
		LEFT JOIN app.ProjectStep PS ON PS.ProjectID = P.ID AND PS.StepNumber =1
	WHERE P.Status >=0 AND (P.ID = @ProjectID OR @ProjectID IS NULL)
		AND (
			ISNULL(ps.IntendStartDate,P.CreatedDateTime) BETWEEN @FromDate AND @ToDate
			AND P.AgentName LIKE '%'+ @TextFilter +'%'
		)
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_GetProjectStep]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Project_GetProjectStep] '<RequestParams ProjectID="1" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Project_GetProjectStep]
	@InputValue XML 
AS
BEGIN
	DECLARE @ProjectID INT
	SELECT @ProjectID = T.i.value('@ProjectID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT StepNumber  = DD.[Index]
		,StepName= DD.Name
		,PS.EmployeeID
		,PS.IntendStartDate
		,PS.IntendEndDate
		,PS.StartDate
		,PS.CompleteDate
		,PS.PartnerName
		,PS.PartnerEmail
		,Status = ISNULL(PS.Status,0)
	FROM core.DataDefination DD
		LEFT JOIN app.ProjectStep PS ON DD.[Index] = PS.StepNumber AND PS.ProjectID = @ProjectID
	WHERE DD.TypeCode ='PROJECTSTEP'
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Project_GetProjectStepChartData]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[app].[usp_Project_GetProjectStep] '<RequestParams ProjectID="1" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Project_GetProjectStepChartData]
	@InputValue XML 
AS
BEGIN
	DECLARE @ProjectID INT
	SELECT @ProjectID = T.i.value('@ProjectID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT StepNumber  = 0
		,StepName= 'Total'
		,EmployeeID = 0
		,IntendStartDate = (SELECT IntendStartDate FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber =1)
		,IntendEndDate =(SELECT IntendEndDate FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber =6)
		,StartDate = (SELECT StartDate FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber =1)
		,CompleteDate = (SELECT CompleteDate FROM app.ProjectStep WHERE ProjectID = @ProjectID AND StepNumber =6 AND Status =1)
		,PartnerName =''
		,PartnerEmail =''
		,Status = 0
		,EmployeeName = P.RequestedByName
		,P.AgentName
	FROM app.Project P
	WHERE P.ID = @ProjectID
	UNION
	
	SELECT StepNumber  = DD.[Index]
		,StepName= DD.Name
		,PS.EmployeeID
		,PS.IntendStartDate
		,PS.IntendEndDate
		,PS.StartDate
		,CompleteDate = CASE WHEN PS.Status =1 THEN ps.CompleteDate ELSE NULL END
		,PS.PartnerName
		,PS.PartnerEmail
		,Status = ISNULL(PS.Status,0)
		,EmployeeName = E.Name 
		,P.AgentName
	FROM core.DataDefination DD
		LEFT JOIN app.ProjectStep PS ON DD.[Index] = PS.StepNumber AND PS.ProjectID = @ProjectID
		LEFT JOIN app.Employee E ON PS.EmployeeID = E.ID
		LEFT JOIN app.Project P ON PS.ProjectID = P.ID
	WHERE DD.TypeCode ='PROJECTSTEP_CHART'
	
END

GO
/****** Object:  StoredProcedure [app].[usp_Schedule_SendLateStepEmail]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [app].[usp_Schedule_SendLateStepEmail] NULL,NULL
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_Schedule_SendLateStepEmail]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	EXEC [core].[usp_TOL_DBA_WriteActionAudit] 0,'','usp_Schedule_SendLateStepEmail','','',NULL,''
	DECLARE @StepIDtbl AS TABLE(ID INT,Email VARCHAR(512),DayNum VARCHAR(10),PartnerEmail varchar(512))
	
	--Lay ra danh sach step bi tre, can gui email, ID va mot so thong tin
	INSERT INTO @StepIDtbl(ID,Email,DayNum,PartnerEmail)
	SELECT PS.ID,E.Email
		,DayNum = DAY( GETDATE() - PS.IntendEndDate) -1
		,PS.PartnerEmail
	FROM app.ProjectStep PS
		JOIN app.Project P ON PS.ProjectID = P.ID AND P.Status >=0
		LEFT JOIN app.Employee E ON ps.EmployeeID = e.ID
	WHERE PS.Status !=1 AND PS.Status >=0 AND PS.IntendStartDate IS NOT NULL AND PS.IntendEndDate IS NOT NULL
		AND GETDATE() > PS.IntendEndDate
		AND (E.Email >'' OR PS.PartnerEmail >'')
	
	-- Tao table du lieu cho email
	CREATE TABLE #EmailData(
		AgentName NVARCHAR(512),
		DayNum VARCHAR(10),
		StepName NVARCHAR(256),
		IntendEndDate VARCHAR(50)
	)
	
	DECLARE @EmailSubject NVARCHAR(256),@EmailBody NVARCHAR(MAX),@EmailAddress VARCHAR(512),@DayNum VARCHAR(10)
	DECLARE @StepID INT,@StepIDtmp INT
	SELECT TOP 1 @StepID = ID
		,@EmailAddress = ISNULL(Email,'') + CASE WHEN Email >'' AND PartnerEmail >'' THEN ',' ELSE '' END  +ISNULL( PartnerEmail,'')
		,@DayNum = DayNum
	FROM @StepIDtbl
	ORDER BY ID
	-- duyet qua cac ID, va gui email
	WHILE(@StepID >0)
	BEGIN
		--du lieu cho email
		DELETE #EmailData
		INSERT INTO #EmailData
		        ( AgentName ,
		          DayNum ,
		          StepName ,
		          IntendEndDate
		        )
		SELECT AgentName = p.AgentName
			,DayNum = @DayNum
			,StepName = D.Name
			,IntendEndDate = ps.IntendEndDate
		FROM app.ProjectStep PS
			JOIN app.Project p ON ps.ProjectID = p.ID
			LEFT JOIN core.DataDefination D ON D.TypeCode ='PROJECTSTEP' AND d.[Index] = PS.StepNumber
		WHERE ps.ID = @StepID
		
		--Load template email, replace data vao template
		EXEC [res].[usp_Email_LoadTemplate] 'SHOPSIGN_STEP_LATE'
				,@EmailSubject OUTPUT
				,@EmailBody OUTPUT
		--Gui email
		EXEC core.usp_Sys_SendEmail @To = @EmailAddress, -- varchar(256)
		    @Subject = @EmailSubject, -- nvarchar(256)
		    @Body = @EmailBody -- nvarchar(256)
		
		-- Lay ID tiep theo
		SELECT @StepIDtmp = @StepID, @StepID = 0
		SELECT TOP 1 @StepID = ID,@EmailAddress = Email,@DayNum = DayNum
		FROM @StepIDtbl
		WHERE ID > @StepIDtmp
		ORDER BY ID
	END
	
	DROP TABLE #EmailData
END

GO
/****** Object:  StoredProcedure [app].[usp_User_ActionUserRole]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*[app].[usp_User_ActionUserRole] '<InputValue UserID="1"/>
<RequestParams UserID="3" >
 <Item ViewID="1" IsView="1" IsUpdate="1" IsDelete="1" IsInsert="1" IsSpecial="1"/>
 <Item ViewID="3" IsView="1" IsUpdate="1" IsDelete="1" IsInsert="1" IsSpecial="1"/>
</RequestParams>'
*/
-- =============================================
-- Author:  <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_User_ActionUserRole]
 @InputValue XML,
 @OutputValue XML = null OUTPUT
AS
BEGIN
	DECLARE 
		@ID      int, 
		@UserID     INT,
		@ActionUserID   int

	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)

	SELECT @ActionUserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	--neu khong co role nao
	IF(NOT EXISTS(SELECT 1
	              FROM @InputValue.nodes('RequestParams/Roles') T(i)))
	BEGIN
		SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
		RETURN;
	END
	
	-- Delete all
	UPDATE core.UserView
	SET Status =-1
	WHERE UserID = @ActionUserID

	-- Reupdate
	UPDATE UV
	SET IsView = I.IsView
		,IsInsert = I.IsInsert
		,IsUpdate = I.IsUpdate
		,IsDelete = I.IsDelete
		,IsSpecial = I.IsSpecial
		,UV.Status = 0
		,LastUpdatedDateTime = GETDATE()
		,LastUpdatedBy = @UserID
	FROM core.UserView UV
	JOIN (SELECT 
			ID      = T.i.value('@ID[1]','int'),
			UserID     = @ActionUserID,
			ViewID     = T.i.value('@ViewID[1]','int'),
			IsView     = T.i.value('@IsView[1]','bit'),
			IsInsert    = T.i.value('@IsInsert[1]','bit'),
			IsUpdate    = T.i.value('@IsUpdate[1]','bit'),
			IsDelete    = T.i.value('@IsDelete[1]','bit'),
			IsSpecial    = T.i.value('@IsSpecial[1]','bit')
	FROM @InputValue.nodes('RequestParams/Roles/Role') T(i)
	) I ON I.UserID = UV.UserID AND I.ViewID = UV.ViewID
	WHERE UV.UserID = @ActionUserID

	--Insert new
	INSERT INTO core.UserView
		 ( UserID ,
		   ViewID ,
		   IsView ,
		   IsInsert ,
		   IsUpdate ,
		   IsDelete ,
		   IsSpecial,
		   CreatedBy
		 )
	SELECT 
		UserID     = @ActionUserID,
		ViewID     = T.i.value('@ViewID[1]','int'),
		IsView     = T.i.value('@IsView[1]','bit'),
		IsInsert    = T.i.value('@IsInsert[1]','bit'),
		IsUpdate    = T.i.value('@IsUpdate[1]','bit'),
		IsDelete    = T.i.value('@IsDelete[1]','bit'),
		IsSpecial    = T.i.value('@IsSpecial[1]','bit'),
		CreatedBy    = @UserID
	FROM @InputValue.nodes('RequestParams/Roles/Role') T(i)
	WHERE NOT EXISTS(SELECT 1 FROM core.UserView 
					WHERE UserID =@ActionUserID
						AND T.i.value('@ViewID[1]','int') = ViewID)
	  
	SET @OutputValue ='<OutputValue MessageCode="OK" Result="1" />'
END

GO
/****** Object:  StoredProcedure [app].[usp_User_GetUserList]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [app].[usp_User_GetUserRole] '<RequestParams UserID="2" />'
-- =============================================
-- Author:  <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_User_GetUserList]
	@InputValue XML
AS
BEGIN
 DECLARE @UserID INT 
 SELECT @UserID = T.i.value('@UserID[1]','int')
 FROM @InputValue.nodes('RequestParams') T(i)
 
 SELECT U.ID
	,U.UserName
	,U.FullName,U.Alias
	,U.EmployeeID,U.CreatedDateTime
	,U.CreatedBy,U.Status
	,StatusName = CASE WHEN U.Status =0 THEN 'Active' ELSE 'InActive' END
	,EmployeeName = E.Name
	,EmployeeAlias = E.Alias
 FROM core.UserList U WITH(NOLOCK)
	LEFT JOIN app.Employee E ON U.EmployeeID = E.ID AND E.Status =0
 WHERE U.Status >=0
END

GO
/****** Object:  StoredProcedure [app].[usp_User_GetUserRole]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [app].[usp_User_GetUserRole] '<RequestParams UserID="2" />'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[usp_User_GetUserRole]
	@InputValue XML
AS
BEGIN
	DECLARE @UserID INT 
	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT ViewID = V.ID,V.Name,UV.IsView,UV.IsInsert,UV.IsUpdate,UV.IsDelete,UV.IsSpecial
	FROM core.[View] V
	LEFT JOIN core.UserView UV ON UV.UserID = @UserID AND V.ID = UV.ViewID AND UV.Status =0
	WHERE V.Status = 0
END

GO
/****** Object:  StoredProcedure [core].[usp_GetApplicationMessageWithResult]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================
-- Author:		Nam.p.nguyen@pmsa.com.vn
-- Edit by:		Nam.p.nguyen@pmsa.com.vn
-- Create date: 2012-01-6
-- Update date:	2012-01-6

-- Description:	GetMessage By Code
-- Return:      
-- ==============================================================
--EXEC [core].[usp_DTO_APP_GetErrorMessageWithResult] 'CORE_VRF_OpenIDNotRegistered',1,29,'[EMAIL]','nam.p.nguyen@pmsa.com.vn'
CREATE PROCEDURE [core].[usp_GetApplicationMessageWithResult]
	@MessageCode varchar(50),
	@Result sql_variant	,
	@Language int=null
AS
BEGIN
	SET NOCOUNT ON
	IF(NOT EXISTS(SELECT 1 FROM core.ApplicationMessage WITH (readpast)
		WHERE Code = @MessageCode ))
	BEGIN
		INSERT INTO  core.ApplicationMessage(Code,Name,Type,[Description])
		VALUES(@MessageCode,@MessageCode,0,@MessageCode)
	END
	SELECT 
		[ID],Code, Name,[Type],[Description],
		Result = ISNULL(@Result,0)
	FROM core.ApplicationMessage WITH (readpast)
	WHERE Code = @MessageCode 
END

GO
/****** Object:  StoredProcedure [core].[usp_ParseResultOutput]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nam.p.nguyen@pmsa.com.vn
-- Create date: 13/08/2010
-- Description:	Parse resultoutput to message
-- =============================================
/*
declare @resultoutput xml ='<ResultOutput MessageCode="SYSTEM_ERROR" Result="0" ReplaceCode="[MESSAGE]" ReplaceValue="abce"/>'
 exec [core].[usp_SYS_GLO_ParseResultOutput] @resultoutput,29
 */
CREATE PROCEDURE [core].[usp_ParseResultOutput]
	@ResultOutput xml,
	@LanguageID int	=null
AS
BEGIN
	
	
	DECLARE @iResult varchar(100), @idoc int, @MessageCode varchar(50),@ResultID int,
	@ReplaceCode varchar(100),@ReplaceValue nvarchar(256)
	
	SELECT @iResult = T.i.value('@Result[1]','varchar(100)')
		,@MessageCode = T.i.value('@MessageCode[1]','varchar(100)')
		,@ResultID =  T.i.value('@ReturnID[1]','int')
		,@ReplaceCode =  T.i.value('@ReplaceCode[1]','varchar(100)')
		,@ReplaceValue =  T.i.value('@ReplaceValue[1]','nvarchar(256)')
	FROM @ResultOutput.nodes('OutputValue') T(i)
	IF(@ResultID is null AND ISNUMERIC(@iResult)=1) SET @ResultID=@iResult
	
	IF(EXISTS(SELECT ID FROM ApplicationMessage with(NOLOCK) WHERE Code = @MessageCode))
	BEGIN
		DECLARE @Message nvarchar(246)
		SELECT @Message =Description
		FROM ApplicationMessage WITH (NOLOCK)
		WHERE Code = @MessageCode 
		IF(@ReplaceCode is not null)
			SELECT @Message = REPLACE(@Message,@ReplaceCode,@ReplaceValue)
		 
		SELECT 
			[ID],Code,
			Name,
			Description=@Message, --core.svf_SYS_GLO_GetValueMapping( [Description], LanguageID, 'ErrorMessage', 'Description', ID, @LanguageID) [Description],
			[Type],
			Result = ISNULL(@iResult,0),
			ResultID = @ResultID
		FROM ApplicationMessage WITH (NOLOCK)
		WHERE Code = @MessageCode 
		
	END
	ELSE
	BEGIN
		-- Neu ko co thi insert vao Error message
		INSERT INTO ApplicationMessage(Code,Name,[Description],[Type])
		VALUES(@MessageCode,@MessageCode,@MessageCode,8)
		
		EXEC [core].usp_GetApplicationMessageWithResult @MessageCode,@iResult,@LanguageID
	
	END
END

GO
/****** Object:  StoredProcedure [core].[usp_SYS_Login]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  npnam
-- Create date: 2012-1-2
-- Description: 
-- =============================================
/*
DECLARE @InputValue xml = '<InputValue UserName = "demo" Password = "123456"/>',@OutputValue XML

EXEC core.usp_SYS_Login @InputValue,@OutputValue output
select @OutputValue
*/
CREATE PROCEDURE [core].[usp_SYS_Login]
 -- Add the parameters for the stored procedure here
 @InputValue XML,
 @OutputValue XML output
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;
 
 DECLARE @UserLogin varchar(50),@Password varchar(100),@UserID INT
  ,@MsgCode varchar(50)='SUCCESS'
  ,@LanguageID int
 SELECT @UserLogin = T.item.value('@UserName[1]','varchar(50)'),
  @Password = T.item.value('@Password[1]','varchar(50)'),
  @LanguageID = T.item.value('@LanguageID[1]','int')
 FROM @InputValue.nodes('InputValue') T(item)
 
 SELECT @UserID = ID
 FROM core.UserList
 WHERE UserName = @UserLogin
  AND [Password]=@Password 
  AND Status = 0
 
 IF(@UserID is NULL OR @UserID = 14)
 BEGIN
  SET @MsgCode ='LoginNotExist'
 END
 ELSE
 BEGIN
  UPDATE core.UserList
  SET [Session] = NEWID(),
   LanguageID= @LanguageID
  WHERE ID = @UserID  
 END
 
 IF @MsgCode <> 'SUCCESS'
 BEGIN
  --SELECT 1 WHERE 0=1
  EXEC core.usp_GetApplicationMessageWithResult @MsgCode,0
 
 END
 ELSE
 BEGIN
  EXEC core.usp_GetApplicationMessageWithResult @MsgCode,@UserID
  SELECT U.ID,U.UserName,U.FullName,U.Session,U.Status,U.Alias,U.EmployeeID
	,E.Name EmployeeName
	,E.PositionID
	,IsManager = CASE WHEN E.PositionID =1 THEN 1 ELSE 0 END
  FROM core.UserList U
  LEFT JOIN app.Employee E ON U.EmployeeID = E.ID
  WHERE U.ID = @UserID

 END
END

GO
/****** Object:  StoredProcedure [core].[usp_Sys_SendEmail]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
----Run this command to enable mail
sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE

----To config mail:
go to Managerment > Database Mail to config mail account
*/
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [core].[usp_Sys_SendEmail]
	-- Add the parameters for the stored procedure here
	@To VARCHAR(256),
	@Subject NVARCHAR(256),
	@Body NVARCHAR(256)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	INSERT INTO core.MailQueue(MailTo,[Subject],Body)
	VALUES(@to,@Subject,@Body)
	
	PRINT 'Add to mail queue'
    -- Insert statements for procedure here
	--EXEC msdb.dbo.sp_send_dbmail @recipients=@To,
	--@profile_name='Nippon',
    --@subject = @Subject,
    --@body = @Body,
    --@body_format = 'HTML' ;
END
/*
EXEC core.usp_Sys_SendEmail 'phu.h.le@pmsa.com.vn','nippon email test','def'

sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO

go to Managerment > Database Mail to config mail account
*/
GO
/****** Object:  StoredProcedure [core].[usp_SYS_VRF_CallFunction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM vcore.Client AS C
--
/*
DECLARE @Output xml
EXEC [vcore].[usp_SYS_VRF_CallFunction] 199,'4F5C2508-1ADA-4672-BED1-C7AA3590ACFD',
'<RequestParams ResourceID="E2FF327D-07FF-4EBF-8CFA-C6460FC72041" Type="1" Context="GetData" />
<RequestParams ResourceID="E2FF327D-07FF-4EBF-8CFA-C6460FC72041" Type="1" Context="GetData" />'

*/
-- =============================================
-- Author:		npnam
-- Create date: 2011-12-29
-- Description:
-- @InputValue: <InputValue UserID="1" Session="ABCD-EFGHIJK-LMNPQR-STUV" FunctionID="6" UserLogin="123" Password="123" />	
-- =============================================
--[vcore].[usp_SYS_VRF_CallFunctionV2] 199,'4F5C2508-1ADA-4672-BED1-C7AA3590ACFD','<InputValue  UserID="" LanguageID="129"/><RequestParams Function="GetResource" Type="11"/>'
CREATE PROCEDURE [core].[usp_SYS_VRF_CallFunction]
	-- Add the parameters for the stored procedure here
	@FunctionID int,
	@ClientKey varchar(36),
	@InputValue xml
AS
BEGIN
	SET ARITHABORT ON;
	DECLARE @UserID int
		,@SecrectTokenGuid uniqueidentifier
		,@UserType int
		,@SecrectToken VARCHAR(36)
		,@StoreProcedureName nvarchar(128)
		,@StoreName nvarchar(80)
		,@IsReturnApplicationMessage bit=0
		,@OutputValue xml
		,@ClientID int
	
	SELECT	@UserID =T.item.value('@UserID[1]','int'),
			@SecrectToken = T.item.value('@SecrectToken[1]','VARCHAR(36)')
	FROM	@InputValue.nodes('InputValue') T(item)
	
	--SELECT @ClientID = ID
	--FROM core.Client  AS C WITH (NOLOCK)
	--WHERE IDKey = @ClientKey
	
	IF(@ClientID IS NULL OR @ClientID =0) SET @ClientID = 1
	
	--Kiem tra client
	IF(@ClientID IS NULL OR @ClientID =0)
	BEGIN
		EXEC [core].[usp_GetApplicationMessageWithResult] 'SYS_ERR_CLIENTKEY_INVALID',0,0
		RETURN
	END
	
	IF(NOT EXISTS(SELECT 1 FROM @InputValue.nodes('InputValue') T(i)))
	BEGIN
		PRINT 'add node'
		SET @InputValue.modify('insert <InputValue /> before (/RequestParams)[1]')
		PRINT 'add node::' + CONVERT (nvarchar(MAX),@InputValue)
	END
	
	SET @InputValue.modify('insert attribute ClientID {sql:variable("@ClientID")} into (/InputValue)[1]')
	--Get Store Name
	SELECT @StoreProcedureName = 'EXEC '+StoreProcedureName +' @InputValue,@OutputValue output',
		@StoreName = StoreProcedureName,
		@IsReturnApplicationMessage = IsReturnApplicationMessage
	FROM core.SystemFunction WITH (NOLOCK)
	WHERE ID = @FunctionID
	
	--print @StoreProcedureName
	
	DECLARE @Input nvarchar(max)
	SET @Input = CAST(@InputValue as nvarchar(max))
		
	EXEC core.usp_TOL_DBA_WriteActionAudit @UserID,@SecrectToken,@StoreName,@Input,''	
	print 'Excute function'
	--Execute function
	BEGIN TRY
		EXEC sp_executesql @StoreProcedureName,N'@InputValue xml,@OutputValue xml output',@InputValue = @InputValue,@OutputValue = @OutputValue OUTPUT
		IF(@OutputValue IS NULL)
		BEGIN
			SET @OutputValue = '<OutputValue MessageCode="RequestOK" Result="1"/>'
		END
		-- Neu thanh cong thi tra ve ket qua thanh cong
		IF(@IsReturnApplicationMessage =0 OR @IsReturnApplicationMessage is null)
			SET @OutputValue.modify('insert <OutputValue MessageCode="RequestOK"  Result="1"/> as first into (/)[1]')
			--EXEC [vcore].[usp_GetApplicationMessageWithResult] 'OK',1,0
		EXEC core.usp_ParseResultOutput @OutputValue
		
	END TRY
	BEGIN CATCH
		
		print 'catch'
		DECLARE @ErrMsg nvarchar(250),@ErrMsgCode nvarchar(250)
		SELECT @ErrMsg = ERROR_MESSAGE(),
			@ErrMsgCode = ERROR_NUMBER()
			SELECT @ErrMsg,
			@ErrMsgCode,ERROR_PROCEDURE(),ERROR_SEVERITY()
			
		--EXEC core.usp_TOL_DBA_WriteActionAudit @UserID,@SecrectToken,@StoreName,@InputValue,@ErrMsg	
		IF(@IsReturnApplicationMessage =0 OR @IsReturnApplicationMessage is null)
		BEGIN
			SELECT 1 WHERE 0=1
		END
		
		SELECT ID=0, Code='SYSTEM_ERROR',
				Name=@ErrMsgCode,
				Description =@ErrMsg,
				Type=0,
				Result =0		
		
	END CATCH
END

GO
/****** Object:  StoredProcedure [core].[usp_TOL_DBA_WriteActionAudit]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- core.usp_TOL_DBA_WriteActionAudit 21,'123','abc','','','2010-08-18'
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [core].[usp_TOL_DBA_WriteActionAudit]
	@UserID int,
	@Session varchar(36),
	@StoreName varchar(50),
	@InputNote nvarchar(max),
	@OutputNote nvarchar(max)=null,
	@StartTime datetime=null,
	@Type varchar(100) =''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @isEnable int=1, @configUserID int=0,@Duration int
	--SELECT @isEnable = CAST([core].[svf_DTO_APP_GetSystemConfigByCode]('System::Profiler::Enable') AS Int)
	--SELECT @configUserID = CAST([core].[svf_DTO_APP_GetSystemConfigByCode]('System::Profiler::UserID') AS int)
	
	
	IF(@isEnable =1 AND (@configUserID = @UserID OR @configUserID =0))
	BEGIN
		SET @Duration = DATEDIFF(MILLISECOND,@StartTime,GETDATE())
		INSERT INTO LogAction(UserID,Session, StoreName,InputNote,OutputNote,SystemDateTime,StartTime,EndTime)
		VALUES(@UserID,@Session, @StoreName,@InputNote,@OutputNote,GETDATE(),@StartTime,GETDATE())
    END
END

GO
/****** Object:  StoredProcedure [core].[usp_User_ActionUserList]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-05
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" UserName="" Password="" Session="" FullName="" Alias="" EmployeeID="1" LanguageID="1"/>
CREATE PROCEDURE [core].[usp_User_ActionUserList]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE 
		@ID						int, 
		@UserName				varchar(50), 
		@Password				varchar(100), 
		@Session				uniqueidentifier, 
		@FullName				nvarchar(256), 
		@Alias					nvarchar(256), 
		@EmployeeID				int, 
		@LanguageID				int, 
		@Status					int, 
		@Action					varchar(100),
		@ReturnMsg				varchar(100)='OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max)

	SELECT 
		@ID						= T.i.value('@ID[1]','int'),
		@UserName				= T.i.value('@UserName[1]','varchar(50)'),
		@Password				= T.i.value('@Password[1]','varchar(100)'),
		@Session				= T.i.value('@Session[1]','uniqueidentifier'),
		@FullName				= T.i.value('@FullName[1]','nvarchar(256)'),
		@Alias					= T.i.value('@Alias[1]','nvarchar(256)'),
		@EmployeeID				= T.i.value('@EmployeeID[1]','int'),
		@LanguageID				= T.i.value('@LanguageID[1]','int'),
		@Status					= T.i.value('@Status[1]','int'),
		@IDs					= T.i.value('@IDs[1]','varchar(max)'), 
		@UserID					= T.i.value('@UserID[1]','int'),
		@Action					= T.i.value('@Action[1]','varchar(50)')
	FROM @InputValue.nodes('RequestParams') T(i)
	IF(@Action ='UPDATE')
	BEGIN
		UPDATE core.UserList
		SET
		UserName				= @UserName,
		--Password				= @Password,
		Session					= @Session,
		FullName				= @FullName,
		Alias					= @Alias,
		EmployeeID				= @EmployeeID,
		LanguageID				= @LanguageID,
		LastUpdatedDateTime		= GETDATE(),
		LastUpdatedBy			= @UserID
		WHERE ID = @ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='INSERT')
	BEGIN
		INSERT INTO core.UserList(
			UserName,
			Password,
			Session,
			FullName,
			Alias,
			EmployeeID,
			LanguageID,
			CreatedBy)
		VALUES(
			@UserName,
			@Password,
			@Session,
			@FullName,
			@Alias,
			@EmployeeID,
			@LanguageID,
			@UserID)
		SET @ID = SCOPE_IDENTITY()
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='UPDATE::CHANGEPASS')
	BEGIN
		DECLARE @OldPass VARCHAR(100),@NewPass VARCHAR(100)
		SELECT @OldPass = T.i.value('@OldPassword[1]','VARCHAR(100)')
			,@NewPass = T.i.value('@NewPassword[1]','VARCHAR(100)')
			,@UserID = T.i.value('@UserID[1]','int')
		FROM @InputValue.nodes('RequestParams') T(i)
		IF(@NewPass IS NULL OR @NewPass ='')
		BEGIN
			SELECT @ReturnMsg ='INVALID_PASSWORD_POLICY'
			SET @ReturnResult = 0
		END
		ELSE
		--Kiem tra mat khau cu dung
		IF(EXISTS(SELECT 1 FROM core.UserList WITH(NOLOCK)
				WHERE ID = @UserID AND Password = @OldPass))
		BEGIN	
			UPDATE core.UserList
			SET [Password] = @NewPass
			WHERE ID = @UserID
			
			SET @ReturnResult = @UserID
		END	
		ELSE
		BEGIN
			SELECT @ReturnMsg ='INVALID_OLDPASSWORD'
			SET @ReturnResult = 0
		END
		
	END
	ELSE IF(@Action ='UPDATE::RESETPASS')
	BEGIN
		EXEC [core].[usp_User_ActionUserList_ResetPass] @InputValue,@OutputValue OUTPUT
		RETURN
	END
	ELSE IF(@Action ='DELETE')
	BEGIN
		UPDATE core.UserList
		SET Status					= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE ID=@ID
		SET @ReturnResult = @ID
	END
	ELSE IF(@Action ='DELETEMULTI')
	BEGIN
		UPDATE core.UserList
		SET Status				= -1
			,LastUpdatedBy			= @UserID
			,LastUpdatedDateTime	= GETDATE()
		WHERE EXISTS(SELECT 1 FROM core.tvf_DTO_MAR_GetListFromString(@IDs) WHERE Item = ID)
		SET @ReturnResult = 1
	END
	ELSE
	BEGIN
		SELECT @ReturnMsg ='INVALID_ACTION'
	END
	
	-- Update Role
	IF(@ReturnMsg ='OK' AND @Action IN ('INSERT','UPDATE'))
	BEGIN
		SET @Inputvalue.modify('insert attribute UserID {sql:variable("@ID")} 
									 into (descendant::RequestParams[not(@UserID)])[1]')
		EXEC [app].[usp_User_ActionUserRole] @InputValue,@OutputValue output
	END
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [core].[usp_User_ActionUserList_ResetPass]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-05
-- Description:	<Description,,>
-- =============================================
-- <InputValue  ID="1" UserName="" Password="" Session="" FullName="" Alias="" EmployeeID="1" LanguageID="1"/>
CREATE PROCEDURE [core].[usp_User_ActionUserList_ResetPass]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE 
		
		@ReturnMsg				varchar(100)='RESETPASS_OK',
		@ReturnResult			int,
		@UserID					int,
		@IDs					varchar(max)

	
	DECLARE @NewPass VARCHAR(100)
	SELECT @NewPass = T.i.value('@Password[1]','VARCHAR(100)')
		,@UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	-- Validate
	IF(@NewPass IS NULL OR @NewPass ='' OR @NewPass='d41d8cd98f00b204e9800998ecf8427e')
	BEGIN
		SELECT @ReturnMsg ='INVALID_PASSWORD_POLICY'
		SET @ReturnResult = 0
	END
	ELSE
	BEGIN
		UPDATE core.UserList
		SET [Password] = @NewPass
		WHERE ID = @UserID
		
		SET @ReturnResult = @UserID
	END	
	EXEC core.usp_GetApplicationMessageWithResult @ReturnMsg,@ReturnResult
END

GO
/****** Object:  StoredProcedure [core].[usp_View_ExecuteAction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [core].[usp_View_ExecuteAction]
	@InputValue XML,
	@OutputValue XML = null output
AS
BEGIN
	DECLARE @Sys_ViewID INT ,@StoreName NVARCHAR(200),@Action VARCHAR(20),@UserID int
	SELECT @Sys_ViewID = T.i.value('@Sys_ViewID[1]','int')
		,@Action = T.i.value('@Action[1]','varchar(20)')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT @UserID = T.i.value('@UserID[1]','int')
	FROM @InputValue.nodes('InputValue') T(i)
	
	DECLARE @IsView BIT,@IsUpdate BIT
		,@IsInsert BIT,@IsDelete BIT
		,@IsSpecial bit
		,@ErrorCode VARCHAR(100) ='OK'
	SELECT @IsView = IsView
		,@IsUpdate = IsUpdate
		,@IsInsert = IsInsert
		,@IsDelete = IsDelete
		,@IsSpecial = IsSpecial
	FROM core.UserView WITH(NOLOCK)
	WHERE ViewID = @Sys_ViewID AND UserID = @UserID
	
	IF(@Action ='INSERT')
	BEGIN	
		--IF(@IsInsert IS NULL OR @IsInsert =0) SET @ErrorCode ='INSERT_DENIED' 
		
		SELECT @StoreName = ManualInsertStore
		FROM core.[VIEW] 
		WHERE ID = @Sys_ViewID
	END
	IF(@Action ='UPDATE')
	BEGIN	
		--IF(@IsUpdate IS NULL OR @IsUpdate =0) SET @ErrorCode ='UPDATE_DENIED' 
		SELECT @StoreName = ManualUpdateStore
		FROM core.[VIEW] 
		WHERE ID = @Sys_ViewID
	END
	IF(@Action LIKE 'UPDATE::%')
	BEGIN	
		--IF(@IsSpecial IS NULL OR @IsSpecial =0) SET @ErrorCode ='UPDATE_DENIED' 
		SELECT @StoreName = ManualUpdateStore
		FROM core.[VIEW] 
		WHERE ID = @Sys_ViewID
	END
	IF(@Action ='DELETE')
	BEGIN	
		--IF(@IsDelete IS NULL OR @IsDelete =0) SET @ErrorCode ='DELETE_DENIED' 
		SELECT @StoreName = ManualUpdateStore
		FROM core.[VIEW] 
		WHERE ID = @Sys_ViewID
	END
	IF(@StoreName IS NULL OR @StoreName ='' )
	BEGIN
		EXEC core.usp_GetApplicationMessageWithResult 'ERROR',0
	END
	ELSE IF(@ErrorCode !='OK')
	BEGIN
		EXEC core.usp_GetApplicationMessageWithResult @ErrorCode,0
	END
	ELSE
	BEGIN
		SET @StoreName  = @StoreName + ' @InputValue'
		EXEC sp_executesql @StoreName ,N'@InputValue xml',@InputValue = @InputValue
	END
	
	
END

GO
/****** Object:  StoredProcedure [core].[usp_View_GetContextData]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [core].[usp_View_GetContextData]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
	
AS
BEGIN
	DECLARE @Sys_ViewID INT ,@GetStoreName NVARCHAR(200)
	SELECT @Sys_ViewID = T.i.value('@Sys_ViewID[1]','int')
	FROM @InputValue.nodes('RequestParams') T(i)
	
	SELECT @GetStoreName = ManualSelectStore
	FROM core.[VIEW] 
	WHERE ID = @Sys_ViewID
	
	IF(@GetStoreName IS NULL OR @GetStoreName ='')
	BEGIN
		DECLARE @SQL NVARCHAR(MAX),@Where NVARCHAR(MAX)
		SELECT @SQL = 'SELECT * FROM ' + MasterTable +' WHERE Status =0 '
				+ CASE WHEN AdditionSQL IS NULL THEN ''
					ELSE 'AND ' + AdditionSQL END
		FROM core.[VIEW] 
		WHERE ID = @Sys_ViewID 
		
		EXEC sp_executesql @SQL
	END
	ELSE
	BEGIN
		SET @GetStoreName  = @GetStoreName + ' @InputValue'
		EXEC sp_executesql @GetStoreName ,N'@InputValue xml',@InputValue = @InputValue
	END
	
	
END

GO
/****** Object:  StoredProcedure [res].[usp_Email_GetMailQueue]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Load template tu cau hinh DataDefinition
-- tao template #EmailData chua cac cot co trong template de replate
-- =============================================
CREATE PROCEDURE [res].[usp_Email_GetMailQueue]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	-- Lay 10 email 
	DECLARE  @tbl AS Table(ID int )
	
	INSERT INTO @tbl
	        ( ID )
	SELECT TOP 10 ID 
	FROM core.MailQueue
	WHERE Status =0
	ORDER BY CreatedDateTime
	
	SELECT *
	FROM core.MailQueue WITH(NOLOCK)
	WHERE ID IN (SELECT ID FROM @tbl)
	
	UPDATE core.MailQueue
	SET Status = 1
	WHERE ID IN (SELECT ID FROM @tbl)
END

GO
/****** Object:  StoredProcedure [res].[usp_Email_LoadTemplate]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Load template tu cau hinh DataDefinition
-- tao template #EmailData chua cac cot co trong template de replate
-- =============================================
CREATE PROCEDURE [res].[usp_Email_LoadTemplate]
	@TemplateCode VARCHAR(100),
	@Subject NVARCHAR(512) OUTPUT,
	@Body NVARCHAR(MAX) OUTPUT
	
AS
BEGIN
	SELECT @Subject =@TemplateCode,@Body ='TEMPLATE NOT FOUND'
	
	SELECT @Subject = ValueString,
		@Body = ValueString2
	FROM core.DataDefination WITH(NOLOCK)
	WHERE TypeCode ='EMAIL_TEMPLATE'
		AND Code = @TemplateCode
	
	IF OBJECT_ID('tempdb..#EmailData') IS NOT NULL
	BEGIN
		--Duyet qua danh sach 
		EXEC res.usp_Email_ReplateTemplateData @Subject OUTPUT
		EXEC res.usp_Email_ReplateTemplateData @Body OUTPUT
	END
	
	
END

GO
/****** Object:  StoredProcedure [res].[usp_Email_ReplateTemplateData]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [res].[usp_Email_ReplateTemplateData]
	@Template NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @TemplateTmp NVARCHAR(max) = @Template
	DECLARE @ReplateQuery NVARCHAR(MAX)
	IF OBJECT_ID('tempdb..#EmailData') IS NOT NULL
	BEGIN
		--Duyet qua danh sach, tim va lay ra chuoi trong ngoac vuon []
		PRINT '  [01] Get parameter name'
		
		DECLARE @DelimiterOpen char(1) = '['
		DECLARE @DelimiterClose char(1) = ']'
		DECLARE @Parameter varchar(50),@ColumnName VARCHAR(50)
		DECLARE @OrderID int
		DECLARE @posOpen int = charindex(@DelimiterOpen, @TemplateTmp)
		DECLARE @posClose int = charindex(@DelimiterClose, @TemplateTmp,@posOpen)
		WHILE (@posOpen <> 0 AND @posClose <>0)
		BEGIN
			SET @Parameter = substring(@TemplateTmp, @posOpen, @posClose - @posOpen + 1)
			SET @ColumnName = substring(@TemplateTmp, @posOpen + 1, @posClose - @posOpen -1)
			PRINT '  + Para:' + @Parameter
			PRINT '  + Template:' + @TemplateTmp
			
			PRINT ' BEGIN REPLACE ' + convert(VARCHAR(50),GETDATE(),109)
			
			--Neu temptable ton tai cot 
			IF(EXISTS(SELECT 1 
					FROM tempdb.sys.columns
					WHERE object_id =  OBJECT_ID('tempdb..#EmailData')
					AND name = @ColumnName)
				)
			BEGIN
				SET @ReplateQuery =  N'SELECT @Template = REPLACE(@Template,@Parameter,'+@Parameter+') 
				FROM #EmailData'
				EXEC sp_executesql @ReplateQuery,N'@Template nvarchar(max) output,@Parameter varchar(50)',@Template = @Template OUTPUT,@Parameter=@Parameter
			END
			
			PRINT ' END REPLACE ' + convert(VARCHAR(50),GETDATE(),109)
			
			SET @TemplateTmp = substring(@TemplateTmp, @posClose +1, len(@TemplateTmp))
			
			SET @posOpen  = charindex(@DelimiterOpen, @TemplateTmp)
			SET @posClose  = charindex(@DelimiterClose, @TemplateTmp,@posOpen)
		END	
	END
	
	
END

GO
/****** Object:  StoredProcedure [rpt].[usp_Shopsign_ProjectSummary]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		nguyenphinam@gmail.com
-- Create date: 2015-08-17
-- Description:	<Description,,>
-- =============================================
-- [rpt].[usp_Shopsign_ProjectSummary] '<InputValue  />'
CREATE PROCEDURE [rpt].[usp_Shopsign_ProjectSummary]
	@InputValue XML,
	@OutputValue XML = NULL OUTPUT
AS
BEGIN
	DECLARE @tblReport AS TABLE(MarketID INT,MarketParentID INT,MarketColor VARCHAR(10),MarketName NVARCHAR(256)
		,Ton INT
		,Request INT
		,Pending INT
		,Survey INT
		,Approve INT
		,Install INT)
	DECLARE @FromDate DATE,@ToDate DATE
	SELECT	 @FromDate ='1900-01-01',@ToDate ='3000-01-01'
	-- insert tat ca market vao
	INSERT INTO @tblReport
	        ( MarketID,MarketParentID,MarketColor,MarketName)
	SELECT ID,ParentID,BackColor ,Code
	FROM app.Area WITH(NOLOCK)
	WHERE Status =0
	
	UPDATE RPT
	SET Ton = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID AND Status != 1 ))
		,Request = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID 
								AND StepNumber = 1 
								AND IntendStartDate BETWEEN @FromDate AND @ToDate)
								)
		,Pending = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID AND Status != 1 ))
		,Survey = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID AND Status = 1 
								AND StepNumber = 2 
								AND CompleteDate BETWEEN @FromDate AND @ToDate)
								)
		,Approve = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID AND Status = 1 
								AND StepNumber = 4 
								AND CompleteDate BETWEEN @FromDate AND @ToDate)
								)
		,Install = (SELECT COUNT(*) 
				FROM app.Project P WITH(NOLOCK) 
					WHERE P.Status =0 AND P.AreaID = RPT.MarketID
					 AND EXISTS(SELECT 1 FROM app.ProjectStep WITH(NOLOCK) 
							WHERE ProjectID = P.ID AND Status = 1 
								AND StepNumber = 5 
								AND CompleteDate BETWEEN @FromDate AND @ToDate)
					)
	FROM @tblReport RPT
	
	
	SELECT * FROM @tblReport
	
END

GO
/****** Object:  UserDefinedFunction [dbo].[DataDefinitionName]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[DataDefinitionName]
(
	@DataCode VARCHAR(100),
	@Index int
)
RETURNS NVARCHAR(256)
AS
BEGIN
	

	DECLARE @result NVARCHAR(256)
	SELECT @result = Name FROM core.DataDefination WITH(NOLOCK)
	WHERE TypeCode = @DataCode AND [Index] = @Index
	
	RETURN @result
END

GO
/****** Object:  Table [app].[Area]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[Area](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [int] NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](256) NULL,
	[ManagerEmployeeID] [int] NULL,
	[BackColor] [varchar](10) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[Department]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[Department](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](256) NULL,
	[Description] [nvarchar](512) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[District]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[District](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](200) NULL,
	[CityID] [int] NULL,
	[Index] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_District] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[Employee]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[Employee](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](256) NOT NULL,
	[Alias] [nvarchar](256) NULL,
	[Email] [varchar](100) NULL,
	[Phone] [varchar](20) NULL,
	[Address] [nvarchar](256) NULL,
	[PositionID] [int] NULL,
	[DepartmentID] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[Position]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[Position](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](256) NULL,
	[Description] [nvarchar](512) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_Position] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[Product]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[Product](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](500) NULL,
	[DistrictID] [int] NULL,
	[WardID] [int] NULL,
	[Address] [nvarchar](2000) NULL,
	[FudPicture] [nvarchar](500) NULL,
	[Struture] [nvarchar](500) NULL,
	[AreaPerFloor] [decimal](18, 2) NULL,
	[AvailableArea] [decimal](18, 2) NULL,
	[AreaDescription] [nvarchar](500) NULL,
	[HirePrice] [decimal](18, 2) NULL,
	[PriceDescription] [nvarchar](1000) NULL,
	[ServiceFee] [nvarchar](500) NULL,
	[VATTax] [nvarchar](500) NULL,
	[TotalPrice] [nvarchar](500) NULL,
	[ParkingFee] [nvarchar](500) NULL,
	[ElectricityFee] [nvarchar](500) NULL,
	[HireDuration] [nvarchar](500) NULL,
	[PrePaid] [nvarchar](500) NULL,
	[Payment] [nvarchar](500) NULL,
	[DecorationTime] [nvarchar](500) NULL,
	[BuildingDirectionID] [int] NULL,
	[BuildingType] [nvarchar](500) NULL,
	[OtherFee] [nvarchar](500) NULL,
	[Description] [text] NULL,
	[ManagerName] [nvarchar](500) NULL,
	[ManagerMobilePhone] [nvarchar](20) NULL,
	[IsHiredWholeBuilding] [bit] NULL,
	[IsGroundFloor] [bit] NULL,
	[Status] [int] NULL,
	[CreateDateTime] [datetime] NULL,
	[CreateByID] [int] NULL,
	[ModifyDateTime] [datetime] NULL,
	[ModifyByID] [int] NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [app].[Project]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[Project](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AgentName] [nvarchar](256) NULL,
	[AgentAddress] [nvarchar](512) NULL,
	[AreaID] [int] NULL,
	[AgentPhone] [nvarchar](50) NULL,
	[AgentContactName] [nvarchar](256) NULL,
	[ApprovedBy] [int] NULL,
	[AreaManagerID] [int] NULL,
	[AttachedPhoto] [int] NULL,
	[CompetitorName] [nvarchar](256) NULL,
	[ComplitionDate] [date] NULL,
	[DealerType] [int] NULL,
	[EstimatedAnnualTurnover] [numeric](18, 0) NULL,
	[HadCCM] [int] NULL,
	[HadCompetitorShopsign] [int] NULL,
	[IsCCM] [int] NULL,
	[RequestObjects] [int] NULL,
	[MasterDealerName] [nvarchar](256) NULL,
	[NumberOfShelf] [int] NULL,
	[NumberOfShopsign] [int] NULL,
	[RequestedBy] [int] NULL,
	[RequestedByName] [nvarchar](256) NULL,
	[RequisitionDate] [date] NULL,
	[ShopsignPlacement] [int] NULL,
	[ShopsignSize] [varchar](50) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[RequestOther] [nvarchar](512) NULL,
	[StepConfigID] [int] NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[ProjectStep]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[ProjectStep](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectID] [int] NULL,
	[StepNumber] [int] NULL,
	[StepName] [nvarchar](256) NULL,
	[EmployeeID] [int] NULL,
	[IntendStartDate] [date] NULL,
	[IntendEndDate] [date] NULL,
	[CompleteDate] [date] NULL,
	[PartnerName] [nvarchar](256) NULL,
	[PartnerEmail] [varchar](100) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[CompleteBy] [int] NULL,
	[RejectBy] [int] NULL,
	[RejectDate] [date] NULL,
	[StartDate] [date] NULL,
	[RejectNote] [nvarchar](512) NULL,
 CONSTRAINT [PK_ProjectStep] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[SimpleData]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[SimpleData](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](100) NULL,
	[Name] [nvarchar](256) NULL,
	[ParentID] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_SimpleData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [app].[StepConfig]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [app].[StepConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](100) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_StepConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [app].[StepConfigDetail]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[StepConfigDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StepConfigID] [int] NULL,
	[StepNumber] [int] NULL,
	[IntendDays] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_StepConfigDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [app].[Ward]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [app].[Ward](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](250) NULL,
	[DistrictID] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Ward] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [core].[ApplicationMessage]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[ApplicationMessage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](256) NULL,
	[Type] [int] NOT NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_ApplicationMessage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[DataDefination]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[DataDefination](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypeCode] [varchar](50) NULL,
	[Type] [int] NULL,
	[Code] [nvarchar](100) NULL,
	[Name] [nvarchar](512) NULL,
	[Index] [int] NULL,
	[ParentID] [int] NULL,
	[Value] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[ValueString] [nvarchar](max) NULL,
	[ValueString2] [nvarchar](max) NULL,
 CONSTRAINT [PK_DataDefination] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[InterfaceFunction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[InterfaceFunction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ViewID] [int] NULL,
	[Code] [varchar](20) NULL,
	[Name] [nvarchar](100) NULL,
	[State] [nchar](100) NULL,
	[Title] [nvarchar](256) NULL,
	[ParentID] [int] NULL,
	[LinkURL] [varchar](256) NULL,
	[ZOrder] [int] NULL,
	[Status] [int] NOT NULL,
	[IsDefault] [bit] NULL,
	[IsLoad] [bit] NULL,
	[FormControlType] [varchar](256) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[ChildCount] [int] NULL,
	[OpenType] [int] NULL,
	[CssIcon] [varchar](max) NULL,
	[LabelCss] [varchar](max) NULL,
	[BGMetro] [nvarchar](100) NULL,
	[IconMetro] [nvarchar](100) NULL,
 CONSTRAINT [PK_InterfaceFunction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[LogAction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[LogAction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[Session] [varchar](36) NULL,
	[StoreName] [varchar](128) NULL,
	[InputNote] [nvarchar](max) NULL,
	[OutputNote] [nvarchar](max) NULL,
	[SystemDateTime] [datetime] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
 CONSTRAINT [PK_LogAction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[MailQueue]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[MailQueue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MailFrom] [varchar](100) NULL,
	[MailTo] [varchar](max) NULL,
	[Subject] [nvarchar](512) NULL,
	[Body] [nvarchar](max) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedUserID] [int] NULL,
	[UpdatedDateTime] [datetime] NULL,
	[UpdatedUserID] [int] NULL,
 CONSTRAINT [PK_MailQueue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[SystemConfig]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[SystemConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [nvarchar](80) NULL,
	[Value] [sql_variant] NULL,
	[ClientGroup] [int] NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_SystemConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[SystemFunction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[SystemFunction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Schema] [nchar](10) NULL,
	[StoreProcedureName] [varchar](80) NULL,
	[IsPublic] [bit] NULL,
	[IsReturnApplicationMessage] [bit] NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_SystemFunction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[UserGroup]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[UserGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClientGroupID] [int] NULL,
	[Code] [varchar](20) NULL,
	[Name] [nvarchar](100) NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[ParentID] [int] NULL,
	[Description] [nvarchar](256) NULL,
 CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[UserGroupInterfaceFunction]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[UserGroupInterfaceFunction](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserGroupID] [int] NOT NULL,
	[InterfaceFunctionID] [int] NOT NULL,
	[Permission] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_UserGroupInterfaceFunction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [core].[UserGroupUser]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[UserGroupUser](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[UserGroupID] [int] NOT NULL,
	[Status] [int] NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_UserGroupUser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [core].[UserList]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[UserList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](100) NOT NULL,
	[Session] [uniqueidentifier] NULL,
	[FullName] [nvarchar](256) NULL,
	[Alias] [nvarchar](256) NULL,
	[EmployeeID] [int] NULL,
	[LanguageID] [int] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_UserList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [core].[UserView]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[UserView](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ViewID] [int] NOT NULL,
	[IsView] [bit] NULL,
	[IsInsert] [bit] NULL,
	[IsUpdate] [bit] NULL,
	[IsDelete] [bit] NULL,
	[IsSpecial] [bit] NULL,
	[State] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
 CONSTRAINT [PK_UserView] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [core].[View]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [core].[View](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [int] NULL,
	[Code] [varchar](64) NULL,
	[Name] [nvarchar](100) NULL,
	[Title] [nvarchar](100) NULL,
	[Description] [nvarchar](100) NULL,
	[MasterTable] [varchar](50) NULL,
	[AdditionSQL] [varchar](512) NULL,
	[UIOptionsExtends] [nvarchar](max) NULL,
	[ManualSelectStore] [varchar](100) NULL,
	[ManualInsertStore] [varchar](100) NULL,
	[ManualUpdateStore] [varchar](100) NULL,
	[Type] [varchar](20) NULL,
	[IsList] [tinyint] NOT NULL,
	[IsView] [tinyint] NULL,
	[IsInsert] [tinyint] NULL,
	[IsUpdate] [tinyint] NULL,
	[Status] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[CreatedUserID] [int] NULL,
	[LastUpdatedDateTime] [datetime] NULL,
	[LastUpdatedUserID] [int] NULL,
	[InheritID] [int] NULL,
	[Model] [varchar](100) NULL,
	[LoadOptions] [varchar](50) NULL,
	[UpdateAction] [varchar](50) NULL,
 CONSTRAINT [PK_View] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 1/25/2016 5:02:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [app].[Area] ADD  CONSTRAINT [DF_Area_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Area] ADD  CONSTRAINT [DF_Area_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[Department] ADD  CONSTRAINT [DF_Department_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Department] ADD  CONSTRAINT [DF_Department_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[District] ADD  CONSTRAINT [DF_District_ZOrder]  DEFAULT ((0)) FOR [Index]
GO
ALTER TABLE [app].[District] ADD  CONSTRAINT [DF_District_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Employee] ADD  CONSTRAINT [DF_Employee_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Employee] ADD  CONSTRAINT [DF_Employee_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[Position] ADD  CONSTRAINT [DF_Position_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Position] ADD  CONSTRAINT [DF_Position_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[Product] ADD  CONSTRAINT [DF_Product_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
GO
ALTER TABLE [app].[Project] ADD  CONSTRAINT [DF_Project_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[Project] ADD  CONSTRAINT [DF_Project_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[ProjectStep] ADD  CONSTRAINT [DF_ProjectStep_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[ProjectStep] ADD  CONSTRAINT [DF_ProjectStep_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[SimpleData] ADD  CONSTRAINT [DF_SimpleData_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[SimpleData] ADD  CONSTRAINT [DF_SimpleData_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[StepConfig] ADD  CONSTRAINT [DF_StepConfig_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[StepConfig] ADD  CONSTRAINT [DF_StepConfig_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[StepConfigDetail] ADD  CONSTRAINT [DF_StepConfigDetail_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [app].[StepConfigDetail] ADD  CONSTRAINT [DF_StepConfigDetail_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [app].[Ward] ADD  CONSTRAINT [DF_Ward_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[ApplicationMessage] ADD  CONSTRAINT [DF_ApplicationMessage_Type]  DEFAULT ((0)) FOR [Type]
GO
ALTER TABLE [core].[DataDefination] ADD  CONSTRAINT [DF_DataDefination_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[DataDefination] ADD  CONSTRAINT [DF_DataDefination_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_ParentID]  DEFAULT ((0)) FOR [ParentID]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_IsLoad]  DEFAULT ((0)) FOR [IsLoad]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_OpenType]  DEFAULT ((0)) FOR [OpenType]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_CssIcon]  DEFAULT ('fa fa-users text-success') FOR [CssIcon]
GO
ALTER TABLE [core].[InterfaceFunction] ADD  CONSTRAINT [DF_InterfaceFunction_LabelCss]  DEFAULT ('fa fa-angle-left') FOR [LabelCss]
GO
ALTER TABLE [core].[MailQueue] ADD  CONSTRAINT [DF_MailQueue_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[MailQueue] ADD  CONSTRAINT [DF_MailQueue_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[UserGroup] ADD  CONSTRAINT [DF_UserGroup_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[UserGroup] ADD  CONSTRAINT [DF_UserGroup_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[UserGroup] ADD  CONSTRAINT [DF_UserGroup_LastUpdatedDateTime]  DEFAULT (getdate()) FOR [LastUpdatedDateTime]
GO
ALTER TABLE [core].[UserGroupInterfaceFunction] ADD  CONSTRAINT [DF_UserGroupInterfaceFunction_Permission]  DEFAULT ((0)) FOR [Permission]
GO
ALTER TABLE [core].[UserGroupInterfaceFunction] ADD  CONSTRAINT [DF_UserGroupInterfaceFunction_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[UserGroupInterfaceFunction] ADD  CONSTRAINT [DF_UserGroupInterfaceFunction_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[UserGroupUser] ADD  CONSTRAINT [DF_UserGroupUser_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[UserGroupUser] ADD  CONSTRAINT [DF_UserGroupUser_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[UserList] ADD  CONSTRAINT [DF_UserList_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[UserList] ADD  CONSTRAINT [DF_UserList_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[UserView] ADD  CONSTRAINT [DF_UserView_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[UserView] ADD  CONSTRAINT [DF_UserView_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [core].[View] ADD  CONSTRAINT [DF_View_IsList]  DEFAULT ((0)) FOR [IsList]
GO
ALTER TABLE [core].[View] ADD  CONSTRAINT [DF_View_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [core].[View] ADD  CONSTRAINT [DF_View_CreatedDateTime]  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
