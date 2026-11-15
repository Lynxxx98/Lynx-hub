-- ==========================================================
-- LYNX SCRIPT HUB — ANTI CLIP / FLY / GOD MODE
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- === RANDOMIZED IDENTIFIERS (anti-signature) ===
local _a1 = "AntiClip_" .. math.random(1000,9999)
local _a2 = "Fly_" .. math.random(1000,9999)
local _a3 = "God_" .. math.random(1000,9999)

-- === UI BUILD (pop up) ===
local _gui = Instance.new("ScreenGui")
_gui.Name = "UI_" .. math.random(100000,999999)
_gui.ResetOnSpawn = false
_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_gui.Parent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")

-- Toggle button (buka-tutup)
local _toggle = Instance.new("TextButton")
_toggle.Size = UDim2.new(0, 50, 0, 50)
_toggle.Position = UDim2.new(0, 20, 0.5, -25)
_toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
_toggle.Text = "≡"
_toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
_toggle.TextSize = 28
_toggle.Font = Enum.Font.GothamBold
_toggle.BorderSizePixel = 0
_toggle.Parent = _gui
Instance.new("UICorner", _toggle).CornerRadius = UDim.new(0, 10)

-- Panel utama
local _panel = Instance.new("Frame")
_panel.Size = UDim2.new(0, 260, 0, 300)
_panel.Position = UDim2.new(0, 20, 0.5, -150)
_panel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
_panel.BorderSizePixel = 0
_panel.Visible = false
_panel.Parent = _gui
Instance.new("UICorner", _panel).CornerRadius = UDim.new(0, 12)

local _title = Instance.new("TextLabel")
_title.Size = UDim2.new(1, 0, 0, 45)
_title.BackgroundTransparency = 1
_title.Text = "Lynx Script Hub"
_title.TextColor3 = Color3.fromRGB(180, 140, 255)
_title.Font = Enum.Font.GothamBold
_title.TextSize = 20
_title.Parent = _panel

-- Subtitle
local _sub = Instance.new("TextLabel")
_sub.Size = UDim2.new(1, 0, 0, 18)
_sub.Position = UDim2.new(0, 0, 0, 40)
_sub.BackgroundTransparency = 1
_sub.Text = "Universal Panel v1.0"
_sub.TextColor3 = Color3.fromRGB(120, 120, 140)
_sub.Font = Enum.Font.Gotham
_sub.TextSize = 11
_sub.Parent = _panel

-- Drag panel
local _dragging, _dragStart, _startPos
_title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        _dragging = true
        _dragStart = inp.Position
        _startPos = _panel.Position
    end
end)
UserInput.InputChanged:Connect(function(inp)
    if _dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - _dragStart
        _panel.Position = UDim2.new(_startPos.X.Scale, _startPos.X.Offset + d.X,
                                    _startPos.Y.Scale, _startPos.Y.Offset + d.Y)
    end
end)
UserInput.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then _dragging = false end
end)

-- Toggle buka-tutup
local _open = false
_toggle.MouseButton1Click:Connect(function()
    _open = not _open
    _panel.Visible = _open
    TweenService:Create(_toggle, TweenInfo.new(0.2), {
        BackgroundColor3 = _open and Color3.fromRGB(90, 50, 140) or Color3.fromRGB(30, 30, 40)
    }):Play()
end)

-- Helper toggle button
local function makeToggle(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = _panel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(90, 50, 140) or Color3.fromRGB(40, 40, 55)
        pcall(callback, state)
    end)
    return btn
end

-- === 1. ANTI CLIP ===
local _acConn
local function setAntiClip(on)
    if _acConn then _acConn:Disconnect() _acConn = nil end
    local char = LP.Character or LP.CharacterAdded:Wait()
    if on then
        _acConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end)
    else
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.CanCollide = true end)
                end
            end
        end
    end
end
makeToggle("Anti Clip", 70, setAntiClip)

-- === 2. FLY (BodyGyro + BodyVelocity) ===
local _flyConn, _flyBV, _flyBG, _flySpeed = nil, nil, nil, 50
local _fly = false
local function setFly(on)
    _fly = on
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    if on then
        _flyBG = Instance.new("BodyGyro")
        _flyBG.P = 9e4
        _flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        _flyBG.CFrame = hrp.CFrame
        _flyBG.Parent = hrp

        _flyBV = Instance.new("BodyVelocity")
        _flyBV.Velocity = Vector3.zero
        _flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        _flyBV.Parent = hrp

        _flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            _flyBV.Velocity = move * _flySpeed
            _flyBG.CFrame = cam.CFrame
        end)
    else
        if _flyConn then _flyConn:Disconnect() _flyConn = nil end
        if _flyBV then _flyBV:Destroy() _flyBV = nil end
        if _flyBG then _flyBG:Destroy() _flyBG = nil end
    end
end
makeToggle("Fly", 120, setFly)

-- === 3. GOD MODE ===
local _godConn
local function setGod(on)
    if _godConn then _godConn:Disconnect() _godConn = nil end
    if on then
        _godConn = RunService.Heartbeat:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end)
            end
        end)
    else
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.MaxHealth = 100
                hum.Health = 100
            end)
        end
    end
end
makeToggle("God Mode", 170, setGod)

-- === Auto-reset on respawn ===
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if _fly then setFly(true) end
    if _acConn then setAntiClip(true) end
end)