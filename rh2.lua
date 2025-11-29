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

local LocalPlayer = Players.LocalPlayer

-- Configuration
_G.ShowShotRange = false
_G.ShowDunkRange = false
_G.ShowPassRange = false
_G.RangeDistance = 30

-- Visualizer Parts
local rangeVisualizers = {}

-- Create Range Visualizer
local function createRH2Visualizer(position, radius, locationType)
    local color = Color3.fromRGB(255, 0, 0) -- Default red
    
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

-- Find RH2 Locations
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
    
    -- Find court areas
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("court") or obj.Name:lower():find("floor") then
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
    
    -- Find three-point line
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("three") or obj.Name:lower():find("3pt") then
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
    
    -- If no locations found, create default positions
    if #locations == 0 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local rootPos = char.HumanoidRootPart.Position
            table.insert(locations, {
                Position = rootPos + Vector3.new(0, 0, 50),
                Name = "Default Hoop",
                Type = "Hoop"
            })
            table.insert(locations, {
                Position = rootPos + Vector3.new(25, 0, 0),
                Name = "Default 3-Point",
                Type = "ThreePoint"
            })
        end
    end
    
    return locations
end

-- Update Visualizers
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
    
    local locations = findRH2Locations()
    
    for _, location in pairs(locations) do
        if _G.ShowShotRange and (location.Type == "Hoop" or location.Type == "ThreePoint") then
            createRH2Visualizer(location.Position, _G.RangeDistance, location.Type)
        end
        
        if _G.ShowDunkRange and location.Type == "Court" then
            createRH2Visualizer(location.Position, _G.RangeDistance, "Dunk")
        end
    end
    
    print("Created " .. #rangeVisualizers .. " visualizers")
end

-- Rayfield UI
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
        if _G.ShowShotRange or _G.ShowDunkRange then
            updateRH2Visualizers()
        end
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

-- Cleanup Button
local CleanButton = MainTab:CreateButton({
    Name = "Clear All Visualizers",
    Callback = function()
        for _, visualizer in pairs(rangeVisualizers) do
            if visualizer and visualizer.Parent then
                visualizer:Destroy()
            end
        end
        rangeVisualizers = {}
        _G.ShowShotRange = false
        _G.ShowDunkRange = false
        ShotToggle:Set(false)
        DunkToggle:Set(false)
    end,
})

-- Auto-cleanup when player leaves
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, visualizer in pairs(rangeVisualizers) do
            if visualizer and visualizer.Parent then
                visualizer:Destroy()
            end
        end
    end
end)

-- Initialization
Rayfield:Notify({
    Title = "RH2 Visualizer Loaded",
    Content = "Toggle ranges to see visual spheres",
    Duration = 5,
})

print("RH2 Basketball Visualizer loaded successfully!")
