getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Badge Range Visualizer",
   LoadingTitle = "Range Visualizer",
   LoadingSubtitle = "by Sirius",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "BadgeRangeConfig"
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

-- Configuration
_G.ShowBadgeRange = false
_G.RangeDistance = 50
_G.VisualizerColor = Color3.fromRGB(0, 255, 0)
_G.MobileUIEnabled = false

-- Visualizer Parts
local rangeVisualizers = {}
local rangeBeams = {}

-- Mobile UI Elements
local mobileScreenGui = nil
local mobileFrame = nil

-- Create Range Visualizer
local function createRangeVisualizer(position, radius)
    local visualizer = Instance.new("Part")
    visualizer.Name = "BadgeRangeVisualizer"
    visualizer.Shape = Enum.PartType.Ball
    visualizer.Material = Enum.Material.Neon
    visualizer.Color = _G.VisualizerColor
    visualizer.Transparency = 0.7
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
    visualizer.Position = position
    visualizer.Parent = workspace
    
    -- Create a beam effect
    local beam = Instance.new("Beam")
    beam.Attachment0 = Instance.new("Attachment")
    beam.Attachment0.Parent = visualizer
    beam.Attachment1 = Instance.new("Attachment")
    beam.Attachment1.Parent = visualizer
    beam.Attachment1.Position = Vector3.new(0, radius, 0)
    beam.Color = ColorSequence.new(_G.VisualizerColor)
    beam.Width0 = 2
    beam.Width1 = 2
    beam.Parent = visualizer
    
    -- Surface GUI for distance display
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Parent = visualizer
    surfaceGui.Face = Enum.NormalId.Top
    surfaceGui.AlwaysOnTop = true
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = radius .. " studs"
    distanceLabel.TextColor3 = _G.VisualizerColor
    distanceLabel.TextScaled = true
    distanceLabel.Parent = surfaceGui
    
    table.insert(rangeVisualizers, visualizer)
    table.insert(rangeBeams, beam)
    
    return visualizer
end

-- Find Badge Locations
local function findBadgeLocations()
    local badgeLocations = {}
    
    -- Search for common badge-related objects
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("badge") or obj.Name:lower():find("range") or obj.Name:lower():find("trigger") then
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                table.insert(badgeLocations, {
                    Part = obj,
                    Position = obj.Position,
                    Name = obj.Name
                })
            end
        end
    end
    
    -- Also check for proximity prompts which are often used for badges
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and (parent:IsA("Part") or parent:IsA("MeshPart")) then
                table.insert(badgeLocations, {
                    Part = parent,
                    Position = parent.Position,
                    Name = "Proximity: " .. (obj.ActionText or "Unknown")
                })
            end
        end
    end
    
    return badgeLocations
end

-- Update Range Visualizers
local function updateRangeVisualizers()
    -- Clear existing visualizers
    for _, visualizer in pairs(rangeVisualizers) do
        if visualizer and visualizer.Parent then
            visualizer:Destroy()
        end
    end
    rangeVisualizers = {}
    rangeBeams = {}
    
    if not _G.ShowBadgeRange then return end
    
    local badgeLocations = findBadgeLocations()
    
    for _, badge in pairs(badgeLocations) do
        local visualizer = createRangeVisualizer(badge.Position, _G.RangeDistance)
        
        -- Add billboard GUI with badge info
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, _G.RangeDistance + 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = visualizer
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 0.5
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.Text = badge.Name .. "\nRange: " .. _G.RangeDistance .. " studs"
        label.TextColor3 = _G.VisualizerColor
        label.TextScaled = true
        label.Parent = billboard
        
        print("Found badge location: " .. badge.Name .. " at " .. tostring(badge.Position))
    end
    
    if #badgeLocations == 0 then
        print("No badge locations found. Creating sample visualizer at player position.")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            createRangeVisualizer(LocalPlayer.Character.HumanoidRootPart.Position, _G.RangeDistance)
        end
    end
end

-- Toggle Range Visualizer
local function toggleRangeVisualizer()
    _G.ShowBadgeRange = not _G.ShowBadgeRange
    
    if _G.ShowBadgeRange then
        updateRangeVisualizers()
        Rayfield:Notify({
            Title = "Range Visualizer",
            Content = "Badge range visualizer enabled",
            Duration = 3,
            Image = nil,
        })
    else
        for _, visualizer in pairs(rangeVisualizers) do
            if visualizer and visualizer.Parent then
                visualizer:Destroy()
            end
        end
        rangeVisualizers = {}
        rangeBeams = {}
        
        Rayfield:Notify({
            Title = "Range Visualizer",
            Content = "Badge range visualizer disabled",
            Duration = 3,
            Image = nil,
        })
    end
    
    updateMobileUI()
end

-- Create Mobile UI
local function createMobileUI()
    if mobileScreenGui then mobileScreenGui:Destroy() end
    
    mobileScreenGui = Instance.new("ScreenGui")
    mobileScreenGui.Name = "RangeVisualizerMobileUI"
    mobileScreenGui.Parent = game.CoreGui
    mobileScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    mobileFrame = Instance.new("Frame")
    mobileFrame.Size = UDim2.new(0, 180, 0, 120)
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
    title.Text = "Range Visualizer"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Parent = mobileFrame
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 30)
    toggleBtn.Position = UDim2.new(0, 5, 0, 30)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    toggleBtn.Text = "Toggle Range"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Parent = mobileFrame
    toggleBtn.MouseButton1Click:Connect(toggleRangeVisualizer)
    
    -- Range Display
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(1, -10, 0, 20)
    rangeLabel.Position = UDim2.new(0, 5, 0, 65)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Text = "Range: " .. _G.RangeDistance .. " studs"
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextSize = 12
    rangeLabel.Parent = mobileFrame
    
    -- Status Display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.Position = UDim2.new(0, 5, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Off"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 12
    statusLabel.Parent = mobileFrame
    
    _G.MobileUIEnabled = true
end

-- Update Mobile UI
local function updateMobileUI()
    if not mobileFrame then return end
    
    local statusLabel = mobileFrame:FindFirstChild("StatusLabel")
    local rangeLabel = mobileFrame:FindFirstChild("RangeLabel")
    local toggleBtn = mobileFrame:FindFirstChild("ToggleButton")
    
    if statusLabel then
        statusLabel.Text = "Status: " .. (_G.ShowBadgeRange and "On" or "Off")
        statusLabel.TextColor3 = _G.ShowBadgeRange and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    
    if rangeLabel then
        rangeLabel.Text = "Range: " .. _G.RangeDistance .. " studs"
    end
    
    if toggleBtn then
        toggleBtn.BackgroundColor3 = _G.ShowBadgeRange and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(70, 70, 70)
    end
end

-- Detect if mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Rayfield UI
local MainTab = Window:CreateTab("Range Visualizer", nil)
local VisualizerSection = MainTab:CreateSection("Badge Range Settings")

-- Toggle Visualizer
local Toggle = MainTab:CreateToggle({
    Name = "Show Badge Range",
    CurrentValue = false,
    Flag = "ShowBadgeRange",
    Callback = function(Value)
        _G.ShowBadgeRange = Value
        if Value then
            updateRangeVisualizers()
        else
            for _, visualizer in pairs(rangeVisualizers) do
                if visualizer and visualizer.Parent then
                    visualizer:Destroy()
                end
            end
            rangeVisualizers = {}
            rangeBeams = {}
        end
        updateMobileUI()
    end,
})

-- Range Slider
local Slider = MainTab:CreateSlider({
    Name = "Range Distance",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "RangeDistance",
    Callback = function(Value)
        _G.RangeDistance = Value
        if _G.ShowBadgeRange then
            updateRangeVisualizers()
        end
        updateMobileUI()
    end,
})

-- Color Picker
local ColorPicker = MainTab:CreateColorPicker({
    Name = "Visualizer Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "VisualizerColor",
    Callback = function(Value)
        _G.VisualizerColor = Value
        if _G.ShowBadgeRange then
            updateRangeVisualizers()
        end
    end
})

-- Refresh Button
local Button = MainTab:CreateButton({
    Name = "Refresh Visualizers",
    Callback = function()
        if _G.ShowBadgeRange then
            updateRangeVisualizers()
            Rayfield:Notify({
                Title = "Range Visualizer",
                Content = "Visualizers refreshed",
                Duration = 2,
            })
        end
    end,
})

-- Auto-detect mobile and create UI
spawn(function()
    wait(2) -- Wait for Rayfield to load
    if isMobile() then
        createMobileUI()
        Rayfield:Notify({
            Title = "Mobile Detected",
            Content = "Touch controls enabled",
            Duration = 5,
        })
    end
end)

-- Initialization
Rayfield:Notify({
    Title = "Range Visualizer Loaded",
    Content = "Use to visualize badge ranges",
    Duration = 5,
})

print("Badge Range Visualizer loaded successfully!")
print("Features: Range visualization, Mobile support, Rayfield UI")
