--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys

]]

--// Cache

local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	-- Auxillary functions - if the executor doesn't support "getrawmetatable".

	__index = function(self, Index)
		return self[Index]
	end,

	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local getrenderproperty, setrenderproperty = getrenderproperty or __index, setrenderproperty or __newindex

local GetService = __index(game, "GetService")

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")
local GuiService = GetService(game, "GuiService")

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}
local Connect, Disconnect = __index(game, "DescendantAdded").Connect

--// Mobile Support Variables
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local TouchInputFrame = nil
local TouchStartPosition = nil
local TouchCurrentPosition = nil
local IsTouching = false

--[[
local Degrade = false

do
	xpcall(function()
		local TemporaryDrawing = Drawingnew("Line")
		getrenderproperty = getupvalue(getmetatable(TemporaryDrawing).__index, 4)
		setrenderproperty = getupvalue(getmetatable(TemporaryDrawing).__newindex, 4)
		TemporaryDrawing.Remove(TemporaryDrawing)
	end, function()
		Degrade, getrenderproperty, setrenderproperty = true, function(Object, Key)
			return Object[Key]
		end, function(Object, Key, Value)
			Object[Key] = Value
		end
	end)

	local TemporaryConnection = Connect(__index(game, "DescendantAdded"), function() end)
	Disconnect = TemporaryConnection.Disconnect
	Disconnect(TemporaryConnection)
end
]]

--// Checking for multiple processes

if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
	ExunysDeveloperAimbot:Exit()
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1 -- Bigger = Slower
	},

	Settings = {
		Enabled = true,

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		Sensitivity2 = 3.5, -- mousemoverel Sensitivity

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false,
		
		-- Mobile Settings
		MobileTrigger = "Touch", -- "Touch", "Button", or "Both"
		MobileButtonSize = 80,
		MobileButtonPosition = Vector2new(50, 50),
		MobileButtonTransparency = 0.5
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 90,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	FOVCircleOutline = Drawingnew("Circle"),
	FOVCircle = Drawingnew("Circle"),
	
	-- Mobile UI Elements
	MobileUI = {
		AimButton = nil,
		AimButtonFrame = nil
	}
}

local Environment = getgenv().ExunysDeveloperAimbot

setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)

--// Core Functions

local FixUsername = function(String)
	local Result

	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")

		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
		end
	end

	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed

	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil

	local FOVCircle = Environment.FOVCircle--Degrade and Environment.FOVCircle or Environment.FOVCircle.__OBJECT

	setrenderproperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	__newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)

	if Animation then
		Animation:Cancel()
	end
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

		for _, Value in next, GetPlayers(Players) do
			local Character = __index(Value, "Character")
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")

			if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, __index(Value, "Name")) and Character and FindFirstChild(Character, LockPart) and Humanoid then
				local PartPosition, TeamCheckOption = __index(Character[LockPart], "Position"), Environment.DeveloperSettings.TeamCheckOption

				if Settings.TeamCheck and __index(Value, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
					continue
				end

				if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
					continue
				end

				if Settings.WallCheck then
					local BlacklistTable = GetDescendants(__index(LocalPlayer, "Character"))

					for _, Value in next, GetDescendants(Character) do
						BlacklistTable[#BlacklistTable + 1] = Value
					end

					if #GetPartsObscuringTarget(Camera, {PartPosition}, BlacklistTable) > 0 then
						continue
					end
				end

				local Vector, OnScreen, Distance = WorldToViewportPoint(Camera, PartPosition)
				Vector = ConvertVector(Vector)
				
				-- Use touch position for mobile, mouse position for desktop
				local InputPosition = IsMobile and (TouchCurrentPosition or GetMouseLocation(UserInputService)) or GetMouseLocation(UserInputService)
				Distance = (InputPosition - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
	else
		local LockedPosition = ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))
		local InputPosition = IsMobile and (TouchCurrentPosition or GetMouseLocation(UserInputService)) or GetMouseLocation(UserInputService)
		
		if (InputPosition - LockedPosition).Magnitude > RequiredDistance then
			CancelLock()
		end
	end
end

--// Mobile Support Functions

local CreateMobileUI = function()
	if not IsMobile then return end
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ExunysAimbotMobileUI"
	ScreenGui.DisplayOrder = 10
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	
	local AimButton = Instance.new("TextButton")
	AimButton.Name = "AimButton"
	AimButton.Size = UDim2.new(0, Environment.Settings.MobileButtonSize, 0, Environment.Settings.MobileButtonSize)
	AimButton.Position = UDim2.new(0, Environment.Settings.MobileButtonPosition.X, 0, Environment.Settings.MobileButtonPosition.Y)
	AimButton.BackgroundColor3 = Color3fromRGB(255, 255, 255)
	AimButton.BackgroundTransparency = Environment.Settings.MobileButtonTransparency
	AimButton.Text = "AIM"
	AimButton.TextColor3 = Color3fromRGB(0, 0, 0)
	AimButton.TextScaled = true
	AimButton.BorderSizePixel = 0
	AimButton.ZIndex = 10
	AimButton.Parent = ScreenGui
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Environment.Settings.MobileButtonSize / 4)
	Corner.Parent = AimButton
	
	Environment.MobileUI.AimButton = AimButton
	Environment.MobileUI.AimButtonFrame = ScreenGui
end

local HandleMobileInput = function()
	if not IsMobile then return end
	
	local Settings = Environment.Settings
	
	-- Touch input handling
	ServiceConnections.TouchStarted = Connect(__index(UserInputService, "TouchStarted"), function(Input, Processed)
		if Processed or Typing then return end
		
		if Settings.MobileTrigger == "Touch" or Settings.MobileTrigger == "Both" then
			TouchStartPosition = Input.Position
			TouchCurrentPosition = Input.Position
			IsTouching = true
			Running = true
		end
	end)
	
	ServiceConnections.TouchMoved = Connect(__index(UserInputService, "TouchMoved"), function(Input, Processed)
		if Processed or not IsTouching then return end
		TouchCurrentPosition = Input.Position
	end)
	
	ServiceConnections.TouchEnded = Connect(__index(UserInputService, "TouchEnded"), function(Input, Processed)
		if Processed then return end
		
		if Settings.MobileTrigger == "Touch" or Settings.MobileTrigger == "Both" then
			IsTouching = false
			TouchCurrentPosition = nil
			
			if not Settings.Toggle then
				Running = false
				CancelLock()
			end
		end
	end)
	
	-- Button input handling
	if Environment.MobileUI.AimButton then
		ServiceConnections.MobileButtonDown = Connect(__index(Environment.MobileUI.AimButton, "MouseButton1Down"), function()
			if Settings.MobileTrigger == "Button" or Settings.MobileTrigger == "Both" then
				if Settings.Toggle then
					Running = not Running
					if not Running then
						CancelLock()
					end
				else
					Running = true
				end
			end
		end)
		
		ServiceConnections.MobileButtonUp = Connect(__index(Environment.MobileUI.AimButton, "MouseButton1Up"), function()
			if (Settings.MobileTrigger == "Button" or Settings.MobileTrigger == "Both") and not Settings.Toggle then
				Running = false
				CancelLock()
			end
		end)
	end
end

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	--[[
	if not Degrade then
		FOVCircle, FOVCircleOutline = FOVCircle.__OBJECT, FOVCircleOutline.__OBJECT
	end
	]]
	
	-- Create mobile UI if on mobile
	if IsMobile then
		CreateMobileUI()
		HandleMobileInput()
	end

	ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
		local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

		if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				if Index == "Color" then
					continue
				end

				if pcall(getrenderproperty, FOVCircle, Index) then
					setrenderproperty(FOVCircle, Index, Value)
					setrenderproperty(FOVCircleOutline, Index, Value)
				end
			end

			setrenderproperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)

			setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			
			-- Use touch position for mobile FOV circle
			local InputPosition = IsMobile and (TouchCurrentPosition or GetMouseLocation(UserInputService)) or GetMouseLocation(UserInputService)
			setrenderproperty(FOVCircle, "Position", InputPosition)
			setrenderproperty(FOVCircleOutline, "Position", InputPosition)
		else
			setrenderproperty(FOVCircle, "Visible", false)
			setrenderproperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()

			Offset = OffsetToMoveDirection and __index(FindFirstChildOfClass(__index(Environment.Locked, "Character"), "Humanoid"), "MoveDirection") * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero

			if Environment.Locked then
				local LockedPosition_Vector3 = __index(__index(Environment.Locked, "Character")[LockPart], "Position")
				local LockedPosition = WorldToViewportPoint(Camera, LockedPosition_Vector3 + Offset)
				
				local InputPosition = IsMobile and (TouchCurrentPosition or GetMouseLocation(UserInputService)) or GetMouseLocation(UserInputService)

				if Environment.Settings.LockMode == 2 then
					if not IsMobile then -- mousemoverel doesn't work on mobile
						mousemoverel((LockedPosition.X - InputPosition.X) / Settings.Sensitivity2, (LockedPosition.Y - InputPosition.Y) / Settings.Sensitivity2)
					end
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
						Animation:Play()
					else
						__newindex(Camera, "CFrame", CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset))
					end

					if not IsMobile then -- Mouse sensitivity doesn't affect mobile
						__newindex(UserInputService, "MouseDeltaSensitivity", 0)
					end
				end

				setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing or IsMobile then -- Skip desktop input handling on mobile
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running

				if not Running then
					CancelLock()
				end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Toggle or Typing or IsMobile then -- Skip desktop input handling on mobile
			return
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Functions

function Environment.Exit(self) -- METHOD | ExunysDeveloperAimbot:Exit(<void>)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")

	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
	
	-- Clean up mobile UI
	if IsMobile and Environment.MobileUI.AimButtonFrame then
		Environment.MobileUI.AimButtonFrame:Destroy()
	end

	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil
	CreateMobileUI = nil; HandleMobileInput = nil

	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart() -- ExunysDeveloperAimbot.Restart(<void>)
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
	
	-- Clean up mobile UI
	if IsMobile and Environment.MobileUI.AimButtonFrame then
		Environment.MobileUI.AimButtonFrame:Destroy()
	end

	Load()
end

function Environment.Blacklist(self, Username) -- METHOD | ExunysDeveloperAimbot:Blacklist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")

	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username) -- METHOD | ExunysDeveloperAimbot:Whitelist(<string> Player Name)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)

	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")

	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer() -- ExunysDeveloperAimbot.GetClosestPlayer(<void>)
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()

	return Value
end

-- Mobile-specific functions
function Environment.SetMobileButtonPosition(self, Position) -- METHOD | ExunysDeveloperAimbot:SetMobileButtonPosition(<Vector2> Position)
	assert(self, "EXUNYS_AIMBOT-V3.SetMobileButtonPosition: Missing parameter #1 \"self\" <table>.")
	assert(Position, "EXUNYS_AIMBOT-V3.SetMobileButtonPosition: Missing parameter #2 \"Position\" <Vector2>.")
	
	self.Settings.MobileButtonPosition = Position
	
	if IsMobile and self.MobileUI.AimButton then
		self.MobileUI.AimButton.Position = UDim2.new(0, Position.X, 0, Position.Y)
	end
end

function Environment.SetMobileButtonSize(self, Size) -- METHOD | ExunysDeveloperAimbot:SetMobileButtonSize(<number> Size)
	assert(self, "EXUNYS_AIMBOT-V3.SetMobileButtonSize: Missing parameter #1 \"self\" <table>.")
	assert(Size, "EXUNYS_AIMBOT-V3.SetMobileButtonSize: Missing parameter #2 \"Size\" <number>.")
	
	self.Settings.MobileButtonSize = Size
	
	if IsMobile and self.MobileUI.AimButton then
		self.MobileUI.AimButton.Size = UDim2.new(0, Size, 0, Size)
		
		-- Update corner radius
		local Corner = self.MobileUI.AimButton:FindFirstChild("UICorner")
		if Corner then
			Corner.CornerRadius = UDim.new(0, Size / 4)
		end
	end
end

function Environment.SetMobileButtonTransparency(self, Transparency) -- METHOD | ExunysDeveloperAimbot:SetMobileButtonTransparency(<number> Transparency)
	assert(self, "EXUNYS_AIMBOT-V3.SetMobileButtonTransparency: Missing parameter #1 \"self\" <table>.")
	assert(Transparency, "EXUNYS_AIMBOT-V3.SetMobileButtonTransparency: Missing parameter #2 \"Transparency\" <number>.")
	
	self.Settings.MobileButtonTransparency = Transparency
	
	if IsMobile and self.MobileUI.AimButton then
		self.MobileUI.AimButton.BackgroundTransparency = Transparency
	end
end

Environment.Load = Load -- ExunysDeveloperAimbot.Load()

setmetatable(Environment, {__call = Load})

return Environment
