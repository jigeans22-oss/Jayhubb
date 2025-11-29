getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RH2 Basketball Visualizer",
   LoadingTitle = "RH2 Visualizer",
   LoadingSubtitle = "by Sirius",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "RH2Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- RH2 Specific Configuration
_G.ShowShotRange = false
_G.ShowDunkRange = false
_G.ShowPassRange = false
_G.RangeDistance = 30
_G.VisualizerColor = Color3.fromRGB(0, 255, 0)
_G.MobileUIEnabled = false

-- Visualizer Parts
local rangeVisualizers = {}

-- Mobile UI Elements
local mobileScreenGui = nil
local mobileFrame = nil

-- RH2 Specific Location Finder
local function findRH2Locations()
    local locations = {}
    
    -- Find basketball hoops
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("hoop") or obj.Name:lower():find("basket") or obj.Name:lower():find("rim") then
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                table.insert(locations, {
                    Part = obj,
                    Position = obj.Position,
                    Name = "Hoop: " .. obj.Name,
                    Type = "Hoop"
                })
            end
        end
    end
    
    -- Find court boundaries
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("court") or obj.Name:lower():find("floor") or obj.Name:lower():find("bound") then
            if obj:IsA("Part") then
                table.insert(locations, {
                    Part = obj,
                    Position = obj.Position,
                    Name = "Court: " .. obj.Name,
                    Type = "Court"
                })
            end
        end
    end
    
    -- Find three-point line areas
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("three") or obj.Name:lower():find("3pt") or obj.Name:lower():find("long") then
            if obj:IsA("Part") then
                table.insert(locations, {
                    Part = obj,
                    Position = obj.Position,
                    Name = "3-Point: " .. obj.Name,
                    Type = "ThreePoint"
                })
            end
        end
    end
    
    -- Find dunk zones
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("dunk") or obj.Name:lower():find("slam") then
            if obj:IsA("Part") then
                table.insert(locations, {
                    Part = obj,
                    Position = obj.Position,
                    Name = "Dunk Zone: " .. obj.Name,
                    Type = "Dunk"
                })
            end
        end
    end
    
    -- Find pass targets or teammates
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                table.insert(locations, {
                    Part = root,
                    Position = root.Position,
                    Name = "Teammate: " .. player.Name,
                    Type = "Teammate"
                })
            end
        end
    end
    
    return locations
end

-- Create Range Visualizer for RH2
local function createRH2Visualizer(position, radius, locationType)
    local color = _G.VisualizerColor
    
    -- Different colors for different types
    if locationType == "Hoop" then
        color = Color3.fromRGB(255, 0, 0) -- Red for hoops
    elseif locationType == "ThreePoint" then
        color = Color3.fromRGB(255, 165, 0) -- Orange for 3-point
    elseif locationType == "Dunk" then
        color = Color3.fromRGB(0, 0, 255) -- Blue for dunk
    elseif locationType == "Teammate" then
        color = Color3.fromRGB(0, 255, 0) -- Green for teammates
    end
    
    local visualizer = Instance.new("Part")
    visualizer.Name = "RH2RangeVisualizer"
    visualizer.Shape = Enum.PartType.Ball
    visualizer.Material = Enum.Material.Neon
    visualizer.Color = color
    visualizer.Transparency = 0.8
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
    visualizer.Position = position
    visualizer.Parent = workspace
    
    -- Billboard GUI for info
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, radius + 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = visualizer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.7
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = locationType .. "\nRange: " .. radius .. " studs"
    label.TextColor3 = color
    label.TextScaled = true
    label.Parent = billboard
    
    table.insert(rangeVisualizers, visualizer)
    return visualizer
end

-- Update RH2 Visualizers
local function updateRH2Visualizers()
    -- Clear existing visualizers
    for _, visualizer in pairs(rangeVisualizers) do
        if visualizer and visualizer.Parent then
            visualizer:Destroy()
        end
    end
    rangeVisualizers = {}
    
    if not _G.ShowShotRange and not _G.ShowDunkRange and not _G.ShowPassRange then
        return
    end
    
    local rh2Locations = findRH2Locations()
    
    for _, location in pairs(rh2Locations) do
        if _G.ShowShotRange and (location.Type == "Hoop" or location.Type == "ThreePoint") then
            createRH2Visualizer(location.Position, _G.RangeDistance, location.Type)
        end
        
        if _G.ShowDunkRange and location.Type == "Dunk" then
            createRH2Visualizer(location.Position, _G.RangeDistance, location.Type)
        end
        
        if _G.ShowPassRange and location.Type == "Teammate" then
            createRH2Visualizer(location.Position, _G.RangeDistance, location.Type)
        end
    end
    
    if #rh2Locations == 0 then
        print("No RH2 locations found. Creating sample visualizers.")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            createRH2Visualizer(LocalPlayer.Character.HumanoidRootPart.Position, _G.RangeDistance, "Sample")
        end
    else
        print("Found " .. #rh2Locations .. " RH2 locations")
    end
end

-- Create Mobile UI for RH2
local function createMobileUI()
    if mobileScreenGui then mobileScreenGui:Destroy() end
    
    mobileScreenGui = Instance.new("ScreenGui")
    mobileScreenGui.Name = "RH2MobileUI"
    mobileScreenGui.Parent = game.CoreGui
    mobileScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    mobileFrame = Instance.new("Frame")
    mobileFrame.Size = UDim2.new(0, 200, 0, 180)
    mobileFrame.Position = UDim2.new(0, 10, 0, 10)
    mobileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mobileFrame.BackgroundTransparency = 0.3
    mobileFrame.BorderSizePixel = 0
    mobileFrame.Parent = mobileScreenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.Text = "RH2 Visualizer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Parent = mobileFrame
    
    -- Toggle Buttons
    local buttons = {
        {"Shot Range", "ShowShotRange"},
        {"Dunk Range", "ShowDunkRange"}, 
        {"Pass Range", "ShowPassRange"}
    }
    
    for i, btnData in ipairs(buttons) do
        local btnName, globalVar = btnData[1], btnData[2]
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 25)
        button.Position = UDim2.new(0, 5, 0, 25 + (i * 30))
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        button.Text = btnName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.Parent = mobileFrame
        button.MouseButton1Click:Connect(function()
            _G[globalVar] = not _G[globalVar]
            updateRH2Visualizers()
            updateMobileUI()
        end)
    end
    
    -- Range Display
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(1, -10, 0, 20)
    rangeLabel.Position = UDim2.new(0, 5, 0, 130)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Text = "Range: " .. _G.RangeDistance .. " studs"
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextSize = 12
    rangeLabel.Parent = mobileFrame
    
    -- Status Display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 150)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Active: 0/3"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    statusLabel.Parent = mobileFrame
    
    _G.MobileUIEnabled = true
    updateMobileUI()
end

-- Update Mobile UI
local function updateMobileUI()
    if not mobileFrame then return end
    
    local statusLabel = mobileFrame:FindFirstChild("StatusLabel")
    local rangeLabel = mobileFrame:FindFirstChild("RangeLabel")
    
    if statusLabel then
        local activeCount = (_G.ShowShotRange and 1 or 0) + (_G.ShowDunkRange and 1 or 0) + (_G.ShowPassRange and 1 or 0)
        statusLabel.Text = "Active: " .. activeCount .. "/3"
        statusLabel.TextColor3 = activeCount > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    
    if rangeLabel then
        rangeLabel.Text = "Range: " .. _G.RangeDistance .. " studs"
    end
end

-- Detect if mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Rayfield UI for RH2
local MainTab = Window:CreateTab("RH2 Visualizer", nil)
local VisualizerSection = MainTab:CreateSection("Basketball Range Settings")

-- Shot Range Toggle
local ShotToggle = MainTab:CreateToggle({
    Name = "Show Shot Range",
    CurrentValue = false,
    Flag = "ShowShotRange",
    Callback = function(Value)
        _G.ShowShotRange = Value
        updateRH2Visualizers()
        updateMobileUI()
    end,
})

-- Dunk Range Toggle
local DunkToggle = MainTab:CreateToggle({
    Name = "Show Dunk Range", 
    CurrentValue = false,
    Flag = "ShowDunkRange",
    Callback = function(Value)
        _G.ShowDunkRange = Value
        updateRH2Visualizers()
        updateMobileUI()
    end,
})

-- Pass Range Toggle
local PassToggle = MainTab:CreateToggle({
    Name = "Show Pass Range",
    CurrentValue = false,
    Flag = "ShowPassRange",
    Callback = function(Value)
        _G.ShowPassRange = Value
        updateRH2Visualizers()
        updateMobileUI()
    end,
})

-- Range Slider
local Slider = MainTab:CreateSlider({
    Name = "Range Distance",
    Range = {10, 50},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "RangeDistance",
    Callback = function(Value)
        _G.RangeDistance = Value
        updateRH2Visualizers()
        updateMobileUI()
    end,
})

-- Refresh Button
local Button = MainTab:CreateButton({
    Name = "Refresh Visualizers",
    Callback = function()
        updateRH2Visualizers()
        Rayfield:Notify({
            Title = "RH2 Visualizer",
            Content = "Visualizers refreshed",
            Duration = 2,
        })
    end,
})

-- Auto-detect mobile and create UI
spawn(function()
    wait(2)
    if isMobile() then
        createMobileUI()
        Rayfield:Notify({
            Title = "Mobile Detected",
            Content = "RH2 touch controls enabled",
            Duration = 5,
        })
    end
end)

-- Initialization
Rayfield:Notify({
    Title = "RH2 Visualizer Loaded",
    Content = "Use to visualize basketball ranges",
    Duration = 5,
})

print("RH2 Basketball Visualizer loaded successfully!")
