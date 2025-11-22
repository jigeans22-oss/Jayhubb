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

--// Rayfield GUI Implementation

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Haxzo's",
   LoadingTitle = "Haxzo aimbot",
   LoadingSubtitle = "by Haxzo",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Haxzoaimbot",
      FileName = "Configuration"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Main Toggle
local MainToggle = Window:CreateTab("Main", 4483362458)

local AimbotToggle = MainToggle:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = Environment.Settings.Enabled,
   Flag = "AimbotEnabled",
   Callback = function(Value)
      Environment.Settings.Enabled = Value
   end,
})

local FOVToggle = MainToggle:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = Environment.FOVSettings.Enabled,
   Flag = "FOVEnabled",
   Callback = function(Value)
      Environment.FOVSettings.Enabled = Value
      Environment.FOVSettings.Visible = Value
   end,
})

local TeamCheckToggle = MainToggle:CreateToggle({
   Name = "Team Check",
   CurrentValue = Environment.Settings.TeamCheck,
   Flag = "TeamCheck",
   Callback = function(Value)
      Environment.Settings.TeamCheck = Value
   end,
})

local WallCheckToggle = MainToggle:CreateToggle({
   Name = "Wall Check",
   CurrentValue = Environment.Settings.WallCheck,
   Flag = "WallCheck",
   Callback = function(Value)
      Environment.Settings.WallCheck = Value
   end,
})

local AliveCheckToggle = MainToggle:CreateToggle({
   Name = "Alive Check",
   CurrentValue = Environment.Settings.AliveCheck,
   Flag = "AliveCheck",
   Callback = function(Value)
      Environment.Settings.AliveCheck = Value
   end,
})

local ToggleMode = MainToggle:CreateToggle({
   Name = "Toggle Mode",
   CurrentValue = Environment.Settings.Toggle,
   Flag = "ToggleMode",
   Callback = function(Value)
      Environment.Settings.Toggle = Value
   end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local FOVSlider = SettingsTab:CreateSlider({
   Name = "FOV Radius",
   Range = {1, 500},
   Increment = 1,
   Suffix = "px",
   CurrentValue = Environment.FOVSettings.Radius,
   Flag = "FOVRadius",
   Callback = function(Value)
      Environment.FOVSettings.Radius = Value
   end,
})

local SensitivitySlider = SettingsTab:CreateSlider({
   Name = "Smoothness",
   Range = {0, 10},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = Environment.Settings.Sensitivity,
   Flag = "Sensitivity",
   Callback = function(Value)
      Environment.Settings.Sensitivity = Value
   end,
})

local MouseSensitivitySlider = SettingsTab:CreateSlider({
   Name = "Mouse Sensitivity",
   Range = {0.1, 10},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = Environment.Settings.Sensitivity2,
   Flag = "MouseSensitivity",
   Callback = function(Value)
      Environment.Settings.Sensitivity2 = Value
   end,
})

local LockPartDropdown = SettingsTab:CreateDropdown({
   Name = "Aim Part",
   Options = {"Head", "HumanoidRootPart", "Torso", "LeftHand", "RightHand"},
   CurrentOption = Environment.Settings.LockPart,
   Flag = "LockPart",
   Callback = function(Option)
      Environment.Settings.LockPart = Option
   end,
})

local LockModeDropdown = SettingsTab:CreateDropdown({
   Name = "Aim Mode",
   Options = {"CFrame", "Mouse"},
   CurrentOption = Environment.Settings.LockMode == 1 and "CFrame" or "Mouse",
   Flag = "LockMode",
   Callback = function(Option)
      Environment.Settings.LockMode = Option == "CFrame" and 1 or 2
   end,
})

local TriggerKeyDropdown = SettingsTab:CreateDropdown({
   Name = "Trigger Key",
   Options = {"MouseButton2", "LeftShift", "LeftControl", "Q", "E", "F"},
   CurrentOption = "MouseButton2",
   Flag = "TriggerKey",
   Callback = function(Option)
      Environment.Settings.TriggerKey = Option == "MouseButton2" and Enum.UserInputType.MouseButton2 or Enum.KeyCode[Option]
   end,
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local FOVColorPicker = VisualsTab:CreateColorPicker({
   Name = "FOV Color",
   Color = Environment.FOVSettings.Color,
   Flag = "FOVColor",
   Callback = function(Value)
      Environment.FOVSettings.Color = Value
   end
})

local LockedColorPicker = VisualsTab:CreateColorPicker({
   Name = "Locked Color",
   Color = Environment.FOVSettings.LockedColor,
   Flag = "LockedColor",
   Callback = function(Value)
      Environment.FOVSettings.LockedColor = Value
   end
})

local OutlineColorPicker = VisualsTab:CreateColorPicker({
   Name = "Outline Color",
   Color = Environment.FOVSettings.OutlineColor,
   Flag = "OutlineColor",
   Callback = function(Value)
      Environment.FOVSettings.OutlineColor = Value
   end
})

local RainbowFOVToggle = VisualsTab:CreateToggle({
   Name = "Rainbow FOV",
   CurrentValue = Environment.FOVSettings.RainbowColor,
   Flag = "RainbowFOV",
   Callback = function(Value)
      Environment.FOVSettings.RainbowColor = Value
   end,
})

local RainbowOutlineToggle = VisualsTab:CreateToggle({
   Name = "Rainbow Outline",
   CurrentValue = Environment.FOVSettings.RainbowOutlineColor,
   Flag = "RainbowOutline",
   Callback = function(Value)
      Environment.FOVSettings.RainbowOutlineColor = Value
   end,
})

local FOVThicknessSlider = VisualsTab:CreateSlider({
   Name = "FOV Thickness",
   Range = {1, 10},
   Increment = 1,
   Suffix = "px",
   CurrentValue = Environment.FOVSettings.Thickness,
   Flag = "FOVThickness",
   Callback = function(Value)
      Environment.FOVSettings.Thickness = Value
   end,
})

local FOVTransparencySlider = VisualsTab:CreateSlider({
   Name = "FOV Transparency",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = Environment.FOVSettings.Transparency,
   Flag = "FOVTransparency",
   Callback = function(Value)
      Environment.FOVSettings.Transparency = Value
   end,
})

-- Player Management Tab
local PlayersTab = Window:CreateTab("Players", 4483362458)

local BlacklistSection = PlayersTab:CreateSection("Blacklist Management")

local PlayerDropdown = PlayersTab:CreateDropdown({
   Name = "Select Player",
   Options = {},
   CurrentOption = "",
   Flag = "PlayerSelect",
   Callback = function(Option)
      -- Store selected player
   end,
})

local function UpdatePlayerList()
   local players = {}
   for _, player in next, GetPlayers(Players) do
      if player ~= LocalPlayer then
         table.insert(players, player.Name)
      end
   end
   Rayfield:UpdateDropdown("PlayerSelect", players, "")
end

local BlacklistButton = PlayersTab:CreateButton({
   Name = "Blacklist Selected",
   Callback = function()
      local selected = Rayfield.Flags["PlayerSelect"]
      if selected and selected ~= "" then
         Environment:Blacklist(selected)
         Rayfield:Notify({
            Title = "Blacklist",
            Content = "Added " .. selected .. " to blacklist",
            Duration = 3,
            Image = 4483362458
         })
      end
   end,
})

local WhitelistButton = PlayersTab:CreateButton({
   Name = "Whitelist Selected",
   Callback = function()
      local selected = Rayfield.Flags["PlayerSelect"]
      if selected and selected ~= "" then
         Environment:Whitelist(selected)
         Rayfield:Notify({
            Title = "Blacklist",
            Content = "Removed " .. selected .. " from blacklist",
            Duration = 3,
            Image = 4483362458
         })
      end
   end,
})

local BlacklistedPlayersLabel = PlayersTab:CreateLabel("Blacklisted Players: None")

local function UpdateBlacklistDisplay()
   local blacklisted = Environment.Blacklisted
   if #blacklisted > 0 then
      BlacklistedPlayersLabel:Set("Blacklisted Players: " .. table.concat(blacklisted, ", "))
   else
      BlacklistedPlayersLabel:Set("Blacklisted Players: None")
   end
end

-- Update player list periodically
spawn(function()
   while true do
      UpdatePlayerList()
      UpdateBlacklistDisplay()
      wait(5)
   end
end)

-- Misc Tab
local MiscTab = Window:CreateTab("Misc", 4483362458)

local SaveConfigButton = MiscTab:CreateButton({
   Name = "Save Configuration",
   Callback = function()
      Rayfield:Notify({
         Title = "Configuration",
         Content = "Settings saved!",
         Duration = 3,
         Image = 4483362458
      })
   end,
})

local LoadConfigButton = MiscTab:CreateButton({
   Name = "Load Configuration",
   Callback = function()
      Rayfield:Notify({
         Title = "Configuration",
         Content = "Settings loaded!",
         Duration = 3,
         Image = 4483362458
      })
   end,
})

local UnloadButton = MiscTab:CreateButton({
   Name = "Unload Aimbot",
   Callback = function()
      Environment:Exit()
      Rayfield:Destroy()
   end,
})

local StatusLabel = MiscTab:CreateLabel("Status: Ready")

-- Update status
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
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")

	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")

	Username = FixUsername(Username)

	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")

	local Index = tablefind(self.Blacklisted, Username)

	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")

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

Rayfield:Notify({
   Title = "Exunys Aimbot V3",
   Content = "Successfully loaded!",
   Duration = 5,
   Image = 4483362458
})

return Environment
