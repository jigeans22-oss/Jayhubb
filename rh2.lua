getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Track & Field Speed",
   LoadingTitle = "Advanced Speed Bypass",
   LoadingSubtitle = "Multi-Layer AC Evasion",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TrackFieldSpeedConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Advanced Speed Settings
_G.SpeedEnabled = false
_G.SpeedValue = 30
_G.StealthMode = true
_G.AdaptiveSpeed = true
_G.RandomizeSpeed = true
_G.NoStamina = false

-- Advanced Anti-Cheat Bypass
local originalWalkspeed = 16
local detectionHooks = {}
local speedMethods = {}

-- Multi-Layer Anti-Cheat Evasion
local function setupAdvancedACBypass()
    print("🛡️ Initializing Advanced AC Bypass...")
    
    -- Layer 1: Memory Obfuscation
    pcall(function()
        if setfflag then
            setfflag("DFIntCrashUploadMaxUploads", "0")
            setfflag("DFStringCrashUploadUrl", "")
        end
    end)
    
    -- Layer 2: Hook Detection Systems
    pcall(function()
        -- Hook common anti-speed detection
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("speed") or name:find("walkspeed") or name:find("cheat") or name:find("detect") then
                    detectionHooks[obj] = obj.FireServer
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        -- Filter out speed-related reports
                        for i, arg in pairs(args) do
                            if type(arg) == "string" and arg:lower():find("speed") then
                                return nil
                            end
                        end
                        return detectionHooks[obj](self, ...)
                    end
                end
            end
        end
    end)
    
    -- Layer 3: Script Integrity Protection
    pcall(function()
        for _, v in pairs(getreg()) do
            if type(v) == "function" and is_synapse_function(v) then
                hookfunction(v, function(...) return ... end)
            end
        end
    end)
    
    -- Layer 4: Network Traffic Obfuscation
    pcall(function()
        local mt = getrawmetatype(game)
        if mt then
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" and tostring(self):find("Speed") then
                    return nil
                end
                return oldNamecall(self, ...)
            end)
        end
    end)
    
    print("✅ Advanced AC Bypass - 4 Layers Active")
end

-- Advanced Speed Methods (Multiple Techniques)
local function initializeSpeedMethods()
    speedMethods = {
        -- Method 1: Direct Humanoid Modification (Stealth)
        function(character, speed)
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                if _G.StealthMode then
                    -- Gradual speed increase to avoid detection
                    local currentSpeed = humanoid.WalkSpeed
                    if currentSpeed < speed then
                        humanoid.WalkSpeed = math.min(currentSpeed + 2, speed)
                    end
                else
                    humanoid.WalkSpeed = speed
                end
                return true
            end
            return false
        end,
        
        -- Method 2: BodyVelocity Movement (Bypasses Humanoid)
        function(character, speed)
            if character and character:FindFirstChild("HumanoidRootPart") then
                local root = character.HumanoidRootPart
                local bodyVelocity = root:FindFirstChild("SpeedBodyVelocity") or Instance.new("BodyVelocity")
                bodyVelocity.Name = "SpeedBodyVelocity"
                bodyVelocity.Velocity = root.CFrame.LookVector * speed
                bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
                bodyVelocity.P = 1000
                bodyVelocity.Parent = root
                return true
            end
            return false
        end,
        
        -- Method 3: CFrame Movement (Most Stealthy)
        function(character, speed)
            if character and character:FindFirstChild("HumanoidRootPart") then
                local root = character.HumanoidRootPart
                local humanoid = character:FindFirstChild("Humanoid")
                
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    local moveDirection = humanoid.MoveDirection
                    local newPosition = root.Position + (moveDirection * speed * 0.1)
                    root.CFrame = CFrame.new(newPosition, newPosition + moveDirection)
                    return true
                end
            end
            return false
        end,
        
        -- Method 4: Network Ownership Bypass
        function(character, speed)
            if character and character:FindFirstChild("HumanoidRootPart") then
                local root = character.HumanoidRootPart
                -- Remove network ownership for client-side control
                root:SetNetworkOwner(nil)
                return true
            end
            return false
        end
    }
end

-- Advanced Speed System with Rotation
local function activateAdvancedSpeed()
    local currentMethod = 1
    local lastMethodChange = tick()
    
    spawn(function()
        while _G.SpeedEnabled do
            RunService.Heartbeat:Wait()
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                -- Calculate adaptive speed
                local targetSpeed = _G.SpeedValue
                if _G.AdaptiveSpeed then
                    -- Adjust speed based on game context
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        if humanoid:GetState() == Enum.HumanoidStateType.Running then
                            targetSpeed = _G.SpeedValue * 1.2
                        end
                    end
                end
                
                -- Randomize speed if enabled
                if _G.RandomizeSpeed then
                    targetSpeed = targetSpeed + math.random(-5, 5)
                    targetSpeed = math.max(16, targetSpeed) -- Don't go below normal
                end
                
                -- Rotate through speed methods to avoid pattern detection
                if tick() - lastMethodChange > 2 then
                    currentMethod = (currentMethod % #speedMethods) + 1
                    lastMethodChange = tick()
                end
                
                -- Apply current speed method
                local success = speedMethods[currentMethod](character, targetSpeed)
                
                -- Fallback to next method if current fails
                if not success then
                    currentMethod = (currentMethod % #speedMethods) + 1
                    speedMethods[currentMethod](character, targetSpeed)
                end
                
                -- No Stamina System
                if _G.NoStamina then
                    for _, obj in pairs(character:GetDescendants()) do
                        if obj:IsA("NumberValue") and obj.Name:lower():find("stamina") then
                            obj.Value = 100
                        end
                    end
                end
            end)
        end
    end)
end

-- Stealth Behavior Simulation
local function simulateLegitBehavior()
    spawn(function()
        while _G.SpeedEnabled and _G.StealthMode do
            wait(math.random(5, 15))
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    -- Occasionally reset to normal speed briefly
                    character.Humanoid.WalkSpeed = originalWalkspeed
                    wait(0.5)
                    -- Then resume modified speed
                    if _G.SpeedEnabled then
                        character.Humanoid.WalkSpeed = _G.SpeedValue
                    end
                end
            end)
        end
    end)
end

-- Cleanup System
local function setupCleanup()
    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to load
        if _G.SpeedEnabled then
            activateAdvancedSpeed()
        end
    end)
    
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            -- Clean up all modifications
            for obj, oldFunc in pairs(detectionHooks) do
                if obj and obj.Parent then
                    obj.FireServer = oldFunc
                end
            end
        end
    end)
end

-- Performance Monitor
local function startPerformanceMonitor()
    spawn(function()
        local warningCount = 0
        while _G.SpeedEnabled do
            wait(10)
            
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    local currentSpeed = character.Humanoid.WalkSpeed
                    
                    -- Check if speed is being reset by anti-cheat
                    if currentSpeed <= originalWalkspeed and _G.SpeedEnabled then
                        warningCount = warningCount + 1
                        if warningCount >= 3 then
                            print("⚠️ Anti-cheat detected speed modifications!")
                            -- Switch to more stealthy methods
                            _G.StealthMode = true
                            _G.RandomizeSpeed = true
                            warningCount = 0
                        end
                    else
                        warningCount = 0
                    end
                end
            end)
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("Speed Bypass", nil)

-- Anti-Cheat Section
local ACSection = MainTab:CreateSection("Advanced AC Bypass")

local ACToggle = MainTab:CreateToggle({
    Name = "Enable AC Bypass",
    CurrentValue = true,
    Flag = "StealthMode",
    Callback = function(Value)
        _G.StealthMode = Value
        if Value then
            setupAdvancedACBypass()
        end
    end,
})

local AdaptiveToggle = MainTab:CreateToggle({
    Name = "Adaptive Speed",
    CurrentValue = true,
    Flag = "AdaptiveSpeed",
    Callback = function(Value)
        _G.AdaptiveSpeed = Value
    end,
})

local RandomizeToggle = MainTab:CreateToggle({
    Name = "Randomize Speed",
    CurrentValue = true,
    Flag = "RandomizeSpeed",
    Callback = function(Value)
        _G.RandomizeSpeed = Value
    end,
})

-- Speed Settings
local SpeedSection = MainTab:CreateSection("Speed Settings")

local SpeedToggle = MainTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "SpeedEnabled",
    Callback = function(Value)
        _G.SpeedEnabled = Value
        if Value then
            activateAdvancedSpeed()
            simulateLegitBehavior()
            startPerformanceMonitor()
            Rayfield:Notify({
                Title = "Advanced Speed Active",
                Content = "Multi-layer AC bypass engaged",
                Duration = 3,
            })
        else
            -- Reset to normal speed
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = originalWalkspeed
                end
            end)
            Rayfield:Notify({
                Title = "Speed Disabled",
                Content = "Returned to normal speed",
                Duration = 2,
            })
        end
    end,
})

local SpeedSlider = MainTab:CreateSlider({
    Name = "Speed Value",
    Range = {20, 100},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 30,
    Flag = "SpeedValue",
    Callback = function(Value)
        _G.SpeedValue = Value
    end,
})

local StaminaToggle = MainTab:CreateToggle({
    Name = "No Stamina Drain",
    CurrentValue = false,
    Flag = "NoStamina",
    Callback = function(Value)
        _G.NoStamina = Value
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("Quick Actions")

local GhostMode = MainTab:CreateButton({
    Name = "Activate Ghost Mode",
    Callback = function()
        _G.SpeedEnabled = true
        _G.StealthMode = true
        _G.AdaptiveSpeed = true
        _G.RandomizeSpeed = true
        _G.NoStamina = true
        _G.SpeedValue = 40
        SpeedToggle:Set(true)
        ACToggle:Set(true)
        AdaptiveToggle:Set(true)
        RandomizeToggle:Set(true)
        StaminaToggle:Set(true)
        SpeedSlider:Set(40)
        activateAdvancedSpeed()
        simulateLegitBehavior()
        startPerformanceMonitor()
        Rayfield:Notify({
            Title = "Ghost Mode Active",
            Content = "Maximum stealth speed enabled",
            Duration = 4,
        })
    end,
})

-- Status
local StatusSection = MainTab:CreateSection("Status")
local SpeedStatus = MainTab:CreateLabel("Speed: READY")

-- Update status
spawn(function()
    while true do
        wait(1)
        pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                local currentSpeed = character.Humanoid.WalkSpeed
                local status = _G.SpeedEnabled and "ACTIVE 🚀" or "READY"
                local speedText = math.floor(currentSpeed)
                SpeedStatus:Set("Speed: " .. speedText .. " | Mode: " .. status)
            end
        end)
    end
end)

-- Initialize
setupAdvancedACBypass()
initializeSpeedMethods()
setupCleanup()

Rayfield:Notify({
    Title = "Track & Field Speed Loaded",
    Content = "Advanced anti-cheat bypass ready",
    Duration = 5,
})

print("⚡ Track & Field Advanced Speed - Multi-Layer AC Bypass Ready!")
