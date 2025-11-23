local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Settings
local ESP_Enabled = false
local Aimbot_Enabled = false
local FOV = 100
local Smoothness = 0.5

-- Advanced HAXZO PRODUCTIONS GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HAXZO_PRODUCTIONS_UI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 400, 0, 500)
mainContainer.Position = UDim2.new(0.5, -200, 0.5, -250)
mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainContainer.BorderSizePixel = 0
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.Parent = gui

-- Modern Styling
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 15)
containerCorner.Parent = mainContainer

local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(100, 80, 200)
containerStroke.Thickness = 3
containerStroke.Parent = mainContainer

-- Glass Effect
local glassEffect = Instance.new("Frame")
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BackgroundTransparency = 0.95
glassEffect.BorderSizePixel = 0
glassEffect.Parent = mainContainer

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 80)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
header.BorderSizePixel = 0
header.Parent = mainContainer

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = header

-- HAXZO PRODUCTIONS Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0.6, 0)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.Text = "HAXZO PRODUCTIONS"
title.TextColor3 = Color3.fromRGB(220, 180, 255)
title.TextSize = 24
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -80, 0.4, 0)
subtitle.Position = UDim2.new(0, 20, 0.6, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PREMIUM SUITE v2.1"
subtitle.TextColor3 = Color3.fromRGB(180, 160, 255)
subtitle.TextSize = 12
title.Font = Enum.Font.SourceSansLight
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0.5, -20)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(1, -100, 0.5, -20)
minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 18
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeButton

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -40, 1, -100)
contentFrame.Position = UDim2.new(0, 20, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

-- Tab System
local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1, 0, 0, 40)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = contentFrame

local mainTab = Instance.new("TextButton")
mainTab.Size = UDim2.new(0.5, -5, 1, 0)
mainTab.Position = UDim2.new(0, 0, 0, 0)
mainTab.BackgroundColor3 = Color3.fromRGB(60, 50, 100)
mainTab.Text = "MAIN FEATURES"
mainTab.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTab.TextSize = 14
mainTab.Font = Enum.Font.SourceSansBold
mainTab.Parent = tabButtons

local mainTabCorner = Instance.new("UICorner")
mainTabCorner.CornerRadius = UDim.new(0, 8)
mainTabCorner.Parent = mainTab

local settingsTab = Instance.new("TextButton")
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
settingsTab.Text = "SETTINGS"
settingsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsTab.TextSize = 14
settingsTab.Font = Enum.Font.SourceSansBold
settingsTab.Parent = tabButtons

local settingsTabCorner = Instance.new("UICorner")
settingsTabCorner.CornerRadius = UDim.new(0, 8)
settingsTabCorner.Parent = settingsTab

-- Main Features Content
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -50)
mainContent.Position = UDim2.new(0, 0, 0, 50)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- ESP Toggle Card
local espCard = Instance.new("Frame")
espCard.Size = UDim2.new(1, 0, 0, 80)
espCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
espCard.BorderSizePixel = 0
espCard.Parent = mainContent

local espCardCorner = Instance.new("UICorner")
espCardCorner.CornerRadius = UDim.new(0, 10)
espCardCorner.Parent = espCard

local espIcon = Instance.new("TextLabel")
espIcon.Size = UDim2.new(0, 50, 0, 50)
espIcon.Position = UDim2.new(0, 15, 0.5, -25)
espIcon.BackgroundTransparency = 1
espIcon.Text = "👁️"
espIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
espIcon.TextSize = 24
espIcon.Parent = espCard

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(0.5, 0, 0, 25)
espTitle.Position = UDim2.new(0, 80, 0, 15)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP SYSTEM"
espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
espTitle.TextSize = 16
espTitle.Font = Enum.Font.SourceSansBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espCard

local espDesc = Instance.new("TextLabel")
espDesc.Size = UDim2.new(0.5, 0, 0, 20)
espDesc.Position = UDim2.new(0, 80, 0, 40)
espDesc.BackgroundTransparency = 1
espDesc.Text = "Player Visualization"
espDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
espDesc.TextSize = 12
espDesc.Font = Enum.Font.SourceSans
espDesc.TextXAlignment = Enum.TextXAlignment.Left
espDesc.Parent = espCard

local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 80, 0, 35)
espToggle.Position = UDim2.new(1, -100, 0.5, -17)
espToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
espToggle.Text = "OFF"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.TextSize = 14
espToggle.Font = Enum.Font.SourceSansBold
espToggle.Parent = espCard

local espToggleCorner = Instance.new("UICorner")
espToggleCorner.CornerRadius = UDim.new(0, 8)
espToggleCorner.Parent = espToggle

-- Aimbot Toggle Card
local aimbotCard = Instance.new("Frame")
aimbotCard.Size = UDim2.new(1, 0, 0, 80)
aimbotCard.Position = UDim2.new(0, 0, 0, 90)
aimbotCard.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
aimbotCard.BorderSizePixel = 0
aimbotCard.Parent = mainContent

local aimbotCardCorner = Instance.new("UICorner")
aimbotCardCorner.CornerRadius = UDim.new(0, 10)
aimbotCardCorner.Parent = aimbotCard

local aimbotIcon = Instance.new("TextLabel")
aimbotIcon.Size = UDim2.new(0, 50, 0, 50)
aimbotIcon.Position = UDim2.new(0, 15, 0.5, -25)
aimbotIcon.BackgroundTransparency = 1
aimbotIcon.Text = "🎯"
aimbotIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotIcon.TextSize = 24
aimbotIcon.Parent = aimbotCard

local aimbotTitle = Instance.new("TextLabel")
aimbotTitle.Size = UDim2.new(0.5, 0, 0, 25)
aimbotTitle.Position = UDim2.new(0, 80, 0, 15)
aimbotTitle.BackgroundTransparency = 1
aimbotTitle.Text = "AIM ASSIST"
aimbotTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotTitle.TextSize = 16
aimbotTitle.Font = Enum.Font.SourceSansBold
aimbotTitle.TextXAlignment = Enum.TextXAlignment.Left
aimbotTitle.Parent = aimbotCard

local aimbotDesc = Instance.new("TextLabel")
aimbotDesc.Size = UDim2.new(0.5, 0, 0, 20)
aimbotDesc.Position = UDim2.new(0, 80, 0, 40)
aimbotDesc.BackgroundTransparency = 1
aimbotDesc.Text = "Target Lock System"
aimbotDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
aimbotDesc.TextSize = 12
aimbotDesc.Font = Enum.Font.SourceSans
aimbotDesc.TextXAlignment = Enum.TextXAlignment.Left
aimbotDesc.Parent = aimbotCard

local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Size = UDim2.new(0, 80, 0, 35)
aimbotToggle.Position = UDim2.new(1, -100, 0.5, -17)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
aimbotToggle.Text = "OFF"
aimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotToggle.TextSize = 14
aimbotToggle.Font = Enum.Font.SourceSansBold
aimbotToggle.Parent = aimbotCard

local aimbotToggleCorner = Instance.new("UICorner")
aimbotToggleCorner.CornerRadius = UDim.new(0, 8)
aimbotToggleCorner.Parent = aimbotToggle

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 40)
statusBar.Position = UDim2.new(0, 0, 1, -50)
statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
statusBar.BorderSizePixel = 0
statusBar.Parent = contentFrame

local statusBarCorner = Instance.new("UICorner")
statusBarCorner.CornerRadius = UDim.new(0, 8)
statusBarCorner.Parent = statusBar

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "HAXZO PRODUCTIONS | STATUS: READY"
statusText.TextColor3 = Color3.fromRGB(180, 160, 255)
statusText.TextSize = 12
statusText.Font = Enum.Font.SourceSansSemibold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(220, 180, 255)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Radius = FOV
fovCircle.Visible = false

-- GUI Interactions
local function toggleESP()
    ESP_Enabled = not ESP_Enabled
    espToggle.Text = ESP_Enabled and "ON" or "OFF"
    espToggle.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 60, 80)
    statusText.Text = ESP_Enabled and "HAXZO PRODUCTIONS | ESP: ENABLED" or "HAXZO PRODUCTIONS | ESP: DISABLED"
end

local function toggleAimbot()
    Aimbot_Enabled = not Aimbot_Enabled
    aimbotToggle.Text = Aimbot_Enabled and "ON" or "OFF"
    aimbotToggle.BackgroundColor3 = Aimbot_Enabled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 60, 80)
    fovCircle.Visible = Aimbot_Enabled
    statusText.Text = Aimbot_Enabled and "HAXZO PRODUCTIONS | AIMBOT: ENABLED" or "HAXZO PRODUCTIONS | AIMBOT: DISABLED"
end

espToggle.MouseButton1Click:Connect(toggleESP)
aimbotToggle.MouseButton1Click:Connect(toggleAimbot)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(function()
    mainContainer.Visible = not mainContainer.Visible
end)

-- Tab Switching
mainTab.MouseButton1Click:Connect(function()
    mainTab.BackgroundColor3 = Color3.fromRGB(60, 50, 100)
    settingsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    mainContent.Visible = true
end)

settingsTab.MouseButton1Click:Connect(function()
    settingsTab.BackgroundColor3 = Color3.fromRGB(60, 50, 100)
    mainTab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    mainContent.Visible = false
end)

-- YOUR ORIGINAL ESP AND AIMBOT CODE
function CreateESP(target)
    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = Color3.fromRGB(255, 0, 0)
    text.Visible = false

    RunService.RenderStepped:Connect(function()
        if ESP_Enabled and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Team ~= LocalPlayer.Team then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
            if onScreen then
                text.Position = Vector2.new(pos.X, pos.Y - 20)
                text.Text = target.Name
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end)
end

-- ESP para todos os jogadores
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateESP(p)
    end
end)

-- Encontrar inimigo mais próximo dentro do FOV
function GetClosestEnemy()
    local closest = nil
    local shortestDistance = FOV

    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Team ~= LocalPlayer.Team and enemy.Character and enemy.Character:FindFirstChild("Head") then
            local head = enemy.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = enemy
                end
            end
        end
    end

    return closest
end

-- Loop principal
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = Aimbot_Enabled

    if Aimbot_Enabled then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
        end
    end
end)

print("HAXZO PRODUCTIONS Premium Suite Loaded!")
print("Advanced GUI System Activated")
print("ESP & Aimbot Systems Ready")
