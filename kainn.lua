-- 🏀 John Phelps Gymnasium Basketball Cheats
-- MOBILE SUPPORTED VERSION

-- Check if mobile
local isMobile = game:GetService("UserInputService").TouchEnabled
local isConsole = game:GetService("UserInputService").GamepadEnabled

-- Create mobile-friendly UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileBasketballCheats"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (larger for mobile touch)
local MainFrame = Instance.new("Frame")
MainFrame.Size = isMobile and UDim2.new(0.9, 0, 0.8, 0) or UDim2.new(0, 400, 0, 600)
MainFrame.Position = isMobile and UDim2.new(0.05, 0, 0.1, 0) or UDim2.new(0.5, -200, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add corner rounding for mobile
if isMobile then
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame
end

-- Title (bigger text for mobile)
local Title = Instance.new("TextLabel")
Title.Text = "🏀 Basketball Cheats"
Title.Size = UDim2.new(1, 0, 0, isMobile and 60 or 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = isMobile and 24 or 20
Title.Parent = MainFrame

-- Add corner rounding to title
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, isMobile and 12 or 8)
TitleCorner.Parent = Title

-- Drag handle for mobile (bigger touch area)
local DragHandle = Instance.new("TextButton")
DragHandle.Size = UDim2.new(1, 0, 0, isMobile and 60 or 50)
DragHandle.BackgroundTransparency = 1
DragHandle.Text = ""
DragHandle.Parent = MainFrame

-- Scrolling Frame with mobile-optimized scrolling
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -(isMobile and 120 or 100))
ScrollFrame.Position = UDim2.new(0, 10, 0, isMobile and 70 or 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = isMobile and 8 or 5
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
ScrollFrame.Parent = MainFrame

-- Mobile touch scrolling settings
if isMobile then
	ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
end

-- Make window draggable (works for both mouse and touch)
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart
local startPos

local function updatePosition(input)
	local delta
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		delta = input.Position - dragStart
	end
	
	if delta then
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end
end

DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		-- Visual feedback for mobile
		if isMobile then
			MainFrame.BackgroundTransparency = 0.05
		end
		
		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if isMobile then
					MainFrame.BackgroundTransparency = 0.1
				end
				connection:Disconnect()
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updatePosition(input)
	end
end)

-- Create mobile-friendly toggle button
local yPosition = 0
local toggleSpacing = isMobile and 55 or 45

local function CreateMobileToggle(name, defaultValue)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 : 40)
	toggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Parent = ScrollFrame
	
	-- Larger touch area for mobile
	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0.7, 0, 1, 0)
	toggleButton.Position = UDim2.new(0, 0, 0, 0)
	toggleButton.Text = name
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.TextSize = isMobile and 18 or 16
	toggleButton.Font = Enum.Font.Gotham
	toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
	toggleButton.AutoButtonColor = false
	toggleButton.Parent = toggleFrame
	
	-- Rounded corners for mobile
	if isMobile then
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = toggleButton
	end
	
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0.3, 0, 1, 0)
	statusLabel.Position = UDim2.new(0.7, 0, 0, 0)
	statusLabel.Text = defaultValue and "ON" or "OFF"
	statusLabel.TextColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
	statusLabel.TextSize = isMobile and 18 or 16
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.BackgroundTransparency = 1
	statusLabel.Parent = toggleFrame
	
	local value = defaultValue
	
	-- Touch/mouse feedback
	toggleButton.MouseButton1Down:Connect(function()
		if isMobile then
			toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
		end
	end)
	
	toggleButton.MouseButton1Click:Connect(function()
		value = not value
		toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
		statusLabel.Text = value and "ON" or "OFF"
		statusLabel.TextColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
		
		-- Store in global variable
		_G[name:gsub("%s+", "")] = value
		
		-- Mobile vibration feedback (if supported)
		if isMobile and game:GetService("UserInputService").VibrationEnabled then
			game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Large, 0.1)
			task.wait(0.1)
			game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Large, 0)
		end
		
		-- Show notification
		game.StarterGui:SetCore("SendNotification", {
			Title = name,
			Text = value and "Enabled" or "Disabled",
			Duration = 1,
			Icon = "rbxassetid://6031068420"
		})
	end)
	
	toggleButton.MouseButton1Up:Connect(function()
		if isMobile then
			toggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
		end
	end)
	
	yPosition = yPosition + toggleSpacing
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
	
	-- Initialize global variable
	_G[name:gsub("%s+", "")] = defaultValue
	
	return toggleButton
end

-- Create mobile-friendly slider
local function CreateMobileSlider(name, min, max, defaultValue)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 80 : 70)
	sliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Parent = ScrollFrame
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, isMobile and 25 : 20)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextSize = isMobile and 18 : 16
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = sliderFrame
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.3, 0, 0, isMobile and 25 : 20)
	valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
	valueLabel.Text = tostring(defaultValue)
	valueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
	valueLabel.TextSize = isMobile and 18 : 16
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = sliderFrame
	
	-- Larger slider track for mobile touch
	local sliderTrack = Instance.new("TextButton")
	sliderTrack.Size = UDim2.new(1, 0, 0, isMobile and 16 : 12)
	sliderTrack.Position = UDim2.new(0, 0, 0, isMobile and 30 : 25)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Text = ""
	sliderTrack.AutoButtonColor = false
	sliderTrack.Parent = sliderFrame
	
	-- Rounded corners for mobile
	if isMobile then
		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 6)
		trackCorner.Parent = sliderTrack
	end
	
	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderTrack
	
	if isMobile then
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 6)
		fillCorner.Parent = sliderFill
	end
	
	local draggingSlider = false
	
	local function updateSlider(input)
		local relativeX
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
		end
		
		if relativeX then
			local value = math.floor(min + (max - min) * math.clamp(relativeX, 0, 1))
			
			sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			valueLabel.Text = tostring(value)
			_G[name:gsub("%s+", "")] = value
			
			-- Mobile vibration feedback for slider
			if isMobile and game:GetService("UserInputService").VibrationEnabled then
				game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Small, 0.05)
			end
		end
	end
	
	sliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			updateSlider(input)
			
			-- Visual feedback
			if isMobile then
				sliderTrack.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			end
		end
	end)
	
	sliderTrack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
			if isMobile then
				sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Small, 0)
			end
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)
	
	yPosition = yPosition + (isMobile and 85 : 75)
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
	
	-- Initialize global variable
	_G[name:gsub("%s+", "")] = defaultValue
	
	return sliderFrame
end

-- CREATE ALL MOBILE-FRIENDLY TOGGLES

-- Shooting Features
CreateMobileToggle("Auto Shoot", false)
CreateMobileToggle("Perfect Accuracy", false)
CreateMobileToggle("Always Green", false)
CreateMobileSlider("Shoot Delay", 0.5, 5, 1)

-- Movement Features
CreateMobileToggle("Speed Boost", false)
CreateMobileSlider("Speed Amount", 16, 100, 50)
CreateMobileToggle("Infinite Stamina", false)

-- Dunking Features
CreateMobileToggle("Auto Dunk", false)
CreateMobileSlider("Dunk Range", 5, 30, 10)

-- Defense Features
CreateMobileToggle("Auto Block", false)
CreateMobileToggle("Auto Steal", false)
CreateMobileSlider("Steal Range", 5, 30, 10)

-- Visual Features
CreateMobileToggle("Player ESP", false)
CreateMobileToggle("Ball ESP", false)

-- Misc Features
CreateMobileToggle("No Fouls", false)
CreateMobileToggle("Instant Pass", false)
CreateMobileToggle("Auto Rebound", false)

-- Close/Minimize buttons (bigger for mobile)
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Size = UDim2.new(1, -20, 0, isMobile and 50 : 40)
ButtonFrame.Position = UDim2.new(0, 10, 1, -(isMobile and 55 : 45))
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = MainFrame

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.48, 0, 1, 0)
CloseButton.Position = UDim2.new(0, 0, 0, 0)
CloseButton.Text = isMobile and "❌ Close" : "Close"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = isMobile and 18 : 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.AutoButtonColor = false
CloseButton.Parent = ButtonFrame

if isMobile then
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = CloseButton
end

CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Hide button (for mobile to save screen space)
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0.48, 0, 1, 0)
HideButton.Position = UDim2.new(0.52, 0, 0, 0)
HideButton.Text = isMobile and "⬇️ Hide" : "Hide"
HideButton.TextColor3 = Color3.new(1, 1, 1)
HideButton.TextSize = isMobile and 18 : 16
HideButton.Font = Enum.Font.GothamBold
HideButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
HideButton.AutoButtonColor = false
HideButton.Parent = ButtonFrame

if isMobile then
	local hideCorner = Instance.new("UICorner")
	hideCorner.CornerRadius = UDim.new(0, 8)
	hideCorner.Parent = HideButton
end

local isHidden = false
HideButton.MouseButton1Click:Connect(function()
	isHidden = not isHidden
	MainFrame.Visible = not isHidden
	HideButton.Text = isHidden and (isMobile and "⬆️ Show" : "Show") : (isMobile and "⬇️ Hide" : "Hide")
	
	if isMobile and game:GetService("UserInputService").VibrationEnabled then
		game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Small, 0.1)
		task.wait(0.1)
		game:GetService("UserInputService"):SetMotor(Enum.VibrationMotor.Small, 0)
	end
end)

-- Show/hide toggle button in corner when hidden
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = isMobile and UDim2.new(0, 80, 0, 80) or UDim2.new(0, 60, 0, 60)
ToggleButton.Position = isMobile and UDim2.new(1, -90, 1, -90) or UDim2.new(1, -70, 1, -70)
ToggleButton.Text = "🏀"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = isMobile and 32 : 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

if isMobile then
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = ToggleButton
end

ToggleButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	ToggleButton.Visible = false
	isHidden = false
	HideButton.Text = isMobile and "⬇️ Hide" : "Hide"
end)

HideButton.MouseButton1Click:Connect(function()
	if isHidden then
		ToggleButton.Visible = true
	end
end)

-- Initial notification
game.StarterGui:SetCore("SendNotification", {
	Title = "🏀 Mobile Cheats Loaded",
	Text = isMobile and "Touch-friendly UI ready!" : "UI loaded successfully!",
	Duration = 3,
	Icon = "rbxassetid://6031068420"
})

-- Auto-adjust for different screen sizes
if isMobile then
	game:GetService("GuiService"):SetGuiInsetSafetyPadding(0, 0, 0, 0)
end

print("Mobile Basketball Cheats UI loaded!")
print("Device: " .. (isMobile and "Mobile/Touch" : "Desktop"))
