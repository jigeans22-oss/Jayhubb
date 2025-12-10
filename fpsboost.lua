-- Bronx 3 Graphics Downgrader + FPS Booster
-- Put this in your autoexec folder or execute in-game

local GraphicsDowngrader = {}

-- Main downgrade function
function GraphicsDowngrader:ApplyMaxDowngrade()
    -- Force lowest possible graphics settings
    settings().Rendering.QualityLevel = "Level01"
    
    -- Disable expensive visual effects
    settings().Rendering.EagerBulkExecution = true
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").FogEnd = 9e9
    
    -- Turn off shadows completely
    sethiddenproperty(game:GetService("Lighting"), "Technology", "Compatibility")
    
    -- Minimal lighting
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 12
    lighting.GeographicLatitude = 0
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    -- Disable post-processing
    lighting.Blur.Enabled = false
    lighting.SunRays.Enabled = false
    lighting.ColorCorrection.Enabled = false
    lighting.DepthOfField.Enabled = false
    
    -- Reduce particle limits
    settings().Rendering.MaxParticleCount = 10
    settings().Rendering.MaxParticleTexture = 64
    
    -- Force low quality models
    settings().Rendering.EagerBulkExecution = true
    settings().Rendering.FrameRateManager = "Automatic"
    
    -- Reduce texture quality
    settings().Rendering.TextureQuality = 0
    settings().Rendering.MeshPartDetailLevel = "Low"
    
    -- Low quality water
    if workspace:FindFirstChildOfClass("WaterForce") then
        workspace:FindFirstChildOfClass("WaterForce").Enabled = false
    end
    
    -- Reduce character quality
    game:GetService("StarterPlayer").AllowCustomAnimations = false
    
    -- Minimal sound quality
    settings().Rendering.RenderCSGTrianglesDebug = false
end

-- Function to downgrade all existing parts
function GraphicsDowngrader:DowngradeExistingParts()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Remove expensive materials
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
            
            -- Remove textures
            if part:FindFirstChildWhichIsA("Texture") then
                part:FindFirstChildWhichIsA("Texture"):Destroy()
            end
            
            -- Remove decals
            for _, decal in ipairs(part:GetChildren()) do
                if decal:IsA("Decal") then
                    decal:Destroy()
                end
            end
        end
        
        -- Downgrade particle emitters
        if part:IsA("ParticleEmitter") then
            part.Rate = 1
            part.Lifetime = NumberRange.new(0.5)
            part.Enabled = false
        end
        
        -- Disable expensive GUIs
        if part:IsA("SurfaceGui") or part:IsA("BillboardGui") then
            part.Enabled = false
        end
    end
end

-- Function to continuously downgrade new parts
function GraphicsDowngrader:MonitorAndDowngrade()
    workspace.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        
        if descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.Plastic
            descendant.Reflectance = 0
        elseif descendant:IsA("ParticleEmitter") then
            descendant.Enabled = false
        elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
            descendant.Enabled = false
        end
    end)
end

-- Ultra low poly mode (makes everything boxy)
function GraphicsDowngrader:EnableUltraLowPolyMode()
    for _, mesh in ipairs(workspace:GetDescendants()) do
        if mesh:IsA("SpecialMesh") or mesh:IsA("MeshPart") then
            -- Replace meshes with basic blocks
            if mesh.Parent:IsA("BasePart") then
                mesh:Destroy()
                mesh.Parent.Shape = Enum.PartType.Block
            end
        end
    end
end

-- Aggressive texture compression (makes things blurry)
function GraphicsDowngrader:EnableTextureCompression()
    for _, texture in ipairs(workspace:GetDescendants()) do
        if texture:IsA("Texture") or texture:IsA("Decal") then
            -- Force smallest texture size
            texture.Texture = "rbxassetid://0" -- Invalid texture = no texture
        end
    end
end

-- Remove all particles
function GraphicsDowngrader:RemoveAllParticles()
    for _, particle in ipairs(workspace:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Trail") or particle:IsA("Beam") then
            particle:Destroy()
        end
    end
end

-- Minimal audio quality
function GraphicsDowngrader:ReduceAudioQuality()
    for _, sound in ipairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0.1
            sound.PlaybackSpeed = 1
            sound.Looped = false
        end
    end
end

-- Main execution
function GraphicsDowngrader:ExecuteFullDowngrade()
    print("[FPS BOOSTER] Applying maximum graphics downgrade...")
    
    -- Apply settings
    self:ApplyMaxDowngrade()
    
    -- Process existing content
    self:DowngradeExistingParts()
    self:EnableUltraLowPolyMode()
    self:EnableTextureCompression()
    self:RemoveAllParticles()
    self:ReduceAudioQuality()
    
    -- Start monitoring for new content
    self:MonitorAndDowngrade()
    
    print("[FPS BOOSTER] Graphics have been horribly downgraded!")
    print("[FPS BOOSTER] Your FPS should now be much higher (but everything looks terrible)")
end

-- Run the downgrader
GraphicsDowngrader:ExecuteFullDowngrade()

-- Create a simple GUI to control the downgrader
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local UltraMode = Instance.new("TextButton")

ScreenGui.Name = "FPSExtremeBooster"
ScreenGui.Parent = game:GetService("CoreGui")

Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.8, 0, 0.1, 0)
Frame.Size = UDim2.new(0, 200, 0, 150)

Title.Name = "Title"
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "EXTREME FPS BOOSTER"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextSize = 14

Status.Name = "Status"
Status.Parent = Frame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 0, 0.2, 0)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Font = Enum.Font.SourceSans
Status.Text = "Status: ACTIVE\nGraphics: HORRIBLE"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 12

UltraMode.Name = "UltraMode"
UltraMode.Parent = Frame
UltraMode.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
UltraMode.Position = UDim2.new(0.1, 0, 0.5, 0)
UltraMode.Size = UDim2.new(0.8, 0, 0, 40)
UltraMode.Font = Enum.Font.SourceSansBold
UltraMode.Text = "ULTRA LOW POLY MODE"
UltraMode.TextColor3 = Color3.fromRGB(255, 255, 255)
UltraMode.TextSize = 12

UltraMode.MouseButton1Click:Connect(function()
    GraphicsDowngrader:EnableUltraLowPolyMode()
    Status.Text = "Status: ULTRA MODE\nEverything is now boxes!"
end)

-- Keep downgrading periodically
while true do
    task.wait(5)
    GraphicsDowngrader:DowngradeExistingParts()
end
