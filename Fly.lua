--==================================================
-- Mobile Flight Controller
-- Roblox Luau
-- 用于自己的 Roblox 游戏项目
-- 安装位置：
-- StarterPlayer > StarterPlayerScripts > LocalScript
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
--========================
-- 配置
--========================
local MIN_SPEED = 10
local MAX_SPEED = 200
local DEFAULT_SPEED = 70
local currentSpeed = DEFAULT_SPEED
local flying = false
local ascendHeld = false
local descendHeld = false
local character
local humanoid
local root
local attachment
local linearVelocity
local alignOrientation
local heartbeatConnection
local oldAutoRotate
local oldPlatformStand
local savedWalkSpeed
local savedJumpPower
local savedJumpHeight
local savedUseJumpPower
--========================
-- 创建 UI
--========================
local oldGui = playerGui:FindFirstChild("MobileFlightGui")
if oldGui then
    oldGui:Destroy()
end
local gui = Instance.new("ScreenGui")
gui.Name = "MobileFlightGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = playerGui
local panel = Instance.new("Frame")
panel.Name = "FlightPanel"
panel.Size = UDim2.fromOffset(230, 275)
panel.Position = UDim2.new(1, -245, 0.5, -138)
panel.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(85, 150, 255)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel
local function makeLabel(name, text, size, position)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = panel
    return label
end
local function makeButton(name, text, size, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(43, 53, 73)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button
    return button
end
local title = makeLabel(
    "Title",
    "FLIGHT CONTROL",
    UDim2.new(1, -20, 0, 28),
    UDim2.fromOffset(10, 8)
)
local toggleButton = makeButton(
    "FlyToggle",
    "FLY: OFF",
    UDim2.new(1, -20, 0, 38),
    UDim2.fromOffset(10, 42)
)
local speedLabel = makeLabel(
    "SpeedLabel",
    "Speed: 70",
    UDim2.new(1, -20, 0, 24),
    UDim2.fromOffset(10, 87)
)
--========================
-- 速度滑块
--========================
local sliderBackground = Instance.new("Frame")
sliderBackground.Name = "SliderBackground"
sliderBackground.Size = UDim2.new(1, -30, 0, 12)
sliderBackground.Position = UDim2.fromOffset(15, 119)
sliderBackground.BackgroundColor3 = Color3.fromRGB(65, 73, 91)
sliderBackground.BorderSizePixel = 0
sliderBackground.Active = true
sliderBackground.Parent = panel
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBackground
local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(
    (currentSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED),
    0, 1, 0
)
sliderFill.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBackground
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill
local sliderKnob = Instance.new("TextButton")
sliderKnob.Name = "SliderKnob"
sliderKnob.Text = ""
sliderKnob.Size = UDim2.fromOffset(22, 22)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(
    (currentSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED),
    0, 0.5, 0
)
sliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBackground
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob
--========================
-- 数字输入
--========================
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.fromOffset(125, 34)
speedInput.Position = UDim2.fromOffset(10, 147)
speedInput.BackgroundColor3 = Color3.fromRGB(43, 53, 73)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.PlaceholderText = "10 - 200"
speedInput.PlaceholderColor3 = Color3.fromRGB(180, 185, 195)
speedInput.Text = tostring(currentSpeed)
speedInput.TextScaled = true
speedInput.ClearTextOnFocus = false
speedInput.Font = Enum.Font.Gotham
speedInput.BorderSizePixel = 0
speedInput.Parent = panel
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = speedInput
local setButton = makeButton(
    "SetSpeed",
    "SET",
    UDim2.fromOffset(75, 34),
    UDim2.fromOffset(145, 147)
)
--========================
-- 上升 / 下降按钮
--========================
local upButton = makeButton(
    "Ascend",
    "▲ UP",
    UDim2.fromOffset(95, 38),
    UDim2.fromOffset(10, 191)
)
local downButton = makeButton(
    "Descend",
    "▼ DOWN",
    UDim2.fromOffset(95, 38),
    UDim2.fromOffset(125, 191)
)
local helpLabel = makeLabel(
    "Help",
    "Move: Joystick + Camera",
    UDim2.new(1, -20, 0, 25),
    UDim2.fromOffset(10, 237)
)
helpLabel.Font = Enum.Font.Gotham
helpLabel.TextColor3 = Color3.fromRGB(185, 195, 215)
--========================
-- 同步速度显示
--========================
local function setSpeed(value)
    value = tonumber(value)
    if not value or value ~= value then
        return
    end
    currentSpeed = math.floor(
        math.clamp(value, MIN_SPEED, MAX_SPEED)
    )
    local fraction =
        (currentSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    speedLabel.Text = "Speed: " .. currentSpeed
    speedInput.Text = tostring(currentSpeed)
    sliderFill.Size = UDim2.new(fraction, 0, 1, 0)
    sliderKnob.Position = UDim2.new(fraction, 0, 0.5, 0)
end
local draggingSlider = false
local function updateSlider(inputPositionX)
    local width = sliderBackground.AbsoluteSize.X
    if width <= 0 then
        return
    end
    local relativeX =
        inputPositionX - sliderBackground.AbsolutePosition.X
    local fraction = math.clamp(relativeX / width, 0, 1)
    setSpeed(
        MIN_SPEED + fraction * (MAX_SPEED - MIN_SPEED)
    )
end
sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        updateSlider(input.Position.X)
    end
end)
sliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        updateSlider(input.Position.X)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider then
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)
setButton.Activated:Connect(function()
    setSpeed(speedInput.Text)
end)
speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        setSpeed(speedInput.Text)
    end
end)
--========================
-- 角色管理
--========================
local function getCharacter()
    character = player.Character
        or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end
local function clearFlightObjects()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    if linearVelocity then
        linearVelocity:Destroy()
        linearVelocity = nil
    end
    if alignOrientation then
        alignOrientation:Destroy()
        alignOrientation = nil
    end
    if attachment then
        attachment:Destroy()
        attachment = nil
    end
end
--========================
-- 关闭飞行
--========================
local function stopFlying()
    flying = false
    ascendHeld = false
    descendHeld = false
    clearFlightObjects()
    if humanoid and humanoid.Parent then
        humanoid.AutoRotate =
            oldAutoRotate ~= nil and oldAutoRotate or true
        humanoid.PlatformStand =
            oldPlatformStand ~= nil and oldPlatformStand or false
        if savedWalkSpeed then
            humanoid.WalkSpeed = savedWalkSpeed
        end
        if savedUseJumpPower ~= nil then
            humanoid.UseJumpPower = savedUseJumpPower
        end
        if savedJumpPower then
            humanoid.JumpPower = savedJumpPower
        end
        if savedJumpHeight then
            humanoid.JumpHeight = savedJumpHeight
        end
        if humanoid.Health > 0 then
            humanoid:ChangeState(
                Enum.HumanoidStateType.GettingUp
            )
        end
    end
    toggleButton.Text = "FLY: OFF"
    toggleButton.BackgroundColor3 =
        Color3.fromRGB(43, 53, 73)
end
--========================
-- 开启飞行
--========================
local function startFlying()
    getCharacter()
    if not humanoid
        or not root
        or humanoid.Health <= 0 then
        return
    end
    clearFlightObjects()
    flying = true
    oldAutoRotate = humanoid.AutoRotate
    oldPlatformStand = humanoid.PlatformStand
    savedWalkSpeed = humanoid.WalkSpeed
    savedUseJumpPower = humanoid.UseJumpPower
    savedJumpPower = humanoid.JumpPower
    savedJumpHeight = humanoid.JumpHeight
    humanoid.AutoRotate = false
    humanoid.PlatformStand = false
    attachment = Instance.new("Attachment")
    attachment.Name = "FlightAttachment"
    attachment.Parent = root
    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "FlightVelocity"
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    linearVelocity.VectorVelocity = Vector3.zero
    linearVelocity.ForceLimitsEnabled = false
    linearVelocity.Parent = root
    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Name = "FlightOrientation"
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode =
        Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.Responsiveness = 15
    alignOrientation.MaxTorque = 1000000
    alignOrientation.Parent = root
    humanoid:ChangeState(
        Enum.HumanoidStateType.Physics
    )
    toggleButton.Text = "FLY: ON"
    toggleButton.BackgroundColor3 =
        Color3.fromRGB(25, 135, 85)
    heartbeatConnection = RunService.RenderStepped:Connect(function()
        if not flying
            or not character
            or not character.Parent
            or not root
            or not root.Parent
            or not humanoid
            or humanoid.Health <= 0 then
            stopFlying()
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        -- 摄像机的完整视线，包含上下俯仰角
        local look = camera.CFrame.LookVector
        -- 摄像机水平前方
        local flatForward = Vector3.new(
            look.X,
            0,
            look.Z
        )
        if flatForward.Magnitude > 0.001 then
            flatForward = flatForward.Unit
        else
            flatForward = Vector3.new(0, 0, -1)
        end
        -- 摄像机右方
        local flatRight = Vector3.new(
            flatForward.Z,
            0,
            -flatForward.X
        )
        -- Roblox 默认移动摇杆方向
        local move = humanoid.MoveDirection
        -- 将移动方向转换成摄像机相对方向
        local forwardAmount = move:Dot(flatForward)
        local rightAmount = move:Dot(flatRight)
        -- 前后移动会沿摄像机视线飞行
        local direction =
            look * forwardAmount
            + flatRight * rightAmount
        -- 额外的上升 / 下降控制
        local verticalInput =
            (ascendHeld and 1 or 0)
            - (descendHeld and 1 or 0)
        direction = direction
            + Vector3.new(0, verticalInput, 0)
        if direction.Magnitude > 1 then
            direction = direction.Unit
        end
        linearVelocity.VectorVelocity =
            direction * currentSpeed
        -- 角色朝向摄像机的水平朝向
        alignOrientation.CFrame =
            CFrame.lookAt(
                Vector3.zero,
                flatForward,
                Vector3.yAxis
            )
    end)
end
--========================
-- 按钮事件
--========================
toggleButton.Activated:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)
local function bindHold(button, setter)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(true)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setter(false)
        end
    end)
end
bindHold(upButton, function(value)
    ascendHeld = value
end)
bindHold(downButton, function(value)
    descendHeld = value
end)
--========================
-- 焦点与重生处理
--========================
UserInputService.WindowFocusReleased:Connect(function()
    ascendHeld = false
    descendHeld = false
    draggingSlider = false
end)
player.CharacterAdded:Connect(function(newCharacter)
    stopFlying()
    character = newCharacter
    humanoid = nil
    root = nil
    task.wait(0.25)
    if player.Character == newCharacter then
        getCharacter()
    end
end)
-- 初始化
setSpeed(DEFAULT_SPEED)
getCharacter()
