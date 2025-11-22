local Rayfield = loadstring(game:HttpGet('https://[Log in to view URL]'))()


local Window = Rayfield:CreateWindow({
   Name = "✔THA BRONX 3",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "MADE BY Haxzo",
   LoadingSubtitle = "TB3",
   Theme = "Ocean", -- Check https://[Log in to view URL]

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "THA BRONX 3"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "THA BRONX 3",
      Subtitle = "Key System",
      Note = "DM ME", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Haxzo"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local mainTab = Window:CreateTab("main",nil) -- Title, Image
local mainSection = mainTab:CreateSection("main")

Rayfield:Notify({
   Title = "U EXECUTED THE BEST SCRIPT",
   Content = "HAVE FUN DUMBASS",
   Duration = 6.5,
   Image = 4483362458,
})

local Button = mainTab:CreateButton({
   Name = "infinite jump😊",
   Callback = function()
   --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

            
local InfiniteJumpEnabled = true
game:GetService("UserInputService").JumpRequest:connect(function()
	if InfiniteJumpEnabled then
		game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
	end
end)
   end,
})

local Slider = mainTab:CreateSlider({
   Name = "walkspeed",
   Range = {0, 500},
   Increment = 1,
   Suffix = "WALKSPEED",
   CurrentValue = 16,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
           game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Dropdown = mainTab:CreateDropdown({
   Name = "TELEPORT",
   Options = {"ANTI","USEFULL"},
   CurrentOption = {"STARTER ISLAND"},
   MultipleOptions = false,
   Flag = "TELEPORT", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
        print(Options)
   end,
})

local ESPTab = Window:CreateTab("ESPTab", nil) -- Title, Image
local ESPSection = ESPTab:CreateSection("ESPTab")

local Toggle = ESPTab:CreateToggle({
   Name = "ESP TOGGLE",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        -- ESP Script Example in Roblox

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Function to create a 3D box around the target
local function createESP(player)
    -- Make sure the player has a character
    if player.Character and player.Character:FindFirstChild("Head") then
        -- Create ESP Box
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Adornee = player.Character:WaitForChild("Head")
        espBox.Size = Vector3.new(2, 2, 2) -- You can adjust the size here
        espBox.Color3 = Color3.fromRGB(255, 0, 0) -- Red color for ESP
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 10
        espBox.Parent = player.Character
        espBox.Visible = true

        -- Cleanup when the player leaves or the character is removed
        player.CharacterAdded:Connect(function()
            espBox:Destroy()
        end)
    end
end

-- Loop through all players in the game and create ESP for each one
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Player then
        createESP(player)
    end
end

-- Listen for new players joining
Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        createESP(player)
    end
end)

   end,
})


local AIMBOTTab = Window:CreateTab("AIMBOT", nil) -- Title, Image
local Section = AIMBOTTab:CreateSection("AIMBOT")

local Toggle = AIMBOTTab:CreateToggle({
   Name = "AIMBOT TOGGLE",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimbotEnabled = false
local LockedTarget = nil
local FOV = 100 -- Adjust to change aim assist area

-- Function to check if a player is within the FOV
local function IsInFOV(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local camera = game.Workspace.CurrentCamera
        local targetPos = camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distanceFromCenter = (Vector2.new(targetPos.X, targetPos.Y) - screenCenter).Magnitude
        
        return distanceFromCenter <= FOV
    end
    return false
end

-- Function to get the closest player within FOV
local function GetClosestPlayer()
    local players = game.Players:GetPlayers()
    local localPlayer = game.Players.LocalPlayer
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, player in pairs(players) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if IsInFOV(player) then -- Only select players inside the FOV
                local pos = player.Character.HumanoidRootPart.Position
                local distance = (pos - localPlayer.Character.HumanoidRootPart.Position).magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Function to smoothly aim at the target
local function SmoothAimAt(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local camera = game.Workspace.CurrentCamera
        local targetPos = target.Character.HumanoidRootPart.Position
        local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)

        -- Smooth transition to target
        camera.CFrame = camera.CFrame:Lerp(newCFrame, 0.2) -- Adjust 0.2 for faster/slower aiming
    end
end

-- Aimbot toggle function
local function ToggleAimbot()
    AimbotEnabled = not AimbotEnabled -- Toggle on/off

    if AimbotEnabled then
        LockedTarget = GetClosestPlayer() -- Lock onto nearest target
    else
        LockedTarget = nil -- Unlock target
    end
end

-- Keybind to toggle aimbot on/off
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Z and not gameProcessed then
        ToggleAimbot()
    end
end)

-- Main loop: Keep aiming at the locked target if aimbot is enabled
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and LockedTarget then
        SmoothAimAt(LockedTarget)

        -- If target dies or disappears, unlock aimbot
        if not LockedTarget.Character or not LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            AimbotEnabled = false
            LockedTarget = nil
        end
    end
end)

   end,
})

local TeleportTab = Window:CreateTab("Teleport", nil) -- Create a tab for teleportation
local TeleportSection = TeleportTab:CreateSection("Teleport System")

local SelectedPlayer = nil

-- Function to get all player names except yourself
local function GetPlayers()
    local playerNames = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

-- Dropdown for selecting a player
local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayers(),
    CurrentOption = nil,
    MultipleOptions = false,
    Flag = "TeleportPlayer",
    Callback = function(option)
        SelectedPlayer = option
    end,
})

-- Function to get a player's character safely
local function GetPlayerCharacter(playerName)
    local player = game.Players:FindFirstChild(playerName)
    if player then
        local character = player.Character or player.CharacterAdded:Wait()
        while not character:FindFirstChild("HumanoidRootPart") do
            task.wait(0.1)
        end
        return character
    end
    return nil
end

-- Function to teleport to selected player
local function TeleportToPlayer()
    if SelectedPlayer then
        local localPlayer = game.Players.LocalPlayer
        local targetCharacter = GetPlayerCharacter(SelectedPlayer)

        if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
            local localCharacter = localPlayer.Character
            if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
                -- Teleport slightly above the target to avoid overlap
                localCharacter:SetPrimaryPartCFrame(targetCharacter.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))

                Rayfield:Notify({
                    Title = "Teleport Success",
                    Content = "Teleported to " .. SelectedPlayer,
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "Player not found or not loaded!",
                Duration = 3,
            })
        end
    else
        Rayfield:Notify({
            Title = "Teleport Failed",
            Content = "No player selected!",
            Duration = 3,
        })
    end
end

-- Create a teleport button
local TeleportButton = TeleportTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        TeleportToPlayer()
    end,
})

-- Update dropdown when players join or leave
game.Players.PlayerAdded:Connect(function()
    PlayerDropdown:SetOptions(GetPlayers())
end)

game.Players.PlayerRemoving:Connect(function()
    PlayerDropdown:SetOptions(GetPlayers())
end)

local GUNSTab = Window:CreateTab("GUNS",nil) -- Title, Image
local Section = GUNSTab:CreateSection("GUNS")

local Button = GUNSTab:CreateButton({
   Name = "DUPEGUNS",
   Callback = function()
        -- Script for duplicating an item in a player's inventory
local Players = game:GetService("Players")

-- Function to duplicate a specific item in player's backpack
local function duplicateItem(player, itemName)
    -- Get the player's Backpack
    local backpack = player.Backpack
    
    -- Search for the item in the backpack
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name == itemName then
            -- Create a copy of the item
            local itemClone = item:Clone()
            
            -- Parent the clone to the player's backpack to duplicate the item
            itemClone.Parent = backpack
            break
        end
    end
end

-- Example: Duplicate a specific item when the player touches a part or performs an action
game.Workspace.DuplicateButton.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    
    if player then
        -- Call the duplicateItem function to duplicate a "ToolName" item
        duplicateItem(player, "ToolName")  -- Replace "ToolName" with the name of the item you want to duplicate
    end
end)


   end,
})

local Toggle = ESPTab:CreateToggle({
   Name = "NAMES",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
         -- ESP Script to display player names above their head in Roblox

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

-- Function to create name ESP
local function createNameESP(player)
    -- Make sure the player has a character
    if player.Character and player.Character:FindFirstChild("Head") then
        -- Create a BillboardGui to display the name above the player
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = player.Character:WaitForChild("Head")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0) -- Adjust the height of the name
        billboard.AlwaysOnTop = true
        billboard.Parent = player.Character

        -- Create the text label for the player's name
        local label = Instance.new("TextLabel")
        label.Text = player.Name
        label.TextSize = 10
        label.TextColor3 = Color3.fromRGB(255, 255, 255) -- White color for name
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Parent = billboard
        
        -- Cleanup when the player leaves or the character is removed
        player.CharacterAdded:Connect(function()
            billboard:Destroy()
        end)
    end
end

-- Loop through all players in the game and create name ESP for each one
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Player then
        createNameESP(player)
    end
end

-- Listen for new players joining
Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        createNameESP(player)
    end
end)

   end,
})

local Slider = mainTab:CreateSlider({
   Name = "Jumppower",
   Range = {0, 400},
   Increment = 1,
   Suffix = "Jumppower",
   CurrentValue = 10,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Jumppower = (Value)
   end,
})
