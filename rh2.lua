getgenv().SecureMode = true

-- Basketball Script - Mobile Supported
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- Configuration
_G.AlwaysMakeShots = false
_G.AutoRebound = false
_G.AutoSteal = false
_G.AutoBlock = false
_G.ShowDistances = false
_G.MobileUIEnabled = false

-- Mobile UI Elements
local screenGui = nil
local mainFrame = nil
local buttons = {}

-- Universal Shot Modifier
local function enableAlwaysMakeShots()
    _G.AlwaysMakeShots = true
    print("Always Make Shots: Enabled")
end

local function disableAlwaysMakeShots()
    _G.AlwaysMakeShots = false
    print("Always Make Shots: Disabled")
end

-- Auto Rebound
local function startAutoRebound()
    _G.AutoRebound = true
    print("Auto Rebound: Enabled")
    
    spawn(function()
        while _G.AutoRebound do
            wait(0.1)
            pcall(function()
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball") or findBall()
                local char = LocalPlayer.Character
                if ball and char and char:FindFirstChild("HumanoidRootPart") then
                    local distance = (ball.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then
                        char.HumanoidRootPart.CFrame = CFrame.new(ball.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end)
end

local function stopAutoRebound()
    _G.AutoRebound = false
    print("Auto Rebound: Disabled")
end

-- Auto Steal
local function startAutoSteal()
    _G.AutoSteal = true
    print("Auto Steal: Enabled")
    
    spawn(function()
        while _G.AutoSteal do
            wait(0.5)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end)
        end
    end)
end

local function stopAutoSteal()
    _G.AutoSteal = false
    print("Auto Steal: Disabled")
end

-- Auto Block
local function startAutoBlock()
    _G.AutoBlock = true
    print("Auto Block: Enabled")
    
    spawn(function()
        while _G.AutoBlock do
            wait(0.3)
            pcall(function()
                local players = Players:GetPlayers()
                local localChar = LocalPlayer.Character
                
                for _, player in pairs(players) do
                    if player ~= LocalPlayer then
                        local char = player.Character
                        if char then
                            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
                            local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball") or findBall()
                            
                            if humanoidRootPart and ball and localChar then
                                local ballDistance = (ball.Position - humanoidRootPart.Position).Magnitude
                                local playerDistance = (humanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
                                
                                if ballDistance < 10 and playerDistance < 20 then
                                    VirtualInputManager:SendKeyEvent(true, "Q", false, game)
                                    VirtualInputManager:SendKeyEvent(false, "Q", false, game)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local function stopAutoBlock()
    _G.AutoBlock = false
    print("Auto Block: Disabled")
end

-- Distance Visualizer
local function startDistanceVisualizer()
    _G.ShowDistances = true
    print("Distance Visualizer: Enabled")
    
    spawn(function()
        while _G.ShowDistances do
            wait(0.5)
            pcall(function()
                local localChar = LocalPlayer.Character
                if localChar then
                    local rootPart = localChar:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        for _, hoop in pairs(workspace:GetDescendants()) do
                            if hoop.Name:lower():find("hoop") or hoop.Name:lower():find("basket") then
                                local distance = (rootPart.Position - hoop.Position).Magnitude
                                print("Distance to " .. hoop.Name .. ": " .. math.floor(distance) .. " studs")
                            end
                        end
                    end)
