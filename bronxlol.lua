-- Playground Basketball Script with Rayfield UI
-- Game ID: 18474291382

-- Game ID Verification
local TARGET_GAME_ID = 18474291382
local ACTUAL_GAME_ID = game.PlaceId

if ACTUAL_GAME_ID ~= TARGET_GAME_ID then
    -- Kick player if wrong game
    game:GetService("Players").LocalPlayer:Kick("❌ Game ID not found. This script only works for Playground Basketball.")
    return
end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Playground Basketball",
    LoadingTitle = "Loading Playground Basketball Script...",
    LoadingSubtitle = "by ScriptHub",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PlaygroundBasketball",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Main Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- Auto Green Section
local AutoGreenSection = MainTab:CreateSection("Auto Green")

local AutoGreenToggle = MainTab:CreateToggle({
    Name = "Auto Green",
    CurrentValue = false,
    Flag = "AutoGreen",
    Callback = function(Value)
        _G.AutoGreen = Value
    end,
})

MainTab:CreateSlider({
    Name = "Auto Green Delay",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 0.5,
    Flag = "AutoGreenDelay",
    Callback = function(Value)
        _G.AutoGreenDelay = Value
    end,
})

-- Movement Section
local MovementSection = MainTab:CreateSection("Movement")

local WalkSpeedSlider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 22,
    Flag = "WalkSpeed",
    Callback = function(Value)
        _G.WalkSpeed = Value
    end,
})

local JumpPowerSlider = MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 60,
    Flag = "JumpPower",
    Callback = function(Value)
        _G.JumpPower = Value
    end,
})

-- Dribble Glide Section
local DribbleSection = MainTab:CreateSection("Dribble Enhancement")

local DribbleGlideToggle = MainTab:CreateToggle({
    Name = "Dribble Glide",
    CurrentValue = false,
    Flag = "DribbleGlide",
    Callback = function(Value)
        _G.DribbleGlide = Value
    end,
})

MainTab:CreateSlider({
    Name = "Glide Strength",
    Range = {0.1, 3},
    Increment = 0.1,
    Suffix = "multiplier",
    CurrentValue = 1.5,
    Flag = "GlideStrength",
    Callback = function(Value)
        _G.GlideStrength = Value
    end,
})

-- Auto Guard Section
local DefenseSection = MainTab:CreateSection("Auto Defense")

local AutoGuardToggle = MainTab:CreateToggle({
    Name = "Auto Guard",
    CurrentValue = false,
    Flag = "AutoGuard",
    Callback = function(Value)
        _G.AutoGuard = Value
        if not Value and _G.GuardLoop then
            _G.GuardLoop:Disconnect()
            _G.GuardLoop = nil
        end
    end,
})

MainTab:CreateSlider({
    Name = "Guard Distance",
    Range = {5, 30},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "GuardDistance",
    Callback = function(Value)
        _G.GuardDistance = Value
    end,
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)

local HighlightSection = VisualTab:CreateSection("Player Highlights")

local HighlightEnemyToggle = VisualTab:CreateToggle({
    Name = "Highlight Ball Carrier",
    CurrentValue = false,
    Flag = "HighlightEnemy",
    Callback = function(Value)
        _G.HighlightBallCarrier = Value
    end,
})

VisualTab:CreateColorPicker({
    Name = "Highlight Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "HighlightColor",
    Callback = function(Value)
        _G.HighlightColor = Value
    end
})

-- Mobile Tab
local MobileTab = Window:CreateTab("Mobile", 4483362458)

local MobileSection = MobileTab:CreateSection("Mobile Controls")

local ShootButtonToggle = MobileTab:CreateToggle({
    Name = "Enable Shoot Button",
    CurrentValue = false,
    Flag = "ShootButton",
    Callback = function(Value)
        _G.ShowShootButton = Value
        if Value then
            CreateShootButton()
        else
            RemoveShootButton()
        end
    end,
})

MobileTab:CreateButton({
    Name = "Test Shoot Button",
    Callback = function()
        ShootBall()
    end,
})

-- Initialize global variables
_G.WalkSpeed = 22
_G.JumpPower = 60
_G.AutoGreenDelay = 0.5
_G.GlideStrength = 1.5
_G.GuardDistance = 10
_G.HighlightColor = Color3.fromRGB(255, 0, 0)

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Core functions
function FindBasketball()
    if not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChild("Basketball") or LocalPlayer.Character:FindFirstChildOfClass("Tool")
end

function IsInGreenZone()
    local basketball = FindBasketball()
    if not basketball then return false end
    
    -- Check if player is in shooting range (green zone)
    -- This logic depends on the game's mechanics
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    -- Find nearest hoop
    local hoops = Workspace:FindFirstChild("Hoops") or Workspace:GetDescendants()
    local nearestHoop = nil
    local nearestDistance = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("hoop") or obj.Name:lower():find("rim") or obj.Name:lower():find("goal") then
            if obj:IsA("BasePart") then
                local distance = (character.HumanoidRootPart.Position - obj.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestHoop = obj
                end
            end
        end
    end
    
    -- Determine if in green zone based on distance
    -- Adjust these values based on actual game mechanics
    return nearestDistance < 50 -- Example distance
end

function ShootBall()
    local basketball = FindBasketball()
    if not basketball then return end
    
    -- Simulate shooting
    if basketball:FindFirstChild("Click") then
        basketball.Click:FireServer()
    elseif basketball:FindFirstChild("RemoteEvent") then
        basketball.RemoteEvent:FireServer("Shoot")
    else
        -- Try to find shoot function
        for _, v in pairs(getconnections(basketball:GetPropertyChangedSignal("Parent"))) do
            pcall(function()
                v:Fire()
            end)
        end
    end
end

-- Auto Green System
local AutoGreenConnection
local function StartAutoGreen()
    if AutoGreenConnection then AutoGreenConnection:Disconnect() end
    
    AutoGreenConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoGreen or not LocalPlayer.Character then return end
        
        local basketball = FindBasketball()
        if not basketball then return end
        
        if IsInGreenZone() then
            ShootBall()
            task.wait(_G.AutoGreenDelay)
        end
    end)
end

-- Movement System
local MovementConnection
local function UpdateMovement()
    if MovementConnection then MovementConnection:Disconnect() end
    
    MovementConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
        
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.WalkSpeed = _G.WalkSpeed
        humanoid.JumpPower = _G.JumpPower
    end)
end

-- Dribble Glide System
local DribbleGlideConnection
local function StartDribbleGlide()
    if DribbleGlideConnection then DribbleGlideConnection:Disconnect() end
    
    DribbleGlideConnection = RunService.Heartbeat:Connect(function()
        if not _G.DribbleGlide or not LocalPlayer.Character then return end
        
        local basketball = FindBasketball()
        if not basketball then return end
        
        local character = LocalPlayer.Character
        if character:FindFirstChild("HumanoidRootPart") then
            -- Apply glide effect when moving with ball
            local humanoid = character.Humanoid
            if humanoid.MoveDirection.Magnitude > 0 then
                local velocity = character.HumanoidRootPart.Velocity
                local newVelocity = humanoid.MoveDirection * (_G.GlideStrength * 30)
                
                character.HumanoidRootPart.Velocity = Vector3.new(
                    newVelocity.X,
                    velocity.Y,
                    newVelocity.Z
                )
            end
        end
    end)
end

-- Auto Guard System
local function FindClosestEnemyWithBall()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Check if enemy has basketball
            local basketball = player.Character:FindFirstChild("Basketball") or 
                              player.Character:FindFirstChildOfClass("Tool")
            
            if basketball then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - 
                                 player.Character.HumanoidRootPart.Position).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local GuardConnection
local function StartAutoGuard()
    if GuardConnection then GuardConnection:Disconnect() end
    
    GuardConnection = RunService.Heartbeat:Connect(function()
        if not _G.AutoGuard or not LocalPlayer.Character then return end
        
        local target = FindClosestEnemyWithBall()
        if not target or not target.Character then return end
        
        local character = LocalPlayer.Character
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        
        if character:FindFirstChild("HumanoidRootPart") and targetRoot then
            -- Calculate position in front of enemy
            local direction = (targetRoot.Position - character.HumanoidRootPart.Position).Unit
            local guardPosition = targetRoot.Position - (direction * _G.GuardDistance)
            
            -- Move towards guard position
            character.Humanoid:MoveTo(guardPosition)
        end
    end)
end

-- Highlight System
local Highlights = {}
local HighlightConnection

local function CreateHighlight(player)
    if Highlights[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "BallCarrierHighlight"
    highlight.FillColor = _G.HighlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    highlight.Adornee = character
    
    Highlights[player] = highlight
    
    -- Update when character changes
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        highlight.Adornee = newChar
        highlight.Parent = newChar
    end)
end

local function RemoveHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function UpdateHighlights()
    if HighlightConnection then HighlightConnection:Disconnect() end
    
    HighlightConnection = RunService.Heartbeat:Connect(function()
        if not _G.HighlightBallCarrier then
            -- Remove all highlights
            for player, highlight in pairs(Highlights) do
                highlight:Destroy()
            end
            Highlights = {}
            return
        end
        
        -- Update highlight for player with ball
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hasBall = player.Character:FindFirstChild("Basketball") or 
                               player.Character:FindFirstChildOfClass("Tool")
                
                if hasBall then
                    CreateHighlight(player)
                    if Highlights[player] then
                        Highlights[player].FillColor = _G.HighlightColor
                        Highlights[player].Enabled = true
                    end
                else
                    RemoveHighlight(player)
                end
            else
                RemoveHighlight(player)
            end
        end
    end)
end

-- Mobile Shoot Button
local ShootButton
function CreateShootButton()
    if ShootButton then return end
    
    ShootButton = Instance.new("TextButton")
    ShootButton.Name = "MobileShootButton"
    ShootButton.Text = "🏀 SHOOT"
    ShootButton.TextScaled = true
    ShootButton.Font = Enum.Font.GothamBold
    ShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShootButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    ShootButton.BackgroundTransparency = 0.3
    ShootButton.Size = UDim2.new(0, 120, 0, 120)
    ShootButton.Position = UDim2.new(1, -130, 1, -130)
    ShootButton.AnchorPoint = Vector2.new(1, 1)
    ShootButton.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.3, 0)
    UICorner.Parent = ShootButton
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 3
    UIStroke.Parent = ShootButton
    
    -- Make button draggable
    local dragging = false
    local dragStart, startPos
    
    ShootButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ShootButton.Position
            
            -- Visual feedback
            ShootButton.BackgroundTransparency = 0.1
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    ShootButton.BackgroundTransparency = 0.3
                end
            end)
        end
    end)
    
    ShootButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            local delta = input.Position - dragStart
            ShootButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Shoot on click/tap
    ShootButton.MouseButton1Click:Connect(function()
        ShootBall()
    end)
    
    ShootButton.TouchTap:Connect(function()
        ShootBall()
    end)
end

function RemoveShootButton()
    if ShootButton then
        ShootButton:Destroy()
        ShootButton = nil
    end
end

-- Initialize all systems
UpdateMovement()
UpdateHighlights()

-- Toggle connections
AutoGreenToggle.Callback = function(Value)
    _G.AutoGreen = Value
    if Value then
        StartAutoGreen()
    elseif AutoGreenConnection then
        AutoGreenConnection:Disconnect()
        AutoGreenConnection = nil
    end
end

DribbleGlideToggle.Callback = function(Value)
    _G.DribbleGlide = Value
    if Value then
        StartDribbleGlide()
    elseif DribbleGlideConnection then
        DribbleGlideConnection:Disconnect()
        DribbleGlideConnection = nil
    end
end

AutoGuardToggle.Callback = function(Value)
    _G.AutoGuard = Value
    if Value then
        StartAutoGuard()
    elseif GuardConnection then
        GuardConnection:Disconnect()
        GuardConnection = nil
    end
end

-- Anti-AFK
local VirtualInputManager = game:GetService("VirtualInputManager")
local AFKConnection = RunService.Heartbeat:Connect(function()
    VirtualInputManager:SendKeyEvent(true, "W", false, nil)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "W", false, nil)
    task.wait(29)
end)

-- Cleanup on script termination
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    -- Reapply movement when character respawns
    UpdateMovement()
end)

-- Notification
Rayfield:Notify({
    Title = "Playground Basketball Loaded",
    Content = "Script activated successfully! Game ID verified.",
    Duration = 5,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "OK",
            Callback = function()
                print("User acknowledged notification")
            end
        },
    },
})

print("======================================")
print("PLAYGROUND BASKETBALL SCRIPT LOADED")
print("Game ID: " .. ACTUAL_GAME_ID .. " ✓")
print("Features:")
print("- Auto Green System")
print("- WalkSpeed/JumpPower Control")
print("- Dribble Glide Enhancement")
print("- Auto Guard Defense")
print("- Mobile Shoot Button")
print("- Ball Carrier Highlights")
print("======================================")
