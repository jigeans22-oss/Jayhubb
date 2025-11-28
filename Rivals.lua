-- Nameless Hub | Rivals
-- Working Orion UI Version

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

-- Try to load Orion UI with multiple sources
local OrionLib = nil
local success, errorMsg = pcall(function()
    -- Try multiple Orion sources
    local sources = {
        'https://raw.githubusercontent.com/shlexware/Orion/main/source.lua',
        'https://pastebin.com/raw/UwFCVrhS',
        'https://raw.githubusercontent.com/richie0866/orion/main/source'
    }
    
    for _, source in pairs(sources) do
        local lib = loadstring(game:HttpGet(source))()
        if lib then
            OrionLib = lib
            break
        end
    end
end)

-- If Orion fails, create a simple UI instead
if not OrionLib then
    warn("Orion UI failed to load, creating simple UI...")
    
    -- Simple UI as fallback
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NamelessHubSimple"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NAMELESS HUB | RIVALS"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Header
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 7)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Content
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
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
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Simple UI functions
    function CreateToggle(name, yPos, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(1, 0, 0, 35)
        toggle.Position = UDim2.new(0, 0, 0, yPos)
        toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        toggle.Text = name .. ": OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggle.TextSize = 14
        toggle.Font = Enum.Font.Gotham
        toggle.Parent = ContentFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = toggle
        
        toggle.MouseButton1Click:Connect(function()
            local currentText = toggle.Text
            local isOn = currentText:find("ON")
            toggle.Text = name .. ": " .. (isOn and "OFF" or "ON")
            toggle.TextColor3 = isOn and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
            if callback then
                callback(not isOn)
            end
        end)
        
        return toggle
    end
    
    -- Store UI reference
    SimpleUI = {
        ScreenGui = ScreenGui,
        CreateToggle = CreateToggle
    }
end

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

-- Create UI Elements based on what loaded
if OrionLib then
    -- Orion UI Version
    local Window = OrionLib:MakeWindow({
        Name = "Nameless Hub | Rivals",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "NamelessHubRivals",
        IntroEnabled = true,
        IntroText = "Nameless Hub"
    })

    local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
    local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"})

    CombatTab:AddToggle({
        Name = "Silent Aim",
        Default = false,
        Callback = function(Value)
            SilentAimEnabled = Value
            if Value then setupSilentAim() end
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
            if FOVCircle then FOVCircle.Radius = Value end
        end    
    })

    CombatTab:AddDropdown({
        Name = "Aim Part",
        Default = "Head",
        Options = {"Head", "HumanoidRootPart", "UpperTorso"},
        Callback = function(Value)
            AimPartName = Value
        end    
    })

    VisualsTab:AddToggle({
        Name = "ESP",
        Default = false,
        Callback = function(Value)
            ESPEnabled = Value
            if not Value then
                for _, esp in pairs(espObjects) do
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                end
            end
        end    
    })

    OrionLib:Init()
    print("Orion UI Loaded Successfully!")
else
    -- Simple UI Version
    SimpleUI.CreateToggle("Silent Aim", 10, function(value)
        SilentAimEnabled = value
        if value then setupSilentAim() end
    end)
    
    SimpleUI.CreateToggle("ESP", 55, function(value)
        ESPEnabled = value
        if not value then
            for _, esp in pairs(espObjects) do
                esp.Box.Visible = false
                esp.Name.Visible = false
            end
        end
    end)
    
    SimpleUI.CreateToggle("FOV Circle", 100, function(value)
        FOVCircleEnabled = value
        if value then
            CreateFOVCircle()
        elseif FOVCircle then
            FOVCircle.Visible = false
        end
    end)
    
    print("Simple UI Loaded Successfully!")
end

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
        if OrionLib then
            OrionLib:ToggleUI()
        elseif SimpleUI and SimpleUI.ScreenGui then
            SimpleUI.ScreenGui.Enabled = not SimpleUI.ScreenGui.Enabled
        end
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

print("Nameless Hub | Rivals - Loaded Successfully!")
print("Platform: " .. (isMobile() and "Mobile" or "PC"))
print("UI Type: " .. (OrionLib and "Orion" or "Simple"))
