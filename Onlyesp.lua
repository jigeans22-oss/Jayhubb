local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/WeebsMain/txid-ui-library/refs/heads/main/UI.lua"))()

-- Smaller Mobile-Friendly Window
local Window = Library:Window({
    Name = "KAINO HUB",
    SubTitle = "BY KAINO STUDIOS",
    ExpiresIn = "30d",
    Size = UDim2.new(0, 420, 0, 320) -- Mobile-friendly size
})

---------------------------------------------------------
-- PAGES
---------------------------------------------------------
local CombatPage = Window:Page({Name = "Combat", Icon = "136879043989014"})
local VisualsPage = Window:Page({Name = "Visuals", Icon = "136879043989014"})
local MiscPage = Window:Page({Name = "Misc", Icon = "136879043989014"})

---------------------------------------------------------
-- SUBPAGES / SECTIONS
---------------------------------------------------------
local CombatMain = CombatPage:SubPage({Name = "Main", Columns = 2})
local VisualMain = VisualsPage:SubPage({Name = "Main", Columns = 2})
local MiscMain = MiscPage:SubPage({Name = "Main", Columns = 2})

local CSection = CombatMain:Section({Name = "Combat Options", Icon = "136879043989014", Side = 1})
local VSection = VisualMain:Section({Name = "Visual Options", Icon = "136879043989014", Side = 1})
local MSection = MiscMain:Section({Name = "Misc Options", Icon = "136879043989014", Side = 1})

---------------------------------------------------------
-- GOD MODE FUNCTION
---------------------------------------------------------
local godModeEnabled = false
local godModeConnection

local function enableGodMode(player)
    if not player or not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge

        -- Disconnect previous connection if exists
        if godModeConnection then godModeConnection:Disconnect() end

        godModeConnection = humanoid.HealthChanged:Connect(function()
            if godModeEnabled and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

---------------------------------------------------------
-- UI ELEMENTS
---------------------------------------------------------
CSection:Toggle({
    Name = "God Mode",
    Flag = "GodMode_Toggle",
    Default = false,
    Callback = function(v)
        godModeEnabled = v
        if godModeEnabled then
            enableGodMode(LocalPlayer)
        elseif godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
    end
})

-- Placeholder Toggles
CSection:Toggle({
    Name = "Combat Feature",
    Flag = "Combat_Toggle",
    Default = false,
    Callback = function(v) print("Combat Feature:", v) end
})

CSection:Slider({
    Name = "Combat Strength",
    Flag = "Combat_Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(v) print("Combat Strength:", v) end
})

VSection:Toggle({
    Name = "Visual Feature",
    Flag = "Visual_Toggle",
    Default = false,
    Callback = function(v) print("Visual Feature:", v) end
})

MSection:Dropdown({
    Name = "Mode",
    Flag = "Mode_Drop",
    Items = {"Normal", "Advanced", "Experimental"},
    Default = "Normal",
    Callback = function(v) print("Mode Selected:", v) end
})

Library:CreateSettingsPage(Window)

Library:Notification("UI Loaded Successfully!", 5, "94627324690861")

---------------------------------------------------------
-- MOBILE UI TOGGLE BUTTON
---------------------------------------------------------
local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

if isMobile() then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileToggleUI"
    ScreenGui.Parent = game.CoreGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    ToggleBtn.Text = "UI"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.TextScaled = true
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true
    ToggleBtn.ZIndex = 9999999

    local uiOpen = true
    ToggleBtn.MouseButton1Click:Connect(function()
        uiOpen = not uiOpen
        for _, gui in ipairs(game.CoreGui:GetChildren()) do
            if gui ~= ScreenGui then
                gui.Enabled = uiOpen
            end
        end
    end)
end
