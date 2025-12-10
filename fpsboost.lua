-- Auto FPS Booster (No UI Version)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

print("🚀 Auto FPS Booster Initializing...")

-- Store original settings for potential restoration
local OriginalSettings = {
    GraphicsQuality = Enum.SavedQualitySetting.QualityLevel10,
    Shadows = Lighting.ShadowSoftness,
    Lighting = Lighting.GlobalShadows,
    Particles = {},
    Effects = {},
    Terrain = {}
}

-- Apply all optimizations immediately
function applyUltraSettings()
    print("⚡ Applying maximum FPS optimizations...")
    
    -- Set lowest graphics quality
    settings().Rendering.QualityLevel = 1
    
    -- Disable all shadows
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.ShadowColor = Color3.fromRGB(178, 178, 183)
    
    -- Disable lighting effects
    Lighting.Outlines = false
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.FogEnd = 1000000
    Lighting.Bloom.Enabled = false
    Lighting.Blur.Enabled = false
    Lighting.SunRays.Enabled = false
    Lighting.ColorCorrection.Enabled = false
    Lighting.DepthOfField.Enabled = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    
    -- Remove materials if possible (Plastic uses less resources)
    if sethiddenproperty then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    sethiddenproperty(part, "Material", Enum.Material.Plastic)
                end)
            end
        end
    end
    
    -- Disable all particles
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or 
           obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
            if not OriginalSettings.Effects[obj] then
                OriginalSettings.Effects[obj] = obj.Enabled
            end
        end
    end
    
    -- Remove textures and decals
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Remove textures
            if obj:FindFirstChildWhichIsA("Texture") then
                for _, texture in pairs(obj:GetChildren()) do
                    if texture:IsA("Texture") then
                        texture:Destroy()
                    end
                end
            end
            -- Remove decals
            if obj:FindFirstChildWhichIsA("Decal") then
                for _, decal in pairs(obj:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal:Destroy()
                    end
                end
            end
        end
    end
    
    -- Hide terrain
    if Terrain then
        Terrain.Transparency = 1
        OriginalSettings.Terrain.Transparency = Terrain.Transparency
    end
    
    -- Disable lights
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        end
    end
    
    -- Reduce physics quality
    settings().Physics.ThrottleAdjustTime = 2
    settings().Physics.AllowSleep = true
    
    -- Reduce render distance
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(game:GetService("Workspace").CurrentCamera, "MaxAxisRenderDistance", 100)
        end)
    end
    
    -- Lower texture quality
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(game, "TextureQuality", 0.1)
        end)
    end
    
    -- Disable character animations for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            end
        end
    end
    
    -- Handle new players joining
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            end
        end)
    end)
    
    print("✅ All optimizations applied!")
end

-- FPS monitoring and auto-adjustment
local frameCount = 0
local fps = 60
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 1 then
        fps = math.floor(frameCount / (currentTime - lastTime))
        frameCount = 0
        lastTime = currentTime
    end
end)

-- Performance monitoring
task.spawn(function()
    while task.wait(2) do
        -- Auto-collect garbage when memory is high
        local mem = collectgarbage("count")
        if mem > 10000 then -- If memory > ~10MB
            collectgarbage("collect")
        end
        
        -- Additional optimization if FPS drops below 30
        if fps < 30 then
            -- Clear unused sound instances
            for _, instance in pairs(game:GetDescendants()) do
                if instance:IsA("Sound") and not instance.Playing then
                    instance:Destroy()
                end
            end
        end
    end
end)

-- Apply optimizations on new instances
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    
    -- Auto-disable new particles
    if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or 
       descendant:IsA("Smoke") or descendant:IsA("Fire") then
        descendant.Enabled = false
    end
    
    -- Auto-disable new lights
    if descendant:IsA("PointLight") or descendant:IsA("SurfaceLight") or descendant:IsA("SpotLight") then
        descendant.Enabled = false
    end
    
    -- Remove textures from new parts
    if descendant:IsA("BasePart") then
        if sethiddenproperty then
            pcall(function()
                sethiddenproperty(descendant, "Material", Enum.Material.Plastic)
            end)
        end
        
        -- Auto-remove textures/decals from new parts
        for _, child in pairs(descendant:GetChildren()) do
            if child:IsA("Texture") or child:IsA("Decal") then
                child:Destroy()
            end
        end
    end
end)

-- Apply initial optimizations with delay
task.wait(1)
applyUltraSettings()

print("🎮 FPS Booster Active!")
print("📊 Graphics set to minimum quality")
print("🔧 All optimizations applied automatically")

-- Optional: Add a simple way to restore settings (hold R key for 3 seconds)
local restoreStartTime = nil
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R and not gameProcessed then
        restoreStartTime = tick()
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R and restoreStartTime then
        local holdTime = tick() - restoreStartTime
        if holdTime >= 3 then
            print("🔄 Restoring original graphics settings...")
            -- Restore basic settings (partial restore)
            settings().Rendering.QualityLevel = OriginalSettings.GraphicsQuality
            Lighting.GlobalShadows = OriginalSettings.Lighting
            Lighting.ShadowSoftness = OriginalSettings.Shadows
            Lighting.Outlines = true
            Lighting.Brightness = 1
            print("✅ Original settings restored (partial)")
        end
        restoreStartTime = nil
    end
end)
