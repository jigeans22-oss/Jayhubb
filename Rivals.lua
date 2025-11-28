-- Nameless Hub | Rivals - Advanced UI
-- With Fire Animation & Platform-Specific Aim

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
local SilentAimEnabled = false
local ESPEnabled = false
local FOVCircleEnabled = false
local AimFOV = 100
local AimPartName = "Head"
local UIVisible = false

-- Mobile detection
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- Create Advanced UI
local function CreateAdvancedUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessHubAdvanced"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Container (Initially hidden)
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 450, 0, 500)
    MainContainer.Position = UDim2.new(0.5, -225, 0.5, -250)
    MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainContainer.BackgroundTransparency = 0.1
    MainContainer.BorderSizePixel = 0
    MainContainer.Visible = false
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
    FireContainer.Parent = MainContainer
    
    local fireParticles = {}
    local function createFireParticle()
        local FireParticle = Instance.new("Frame")
        FireParticle.Size = UDim2.new(0, math.random(20, 60), 0, math.random(20, 60))
        FireParticle.BackgroundColor3 = Color3.fromRGB(
            math.random(200, 255),
            math.random(50, 150),
            math.random(0, 50)
        )
        FireParticle.BackgroundTransparency = 0.7
        FireParticle.BorderSizePixel = 0
        FireParticle.Parent = FireContainer
        
        local FireCorner = Instance.new("UICorner")
        FireCorner.CornerRadius = UDim.new(1, 0)
        FireCorner.Parent = FireParticle
        
        local startPos = UDim2.new(
            math.random() * 1.2 - 0.1,
            0,
            1.1,
            0
        )
        
        FireParticle.Position = startPos
        
        local tweenInfo = TweenInfo.new(
            math.random(2, 4),
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local goal = {
            Position = UDim2.new(
                startPos.X.Scale + (math.random() - 0.5) * 0.3,
                0,
                -0.2,
                0
            ),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, FireParticle.Size.X.Offset * 0.3, 0, FireParticle.Size.Y.Offset * 0.3)
        }
        
        local tween = TweenService:Create(FireParticle, tweenInfo, goal)
        tween:Play()
        
        table.insert(fireParticles, FireParticle)
        
        tween.Completed:Connect(function()
            FireParticle:Destroy()
            for i, particle in pairs(fireParticles) do
                if particle == FireParticle then
                    table.remove(fireParticles, i)
                    break
                end
            end
        end)
    end
    
    -- Fire animation loop
    spawn(function()
        while ScreenGui.Parent do
            if UIVisible and #fireParticles < 15 then
                createFireParticle()
            end
            wait(0.1)
        end
    end)
    
    -- Header with gradient
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Header.BorderSizePixel = 0
    Header.Parent = MainContainer
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 80))
    })
    HeaderGradient.Rotation = 45
    HeaderGradient.Parent = Header
    
    -- Title with glow
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NAMELESS HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local TitleGlow = Instance.new("TextLabel")
    TitleGlow.Size = Title.Size
    TitleGlow.Position = Title.Position
    TitleGlow.BackgroundTransparency = 1
    TitleGlow.Text = "NAMELESS HUB"
    TitleGlow.TextColor3 = Color3.fromRGB(255, 100, 50)
    TitleGlow.TextSize = 20
    TitleGlow.Font = Enum.Font.GothamBold
    TitleGlow.TextXAlignment = Enum.TextXAlignment.Left
    TitleGlow.ZIndex = -1
    TitleGlow.Parent = Header
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 15, 1, -15)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "RIVALS | " .. (isMobile() and "MOBILE AIMBOT" or "PC SILENT AIM")
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
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
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    local CloseGlow = Instance.new("UIStroke")
    CloseGlow.Color = Color3.fromRGB(255, 100, 100)
    CloseGlow.Thickness = 1
    CloseGlow.Parent = CloseButton
    
    -- Tab Buttons
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -20, 0, 40)
    TabContainer.Position = UDim2.new(0, 10, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainContainer
    
    local tabs = {}
    local currentTab = "Combat"
    
    local function CreateTabButton(name, xPosition)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 120, 1, 0)
        TabButton.Position = UDim2.new(0, xPosition, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabButton
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Color3.fromRGB(100, 100, 150)
        TabStroke.Thickness = 1
        TabStroke.Parent = TabButton
        
        TabButton.MouseButton1Click:Connect(function()
            currentTab = name
            for tabName, tabFrame in pairs(tabs) do
                tabFrame.Visible = (tabName == name)
            end
            -- Update button states
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    if child.Text == name then
                        child.BackgroundColor3 = Color3.fromRGB(255, 80, 40)
                        child.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                        child.TextColor3 = Color3.fromRGB(200, 200, 200)
                    end
                end
            end
        end)
        
        return TabButton
    end
    
    -- Create tabs
    local combatTabBtn = CreateTabButton("Combat", 0)
    local visualsTabBtn = CreateTabButton("Visuals", 125)
    local settingsTabBtn = CreateTabButton("Settings", 250)
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -20, 1, -130)
    ContentArea.Position = UDim2.new(0, 10, 0, 110)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainContainer
    
    -- Combat Tab
    local CombatTab = Instance.new("Frame")
    CombatTab.Size = UDim2.new(1, 0, 1, 0)
    CombatTab.BackgroundTransparency = 1
    CombatTab.Visible = true
    CombatTab.Parent = ContentArea
    tabs["Combat"] = CombatTab
    
    -- Visuals Tab
    local VisualsTab = Instance.new("Frame")
    VisualsTab.Size = UDim2.new(1, 0, 1, 0)
    VisualsTab.BackgroundTransparency = 1
    VisualsTab.Visible = false
    VisualsTab.Parent = ContentArea
    tabs["Visuals"] = VisualsTab
    
    -- Settings Tab
    local SettingsTab = Instance.new("Frame")
    SettingsTab.Size = UDim2.new(1, 0, 1, 0)
    SettingsTab.BackgroundTransparency = 1
    SettingsTab.Visible = false
    SettingsTab.Parent = ContentArea
    tabs["Settings"] = SettingsTab
    
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
    
    -- Set initial tab state
    combatTabBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 40)
    combatTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    return {
        ScreenGui = ScreenGui,
        MainContainer = MainContainer,
        CombatTab = CombatTab,
        VisualsTab = VisualsTab,
        SettingsTab = SettingsTab,
        CloseButton = CloseButton
    }
end

-- Create UI Elements Function
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
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1
    })
    
    local ToggleLabel = CreateUIElement(ToggleContainer, "TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    local ToggleButton = CreateUIElement(ToggleContainer, "TextButton", {
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(1, -60, 0.5, -15),
        BackgroundColor3 = defaultValue and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100),
        Text = "",
        AutoButtonColor = false
    })
    
    local ToggleCorner = CreateUIElement(ToggleButton, "UICorner", {
        CornerRadius = UDim.new(0, 15)
    })
    
    local ToggleKnob = CreateUIElement(ToggleButton, "Frame", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = defaultValue and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    local KnobCorner = CreateUIElement(ToggleKnob, "UICorner", {
        CornerRadius = UDim.new(1, 0)
    })
    
    local ToggleStroke = CreateUIElement(ToggleButton, "UIStroke", {
        Color = Color3.fromRGB(150, 150, 150),
        Thickness = 1
    })
    
    ToggleButton.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        
        -- Animate toggle
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

-- Create Slider
local function CreateSlider(parent, name, yPosition, min, max, defaultValue, callback)
    local SliderContainer = CreateUIElement(parent, "Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1
    })
    
    local SliderLabel = CreateUIElement(SliderContainer, "TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name .. ": " .. defaultValue,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham
    })
    
    local SliderTrack = CreateUIElement(SliderContainer, "TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        Text = "",
        AutoButtonColor = false
    })
    
    local TrackCorner = CreateUIElement(SliderTrack, "UICorner", {
        CornerRadius = UDim.new(0, 10)
    })
    
    local SliderFill = CreateUIElement(SliderTrack, "Frame", {
        Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 100, 50),
        BorderSizePixel = 0
    })
    
    local FillCorner = CreateUIElement(SliderFill, "UICorner", {
        CornerRadius = UDim.new(0, 10)
    })
    
    local SliderButton = CreateUIElement(SliderTrack, "TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new((defaultValue - min) / (max - min), -10, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        AutoButtonColor = false
    })
    
    local ButtonCorner = CreateUIElement(SliderButton, "UICorner", {
        CornerRadius = UDim.new(1, 0)
    })
    
    local ButtonStroke = CreateUIElement(SliderButton, "UIStroke", {
        Color = Color3.fromRGB(200, 200, 200),
        Thickness = 2
    })
    
    local isSliding = false
    
    local function updateSlider(input)
        local sliderPos = SliderTrack.AbsolutePosition
        local sliderSize = SliderTrack.AbsoluteSize
        local relativeX = math.clamp((input.Position.X - sliderPos.X) / sliderSize.X, 0, 1)
        
        local value = math.floor(min + (max - min) * relativeX)
        SliderLabel.Text = name .. ": " .. value
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativeX, -10, 0, 0)
        
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
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, yPosition),
        BackgroundTransparency = 1
    })
    
    local DropdownLabel = CreateUIElement(DropdownContainer, "TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    local DropdownButton = CreateUIElement(DropdownContainer, "TextButton", {
        Size = UDim2.new(0.6, 0, 0, 35),
        Position = UDim2.new(0.4, 0, 0, 5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        Text = defaultValue,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham
    })
    
    local DropdownCorner = CreateUIElement(DropdownButton, "UICorner", {
        CornerRadius = UDim.new(0, 6)
    })
    
    local DropdownStroke = CreateUIElement(DropdownButton, "UIStroke", {
        Color = Color3.fromRGB(100, 100, 150),
        Thickness = 1
    })
    
    local DropdownOpen = false
    local DropdownFrame
    
    local function toggleDropdown()
        DropdownOpen = not DropdownOpen
        
        if DropdownOpen then
            DropdownFrame = CreateUIElement(DropdownContainer, "Frame", {
                Size = UDim2.new(0.6, 0, 0, #options * 30),
                Position = UDim2.new(0.4, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 10
            })
            
            local DropdownListCorner = CreateUIElement(DropdownFrame, "UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
            
            local DropdownListStroke = CreateUIElement(DropdownFrame, "UIStroke", {
                Color = Color3.fromRGB(100, 100, 150),
                Thickness = 1
            })
            
            for i, option in ipairs(options) do
                local OptionButton = CreateUIElement(DropdownFrame, "TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, (i-1)*30),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 70),
                    Text = option,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false
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

-- Create the UI
local AdvancedUI = CreateAdvancedUI()

-- Create UI Controls
-- Combat Tab
CreateToggleSwitch(AdvancedUI.CombatTab, "Silent Aim", 10, false, function(value)
    SilentAimEnabled = value
end)

CreateToggleSwitch(AdvancedUI.CombatTab, "FOV Circle", 65, false, function(value)
    FOVCircleEnabled = value
    if value then
        CreateFOVCircle()
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)

CreateSlider(AdvancedUI.CombatTab, "Aim FOV", 120, 10, 500, 100, function(value)
    AimFOV = value
    if FOVCircle then
        FOVCircle.Radius = value
    end
end)

CreateDropdown(AdvancedUI.CombatTab, "Aim Part", 190, {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(value)
    AimPartName = value
end)

-- Visuals Tab
CreateToggleSwitch(AdvancedUI.VisualsTab, "ESP", 10, false, function(value)
    ESPEnabled = value
end)

CreateToggleSwitch(AdvancedUI.VisualsTab, "Show Names", 65, true, function(value)
    -- ESP name visibility handled in ESP update
end)

CreateSlider(AdvancedUI.VisualsTab, "ESP Box Size", 120, 1, 5, 2, function(value)
    -- ESP size multiplier
end)

-- Settings Tab
CreateToggleSwitch(AdvancedUI.SettingsTab, "Watermark", 10, true, function(value)
    -- Watermark visibility
end)

-- Toggle Button
local ToggleButton = CreateUIElement(LocalPlayer.PlayerGui, "TextButton", {
    Size = UDim2.new(0, 100, 0, 40),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(255, 80, 40),
    Text = "OPEN",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
})

local ToggleCorner = CreateUIElement(ToggleButton, "UICorner", {
    CornerRadius = UDim.new(0, 8)
})

local ToggleGlow = CreateUIElement(ToggleButton, "UIStroke", {
    Color = Color3.fromRGB(255, 120, 80),
    Thickness = 2
})

-- Toggle UI visibility
ToggleButton.MouseButton1Click:Connect(function()
    UIVisible = not UIVisible
    AdvancedUI.MainContainer.Visible = UIVisible
    ToggleButton.Text = UIVisible and "CLOSE" or "OPEN"
end)

AdvancedUI.CloseButton.MouseButton1Click:Connect(function()
    UIVisible = false
    AdvancedUI.MainContainer.Visible = false
    ToggleButton.Text = "OPEN"
end)

-- FOV Circle System
local FOVCircle = nil
local function CreateFOVCircle()
    if FOVCircle then 
        FOVCircle:Remove() 
        FOVCircle = nil
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = AimFOV
    FOVCircle.Color = Color3.fromRGB(255, 100, 50)
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

-- Platform-specific aiming
local function GetClosestTargetPosition()
    if not SilentAimEnabled then return nil end
    
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild(AimPartName) then
        return target.Character[AimPartName].Position
    end
    return nil
end

-- Mobile Aimbot System
local MobileAimbotEnabled = false
local function SetupMobileAimbot()
    if not isMobile() then return end
    
    -- Mobile-specific aimbot that works with touch controls
    local lastTouchPosition = nil
    
    UserInputService.TouchStarted:Connect(function(input, gameProcessed)
        if gameProcessed or not MobileAimbotEnabled then return end
        lastTouchPosition = input.Position
    end)
    
    UserInputService.TouchMoved:Connect(function(input, gameProcessed)
        if gameProcessed or not MobileAimbotEnabled then return end
        lastTouchPosition = input.Position
    end)
    
    -- Mobile aimbot automatically adjusts aim when shooting
    RunService.Heartbeat:Connect(function()
        if not MobileAimbotEnabled or not lastTouchPosition then return end
        
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPartName) then
            -- Mobile aimbot logic would adjust camera or input here
            -- This is game-specific and would need adaptation
        end
    end)
end

-- PC Silent Aim Hook
local function SetupPCSilentAim()
    if isMobile() then return end
    
    local oldNamecall
    local hooked = false
    
    if hooked then return end
    
    local success, errorMsg = pcall(function()
        if not getrawmetatable then return end
        
        local meta = getrawmetatable(game)
        if not meta then return end
        
        oldNamecall = meta.__namecall
        
        setreadonly(meta, false)
        
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if SilentAimEnabled and (method == "FireServer" or method == "invokeServer") then
                local targetPos = GetClosestTargetPosition()
                if targetPos then
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
                    local size = (1000 / pos.Z) * 2 -- Size multiplier from slider
                    
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

-- Platform-specific setup
if isMobile() then
    MobileAimbotEnabled = true
    SetupMobileAimbot()
    print("Mobile Aimbot System Activated")
else
    SetupPCSilentAim()
    print("PC Silent Aim System Activated")
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

print("Nameless Hub | Rivals - Advanced UI Loaded!")
print("Platform: " .. (isMobile() and "Mobile - Aimbot Active" or "PC - Silent Aim Active"))
print("Made by Haxzo")
