local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function createESP(Player)
    local Name = Drawing.new("Text")
    Name.Text = Player.Name
    Name.Size = 16
    Name.Outline = true
    Name.Center = true
    Name.Color = Color3.fromRGB(255, 100, 100)

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(255, 100, 100)

    local function update()
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(Character.Head.Position)
                if OnScreen then
                    local X = Pos.X
                    local Y = Pos.Y
                    Name.Position = Vector2.new(X, Y - 33)
                    Box.Size = Vector2.new(2450 / Pos.Z, 3850/ Pos.Z)
                    Box.Position = Vector2.new(X - Box.Size.X / 2, Y - Box.Size.Y /9)
                    Name.Visible = true
                    Box.Visible = true
                    return
                end
            end
        end
        Name.Visible = false
        Box.Visible = false
    end
    update()

    local Connection1 = Player.CharacterAdded:Connect(function()
        update()
    end)
    local Connection2 = Player.CharacterRemoving:Connect(function()
        Name.Visible = false
        Box.Visible = false
    end)

    return {
        update = update,
        disconnect = function()
            Name:Remove()
            Box:Remove()
            Connection1:Disconnect()
            Connection2:Disconnect()
        end
    }
end

local EspList = {}
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        table.insert(EspList, createESP(Player))
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, Esp in pairs(EspList) do
        Esp.update()
    end
end)
