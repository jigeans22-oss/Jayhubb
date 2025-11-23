local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ESP Variables
local EspList = {}
local ESPEnabled = true

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 300, 0, 200)
mainContainer.Position = UDim2.new(0.02, 0, 0.3, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- Corner
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = mainContainer

-- Stroke
local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(100, 100, 200)
containerStroke.Thickness = 2
containerStroke.Parent = mainContainer

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
header.BorderSizePixel = 0
header.Parent = mainContainer

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ESP GUI"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = header

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- ESP Toggle Frame
local espToggleFrame = Instance.new("Frame")
espToggleFrame.Size = UDim2.new(1, -40, 0, 60)
espToggleFrame.Position = UDim2.new(0, 20, 0, 70)
espToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
espToggleFrame.BorderSizePixel = 0
espToggleFrame.Parent = mainContainer

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espToggleFrame

-- ESP Label
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.6, 0, 1, 0)
espLabel.Position = UDim2.new(0, 15, 0, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
espLabel.TextSize = 18
espLabel.Font = Enum.Font.SourceSansBold
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = espToggleFrame

-- ESP Toggle Button
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 80, 0, 35)
espButton.Position = UDim2.new(1, -90, 0.5, -17)
espButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
espButton.Text = "ENABLED"
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextSize = 14
espButton.Font = Enum.Font.SourceSansBold
espButton.Parent = espToggleFrame

local espButtonCorner = Instance.new("UICorner")
espButtonCorner.CornerRadius = UDim.new(0, 8)
espButtonCorner.Parent = espButton

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Press F to hide/show GUI"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainContainer

-- GUI Controls
local isGUIVisible = true

closeButton.MouseButton1Click:Connect(function()
    mainContainer.Visible = false
    isGUIVisible = false
end)

-- Toggle GUI with F key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        mainContainer.Visible = not mainContainer.Visible
        isGUIVisible = mainContainer.Visible
    end
end)

-- ESP Functionality
local function createESP(Player)
    local Name = Drawing.new("Text")
    Name.Text = Player.Name
    Name.Size = 16
    Name.Outline = true
    Name.Center = true
    Name.Color = Color3.fromRGB(255, 100, 100)

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(255, 100, 100)

    local function update()
        if not ESPEnabled then
            Name.Visible = false
            Box.Visible = false
            return
        end
        
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(Character.Head.Position)
                if OnScreen then
                    local X = Pos.X
                    local Y = Pos.Y
                    Name.Position = Vector2.new(X, Y - 33)
                    Box.Size = Vector2.new(2450 / Pos.Z, 3850/ Pos.Z)
                    Box.Position = Vector2.new(X - Box.Size.X / 2, Y - Box.Size.Y /9)
                    Name.Visible = true
                    Box.Visible = true
                    return
                end
            end
        end
        Name.Visible = false
        Box.Visible = false
    end
    update()

    local Connection1 = Player.CharacterAdded:Connect(function()
        update()
    end)
    local Connection2 = Player.CharacterRemoving:Connect(function()
        Name.Visible = false
        Box.Visible = false
    end)

    return {
        update = update,
        disconnect = function()
            Name:Remove()
            Box:Remove()
            Connection1:Disconnect()
            Connection2:Disconnect()
        end
    }
end

-- Initialize ESP
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        table.insert(EspList, createESP(Player))
    end
end

-- ESP Toggle Functionality
espButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        espButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        espButton.Text = "ENABLED"
        -- Re-enable ESP for all players
        for _, esp in pairs(EspList) do
            esp.update()
        end
    else
        espButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        espButton.Text = "DISABLED"
        -- Disable ESP for all players
        for _, esp in pairs(EspList) do
            esp.update()
        end
    end
end)

-- Update ESP
RunService.RenderStepped:Connect(function()
    for _, Esp in pairs(EspList) do
        Esp.update()
    end
end)

-- Handle new players
Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        table.insert(EspList, createESP(Player))
    end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(Player)
    for i, esp in pairs(EspList) do
        if esp.Player == Player then
            esp.disconnect()
            table.remove(EspList, i)
            break
        end
    end
end)

print("ESP GUI Loaded!")
print("Press F to toggle GUI")
print("ESP is enabled by default")
