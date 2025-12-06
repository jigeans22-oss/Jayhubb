-- Football Fusion 2 WalkSpeed Bypass
-- Use with caution

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Anti-cheat detection variables
local originalWalkSpeed = 16
local bypassEnabled = false
local detectionBypass = false

-- Create simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FF2Speed"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "⚽ Football Fusion 2"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Speed Toggle
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(1, -20, 0, 30)
SpeedToggle.Position = UDim2.new(0, 10, 0, 40)
SpeedToggle.Text = "🚀 Enable Speed (OFF)"
SpeedToggle.TextColor3 = Color3.new(1, 1, 1)
SpeedToggle.TextSize = 14
SpeedToggle.Font = Enum.Font.Gotham
SpeedToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedToggle.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = SpeedToggle

-- Speed Slider
local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Size = UDim2.new(1, -20, 0, 20)
SpeedSlider.Position = UDim2.new(0, 10, 0, 80)
SpeedSlider.Text = ""
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SpeedSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SpeedSlider

local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.3, 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SpeedFill.Parent = SpeedSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SpeedFill

local SpeedValue = Instance.new("TextLabel")
SpeedValue.Text = "Speed: 16"
SpeedValue.Size = UDim2.new(1, -20, 0, 20)
SpeedValue.Position = UDim2.new(0, 10, 0, 105)
SpeedValue.BackgroundTransparency = 1
SpeedValue.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedValue.Font = Enum.Font.Gotham
SpeedValue.TextSize = 14
SpeedValue.TextXAlignment = Enum.TextXAlignment.Left
SpeedValue.Parent = MainFrame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Variables
local currentSpeed = 16
local maxSpeed = 100
local isEnabled = false
local draggingSlider = false

-- Function to apply speed
function applySpeed()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if isEnabled then
        humanoid.WalkSpeed = currentSpeed
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Function to bypass anti-cheat (simplified version)
function setupBypass()
    -- Method 1: Hook Humanoid property changes
    local originalIndex
    originalIndex = hookmetamethod(game, "__index", function(self, key)
        if checkcaller() then
            return originalIndex(self, key)
        end
        
        if self:IsA("Humanoid") and key == "WalkSpeed" and isEnabled then
            return currentSpeed
        end
        
        return originalIndex(self, key)
    end)
    
    -- Method 2: Network manipulation (simplified)
    local networkBypass = false
    if not networkBypass then
        spawn(function()
            while task.wait(0.1) do
                if not isEnabled then continue end
                if not LocalPlayer.Character then continue end
                
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Constantly reapply to bypass checks
                    humanoid.WalkSpeed = currentSpeed
                end
            end
        end)
        networkBypass = true
    end
    
    bypassEnabled = true
end

-- Toggle speed
SpeedToggle.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    
    if isEnabled then
        SpeedToggle.Text = "🚀 Enable Speed (ON)"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        if not bypassEnabled then
            setupBypass()
        end
        
        applySpeed()
    else
        SpeedToggle.Text = "🚀 Enable Speed (OFF)"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        applySpeed()
    end
end)

-- Speed slider
SpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
