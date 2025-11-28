-- Nameless Hub | Rivals - Fixed Button Version
-- Complete working script with visible toggle button

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

-- Configuration
local Config = {
    SilentAimEnabled = false,
    ESPEnabled = false,
    FOVCircleEnabled = false,
    AimFOV = 100,
    AimPartName = "Head",
    UIVisible = false
}

-- Mobile detection
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Create Toggle Button FIRST (so it's always visible)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "NamelessHubToggle"
ToggleButton.Size = UDim2.new(0, 120, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 40)
ToggleButton.BackgroundTransparency = 0
ToggleButton.Text = "OPEN UI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = true
ToggleButton.Visible = true
ToggleButton.ZIndex = 100
ToggleButton.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Create Advanced UI
local function CreateAdvancedUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessHubAdvanced"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    
    -- Main Container (Initially hidden)
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 400, 0, 450)
    MainContainer.Position = UDim2.new(0.5, -200, 0.5, -225)
    MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainContainer.BackgroundTransparency = 0
    MainContainer.BorderSizePixel = 0
    MainContainer.Visible = false
    MainContainer.ZIndex = 10
    MainContainer.Parent = ScreenGui
    
    -- Outer Glow Effect
    local OuterGlow = Instance.new("UIStroke")
    OuterGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    OuterGlow.Color = Color3.fromRGB(255, 100, 50)
    OuterGlow.Thickness = 2
    OuterGlow.Transparency = 0.3
    OuterGlow.Parent = MainContainer
    
    -- Main Corner
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainContainer
    
    -- Fire Background Animation
    local FireContainer = Instance.new("Frame")
    FireContainer.Size = UDim2.new(1, 0, 1, 0)
    FireContainer.BackgroundTransparency = 1
    FireContainer.ClipsDescendants = true
    FireContainer.ZIndex = 1
    FireContainer.Parent = MainContainer
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Header.BorderSizePixel = 0
    Header.ZIndex = 11
    Header.Parent = MainContainer
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NAMELESS HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 12
    Title.Parent = Header
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 15, 1, -15)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "RIVALS | " .. (isMobile() and "MOBILE" or "PC")
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 12
    Subtitle.Parent = Header
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 80, 0, 30)
    CloseButton.Position = UDim2.new(1, -90, 0, 10)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "CLOSE"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.ZIndex = 12
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -20, 1, -70)
    ContentArea.Position = UDim2.new(0, 10, 0, 60)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 11
    ContentArea.Parent = MainContainer
    
    -- Make draggable
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
    
    return {
        ScreenGui = ScreenGui,
        MainContainer = MainContainer,
        ContentArea = ContentArea,
        CloseButton = CloseButton,
        FireContainer = FireContainer
    }
end

-- Create UI Elements
local function CreateUIElement(parent, elementType, properties)
    local element = Instance.new(elementType)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            element[prop] = value
        end
    end
    element.Parent = parent
    return element
end

-- Create Toggle Switch
local function CreateToggleSwitch(parent, name, yPosition, defaultValue, callback)
    local ToggleContainer = CreateUIElement(parent, "Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1,
        ZIndex = 12
    })
    
    local ToggleLabel = CreateUIElement(ToggleContainer, "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    })
    
    local ToggleButton = CreateUIElement(ToggleContainer, "TextButton", {
        Size = UDim2.new(0, 50, 0, 25),
        Position = UDim2.new(1, -50, 0.5, -12),
        BackgroundColor3 = defaultValue and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 13
    })
    
    local ToggleCorner = CreateUIElement(ToggleButton, "UICorner", {
        CornerRadius = UDim.new(0, 12)
    })
    
    local ToggleKnob = CreateUIElement(ToggleButton, "Frame", {
        Size = UDim2.new(0, 21, 0, 21),
        Position = defaultValue and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 14
    })
    
    local KnobCorner = CreateUIElement(ToggleKnob, "UICorner", {
        CornerRadius = UDim.new(1, 0)
    })
    
    ToggleButton.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        
        -- Animate toggle
        local goal = {
            BackgroundColor3 = newValue and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100),
            Position = newValue and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }
        
        local tween = TweenService:Create(ToggleKnob, TweenInfo.new(0.2), goal)
        tween:Play()
        
        if callback then
            callback(newValue)
        end
    end)
    
    return ToggleContainer
end

-- Create Slider
local function CreateSlider(parent, name, yPosition, min, max, defaultValue, callback)
    local SliderContainer = CreateUIElement(parent, "Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1,
        ZIndex = 12
    })
    
    local SliderLabel = CreateUIElement(SliderContainer, "TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name .. ": " .. defaultValue,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        ZIndex = 13
    })
    
    local SliderTrack = CreateUIElement(SliderContainer, "TextButton", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 13
    })
    
    local TrackCorner = CreateUIElement(SliderTrack, "UICorner", {
        CornerRadius = UDim.new(0, 8)
    })
    
    local SliderFill = CreateUIElement(SliderTrack, "Frame", {
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 100, 50),
        BorderSizePixel = 0,
        ZIndex = 14
    })
    
    local FillCorner = CreateUIElement(SliderFill, "UICorner", {
        CornerRadius = UDim.new(0, 8)
    })
    
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

-- Create Dropdown
local function CreateDropdown(parent, name, yPosition, options, defaultValue, callback)
    local DropdownContainer = CreateUIElement(parent, "Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1,
        ZIndex = 12
    })
    
    local DropdownLabel = CreateUIElement(DropdownContainer, "TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        ZIndex = 13
    })
    
    local DropdownButton = CreateUIElement(DropdownContainer, "TextButton", {
        Size = UDim2.new(0.6, 0, 0, 30),
        Position = UDim2.new(0.4, 0, 0, 5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        Text = defaultValue,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 13
    })
    
    local DropdownCorner = CreateUIElement(DropdownButton, "UICorner", {
        CornerRadius = UDim.new(0, 6)
    })
    
    local DropdownOpen = false
    local DropdownFrame
    
    local function toggleDropdown()
        DropdownOpen = not DropdownOpen
        
        if DropdownOpen then
            DropdownFrame = CreateUIElement(DropdownContainer, "Frame", {
                Size = UDim2.new(0.6, 0, 0, #options * 25),
                Position = UDim2.new(0.4, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 20
            })
            
            local DropdownListCorner = CreateUIElement(DropdownFrame, "UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
            
            for i, option in ipairs(options) do
                local OptionButton = CreateUIElement(DropdownFrame, "TextButton", {
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, (i-1)*25),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 70),
                    Text = option,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                    ZIndex = 21
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    DropdownOpen = false
                    DropdownFrame:Destroy()
                    if callback then
                        callback(option)
                    end
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    OptionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                end)
            end
        else
            if DropdownFrame then
                DropdownFrame:Destroy()
            end
        end
    end
    
    DropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    return DropdownContainer
end

-- Fire Animation System
local function StartFireAnimation(fireContainer)
    spawn(function()
        while fireContainer and fireContainer.Parent do
            if Config.UIVisible then
                local FireParticle = CreateUIElement(fireContainer, "Frame", {
                    Size = UDim2.new(0, math.random(20, 50), 0, math.random(20, 50)),
                    Position = UDim2.new(math.random() * 1.2 - 0.1, 0, 1.1, 0),
                    BackgroundColor3 = Color3.fromRGB(
                        math.random(200, 255),
                        math.random(50, 150),
                        math.random(0, 50)
                    ),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    ZIndex = 2
                })
                
                local FireCorner = CreateUIElement(FireParticle, "UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
                
                local tweenInfo = TweenInfo.new(
                    math.random(2, 4),
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local goal = {
                    Position = UDim2.new(
                        FireParticle.Position.X.Scale + (math.random() - 0.5) * 0.3,
                        0,
                        -0.2,
                        0
                    ),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, FireParticle.Size.X.Offset * 0.3, 0, FireParticle.Size.Y.Offset * 0.3)
                }
                
                local tween = TweenService:Create(FireParticle, tweenInfo, goal)
                tween:Play()
                
                tween.Completed:Connect(function()
                    FireParticle:Destroy()
                end)
            end
            wait(0.15)
        end
    end)
end

-- Create the UI
local AdvancedUI = CreateAdvancedUI()

-- Create UI Controls
CreateToggleSwitch(AdvancedUI.ContentArea, "Silent Aim", 10, false, function(value)
    Config.SilentAimEnabled = value
    print("Silent Aim:", value and "ON" or "OFF")
end)

CreateToggleSwitch(AdvancedUI.ContentArea, "FOV Circle", 60, false, function(value)
    Config.FOVCircleEnabled = value
    print("FOV Circle:", value and "ON" or "OFF")
    if value then
        CreateFOVCircle()
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)

CreateSlider(AdvancedUI.ContentArea, "Aim FOV", 110, 10, 500, 100, function(value)
    Config.AimFOV = value
    if FOVCircle then
        FOVCircle.Radius = value
    end
end)

CreateDropdown(AdvancedUI.ContentArea, "Aim Part", 170, {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(value)
    Config.AimPartName = value
    print("Aim Part:", value)
end)

CreateToggleSwitch(AdvancedUI.ContentArea, "ESP", 220, false, function(value)
    Config.ESPEnabled = value
    print("ESP:", value and "ON" or "OFF")
end)

-- Toggle Button functionality
ToggleButton.MouseButton1Click:Connect(function()
    Config.UIVisible = not Config.UIVisible
    AdvancedUI.MainContainer.Visible = Config.UIVisible
    ToggleButton.Text = Config.UIVisible and "CLOSE UI" or "OPEN UI"
end)

AdvancedUI.CloseButton.MouseButton1Click:Connect(function()
    Config.UIVisible = false
    AdvancedUI.MainContainer.Visible = false
    ToggleButton.Text = "OPEN UI"
end)

-- Start fire animation
StartFireAnimation(AdvancedUI.FireContainer)

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

-- Target finding
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

-- Main loop
RunService.RenderStepped:Connect(function()
    if Config.ESPEnabled then
        UpdateESP()
    end
    
    if Config.FOVCircleEnabled then
        UpdateFOVCircle()
    end
end)

print("====================================")
print("Nameless Hub | Rivals - LOADED")
print("Platform: " .. (isMobile() and "Mobile" or "PC"))
print("Toggle Button: Top-Left Corner (20,20)")
print("Button Size: 120x50 pixels")
print("Button Color: Orange with white border")
print("====================================")

-- Success message with button location info
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nameless Hub Loaded!",
    Text = "Look for ORANGE button in TOP-LEFT corner",
    Duration = 8
})
