-- PHILLY STREETZ SAFE FPS BOOST
-- Extreme visuals reduction, crash-safe

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- ===== LIGHTING (SAFE & FAST) =====
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogStart = 0
    Lighting.FogEnd = 1e9
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end)

-- Disable post-processing
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("PostEffect") then
        v.Enabled = false
    end
end

-- ===== TERRAIN WATER =====
pcall(function()
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
end)

-- ===== SLOW WORKSPACE OPTIMIZATION =====
task.spawn(function()
    local processed = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1

        elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles") then
            obj.Enabled = false
        end

        processed += 1
        if processed % 250 == 0 then
            task.wait() -- PREVENTS CRASH
        end
    end
end)

-- ===== FPS CAP (SAFE) =====
pcall(function()
    if setfpscap then
        setfpscap(120) -- use 60 if mobile is still laggy
    end
end)

print("✅ Philly Streetz FPS Boost Applied")
