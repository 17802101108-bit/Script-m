local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local aimEnabled = true
local aimKey = Enum.UserInputType.MouseButton2
local targetPartName = "Head"
local AIM_SMOOTH = 30
local AIM_SMOOTH_MIN = 1
local AIM_SMOOTH_MAX = 100
local FOV_RADIUS = 120
local FOV_MIN = 20
local FOV_MAX = 300
local showFOV = true
local AIM_MAX_DISTANCE = 300
local wallCheck = true
local isAiming = false
local changingBind = false
local currentTarget = nil

-- 窗口显隐热键
local windowToggleKey = Enum.KeyCode.F1
local changingWindowKey = false

-- FOV圆圈渲染
local hasDrawing, Drawing = pcall(function() return Drawing end)
local fovCircle
if hasDrawing then
	fovCircle = Drawing.new("Circle")
	fovCircle.Thickness = 1
	fovCircle.Filled = false
	fovCircle.Color = Color3.new(1,1,1)
	fovCircle.Transparency = 1
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 340) -- 加高容纳FOV滑块
MainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromHex("#181818")
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local r6 = Instance.new("UICorner")
r6.CornerRadius = UDim.new(0, 6)
local r4 = Instance.new("UICorner")
r4.CornerRadius = UDim.new(0, 4)

local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(0.86, 0, 0, 32)
AimToggle.Position = UDim2.new(0.07, 0, 0.03, 0)
AimToggle.BackgroundColor3 = Color3.fromHex("#2ecc71")
AimToggle.TextColor3 = Color3.new(1,1,1)
AimToggle.Text = "AIM: ON"
AimToggle.TextSize = 15
AimToggle.Parent = MainFrame
r6:Clone().Parent = AimToggle

-- 窗口隐藏按键设置
local WindowToggleBtn = Instance.new("TextButton")
WindowToggleBtn.Size = UDim2.new(0.86, 0, 0, 28)
WindowToggleBtn.Position = UDim2.new(0.07, 0, 0.14, 0)
WindowToggleBtn.BackgroundColor3 = Color3.fromHex("#444444")
WindowToggleBtn.TextColor3 = Color3.new(1,1,1)
WindowToggleBtn.Text = "Window Hotkey: F1"
WindowToggleBtn.TextSize = 12
WindowToggleBtn.Parent = MainFrame
r4:Clone().Parent = WindowToggleBtn

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.86, 0, 0, 20)
TargetLabel.Position = UDim2.new(0.07, 0, 0.24, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target Part"
TargetLabel.TextColor3 = Color3.fromHex("#cccccc")
TargetLabel.TextSize = 13
TargetLabel.Parent = MainFrame

local HeadBtn = Instance.new("TextButton")
HeadBtn.Size = UDim2.new(0.26, 0, 0, 26)
HeadBtn.Position = UDim2.new(0.07, 0, 0.31, 0)
HeadBtn.BackgroundColor3 = Color3.fromHex("#34495e")
HeadBtn.Text = "Head"
HeadBtn.TextColor3 = Color3.new(1,1,1)
HeadBtn.TextSize = 12
HeadBtn.Parent = MainFrame
r4:Clone().Parent = HeadBtn

local TorsoBtn = Instance.new("TextButton")
TorsoBtn.Size = UDim2.new(0.26, 0, 0, 26)
TorsoBtn.Position = UDim2.new(0.37, 0, 0.31, 0)
TorsoBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
TorsoBtn.Text = "Torso"
TorsoBtn.TextColor3 = Color3.new(1,1,1)
TorsoBtn.TextSize = 12
TorsoBtn.Parent = MainFrame
r4:Clone().Parent = TorsoBtn

local RootBtn = Instance.new("TextButton")
RootBtn.Size = UDim2.new(0.26, 0, 0, 26)
RootBtn.Position = UDim2.new(0.67, 0, 0.31, 0)
RootBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
RootBtn.Text = "Root"
RootBtn.TextColor3 = Color3.new(1,1,1)
RootBtn.TextSize = 12
RootBtn.Parent = MainFrame
r4:Clone().Parent = RootBtn

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.86, 0, 0, 20)
KeyLabel.Position = UDim2.new(0.07, 0, 0.42, 0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Aim Key"
KeyLabel.TextColor3 = Color3.fromHex("#cccccc")
KeyLabel.TextSize = 13
KeyLabel.Parent = MainFrame

local KeyBindButton = Instance.new("TextButton")
KeyBindButton.Size = UDim2.new(0.86, 0, 0, 30)
KeyBindButton.Position = UDim2.new(0.07, 0, 0.49, 0)
KeyBindButton.BackgroundColor3 = Color3.fromHex("#2d3d3d")
KeyBindButton.Text = "RightMouse"
KeyBindButton.TextColor3 = Color3.new(1,1,1)
KeyBindButton.TextSize = 14
KeyBindButton.Parent = MainFrame
r4:Clone().Parent = KeyBindButton

local WallCheckBtn = Instance.new("TextButton")
WallCheckBtn.Size = UDim2.new(0.4, 0, 0, 26)
WallCheckBtn.Position = UDim2.new(0.07, 0, 0.61, 0)
WallCheckBtn.BackgroundColor3 = Color3.fromHex("#3498db")
WallCheckBtn.Text = "Wallcheck: ON"
WallCheckBtn.TextColor3 = Color3.new(1,1,1)
WallCheckBtn.TextSize = 12
WallCheckBtn.Parent = MainFrame
r4:Clone().Parent = WallCheckBtn

local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(0.4, 0, 0, 26)
FOVToggle.Position = UDim2.new(0.53, 0, 0.61, 0)
FOVToggle.BackgroundColor3 = Color3.fromHex("#3498db")
FOVToggle.Text = "FOV: ON"
FOVToggle.TextColor3 = Color3.new(1,1,1)
FOVToggle.TextSize = 12
FOVToggle.Parent = MainFrame
r4:Clone().Parent = FOVToggle

-- 自瞄平滑滑块
local AimSpeedLabel = Instance.new("TextLabel")
AimSpeedLabel.Size = UDim2.new(0.86, 0, 0, 20)
AimSpeedLabel.Position = UDim2.new(0.07, 0, 0.70, 0)
AimSpeedLabel.BackgroundTransparency = 1
AimSpeedLabel.Text = "Aim Smooth"
AimSpeedLabel.TextColor3 = Color3.fromHex("#cccccc")
AimSpeedLabel.TextSize = 13
AimSpeedLabel.Parent = MainFrame

local AimSpeedSliderBg = Instance.new("Frame")
AimSpeedSliderBg.Size = UDim2.new(0.86, 0, 0, 22)
AimSpeedSliderBg.Position = UDim2.new(0.07, 0, 0.77, 0)
AimSpeedSliderBg.BackgroundColor3 = Color3.fromHex("#2b2b2b")
AimSpeedSliderBg.Parent = MainFrame
r4:Clone().Parent = AimSpeedSliderBg

local AimSpeedSliderFill = Instance.new("Frame")
AimSpeedSliderFill.Size = UDim2.new((AIM_SMOOTH - AIM_SMOOTH_MIN) / (AIM_SMOOTH_MAX - AIM_SMOOTH_MIN), 0, 1, 0)
AimSpeedSliderFill.BackgroundColor3 = Color3.fromHex("#2ecc71")
AimSpeedSliderFill.Parent = AimSpeedSliderBg
r4:Clone().Parent = AimSpeedSliderFill

local AimSpeedValue = Instance.new("TextLabel")
AimSpeedValue.Size = UDim2.new(0.86, 0, 0, 18)
AimSpeedValue.Position = UDim2.new(0.07, 0, 0.83, 0)
AimSpeedValue.BackgroundTransparency = 1
AimSpeedValue.Text = "Smooth: " .. AIM_SMOOTH
AimSpeedValue.TextColor3 = Color3.fromHex("#bbbbbb")
AimSpeedValue.TextSize = 11
AimSpeedValue.Parent = MainFrame

-- 【新增FOV半径滑块】
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.86, 0, 0, 20)
FovLabel.Position = UDim2.new(0.07, 0, 0.87, 0)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Radius"
FovLabel.TextColor3 = Color3.fromHex("#cccccc")
FovLabel.TextSize = 13
FovLabel.Parent = MainFrame

local FovSliderBg = Instance.new("Frame")
FovSliderBg.Size = UDim2.new(0.86, 0, 0, 22)
FovSliderBg.Position = UDim2.new(0.07, 0, 0.93, 0)
FovSliderBg.BackgroundColor3 = Color3.fromHex("#2b2b2b")
FovSliderBg.Parent = MainFrame
r4:Clone().Parent = FovSliderBg

local FovSliderFill = Instance.new("Frame")
FovSliderFill.Size = UDim2.new((FOV_RADIUS - FOV_MIN)/(FOV_MAX-FOV_MIN), 0,1,0)
FovSliderFill.BackgroundColor3 = Color3.fromHex("#3498db")
FovSliderFill.Parent = FovSliderBg
r4:Clone().Parent = FovSliderFill

local dragActive = false
local slidingAimSpeed = false
local slidingFov = false

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragActive = true
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragActive and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Delta
		MainFrame.Position += UDim2.fromOffset(delta.X, delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragActive = false
		slidingAimSpeed = false
		slidingFov = false
	end
end)

AimToggle.MouseButton1Click:Connect(function()
	aimEnabled = not aimEnabled
	AimToggle.Text = aimEnabled and "AIM: ON" or "AIM: OFF"
	AimToggle.BackgroundColor3 = aimEnabled and Color3.fromHex("#2ecc71") or Color3.fromHex("#e74c3c")
end)

WindowToggleBtn.MouseButton1Click:Connect(function()
	changingWindowKey = true
	WindowToggleBtn.Text = "Press any key..."
end)

WallCheckBtn.MouseButton1Click:Connect(function()
	wallCheck = not wallCheck
	WallCheckBtn.Text = wallCheck and "Wallcheck: ON" or "Wallcheck: OFF"
	WallCheckBtn.BackgroundColor3 = wallCheck and Color3.fromHex("#3498db") or Color3.fromHex("#636e72")
end)

FOVToggle.MouseButton1Click:Connect(function()
	showFOV = not showFOV
	FOVToggle.Text = showFOV and "FOV: ON" or "FOV: OFF"
	FOVToggle.BackgroundColor3 = showFOV and Color3.fromHex("#3498db") or Color3.fromHex("#636e72")
end)

HeadBtn.MouseButton1Click:Connect(function()
	targetPartName = "Head"
	HeadBtn.BackgroundColor3 = Color3.fromHex("#34495e")
	TorsoBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
	RootBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
end)

TorsoBtn.MouseButton1Click:Connect(function()
	targetPartName = "UpperTorso"
	HeadBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
	TorsoBtn.BackgroundColor3 = Color3.fromHex("#34495e")
	RootBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
end)

RootBtn.MouseButton1Click:Connect(function()
	targetPartName = "HumanoidRootPart"
	HeadBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
	TorsoBtn.BackgroundColor3 = Color3.fromHex("#2c3e50")
	RootBtn.BackgroundColor3 = Color3.fromHex("#34495e")
end)

KeyBindButton.MouseButton1Click:Connect(function()
	changingBind = true
	KeyBindButton.Text = "Press any key..."
end)

AimSpeedSliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		slidingAimSpeed = true
		dragActive = false
	end
end)

FovSliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		slidingFov = true
		dragActive = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if slidingAimSpeed then
		local x = input.Position.X - AimSpeedSliderBg.AbsolutePosition.X
		local scale = math.clamp(x / AimSpeedSliderBg.AbsoluteSize.X, 0, 1)
		AIM_SMOOTH = math.floor(AIM_SMOOTH_MIN + (AIM_SMOOTH_MAX - AIM_SMOOTH_MIN) * scale)
		AimSpeedSliderFill.Size = UDim2.new(scale, 0, 1, 0)
		AimSpeedValue.Text = "Smooth: " .. AIM_SMOOTH
	end
	if slidingFov then
		local x = input.Position.X - FovSliderBg.AbsolutePosition.X
		local scale = math.clamp(x / FovSliderBg.AbsoluteSize.X, 0,1)
		FOV_RADIUS = math.floor(FOV_MIN + (FOV_MAX-FOV_MIN)*scale)
		FovSliderFill.Size = UDim2.new(scale,0,1,0)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if changingWindowKey then
		changingWindowKey = false
		if input.UserInputType == Enum.UserInputType.Keyboard then
			windowToggleKey = input.KeyCode
			WindowToggleBtn.Text = "Window Hotkey: "..input.KeyCode.Name
		end
		return
	end

	if input.KeyCode == windowToggleKey then
		MainFrame.Visible = not MainFrame.Visible
		return
	end

	if changingBind then
		changingBind = false
		if input.UserInputType == Enum.UserInputType.Keyboard then
			aimKey = input.KeyCode
			KeyBindButton.Text = input.KeyCode.Name
		else
			aimKey = input.UserInputType
			KeyBindButton.Text = "Mouse " .. tostring(aimKey):sub(-1)
		end
		return
	end

	if aimEnabled and (input.KeyCode == aimKey or input.UserInputType == aimKey) then
		isAiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == aimKey or input.UserInputType == aimKey then
		isAiming = false
		currentTarget = nil
	end
end)

local function isVisible(targetPart)
	if not targetPart then return false end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {char, targetPart.Parent}
	local result = Workspace:Raycast(root.Position, targetPart.Position - root.Position, rayParams)
	return result == nil
end

local function getClosestTargetInFOV()
	local best = nil
	local min = math.huge
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local cen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for _, plr in Players:GetPlayers() do
		if plr == player then continue end
		local c = plr.Character
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		local part = c and c:FindFirstChild(targetPartName)
		if not hum or not part or hum.Health <= 0 then continue end
		if wallCheck and not isVisible(part) then
			continue
		end
		local dist = (part.Position - root.Position).Magnitude
		if dist > AIM_MAX_DISTANCE then continue end
		local vp, on = Camera:WorldToViewportPoint(part.Position)
		if not on then continue end
		local d = (Vector2.new(vp.X, vp.Y) - cen).Magnitude
		if d < FOV_RADIUS and d < min then
			min = d
			best = part
		end
	end
	return best
end

RunService.RenderStepped:Connect(function(dt)
	-- 更新FOV圆圈
	if hasDrawing then
		fovCircle.Visible = showFOV
		fovCircle.Position = Camera.ViewportSize / 2
		fovCircle.Radius = FOV_RADIUS
	end

	if not aimEnabled or not isAiming then return end
	local t = getClosestTargetInFOV()
	if t then
		local cf = CFrame.lookAt(Camera.CFrame.Position, t.Position)
		Camera.CFrame = Camera.CFrame:Lerp(cf, dt * AIM_SMOOTH)
	end
end)
