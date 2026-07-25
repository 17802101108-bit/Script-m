local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 设置项
local espEnabled = true
local showBox = true
local showSkeleton = true
local showName = true
local showDistance = true
local boxColor = Color3.new(0, 1, 1)
local skeletonColor = Color3.new(1, 0, 0)
local HideGuiKey = Enum.KeyCode.F1
local isWaitingKey = false

-- UI容器
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromHex("#181818")
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- 按钮创建辅助
local function MakeButton(parent, pos, size, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.TextSize = 12
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    return btn
end

-- UI按钮
local EspToggle = MakeButton(MainFrame, UDim2.new(0.07,0,0.04,0),UDim2.new(0.86,0,0,32),"ESP: ON",Color3.fromHex("#2ecc71"))
local BoxBtn = MakeButton(MainFrame, UDim2.new(0.07,0,0.16,0),UDim2.new(0.4,0,0,26),"Box: ON",Color3.fromHex("#3498db"))
local SkeletonBtn = MakeButton(MainFrame, UDim2.new(0.53,0,0.16,0),UDim2.new(0.4,0,0,26),"Skeleton: ON",Color3.fromHex("#3498db"))
local NameBtn = MakeButton(MainFrame, UDim2.new(0.07,0,0.26,0),UDim2.new(0.4,0,0,26),"Name: ON",Color3.fromHex("#3498db"))
local DistBtn = MakeButton(MainFrame, UDim2.new(0.53,0,0.26,0),UDim2.new(0.4,0,0,26),"Distance: ON",Color3.fromHex("#3498db"))
local KeyBindBtn = MakeButton(MainFrame, UDim2.new(0.07,0,0.36,0),UDim2.new(0.86,0,0,28),"Hide Key: F1 | Click to change",Color3.fromHex("#9b59b6"))

local TipLabel = Instance.new("TextLabel")
TipLabel.Size = UDim2.new(0.86, 0, 0, 30)
TipLabel.Position = UDim2.new(0.07, 0, 0.48, 0)
TipLabel.BackgroundTransparency = 1
TipLabel.Text = "R6 & R15 Skeleton Supported"
TipLabel.TextColor3 = Color3.new(0.6,0.6,0.6)
TipLabel.TextSize = 11
TipLabel.Parent = MainFrame

-- 窗口拖拽
local dragging = false
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        MainFrame.Position += UDim2.fromOffset(input.Delta.X, input.Delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- 按钮功能绑定
EspToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    EspToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    EspToggle.BackgroundColor3 = espEnabled and Color3.fromHex("#2ecc71") or Color3.fromHex("#e74c3c")
end)
BoxBtn.MouseButton1Click:Connect(function()
    showBox = not showBox
    BoxBtn.Text = showBox and "Box: ON" or "Box: OFF"
end)
SkeletonBtn.MouseButton1Click:Connect(function()
    showSkeleton = not showSkeleton
    SkeletonBtn.Text = showSkeleton and "Skeleton: ON" or "Skeleton: OFF"
end)
NameBtn.MouseButton1Click:Connect(function()
    showName = not showName
    NameBtn.Text = showName and "Name: ON" or "Name: OFF"
end)
DistBtn.MouseButton1Click:Connect(function()
    showDistance = not showDistance
    DistBtn.Text = showDistance and "Distance: ON" or "Distance: OFF"
end)

-- UI内改快捷键
KeyBindBtn.MouseButton1Click:Connect(function()
    if isWaitingKey then return end
    isWaitingKey = true
    KeyBindBtn.Text = "Press any key..."
    KeyBindBtn.BackgroundColor3 = Color3.new(1,0,0)
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            HideGuiKey = input.KeyCode
            KeyBindBtn.Text = "Hide Key: "..input.KeyCode.Name.." | Click to change"
            KeyBindBtn.BackgroundColor3 = Color3.fromHex("#9b59b6")
            isWaitingKey = false
            connection:Disconnect()
        end
    end)
end)

-- 切换窗口显示隐藏
UserInputService.InputBegan:Connect(function(input,gp)
    if gp or isWaitingKey then return end
    if input.KeyCode == HideGuiKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 创建绘制线条（骨骼专用）
local function NewLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.8
    line.Visible = false
    return line
end

-- 骨骼关节配对 R6 / R15
local SkeletonJoints = {
    R6 = {
        {"Head","Torso"},
        {"Torso","Left Arm"},{"Torso","Right Arm"},
        {"Torso","Left Leg"},{"Torso","Right Leg"}
    },
    R15 = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
    }
}

local cache = {}

-- ==============================================
-- 【残影修复核心函数】隐藏该玩家所有ESP
-- ==============================================
local function ClearPlayerESP(player)
    local data = cache[player]
    if not data then return end

    if data.Box then data.Box.Visible = false end
    if data.NameLabel then data.NameLabel.Visible = false end
    if data.DistLabel then data.DistLabel.Visible = false end
    for _, line in pairs(data.SkeletonLines or {}) do
        line.Visible = false
    end
end

-- 角色消失/重生时清理
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterRemoving:Connect(function()
        task.wait()
        ClearPlayerESP(plr)
    end)
end)

-- 玩家退出游戏时彻底清理
Players.PlayerRemoving:Connect(function(plr)
    ClearPlayerESP(plr)
    cache[plr] = nil
end)

RunService.RenderStepped:Connect(function()
    -- ==============================================
    -- 【关键修复】每一帧先隐藏所有人ESP，杜绝残影
    -- ==============================================
    for _, plr in pairs(Players:GetPlayers()) do
        ClearPlayerESP(plr)
    end

    -- 关闭ESP，直接返回
    if not espEnabled then
        return
    end

    -- 遍历所有玩家
    for _,Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Char = Player.Character
        if not Char or not Char:IsDescendantOf(Workspace) then continue end

        local Hum = Char:FindFirstChildOfClass("Humanoid")
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        if not Hum or not HRP or Hum.Health <= 0 then continue end

        local Data = cache[Player]
        if not Data then
            Data = {
                Box = nil,
                NameLabel = nil,
                DistLabel = nil,
                SkeletonLines = {}
            }
            cache[Player] = Data
        end

        -- ========== 【修复ESP方框大小】精准包围盒算法 ==========
        local minY, maxY = math.huge, -math.huge
        local parts = Char:GetChildren()
        for _,part in pairs(parts) do
            if part:IsA("BasePart") then
                minY = math.min(minY, part.Position.Y - part.Size.Y/2)
                maxY = math.max(maxY, part.Position.Y + part.Size.Y/2)
            end
        end

        local TopWorld = Vector3.new(HRP.Position.X, maxY, HRP.Position.Z)
        local BotWorld = Vector3.new(HRP.Position.X, minY, HRP.Position.Z)
        local TopScreen, TopOnScreen = Camera:WorldToViewportPoint(TopWorld)
        local BotScreen, BotOnScreen = Camera:WorldToViewportPoint(BotWorld)
        local onScreen = TopOnScreen and BotOnScreen

        if not onScreen then continue end

        local BoxHeight = math.abs(BotScreen.Y - TopScreen.Y)
        local BoxWidth = BoxHeight * 0.48
        local CenterX = (TopScreen.X + BotScreen.X)/2

        -- 绘制方框
        if showBox then
            if not Data.Box then
                local frame = Instance.new("Frame")
                frame.BackgroundTransparency = 1
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1.5
                stroke.Parent = frame
                frame.Parent = ScreenGui
                Data.Box = frame
            end
            Data.Box.Size = UDim2.fromOffset(BoxWidth, BoxHeight)
            Data.Box.Position = UDim2.fromOffset(CenterX - BoxWidth/2, TopScreen.Y)
            Data.Box.UIStroke.Color = boxColor
            Data.Box.Visible = true
        end

        -- 玩家名称
        if showName then
            if not Data.NameLabel then
                local lab = Instance.new("TextLabel")
                lab.BackgroundTransparency = 1
                lab.TextColor3 = Color3.new(1,1,1)
                lab.TextSize = 13
                lab.Size = UDim2.fromOffset(120,24)
                lab.Parent = ScreenGui
                Data.NameLabel = lab
            end
            Data.NameLabel.Text = Player.Name
            Data.NameLabel.Position = UDim2.fromOffset(CenterX - 60, TopScreen.Y - 22)
            Data.NameLabel.Visible = true
        end

        -- 距离文字
        if showDistance then
            if not Data.DistLabel then
                local lab = Instance.new("TextLabel")
                lab.BackgroundTransparency = 1
                lab.TextColor3 = Color3.new(1,1,1)
                lab.TextSize = 12
                lab.Size = UDim2.fromOffset(120,22)
                lab.Parent = ScreenGui
                Data.DistLabel = lab
            end
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - HRP.Position).Magnitude) or 0
            Data.DistLabel.Text = dist.." studs"
            Data.DistLabel.Position = UDim2.fromOffset(CenterX - 60, BotScreen.Y + 6)
            Data.DistLabel.Visible = true
        end

        -- ========== 【骨骼绘制 R6/R15 可用】 ==========
        local jointList
        if Hum.RigType == Enum.HumanoidRigType.R6 then
            jointList = SkeletonJoints.R6
        else
            jointList = SkeletonJoints.R15
        end

        -- 初始化线条数量
        while #Data.SkeletonLines < #jointList do
            table.insert(Data.SkeletonLines, NewLine())
        end

        for i,jointPair in pairs(jointList) do
            local partA = Char:FindFirstChild(jointPair[1])
            local partB = Char:FindFirstChild(jointPair[2])
            local line = Data.SkeletonLines[i]

            if partA and partB and showSkeleton then
                local posA, aOn = Camera:WorldToViewportPoint(partA.Position)
                local posB, bOn = Camera:WorldToViewportPoint(partB.Position)
                if aOn and bOn then
                    line.From = Vector2.new(posA.X, posA.Y)
                    line.To = Vector2.new(posB.X, posB.Y)
                    line.Color = skeletonColor
                    line.Visible = true
                end
            end
        end
    end
end)
