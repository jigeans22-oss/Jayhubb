getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MyCourt Auto-Shoot Pro",
   LoadingTitle = "MyCourt Hacks",
   LoadingSubtitle = "Optimized for MyCourt",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MyCourtConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Settings
_G.AutoShoot = false
_G.AutoGreen = true
_G.ShotDelay = 0.2
_G.ExtendShotRange = false
_G.ShotRangeMultiplier = 2.0
_G.AlwaysMakeShots = true

-- MyCourt Detection
local function isInMyCourt()
    -- Check for MyCourt specific objects
    if workspace:FindFirstChild("MyCourt") then return true end
    if workspace:FindFirstChild("PracticeCourt") then return true end
    if game:GetService("Lighting"):FindFirstChild("MyCourt") then return true end
    
    -- Check player count (MyCourt usually has few players)
    local playerCount = #Players:GetPlayers()
    if playerCount <= 4 then return true end
    
    -- Check for MyCourt specific objects
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("mycourt") or obj.Name:lower():find("practice") then
            return true
        end
    end
    
    return false
end

-- Find MyCourt specific objects
local function findMyCourtObjects()
    local objects = {}
    
    -- MyCourt basketball hoops (common names)
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Hoops in MyCourt
        if obj.Name:lower():find("hoop") or 
           obj.Name:lower():find("basket") or 
           obj.Name:lower():find("rim") or
           obj.Name:lower():find("goal") or
           obj.Name:lower():find("score") then
            
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                table.insert(objects, {Object = obj, Type = "Hoop"})
            end
        end
        
        -- Basketball in MyCourt
        if obj.Name:lower():find("basketball") or 
           obj.Name:lower():find("ball") or
           obj.Name:lower():find("sphere") then
            
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                table.insert(objects, {Object = obj, Type = "Ball"})
            end
        end
        
        -- Shoot triggers in MyCourt
        if obj.Name:lower():find("shoot") or 
           obj.Name:lower():find("shot") or
           obj.Name:lower():find("fire") or
           obj.Name:lower():find("throw") then
            
            if obj:IsA("Part") or obj:IsA("TextButton") or obj:IsA("RemoteEvent") then
                table.insert(objects, {Object = obj, Type = "ShootTrigger"})
            end
        end
    end
    
    return objects
end

-- MyCourt Auto-Shoot System
local function setupMyCourtAutoShoot()
    spawn(function()
        while _G.AutoShoot do
            wait(_G.ShotDelay)
            pcall(function()
                local myCourtObjects = findMyCourtObjects()
                
                -- Method 1: Trigger shoot buttons
                for _, obj in pairs(myCourtObjects) do
                    if obj.Type == "ShootTrigger" and obj.Object:IsA("TextButton") then
                        if obj.Object.Visible then
                            obj.Object:FireEvent("MouseButton1Click")
                        end
                    end
                end
                
                -- Method 2: Fire shoot remote events
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        -- Try common MyCourt shoot event names
                        if obj.Name:lower():find("shoot") or 
                           obj.Name:lower():find("shot") or
                           obj.Name:lower():find("fire") or
                           obj.Name:lower():find("throw") or
                           obj.Name:lower():find("basket") then
                            
                            obj:FireServer("shoot")
                            obj:FireServer("shot")
                            obj:FireServer(LocalPlayer)
                        end
                    end
                end
                
                -- Method 3: Direct ball manipulation for MyCourt
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball")
                if ball then
                    local hoop = workspace:FindFirstChild("Hoop") or workspace:FindFirstChild("Basket")
                    if hoop then
                        -- Calculate shot trajectory
                        local direction = (hoop.Position - ball.Position).Unit
                        local distance = (hoop.Position - ball.Position).Magnitude
                        
                        -- Apply force to ball (MyCourt physics)
                        if _G.ExtendShotRange then
                            ball.Velocity = direction * (distance * _G.ShotRangeMultiplier)
                        else
                            ball.Velocity = direction * distance * 1.5
                        end
                    end
                end
            end)
        end
    end)
end

-- MyCourt Auto-Green System
local function setupMyCourtAutoGreen()
    spawn(function()
        while _G.AutoGreen or _G.AlwaysMakeShots do
            wait(0.1)
            pcall(function()
                -- Hook all possible MyCourt remotes
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local oldFireServer = obj.FireServer
                        if not obj.__mycourtHooked then
                            obj.__mycourtHooked = true
                            obj.FireServer = function(self, ...)
                                local args = {...}
                                
                                -- Force success for any shot-related events
                                if _G.AutoGreen or _G.AlwaysMakeShots then
                                    for i, arg in pairs(args) do
                                        if type(arg) == "boolean" then
                                            args[i] = true
                                        elseif type(arg) == "number" and arg < 100 then
                                            args[i] = 100
                                        elseif type(arg) == "string" then
                                            if arg:lower():find("miss") or arg:lower():find("fail") then
                                                args[i] = "score"
                                            end
                                        end
                                    end
                                end
                                
                                return oldFireServer(self, unpack(args))
                            end
                        end
                    end
                end
                
                -- Direct ball manipulation for guaranteed scores
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball")
                if ball then
                    local hoop = workspace:FindFirstChild("Hoop") or workspace:FindFirstChild("Basket")
                    if hoop then
                        -- Make ball go directly into hoop
                        local hoopPos = hoop.Position + Vector3.new(0, 5, 0) -- Aim for center of hoop
                        local direction = (hoopPos - ball.Position).Unit
                        local distance = (hoopPos - ball.Position).Magnitude
                        
                        if distance < 100 then -- Only when ball is in reasonable range
                            -- Apply magnetic force toward hoop
                            local force = direction * 25
                            ball.Velocity = ball.Velocity + force
                        end
                    end
                end
            end)
        end
    end)
end

-- MyCourt Range Extension
local function setupMyCourtRange()
    spawn(function()
        while _G.ExtendShotRange do
            wait(0.3)
            pcall(function()
                -- Modify character properties for MyCourt
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        -- Increase jump and movement for better shots
                        humanoid.JumpPower = 55
                        humanoid.WalkSpeed = 22
                    end
                end
                
                -- Modify ball physics for longer range
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball")
                if ball then
                    -- Reduce gravity effect
                    local bodyForce = ball:FindFirstChild("BodyForce") or Instance.new("BodyForce")
                    bodyForce.Force = Vector3.new(0, workspace.Gravity * -0.3, 0)
                    bodyForce.Parent = ball
                    
                    -- Reduce air resistance
                    ball.Material = Enum.Material.Neon
                end
            end)
        end
    end)
end

-- Detect when player tries to shoot in MyCourt
local function setupMyCourtShootDetection()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Common shoot keys in MyCourt
        if input.KeyCode == Enum.KeyCode.E or 
           input.KeyCode == Enum.KeyCode.F or 
           input.KeyCode == Enum.KeyCode.Space or
           input.KeyCode == Enum.KeyCode.ButtonA then
            
            if _G.AutoGreen then
                -- Enhance the shot automatically
                pcall(function()
                    local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChild("Ball")
                    if ball then
                        local hoop = workspace:FindFirstChild("Hoop") or workspace:FindFirstChild("Basket")
                        if hoop then
                            -- Calculate perfect shot trajectory
                            local targetPos = hoop.Position + Vector3.new(0, 3, 0)
                            local direction = (targetPos - ball.Position).Unit
                            
                            -- Apply perfect shot force
                            local shotPower = 50
                            if _G.ExtendShotRange then
                                shotPower = shotPower * _G.ShotRangeMultiplier
                            end
                            
                            ball.Velocity = direction * shotPower
                        end
                    end
                end)
            end
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("MyCourt Hacks", nil)

-- Court Status
local StatusSection = MainTab:CreateSection("Court Status")
local CourtLabel = MainTab:CreateLabel("Detecting Court Type...")

-- Auto-Shoot Section
local AutoShootSection = MainTab:CreateSection("MyCourt Auto-Shoot")

local AutoShootToggle = MainTab:CreateToggle({
    Name = "Auto-Shoot in MyCourt",
    CurrentValue = false,
    Flag = "AutoShoot",
    Callback = function(Value)
        _G.AutoShoot = Value
        if Value then
            setupMyCourtAutoShoot()
            Rayfield:Notify({
                Title = "MyCourt Auto-Shoot",
                Content = "Automatic shooting activated",
                Duration = 3,
            })
        end
    end,
})

-- Auto-Green Section
local AutoGreenSection = MainTab:CreateSection("MyCourt Auto-Green")

local AutoGreenToggle = MainTab:CreateToggle({
    Name = "Auto-Green (Always Score)",
    CurrentValue = true,
    Flag = "AutoGreen",
    Callback = function(Value)
        _G.AutoGreen = Value
        if Value then
            setupMyCourtAutoGreen()
            Rayfield:Notify({
                Title = "MyCourt Auto-Green",
                Content = "Perfect shots guaranteed",
                Duration = 3,
            })
        end
    end,
})

-- Range Section
local RangeSection = MainTab:CreateSection("MyCourt Range")

local RangeToggle = MainTab:CreateToggle({
    Name = "Extend Shot Range",
    CurrentValue = false,
    Flag = "ExtendShotRange",
    Callback = function(Value)
        _G.ExtendShotRange = Value
        if Value then
            setupMyCourtRange()
            Rayfield:Notify({
                Title = "MyCourt Range Extended",
                Content = "Longer shooting range activated",
                Duration = 3,
            })
        end
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("MyCourt Quick Actions")

local PerfectPractice = MainTab:CreateButton({
    Name = "Perfect Practice Mode",
    Callback = function()
        _G.AutoShoot = true
        _G.AutoGreen = true
        _G.ExtendShotRange = true
        AutoShootToggle:Set(true)
        AutoGreenToggle:Set(true)
        RangeToggle:Set(true)
        setupMyCourtAutoShoot()
        setupMyCourtAutoGreen()
        setupMyCourtRange()
        Rayfield:Notify({
            Title = "Perfect Practice",
            Content = "Auto-shoot + Auto-green + Max range",
            Duration = 3,
        })
    end,
})

local RefreshCourt = MainTab:CreateButton({
    Name = "Refresh Court Detection",
    Callback = function()
        if isInMyCourt() then
            CourtLabel:Set("Status: MyCourt Detected ✓")
            Rayfield:Notify({
                Title = "MyCourt Detected",
                Content = "All features optimized for MyCourt",
                Duration = 3,
            })
        else
            CourtLabel:Set("Status: Regular Game Detected")
            Rayfield:Notify({
                Title = "Regular Game",
                Content = "Using standard game features",
                Duration = 3,
            })
        end
    end,
})

-- Initialize
setupMyCourtShootDetection()
setupMyCourtAutoGreen()

-- Set court status
if isInMyCourt() then
    CourtLabel:Set("Status: MyCourt Detected ✓")
else
    CourtLabel:Set("Status: Regular Game Detected")
end

Rayfield:Notify({
    Title = "MyCourt Hacks Loaded",
    Content = "Optimized for MyCourt practice",
    Duration = 5,
})

print("MyCourt Basketball Hacks initialized!")
print("Court Type: " .. (isInMyCourt() and "MyCourt" or "Regular Game"))
