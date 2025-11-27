-- Load necessary libraries and services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Nameless Hub | Rivals", HidePremium = false, SaveConfig = true, ConfigFolder = "NamelessHub"})

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

-- FOV Circle Drawing
local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = AimFOV
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    
    if isMobile() then
        -- Stationary circle at screen center for mobile
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        -- Mouse-following circle for PC
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
end

-- Update FOV Circle position (PC only)
local function UpdateFOVCircle()
    if not FOVCircle or not FOVCircleEnabled then return end
    
    if not isMobile() then
        -- Update circle position to follow mouse (PC only)
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
    -- Update circle radius based on FOV slider
    FOVCircle.Radius = AimFOV
end

-- Mobile shooting detection
local IsShooting = false
local LastTouchPosition = nil

-- Utility functions
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPartName) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPartName].Position)
            if onScreen then
                local inputPos
                if isMobile() and LastTouchPosition then
                    -- Use last touch position for mobile
                    inputPos = LastTouchPosition
                else
                    -- Use mouse position for PC
                    inputPos = UserInputService:GetMouseLocation()
                end
                
                local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(inputPos.X, inputPos.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

-- Mobile touch input handling for shooting
if isMobile() then
    -- Track touch positions for mobile aiming
    UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        LastTouchPosition = input.Position
    end)
    
    UserInputService.TouchMoved:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        LastTouchPosition = input.Position
    end)
    
    -- Detect mobile shooting (long press or specific gesture)
    local shootConnection
    UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed or not SilentAimEnabled then return end
        
        -- Start tracking for shoot detection (long press)
        local touchTime = tick()
        local touchPosition = input.Position
        LastTouchPosition = touchPosition
        
        shootConnection = RunService.Heartbeat:Connect(function()
            -- If touch is held for more than 0.1 seconds, consider it shooting
            if tick() - touchTime > 0.1 and not IsShooting then
                IsShooting = true
                -- Trigger silent aim for mobile
                local target = GetClosestTarget()
                if target and target.Character and target.Character:FindFirstChild(AimPartName) then
                    -- Mobile shooting logic would go here
                    -- This would depend on the specific game's mobile shooting mechanism
                end
            end
        end)
    end)
    
    UserInputService.TouchEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        IsShooting = false
        if shootConnection then
            shootConnection:Disconnect()
            shootConnection = nil
        end
    end)
end

-- Universal shooting detection (works for both PC and mobile)
local function handleShooting()
    if not SilentAimEnabled then return end
    
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild(AimPartName) then
        return target.Character[AimPartName].Position
    end
    return nil
end

-- Silent Aim Hook (Universal for PC and Mobile)
local mt = getrawmetatable or getmetatable
local oldNamecall
if mt then
    local meta = mt(game)
    oldNamecall = meta.__namecall
    setreadonly(meta, false)
    meta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if SilentAimEnabled and method == "FireServer" then
            -- Check for common shooting event names in Rivals
            local eventName = tostring(self)
            if eventName:find("Shoot") or eventName:find("Fire") or eventName:find("Weapon") or eventName:find("Damage") then
                local targetPos = handleShooting()
                if targetPos then
                    -- Modify the shooting position to target position
                    if args[1] and typeof(args[1]) == "Vector3" then
                        args[1] = targetPos
                    elseif args[1] and typeof(args[1]) == "table" and args[1].Position then
                        args[1].Position = targetPos
                    elseif args[1] and typeof(args[1]) == "table" and args[1].Target then
                        args[1].Target = targetPos
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end

        return oldNamecall(self, ...)
    end)
    setreadonly(meta, true)
end

-- Alternative method for games that don't use RemoteEvents
local function setupMobileShooting()
    if not isMobile() then return end
    
    -- Create a virtual shoot button for mobile if needed
    local virtualShootButton = Instance.new("TextButton")
    virtualShootButton.Name = "VirtualShootBtn"
    virtualShootButton.Size = UDim2.new(0, 80, 0, 80)
    virtualShootButton.Position = UDim2.new(1, -100, 1, -100)
    virtualShootButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    virtualShootButton.BackgroundTransparency = 0.5
    virtualShootButton.Text = "SHOOT"
    virtualShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    virtualShootButton.TextSize = 14
    virtualShootButton.Font = Enum.Font.GothamBold
    virtualShootButton.Visible = false
    virtualShootButton.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local virtualCorner = Instance.new("UICorner")
    virtualCorner.CornerRadius = UDim.new(0, 40)
    virtualCorner.Parent = virtualShootButton
    
    -- Show virtual shoot button when silent aim is enabled on mobile
    SilentAimToggle = function(value)
        if isMobile() then
            virtualShootButton.Visible = value
        end
    end
end

-- ESP Implementation
local espFolder = Instance.new("Folder", Camera)
espFolder.Name = "ESPFolder"

local function CreateESP(player)
    local espBox = Drawing and Drawing.new("Square") or nil
    local espName = Drawing and Drawing.new("Text") or nil

    if not espBox or not espName then return end

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

    return {
        Box = espBox,
        Name = espName
    }
end

local espObjects = {}

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                if not espObjects[player] then
                    espObjects[player] = CreateESP(player)
                end
                local esp = espObjects[player]
                if esp then
                    local size = 1000 / pos.Z
                    esp.Box.Size = Vector2.new(size, size)
                    esp.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - size / 2)
                    esp.Box.Visible = ESPEnabled

                    esp.Name.Position = Vector2.new(pos.X, pos.Y - size / 2 - 15)
                    esp.Name.Visible = ESPEnabled
                end
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

-- Cleanup ESP on player removal
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

-- Combat Tab
CombatTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        SilentAimEnabled = Value
        if isMobile() then
            setupMobileShooting()
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
    Options = {"Head", "HumanoidRootPart", "Torso"},
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
            -- Hide all ESP boxes when turning off
            for _, esp in pairs(espObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
            end
        end
    end    
})

VisualsTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        for _, esp in pairs(espObjects) do
            if esp.Box then
                esp.Box.Color = Value
            end
        end
    end
})

-- Mobile UI Toggle (Only for mobile)
if isMobile() then
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 80, 0, 40)
    MobileToggleButton.Position = UDim2.new(0, 10, 0, 10)
    MobileToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MobileToggleButton.Text = "TOGGLE UI"
    MobileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggleButton.TextSize = 14
    MobileToggleButton.Font = Enum.Font.GothamBold
    MobileToggleButton.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MobileToggleCorner = Instance.new("UICorner")
    MobileToggleCorner.CornerRadius = UDim.new(0, 8)
    MobileToggleCorner.Parent = MobileToggleButton
    
    MobileToggleButton.MouseButton1Click:Connect(function()
        OrionLib:ToggleUI()
    end)
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
    
    -- Update FOV Circle
    if FOVCircleEnabled then
        UpdateFOVCircle()
    end
end)

-- Initialize mobile shooting
setupMobileShooting()

OrionLib:Init()
print("NAMELESS HUB | Rivals Loaded")
print("Mobile Support: " .. tostring(isMobile()))
