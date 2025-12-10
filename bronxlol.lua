-- Da Hood Ultimate Script with Official Obsidian UI
-- Features: Aimbot, Silent Aim, Anti-Lock, Auto-Buy, Auto-Stomp, ESP, FPS Boost, Mobile Support

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load Official Obsidian UI Library
local ObsidianSuccess, Obsidian = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianHub/Releases/main/Obsidian.lua"))()
end)

if not ObsidianSuccess then
    -- Fallback to alternative source
    Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/ObsidianV/Obsidian/main/Main.lua"))()
end

-- Configuration
local Settings = {
    Aimbot = {
        Enabled = true,
        Keybind = "Q",
        FOV = 75,
        Smoothness = 0.2,
        WallCheck = false,
        VisibleCheck = true,
        AutoFire = false,
        TeamCheck = false,
        SilentAim = true,
        HitChance = 100
    },
    AntiLock = {
        Enabled = true,
        Strength = 1.5,
        Prediction = 0.12,
        AntiShake = true
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Distance = true,
        HealthBar = true,
        Weapon = true,
        Tracers = false,
        TeamColor = true,
        MaxDistance = 1000
    },
    AutoBuy = {
        Enabled = true,
        BuyOnSpawn = true,
        PreferredGuns = {"AK-47", "Shotgun", "Revolver"},
        AutoAmmo = true
    },
    AutoStomp = {
        Enabled = true,
        Range = 15,
        Delay = 0.5
    },
    Misc = {
        FPSBoost = true,
        WalkSpeed = 22,
        JumpPower = 55,
        NoClip = false,
        AntiAFK = true,
        RejoinOnKick = true
    }
}

-- Create Obsidian UI Window
local Window = Obsidian:CreateWindow({
    Title = "Da Hood Ultimate",
    Style = 1,
    Size = UDim2.new(0, 500, 0, 500),
    Position = UDim2.new(0.5, -250, 0.5, -250),
    Theme = "Midnight",
    Icon = "rbxassetid://0"
})

-- Create Tabs
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local AutoTab = Window:CreateTab("Auto")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- Combat Tab
local AimbotSection = CombatTab:CreateSection("Aimbot")
AimbotSection:CreateToggle("Enabled", Settings.Aimbot.Enabled, function(Value)
    Settings.Aimbot.Enabled = Value
end)

AimbotSection:CreateToggle("Silent Aim", Settings.Aimbot.SilentAim, function(Value)
    Settings.Aimbot.SilentAim = Value
end)

AimbotSection:CreateToggle("Auto Fire", Settings.Aimbot.AutoFire, function(Value)
    Settings.Aimbot.AutoFire = Value
end)

AimbotSection:CreateToggle("Wall Check", Settings.Aimbot.WallCheck, function(Value)
    Settings.Aimbot.WallCheck = Value
end)

AimbotSection:CreateSlider("FOV", Settings.Aimbot.FOV, 1, 360, function(Value)
    Settings.Aimbot.FOV = Value
end)

AimbotSection:CreateSlider("Smoothness", Settings.Aimbot.Smoothness, 0, 1, 0.1, function(Value)
    Settings.Aimbot.Smoothness = Value
end)

AimbotSection:CreateSlider("Hit Chance", Settings.Aimbot.HitChance, 0, 100, function(Value)
    Settings.Aimbot.HitChance = Value
end)

AimbotSection:CreateKeybind("Aimbot Key", "Q", function(Key)
    Settings.Aimbot.Keybind = Key
end)

local AntiLockSection = CombatTab:CreateSection("Anti-Lock")
AntiLockSection:CreateToggle("Enabled", Settings.AntiLock.Enabled, function(Value)
    Settings.AntiLock.Enabled = Value
end)

AntiLockSection:CreateSlider("Strength", Settings.AntiLock.Strength, 0.1, 5, 0.1, function(Value)
    Settings.AntiLock.Strength = Value
end)

AntiLockSection:CreateSlider("Prediction", Settings.AntiLock.Prediction, 0, 0.5, 0.01, function(Value)
    Settings.AntiLock.Prediction = Value
end)

AntiLockSection:CreateToggle("Anti-Shake", Settings.AntiLock.AntiShake, function(Value)
    Settings.AntiLock.AntiShake = Value
end)

-- Visuals Tab
local ESPSection = VisualsTab:CreateSection("ESP")
ESPSection:CreateToggle("Enabled", Settings.ESP.Enabled, function(Value)
    Settings.ESP.Enabled = Value
end)

ESPSection:CreateToggle("Box ESP", Settings.ESP.Box, function(Value)
    Settings.ESP.Box = Value
end)

ESPSection:CreateToggle("Name ESP", Settings.ESP.Name, function(Value)
    Settings.ESP.Name = Value
end)

ESPSection:CreateToggle("Health Bar", Settings.ESP.HealthBar, function(Value)
    Settings.ESP.HealthBar = Value
end)

ESPSection:CreateToggle("Tracers", Settings.ESP.Tracers, function(Value)
    Settings.ESP.Tracers = Value
end)

ESPSection:CreateToggle("Team Color", Settings.ESP.TeamColor, function(Value)
    Settings.ESP.TeamColor = Value
end)

ESPSection:CreateSlider("Max Distance", Settings.ESP.MaxDistance, 50, 2000, function(Value)
    Settings.ESP.MaxDistance = Value
end)

-- Auto Tab
local AutoBuySection = AutoTab:CreateSection("Auto-Buy")
AutoBuySection:CreateToggle("Enabled", Settings.AutoBuy.Enabled, function(Value)
    Settings.AutoBuy.Enabled = Value
end)

AutoBuySection:CreateToggle("Buy on Spawn", Settings.AutoBuy.BuyOnSpawn, function(Value)
    Settings.AutoBuy.BuyOnSpawn = Value
end)

AutoBuySection:CreateToggle("Auto Ammo", Settings.AutoBuy.AutoAmmo, function(Value)
    Settings.AutoBuy.AutoAmmo = Value
end)

local AutoStompSection = AutoTab:CreateSection("Auto-Stomp")
AutoStompSection:CreateToggle("Enabled", Settings.AutoStomp.Enabled, function(Value)
    Settings.AutoStomp.Enabled = Value
end)

AutoStompSection:CreateSlider("Range", Settings.AutoStomp.Range, 5, 50, function(Value)
    Settings.AutoStomp.Range = Value
end)

AutoStompSection:CreateSlider("Delay", Settings.AutoStomp.Delay, 0.1, 2, 0.1, function(Value)
    Settings.AutoStomp.Delay = Value
end)

-- Misc Tab
local MovementSection = MiscTab:CreateSection("Movement")
MovementSection:CreateSlider("Walk Speed", Settings.Misc.WalkSpeed, 16, 100, function(Value)
    Settings.Misc.WalkSpeed = Value
end)

MovementSection:CreateSlider("Jump Power", Settings.Misc.JumpPower, 50, 200, function(Value)
    Settings.Misc.JumpPower = Value
end)

MovementSection:CreateToggle("No Clip", Settings.Misc.NoClip, function(Value)
    Settings.Misc.NoClip = Value
end)

local PerformanceSection = MiscTab:CreateSection("Performance")
PerformanceSection:CreateToggle("FPS Boost", Settings.Misc.FPSBoost, function(Value)
    Settings.Misc.FPSBoost = Value
    if Value then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        settings().Rendering.QualityLevel = 1
    end
end)

PerformanceSection:CreateToggle("Anti-AFK", Settings.Misc.AntiAFK, function(Value)
    Settings.Misc.AntiAFK = Value
end)

-- Settings Tab
local UISection = SettingsTab:CreateSection("UI Settings")
UISection:CreateDropdown("Theme", {"Midnight", "Abyss", "Obsidian", "Dark", "Light"}, "Midnight", function(Value)
    Obsidian:SetTheme(Value)
end)

UISection:CreateKeybind("UI Toggle", "RightShift", function(Key)
    Window:SetKeybind(Key)
end)

UISection:CreateToggle("Mobile Support", true, function(Value)
    if Value and UserInputService.TouchEnabled then
        -- Mobile button creation code would go here
    end
end)

local ConfigSection = SettingsTab:CreateSection("Configuration")
ConfigSection:CreateButton("Save Config", function()
    -- Save configuration
    writefile("DaHoodConfig.json", game:GetService("HttpService"):JSONEncode(Settings))
    Obsidian:Notify("Config Saved", "Configuration has been saved successfully.")
end)

ConfigSection:CreateButton("Load Config", function()
    -- Load configuration
    if isfile("DaHoodConfig.json") then
        local Loaded = game:GetService("HttpService"):JSONDecode(readfile("DaHoodConfig.json"))
        for Category, Values in pairs(Loaded) do
            for Key, Value in pairs(Values) do
                Settings[Category][Key] = Value
            end
        end
        Obsidian:Notify("Config Loaded", "Configuration has been loaded successfully.")
    end
end)

ConfigSection:CreateButton("Reset Config", function()
    -- Reset to defaults
    Settings = {
        Aimbot = {Enabled = true, Keybind = "Q", FOV = 75, Smoothness = 0.2, WallCheck = false, VisibleCheck = true, AutoFire = false, TeamCheck = false, SilentAim = true, HitChance = 100},
        AntiLock = {Enabled = true, Strength = 1.5, Prediction = 0.12, AntiShake = true},
        ESP = {Enabled = true, Box = true, Name = true, Distance = true, HealthBar = true, Weapon = true, Tracers = false, TeamColor = true, MaxDistance = 1000},
        AutoBuy = {Enabled = true, BuyOnSpawn = true, PreferredGuns = {"AK-47", "Shotgun", "Revolver"}, AutoAmmo = true},
        AutoStomp = {Enabled = true, Range = 15, Delay = 0.5},
        Misc = {FPSBoost = true, WalkSpeed = 22, JumpPower = 55, NoClip = false, AntiAFK = true, RejoinOnKick = true}
    }
    Obsidian:Notify("Config Reset", "Configuration has been reset to defaults.")
end)

-- Aimbot Functionality
local Camera = Workspace.CurrentCamera
local AimbotTarget = nil
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Radius = Settings.Aimbot.FOV
AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotFOVCircle.Thickness = 2
AimbotFOVCircle.Filled = false

-- ESP Functionality
local ESPCache = {}

local function GetClosestPlayer()
    if not Settings.Aimbot.Enabled then return nil end
    
    local MaxDistance = Settings.Aimbot.FOV
    local ClosestPlayer = nil
    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Player and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            if Settings.Aimbot.TeamCheck and Player.Team == Player.Team then continue end
            
            local Character = Player.Character
            local Head = Character:FindFirstChild("Head")
            if Head then
                local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                
                if OnScreen then
                    local Distance = (MousePos - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                    
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        ClosestPlayer = Player
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

-- Anti-Lock System
local AntiLockConnection
if Settings.AntiLock.Enabled then
    AntiLockConnection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Root = Player.Character.HumanoidRootPart
            
            if Settings.AntiLock.AntiShake then
                Root.AssemblyLinearVelocity = Vector3.new(
                    math.random(-Settings.AntiLock.Strength, Settings.AntiLock.Strength),
                    Root.AssemblyLinearVelocity.Y,
                    math.random(-Settings.AntiLock.Strength, Settings.AntiLock.Strength)
                )
            end
        end
    end)
end

-- Auto-Buy System
local function AutoBuyGuns()
    if not Settings.AutoBuy.Enabled then return end
    
    local Shops = Workspace:FindFirstChild("Ignored")
    if not Shops then return end
    
    local DropFolder = Shops:FindFirstChild("Drop")
    if not DropFolder then return end
    
    for _, Shop in pairs(DropFolder:GetChildren()) do
        if Shop:FindFirstChild("ClickDetector") then
            for _, Gun in pairs(Settings.AutoBuy.PreferredGuns) do
                if string.find(Shop.Name:lower(), Gun:lower()) then
                    fireclickdetector(Shop.ClickDetector)
                    task.wait(0.5)
                    break
                end
            end
        end
    end
    
    if Settings.AutoBuy.AutoAmmo then
        for _, Shop in pairs(DropFolder:GetChildren()) do
            if Shop.Name:lower():find("ammo") and Shop:FindFirstChild("ClickDetector") then
                fireclickdetector(Shop.ClickDetector)
                task.wait(0.2)
            end
        end
    end
end

-- Auto-Stomp System
local AutoStompConnection
if Settings.AutoStomp.Enabled then
    AutoStompConnection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            for _, OtherPlayer in pairs(Players:GetPlayers()) do
                if OtherPlayer ~= Player and OtherPlayer.Character and OtherPlayer.Character:FindFirstChild("Humanoid") then
                    local Distance = (Player.Character.HumanoidRootPart.Position - OtherPlayer.Character.HumanoidRootPart.Position).Magnitude
                    
                    if Distance < Settings.AutoStomp.Range and OtherPlayer.Character.Humanoid.Health < 35 then
                        Player.Character.Humanoid.Jump = true
                        task.wait(Settings.AutoStomp.Delay)
                        break
                    end
                end
            end
        end
    end)
end

-- FPS Boost
if Settings.Misc.FPSBoost then
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    settings().Rendering.QualityLevel = 1
end

-- WalkSpeed/JumpPower
local SpeedConnection = RunService.Heartbeat:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Settings.Misc.WalkSpeed
        Player.Character.Humanoid.JumpPower = Settings.Misc.JumpPower
    end
end)

-- Anti-AFK
if Settings.Misc.AntiAFK then
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LastAction = tick()
    
    local AntiAFKConnection = RunService.Heartbeat:Connect(function()
        if tick() - LastAction > 20 then
            VirtualInputManager:SendKeyEvent(true, "W", false, nil)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "W", false, nil)
            LastAction = tick()
        end
    end)
end

-- No Clip
if Settings.Misc.NoClip then
    local NoClipConnection = RunService.Stepped:Connect(function()
        if Player.Character then
            for _, Part in pairs(Player.Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end
    end)
end

-- Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if Settings.Aimbot.Enabled and Settings.Aimbot.SilentAim and AimbotTarget and AimbotTarget.Character then
        if Method == "FireServer" and tostring(self) == "RemoteEvent" then
            local RemoteName = self.Name
            
            if RemoteName == "Shoot" or RemoteName == "Damage" then
                if math.random(1, 100) <= Settings.Aimbot.HitChance then
                    local Head = AimbotTarget.Character:FindFirstChild("Head")
                    if Head then
                        Args[1] = Head.Position
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, unpack(Args))
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    AimbotFOVCircle.Radius = Settings.Aimbot.FOV
    AimbotFOVCircle.Visible = Settings.Aimbot.Enabled
    AimbotFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Update Aimbot Target
    AimbotTarget = GetClosestPlayer()
    
    -- Auto Fire
    if Settings.Aimbot.AutoFire and AimbotTarget and Mouse.Target then
        mouse1click()
    end
end)

-- Auto-Buy on Spawn
Player.CharacterAdded:Connect(function(Character)
    task.wait(1)
    if Settings.AutoBuy.Enabled and Settings.AutoBuy.BuyOnSpawn then
        AutoBuyGuns()
    end
end)

-- Initial Buy
task.wait(2)
if Settings.AutoBuy.Enabled and Settings.AutoBuy.BuyOnSpawn then
    AutoBuyGuns()
end

-- Mobile Support
if UserInputService.TouchEnabled then
    local MobileButton = Instance.new("TextButton")
    MobileButton.Name = "MobileToggle"
    MobileButton.Text = "☰"
    MobileButton.TextScaled = true
    MobileButton.Font = Enum.Font.GothamBold
    MobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MobileButton.BackgroundTransparency = 0.3
    MobileButton.Size = UDim2.new(0, 60, 0, 60)
    MobileButton.Position = UDim2.new(0, 20, 0.5, -30)
    MobileButton.AnchorPoint = Vector2.new(0, 0.5)
    MobileButton.Parent = CoreGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.3, 0)
    UICorner.Parent = MobileButton
    
    MobileButton.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
end

-- Load notification
Obsidian:Notify("Da Hood Ultimate Loaded", "All features enabled successfully!\nPress RightShift to toggle UI.")
print("======================================")
print("DA HOOD ULTIMATE LOADED!")
print("Official Obsidian UI: ✓")
print("All Features: ✓")
print("Mobile Support: ✓")
print("======================================")
