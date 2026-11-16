local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 320)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -64, 0, 28)
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
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextSize = 20
minBtn.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.Parent = frame

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

-- logo kotak (tombol buka)
local logo = Instance.new("TextButton")
logo.Size = UDim2.new(0, 48, 0, 48)
logo.Position = UDim2.new(0, 10, 0.2, 0)
logo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
logo.Text = "N"
logo.TextColor3 = Color3.new(1, 1, 1)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 26
logo.AutoButtonColor = false
logo.Parent = gui
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", logo)
stroke.Color = Color3.fromRGB(170, 40, 40)
stroke.Thickness = 2

-- drag (onTap dipanggil kalau cuma di-tap, bukan digeser)
local function makeDraggable(handle, obj, onTap)
    local drag, moved, dStart, oStart = false, false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag, moved = true, false
            dStart, oStart = i.Position, obj.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    drag = false
                    if onTap and not moved then onTap() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            if d.Magnitude > 8 then moved = true end
            if moved then
                obj.Position = UDim2.new(oStart.X.Scale, oStart.X.Offset + d.X,
                                         oStart.Y.Scale, oStart.Y.Offset + d.Y)
            end
        end
    end)
end

local function openPanel()
    frame.Position = logo.Position
    logo.Visible = false
    frame.Visible = true
end

local function collapsePanel()
    logo.Position = frame.Position
    frame.Visible = false
    logo.Visible = true
end

makeDraggable(logo, logo, openPanel)
makeDraggable(title, frame)
minBtn.MouseButton1Click:Connect(collapsePanel)

-- X: matiin semua fitur lalu hapus GUI
closeBtn.MouseButton1Click:Connect(function()
    for k in pairs(S) do S[k] = false end
    following, orbiting = nil, nil
    local r, h = getRoot(), getHum()
    local bv = r and r:FindFirstChild("NyxFly")
    if bv then bv:Destroy() end
    if h then h.PlatformStand = false end
    if r then r.Anchored = false end
    cam.CameraType = Enum.CameraType.Custom
    if h then cam.CameraSubject = h end
    gui:Destroy()
end)