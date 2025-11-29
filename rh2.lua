getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "School Fight Combat",
   LoadingTitle = "Combat System",
   LoadingSubtitle = "For Fight in a School",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "SchoolFightConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Combat Settings
_G.KillAura = false
_G.KillAuraRange = 25
_G.AutoAttack = false
_G.TargetNearest = true
_G.ForceField = false
_G.SpeedBoost = false

-- Anti-Cheat Settings
_G.HideCombat = true
_G.RandomizeAttacks = true
_G.LegitMode = false
_G.AntiReport = true

-- Advanced Anti-Cheat Bypass
local function setupAdvancedACBypass()
    print("🛡️ Initializing Advanced AC Bypass...")
    
    -- Memory obfuscation
    if setfflag then
        setfflag("DFIntCrashUploadMaxUploads", "0")
    end
    
    -- Hook detection systems
    pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("report") or obj.Name:lower():find("cheat") or obj.Name:lower():find("detect")) then
                local oldFire = obj.FireServer
                obj.FireServer = function(self, ...)
                    warn("Blocked AC report: " .. obj.Name)
                    return nil
                end
            end
        end
    end)
    
    -- Script hiding
    pcall(function()
        for _, v in pairs(getreg()) do
            if type(v) == "function" and is_synapse_function(v) then
                hookfunction(v, function(...) return ... end)
            end
        end
    end)
    
    print("✅ Advanced AC Bypass Active")
end

-- Find valid targets (enemies)
local function getValidTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- Get nearest target
local function getNearestTarget()
    local targets = getValidTargets()
    local nearest = nil
    local nearestDist = math.huge
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local root = character.HumanoidRootPart
    
    for _, target in pairs(targets) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local distance = (root.Position - targetRoot.Position).Magnitude
            
            if distance < nearestDist and distance <= _G.KillAuraRange then
                nearestDist = distance
                nearest = target
            end
        end
    end
    
    return nearest
end

-- Kill Aura System
local function activateKillAura()
    spawn(function()
        while _G.KillAura do
            wait(_G.LegitMode and 0.3 or 0.1) -- Slower in legit mode
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local targets = getValidTargets()
                
                for _, target in pairs(targets) do
                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = target.Character.HumanoidRootPart
                        local distance = (character.HumanoidRootPart.Position - targetRoot.Position).Magnitude
                        
                        if distance <= _G.KillAuraRange then
                            -- Method 1: Remote event attacks
                            for _, obj in pairs(game:GetDescendants()) do
                                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("hit") or obj.Name:lower():find("damage") or obj.Name:lower():find("attack")) then
                                    if _G.RandomizeAttacks and math.random(1, 3) == 1 then
                                        -- Add randomness to avoid pattern detection
                                        obj:FireServer(target, math.random(25, 50))
                                    else
                                        obj:FireServer(target, 50) -- High damage
                                    end
                                end
                            end
                            
                            -- Method 2: Direct damage
                            local targetHumanoid = target.Character:FindFirstChild("Humanoid")
                            if targetHumanoid then
                                targetHumanoid:TakeDamage(35)
                            end
                            
                            -- Method 3: Touch damage
                            if not _G.LegitMode then
                                firetouchinterest(character.HumanoidRootPart, targetRoot, 0)
                                wait()
                                firetouchinterest(character.HumanoidRootPart, targetRoot, 1)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Auto-Target System
local function activateAutoTarget()
    spawn(function()
        while _G.AutoAttack do
            wait(0.2)
            
            pcall(function()
                local nearest = getNearestTarget()
                if nearest then
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        -- Face the target
                        local targetRoot = nearest.Character.HumanoidRootPart
                        character.HumanoidRootPart.CFrame = CFrame.new(
                            character.HumanoidRootPart.Position,
                            Vector3.new(targetRoot.Position.X, character.HumanoidRootPart.Position.Y, targetRoot.Position.Z)
                        )
                        
                        -- Auto-attack
                        if _G.KillAura then
                            for _, obj in pairs(game:GetDescendants()) do
                                if obj:IsA("RemoteEvent") and obj.Name:lower():find("attack") then
                                    obj:FireServer(nearest, 40)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Force Field Protection
local function activateForceField()
    spawn(function()
        while _G.ForceField do
            wait(1)
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    -- Prevent damage
                    character.Humanoid.Health = 100
                    
                    -- Block incoming attacks
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:IsA("RemoteEvent") and obj.Name:lower():find("damage") then
                            local oldFire = obj.FireServer
                            obj.FireServer = function(self, ...)
                                local args = {...}
                                -- Block damage to self
                                if args[1] == LocalPlayer then
                                    return nil
                                end
                                return oldFire(self, ...)
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
                    character.Humanoid.WalkSpeed = 25 -- Increased speed
                    character.Humanoid.JumpPower = 55
                end
            end)
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("Combat System", nil)

-- Anti-Cheat Section
local ACSection = MainTab:CreateSection("Advanced AC Bypass")

local ACToggle = MainTab:CreateToggle({
    Name = "Enable AC Bypass",
    CurrentValue = true,
    Flag = "HideCombat",
    Callback = function(Value)
        _G.HideCombat = Value
        if Value then setupAdvancedACBypass() end
    end,
})

local RandomizeToggle = MainTab:CreateToggle({
    Name = "Randomize Attacks",
    CurrentValue = true,
    Flag = "RandomizeAttacks",
    Callback = function(Value)
        _G.RandomizeAttacks = Value
    end,
})

local LegitToggle = MainTab:CreateToggle({
    Name = "Legit Mode",
    CurrentValue = false,
    Flag = "LegitMode",
    Callback = function(Value)
        _G.LegitMode = Value
    end,
})

-- Combat Section
local CombatSection = MainTab:CreateSection("Combat Settings")

local KillAuraToggle = MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        _G.KillAura = Value
        if Value then
            activateKillAura()
            Rayfield:Notify({
                Title = "Kill Aura Active",
                Content = "Auto-attacking nearby enemies",
                Duration = 3,
            })
        end
    end,
})

local AuraRange = MainTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {10, 50},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 25,
    Flag = "KillAuraRange",
    Callback = function(Value)
        _G.KillAuraRange = Value
    end,
})

local AutoAttackToggle = MainTab:CreateToggle({
    Name = "Auto-Target",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        _G.AutoAttack = Value
        if Value then
            activateAutoTarget()
            Rayfield:Notify({
                Title = "Auto-Target Active",
                Content = "Automatically targeting enemies",
                Duration = 3,
            })
        end
    end,
})

-- Defense Section
local DefenseSection = MainTab:CreateSection("Defense")

local ForceFieldToggle = MainTab:CreateToggle({
    Name = "Force Field",
    CurrentValue = false,
    Flag = "ForceField",
    Callback = function(Value)
        _G.ForceField = Value
        if Value then
            activateForceField()
            Rayfield:Notify({
                Title = "Force Field Active",
                Content = "Damage protection enabled",
                Duration = 3,
            })
        end
    end,
})

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
                Content = "Movement speed increased",
                Duration = 3,
            })
        end
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("Quick Actions")

local GodMode = MainTab:CreateButton({
    Name = "Activate God Mode",
    Callback = function()
        _G.KillAura = true
        _G.AutoAttack = true
        _G.ForceField = true
        _G.SpeedBoost = true
        KillAuraToggle:Set(true)
        AutoAttackToggle:Set(true)
        ForceFieldToggle:Set(true)
        SpeedToggle:Set(true)
        activateKillAura()
        activateAutoTarget()
        activateForceField()
        activateSpeedBoost()
        Rayfield:Notify({
            Title = "God Mode Active",
            Content = "All combat features enabled",
            Duration = 4,
        })
    end,
})

-- Initialize
setupAdvancedACBypass()

Rayfield:Notify({
    Title = "School Fight Combat Loaded",
    Content = "With advanced anti-cheat bypass",
    Duration = 5,
})

print("🎮 School Fight Combat system initialized!")
