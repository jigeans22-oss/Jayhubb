--[[
    Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
    https://github.com/Exunys
    Fixed for Delta, Xeno, Solara compatibility
]]

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--// Variables
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--// Safe Drawing Library Check
local DrawingLibrary
local DrawingSupported = pcall(function()
    DrawingLibrary = Drawing
    local test = DrawingLibrary.new("Circle")
    test.Visible = false
    test:Remove()
end)

--// Environment
getgenv().ExunysDeveloperAimbot = {
    Settings = {
        Enabled = true,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        OffsetToMoveDirection = false,
        OffsetIncrement = 15,
        Sensitivity = 0,
        Sensitivity2 = 3.5,
        LockMode = 1,
        LockPart = "Head",
        TriggerKey = Enum.UserInputType.MouseButton2,
        Toggle = false,
        MobileTrigger = "Touch",
        MobileButtonSize = 80,
        MobileButtonPosition = Vector2.new(50, 50),
        MobileButtonTransparency = 0.5
    },

    FOVSettings = {
        Enabled = true,
        Visible = true,
        Radius = 90,
        NumSides = 60,
        Thickness = 1,
        Transparency = 1,
        Filled = false,
        RainbowColor = false,
        RainbowOutlineColor = false,
        Color = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        LockedColor = Color3.fromRGB(255, 150, 150)
    },

    Blacklisted = {},
    ServiceConnections = {},
    IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
    Typing = false,
    Running = false,
    Locked = nil,
    RequiredDistance = 2000
}

local Environment = getgenv().ExunysDeveloperAimbot

--// Create FOV Circles if supported
if DrawingSupported then
    Environment.FOVCircleOutline = DrawingLibrary.new("Circle")
    Environment.FOVCircle = DrawingLibrary.new("Circle")
    Environment.FOVCircleOutline.Visible = false
    Environment.FOVCircle.Visible = false
else
    warn("Drawing library not supported - FOV circle disabled")
    Environment.FOVSettings.Enabled = false
end

--// Core Functions
local function FixUsername(String)
    local Result
    for _, Player in ipairs(Players:GetPlayers()) do
        local Name = Player.Name
        if string.sub(string.lower(Name), 1, #String) == string.lower(String) then
            Result = Name
            break
        end
    end
    return Result
end

local function GetRainbowColor()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

local function ConvertVector(Vector)
    return Vector2.new(Vector.X, Vector.Y)
end

local function CancelLock()
    Environment.Locked = nil
    if DrawingSupported then
        Environment.FOVCircle.Color = Environment.FOVSettings.Color
    end
end

local function GetClosestPlayer()
    local Settings = Environment.Settings
    local LockPart = Settings.LockPart

    if not Environment.Locked then
        Environment.RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

        for _, Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then continue end
            if table.find(Environment.Blacklisted, Player.Name) then continue end

            local Character = Player.Character
            if not Character then continue end

            local TargetPart = Character:FindFirstChild(LockPart)
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            
            if not TargetPart or not Humanoid then continue end

            -- Team Check
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then
                continue
            end

            -- Alive Check
            if Settings.AliveCheck and Humanoid.Health <= 0 then
                continue
            end

            -- Wall Check
            if Settings.WallCheck then
                local BlacklistTable = {}
                local LocalCharacter = LocalPlayer.Character
                if LocalCharacter then
                    for _, Descendant in ipairs(LocalCharacter:GetDescendants()) do
                        table.insert(BlacklistTable, Descendant)
                    end
                end
                for _, Descendant in ipairs(Character:GetDescendants()) do
                    table.insert(BlacklistTable, Descendant)
                end

                local ObscuringParts = Camera:GetPartsObscuringTarget({TargetPart.Position}, BlacklistTable)
                if #ObscuringParts > 0 then
                    continue
                end
            end

            local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            local ScreenPosition = ConvertVector(Vector)
            
            local InputPosition
            if Environment.IsMobile and Environment.TouchCurrentPosition then
                InputPosition = Environment.TouchCurrentPosition
            else
                InputPosition = Vector2.new(Mouse.X, Mouse.Y)
            end
            
            local Distance = (InputPosition - ScreenPosition).Magnitude

            if Distance < Environment.RequiredDistance and OnScreen then
                Environment.RequiredDistance = Distance
                Environment.Locked = Player
            end
        end
    else
        local LockedCharacter = Environment.Locked.Character
        if LockedCharacter then
            local LockedPart = LockedCharacter:FindFirstChild(LockPart)
            if LockedPart then
                local LockedPosition = ConvertVector(Camera:WorldToViewportPoint(LockedPart.Position))
                local InputPosition = Environment.IsMobile and Environment.TouchCurrentPosition or Vector2.new(Mouse.X, Mouse.Y)
                
                if (InputPosition - LockedPosition).Magnitude > Environment.RequiredDistance then
                    CancelLock()
                end
            else
                CancelLock()
            end
        else
            CancelLock()
        end
    end
end

--// Mobile Support
local function CreateMobileUI()
    if not Environment.IsMobile then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExunysAimbotMobileUI"
    ScreenGui.DisplayOrder = 10
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local AimButton = Instance.new("TextButton")
    AimButton.Name = "AimButton"
    AimButton.Size = UDim2.new(0, Environment.Settings.MobileButtonSize, 0, Environment.Settings.MobileButtonSize)
    AimButton.Position = UDim2.new(0, Environment.Settings.MobileButtonPosition.X, 0, Environment.Settings.MobileButtonPosition.Y)
    AimButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AimButton.BackgroundTransparency = Environment.Settings.MobileButtonTransparency
    AimButton.Text = "AIM"
    AimButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    AimButton.TextScaled = true
    AimButton.BorderSizePixel = 0
    AimButton.ZIndex = 10
    AimButton.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Environment.Settings.MobileButtonSize / 4)
    Corner.Parent = AimButton
    
    Environment.MobileUI = Environment.MobileUI or {}
    Environment.MobileUI.AimButton = AimButton
    Environment.MobileUI.AimButtonFrame = ScreenGui
end

local function HandleMobileInput()
    if not Environment.IsMobile then return end
    
    local Settings = Environment.Settings
    
    -- Touch input handling
    Environment.ServiceConnections.TouchStarted = UserInputService.TouchStarted:Connect(function(Input, Processed)
        if Processed or Environment.Typing then return end
        
        if Settings.MobileTrigger == "Touch" or Settings.MobileTrigger == "Both" then
            Environment.TouchStartPosition = Input.Position
            Environment.TouchCurrentPosition = Input.Position
            Environment.IsTouching = true
            Environment.Running = true
        end
    end)
    
    Environment.ServiceConnections.TouchMoved = UserInputService.TouchMoved:Connect(function(Input, Processed)
        if Processed or not Environment.IsTouching then return end
        Environment.TouchCurrentPosition = Input.Position
    end)
    
    Environment.ServiceConnections.TouchEnded = UserInputService.TouchEnded:Connect(function(Input, Processed)
        if Processed then return end
        
        if Settings.MobileTrigger == "Touch" or Settings.MobileTrigger == "Both" then
            Environment.IsTouching = false
            Environment.TouchCurrentPosition = nil
            
            if not Settings.Toggle then
                Environment.Running = false
                CancelLock()
            end
        end
    end)
    
    -- Button input handling
    if Environment.MobileUI and Environment.MobileUI.AimButton then
        Environment.ServiceConnections.MobileButtonDown = Environment.MobileUI.AimButton.MouseButton1Down:Connect(function()
            if Settings.MobileTrigger == "Button" or Settings.MobileTrigger == "Both" then
                if Settings.Toggle then
                    Environment.Running = not Environment.Running
                    if not Environment.Running then
                        CancelLock()
                    end
                else
                    Environment.Running = true
                end
            end
        end)
        
        Environment.ServiceConnections.MobileButtonUp = Environment.MobileUI.AimButton.MouseButton1Up:Connect(function()
            if (Settings.MobileTrigger == "Button" or Settings.MobileTrigger == "Both") and not Settings.Toggle then
                Environment.Running = false
                CancelLock()
            end
        end)
    end
end

--// Simple UI (Fallback for when Rayfield fails)
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExunysAimbotSimpleUI"
    ScreenGui.DisplayOrder = 999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Title.Text = "Exunys Aimbot V3"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Title
    
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -10, 1, -50)
    Container.Position = UDim2.new(0, 5, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 4
    Container.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = Container
    
    -- Toggle for Aimbot
    local function CreateToggle(Name, CurrentValue, Callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = Container
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0, 50, 0, 25)
        ToggleButton.Position = UDim2.new(1, -55, 0, 2)
        ToggleButton.BackgroundColor3 = CurrentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        ToggleButton.Text = CurrentValue and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 12
        ToggleButton.Parent = ToggleFrame
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = ToggleButton
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        ToggleButton.MouseButton1Click:Connect(function()
            CurrentValue = not CurrentValue
            ToggleButton.BackgroundColor3 = CurrentValue and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            ToggleButton.Text = CurrentValue and "ON" or "OFF"
            Callback(CurrentValue)
        end)
        
        return ToggleFrame
    end
    
    -- Slider function
    local function CreateSlider(Name, Min, Max, CurrentValue, Callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = Container
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = Name .. ": " .. CurrentValue
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SliderFrame
        
        local Slider = Instance.new("Frame")
        Slider.Size = UDim2.new(1, 0, 0, 10)
        Slider.Position = UDim2.new(0, 0, 0, 25)
        Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Slider.Parent = SliderFrame
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 4)
        SliderCorner.Parent = Slider
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((CurrentValue - Min) / (Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        Fill.Parent = Slider
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 4)
        FillCorner.Parent = Fill
        
        local dragging = false
        
        local function UpdateSlider(input)
            local pos = UDim2.new(math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1), 0, 1, 0)
            Fill.Size = pos
            local value = math.floor(Min + (pos.X.Scale * (Max - Min)))
            Label.Text = Name .. ": " .. value
            Callback(value)
        end
        
        Slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        Slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
        
        return SliderFrame
    end
    
    -- Create UI Elements
    CreateToggle("Enable Aimbot", Environment.Settings.Enabled, function(value)
        Environment.Settings.Enabled = value
    end)
    
    CreateToggle("Show FOV", Environment.FOVSettings.Enabled, function(value)
        Environment.FOVSettings.Enabled = value
        Environment.FOVSettings.Visible = value
    end)
    
    CreateToggle("Team Check", Environment.Settings.TeamCheck, function(value)
        Environment.Settings.TeamCheck = value
    end)
    
    CreateToggle("Alive Check", Environment.Settings.AliveCheck, function(value)
        Environment.Settings.AliveCheck = value
    end)
    
    CreateToggle("Wall Check", Environment.Settings.WallCheck, function(value)
        Environment.Settings.WallCheck = value
    end)
    
    CreateSlider("FOV Radius", 1, 500, Environment.FOVSettings.Radius, function(value)
        Environment.FOVSettings.Radius = value
    end)
    
    CreateSlider("Aim Sensitivity", 0, 5, Environment.Settings.Sensitivity, function(value)
        Environment.Settings.Sensitivity = value
    end)
    
    Environment.SimpleUI = ScreenGui
end

--// Main Loop
local function Load()
    -- Create mobile UI if needed
    if Environment.IsMobile then
        CreateMobileUI()
        HandleMobileInput()
    end
    
    -- Create simple UI
    CreateSimpleUI()
    
    -- Typing detection
    Environment.ServiceConnections.TypingStarted = UserInputService.TextBoxFocused:Connect(function()
        Environment.Typing = true
    end)
    
    Environment.ServiceConnections.TypingEnded = UserInputService.TextBoxFocusReleased:Connect(function()
        Environment.Typing = false
    end)
    
    -- Input handling for desktop
    if not Environment.IsMobile then
        Environment.ServiceConnections.InputBegan = UserInputService.InputBegan:Connect(function(Input)
            if Environment.Typing then return end
            
            local TriggerKey = Environment.Settings.TriggerKey
            local Toggle = Environment.Settings.Toggle
            
            if Input.UserInputType == TriggerKey or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey) then
                if Toggle then
                    Environment.Running = not Environment.Running
                    if not Environment.Running then
                        CancelLock()
                    end
                else
                    Environment.Running = true
                end
            end
        end)
        
        Environment.ServiceConnections.InputEnded = UserInputService.InputEnded:Connect(function(Input)
            if Environment.Typing or Environment.Settings.Toggle then return end
            
            local TriggerKey = Environment.Settings.TriggerKey
            if Input.UserInputType == TriggerKey or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey) then
                Environment.Running = false
                CancelLock()
            end
        end)
    end
    
    -- Main render loop
    Environment.ServiceConnections.RenderStepped = RunService.RenderStepped:Connect(function()
        local Settings = Environment.Settings
        local FOVSettings = Environment.FOVSettings
        
        -- Update FOV Circle
        if DrawingSupported and FOVSettings.Enabled and Settings.Enabled then
            Environment.FOVCircle.Visible = FOVSettings.Visible
            Environment.FOVCircleOutline.Visible = FOVSettings.Visible
            
            Environment.FOVCircle.Radius = FOVSettings.Radius
            Environment.FOVCircleOutline.Radius = FOVSettings.Radius
            Environment.FOVCircle.NumSides = FOVSettings.NumSides
            Environment.FOVCircleOutline.NumSides = FOVSettings.NumSides
            Environment.FOVCircle.Thickness = FOVSettings.Thickness
            Environment.FOVCircleOutline.Thickness = FOVSettings.Thickness + 1
            Environment.FOVCircle.Transparency = FOVSettings.Transparency
            Environment.FOVCircleOutline.Transparency = FOVSettings.Transparency
            Environment.FOVCircle.Filled = FOVSettings.Filled
            Environment.FOVCircleOutline.Filled = FOVSettings.Filled
            
            Environment.FOVCircle.Color = Environment.Locked and FOVSettings.LockedColor or (FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
            Environment.FOVCircleOutline.Color = FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor
            
            local InputPosition = Environment.IsMobile and Environment.TouchCurrentPosition or Vector2.new(Mouse.X, Mouse.Y)
            Environment.FOVCircle.Position = InputPosition
            Environment.FOVCircleOutline.Position = InputPosition
        elseif DrawingSupported then
            Environment.FOVCircle.Visible = false
            Environment.FOVCircleOutline.Visible = false
        end
        
        -- Aimbot logic
        if Environment.Running and Settings.Enabled then
            GetClosestPlayer()
            
            if Environment.Locked then
                local Character = Environment.Locked.Character
                if Character then
                    local TargetPart = Character:FindFirstChild(Settings.LockPart)
                    if TargetPart then
                        local Offset = Settings.OffsetToMoveDirection and 
                                     (Character:FindFirstChildOfClass("Humanoid") and Character:FindFirstChildOfClass("Humanoid").MoveDirection * (math.clamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3.zero) or 
                                     Vector3.zero
                        
                        local TargetPosition = TargetPart.Position + Offset
                        
                        if Settings.LockMode == 2 then
                            -- MouseMove mode (desktop only)
                            if not Environment.IsMobile then
                                local Vector = Camera:WorldToViewportPoint(TargetPosition)
                                local ScreenPosition = Vector2.new(Vector.X, Vector.Y)
                                local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
                                
                                mousemoverel(
                                    (ScreenPosition.X - MousePosition.X) / Settings.Sensitivity2,
                                    (ScreenPosition.Y - MousePosition.Y) / Settings.Sensitivity2
                                )
                            end
                        else
                            -- CFrame mode
                            if Settings.Sensitivity > 0 then
                                local Tween = TweenService:Create(
                                    Camera,
                                    TweenInfo.new(Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                                    {CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)}
                                )
                                Tween:Play()
                            else
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    print("Exunys Aimbot V3 Loaded Successfully!")
    print("Compatible with Delta, Xeno, Solara, and other executors")
end

--// Public Methods
function Environment:Exit()
    for name, connection in pairs(self.ServiceConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    if DrawingSupported then
        self.FOVCircle:Remove()
        self.FOVCircleOutline:Remove()
    end
    
    if self.MobileUI and self.MobileUI.AimButtonFrame then
        self.MobileUI.AimButtonFrame:Destroy()
    end
    
    if self.SimpleUI then
        self.SimpleUI:Destroy()
    end
    
    getgenv().ExunysDeveloperAimbot = nil
    print("Aimbot unloaded successfully!")
end

function Environment:Restart()
    self:Exit()
    task.wait(0.1)
    Load()
end

function Environment:Blacklist(Username)
    Username = FixUsername(Username)
    if Username and not table.find(self.Blacklisted, Username) then
        table.insert(self.Blacklisted, Username)
        print("Blacklisted: " .. Username)
    end
end

function Environment:Whitelist(Username)
    Username = FixUsername(Username)
    if Username then
        local index = table.find(self.Blacklisted, Username)
        if index then
            table.remove(self.Blacklisted, index)
            print("Whitelisted: " .. Username)
        end
    end
end

function Environment.GetClosestPlayer()
    GetClosestPlayer()
    local player = Environment.Locked
    CancelLock()
    return player
end

-- Mobile methods
function Environment:SetMobileButtonPosition(Position)
    self.Settings.MobileButtonPosition = Position
    if self.IsMobile and self.MobileUI and self.MobileUI.AimButton then
        self.MobileUI.AimButton.Position = UDim2.new(0, Position.X, 0, Position.Y)
    end
end

function Environment:SetMobileButtonSize(Size)
    self.Settings.MobileButtonSize = Size
    if self.IsMobile and self.MobileUI and self.MobileUI.AimButton then
        self.MobileUI.AimButton.Size = UDim2.new(0, Size, 0, Size)
    end
end

function Environment:SetMobileButtonTransparency(Transparency)
    self.Settings.MobileButtonTransparency = Transparency
    if self.IsMobile and self.MobileUI and self.MobileUI.AimButton then
        self.MobileUI.AimButton.BackgroundTransparency = Transparency
    end
end

-- Auto-load
local success, err = pcall(Load)
if not success then
    warn("Aimbot loading error: " .. tostring(err))
else
    print("Aimbot loaded successfully!")
end

return Environment
end
