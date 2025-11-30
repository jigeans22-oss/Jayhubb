-- MOBILE FPS BOOSTER (iOS RAM-PROTECTION MODE)
-- prevents getting kicked to home screen from memory crash

local lp = game:GetService("Players").LocalPlayer
local ws = workspace
local lighting = game:GetService("Lighting")
local ts = game:GetService("TweenService")

--■■■■ GRAPHICS KILLER ■■■■--
-- Removes expensive post effects
for _, v in ipairs(lighting:GetChildren()) do
    if v:IsA("BloomEffect")
    or v:IsA("DepthOfFieldEffect")
    or v:IsA("SunRaysEffect")
    or v:IsA("ColorCorrectionEffect")
    or v:IsA("BlurEffect") then
        v.Enabled = false
    end
end

-- Removes global shadows (MASSIVE lag saver)
lighting.GlobalShadows = false
lighting.EnvironmentSpecularScale = 0
lighting.EnvironmentDiffuseScale = 0

--■■■■ MAP OPTIMIZER ■■■■--
for _, v in ipairs(ws:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    end
end

--■■■■ PARTICLE & SMOKE REMOVAL ■■■■--
for _, v in ipairs(ws:GetDescendants()) do
    if v:IsA("ParticleEmitter") 
    or v:IsA("Trail") 
    or v:IsA("Smoke")
    or v:IsA("Fire")
    or v:IsA("Sparkles")
    then
        v.Enabled = false
    end
end

--■■■■ ENTITY LIMITER (reduces memory spikes) ■■■■--
game:GetService("RunService").Heartbeat:Connect(function()
    for _, v in ipairs(ws:GetChildren()) do
        -- remove random trash models that servers spam
        if v:IsA("Model") and #v:GetChildren() > 150 then
            v:Destroy()
        end
    end
end)

--■■■■ TEXTURE UNLOADER ■■■■--
local function unloadTextures()
    for _, v in ipairs(ws:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Texture = ""
        end
    end
end
unloadTextures()

--■■■■ FPS UNLOCKER STYLE RENDER DROP ■■■■--
setfpscap(50) -- best for iOS: stable performance without spikes

--■■■■ MEMORY PROTECTOR ■■■■--
collectgarbage("collect")   -- clear lua memory
collectgarbage("collect")   -- double pass (mobile safe)

print("✓ FPS Booster Activated (Mobile Safe)")
