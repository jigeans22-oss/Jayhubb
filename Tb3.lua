local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Tha Bronx 3",
    LoadingTitle = "Loading Tha Bronx 3 Script",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ThaBronx3Scripts",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)

local Section = Tab:CreateSection("Features")

local autoGunDupeToggle = Tab:CreateToggle({
    Name = "Auto Gun Dupe",
    CurrentValue = false,
    Flag = "AutoGunDupe",
    Callback = function(value)
        if value then
            _G.AutoGunDupe = true
            spawn(function()
                while _G.AutoGunDupe do
                    local player = game.Players.LocalPlayer
                    local gun = player.Backpack:FindFirstChildWhichIsA("Tool") or player.Character:FindFirstChildWhichIsA("Tool")
                    if gun then
                        -- Simulate dropping and picking up the gun to duplicate
                        local gunClone = gun:Clone()
                        gunClone.Parent = player.Backpack
                    end
                    wait(1)
                end
            end)
        else
            _G.AutoGunDupe = false
        end
    end
})

local infMoneyToggle = Tab:CreateToggle({
    Name = "Infinite Money",
    CurrentValue = false,
    Flag = "InfMoney",
    Callback = function(value)
        if value then
            _G.InfMoney = true
            spawn(function()
                while _G.InfMoney do
                    local player = game.Players.LocalPlayer
                    local leaderstats = player:FindFirstChild("leaderstats")
                    if leaderstats then
                        local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
                        if money and money.Value < 1e9 then
                            money.Value = money.Value + 1000
                        end
                    end
                    wait(0.5)
                end
            end)
        else
            _G.InfMoney = false
        end
    end
})

local Section2 = Tab:CreateSection("Misc")

Tab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})
