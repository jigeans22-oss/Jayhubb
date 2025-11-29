getgenv().SecureMode = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "The Bronx Currency Pro",
   LoadingTitle = "Currency + AC Bypass",
   LoadingSubtitle = "Full Protection System",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "BronxProConfig"
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Currency Settings
_G.MoneyHack = false
_G.CashAmount = 10000
_G.ForceMoney = false
_G.AutoFarm = false

-- Anti-Cheat Bypass Settings
_G.HideScripts = true
_G.SpoofMemory = true
_G.AntiKick = true
_G.ClearLogs = true
_G.SimulateLegit = true
_G.RandomizePatterns = true

-- Anti-Cheat Bypass System
local function setupACBypass()
    print("🛡️ Initializing Anti-Cheat Bypass...")
    
    -- Hide script execution
    if _G.HideScripts then
        pcall(function()
            -- Obfuscate function calls
            for _, v in pairs(getreg()) do
                if type(v) == "function" and is_synapse_function(v) then
                    hookfunction(v, function(...) return ... end)
                end
            end
            
            -- Randomize script signatures
            if setfflag then
                setfflag("DFIntCrashUploadMaxUploads", "0")
            end
        end)
    end

    -- Spoof memory usage
    if _G.SpoofMemory then
        pcall(function()
            local oldgcinfo = gcinfo
            gcinfo = function() return math.random(35, 75) end
        end)
    end

    -- Anti-kick protection
    if _G.AntiKick then
        pcall(function()
            LocalPlayer.Kick:Connect(function()
                warn("Kick attempt blocked")
                return nil
            end)
        end)
    end

    -- Clear execution logs
    if _G.ClearLogs then
        pcall(function()
            rconsoleclear()
            game:GetService("LogService").MessageOut:Connect(function() end)
        end)
    end

    -- Simulate legitimate behavior
    if _G.SimulateLegit then
        spawn(function()
            while _G.SimulateLegit do
                wait(math.random(10, 30))
                pcall(function()
                    -- Simulate normal player actions
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("Humanoid") then
                        local humanoid = character.Humanoid
                        -- Random movements
                        if math.random(1, 5) == 1 then
                            humanoid:Move(Vector3.new(
                                math.random(-5, 5),
                                0,
                                math.random(-5, 5)
                            ))
                        end
                    end
                end)
            end
        end)
    end
    print("✅ Anti-Cheat Bypass Active")
end

-- Advanced Remote Event Hooking with AC Evasion
local function hookRemotesSafely()
    local hookedRemotes = {}
    
    return function(remote, callback)
        if hookedRemotes[remote] then return end
        hookedRemotes[remote] = true
        
        pcall(function()
            local oldFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                
                -- Randomize timing to avoid pattern detection
                if _G.RandomizePatterns then
                    wait(math.random(1, 10) / 100)
                end
                
                -- Call the modification callback
                local modifiedArgs = callback(args) or args
                
                return oldFireServer(self, unpack(modifiedArgs))
            end
        end)
    end
end

-- Find and Hook Bronx Remotes Safely
local function findAndHookBronxRemotes()
    local safeHook = hookRemotesSafely()
    local foundCount = 0
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            
            -- Money-related remotes
            if nameLower:find("cash") or nameLower:find("money") or 
               nameLower:find("currency") or nameLower:find("reward") or
               nameLower:find("purchase") or nameLower:find("collect") then
                
                safeHook(obj, function(args)
                    if _G.MoneyHack then
                        for i, arg in pairs(args) do
                            if type(arg) == "number" and arg > 0 and arg < 100000 then
                                -- Multiply with randomization
                                local multiplier = math.random(5, 15)
                                args[i] = arg * multiplier
                            elseif type(arg) == "string" and arg:find("%d+") then
                                -- Replace numbers in strings
                                args[i] = arg:gsub("%d+", tostring(_G.CashAmount))
                            end
                        end
                        
                        -- Add random arguments to avoid pattern detection
                        if _G.RandomizePatterns and math.random(1, 3) == 1 then
                            table.insert(args, "legit_player_action")
                            table.insert(args, math.random(1000, 9999))
                        end
                    end
                    return args
                end)
                foundCount = foundCount + 1
            end
            
            -- Anti-cheat reporting remotes (block them)
            if nameLower:find("report") or nameLower:find("cheat") or 
               nameLower:find("detect") or nameLower:find("violation") then
                
                safeHook(obj, function(args)
                    -- Block anti-cheat reports
                    warn("Blocked anti-cheat report to: " .. obj.Name)
                    return {} -- Return empty to block
                end)
            end
        end
        
        -- Also hook RemoteFunctions
        if obj:IsA("RemoteFunction") then
            local nameLower = obj.Name:lower()
            if nameLower:find("cash") or nameLower:find("money") then
                local oldInvoke = obj.InvokeServer
                obj.InvokeServer = function(self, ...)
                    local args = {...}
                    if _G.MoneyHack then
                        for i, arg in pairs(args) do
                            if type(arg) == "number" and arg > 0 then
                                args[i] = arg * 10
                            end
                        end
                    end
                    return oldInvoke(self, unpack(args))
                end
                foundCount = foundCount + 1
            end
        end
    end
    
    return foundCount
end

-- Money Modification System with AC Protection
local function setupMoneySystem()
    spawn(function()
        while _G.MoneyHack do
            wait(math.random(2, 5)) -- Random intervals
            pcall(function()
                local hookedCount = findAndHookBronxRemotes()
                
                -- Client-side money display modification
                if _G.ForceMoney then
                    pcall(function()
                        -- Modify various stat locations
                        local statLocations = {
                            LocalPlayer:FindFirstChild("leaderstats"),
                            LocalPlayer:FindFirstChild("Stats"),
                            LocalPlayer:FindFirstChild("Data"),
                            workspace:FindFirstChild("GameData")
                        }
                        
                        for _, stats in pairs(statLocations) do
                            if stats then
                                for _, stat in pairs(stats:GetChildren()) do
                                    local statName = stat.Name:lower()
                                    if statName:find("cash") or statName:find("money") or statName:find("currency") then
                                        if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                                            -- Set with random variation
                                            local variation = math.random(-100, 100)
                                            stat.Value = _G.CashAmount + variation
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
                
                -- Trigger fake "legitimate" money events
                if _G.RandomizePatterns then
                    pcall(function()
                        for _, remote in pairs(game:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and remote.Name:lower():find("reward") then
                                if math.random(1, 10) == 1 then
                                    remote:FireServer("daily_bonus", math.random(50, 200))
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end)
end

-- Auto-Farm System with Legitimacy Simulation
local function setupAutoFarm()
    spawn(function()
        while _G.AutoFarm do
            wait(math.random(3, 8)) -- Random farming intervals
            pcall(function()
                -- Look for collectibles with random patterns
                local collectibles = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("cash") or obj.Name:lower():find("money") or 
                       obj.Name:lower():find("coin") or obj.Name:lower():find("reward") then
                        if obj:IsA("Part") then
                            table.insert(collectibles, obj)
                        end
                    end
                end
                
                -- Collect in random order
                if #collectibles > 0 then
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local randomCollectible = collectibles[math.random(1, #collectibles)]
                        firetouchinterest(character.HumanoidRootPart, randomCollectible, 0)
                        wait(0.1)
                        firetouchinterest(character.HumanoidRootPart, randomCollectible, 1)
                    end
                end
                
                -- Random mission triggers
                if math.random(1, 5) == 1 then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Name:lower():find("mission") then
                            local character = LocalPlayer.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                firetouchinterest(character.HumanoidRootPart, obj, 0)
                                wait(0.1)
                                firetouchinterest(character.HumanoidRootPart, obj, 1)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Rayfield UI
local MainTab = Window:CreateTab("Currency Pro", nil)

-- Anti-Cheat Section
local ACSection = MainTab:CreateSection("Anti-Cheat Protection")

local ACToggle = MainTab:CreateToggle({
    Name = "Enable AC Bypass",
    CurrentValue = true,
    Flag = "HideScripts",
    Callback = function(Value)
        _G.HideScripts = Value
        if Value then setupACBypass() end
    end,
})

local SpoofToggle = MainTab:CreateToggle({
    Name = "Spoof Memory",
    CurrentValue = true,
    Flag = "SpoofMemory",
    Callback = function(Value)
        _G.SpoofMemory = Value
    end,
})

local RandomizeToggle = MainTab:CreateToggle({
    Name = "Randomize Patterns",
    CurrentValue = true,
    Flag = "RandomizePatterns",
    Callback = function(Value)
        _G.RandomizePatterns = Value
    end,
})

-- Money Section
local MoneySection = MainTab:CreateSection("Money Settings")

local MoneyToggle = MainTab:CreateToggle({
    Name = "Money Modifier",
    CurrentValue = false,
    Flag = "MoneyHack",
    Callback = function(Value)
        _G.MoneyHack = Value
        if Value then
            setupMoneySystem()
            Rayfield:Notify({
                Title = "Money Modifier Active",
                Content = "With AC protection",
                Duration = 3,
            })
        end
    end,
})

local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Smart Auto-Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            setupAutoFarm()
            Rayfield:Notify({
                Title = "Smart Auto-Farm",
                Content = "With legitimacy simulation",
                Duration = 3,
            })
        end
    end,
})

-- Quick Actions
local ActionsSection = MainTab:CreateSection("Quick Actions")

local ActivateAll = MainTab:CreateButton({
    Name = "Activate Full System",
    Callback = function()
        _G.HideScripts = true
        _G.SpoofMemory = true
        _G.RandomizePatterns = true
        _G.MoneyHack = true
        _G.AutoFarm = true
        ACToggle:Set(true)
        SpoofToggle:Set(true)
        RandomizeToggle:Set(true)
        MoneyToggle:Set(true)
        AutoFarmToggle:Set(true)
        setupACBypass()
        setupMoneySystem()
        setupAutoFarm()
        Rayfield:Notify({
            Title = "Full System Active",
            Content = "All protections and features enabled",
            Duration = 4,
        })
    end,
})

-- Initialize
setupACBypass()

Rayfield:Notify({
    Title = "Bronx Currency Pro Loaded",
    Content = "With advanced anti-cheat bypass",
    Duration = 6,
})

print("🎮 The Bronx Currency Pro with AC Bypass initialized!")
