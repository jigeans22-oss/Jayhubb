-- Nameless Hub | Rivals
-- Fixed Orion UI Version

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for player
repeat wait() until LocalPlayer.Character

-- Load Orion UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "Nameless Hub | Rivals",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NamelessHubRivals",
    IntroEnabled = true,
    IntroText = "Nameless Hub"
})

-- Configuration
local SilentAimEnabled = false
local ESPEnabled = false
local FOVCircleEnabled = false
local AimFOV = 100
local AimPartName = "Head"

-- Mobile detection
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- FOV Circle
local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then 
        FOVCircle:Remove() 
        FOVCircle = nil
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = AimFOV
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    
    if isMobile() then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
end

local function UpdateFOVCircle()
    if not FOVCircle or not FOVCircleEnabled then return end
    
    if not isMobile() then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
    FOVCircle.Radius = AimFOV
end

-- Target finding
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local aimPart = player.Character:FindFirstChild(AimPartName)
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local targetPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local inputPos
                    if isMobile() then
                        inputPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    else
                        inputPos = UserInputService:GetMouseLocation()
                    end
                    
                    local distance = (Vector2.new(targetPos.X, targetPos.Y) - inputPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = player
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Silent Aim Logic
local function GetClosestTargetPosition()
    if not SilentAimEnabled then return nil end
    
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild(AimPartName) then
        return target.Character[AimPartName].Position
    end
    return nil
end

-- Hook for shooting
local oldNamecall
local hooked = false

local function setupSilentAim()
    if hooked then return end
    
    local success, errorMsg = pcall(function()
        if not getrawmetatable then
            error("getrawmetatable not available")
        end
        
        local meta = getrawmetatable(game)
        if not meta then
            error("Could not get metatable")
        end
        
        oldNamecall = meta.__namecall
        
        setreadonly(meta, false)
        
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if SilentAimEnabled and (method == "FireServer" or method == "invokeServer") then
                local targetPos = GetClosestTargetPosition()
                if targetPos then
                    -- Modify shooting arguments for Rivals
                    if type(args[1]) == "table" then
                        if args[1].Position then
                            args[1].Position = targetPos
                        elseif args[1].Target then
                            args[1].Target = targetPos
                        end
                    elseif type(args[1]) == "Vector3" then
                        args[1] = targetPos
                    end
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(meta, true)
        hooked = true
    end)
    
    if not success then
        warn("Silent Aim hook failed: " .. tostring(errorMsg))
    end
end

-- ESP System
local espObjects = {}
local function CreateESP(player)
    local espBox = Drawing.new("Square")
    local espName = Drawing.new("Text")
    
    espBox.Visible = false
    espBox.Color = Color3.new(1, 0, 0)
    espBox.Thickness = 2
    espBox.Filled = false
    
    espName.Visible = false
    espName.Color = Color3.new(1, 1, 1)
    espName.Size = 14
    espName.Center = true
    espName.Outline = true
    espName.Text = player.Name
    
    return {Box = espBox, Name = espName}
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    if not espObjects[player] then
                        espObjects[player] = CreateESP(player)
                    end
                    
                    local esp = espObjects[player]
                    local size = 1000 / pos.Z
                    
                    esp.Box.Size = Vector2.new(size, size)
                    esp.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    esp.Box.Visible = ESPEnabled
                    
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    esp.Name.Visible = ESPEnabled
                else
                    if espObjects[player] then
                        espObjects[player].Box.Visible = false
                        espObjects[player].Name.Visible = false
                    end
                end
            else
                if espObjects[player] then
                    espObjects[player].Box.Visible = false
                    espObjects[player].Name.Visible = false
                end
            end
        end
    end
end

-- Clean up ESP when players leave
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        if espObjects[player].Box then espObjects[player].Box:Remove() end
        if espObjects[player].Name then espObjects[player].Name:Remove() end
        espObjects[player] = nil
    end
end)

-- Create Tabs
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals", 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

-- Combat Tab
CombatTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        SilentAimEnabled = Value
        if Value then
            setupSilentAim()
        end
    end    
})

CombatTab:AddToggle({
    Name = "FOV Circle", 
    Default = false,
    Callback = function(Value)
        FOVCircleEnabled = Value
        if Value then
            CreateFOVCircle()
        elseif FOVCircle then
            FOVCircle.Visible = false
        end
    end    
})

CombatTab:AddSlider({
    Name = "Aim FOV",
    Min = 10,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "FOV",
    Callback = function(Value)
        AimFOV = Value
        if FOVCircle then
            FOVCircle.Radius = Value
        end
    end    
})

CombatTab:AddDropdown({
    Name = "Aim Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Callback = function(Value)
        AimPartName = Value
    end    
})

-- Visuals Tab
VisualsTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            -- Hide all ESP when turned off
            for _, esp in pairs(espObjects) do
                esp.Box.Visible = false
                esp.Name.Visible = false
            end
        end
    end    
})

VisualsTab:AddColorpicker({
    Name = "ESP Color", 
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        for _, esp in pairs(espObjects) do
            esp.Box.Color = Value
        end
    end
})

VisualsTab:AddToggle({
    Name = "Show Names",
    Default = true,
    Callback = function(Value)
        for _, esp in pairs(espObjects) do
            esp.Name.Visible = Value and ESPEnabled
        end
    end
})

-- Settings Tab
SettingsTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
        -- Clean up drawings
        if FOVCircle then
            FOVCircle:Remove()
        end
        for _, esp in pairs(espObjects) do
            esp.Box:Remove()
            esp.Name:Remove()
        end
    end    
})

SettingsTab:AddLabel("Mobile Mode: " .. tostring(isMobile()))
SettingsTab:AddLabel("Made by Haxzo")

-- Mobile UI Toggle Button
if isMobile() then
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Name = "MobileUIToggle"
    MobileToggle.Size = UDim2.new(0, 100, 0, 40)
    MobileToggle.Position = UDim2.new(0, 10, 0, 10)
    MobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggle.Text = "TOGGLE UI"
    MobileToggle.TextSize = 14
    MobileToggle.Font = Enum.Font.GothamBold
    MobileToggle.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MobileToggle
    
    MobileToggle.MouseButton1Click:Connect(function()
        OrionLib:ToggleUI()
    end)
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
    
    if FOVCircleEnabled then
        UpdateFOVCircle()
    end
end)

-- Initialize silent aim hook
setupSilentAim()

-- Init Orion UI
OrionLib:Init()

print("Nameless Hub | Rivals - Orion UI Loaded!")
print("Platform: " .. (isMobile() and "Mobile" or "PC"))
