local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- Load Obscidian UI
local Obscidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/ObscidianHub/Obscidian/main/obscidian.lua"))()

-- Create window
local Window = Obscidian:New({
    Name = "FPS Booster",
    Icon = "rbxassetid://4483362458",
    ShowLogo = true,
    Logo = "rbxassetid://4483362458",
    Theme = "Dark",
    Size = UDim2.new(0, 450, 0, 400)
})

-- Store original settings
local OriginalSettings = {
    GraphicsQuality = Enum.SavedQualitySetting.QualityLevel10,
    Shadows = Lighting.ShadowSoftness,
    Lighting = Lighting.GlobalShadows,
    Materials = sethiddenproperty or set_hidden_property,
    Particles = {},
    Effects = {},
    Terrain = {}
}

-- Main tab
local MainTab = Window:Tab("Boost", "rbxassetid://4483362458")

-- FPS counter
local FPSCounter = Instance.new("ScreenGui")
FPSCounter.Name = "FPSDisplay"
FPSCounter.ResetOnSpawn = false
FPSCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPS"
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 60"
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FPSLabel.TextSize = 18
FPSLabel.Font = Enum.Font.Code
FPSLabel.Position = UDim2.new(0, 10, 0, 10)
FPSLabel.Size = UDim2.new(0, 100, 0, 25)
FPSLabel.Parent = FPSCounter

local frameCount = 0
local fps = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 1 then
        fps = math.floor(frameCount / (currentTime - lastTime))
        frameCount = 0
        lastTime = currentTime
        FPSLabel.Text = "FPS: " .. fps
    end
end)

-- FPS display toggle
local FPSDisplayEnabled = true
MainTab:Toggle({
    Name = "Show FPS Counter",
    Default = true,
    Callback = function(value)
        FPSDisplayEnabled = value
        if value then
            FPSCounter.Parent = game.CoreGui
        else
            FPSCounter.Parent = nil
        end
    end
})

-- Ultra performance mode
local UltraMode = false
MainTab:Toggle({
    Name = "Ultra Performance Mode",
    Default = false,
    Callback = function(value)
        UltraMode = value
        if value then
            applyUltraSettings()
        else
            restoreOriginalSettings()
        end
    end
})

-- Graphics quality slider
MainTab:Slider({
    Name = "Graphics Quality",
    Min = 1,
    Max = 10,
    Default = 10,
    Callback = function(value)
        settings().Rendering.QualityLevel = value
        if value <= 3 then
            applyLowGraphics()
        end
    end
})

-- Individual settings
local settingsToggles = {}

MainTab:Toggle({
    Name = "Disable Shadows",
    Default = false,
    Callback = function(value)
        settingsToggles.Shadows = value
        if value then
            Lighting.GlobalShadows = false
            Lighting.ShadowSoftness = 0
        else
            Lighting.GlobalShadows = true
            Lighting.ShadowSoftness = OriginalSettings.Shadows
        end
    end
})

MainTab:Toggle({
    Name = "Disable Lighting",
    Default = false,
    Callback = function(value)
        settingsToggles.Lighting = value
        if value then
            Lighting.Outlines = false
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        else
            Lighting.Outlines = true
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(0.5, 0.5, 0.5)
            Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
        end
    end
})

MainTab:Toggle({
    Name = "Remove Textures",
    Default = false,
    Callback = function(value)
        settingsToggles.Textures = value
        if value then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if obj:FindFirstChildWhichIsA("Texture") then
                        for _, texture in pairs(obj:GetChildren()) do
                            if texture:IsA("Texture") then
                                texture:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
})

MainTab:Toggle({
    Name = "Disable Particles",
    Default = false,
    Callback = function(value)
        settingsToggles.Particles = value
        if value then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                    obj.Enabled = false
                    if not OriginalSettings.Particles[obj] then
                        OriginalSettings.Particles[obj] = obj.Enabled
                    end
                end
            end
        else
            for obj, originalState in pairs(OriginalSettings.Particles) do
                if obj and obj.Parent then
                    obj.Enabled = originalState
                end
            end
        end
    end
})

MainTab:Toggle({
    Name = "Remove Terrain",
    Default = false,
    Callback = function(value)
        settingsToggles.Terrain = value
        if value and Terrain then
            Terrain.Transparency = 1
            OriginalSettings.Terrain.Transparency = Terrain.Transparency
        elseif Terrain then
            Terrain.Transparency = OriginalSettings.Terrain.Transparency or 0
        end
    end
})

MainTab:Toggle({
    Name = "Low Quality Water",
    Default = false,
    Callback = function(value)
        settingsToggles.Water = value
        if value then
            if Terrain and Terrain:FindFirstChildOfClass("Water") then
                for _, water in pairs(Terrain:GetChildren()) do
                    if water:IsA("Water") then
                        water.Transparency = 0.8
                        water.WaveSize = 0
                        water.WaveSpeed = 0
                        if not OriginalSettings.Effects[water] then
                            OriginalSettings.Effects[water] = {
                                Transparency = water.Transparency,
                                WaveSize = water.WaveSize,
                                WaveSpeed = water.WaveSpeed
                            }
                        end
                    end
                end
            end
        else
            for obj, settings in pairs(OriginalSettings.Effects) do
                if obj and obj.Parent then
                    obj.Transparency = settings.Transparency
                    obj.WaveSize = settings.WaveSize
                    obj.WaveSpeed = settings.WaveSpeed
                end
            end
        end
    end
})

-- Optimization functions
function applyUltraSettings()
    -- Set lowest graphics
    settings().Rendering.QualityLevel = 1
    
    -- Disable all shadows
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.ShadowColor = Color3.fromRGB(178, 178, 183)
    
    -- Remove effects
    Lighting.FogEnd = 1000000
    Lighting.Bloom.Enabled = false
    Lighting.Blur.Enabled = false
    Lighting.SunRays.Enabled = false
    Lighting.ColorCorrection.Enabled = false
    Lighting.DepthOfField.Enabled = false
    
    -- Set basic lighting
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.Outlines = false
    
    -- Remove materials if possible
    if sethiddenproperty then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    sethiddenproperty(part, "Material", Enum.Material.Plastic)
                end)
            end
        end
    end
    
    -- Remove particles
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
            if not OriginalSettings.Effects[obj] then
                OriginalSettings.Effects[obj] = obj.Enabled
            end
        end
    end
    
    -- Remove textures
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj:FindFirstChildWhichIsA("Texture") then
                for _, texture in pairs(obj:GetChildren()) do
                    if texture:IsA("Texture") then
                        texture:Destroy()
                    end
                end
            end
            if obj:FindFirstChildWhichIsA("Decal") then
                for _, decal in pairs(obj:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal:Destroy()
                    end
                end
            end
        end
    end
    
    -- Disable terrain
    if Terrain then
        Terrain.Transparency = 1
        OriginalSettings.Terrain.Transparency = Terrain.Transparency
    end
end

function applyLowGraphics()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Outlines = false
end

function restoreOriginalSettings()
    settings().Rendering.QualityLevel = OriginalSettings.GraphicsQuality
    
    if OriginalSettings.Shadows then
        Lighting.ShadowSoftness = OriginalSettings.Shadows
    end
    
    Lighting.GlobalShadows = true
    Lighting.Outlines = true
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(0.5, 0.5, 0.5)
    
    -- Restore particles
    for obj, enabled in pairs(OriginalSettings.Particles) do
        if obj and obj.Parent then
            obj.Enabled = enabled
        end
    end
    
    -- Restore terrain
    if Terrain and OriginalSettings.Terrain.Transparency then
        Terrain.Transparency = OriginalSettings.Terrain.Transparency
    end
    
    -- Restore effects
    for obj, settings in pairs(OriginalSettings.Effects) do
        if obj and obj.Parent then
            if type(settings) == "boolean" then
                obj.Enabled = settings
            elseif type(settings) == "table" then
                for prop, value in pairs(settings) do
                    pcall(function()
                        obj[prop] = value
                    end)
                end
            end
        end
    end
end

-- Buttons tab
local ButtonsTab = Window:Tab("Quick Actions", "rbxassetid://4483362458")

ButtonsTab:Button({
    Name = "Apply Maximum Boost",
    Callback = function()
        applyUltraSettings()
        for _, toggle in pairs(settingsToggles) do
            if type(toggle) == "function" then
                toggle(true)
            end
        end
    end
})

ButtonsTab:Button({
    Name = "Reset All Settings",
    Callback = function()
        restoreOriginalSettings()
        for _, toggle in pairs(settingsToggles) do
            if type(toggle) == "function" then
                toggle(false)
            end
        end
        UltraMode = false
    end
})

ButtonsTab:Button({
    Name = "Remove All Decals",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") then
                obj:Destroy()
            end
        end
    end
})

ButtonsTab:Button({
    Name = "Disable All Lights",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
                obj.Enabled = false
            end
        end
    end
})

ButtonsTab:Button({
    Name = "Reduce Render Distance",
    Callback = function()
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(game:GetService("Workspace").CurrentCamera, "MaxAxisRenderDistance", 100)
            end)
        end
    end
})

-- Advanced tab
local AdvancedTab = Window:Tab("Advanced", "rbxassetid://4483362458")

AdvancedTab:Toggle({
    Name = "Disable Character Animations",
    Default = false,
    Callback = function(value)
        if value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                    end
                end
            end
        end
    end
})

AdvancedTab:Toggle({
    Name = "Reduce Physics Quality",
    Default = false,
    Callback = function(value)
        if value then
            settings().Physics.ThrottleAdjustTime = 2
            settings().Physics.AllowSleep = true
        else
            settings().Physics.ThrottleAdjustTime = 0.5
            settings().Physics.AllowSleep = false
        end
    end
})

AdvancedTab:Slider({
    Name = "Texture Quality",
    Min = 1,
    Max = 10,
    Default = 10,
    Callback = function(value)
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(game, "TextureQuality", value / 10)
            end)
        end
    end
})

-- Performance monitor
local PerformanceTab = Window:Tab("Monitor", "rbxassetid://4483362458")

local memLabel = Instance.new("TextLabel")
memLabel.Name = "Memory"
memLabel.BackgroundTransparency = 1
memLabel.Text = "Memory: 0 MB"
memLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
memLabel.TextSize = 16
memLabel.Font = Enum.Font.Code
memLabel.Position = UDim2.new(0, 10, 0, 40)
memLabel.Size = UDim2.new(0, 150, 0, 25)
memLabel.Parent = FPSCounter

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "Ping"
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: 0ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
pingLabel.TextSize = 16
pingLabel.Font = Enum.Font.Code
pingLabel.Position = UDim2.new(0, 10, 0, 70)
pingLabel.Size = UDim2.new(0, 150, 0, 25)
pingLabel.Parent = FPSCounter

task.spawn(function()
    while task.wait(1) do
        -- Memory usage
        local mem = collectgarbage("count")
        memLabel.Text = string.format("Memory: %.1f MB", mem / 1024)
        
        -- Ping
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        pingLabel.Text = string.format("Ping: %dms", ping)
    end
end)

PerformanceTab:Toggle({
    Name = "Show Performance Stats",
    Default = true,
    Callback = function(value)
        if value then
            memLabel.Visible = true
            pingLabel.Visible = true
        else
            memLabel.Visible = false
            pingLabel.Visible = false
        end
    end
})

PerformanceTab:Button({
    Name = "Collect Garbage",
    Callback = function()
        collectgarbage("collect")
    end
})

PerformanceTab:Button({
    Name = "Clear Instances",
    Callback = function()
        for _, instance in pairs(game:GetDescendants()) do
            if instance:IsA("Sound") and not instance.Playing then
                instance:Destroy()
            end
        end
    end
})

-- Auto-optimize
PerformanceTab:Toggle({
    Name = "Auto-Optimize at Low FPS",
    Default = false,
    Callback = function(value)
        if value then
            task.spawn(function()
                while task.wait(5) do
                    if fps < 30 and not UltraMode then
                        applyLowGraphics()
                    end
                end
            end)
        end
    end
})

-- Initialize
FPSCounter.Parent = game.CoreGui
Window:SelectTab(MainTab)

-- Apply initial low settings if FPS is low
task.wait(2)
if fps < 30 then
    applyLowGraphics()
end
