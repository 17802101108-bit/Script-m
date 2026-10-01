-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
-- [[ End Rscripts Risk Notice ]]
--// FULL SKIDWARE + 1 BUTTON (LOOP DASH V4) - WHITE TRANSPARENT - FULL TOGGLE
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

--// OLD SCRIPT TERMINATION SYSTEM
local scriptId = math.random(1, 1000000)
_G.SkidwareId = scriptId
local function isCurrent() return _G.SkidwareId == scriptId end

--// CONFIG
local Config = {
    Enabled = true,
    LethalEnabled = true,
    LethalAnim = "rbxassetid://10503381238",
    LethalDelay = 0.232,
    LethalJump = 55,
    LethalAccuracy = 15,
    LethalCancelDelay = 0.4,
    LethalMode = "V1",
    CancelEnabled = true,
    CooldownActive = true,
    NoClipEnabled = true,
    DashRange = 8,
    TouchMode = false,
    Platform = "PC",
    Keybind = "E",
    CooldownAnims = {
        ["10491993682"] = true,
        ["10479335397"] = true,
        ["13380255751"] = true,
    }
}

local isNoclipping = false
local isCooldown = false

--// ГЛАВНЫЙ ФЛАГ (УПРАВЛЯЕТСЯ КНОПКОЙ)
local loopDashV4Active = false

-- // GLOBAL GUI VARIABLES
local ScreenGui, MainFrame, CooldownBar, CooldownFill

-- // NUMERIC ID EXTRACTION FUNCTION
local function getId(str)
    return tostring(str):match("%d+")
end

--// DASH FUNCTION
local function fireDash()
    if not loopDashV4Active then return end
    local char = player.Character
    if not char then return end
    local communicate = char:FindFirstChild("Communicate")
    if communicate then
        local args = {{
            Dash = Enum.KeyCode.W,
            Key = Enum.KeyCode.Q,
            Goal = "KeyPress"
        }}
        communicate:FireServer(unpack(args))
    end
end

--// HELPER FUNCTIONS
local function clip()
    isNoclipping = false
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local function forceCancel()
    clip()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("LinearVelocity") or obj:IsA("Attachment") or obj:IsA("BodyAngularVelocity") then
                obj:Destroy()
            end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

-- // COOLDOWN HANDLING FUNCTION
local function startCooldown(duration)
    if not isCurrent() or isCooldown then return end
    isCooldown = true
    
    if MainFrame and CooldownBar and CooldownFill then
        CooldownBar.Visible = true
        CooldownFill.Size = UDim2.new(1, 0, 1, 0)
        local tween = TweenService:Create(CooldownFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        tween:Play()
        
        task.delay(duration, function()
            isCooldown = false
            CooldownBar.Visible = false
        end)
    else
        task.wait(duration)
        isCooldown = false
    end
end

local function getTorsoTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    
    local parts = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, Config.DashRange, params)
    local target = nil
    local dist = Config.DashRange
    
    for _, part in pairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") and model ~= char then
            local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
            if torso then
                local d = (char.HumanoidRootPart.Position - torso.Position).Magnitude
                if d < dist then 
                    dist = d 
                    target = torso 
                end
            end
        end
    end
    return target
end

--// LETHAL EXECUTION FUNCTION (апперкот)
local isExecuting = false
local function executeLethal()
    if not loopDashV4Active then return end
    if not isCurrent() or isExecuting or isCooldown then return end
    if not Config.Enabled or not Config.LethalEnabled then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local torso = getTorsoTarget()
    if not torso then clip() return end
    
    isExecuting = true
    
    if not Config.TouchMode then
        task.wait(Config.LethalDelay)
    end
    
    if not isCurrent() then isExecuting = false return end
    
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.LethalJump, root.AssemblyLinearVelocity.Z)
    isNoclipping = true
    fireDash()
    
    local startT = tick()
    local flipped = false
    local forwardDir = (torso.Position - root.Position).Unit
    local sideVec = Vector3.new(-forwardDir.Z, 0, forwardDir.X)
    local bav = nil
    
    if Config.LethalMode == "V1" then
        bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(0, 1000000, 0)
        bav.P = 15000
        bav.Parent = root
    end
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not loopDashV4Active then
            if bav then bav:Destroy() end
            clip()
            isExecuting = false
            if conn then conn:Disconnect() end
            return
        end
        
        if not isCurrent() or not torso or not torso.Parent or not root or not root.Parent then 
            if bav then bav:Destroy() end 
            clip()
            isExecuting = false
            if conn then conn:Disconnect() end
            return 
        end
        
        local elapsed = tick() - startT
        local torsoPos, rootPos = torso.Position, root.Position
        hum.AutoRotate = false
        
        if Config.LethalMode == "V1" then
            local angle = (elapsed / 0.45) * (math.pi / 1.5)
            local radius = Config.LethalAccuracy * (1 - math.clamp(elapsed / 0.45, 0, 1))
            local targetLookPos = torsoPos + (sideVec * math.cos(angle) + forwardDir * math.sin(angle)) * radius
            local lookAtCF = CFrame.lookAt(rootPos, Vector3.new(targetLookPos.X, rootPos.Y, targetLookPos.Z))
            local relativeCF = root.CFrame:Inverse() * lookAtCF
            local _, y, _ = relativeCF:ToEulerAnglesXYZ()
            if bav and bav.Parent then 
                bav.AngularVelocity = Vector3.new(0, y * 30, 0) 
            end
        else
            if elapsed >= Config.LethalAccuracy and not flipped then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
                flipped = true
            end
        end

        local distXZ = (Vector2.new(rootPos.X, rootPos.Z) - Vector2.new(torsoPos.X, torsoPos.Z)).Magnitude
        if Config.CancelEnabled and elapsed > Config.LethalCancelDelay then
            if distXZ < 2.2 then
                if bav then bav:Destroy() end
                forceCancel()
                isExecuting = false
                conn:Disconnect()
                return
            end
        end
        
        if not Config.Enabled or elapsed > 1.5 then
            if bav then bav:Destroy() end
            clip()
            isExecuting = false
            conn:Disconnect()
            return
        end
    end)
end

--// GUI SYSTEM CLEANUP & SETUP
for _, gui in pairs(game.CoreGui:GetChildren()) do
    if gui.Name == "SkidwareUI" or gui.Name == "VuxLethalUI" then
        gui:Destroy()
    end
end

ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "RingYTUI"
ScreenGui.ResetOnSpawn = false

MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, -55)
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.BackgroundTransparency = 0.7

local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 6)
end
applyCorner(MainFrame, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.2

--// ЗАГОЛОВОК
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "by RingYT"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

--// КРЕСТИК (ЗАКРЫТЬ МЕНЮ)
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 5

CloseBtn.MouseButton1Click:Connect(function()
    loopDashV4Active = false
    forceCancel()
    isExecuting = false
    ScreenGui:Destroy()
end)

--// КНОПКА LOOP DASH V4
local Btn1 = Instance.new("TextButton", MainFrame)
Btn1.Size = UDim2.new(0.9, 0, 0, 45)
Btn1.Position = UDim2.new(0.05, 0, 0.35, 0)
Btn1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Btn1.Text = "LOOP DASH V4: ВЫКЛ"
Btn1.TextColor3 = Color3.fromRGB(0, 0, 0)
Btn1.Font = Enum.Font.GothamBold
Btn1.TextSize = 12
Btn1.BackgroundTransparency = 0.5
applyCorner(Btn1, 6)
local s1 = Instance.new("UIStroke", Btn1)
s1.Color = Color3.fromRGB(255, 255, 255)
s1.Transparency = 0.2

--// ЛОГИКА КНОПКИ
Btn1.MouseButton1Click:Connect(function()
    loopDashV4Active = not loopDashV4Active
    if loopDashV4Active then
        Btn1.Text = "LOOP DASH V4: ВКЛ"
        Btn1.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        Btn1.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        Btn1.Text = "LOOP DASH V4: ВЫКЛ"
        Btn1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Btn1.TextColor3 = Color3.fromRGB(0, 0, 0)
        
        forceCancel()
        isExecuting = false
    end
end)

--// CORE SETUP & NOCLIP
local function setup(char)
    if not isCurrent() then return end
    local hum = char:WaitForChild("Humanoid")
    hum.AnimationPlayed:Connect(function(track)
        if not loopDashV4Active then return end
        if not isCurrent() then return end
        
        local animId = getId(track.Animation.AnimationId)
        if Config.CooldownActive and Config.CooldownAnims[animId] then
            startCooldown(5)
        end
        
        if Config.TouchMode or not Config.Enabled then return end
        
        if track.Animation.AnimationId == Config.LethalAnim then
            executeLethal()
        end
    end)
end

RunService.Stepped:Connect(function()
    if not loopDashV4Active then return end
    if not isCurrent() or not Config.NoClipEnabled then return end
    
    if isNoclipping and player.Character then
        for _, model in pairs(workspace:GetChildren()) do
            if model:IsA("Model") and model ~= player.Character and (model:FindFirstChild("Humanoid") or model:FindFirstChildOfClass("Humanoid")) then
                for _, part in pairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

if player.Character then setup(player.Character) end
player.CharacterAdded:Connect(setup)

--// ОБЁРТКА ВОКРУГ executeLethal ДЛЯ LOOP DASH V4
local originalLethal = executeLethal
executeLethal = function()
    if not loopDashV4Active then return end
    originalLethal()
    
    if loopDashV4Active then
        task.wait(0.3)
        fireDash()
        task.wait(0.15)
        fireDash()
        task.wait(0.15)
        fireDash()
        task.wait(0.15)
        fireDash()
    end
end
