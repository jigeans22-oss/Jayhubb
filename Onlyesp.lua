--// Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/WeebsMain/txid-ui-library/refs/heads/main/UI.lua"))()

local Window = Library:Window({
    Name = "Ultimate Hub",
    SubTitle = "v2.0 Beta",
    ExpiresIn = "30d"
})

---------------------------------------------------------
-- Pages / Subpages
---------------------------------------------------------

local CombatPage = Window:Page({Name = "Combat", Icon = "136879043989014"})
local VisualsPage = Window:Page({Name = "Visuals", Icon = "136879043989014"})

local AimbotPage = CombatPage:SubPage({Name = "Aimbot", Columns = 2})
local ESPPage = VisualsPage:SubPage({Name = "ESP", Columns = 2})

---------------------------------------------------------
-- Services
---------------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- Variables
---------------------------------------------------------

local AimbotEnabled = false
local SilentAimEnabled = false
local ESPEnabled = false

local TargetPart = "Head"
local FOV = 90
local FOVColor = Color3.fromRGB(255,255,255)

---------------------------------------------------------
-- FOV Circle (Drawing API)
---------------------------------------------------------

local Circle = Drawing.new("Circle")
Circle.Filled = false
Circle.Thickness = 2
Circle.NumSides = 60
Circle.Radius = FOV
Circle.Visible = false
Circle.Color = FOVColor

---------------------------------------------------------
-- Functions
---------------------------------------------------------

local function getClosestTarget()
    local closest = nil
    local mouse = UIS:GetMouseLocation()
    local shortest = Circle.Radius

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
            local char = player.Character
            local head = char:FindFirstChild(TargetPart)
            local human = char:FindFirstChild("Humanoid")

            if head and human and human.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

---------------------------------------------------------
-- Silent Aim Hook
---------------------------------------------------------

local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__index

mt.__index = newcclosure(function(self,key)
    if SilentAimEnabled and key == "Hit" and self == Camera then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(TargetPart) then
            return target.Character[TargetPart]
        end
    end
    return old(self,key)
end)

setreadonly(mt, true)

---------------------------------------------------------
-- Aimbot Loop
---------------------------------------------------------

RunService.RenderStepped:Connect(function()
    Circle.Position = UIS:GetMouseLocation()

    if AimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(TargetPart) then
            local pos = target.Character[TargetPart].Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
        end
    end
end)

---------------------------------------------------------
-- ESP System
---------------------------------------------------------

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "UltimateESP"

local function createESP(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,4)
    box.Color3 = Color3.new(1,0,0)
    box.Transparency = 0.6
    box.ZIndex = 5
    box.AlwaysOnTop = true
    box.Visible = false
    box.Parent = ESPFolder

    RunService.Heartbeat:Connect(function()
        if ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChild("Humanoid")

            if hum and hum.Health > 0 then
                box.Adornee = hrp
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end

Players.PlayerAdded:Connect(createESP)

---------------------------------------------------------
-- UI Elements
---------------------------------------------------------

-- Aimbot
local AimbotMain = AimbotPage:Section({Name = "Main", Side = 1})
local AimbotSettings = AimbotPage:Section({Name = "Settings", Side = 2})

AimbotMain:Toggle({
    Name = "Enable Aimbot",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(v)
        AimbotEnabled = v
        SilentAimEnabled = false
    end
})

AimbotMain:Toggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    Default = false,
    Callback = function(v)
        SilentAimEnabled = v
        AimbotEnabled = false
    end
})

AimbotSettings:Slider({
    Name = "FOV",
    Flag = "FOV",
    Min = 10,
    Max = 300,
    Default = 90,
    Callback = function(v)
        FOV = v
        Circle.Radius = v
    end
})

AimbotSettings:Dropdown({
    Name = "Target Part",
    Items = {"Head","HumanoidRootPart","Torso"},
    Default = "Head",
    Callback = function(v)
        TargetPart = v
    end
})

AimbotSettings:Toggle({
    Name = "Show FOV Circle",
    Default = true,
    Callback = function(v)
        Circle.Visible = v
    end
})

AimbotMain:Colorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(c)
        FOVColor = c
        Circle.Color = c
    end
})

-- ESP
local ESPSection = ESPPage:Section({Name = "ESP", Side = 1})

ESPSection:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(v)
        ESPEnabled = v
    end
})

---------------------------------------------------------
-- MOBILE UI TOGGLE BUTTON
---------------------------------------------------------

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

if isMobile() then
    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("TextButton")

    ScreenGui.Name = "MobileToggleUI"
    ScreenGui.Parent = game.CoreGui

    ToggleButton.Parent = ScreenGui
    ToggleButton.Size = UDim2.new(0, 70, 0, 70)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    ToggleButton.Text = "UI"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.TextScaled = true
    ToggleButton.BorderSizePixel = 0
    ToggleButton.BackgroundTransparency = 0.2
    ToggleButton.Active = true
    ToggleButton.Draggable = true
    ToggleButton.ZIndex = 9999999

    -- Toggles the whole UI on mobile
    local uiOpen = true

    ToggleButton.MouseButton1Click:Connect(function()
        uiOpen = not uiOpen

        for _, gui in ipairs(game.CoreGui:GetChildren()) do
            if gui ~= ScreenGui then
                gui.Enabled = uiOpen
            end
        end
    end)
end

---------------------------------------------------------
-- Settings Page
---------------------------------------------------------
Library:CreateSettingsPage(Window)

Library:Notification("Script loaded successfully!", 5, "94627324690861")
