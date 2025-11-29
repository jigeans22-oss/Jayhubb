getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Teleport Combat",
   LoadingTitle = "Blink Fighter",
   LoadingSubtitle = "Teleport + Game Mechanics",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TeleportCombatConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Combat Settings
_G.TeleportKill = false
_G.BlinkCombat = false
_G.ComboMode = false
_G.TeleportDelay = 0.2
_G.UseGameMoves = true
_G.AutoExecute = false

-- Anti-Cheat
_G.HideTeleports = true
_G.RandomizeTP = true
_G.LegitTeleport = false

-- Teleport to target and use game mechanics
local function teleportAndAttack(target)
    pcall(function()
        local character = LocalPlayer.Character
        local targetChar = target.Character
        
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local targetRoot = targetChar.HumanoidRootPart
        local myRoot = character.HumanoidRootPart
        
        -- Calculate teleport position (behind target)
        local offset = CFrame.new(0, 0, 3) -- 3 studs behind
        local teleportCFrame = targetRoot.CFrame * offset
        
        -- Add randomness if enabled
        if _G.RandomizeTP then
            local randomOffset = Vector3.new(
                math.random(-2, 2),
                0,
                math.random(-2, 2)
            )
            teleportCFrame = teleportCFrame + randomOffset
        end
        
        -- Teleport
        myRoot.CFrame = teleportCFrame
        
        -- Wait a moment
        wait(0.1)
        
        -- Face the target
        myRoot.CFrame = CFrame.new(myRoot.Position, targetRoot.Position)
        
        -- USE GAME MECHANICS TO ATTACK:
        
        -- Method 1: Look for and use game weapons/tools
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                -- Activate tool
                tool:Activate()
                
                -- Fire tool remotes
                for _, remote in pairs(tool:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(target)
                        remote:FireServer(targetChar)
                        remote:FireServer("hit")
                    end
                end
            end
        end
        
        -- Method 2: Use game attack remotes
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("punch") or name:find("hit") or name:find("attack") or name:find("damage") then
                    remote:FireServer(target)
                    remote:FireServer(targetChar)
                    remote:FireServer("attack")
                end
            end
        end
        
        -- Method 3: Touch damage (common in fighting games)
        firetouchinterest(myRoot, targetRoot, 0)
        wait()
        firetouchinterest(myRoot, targetRoot, 1)
        
        -- Method 4: Direct humanoid damage as backup
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        if targetHumanoid then
            targetHumanoid:TakeDamage(25)
        end
        
        -- Method 5: Look for combat scripts and trigger them
        for _, script in pairs(character:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                if script.Name:lower():find("combat") or script.Name:lower():find("attack") then
                    pcall(function() script:FireServer("attack", target) end)
                end
            end
        end
        
        print("✅ Teleported and attacked: " .. target.Name)
    end)
end

-- Main teleport combat loop
local function startTeleportCombat()
    spawn(function()
        while _G.TeleportKill do
            wait(_G.TeleportDelay)
            
            pcall(function()
                local targets = {}
                
                -- Get all valid targets
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            table.insert(targets, player)
                        end
                    end
                end
                
                if #targets > 0 then
                    -- Teleport to each target and attack
                    for _, target in pairs(targets) do
                        if _G.BlinkCombat then
                            -- Blink mode: Quick teleports
                            teleportAndAttack(target)
                            wait(0.1)
                        else
                            -- Normal mode: Sequential
                            teleportAndAttack(target)
                            wait(_G.TeleportDelay)
                        end
                    end
                end
            end)
        end
    end)
end

-- Combo Mode: Chain attacks on single target
local function startComboMode()
    spawn(function()
        while _G.ComboMode do
            wait(0.5)
            
            pcall(function()
                -- Find nearest target for combo
                local nearest = nil
                local nearestDist = math.huge
                local character = LocalPlayer.Character
                
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local myRoot = character.HumanoidRootPart
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = player
                            end
                        end
                    end
                end
                
                if nearest then
                    -- Combo: Teleport + multiple attacks
                    for i = 1, 3 do -- 3-hit combo
                        teleportAndAttack(nearest)
                        wait(0.2)
                    end
                end
            end)
        end
    end)
end

-- Auto-execute moves (uses game's actual combat system)
local function autoExecuteMoves()
    spawn(function()
        while _G.AutoExecute do
            wait(0.3)
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                -- Find and use special moves/abilities
                for _, remote in pairs(game:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local name = remote.Name:lower()
                        
                        -- Look for special moves
                        if name:find("special") or name:find("ultimate") or name:find("ability") or name:find("move") then
                            remote:FireServer("activate")
                            remote:FireServer("use")
                        end
                        
                        -- Look for combo moves
                        if name:find("combo") or name:find("finisher") or name:find("execute") then
                            remote:FireServer()
                        end
                    end
                end
                
                -- Use keyboard inputs for moves (common in fighting games)
                local keys = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.G}
                for _, key in pairs(keys) do
                    UserInputService:SendKeyEvent(true, key, false, game)
                    UserInputService:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end)
end

-- Find game-specific combat mechanics
local function scanCombatMechanics()
    local mechanics = {}
    
    pcall(function()
        -- Look for combat remotes
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("punch") or name:find("kick") or name:find("hit") or name:find("attack") or name:find("combo") then
                    table.insert(mechanics, "Remote: " .. remote.Name)
                end
            end
        end
        
        -- Look for weapons/tools
        for _, tool in pairs(workspace:GetDescendants()) do
            if tool:IsA("Tool") then
                table.insert(mechanics, "Weapon: " .. tool.Name)
            end
        end
        
        -- Look for combat scripts
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") and script.Name:lower():find("combat") then
                table.insert(mechanics, "Script: " .. script.Name)
            end
        end
    end)
    
    return mechanics
end

-- Rayfield UI
local MainTab = Window:CreateTab("Teleport Combat", nil)

-- Teleport Settings
local TeleportSection = MainTab:CreateSection("Teleport Combat")

local TeleportToggle = MainTab:CreateToggle({
    Name = "Teleport Kill Mode",
    CurrentValue = false,
    Flag = "TeleportKill",
    Callback = function(Value)
        _G.TeleportKill = Value
        if Value then
            startTeleportCombat()
            Rayfield:Notify({
                Title = "Teleport Combat Active",
                Content = "Blinking to targets and attacking",
                Duration = 3,
            })
        end
    end,
})

local BlinkToggle = MainTab:CreateToggle({
    Name = "Blink Combat (Fast)",
    CurrentValue = false,
    Flag = "BlinkCombat",
    Callback = function(Value)
        _G.BlinkCombat = Value
    end,
})

local ComboToggle = MainTab:CreateToggle({
    Name = "Combo Mode",
    CurrentValue = false,
    Flag = "ComboMode",
    Callback = function(Value)
        _G.ComboMode = Value
        if Value then
            startComboMode()
            Rayfield:Notify({
                Title = "Combo Mode Active",
                Content = "3-hit combos on nearest target",
                Duration = 3,
            })
        end
    end,
})

local DelaySlider = MainTab:CreateSlider({
    Name = "Teleport Delay",
    Range = {0.1, 1.0},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 0.2,
    Flag = "TeleportDelay",
    Callback = function(Value)
        _G.TeleportDelay = Value
    end,
})

-- Game Mechanics
local MechanicsSection = MainTab:CreateSection("Game Mechanics")

local AutoExecuteToggle = MainTab:CreateToggle({
    Name = "Auto-Execute Moves",
    CurrentValue = false,
    Flag = "AutoExecute",
    Callback = function(Value)
        _G.AutoExecute = Value
        if Value then
            autoExecuteMoves()
            Rayfield:Notify({
                Title = "Auto-Execute Active",
                Content = "Using game special moves automatically",
                Duration = 3,
            })
        end
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("Quick Actions")

local NinjaMode = MainTab:CreateButton({
    Name = "Activate Ninja Mode",
    Callback = function()
        _G.TeleportKill = true
        _G.BlinkCombat = true
        _G.AutoExecute = true
        TeleportToggle:Set(true)
        BlinkToggle:Set(true)
        AutoExecuteToggle:Set(true)
        startTeleportCombat()
        autoExecuteMoves()
        Rayfield:Notify({
            Title = "Ninja Mode Active",
            Content = "Instant teleports + special moves",
            Duration = 4,
        })
    end,
})

local ScanMoves = MainTab:CreateButton({
    Name = "Scan Combat Mechanics",
    Callback = function()
        local mechanics = scanCombatMechanics()
        local message = "Found " .. #mechanics .. " combat mechanics:\n"
        for i, mech in ipairs(mechanics) do
            if i <= 6 then
                message = message .. "• " .. mech .. "\n"
            end
        end
        Rayfield:Notify({
            Title = "Combat Mechanics",
            Content = message,
            Duration = 6,
        })
    end,
})

-- Status
local StatusSection = MainTab:CreateSection("Status")
local CombatStatus = MainTab:CreateLabel("Ready to fight")

-- Update status
spawn(function()
    while true do
        wait(2)
        local targetCount = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    targetCount = targetCount + 1
                end
            end
        end
        CombatStatus:Set("Alive Targets: " .. targetCount)
    end
end)

Rayfield:Notify({
    Title = "Teleport Combat Loaded",
    Content = "Blink behind enemies and use game mechanics",
    Duration = 5,
})

print("⚡ Teleport Combat system initialized!")
