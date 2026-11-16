-- Roblox | Delta Executor | Nyx Panel v3 (satu file)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- hapus panel lama kalau ada
pcall(function()
    for _, root in ipairs({lp:WaitForChild("PlayerGui"), gethui and gethui() or nil}) do
        local old = root:FindFirstChild("NyxPanel")
        if old then old:Destroy() end
    end
end)

local S = {fling=false, noclip=false, fly=false, speed=false, inf=false,
           click=false, esp=false, antifling=false, spin=false, sjump=false}
local spd = 50
local spectating, following, orbiting
local orbitAngle, lastPos = 0, nil
local errors = 0

local function getChar(p) return p and p.Character end
local function getRoot(p) p = p or lp local c = p.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(p) p = p or lp local c = p.Character return c and c:FindFirstChildOfClass("Humanoid") end

local function findPlayer(name)
    name = name:lower()
    if name == "" then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (p.Name:lower():sub(1, #name) == name
            or p.DisplayName:lower():sub(1, #name) == name) then
            return p
        end
    end
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "NyxPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = (gethui and gethui()) or lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 320)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -34, 0, 28)
title.BackgroundTransparency = 1
title.Text = "  NYX PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Active = true
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 28)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextSize = 20
minBtn.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -34)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = frame

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -4, 0, 32)
grid.CellPadding = UDim2.new(0, 4, 0, 4)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = scroll

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroll.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 230, 0, 28) or UDim2.new(0, 230, 0, 320)
    minBtn.Text = minimized and "+" or "-"
end)

-- drag lewat judul
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, i.Position, frame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================= widget builders =================
local OFF, ON = Color3.fromRGB(45, 45, 45), Color3.fromRGB(30, 130, 70)

local function fail(name, err)
    errors += 1
    title.Text = "  NYX PANEL (" .. errors .. " err)"
    warn("[Nyx] " .. name .. ": " .. tostring(err))
end

local function newBox(placeholder, default, cb)
    local b = Instance.new("TextBox")
    b.PlaceholderText = placeholder
    b.Text = default or ""
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    b.TextSize = 12
    b.ClearTextOnFocus = false
    b.Parent = scroll
    Instance.new("UICorner", b)
    if cb then
        b.FocusLost:Connect(function()
            local ok, e = pcall(cb, b.Text)
            if not ok then fail(placeholder, e) end
        end)
    end
    return b
end

local function newButton(text, cb)
    local b = Instance.new("TextButton")
    b.Text = text
    b.BackgroundColor3 = OFF
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Parent = scroll
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        local ok, e = pcall(cb)
        if not ok then fail(text, e) end
    end)
    return b
end

local function newToggle(text, cb)
    local on = false
    local b
    b = newButton(text, function()
        local want = not on
        local res = cb(want)
        if res == false then return end
        on = want
        b.BackgroundColor3 = on and ON or OFF
    end)
end

-- ================= target =================
local nameBox = newBox("nama player")
newBox("speed", "50", function(t) spd = tonumber(t) or 50 end)

local function target()
    local t = findPlayer(nameBox.Text)
    if not t then
        nameBox.Text = ""
        nameBox.PlaceholderText = "nggak ketemu"
    end
    return t
end

newButton("Next Player", (function()
    local idx = 0
    return function()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        if #list == 0 then return end
        idx = idx % #list + 1
        nameBox.Text = list[idx].Name
    end
end)())

-- ================= target actions =================
newButton("TP", function()
    local t = target()
    local r, tr = getRoot(), getRoot(t)
    if r and tr then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
end)

newButton("TENDANG", function()
    local t = target()
    task.spawn(function()
        local r, tr = getRoot(), getRoot(t)
        if not (r and tr) then return end
        local origin = r.CFrame
        local t0 = tick()
        while tick() - t0 < 2 and tr.Parent and r.Parent do
            RunService.Heartbeat:Wait()
            r.CFrame = tr.CFrame
            r.AssemblyLinearVelocity = Vector3.new(1e6, 1e6, 1e6)
            r.AssemblyAngularVelocity = Vector3.new(1e6, 1e6, 1e6)
        end
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        r.CFrame = origin
    end)
end)

newToggle("Spectate", function(on)
    if on then
        local h = getHum(target())
        if not h then return false end
        cam.CameraSubject = h
    else
        local h = getHum()
        if h then cam.CameraSubject = h end
    end
end)

newToggle("Follow", function(on)
    if on then
        following = target()
        if not following then return false end
    else
        following = nil
    end
end)

newToggle("Orbit", function(on)
    if on then
        orbiting = target()
        if not orbiting then return false end
    else
        orbiting = nil
    end
end)

-- ================= movement =================
newToggle("Touch Fling", function(on) S.fling = on end)
newToggle("Fly", function(on)
    S.fly = on
    if not on then
        local r, h = getRoot(), getHum()
        local bv = r and r:FindFirstChild("NyxFly")
        if bv then bv:Destroy() end
        if h then h.PlatformStand = false end
    end
end)
newToggle("Noclip", function(on) S.noclip = on end)
newToggle("Speed", function(on)
    S.speed = on
    if not on then local h = getHum() if h then h.WalkSpeed = 16 end end
end)
newToggle("Inf Jump", function(on) S.inf = on end)
newToggle("Super Jump", function(on)
    S.sjump = on
    if not on then local h = getHum() if h then h.JumpPower = 50 end end
end)
newToggle("Spin", function(on) S.spin = on end)
newToggle("Anti Fling", function(on) S.antifling = on end)
newToggle("Freeze", function(on)
    local r = getRoot()
    if not r then return false end
    r.Anchored = on
end)
newButton("Sit", function() local h = getHum() if h then h.Sit = true end end)
newButton("Reset", function() local h = getHum() if h then h.Health = 0 end end)

UIS.JumpRequest:Connect(function()
    if S.inf then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ================= click tp =================
newToggle("Click TP", function(on) S.click = on end)
local function clickTeleport(pos2d)
    local r = getRoot()
    if not r then return end
    local ray = cam:ViewportPointToRay(pos2d.X, pos2d.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {lp.Character}
    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if res then r.CFrame = CFrame.new(res.Position + Vector3.new(0, 3, 0)) end
end
UIS.TouchTapInWorld:Connect(function(pos, processed)
    if S.click and not processed then pcall(clickTeleport, pos) end
end)
UIS.InputBegan:Connect(function(i, processed)
    if S.click and not processed and i.UserInputType == Enum.UserInputType.MouseButton1 then
        pcall(clickTeleport, UIS:GetMouseLocation())
    end
end)

-- ================= waypoint =================
do
    local saved
    newButton("Save Pos", function() local r = getRoot() if r then saved = r.CFrame end end)
    newButton("Go Saved", function() local r = getRoot() if r and saved then r.CFrame = saved end end)
    newButton("Copy Coords", function()
        local r = getRoot()
        if r and setclipboard then
            local p = r.Position
            setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
        end
    end)
end

do
    local on = false
    newToggle("Respawn Here", function(v) on = v end)
    lp.CharacterAdded:Connect(function(char)
        if not on or not lastPos then return end
        local r = char:WaitForChild("HumanoidRootPart", 5)
        if r then task.wait(0.3) r.CFrame = lastPos end
    end)
end

-- ================= ESP =================
local espObjs = {}
local function clearESP()
    for _, o in pairs(espObjs) do o.folder:Destroy() end
    table.clear(espObjs)
end
Players.PlayerRemoving:Connect(function(p)
    local o = espObjs[p]
    if o then o.folder:Destroy() espObjs[p] = nil end
end)
newToggle("ESP", function(on)
    S.esp = on
    if not on then clearESP() end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        if S.esp then
            local myRoot = getRoot()
            for _, p in ipairs(Players:GetPlayers()) do
                local char, root = getChar(p), getRoot(p)
                if p ~= lp and char and root then
                    local o = espObjs[p]
                    if not o or o.char ~= char then
                        if o then o.folder:Destroy() end
                        local f = Instance.new("Folder")
                        f.Parent = gui
                        local h = Instance.new("Highlight")
                        h.Adornee = char
                        h.FillColor = Color3.fromRGB(255, 60, 60)
                        h.FillTransparency = 0.6
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = f
                        local bb = Instance.new("BillboardGui")
                        bb.Adornee = root
                        bb.Size = UDim2.new(0, 140, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = f
                        local l = Instance.new("TextLabel")
                        l.Size = UDim2.new(1, 0, 1, 0)
                        l.BackgroundTransparency = 1
                        l.TextColor3 = Color3.new(1, 1, 1)
                        l.TextStrokeTransparency = 0
                        l.TextSize = 13
                        l.Parent = bb
                        o = {folder = f, char = char, label = l}
                        espObjs[p] = o
                    end
                    local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                    o.label.Text = p.DisplayName .. " [" .. dist .. "m]"
                end
            end
        end
    end
end)

-- ================= visual / world =================
do
    local backup
    newToggle("Fullbright", function(on)
        if on then
            backup = {Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                      FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
                      Ambient = Lighting.Ambient}
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        elseif backup then
            for k, v in pairs(backup) do Lighting[k] = v end
        end
    end)
end

do
    local default = workspace.Gravity
    newToggle("Low Gravity", function(on) workspace.Gravity = on and 60 or default end)
    newBox("gravity (196 normal)", "", function(t) workspace.Gravity = tonumber(t) or default end)
end

newBox("FOV (default 70)", "", function(t)
    local v = tonumber(t)
    if v then cam.FieldOfView = math.clamp(v, 30, 120) end
end)

newToggle("Max Zoom", function(on) lp.CameraMaxZoomDistance = on and 1e4 or 128 end)
newToggle("Cam Clip", function(on)
    lp.DevCameraOcclusionMode = on and Enum.DevCameraOcclusionMode.Invisicam
        or Enum.DevCameraOcclusionMode.Zoom
end)
newToggle("Hide Names", function(on)
    for _, p in ipairs(Players:GetPlayers()) do
        local h = getHum(p)
        if h and p ~= lp then
            h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None
                or Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
end)

-- ================= freecam =================
do
    local conn, inputConn
    local pos, yaw, pitch = Vector3.zero, 0, 0
    newToggle("Freecam", function(on)
        local r, h = getRoot(), getHum()
        if on then
            if not r then return false end
            r.Anchored = true
            cam.CameraType = Enum.CameraType.Scriptable
            pos = cam.CFrame.Position
            pitch, yaw = cam.CFrame:ToOrientation()
            inputConn = UIS.InputChanged:Connect(function(i, gp)
                if gp then return end
                if i.UserInputType == Enum.UserInputType.Touch
                    or (i.UserInputType == Enum.UserInputType.MouseMovement
                        and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
                    yaw = yaw - i.Delta.X * 0.005
                    pitch = math.clamp(pitch - i.Delta.Y * 0.005, -1.5, 1.5)
                end
            end)
            conn = RunService.RenderStepped:Connect(function(dt)
                local hum = getHum()
                local md = hum and hum.MoveDirection or Vector3.zero
                local rot = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
                if md.Magnitude > 0 then
                    local look, right = rot.LookVector, rot.RightVector
                    local fl = Vector3.new(look.X, 0, look.Z)
                    local fr = Vector3.new(right.X, 0, right.Z)
                    local f = fl.Magnitude > 0.01 and md:Dot(fl.Unit) or 0
                    local rr = fr.Magnitude > 0.01 and md:Dot(fr.Unit) or 0
                    pos = pos + (look * f + right * rr) * spd * dt
                end
                cam.CFrame = CFrame.new(pos) * rot
            end)
        else
            if conn then conn:Disconnect() end
            if inputConn then inputConn:Disconnect() end
            if r then r.Anchored = false end
            cam.CameraType = Enum.CameraType.Custom
            if h then cam.CameraSubject = h end
        end
    end)
end

-- ================= misc =================
do
    local afkConn
    newToggle("Anti AFK", function(on)
        if on then
            local VU = game:GetService("VirtualUser")
            afkConn = lp.Idled:Connect(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        elseif afkConn then
            afkConn:Disconnect()
            afkConn = nil
        end
    end)
end

newButton("Rejoin", function()
    local TS = game:GetService("TeleportService")
    if #Players:GetPlayers() <= 1 then
        TS:Teleport(game.PlaceId, lp)
    else
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end
end)

newButton("Server Hop", function()
    task.spawn(function()
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if not ok or not data or not data.data then return end
        for _, s in ipairs(data.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                return
            end
        end
    end)
end)

newButton("FPS Boost", function()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    Lighting.GlobalShadows = false
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") then
            o.Material = Enum.Material.Plastic
            o.CastShadow = false
        elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke")
            or o:IsA("Fire") or o:IsA("Sparkles") then
            o.Enabled = false
        end
    end
end)

-- ================= loops =================
RunService.Stepped:Connect(function()
    if S.noclip and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if S.antifling then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)

local function flat(v)
    local f = Vector3.new(v.X, 0, v.Z)
    return f.Magnitude > 0.01 and f.Unit or Vector3.zero
end

RunService.Heartbeat:Connect(function(dt)
    local r, h = getRoot(), getHum()
    if not (r and h) then return end

    if h.Health > 0 then lastPos = r.CFrame end
    if S.speed then h.WalkSpeed = spd end
    if S.sjump then h.UseJumpPower = true h.JumpPower = 120 end

    if S.fly then
        local bv = r:FindFirstChild("NyxFly")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "NyxFly"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Parent = r
        end
        h.PlatformStand = true
        local md = h.MoveDirection
        if md.Magnitude > 0 then
            local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
            local f = md:Dot(flat(look))
            local rr = md:Dot(flat(right))
            bv.Velocity = (look * f + right * rr) * spd * 1.5
        else
            bv.Velocity = Vector3.zero
        end
    end

    if following then
        local tr = getRoot(following)
        if tr then h:MoveTo(tr.Position) end
    end

    if orbiting then
        local tr = getRoot(orbiting)
        if tr then
            orbitAngle += dt * 3
            local p = tr.Position + Vector3.new(math.cos(orbitAngle) * 6, 0, math.sin(orbitAngle) * 6)
            r.CFrame = CFrame.new(p, tr.Position)
        end
    end

    if S.spin then r.CFrame = r.CFrame * CFrame.Angles(0, dt * 12, 0) end
end)

task.spawn(function()
    local flip = 0.1
    while true do
        RunService.Heartbeat:Wait()
        local r = getRoot()
        if S.fling and r then
            local vel = r.AssemblyLinearVelocity
            r.AssemblyLinearVelocity = Vector3.new(1e6, 1e6, 1e6)
            r.AssemblyAngularVelocity = Vector3.new(1e6, 1e6, 1e6)
            RunService.RenderStepped:Wait()
            r.AssemblyLinearVelocity = vel
            r.AssemblyAngularVelocity = Vector3.zero
            RunService.Stepped:Wait()
            r.AssemblyLinearVelocity = vel + Vector3.new(0, flip, 0)
            flip = -flip
        end
    end
end)