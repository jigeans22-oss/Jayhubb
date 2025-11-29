getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Football Fusion 2",
   LoadingTitle = "FF2 Script",
   LoadingSubtitle = "Ball Mag + Auto QB",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "FF2Config"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Football Fusion 2 Settings
_G.BallMagnetism = false
_G.MagnetStrength = 50
_G.AutoQBVote = false
_G.CatchAssist = false
_G.ThrowAccuracy = false
_G.SpeedBoost = false

-- Find Football
local function findFootball()
    local ball = Workspace:FindFirstChild("Football") or Workspace:FindFirstChild("Ball")
    if not ball then
        -- Search for football in descendants
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("football") or obj.Name:lower():find("ball") then
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    return obj
                end
            end
        end
    end
    return ball
end

-- Ball Magnetism System
local function activateBallMagnetism()
    spawn(function()
        while _G.BallMagnetism do
            RunService.Heartbeat:Wait()
            pcall(function()
                local ball = findFootball()
                local character = LocalPlayer.Character
                
                if ball and character and character:FindFirstChild("HumanoidRootPart") then
                    local root = character.HumanoidRootPart
                    local ballPos = ball.Position
                    local myPos = root.Position
                    local distance = (ballPos - myPos).Magnitude
                    
                    -- Only activate magnetism within reasonable distance
                    if distance < 100 then
                        local direction = (myPos - ballPos).Unit
                        local force = direction * _G.MagnetStrength
                        
                        -- Apply magnetic force to ball
                        ball.Velocity = ball.Velocity + force
                        
                        -- Add slight upward force for better catching
                        ball.Velocity = ball.Velocity + Vector3.new(0, 5, 0)
                    end
                end
            end)
        end
    end)
end

-- Auto QB Vote System
local function setupAutoQBVote()
    spawn(function()
        while _G.AutoQBVote do
            wait(5) -- Check every 5 seconds
            
            pcall(function()
                -- Look for QB voting GUI elements
                for _, gui in pairs(game:GetService("CoreGui"):GetDescendants()) do
                    if gui:IsA("TextButton") and (gui.Text:lower():find("qb") or gui.Text:lower():find("quarterback")) then
                        if gui.Visible then
                            gui:FireEvent("MouseButton1Click")
                            print("✅ Auto-voted for QB position")
                        end
                    end
                end
                
                -- Also check player list for QB voting
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BillboardGui") then
                        for _, child in pairs(obj:GetDescendants()) do
                            if child:IsA("TextButton") and child.Text:lower():find("qb") then
                                child:FireEvent("MouseButton1Click")
                            end
                        end
                    end
                end
                
                -- Try remote events for QB voting
                for _, remote in pairs(game:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("vote") or name:find("qb") or name:find("position") then
                            remote:FireServer("QB")
                            remote:FireServer("Quarterback")
                            remote:FireServer(LocalPlayer, "QB")
                        end
                    end
                end
            end)
        end
    end)
end

-- Catch Assist
local function activateCatchAssist()
    spawn(function()
        while _G.CatchAssist do
            RunService.Heartbeat:Wait()
            pcall(function()
                local ball = findFootball()
                local character = LocalPlayer.Character
                
                if ball and character and character:FindFirstChild("HumanoidRootPart") then
                    local root = character.HumanoidRootPart
                    local distance = (ball.Position - root.Position).Magnitude
                    
                    -- Auto-position for catches
                    if distance < 30 then
                        -- Face the ball
                        root.CFrame = CFrame.new(root.Position, ball.Position)
                        
                        -- Move toward ball slightly
                        local direction = (ball.Position - root.Position).Unit
                        root.Velocity = direction * 10
                    end
                end
            end)
        end
    end)
end

-- Throw Accuracy
local function activateThrowAccuracy()
    spawn(function()
        while _G.ThrowAccuracy do
            wait(0.1)
            pcall(function()
                -- Look for throw accuracy remotes
                for _, remote in pairs(game:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        if name:find("throw") or name:find("pass") then
                            -- Hook throw events for perfect accuracy
                            local oldFire = remote.FireServer
                            if not remote.__accuracyHooked then
                                remote.__accuracyHooked = true
                                remote.FireServer = function(self, ...)
                                    local args = {...}
                                    -- Modify throw parameters for accuracy
                                    for i, arg in pairs(args) do
                                        if type(arg) == "number" and arg < 100 then
                                            args[i] = 100 -- Perfect accuracy
                                        end
                                    end
                                    return oldFire(self, unpack(args))
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Speed Boost
local function activateSpeedBoost()
    spawn(function()
        while _G.SpeedBoost do
            wait(0.5)
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = 22 -- Increased speed
                    character.Humanoid.JumpPower = 55
                end
            end)
        end
    end)
end

-- Auto Intercept
local function autoIntercept()
    spawn(function()
        while _G.BallMagnetism do
            wait(0.3)
            pcall(function()
                local ball = findFootball()
                local character = LocalPlayer.Character
                
                if ball and character and character:FindFirstChild("HumanoidRootPart") then
                    -- Check if ball is in the air (not with a player)
                    local ballVelocity = ball.Velocity.Magnitude
                    if ballVelocity > 10 then -- Ball is moving fast (probably thrown)
                        local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude
                        if distance < 50 then
                            -- Move to intercept path
                            local predictedPosition = ball.Position + ball.Velocity * 0.5
                            character.HumanoidRootPart.CFrame = CFrame.new(
                                character.HumanoidRootPart.Position,
                                predictedPosition
                            )
                        end
                    end
                end
            end)
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("Football Fusion 2", nil)

-- Ball Control Section
local BallSection = MainTab:CreateSection("Ball Control")

local MagnetToggle = MainTab:CreateToggle({
    Name = "Ball Magnetism",
    CurrentValue = false,
    Flag = "BallMagnetism",
    Callback = function(Value)
        _G.BallMagnetism = Value
        if Value then
            activateBallMagnetism()
            autoIntercept()
            Rayfield:Notify({
                Title = "Ball Magnetism Active",
                Content = "Football will gravitate toward you",
                Duration = 3,
            })
        end
    end,
})

local MagnetSlider = MainTab:CreateSlider({
    Name = "Magnet Strength",
    Range = {10, 100},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "MagnetStrength",
    Callback = function(Value)
        _G.MagnetStrength = Value
    end,
})

local CatchToggle = MainTab:CreateToggle({
    Name = "Catch Assist",
    CurrentValue = false,
    Flag = "CatchAssist",
    Callback = function(Value)
        _G.CatchAssist = Value
        if Value then
            activateCatchAssist()
            Rayfield:Notify({
                Title = "Catch Assist Active",
                Content = "Auto-positioning for catches",
                Duration = 3,
            })
        end
    end,
})

-- QB Section
local QBSection = MainTab:CreateSection("Quarterback")

local QBToggle = MainTab:CreateToggle({
    Name = "Auto QB Vote",
    CurrentValue = false,
    Flag = "AutoQBVote",
    Callback = function(Value)
        _G.AutoQBVote = Value
        if Value then
            setupAutoQBVote()
            Rayfield:Notify({
                Title = "Auto QB Vote Active",
                Content = "Automatically voting for QB position",
                Duration = 3,
            })
        end
    end,
})

local AccuracyToggle = MainTab:CreateToggle({
    Name = "Perfect Throw Accuracy",
    CurrentValue = false,
    Flag = "ThrowAccuracy",
    Callback = function(Value)
        _G.ThrowAccuracy = Value
        if Value then
            activateThrowAccuracy()
            Rayfield:Notify({
                Title = "Perfect Accuracy Active",
                Content = "100% accurate throws",
                Duration = 3,
            })
        end
    end,
})

-- Player Section
local PlayerSection = MainTab:CreateSection("Player")

local SpeedToggle = MainTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        _G.SpeedBoost = Value
        if Value then
            activateSpeedBoost()
            Rayfield:Notify({
                Title = "Speed Boost Active",
                Content = "Increased movement speed",
                Duration = 3,
            })
        end
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("Quick Actions")

local ProMode = MainTab:CreateButton({
    Name = "Activate Pro Mode",
    Callback = function()
        _G.BallMagnetism = true
        _G.AutoQBVote = true
        _G.CatchAssist = true
        _G.ThrowAccuracy = true
        _G.SpeedBoost = true
        MagnetToggle:Set(true)
        QBToggle:Set(true)
        CatchToggle:Set(true)
        AccuracyToggle:Set(true)
        SpeedToggle:Set(true)
        activateBallMagnetism()
        setupAutoQBVote()
        activateCatchAssist()
        activateThrowAccuracy()
        activateSpeedBoost()
        autoIntercept()
        Rayfield:Notify({
            Title = "Pro Mode Activated",
            Content = "All football features enabled",
            Duration = 4,
        })
    end,
})

-- Status
local StatusSection = MainTab:CreateSection("Status")
local BallStatus = MainTab:CreateLabel("Football: Searching...")

-- Update ball status
spawn(function()
    while true do
        wait(2)
        local ball = findFootball()
        if ball then
            local distance = 999
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude
            end
            BallStatus:Set("Football: " .. math.floor(distance) .. " studs away")
        else
            BallStatus:Set("Football: Not found")
        end
    end
end)

Rayfield:Notify({
    Title = "Football Fusion 2 Script Loaded",
    Content = "Ball magnetism + Auto QB voting ready",
    Duration = 5,
})

print("🏈 Football Fusion 2 Script - Ready for game!")
