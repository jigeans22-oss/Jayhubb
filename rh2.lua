getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "RH2 No Pump Fake",
   LoadingTitle = "Anti Pump Fake",
   LoadingSubtitle = "Real Shots Only",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "NoPumpConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
_G.RealShotsOnly = true
_G.AutoRelease = true
_G.ShotPower = 100
_G.PreventPumpFake = true

-- Fix for RH2 Pump Fake Issue
local function fixPumpFake()
    spawn(function()
        while _G.PreventPumpFake do
            wait(0.1)
            pcall(function()
                -- Method 1: Hook the shoot state system
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("shoot") or obj.Name:lower():find("shot")) then
                        local oldFireServer = obj.FireServer
                        if not obj.__pumpFixed then
                            obj.__pumpFixed = true
                            obj.FireServer = function(self, ...)
                                local args = {...}
                                
                                -- Convert pump fake to real shot
                                for i, arg in pairs(args) do
                                    if type(arg) == "string" then
                                        if arg:lower():find("fake") or arg:lower():find("pump") then
                                            args[i] = "shoot" -- Change fake to real shoot
                                        end
                                    elseif type(arg) == "boolean" then
                                        args[i] = true -- Force real shot
                                    end
                                end
                                
                                -- Add shot power if missing
                                if #args == 1 and type(args[1]) == "string" then
                                    table.insert(args, _G.ShotPower) -- Add power parameter
                                    table.insert(args, true) -- Add success parameter
                                end
                                
                                return oldFireServer(self, unpack(args))
                            end
                        end
                    end
                end
                
                -- Method 2: Direct character state manipulation
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        -- Force out of any fake/animation states
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if track.Name:lower():find("fake") or track.Name:lower():find("pump") then
                                track:Stop()
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto-Release to prevent pump fakes
local function setupAutoRelease()
    spawn(function()
        while _G.AutoRelease do
            wait(0.05)
            pcall(function()
                -- Detect when player starts shooting and force release
                local character = LocalPlayer.Character
                if character then
                    -- Check for shoot animations or states
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if track.Name:lower():find("shoot") or track.Name:lower():find("shot") then
                                -- Force shot completion
                                for _, obj in pairs(game:GetDescendants()) do
                                    if obj:IsA("RemoteEvent") and obj.Name:lower():find("release") then
                                        obj:FireServer("release", _G.ShotPower, true)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Direct Ball Control (Bypass pump fake entirely)
local function directBallControl()
    spawn(function()
        while _G.RealShotsOnly do
            wait(0.1)
            pcall(function()
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball")
                local character = LocalPlayer.Character
                
                if ball and character then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    local hoop = workspace:FindFirstChild("Hoop") or workspace:FindFirstChild("Basket")
                    
                    if root and hoop then
                        -- Check if player is trying to shoot (character facing hoop, etc.)
                        local directionToHoop = (hoop.Position - root.Position).Unit
                        local characterDirection = root.CFrame.LookVector
                        
                        -- If player is facing hoop and ball is close, auto-shoot
                        if directionToHoop:Dot(characterDirection) > 0.7 and (ball.Position - root.Position).Magnitude < 10 then
                            local shotDirection = (hoop.Position - ball.Position).Unit
                            ball.Velocity = shotDirection * _G.ShotPower
                        end
                    end
                end
            end)
        end
    end)
end

-- Hook Input to Force Real Shots
local function hookInputForRealShots()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Detect shoot button press
        if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonA then
            if _G.RealShotsOnly then
                wait(0.1) -- Small delay to let game process input
                pcall(function()
                    -- Force a real shot after any input
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and obj.Name:lower():find("shoot") then
                            -- Send real shot command with full power
                            obj:FireServer("shoot", _G.ShotPower, true, LocalPlayer)
                        end
                    end
                    
                    -- Also trigger release if needed
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and obj.Name:lower():find("release") then
                            obj:FireServer("release", _G.ShotPower, true)
                        end
                    end
                end)
            end
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("No Pump Fake", nil)
local FixSection = MainTab:CreateSection("Pump Fake Fixes")

local PumpFixToggle = MainTab:CreateToggle({
    Name = "Prevent Pump Fakes",
    CurrentValue = true,
    Flag = "PreventPumpFake",
    Callback = function(Value)
        _G.PreventPumpFake = Value
        if Value then
            fixPumpFake()
            Rayfield:Notify({
                Title = "Pump Fake Protection",
                Content = "All shots will be real shots",
                Duration = 3,
            })
        end
    end,
})

local RealShotsToggle = MainTab:CreateToggle({
    Name = "Real Shots Only",
    CurrentValue = true,
    Flag = "RealShotsOnly",
    Callback = function(Value)
        _G.RealShotsOnly = Value
        if Value then
            directBallControl()
            Rayfield:Notify({
                Title = "Real Shots Only",
                Content = "No more pump fakes",
                Duration = 3,
            })
        end
    end,
})

local AutoReleaseToggle = MainTab:CreateToggle({
    Name = "Auto-Release",
    CurrentValue = true,
    Flag = "AutoRelease",
    Callback = function(Value)
        _G.AutoRelease = Value
        if Value then
            setupAutoRelease()
            Rayfield:Notify({
                Title = "Auto-Release",
                Content = "Automatic shot completion",
                Duration = 3,
            })
        end
    end,
})

local ShotPowerSlider = MainTab:CreateSlider({
    Name = "Shot Power",
    Range = {50, 150},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 100,
    Flag = "ShotPower",
    Callback = function(Value)
        _G.ShotPower = Value
    end,
})

-- Quick Fix Button
local QuickFixSection = MainTab:CreateSection("Quick Fixes")

local ForceRealShots = MainTab:CreateButton({
    Name = "Force Real Shot Now",
    Callback = function()
        pcall(function()
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") and obj.Name:lower():find("shoot") then
                    obj:FireServer("shoot", _G.ShotPower, true)
                end
            end
            Rayfield:Notify({
                Title = "Forced Real Shot",
                Content = "Sent real shot command",
                Duration = 2,
            })
        end)
    end,
})

local AntiPumpMode = MainTab:CreateButton({
    Name = "Activate Anti-Pump Mode",
    Callback = function()
        _G.PreventPumpFake = true
        _G.RealShotsOnly = true
        _G.AutoRelease = true
        PumpFixToggle:Set(true)
        RealShotsToggle:Set(true)
        AutoReleaseToggle:Set(true)
        fixPumpFake()
        directBallControl()
        setupAutoRelease()
        Rayfield:Notify({
            Title = "Anti-Pump Mode Active",
            Content = "All pump fake protections enabled",
            Duration = 3,
        })
    end,
})

-- Initialize
fixPumpFake()
directBallControl()
setupAutoRelease()
hookInputForRealShots()

Rayfield:Notify({
    Title = "No Pump Fake Loaded",
    Content = "All shots will be real shots",
    Duration = 5,
})

print("RH2 No Pump Fake system loaded!")
