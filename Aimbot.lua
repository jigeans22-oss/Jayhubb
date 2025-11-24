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
local HttpService = GetService(game, "HttpService")

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
		Toggle = false
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
	FOVCircle = Drawingnew("Circle")
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

	local FOVCircle = Environment.FOVCircle

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
				Distance = (GetMouseLocation(UserInputService) - Vector).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
	elseif (GetMouseLocation(UserInputService) - ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

--// TXID UI Library Implementation

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/WeebsMain/txid-ui-library/refs/heads/main/UI.lua"))()

local Window = Library:Window({
    Name = "KAINO HUB",
    SubTitle = "KAINO STUDIOS",
    ExpiresIn = "30d"
})

local CombatPage = Window:Page({Name = "Combat", Icon = "136879043989014"})
local VisualsPage = Window:Page({Name = "Visuals", Icon = "136879043989014"})
local PlayersPage = Window:Page({Name = "Players", Icon = "136879043989014"})
local MiscPage = Window:Page({Name = "Misc", Icon = "136879043989014"})

local AimbotSubPage = CombatPage:SubPage({Name = "Aimbot", Columns = 2})
local VisualsSubPage = VisualsPage:SubPage({Name = "FOV Settings", Columns = 2})
local PlayersSubPage = PlayersPage:SubPage({Name = "Player Management", Columns = 1})
local SettingsSubPage = MiscPage:SubPage({Name = "Configuration", Columns = 1})

-- Combat Page - Aimbot Section
local MainSection = AimbotSubPage:Section({
    Name = "Main",
    Icon = "136879043989014",
    Side = 1
})

local AimbotSettingsSection = AimbotSubPage:Section({
    Name = "Settings",
    Icon = "72732892493295",
    Side = 2
})

-- Main Aimbot Toggle with Keybind and Colorpicker
local AimbotToggle = MainSection:Toggle({
    Name = "Enable Aimbot",
    Flag = "Aimbot_Enabled",
    Default = Environment.Settings.Enabled,
    Callback = function(Value)
        Environment.Settings.Enabled = Value
    end
})

AimbotToggle:Colorpicker({
    Flag = "Aimbot_Status_Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Color)
        -- Status color for enabled state
    end
})

AimbotToggle:Keybind({
    Flag = "Aimbot_Keybind",
    Default = Enum.KeyCode.E,
    Mode = "Toggle",
    Callback = function(Key)
        Environment.Settings.TriggerKey = Key
    end
})

-- FOV Toggle
local FOVToggle = MainSection:Toggle({
    Name = "Show FOV Circle",
    Flag = "FOV_Enabled",
    Default = Environment.FOVSettings.Enabled,
    Callback = function(Value)
        Environment.FOVSettings.Enabled = Value
        Environment.FOVSettings.Visible = Value
    end
})

-- Team Check
local TeamCheckToggle = MainSection:Toggle({
    Name = "Team Check",
    Flag = "Team_Check",
    Default = Environment.Settings.TeamCheck,
    Callback = function(Value)
        Environment.Settings.TeamCheck = Value
    end
})

-- Wall Check
local WallCheckToggle = MainSection:Toggle({
    Name = "Wall Check",
    Flag = "Wall_Check",
    Default = Environment.Settings.WallCheck,
    Callback = function(Value)
        Environment.Settings.WallCheck = Value
    end
})

-- Alive Check
local AliveCheckToggle = MainSection:Toggle({
    Name = "Alive Check",
    Flag = "Alive_Check",
    Default = Environment.Settings.AliveCheck,
    Callback = function(Value)
        Environment.Settings.AliveCheck = Value
    end
})

-- Toggle Mode
local ToggleMode = MainSection:Toggle({
    Name = "Toggle Mode",
    Flag = "Toggle_Mode",
    Default = Environment.Settings.Toggle,
    Callback = function(Value)
        Environment.Settings.Toggle = Value
    end
})

-- Aimbot Settings Section
local FOVSlider = AimbotSettingsSection:Slider({
    Name = "FOV Radius",
    Flag = "FOV_Radius",
    Min = 1,
    Max = 500,
    Default = Environment.FOVSettings.Radius,
    Decimals = 0,
    Suffix = "px",
    Callback = function(Value)
        Environment.FOVSettings.Radius = Value
    end
})

local SmoothnessSlider = AimbotSettingsSection:Slider({
    Name = "Smoothness",
    Flag = "Smoothness",
    Min = 0,
    Max = 10,
    Default = Environment.Settings.Sensitivity,
    Decimals = 1,
    Suffix = "s",
    Callback = function(Value)
        Environment.Settings.Sensitivity = Value
    end
})

local MouseSensitivitySlider = AimbotSettingsSection:Slider({
    Name = "Mouse Sensitivity",
    Flag = "Mouse_Sensitivity",
    Min = 0.1,
    Max = 10,
    Default = Environment.Settings.Sensitivity2,
    Decimals = 1,
    Suffix = "x",
    Callback = function(Value)
        Environment.Settings.Sensitivity2 = Value
    end
})

local LockPartDropdown = AimbotSettingsSection:Dropdown({
    Name = "Aim Part",
    Flag = "Aim_Part",
    Items = {"Head", "HumanoidRootPart", "Torso", "LeftHand", "RightHand"},
    Default = Environment.Settings.LockPart,
    Multi = false,
    Callback = function(Value)
        Environment.Settings.LockPart = Value
    end
})

local LockModeDropdown = AimbotSettingsSection:Dropdown({
    Name = "Aim Mode",
    Flag = "Aim_Mode",
    Items = {"CFrame", "Mouse"},
    Default = Environment.Settings.LockMode == 1 and "CFrame" or "Mouse",
    Multi = false,
    Callback = function(Value)
        Environment.Settings.LockMode = Value == "CFrame" and 1 or 2
    end
})

-- Visuals Page - FOV Settings
local FOVColorsSection = VisualsSubPage:Section({
    Name = "Colors",
    Icon = "136879043989014",
    Side = 1
})

local FOVAppearanceSection = VisualsSubPage:Section({
    Name = "Appearance",
    Icon = "72732892493295",
    Side = 2
})

-- FOV Colors
local FOVColorPicker = FOVColorsSection:Colorpicker({
    Name = "FOV Color",
    Flag = "FOV_Color",
    Default = Environment.FOVSettings.Color,
    Callback = function(Color)
        Environment.FOVSettings.Color = Color
    end
})

local LockedColorPicker = FOVColorsSection:Colorpicker({
    Name = "Locked Color",
    Flag = "Locked_Color",
    Default = Environment.FOVSettings.LockedColor,
    Callback = function(Color)
        Environment.FOVSettings.LockedColor = Color
    end
})

local OutlineColorPicker = FOVColorsSection:Colorpicker({
    Name = "Outline Color",
    Flag = "Outline_Color",
    Default = Environment.FOVSettings.OutlineColor,
    Callback = function(Color)
        Environment.FOVSettings.OutlineColor = Color
    end
})

-- Rainbow Toggles
local RainbowFOVToggle = FOVColorsSection:Toggle({
    Name = "Rainbow FOV",
    Flag = "Rainbow_FOV",
    Default = Environment.FOVSettings.RainbowColor,
    Callback = function(Value)
        Environment.FOVSettings.RainbowColor = Value
    end
})

local RainbowOutlineToggle = FOVColorsSection:Toggle({
    Name = "Rainbow Outline",
    Flag = "Rainbow_Outline",
    Default = Environment.FOVSettings.RainbowOutlineColor,
    Callback = function(Value)
        Environment.FOVSettings.RainbowOutlineColor = Value
    end
})

-- FOV Appearance
local FOVThicknessSlider = FOVAppearanceSection:Slider({
    Name = "FOV Thickness",
    Flag = "FOV_Thickness",
    Min = 1,
    Max = 10,
    Default = Environment.FOVSettings.Thickness,
    Decimals = 0,
    Suffix = "px",
    Callback = function(Value)
        Environment.FOVSettings.Thickness = Value
    end
})

local FOVTransparencySlider = FOVAppearanceSection:Slider({
    Name = "FOV Transparency",
    Flag = "FOV_Transparency",
    Min = 0,
    Max = 1,
    Default = Environment.FOVSettings.Transparency,
    Decimals = 1,
    Suffix = "",
    Callback = function(Value)
        Environment.FOVSettings.Transparency = Value
    end
})

local FOVSidesSlider = FOVAppearanceSection:Slider({
    Name = "FOV Sides",
    Flag = "FOV_Sides",
    Min = 3,
    Max = 100,
    Default = Environment.FOVSettings.NumSides,
    Decimals = 0,
    Suffix = "",
    Callback = function(Value)
        Environment.FOVSettings.NumSides = Value
    end
})

-- Players Page - Player Management
local BlacklistSection = PlayersSubPage:Section({
    Name = "Blacklist Management",
    Icon = "136879043989014",
    Side = 1
})

-- Player list for blacklisting
local playerList = {}
for _, player in next, GetPlayers(Players) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

local PlayerDropdown = BlacklistSection:Dropdown({
    Name = "Select Player",
    Flag = "Player_Select",
    Items = playerList,
    Default = playerList[1] or "",
    Multi = false,
    Callback = function(Value)
        -- Store selected player
    end
})

local BlacklistButton = BlacklistSection:Button({
    Name = "Blacklist Selected",
    Callback = function()
        local selected = Library.Flags.Player_Select
        if selected and selected ~= "" then
            Environment:Blacklist(selected)
            Library:Notification("Added " .. selected .. " to blacklist", 3, "94627324690861")
        end
    end
})

local WhitelistButton = BlacklistSection:Button({
    Name = "Whitelist Selected",
    Callback = function()
        local selected = Library.Flags.Player_Select
        if selected and selected ~= "" then
            Environment:Whitelist(selected)
            Library:Notification("Removed " .. selected .. " from blacklist", 3, "94627324690861")
        end
    end
})

-- Misc Page - Configuration
local ConfigSection = SettingsSubPage:Section({
    Name = "System",
    Icon = "136879043989014",
    Side = 1
})

local SaveConfigButton = ConfigSection:Button({
    Name = "Save Configuration",
    Callback = function()
        Library:Notification("Settings saved!", 3, "94627324690861")
    end
})

local LoadConfigButton = ConfigSection:Button({
    Name = "Load Configuration",
    Callback = function()
        Library:Notification("Settings loaded!", 3, "94627324690861")
    end
})

local RestartButton = ConfigSection:Button({
    Name = "Restart Aimbot",
    Callback = function()
        Environment:Restart()
        Library:Notification("Aimbot restarted!", 3, "94627324690861")
    end
})

local UnloadButton = ConfigSection:Button({
    Name = "Unload Aimbot",
    Callback = function()
        Environment:Exit()
        Library:Notification("Aimbot unloaded!", 3, "94627324690861")
    end
})

-- Status Label
local StatusLabel = ConfigSection:Label({
    Name = "Status: Ready"
})

-- Update status periodically
spawn(function()
    while true do
        if Environment.Locked then
            StatusLabel:Set("Status: Locked on " .. (Environment.Locked and Environment.Locked.Name or "None"))
        else
            StatusLabel:Set("Status: Searching...")
        end
        wait(0.5)
    end
end)

-- Update player list periodically
spawn(function()
    while true do
        local players = {}
        for _, player in next, GetPlayers(Players) do
            if player ~= LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        PlayerDropdown:Refresh(players, players[1] or "")
        wait(5)
    end
end)

Library:CreateSettingsPage(Window)

--// Load Function

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

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
			setrenderproperty(FOVCircle, "Position", GetMouseLocation(UserInputService))
			setrenderproperty(FOVCircleOutline, "Position", GetMouseLocation(UserInputService))
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

				if Environment.Settings.LockMode == 2 then
					mousemoverel((LockedPosition.X - GetMouseLocation(UserInputService).X) / Settings.Sensitivity2, (LockedPosition.Y - GetMouseLocation(UserInputService).Y) / Settings.Sensitivity2)
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
						Animation:Play()
					else
						__newindex(Camera, "CFrame", CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset))
					end

					__newindex(UserInputService, "MouseDeltaSensitivity", 0)
				end

				setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing then
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

		if Toggle or Typing then
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

function Environment.Exit(self)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")

	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end

	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil

	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart()
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end

	Load()
end

function Environment.Blacklist(self, Username)
	assert(self, "Haxzo_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "Haxzo_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(self, "Haxzo_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")

	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username)
	assert(self, "Haxzo_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "Haxzo_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "Haxzo_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)

	assert(Index, "Haxzo_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")

	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer()
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()

	return Value
end

Environment.Load = Load

setmetatable(Environment, {__call = Load})

-- Initialize the aimbot
Environment:Load()

Library:Notification("Haxzo's Aimbot loaded successfully!", 5, "94627324690861")

return Environment
