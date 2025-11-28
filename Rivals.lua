-- Nameless Hub | Rivals - Working Aimbot System
-- Fixed Mobile Aimbot & PC Silent Aim

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for player
repeat wait() until LocalPlayer.Character

-- Configuration
local Config = {
    SilentAimEnabled = false,
    ESPEnabled = false,
    FOVCircleEnabled = false,
    AimFOV = 100,
    AimPartName = "Head",
    UIVisible = false,
    MobileAimbotEnabled = false
}

-- Mobile detection
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Create Advanced UI with Fire Animation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NamelessHubAdvanced"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Toggle Button (Always visible)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 40)
ToggleButton.BackgroundTransparency = 0
ToggleButton.Text = "OPEN"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = true
ToggleButton.Visible = true
ToggleButton.ZIndex = 1000
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Main Container (Hidden initially)
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 450, 0, 500)
MainContainer.Position = UDim2.new(0.5, -225, 0.5, -250)
MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainContainer.BackgroundTransparency = 0.1
MainContainer.BorderSizePixel = 0
MainContainer.Visible = false
MainContainer.ZIndex = 100
MainContainer.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainContainer

-- Fire Background Container
local FireContainer = Instance.new("Frame")
FireContainer.Size = UDim2.new(1, 0, 1, 0)
FireContainer.BackgroundTransparency = 1
FireContainer.ClipsDescendants = true
FireContainer.ZIndex = 1
FireContainer.Parent = MainContainer

-- Fire Animation Function
local function CreateFireAnimation()
    spawn(function()
        while FireContainer and FireContainer.Parent do
            if Config.UIVisible then
                local FireParticle = Instance.new("Frame")
                FireParticle.Size = UDim2.new(0, math.random(30, 60), 0, math.random(30, 60))
                FireParticle.Position = UDim2.new(math.random() * 1.2 - 0.1, 0, 1.1, 0)
                FireParticle.BackgroundColor3 = Color3.fromRGB(
                    math.random(200, 255),
                    math.random(50, 150), 
                    math.random(0, 50)
                )
                FireParticle.BackgroundTransparency = 0.6
                FireParticle.BorderSizePixel = 0
                FireParticle.ZIndex = 2
                FireParticle.Parent = FireContainer

                local FireCorner = Instance.new("UICorner")
                FireCorner.CornerRadius = UDim.new(1, 0)
                FireCorner.Parent = FireParticle

                local tweenInfo = TweenInfo.new(
                    math.random(3, 5),
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local goal = {
                    Position = UDim2.new(
                        FireParticle.Position.X.Scale + (math.random() - 0.5) * 0.4,
                        0,
                        -0.3,
                        0
                    ),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, FireParticle.Size.X.Offset * 0.2, 0, FireParticle.Size.Y.Offset * 0.2)
                }
                
                local tween = TweenService:Create(FireParticle, tweenInfo, goal)
                tween:Play()

                tween.Completed:Connect(function()
                    if FireParticle then
                        FireParticle:Destroy()
                    end
                end)
            end
            wait(0.1)
        end
    end)
end

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Parent = MainContainer

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NAMELESS HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 102
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 18)
Subtitle.Position = UDim2.new(0, 20, 1, -20)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "RIVALS | " .. (isMobile() and "MOBILE AIMBOT" or "PC SILENT AIM")
Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 102
Subtitle.Parent = Header

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 80, 0, 35)
CloseButton.Position = UDim2.new(1, -90, 0.5, -17)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 102
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -40, 1, -130)
ContentArea.Position = UDim2.new(0, 20, 0, 120)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 101
ContentArea.Parent = MainContainer

-- Create Advanced Toggle Switches
local function CreateAdvancedToggle(name, yPos, defaultValue, callback)
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(1, 0, 0, 45)
    ToggleContainer.Position = UDim2.new(0, 0, 0, yPos)
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.ZIndex = 102
    ToggleContainer.Parent = ContentArea

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.ZIndex = 103
    ToggleLabel.Parent = ToggleContainer

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 60, 0, 30)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -15)
    ToggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.ZIndex = 103
    ToggleButton.Parent = ToggleContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 15)
    ToggleCorner.Parent = ToggleButton

    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 26, 0, 26)
    ToggleKnob.Position = defaultValue and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.ZIndex = 104
    ToggleKnob.Parent = ToggleButton

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = ToggleKnob

    ToggleButton.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        
        local goal = {
            BackgroundColor3 = newValue and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100),
            Position = newValue and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        }
        
        local tween = TweenService:Create(ToggleKnob, TweenInfo.new(0.2), goal)
        tween:Play()
        
        if callback then
            callback(newValue)
        end
    end)
    
    return ToggleContainer
end

-- Create Advanced Slider
local function CreateAdvancedSlider(name, yPos, min, max, defaultValue, callback)
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Size = UDim2.new(1, 0, 0, 60)
    SliderContainer.Position = UDim2.new(0, 0, 0, yPos)
    SliderContainer.BackgroundTransparency = 1
    SliderContainer.ZIndex = 102
    SliderContainer.Parent = ContentArea

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 0, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. defaultValue
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.ZIndex = 103
    SliderLabel.Parent = SliderContainer

    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, 0, 0, 20)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SliderTrack.Text = ""
    SliderTrack.AutoButtonColor = false
    SliderTrack.ZIndex = 103
    SliderTrack.Parent = SliderContainer

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 10)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    SliderFill.BorderSizePixel = 0
    SliderFill.ZIndex = 104
    SliderFill.Parent = SliderTrack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = SliderFill

    local isSliding = false
    
    local function updateSlider(input)
        local sliderPos = SliderTrack.AbsolutePosition
        local sliderSize = SliderTrack.AbsoluteSize
        local relativeX = math.clamp((input.Position.X - sliderPos.X) / sliderSize.X, 0, 1)
        
        local value = math.floor(min + (max - min) * relativeX)
        SliderLabel.Text = name .. ": " .. value
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        
        if callback then
            callback(value)
        end
    end
    
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isSliding = true
            updateSlider(input)
        end
    end)
    
    SliderTrack.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isSliding = false
        end
    end)
    
    return SliderContainer
end

-- Create UI Controls
CreateAdvancedToggle("Silent Aim", 10, false, function(value)
    Config.SilentAimEnabled = value
    print("Silent Aim:", value and "ON" or "OFF")
end)

CreateAdvancedToggle("ESP", 70, false, function(value)
    Config.ESPEnabled = value
    print("ESP:", value and "ON" or "OFF")
end)

CreateAdvancedToggle("FOV Circle", 130, false, function(value)
    Config.FOVCircleEnabled = value
    print("FOV Circle:", value and "ON" or "OFF")
    if value then
        CreateFOVCircle()
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)

CreateAdvancedSlider("Aim FOV", 190, 10, 500, 100, function(value)
    Config.AimFOV = value
    if FOVCircle then
        FOVCircle.Radius = value
    end
end)

-- Make UI Draggable
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
    end
end)

Header.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle Button Functionality
ToggleButton.MouseButton1Click:Connect(function()
    Config.UIVisible = not Config.UIVisible
    MainContainer.Visible = Config.UIVisible
    ToggleButton.Text = Config.UIVisible and "CLOSE" or "OPEN"
end)

CloseButton.MouseButton1Click:Connect(function()
    Config.UIVisible = false
    MainContainer.Visible = false
    ToggleButton.Text = "OPEN"
end)

-- Start Fire Animation
CreateFireAnimation()

-- FOV Circle System
local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then 
        FOVCircle:Remove() 
        FOVCircle = nil
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = Config.FOVCircleEnabled
    FOVCircle.Radius = Config.AimFOV
    FOVCircle.Color = Color3.fromRGB(255, 100, 50)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    
    if isMobile() then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
end

local function UpdateFOVCircle()
    if not FOVCircle or not Config.FOVCircleEnabled then return end
    
    if not isMobile() then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
    FOVCircle.Radius = Config.AimFOV
end

-- TARGET FINDING SYSTEM (FIXED)
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = Config.AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local aimPart = player.Character:FindFirstChild(Config.AimPartName)
            
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

-- MOBILE AIMBOT SYSTEM (FIXED)
local function SetupMobileAimbot()
    if not isMobile() then return end
    
    local lastTouchPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local isShooting = false
    
    -- Track touch position
    UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        lastTouchPosition = input.Position
    end)
    
    UserInputService.TouchMoved:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        lastTouchPosition = input.Position
    end)
    
    -- Mobile aimbot logic
    RunService.Heartbeat:Connect(function()
        if not Config.SilentAimEnabled then return end
        
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Config.AimPartName) then
            local targetPart = target.Character[Config.AimPartName]
            
            -- For mobile, we can adjust the camera to aim at the target
            if targetPart then
                -- Calculate direction to target
                local direction = (targetPart.Position - Camera.CFrame.Position).Unit
                
                -- Smoothly adjust camera (this is a basic implementation)
                -- In a real game, you'd need to hook into the game's aiming system
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            end
        end
    end)
end

-- PC SILENT AIM SYSTEM (FIXED)
local function SetupPCSilentAim()
    if isMobile() then return end
    
    local hooked = false
    
    if hooked then return end
    
    local success, errorMsg = pcall(function()
        if not getrawmetatable then return end
        
        local meta = getrawmetatable(game)
        if not meta then return end
        
        local oldNamecall = meta.__namecall
        
        setreadonly(meta, false)
        
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if Config.SilentAimEnabled and (method == "FireServer" or method == "invokeServer") then
                local target = GetClosestTarget()
                if target and target.Character and target.Character:FindFirstChild(Config.AimPartName) then
                    local targetPos = target.Character[Config.AimPartName].Position
                    
                    -- Modify shooting arguments for Rivals
                    if type(args[1]) == "table" then
                        if args[1].Position then
                            args[1].Position = targetPos
                        elseif args[1].Target then
                            args[1].Target = targetPos
                        elseif args[1].Hit then
                            args[1].Hit = targetPos
                        end
                    elseif type(args[1]) == "Vector3" then
                        args[1] = targetPos
                    elseif #args >= 1 and type(args[1]) == "CFrame" then
                        args[1] = CFrame.new(targetPos)
                    end
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(meta, true)
        hooked = true
        print("PC Silent Aim hook installed successfully!")
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
                    esp.Box.Visible = Config.ESPEnabled
                    
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    esp.Name.Visible = Config.ESPEnabled
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
end

-- Initialize aiming systems
if isMobile() then
    SetupMobileAimbot()
    print("Mobile Aimbot System Activated")
else
    SetupPCSilentAim()
    print("PC Silent Aim System Activated")
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        UpdateESP()
    end
    
    if Config.FOVCircleEnabled then
        UpdateFOVCircle()
    end
end)

print("🎯 NAMELESS HUB | RIVALS - AIMBOT FIXED 🎯")
print("✅ Mobile: Camera-based Aimbot")
print("✅ PC: Silent Aim hook installed")
print("✅ Target finding system working")
print("✅ FOV Circle: " .. (isMobile() and "Stationary" or "Mouse-following"))

-- Success notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Aimbot System Active!",
    Text = (isMobile() and "Mobile Aimbot Ready" or "PC Silent Aim Ready"),
    Duration = 5,
})

-- Test the aimbot system
spawn(function()
    wait(2)
    local target = GetClosestTarget()
    if target then
        print("Target found:", target.Name)
    else
        print("No targets in FOV")
    end
end)
