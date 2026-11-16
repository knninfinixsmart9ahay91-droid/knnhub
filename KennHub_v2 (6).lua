-- Kenn Hub | Crack and Steal | Delta (Android) | Luau
-- UI baru: logo mengambang -> klik buka panel tools (tab, resize, bg gambar)
-- Steal Mode "Dodge": TP ke pet -> steal (dicek beneran kebawa) -> TP ke guard
--   (nabrak tanpa pental) -> TP ke spawn -> drop -> jeda -> ambil lagi -> bawa
--   masuk safe zone (base). Tanpa respawn, tanpa save posisi.
-- Auto Steal & Break nggak perlu "trigger" area dulu: ada streamer latar yang
--   muterin semua area, jadi bisa jalan dari dalam safe zone.
-- Auto Swing = indikator + tombol "Ayunan Otomatis" bawaan game ikut ijo pas Enable nyala.
-- v2: Event, Shop (Auto Buy Plot + Diamond Magnet), emoji di semua tool, break nunggu pecah.
-- Fitur lama tetap ada: Enable (telur), Auto Swing, Break Only/Anywhere,
--   Skip Anim, Auto Treadmill, Stealth Mode, FPS Boost, Filter Area

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local T0 = os.clock()

----------------------------------------------------------------
-- Notif loading (kanan bawah)
----------------------------------------------------------------
local KennNotif = nil
local KH = { txt = { event = "Event: belum scan", shop = "Shop: -", magnet = "Magnet: mati" }, reason = "", stall = "Diem terakhir: -", rejSeen = 0 }
do
	pcall(function()
		local pg = lp:WaitForChild("PlayerGui", 10)
		if not pg then return end
		local old = pg:FindFirstChild("KennHub_Notif")
		if old then old:Destroy() end
		local sg = Instance.new("ScreenGui")
		sg.Name = "KennHub_Notif"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 1000
		sg.Parent = pg

		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(1, 1)
		f.Size = UDim2.fromOffset(250, 54)
		f.Position = UDim2.new(1, 280, 1, -96)
		f.BackgroundColor3 = Color3.fromRGB(14, 12, 24)
		f.BackgroundTransparency = 0.05
		f.BorderSizePixel = 0
		f.Parent = sg
		local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 12) fc.Parent = f
		local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(130, 90, 255) fs.Thickness = 1.5 fs.Parent = f

		local logo = Instance.new("ImageLabel")
		logo.Size = UDim2.fromOffset(38, 38)
		logo.Position = UDim2.fromOffset(8, 8)
		logo.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
		logo.Image = ""
		logo.ScaleType = Enum.ScaleType.Crop
		logo.Parent = f
		local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 8) lc.Parent = logo
		local lk = Instance.new("TextLabel")
		lk.Size = UDim2.fromScale(1, 1)
		lk.BackgroundTransparency = 1
		lk.Text = "K"
		lk.Font = Enum.Font.GothamBlack
		lk.TextSize = 22
		lk.TextColor3 = Color3.new(1, 1, 1)
		lk.Parent = logo

		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(1, -62, 0, 24)
		txt.Position = UDim2.fromOffset(54, 7)
		txt.BackgroundTransparency = 1
		txt.Text = "Loading script Kenn Hub..."
		txt.Font = Enum.Font.GothamBold
		txt.TextSize = 13
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.TextColor3 = Color3.fromRGB(240, 240, 250)
		txt.Parent = f

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(1, -66, 0, 5)
		barBg.Position = UDim2.fromOffset(54, 34)
		barBg.BackgroundColor3 = Color3.fromRGB(40, 38, 60)
		barBg.BorderSizePixel = 0
		barBg.Parent = f
		local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 3) bc.Parent = barBg
		local bar = Instance.new("Frame")
		bar.Size = UDim2.fromScale(0.08, 1)
		bar.BackgroundColor3 = Color3.fromRGB(255, 90, 175)
		bar.BorderSizePixel = 0
		bar.Parent = barBg
		local bc2 = Instance.new("UICorner") bc2.CornerRadius = UDim.new(0, 3) bc2.Parent = bar

		TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -12, 1, -96) }):Play()
		TweenService:Create(bar, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(0.85, 1) }):Play()

		local closed = false
		KennNotif = {}
		function KennNotif.setLogo(id)
			pcall(function() logo.Image = id logo.BackgroundTransparency = 1 lk.Visible = false end)
		end
		function KennNotif.finish(msg, good)
			if closed then return end
			closed = true
			pcall(function()
				txt.Text = msg or "Kenn Hub siap dipakai"
				TweenService:Create(bar, TweenInfo.new(0.25), { Size = UDim2.fromScale(1, 1), BackgroundColor3 = good == false and Color3.fromRGB(235, 75, 85) or Color3.fromRGB(70, 210, 130) }):Play()
			end)
			task.delay(1.8, function()
				pcall(function()
					TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 280, 1, -96) }):Play()
				end)
				task.wait(0.4)
				pcall(function() sg:Destroy() end)
			end)
		end
		task.delay(30, function() if KennNotif then KennNotif.finish("Selesai", true) end end)
	end)
end

local CONFIG = {
	LOGO_URL = "https://files.catbox.moe/78wqev.jpg",
	BG_URL = "https://files.catbox.moe/6cl5xr.jpg",
	LOGO_RADIUS = 6,
	REVISIT = 2.5,
	BREAK_TIMEOUT = 0.3,
	STEAL_LOCKED = true,
	HITS_PER_EGG = 1,
	SETTLE = 0.03,
	AFTER_HIT = 0.03,
	HIT_DELAY = 0.05,
	SWING_DELAY = 0.15,
	LOOP_DELAY = 0.05,
	NEAR_DISTANCE = 22,
	TELEPORT_OFFSET = Vector3.new(0, 4, 5),
	STREAM_MAX = 2.5,
	GHOST_COOLDOWN = 10,
	BLOCK_AFTER_REJECTS = 8,
	BLOCK_FOR = 30,
	RESCAN_EVERY = 0.8,
	STEAL_KEYS = { "steal", "curi", "grab", "rob" },
	STEAL_SKIP_AREAS = { ["Planet X"] = true },
	SAFE_RADIUS = 45,
	STEAL_COOLDOWN = 6,
	HANDOFF_WAIT = 1.2,
	STEAL_AFTER = 0.6,
	WALK_TIMEOUT = 20,
	TREADMILL_STAY = 10,
	TREADMILL_PROMPT_EVERY = 6,
	TREADMILL_RESCAN = 3,
	ANYWHERE_RESCAN = 3,
	STREAM_TIMEOUT = 2,
	STEAL_MEMORY = 8,
	STEAL_RESOLVE_WAIT = 2.5,
	STEAL_SCAN_EVERY = 1.0,
	STEALTH_JITTER = 0.25,
	HATCH_KEYS = { "hatch", "reveal", "opening", "eggopen", "petopen", "newpet", "congrat" },
	DODGE = {
		BUMP_START_DIST = 6,
		BUMP_APPROACH = 0.35,
		BUMP_HOLD = 0.7,
		LAND_WAIT = 1.6,
		JUMP_DIST = 25,
		LAND_DIST = 60,
		DROP_MARGIN = 12,
		DROP_WAIT = 0.4,
		PICKUP_TRIES = 6,
		PICKUP_POLL = 20,
		PICKUP_RADIUS = 20,
		GUARD_KEYS = { "guard", "penjaga", "sentry" },
		PICKUP_KEYS = { "pick", "take", "grab", "pungut", "ambil" },
		DROP_BTN_TEXTS = { "jatuhkan", "drop" },
	},
}

-- urutan = nomor zone (Zone1 = Forest, Zone2 = Desert, ...)
local AREAS = {
	"All", "Forest", "Desert", "Snowy", "Candy", "Swamp", "Ocean",
	"Volcano (Hell)", "Blossom", "Galaxy", "Planet X",
	"Haunted Graveyard", "Fairy Castle", "Fantasy Expansion", "Other",
}

local NAME_KEYS = {
	["Haunted Graveyard"] = { "hauntedgraveyard", "graveyard", "haunted" },
	["Fairy Castle"] = { "fairycastle", "fairy" },
	["Fantasy Expansion"] = { "fantasyexpansion", "fantasy", "expansion" },
}

local STEAL_MODES = { "Instant", "Safe", "Walk", "Anywhere", "Dodge" }

local State = {
	enabled = false, autoSwing = true, autoSteal = false, autoTreadmill = false,
	breakAnywhere = false, stealth = true, fpsBoost = false,
	stealMode = "Dodge", breakOnly = false, skipAnim = true,
	area = "All", alive = true, eggsLeft = true,
	autoEvent = false, autoBuyPlot = false, magnet = false, magnetRadius = 40, learning = false,
	noBlast = true, standoff = 14,
}
local learned = nil
local hitRemote = RS:WaitForChild("EggHitRequest", 5)
local hitArg = 2
local hitName = "Egg"
local hitDelay = CONFIG.HIT_DELAY
local rejects, landed = 0, 0
local lastReject = ""
local cache, lastScan = {}, 0
local visited, ghostCool = {}, {}
local known, anchors = {}, {}
local areaRejects, blocked = {}, {}
local curArea = nil
local statusText = ""
local stealText = ""
local areaCount = 0
local stealing = false
local stealCount = 0
local gains, firstGain = 0, nil
local recorded = {}
local lastAnywhereStream = 0
local stealPoke, spawnSeen, detectOK = 0, nil, false
local lastBreakPos, lastBreakT = nil, 0
local gui

local function norm(s)
	return (string.lower(s):gsub("[^%w]", ""))
end

local function hasAny(str, list)
	str = string.lower(str)
	for _, k in ipairs(list) do
		if string.find(str, k, 1, true) then return true end
	end
	return false
end

local function jitter(base)
	if not State.stealth then return base end
	local f = 1 + (math.random() * 2 - 1) * CONFIG.STEALTH_JITTER
	return math.max(0.02, base * f)
end

local function serArgs(...)
	local a, p = table.pack(...), {}
	for i = 1, a.n do
		local v = a[i]
		p[i] = typeof(v) == "Instance" and v.Name or tostring(v)
	end
	return table.concat(p, ", ")
end

local function recordCall(nm, m, args)
	local parts = {}
	for i = 1, args.n do
		local v = args[i]
		parts[i] = typeof(v) == "Instance" and ("<" .. v:GetFullName() .. ">") or (tostring(v) .. " (" .. typeof(v) .. ")")
	end
	if #recorded >= 25 then table.remove(recorded, 1) end
	table.insert(recorded, string.format("[%.1fs] %s:%s(%s)", os.clock() - T0, nm, m, table.concat(parts, ", ")))
end

pcall(function()
	if hookmetamethod and getnamecallmethod then
		local old
		old = hookmetamethod(game, "__namecall", (newcclosure or function(f) return f end)(function(self, ...)
			local m = getnamecallmethod()
			if (m == "FireServer" or m == "InvokeServer") and not (checkcaller and checkcaller()) then
				if self == hitRemote and m == "FireServer" then
					local a = table.pack(...)
					if typeof(a[2]) == "number" then hitArg = a[2] end
					if typeof(a[1]) == "Instance" then hitName = a[1].Name end
				end
				local ok, nm = pcall(function() return self.Name end)
				if State.learning and ok and type(nm) == "string" and self ~= hitRemote
					and not hasAny(nm, { "swing", "hit", "walk", "move", "input", "ping", "heartbeat", "camera", "treadmill" }) then
					learned = { remote = self, method = m, name = nm, args = table.pack(...) }
					State.learning = false
				end
				if ok and type(nm) == "string" and (string.find(string.lower(nm), "treadmill", 1, true) or string.find(string.lower(nm), "drop", 1, true) or string.find(string.lower(nm), "catch", 1, true) or string.find(string.lower(nm), "respawn", 1, true)) then
					local args = table.pack(...)
					task.defer(recordCall, nm, m, args)
				end
			end
			return old(self, ...)
		end))
	end
end)

pcall(function()
	local rej = RS:FindFirstChild("EggHitRejected")
	if rej and rej:IsA("RemoteEvent") then
		rej.OnClientEvent:Connect(function(...)
			rejects = rejects + 1
			lastReject = serArgs(...)
		end)
	end
	for _, n in ipairs({ "EggHitConfirmed", "EggHitLanded" }) do
		local r = RS:FindFirstChild(n)
		if r and r:IsA("RemoteEvent") then
			r.OnClientEvent:Connect(function()
				landed = landed + 1
				if curArea then areaRejects[curArea] = 0 end
			end)
		end
	end
	local sg = RS:FindFirstChild("SpeedGainRemote")
	if sg and sg:IsA("RemoteEvent") then
		sg.OnClientEvent:Connect(function(...)
			gains = gains + 1
			if not firstGain then firstGain = serArgs(...) end
		end)
	end
	local cf = RS:FindFirstChild("CatchFlingRemote")
	if cf and cf:IsA("RemoteEvent") then
		cf.OnClientEvent:Connect(function(...) recordCall("CatchFlingRemote(server)", "OnClientEvent", table.pack(...)) end)
	end
end)

----------------------------------------------------------------
-- Skip animasi hatch
----------------------------------------------------------------
local function hideHatch(inst)
	if gui and inst:IsDescendantOf(gui) then return end
	if not hasAny(inst.Name, CONFIG.HATCH_KEYS) then return end
	if inst:IsA("ScreenGui") then
		inst.Enabled = false
	elseif inst:IsA("Frame") or inst:IsA("ViewportFrame") or inst:IsA("ImageLabel") then
		inst.Visible = false
	end
end

local function fixCamera()
	local cam = workspace.CurrentCamera
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if cam and hum then
		if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
		if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
	end
end

task.spawn(function()
	local pg = lp:WaitForChild("PlayerGui")
	pg.DescendantAdded:Connect(function(d)
		if State.skipAnim and State.alive then task.defer(hideHatch, d) end
	end)
end)

workspace.DescendantAdded:Connect(function(d)
	if State.noBlast and d:IsA("Explosion") then
		pcall(function()
			d.BlastPressure = 0
			d.DestroyJointRadiusPercent = 0
			d.Visible = false
		end)
	end
end)

----------------------------------------------------------------
-- Swing
----------------------------------------------------------------
local function swing()
	local char = lp.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then
		local bp = lp:FindFirstChild("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") and hasAny(t.Name, { "pickaxe", "palu", "hammer", "kristal" }) then tool = t break end
			end
			tool = tool or bp:FindFirstChildOfClass("Tool")
		end
		if tool and hum then pcall(function() hum:EquipTool(tool) end) end
	end
	if tool then pcall(function() tool:Activate() end) end
end

task.spawn(function()
	while State.alive do
		if State.enabled and State.autoSwing then
			swing()
			task.wait(jitter(CONFIG.SWING_DELAY))
		else
			task.wait(0.2)
		end
	end
end)

----------------------------------------------------------------
-- Tombol "Ayunan Otomatis" bawaan game: Enable nyala -> otomatis jadi ijo
----------------------------------------------------------------
do
local function tapGui(b)
	local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
	if not ok or not vim then return end
	local inset = game:GetService("GuiService"):GetGuiInset()
	local sg = b:FindFirstAncestorOfClass("ScreenGui")
	local add = (sg and sg.IgnoreGuiInset) and 0 or inset.Y
	local p, sz = b.AbsolutePosition, b.AbsoluteSize
	local x, y = p.X + sz.X / 2, p.Y + sz.Y / 2 + add
	pcall(function() vim:SendMouseButtonEvent(x, y, 0, true, game, 1) end)
	task.wait(0.05)
	pcall(function() vim:SendMouseButtonEvent(x, y, 0, false, game, 1) end)
end

local pressMethods = {
	function(b) if firesignal then firesignal(b.Activated) end end,
	function(b)
		if getconnections then
			for _, c in ipairs(getconnections(b.MouseButton1Click)) do pcall(function() c:Fire() end) end
		end
	end,
	function(b) tapGui(b) end,
}

function KH.pressFirst(b)
	if firesignal then pcall(firesignal, b.Activated)
	elseif getconnections then
		for _, c in ipairs(getconnections(b.Activated)) do pcall(function() c:Fire() end) end
	else tapGui(b) end
end

local AUTO_KEYS = { "ayunan otomatis", "auto swing", "autoswing" }
local gameBtn, gameTxt = nil, nil
local gameMethod, gameTurnedOn = 1, false

local function findGameAutoSwing()
	if gameTxt and gameTxt.Parent and gameBtn and gameBtn.Parent then return gameBtn, gameTxt end
	gameBtn, gameTxt = nil, nil
	local pg = lp:FindFirstChild("PlayerGui")
	if not pg then return end
	for _, d in ipairs(pg:GetDescendants()) do
		if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and hasAny(d.Text, AUTO_KEYS) then
			local sg = d:FindFirstAncestorOfClass("ScreenGui")
			if sg and sg.Name ~= "KennHub_UI" and sg.Name ~= "KennHub_Notif" then
				local o, btn = d, nil
				for _ = 1, 5 do
					if o and o:IsA("GuiButton") then btn = o break end
					o = o and o.Parent
				end
				gameBtn, gameTxt = btn or d, d
				return gameBtn, gameTxt
			end
		end
	end
end

local function colorOfGui(o)
	local g = o:FindFirstChildOfClass("UIGradient")
	if g and #g.Color.Keypoints > 0 then return g.Color.Keypoints[1].Value end
	return o.BackgroundColor3
end

-- true = ijo (nyala), false = merah (mati), nil = nggak bisa dibaca
local function gameSwingState(txt)
	local o = txt
	for _ = 1, 5 do
		if o and o:IsA("GuiObject") and o.BackgroundTransparency < 0.95 then
			local c = colorOfGui(o)
			if c.G > c.R * 1.15 and c.G >= c.B then return true end
			if c.R > c.G * 1.4 and c.R > c.B * 1.4 then return false end
		end
		o = o and o.Parent
	end
	return nil
end

task.spawn(function()
	while State.alive do
		local want = State.enabled and State.autoSwing
		local b, txt = findGameAutoSwing()
		if b and txt then
			local st = gameSwingState(txt)
			if st ~= nil then
				local goal = nil
				if want and not st then goal = true
				elseif (not want) and st and gameTurnedOn then goal = false end
				if goal ~= nil then
					pcall(pressMethods[gameMethod], b)
					task.wait(0.8)
					local after = gameSwingState(txt)
					if after == goal then
						gameTurnedOn = goal
					elseif after == st then
						gameMethod = gameMethod % #pressMethods + 1
					end
				end
			end
		end
		task.wait(1)
	end
end)
end

----------------------------------------------------------------
-- Logika telur
----------------------------------------------------------------
local function hitPartRaw(model)
	local p = model:FindFirstChild(hitName, true) or model:FindFirstChild("Egg", true)
	if p and p:IsA("BasePart") then return p end
	local best, size
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			local v = d.Size.X * d.Size.Y * d.Size.Z
			if not size or v > size then best, size = d, v end
		end
	end
	return best
end

local partCache = setmetatable({}, { __mode = "k" })
local function hitPart(model)
	local c = partCache[model]
	if c and c.Parent then return c end
	local p = hitPartRaw(model)
	if p then partCache[model] = p end
	return p
end

local function hit(model)
	swing()
	local part = hitPart(model)
	if hitRemote and part then pcall(function() hitRemote:FireServer(part, hitArg) end) end
end

local function zoneNumber(inst)
	local cur = inst
	while cur and cur ~= workspace do
		local n = tonumber(string.match(cur.Name, "^[Zz]one%s*(%d+)"))
		if n then return n end
		cur = cur.Parent
	end
	return nil
end

local function ancestorModel(inst)
	local cur = inst.Parent
	while cur and cur ~= workspace do
		if cur:IsA("Model") then return cur end
		cur = cur.Parent
	end
	return nil
end

local function zonePosition(z)
	local eggs = z:FindFirstChild("Eggs", true)
	if eggs then
		for _, e in ipairs(eggs:GetChildren()) do
			local ok, cf = pcall(function() return e:GetPivot() end)
			if ok and cf.Position.Magnitude > 1 then return cf.Position end
		end
	end
	local minV, maxV
	for _, d in ipairs(z:GetDescendants()) do
		if d:IsA("BasePart") then
			local p = d.Position
			if not minV then minV, maxV = p, p
			else
				minV = Vector3.new(math.min(minV.X, p.X), math.min(minV.Y, p.Y), math.min(minV.Z, p.Z))
				maxV = Vector3.new(math.max(maxV.X, p.X), math.max(maxV.Y, p.Y), math.max(maxV.Z, p.Z))
			end
		end
	end
	if minV then
		local c = (minV + maxV) / 2
		return Vector3.new(c.X, maxV.Y + 8, c.Z)
	end
	if z:IsA("Model") then
		local ok, cf = pcall(function() return z:GetPivot() end)
		if ok and cf.Position.Magnitude > 1 then return cf.Position + Vector3.new(0, 10, 0) end
	end
	return nil
end

local function buildAnchors()
	local build = workspace:FindFirstChild("Build")
	local zb = build and build:FindFirstChild("ZoneBuilds")
	if zb then
		for _, z in ipairs(zb:GetChildren()) do
			local n = tonumber(string.match(z.Name, "(%d+)"))
			local areaName = n and AREAS[n + 1]
			if areaName and areaName ~= "Other" and areaName ~= "All" then
				local pos = zonePosition(z)
				if pos then anchors[areaName] = pos end
			end
		end
	end
	if build then
		local pool = {}
		for _, d in ipairs(build:GetDescendants()) do
			if d:IsA("Model") or d:IsA("Folder") then table.insert(pool, d) end
		end
		for areaName, keys in pairs(NAME_KEYS) do
			if not anchors[areaName] then
				for _, key in ipairs(keys) do
					for _, d in ipairs(pool) do
						if string.find(norm(d.Name), key, 1, true) then
							local pos = zonePosition(d)
							if pos then anchors[areaName] = pos break end
						end
					end
					if anchors[areaName] then break end
				end
			end
		end
	end
end

local function streamAreas()
	if State.area == "All" then
		for _, pos in pairs(anchors) do pcall(function() lp:RequestStreamAroundAsync(pos, CONFIG.STREAM_TIMEOUT) end) end
	else
		local pos = anchors[State.area]
		if pos then pcall(function() lp:RequestStreamAroundAsync(pos, CONFIG.STREAM_TIMEOUT) end) end
	end
end

-- registry telur: diisi sekali + update lewat event, jadi nggak ada scan seluruh map yang bikin nge-lag
local eggSet = {}
local realCache = setmetatable({}, { __mode = "k" })
local function isAnimal(m)
	return m:FindFirstChildOfClass("Humanoid") ~= nil
		or m:FindFirstChildWhichIsA("AnimationController", true) ~= nil
		or m:FindFirstChildWhichIsA("Animator", true) ~= nil
end
-- telur beneran: bukan hewan/pet hasil netas
local function isRealEgg(m)
	if realCache[m] then return true end
	if isAnimal(m) then return false end
	local eggNamed = hasAny(m.Name, { "egg", "telur" })
	if not eggNamed and hasAny(m.Name, { "pet", "animal", "hewan", "npc", "guard", "penjaga" }) then return false end
	if m:FindFirstChild("EggInfoUi", true) or m:FindFirstChild("EggOverhead", true)
		or m:FindFirstChild(hitName, true) or m:FindFirstChild("Egg", true)
		or (m.Parent and m.Parent.Name == "Eggs") then
		realCache[m] = true
		return true
	end
	return false
end
local function considerEgg(d)
	local n = d.Name
	if n == "EggInfoUi" or n == "EggOverhead" then
		local m = ancestorModel(d)
		if m then eggSet[m] = true end
	elseif d:IsA("Model") then
		local par = d.Parent
		if par and par.Name == "Eggs" then
			eggSet[d] = true
		elseif hasAny(n, { "egg", "telur" }) then
			local skip, p = false, par
			while p and p ~= workspace do
				if p:IsA("Tool") or (p:IsA("Model") and (hasAny(p.Name, { "egg", "telur" }) or Players:GetPlayerFromCharacter(p))) then skip = true break end
				p = p.Parent
			end
			if not skip and not Players:GetPlayerFromCharacter(d) then eggSet[d] = true end
		end
	end
end
task.spawn(function()
	for i, d in ipairs(workspace:GetDescendants()) do
		pcall(considerEgg, d)
		if i % 2500 == 0 then task.wait() end
	end
end)
workspace.DescendantAdded:Connect(function(d) pcall(considerEgg, d) end)
workspace.DescendantRemoving:Connect(function(d) eggSet[d] = nil end)

local function collect()
	local out, seen, counts, seenKeys = {}, {}, {}, {}
	local function add(model)
		if not model or seen[model] then return end
		seen[model] = true
		local n = zoneNumber(model)
		local areaName = (n and AREAS[n + 1] and AREAS[n + 1] ~= "Other") and AREAS[n + 1] or "Other"
		local key = model:GetFullName()
		seenKeys[key] = true
		local ok, cf = pcall(function() return model:GetPivot() end)
		if ok then known[key] = { pos = cf.Position, area = areaName } end
		counts[areaName] = (counts[areaName] or 0) + 1
		table.insert(out, { model = model, area = areaName, key = key })
	end
	for m in pairs(eggSet) do
		if m.Parent then add(m) else eggSet[m] = nil end
	end
	local areaHasEgg = {}
	local rootNow = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	for key, k in pairs(known) do
		if not seenKeys[key] and rootNow and (k.pos - rootNow.Position).Magnitude < 160 then
			known[key] = nil -- kita deket tapi telurnya udah nggak ada = udah pecah, jangan didatangi lagi
		else
			areaHasEgg[k.area] = true
			if not seenKeys[key] then table.insert(out, { ghost = true, pos = k.pos, area = k.area, key = key }) end
		end
	end
	for areaName, pos in pairs(anchors) do
		if not areaHasEgg[areaName] and not counts[areaName] and not (rootNow and (pos - rootNow.Position).Magnitude < 160) then
			table.insert(out, { ghost = true, pos = pos, area = areaName, key = "anchor:" .. areaName })
		end
	end
	local c = 0
	for _ in pairs(counts) do c = c + 1 end
	areaCount = c
	return out, counts
end

local function refresh(force, verbose)
	if force or os.clock() - lastScan > CONFIG.RESCAN_EVERY then
		local ok, res = pcall(collect)
		if ok then cache = res end
		lastScan = os.clock()
	end
end

local function hrp()
	local c = lp.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

lp.CharacterAdded:Connect(function(c)
	local r = c:WaitForChild("HumanoidRootPart", 5)
	if r then
		task.wait(0.6)
		if r.Parent then spawnSeen = r.Position end
	end
end)

local function isUsable(t)
	if not t.model or not t.model.Parent then return false end
	if not isRealEgg(t.model) then return false end
	local part = hitPart(t.model)
	if not part then return false end
	if part.Transparency >= 0.99 then return false end
	return true
end


local function eggAlive(model)
	if not model or not model.Parent then return false end
	local part = hitPart(model)
	return part ~= nil and part.Parent ~= nil and part.Transparency < 0.99
end

-- pukul terus sampai telur ini beneran pecah, baru pindah. Dicatat waktu, jadi nggak balik lagi ke telur yg sama.
local function breakEgg(model, repos)
	local t0 = os.clock()
	local function dead()
		local part = hitPart(model)
		return not (model.Parent and part and part.Parent and part.Transparency < 0.99)
	end
	while State.enabled and State.alive and os.clock() - t0 < CONFIG.BREAK_TIMEOUT do
		if dead() then break end
		local part = hitPart(model)
		if hitRemote and part then pcall(function() hitRemote:FireServer(part, hitArg) end) end
		-- server nolak = pelan dikit; aman = pelan-pelan ngebut lagi (biar nggak kena limit terus diem)
		if rejects ~= KH.rejSeen then
			KH.rejSeen = rejects
			hitDelay = math.min(hitDelay + 0.03, 0.35)
			if repos then repos(true) end
		elseif hitDelay > CONFIG.HIT_DELAY then
			hitDelay = math.max(CONFIG.HIT_DELAY, hitDelay - 0.004)
		end
		local tw = os.clock()
		while os.clock() - tw < hitDelay do
			task.wait()
			if dead() then break end
		end
	end
	local ok = dead()
	if ok and os.clock() - t0 > 0.5 then KH.reason = "pukulan lambat (delay " .. string.format("%.2f", hitDelay) .. ")" end
	return ok
end

local function isVisited(key)
	local v = visited[key]
	return v and v > os.clock()
end

local function markVisited(key, dur)
	visited[key] = os.clock() + (dur or CONFIG.REVISIT)
end

local doneModel = setmetatable({}, { __mode = "k" })
local function isDone(t)
	if isVisited(t.key) then return true end
	local d = t.model and doneModel[t.model]
	return d ~= nil and d > os.clock()
end

-- jatah per telur cuma ~0.3 detik. Pecah / nggak, langsung pindah ke telur lain.
-- Telur yang masih hidup (HP banyak) dicoba lagi nanti, bukan ditungguin.
local function doBreak(t, repos)
	local r0 = rejects
	local ok = breakEgg(t.model, repos)
	doneModel[t.model] = os.clock() + 6
	if ok then known[t.key] = nil end
	-- mulus tanpa tolakan -> pelan-pelan balik ke jarak aman yang jauh dari ledakan
	if ok and rejects == r0 then KH.stand = math.min(State.standoff, (KH.stand or State.standoff) + 0.5) end
	return ok
end

local function inArea(t)
	return State.area == "All" or t.area == State.area
end

local function pickNext(root)
	local best, bestD, ghost, ghostD
	local now = os.clock()
	for _, t in ipairs(cache) do
		if inArea(t) and not isDone(t) and not (blocked[t.area] and blocked[t.area] > now) then
			if t.ghost then
				if not State.breakOnly and not (ghostCool[t.key] and ghostCool[t.key] > now) then
					local d = (t.pos - root.Position).Magnitude
					if not ghostD or d < ghostD then ghost, ghostD = t, d end
				end
			elseif t.model and t.model.Parent then
				local d = (t.model:GetPivot().Position - root.Position).Magnitude
				if (not State.breakOnly or d <= CONFIG.NEAR_DISTANCE) and (not bestD or d < bestD) and isUsable(t) then best, bestD = t, d end
			end
		end
	end
	return best or ghost
end

local function loadArea(root, t)
	statusText = "Muat area: " .. t.area
	pcall(function() lp:RequestStreamAroundAsync(t.pos, 0.8) end)
	root.CFrame = CFrame.new(t.pos + Vector3.new(0, 4, 14))
	pcall(function() root.Anchored = true end)
	local isAnchor = string.sub(t.key, 1, 7) == "anchor:"
	local t0, found = os.clock(), false
	while os.clock() - t0 < 0.8 and State.enabled and State.alive do
		task.wait(0.05)
		refresh(true)
		for _, c in ipairs(cache) do
			if not c.ghost and ((isAnchor and c.area == t.area) or c.key == t.key) then found = true break end
		end
		if found then break end
	end
	if not found and not isAnchor then known[t.key] = nil end
	pcall(function() root.Anchored = false end)
end

local function markBreak(model)
	local ok, cf = pcall(function() return model:GetPivot() end)
	if ok then lastBreakPos, lastBreakT = cf.Position, os.clock() end
	stealPoke = os.clock()
end

-- abis telur pecah: jangan lanjut ke telur berikutnya dulu, kasih steal loop
-- kesempatan ambil pet yang baru netas (scan ulang tiap 0.25s sampai pet muncul)
local function handoffSteal()
	if not (State.autoSteal and State.alive) then return end
	local t0, lastPoke = os.clock(), 0
	while os.clock() - t0 < CONFIG.HANDOFF_WAIT and not stealing and State.alive and State.autoSteal do
		if os.clock() - lastPoke > 0.25 then lastPoke = os.clock() stealPoke = lastPoke end
		task.wait(0.05)
	end
end

local wasEnabled, lastArea = false, State.area

-- scan telur di thread sendiri: loop break nggak ke-stall nunggu scan
task.spawn(function()
	while State.alive do
		if State.enabled then refresh(true) end
		task.wait(0.4)
	end
end)

-- siapin area berikutnya di belakang layar, biar pas egg sini abis egg sana udah ke-load (nggak nunggu)
task.spawn(function()
	while State.alive do
		if State.enabled and not State.breakOnly then
			local root = hrp()
			if root then
				local best, bd, now = nil, nil, os.clock()
				for _, t in ipairs(cache) do
					if t.ghost and inArea(t) and not (ghostCool[t.key] and ghostCool[t.key] > now) then
						local d = (t.pos - root.Position).Magnitude
						if not bd or d < bd then best, bd = t, d end
					end
				end
				if best then pcall(function() lp:RequestStreamAroundAsync(best.pos, 0.6) end) end
			end
		end
		task.wait(0.3)
	end
end)

local function farmStep()
	while stealing and State.alive do task.wait(0.1) end
	if State.breakAnywhere then
		if os.clock() - lastAnywhereStream > CONFIG.ANYWHERE_RESCAN then
			streamAreas()
			lastAnywhereStream = os.clock()
		end
		local t = nil
		for _, c in ipairs(cache) do
			if inArea(c) and not c.ghost and isUsable(c) and not isDone(c) then t = c break end
		end
		if t then
			doBreak(t)
			statusText = "[Anywhere][" .. t.area .. "] " .. t.model.Name
			markBreak(t.model)
			handoffSteal()
		else
			statusText = "Anywhere: nunggu telur..."
			task.wait(0.1)
		end
		return
	end

	local root = hrp()
	if not root then task.wait(0.2) return end
	if not wasEnabled or lastArea ~= State.area then
		visited, blocked, areaRejects = {}, {}, {}
		refresh(true, true)
	end
	wasEnabled, lastArea = true, State.area
	if State.skipAnim then fixCamera() end

	local t = pickNext(root)
	if not t then
		statusText = "Nunggu telur muncul..."
		KH.reason = "nunggu telur"
		task.wait(0.1)
		return
	end
	curArea = t.area
	if t.ghost then
		ghostCool[t.key] = os.clock() + CONFIG.GHOST_COOLDOWN
		KH.reason = "pindah/muat area " .. t.area
		loadArea(root, t)
		return
	end
	local repos = nil
	if not State.breakOnly then
		local function place(shrink)
			if shrink then
				if os.clock() - (KH.lastRepos or 0) < 0.15 then return end
				KH.lastRepos = os.clock()
				KH.stand = math.max(5, math.min(KH.stand or State.standoff, State.standoff) - 3)
			end
			local r = hrp()
			if not (r and t.model.Parent) then return end
			local ep = t.model:GetPivot().Position
			local flat = Vector3.new(r.Position.X - ep.X, 0, r.Position.Z - ep.Z)
			local dir = flat.Magnitude > 0.5 and flat.Unit or Vector3.new(0, 0, 1)
			local stand = math.clamp(math.min(KH.stand or State.standoff, State.standoff), 5, 22)
			r.CFrame = CFrame.new(ep + dir * stand + Vector3.new(0, 4, 0), ep)
			pcall(function() r.AssemblyLinearVelocity = Vector3.zero end)
		end
		place(false)
		repos = place
		task.wait(CONFIG.SETTLE)
	end
	doBreak(t, repos)
	statusText = "[" .. t.area .. "] " .. t.model.Name
	markBreak(t.model)
	handoffSteal()
end

task.spawn(function()
	while State.alive do
		if State.enabled then
			local ts = os.clock()
			KH.reason = ""
			local ok, err = pcall(farmStep)
			local dur = os.clock() - ts
			if dur > 0.6 and KH.reason ~= "" then KH.stall = string.format("Diem terakhir: %.1fs (%s)", dur, KH.reason) end
			if not ok then
				statusText = "err: " .. string.sub(tostring(err), 1, 60)
				warn("[KennHub] farm error: " .. tostring(err))
				local r = hrp()
				if r then pcall(function() r.Anchored = false end) end
				task.wait(0.3)
			end
		else
			wasEnabled = false
			statusText = "Mati"
			task.wait(0.15)
		end
		task.wait()
	end
end)

----------------------------------------------------------------
-- Auto Steal (Instant / Safe / Walk / Anywhere / Dodge)
----------------------------------------------------------------
local home = nil
do
	local r = hrp()
	if r then home = r.Position end
end

local function ownsInst(inst)
	local function matches(v)
		return v == lp.UserId or v == lp.Name or v == lp.DisplayName or v == tostring(lp.UserId) or (typeof(v) == "Instance" and v == lp)
	end
	for _, v in pairs(inst:GetAttributes()) do if matches(v) then return true end end
	for _, c in ipairs(inst:GetChildren()) do
		if c:IsA("ValueBase") then
			local ok, v = pcall(function() return c.Value end)
			if ok and matches(v) then return true end
		end
	end
	return false
end

local myPlotCache
local function myPlot()
	if myPlotCache and myPlotCache.Parent then return myPlotCache end
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, p in ipairs(plots:GetChildren()) do
		if ownsInst(p) then myPlotCache = p return p end
	end
	return nil
end

local function plotOf(inst)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local cur = inst
	while cur and cur.Parent and cur.Parent ~= plots do cur = cur.Parent end
	if cur and cur.Parent == plots then return cur end
	return nil
end

local function homePos()
	local p = myPlot()
	if p then
		local ok, cf = pcall(function() return p:GetPivot() end)
		if ok then return cf.Position + Vector3.new(0, 6, 0) end
	end
	return home
end

local function promptPos(pp)
	local cur = pp.Parent
	while cur and cur ~= workspace do
		if cur:IsA("Attachment") then return cur.WorldPosition end
		if cur:IsA("BasePart") then return cur.Position end
		if cur:IsA("Model") then
			local ok, cf = pcall(function() return cur:GetPivot() end)
			if ok then return cf.Position end
		end
		cur = cur.Parent
	end
	return nil
end

local function collectSteal()
	local out = {}
	local mine = myPlot()
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") and hasAny(d.ActionText .. " " .. d.ObjectText .. " " .. d.Name, CONFIG.STEAL_KEYS) then
			local pl = plotOf(d)
			local mineHit = mine and pl == mine
			local onMe = lp.Character and d:IsDescendantOf(lp.Character)
			if not mineHit and not onMe then table.insert(out, d) end
		end
	end
	return out
end

local function othersNear(pos, r)
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= lp and pl.Character then
			local rp = pl.Character:FindFirstChild("HumanoidRootPart")
			if rp and (rp.Position - pos).Magnitude <= r then return true end
		end
	end
	return false
end

local function firePrompt(pp)
	pcall(function() pp.HoldDuration = 0 end)
	if fireproximityprompt then pcall(fireproximityprompt, pp) end
end

local function holdPrompt(pp)
	pcall(function()
		pp:InputHoldBegin()
		task.wait(math.max(pp.HoldDuration, 0.05) + 0.1)
		pp:InputHoldEnd()
	end)
	if fireproximityprompt then pcall(fireproximityprompt, pp) end
end

local function walkTo(pos, timeout)
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = hrp()
	if not (hum and root) then return false end
	local t0 = os.clock()
	local function reach(p)
		hum:MoveTo(p)
		while os.clock() - t0 < timeout and State.autoSteal and State.alive do
			task.wait(0.1)
			root = hrp()
			if not root then return false end
			if (root.Position - p).Magnitude < 4 then return true end
		end
		return false
	end
	local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
	local ok = pcall(function() path:ComputeAsync(root.Position, pos) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for _, wp in ipairs(path:GetWaypoints()) do
			if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
			if not reach(wp.Position) and os.clock() - t0 >= timeout then break end
		end
	else
		reach(pos)
	end
	root = hrp()
	return root ~= nil and (root.Position - pos).Magnitude < 8
end

-- === Dodge mode helpers ===
local function pivotPos(inst)
	if inst:IsA("Model") then
		local ok, cf = pcall(function() return inst:GetPivot() end)
		return ok and cf.Position or nil
	end
	return inst.Position
end

-- cari guard: prioritas Model yang punya Humanoid, lalu Model biasa, lalu Part
local function findGuard()
	local root = hrp()
	if not root then return nil end
	local pick, pickD = {}, {}
	for _, d in ipairs(workspace:GetDescendants()) do
		local isModel, isPart = d:IsA("Model"), d:IsA("BasePart")
		if (isModel or isPart) and hasAny(d.Name, CONFIG.DODGE.GUARD_KEYS) and not (lp.Character and d:IsDescendantOf(lp.Character)) then
			local rank = isModel and (d:FindFirstChildOfClass("Humanoid") and 1 or 2) or 3
			local pos = pivotPos(d)
			if pos then
				local dist = (pos - root.Position).Magnitude
				if not pickD[rank] or dist < pickD[rank] then pick[rank], pickD[rank] = { inst = d, pos = pos }, dist end
			end
		end
	end
	local r = pick[1] or pick[2] or pick[3]
	if r then return r.inst, r.pos end
	return nil
end

-- Nabrak guard TANPA pental: nggak TP ke dalam badannya (itu yang bikin tabrakan
-- fisik ngelempar). Mulai dari samping, geser pelan masuk ke badan guard,
-- tabrakan fisik guard dimatiin di sisi kita, dan kecepatan kita di-nol-in tiap
-- frame. Guard tetap diem, server tetap ngitung sentuhan dari posisi kita.
-- Balik true kalau kita keburu dipindah game (ke spawn) pas/ abis nabrak.
local function bumpGuard(guard, guardPos)
	local D = CONFIG.DODGE
	local root = hrp()
	if not root then return false end

	local saved = {}
	local function noCollide()
		local list = guard:GetDescendants()
		table.insert(list, guard)
		for _, d in ipairs(list) do
			if d:IsA("BasePart") then
				if saved[d] == nil then saved[d] = d.CanCollide end
				d.CanCollide = false
			end
		end
	end
	local function restore()
		for d, v in pairs(saved) do pcall(function() d.CanCollide = v end) end
		saved = {}
	end

	local relocated = false
	-- percobaan 1: guard dibikin nggak solid (anti pental). percobaan 2: guard
	-- apa adanya, kalau game butuh tabrakan fisik buat nge-trigger.
	for attempt = 1, 2 do
		root = hrp()
		if not root then break end
		local flat = Vector3.new(root.Position.X - guardPos.X, 0, root.Position.Z - guardPos.Z)
		if flat.Magnitude < 1 then flat = Vector3.new(0, 0, 1) end
		local startPos = guardPos + flat.Unit * D.BUMP_START_DIST
		local t0, last = os.clock(), nil
		while os.clock() - t0 < D.LAND_WAIT and State.alive do
			root = hrp()
			if not root then break end
			local pos = root.Position
			local el = os.clock() - t0
			-- game mindahin kita = lompatan posisi yang bukan dari kita
			if last and (pos - last).Magnitude > D.JUMP_DIST then relocated = true break end
			if el > 0.2 and (pos - guardPos).Magnitude > D.LAND_DIST then relocated = true break end
			if attempt == 1 then pcall(noCollide) end
			if el < D.BUMP_HOLD then
				local k = math.clamp(el / D.BUMP_APPROACH, 0, 1)
				local np = startPos:Lerp(guardPos, k)
				root.CFrame = CFrame.new(np)
				last = np
			else
				last = pos
			end
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			RunService.Heartbeat:Wait()
		end
		restore()
		if relocated then break end
	end
	restore()
	return relocated
end

local function findPickupPrompt(pos, radius)
	local best, bestD
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") and d.Enabled then
			local txt = d.ActionText .. " " .. d.ObjectText .. " " .. d.Name
			if hasAny(txt, CONFIG.DODGE.PICKUP_KEYS) or hasAny(txt, CONFIG.STEAL_KEYS) then
				local p = promptPos(d)
				if p then
					local dist = (p - pos).Magnitude
					if dist <= radius and (not bestD or dist < bestD) then best, bestD = d, dist end
				end
			end
		end
	end
	return best
end

local function guiShown(d)
	local cur = d
	while cur and cur ~= game do
		if cur:IsA("GuiObject") and not cur.Visible then return false end
		if cur:IsA("ScreenGui") and not cur.Enabled then return false end
		cur = cur.Parent
	end
	return true
end

-- tombol "Jatuhkan" cuma muncul pas lagi bawa pet -> sekalian jadi penanda "lagi bawa"
local function findDropControl()
	local pg = lp:FindFirstChild("PlayerGui")
	if not pg then return nil end
	for _, d in ipairs(pg:GetDescendants()) do
		if (d:IsA("TextButton") or d:IsA("TextLabel")) and not (gui and d:IsDescendantOf(gui)) then
			local txt = norm(d.Text)
			if txt ~= "" and table.find(CONFIG.DODGE.DROP_BTN_TEXTS, txt) and guiShown(d) then
				local b = d
				while b and not b:IsA("GuiButton") do b = b.Parent end
				return b or d
			end
		end
	end
	return nil
end

local function pressGui(btn)
	if not (btn and btn:IsA("GuiButton") and firesignal) then return end
	pcall(function() firesignal(btn.MouseButton1Click) end)
	pcall(function() firesignal(btn.Activated) end)
end

-- titik drop = tempat spawn (foto 3). Prioritas: posisi spawn yang beneran
-- kepantau pas karakter spawn -> RespawnLocation -> SpawnLocation terdekat base.
local function spawnSpot()
	if spawnSeen then return spawnSeen end
	local rl = lp.RespawnLocation
	if rl and rl.Parent then return rl.Position + Vector3.new(0, 4, 0) end
	local h = homePos()
	local best, bestD
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("SpawnLocation") then
			local dist = h and (d.Position - h).Magnitude or 0
			if not bestD or dist < bestD then best, bestD = d, dist end
		end
	end
	if best then return best.Position + Vector3.new(0, 4, 0) end
	return nil
end

local function findStealNear(pos, r)
	local best, bestD
	for _, d in ipairs(collectSteal()) do
		if d.Enabled then
			local p = promptPos(d)
			if p then
				local dist = (p - pos).Magnitude
				if dist <= r and (not bestD or dist < bestD) then best, bestD = d, dist end
			end
		end
	end
	return best
end

-- prompt bisa ke-streaming-out lalu muncul lagi sbg instance baru -> cari ulang
-- berdasarkan posisi setelah kita nyampe
local function resolvePrompt(pp, pos)
	if pp and pp.Parent then return pp end
	local t0 = os.clock()
	while os.clock() - t0 < CONFIG.STEAL_RESOLVE_WAIT and State.alive do
		local f = findStealNear(pos, 25)
		if f then return f end
		task.wait(0.15)
	end
	return nil
end

-- Alur (sesuai video): TP ke pet -> steal (dicek beneran kebawa) -> TP ke guard
-- (nabrak, guard diem, nggak pental) -> TP ke spawn -> drop -> jeda -> ambil
-- lagi -> bawa masuk safe zone (base). Nggak pakai respawn.
local function dodgeSteal(pp, bestPos)
	local D = CONFIG.DODGE
	local root = hrp()
	if not root then return end

	-- 1) TP ke pet yang baru netas -> steal
	stealText = "Dodge: TP ke pet"
	root.CFrame = CFrame.new(bestPos + Vector3.new(0, 3, 0))
	task.wait(jitter(0.12))
	pp = resolvePrompt(pp, bestPos)
	if not pp then
		stealText = "Dodge: pet udah nggak ada"
		return
	end

	stealText = "Dodge: steal"
	local got = false
	for i = 1, 4 do
		if not pp.Parent then
			pp = resolvePrompt(nil, bestPos)
			if not pp then break end
		end
		if i % 2 == 0 then holdPrompt(pp) else firePrompt(pp) end
		task.wait(jitter(0.25))
		if findDropControl() then
			got, detectOK = true, true
			break
		end
		if not detectOK then got = true break end -- belum bisa deteksi "lagi bawa", anggap berhasil
	end
	if not got then
		stealText = "Dodge: steal gagal"
		return
	end

	-- 2) TP ke penjaga (nabrak) -> game mindahin kita ke spawn
	root = hrp()
	if not root then return end
	local moved = false
	local guard, guardPos = findGuard()
	if guard then
		stealText = "Dodge: TP ke penjaga"
		moved = bumpGuard(guard, guardPos)
	else
		stealText = "Dodge: penjaga nggak ketemu (lihat console)"
		task.wait(0.3)
	end

	root = hrp()
	if not root then return end
	if not moved then
		stealText = "Dodge: penjaga nggak mindahin, TP manual ke spawn"
		local sp = spawnSpot()
		if sp then
			root.CFrame = CFrame.new(sp)
		else
			local h = homePos()
			if not h then
				stealText = "Dodge: spawn & base nggak ketemu"
				return
			end
			local dir = root.Position - h
			if dir.Magnitude < 1 then dir = Vector3.new(0, 0, 1) end
			root.CFrame = CFrame.new(h + dir.Unit * D.DROP_MARGIN + Vector3.new(0, 3, 0))
		end
	end
	task.wait(jitter(0.25))

	-- 3) drop pet di spawn
	root = hrp()
	if not root then return end
	local dropPos = root.Position
	local carrying = findDropControl() ~= nil
	if carrying then detectOK = true end
	if detectOK and not carrying then
		stealText = "Dodge: pet nggak kebawa abis nabrak, ulang"
		return
	end

	stealText = "Dodge: drop pet"
	local dropRemote = RS:FindFirstChild("DropCarriedRemote")
	if dropRemote then pcall(function() dropRemote:FireServer() end) end
	task.wait(jitter(0.25))
	for _ = 1, 3 do
		local ctl = findDropControl()
		if not ctl then break end
		pressGui(ctl)
		task.wait(jitter(0.25))
	end
	task.wait(jitter(D.DROP_WAIT))

	-- 4) steal lagi (nunggu prompt aktif, dicek beneran kebawa)
	stealText = "Dodge: steal lagi"
	local pickedUp = not carrying
	local tPick = os.clock()
	while not pickedUp and State.alive and os.clock() - tPick < D.PICKUP_POLL do
		root = hrp()
		if not root then return end
		if (root.Position - dropPos).Magnitude > 8 then
			root.CFrame = CFrame.new(dropPos + Vector3.new(0, 3, 0))
			task.wait(jitter(0.2))
		end
		local pickup = findPickupPrompt(dropPos, D.PICKUP_RADIUS)
		if pickup and pickup.Enabled then
			holdPrompt(pickup)
			task.wait(jitter(0.35))
			if findDropControl() then pickedUp = true break end
		else
			task.wait(0.2)
		end
	end
	if not pickedUp then
		stealText = "Dodge: prompt ambil lagi nggak ketemu (lihat console)"
		return
	end

	-- 5) bawa ke safe zone
	root = hrp()
	local safePos = homePos()
	if root and safePos then
		stealText = "Dodge: bawa masuk safe zone"
		root.CFrame = CFrame.new(safePos)
	end
end

local stealSeen, lastStealScan, stealCool = {}, 0, {}

local function stealAreaOk(pp)
	local n = zoneNumber(pp)
	local areaName = n and AREAS[n + 1] or nil
	if State.area ~= "All" then
		return areaName == nil or areaName == State.area
	end
	return not (areaName and CONFIG.STEAL_SKIP_AREAS[areaName])
end

local function posKey(pos)
	return math.floor(pos.X / 6) .. ":" .. math.floor(pos.Z / 6)
end

local function scanSteal()
	local ok, res = pcall(collectSteal)
	if not ok then return end
	local now = os.clock()
	for _, pp in ipairs(res) do
		local pos = promptPos(pp)
		if pos then stealSeen[pp] = { pp = pp, pos = pos, t = now } end
	end
	lastStealScan = now
end

-- kandidat = prompt yang lagi ke-load + prompt yang barusan ke-streaming-out
-- (diingat posisinya STEAL_MEMORY detik, TP ke situ bakal nge-load lagi)
local function stealCandidates()
	local out, now = {}, os.clock()
	for pp, e in pairs(stealSeen) do
		local alive = pp.Parent ~= nil
		if not alive and now - e.t > CONFIG.STEAL_MEMORY then
			stealSeen[pp] = nil
		else
			local pos = e.pos
			if alive then
				pos = promptPos(pp) or e.pos
				e.pos = pos
			end
			if pos and (not alive or pp.Enabled) and (not alive or stealAreaOk(pp)) then
				table.insert(out, { pp = pp, pos = pos, alive = alive })
			end
		end
	end
	return out
end

task.spawn(function()
	local was = false
	while State.alive do
		if State.autoSteal then
			if not was then
				was = true
				if not myPlot() then
					local r = hrp()
					if r then home = r.Position end
				end
			end

			local root = hrp()
			if root and (os.clock() - lastStealScan > CONFIG.STEAL_SCAN_EVERY or stealPoke > lastStealScan) then
				scanSteal()
			end

			if root then
				local cands = stealCandidates()
				local best, bestD
				local ref = root.Position
				if lastBreakPos and os.clock() - lastBreakT < 8 then ref = lastBreakPos end
				for _, c in ipairs(cands) do
					local k = posKey(c.pos)
					if (c.alive or State.stealMode == "Dodge") and not (stealCool[k] and stealCool[k] > os.clock()) then
						if State.stealMode ~= "Safe" or not othersNear(c.pos, CONFIG.SAFE_RADIUS) then
							local d = (c.pos - ref).Magnitude
							if not bestD or d < bestD then best, bestD = c, d end
						end
					end
				end

				if best then
					stealing = true
					stealCool[posKey(best.pos)] = os.clock() + CONFIG.STEAL_COOLDOWN
					if not best.alive then stealSeen[best.pp] = nil end
					local pp, bestPos = best.pp, best.pos
					local h = homePos()
					local mode = State.stealMode
					stealText = "Steal (" .. mode .. ")"

					if mode == "Instant" then
						local back = root.CFrame
						root.CFrame = CFrame.new(bestPos + Vector3.new(0, 3, 0))
						task.wait(0.08)
						firePrompt(pp)
						task.wait(0.15)
						root = hrp()
						if root then root.CFrame = h and CFrame.new(h) or back end
					elseif mode == "Safe" then
						local back = root.CFrame
						root.CFrame = CFrame.new(bestPos + Vector3.new(0, 3, 0))
						task.wait(0.35)
						if othersNear(bestPos, CONFIG.SAFE_RADIUS) then
							stealText = "Safe: ada orang, batal"
						else
							holdPrompt(pp)
							task.wait(0.4)
						end
						root = hrp()
						if root then root.CFrame = h and CFrame.new(h) or back end
					elseif mode == "Walk" then
						if walkTo(bestPos, CONFIG.WALK_TIMEOUT) then
							holdPrompt(pp)
							task.wait(0.3)
						else
							stealText = "Walk: gagal sampai"
						end
						if h then walkTo(h, CONFIG.WALK_TIMEOUT) end
					elseif mode == "Dodge" then
						dodgeSteal(pp, bestPos)
					else -- Anywhere
						firePrompt(pp)
						task.wait(jitter(0.25))
					end

					stealCount = stealCount + 1
					task.wait(jitter(CONFIG.STEAL_AFTER))
					stealing = false
				else
					stealText = "Steal: nunggu target (" .. #cands .. ")"
				end
			end
		else
			was = false
			stealing = false
		end
		task.wait((os.clock() - stealPoke < 2) and 0.05 or 0.25)
	end
end)

-- Streamer latar: muterin anchor semua area (atau area yang dipilih) biar
-- telur & pet ke-load tanpa kita harus jalan ke sana dulu. Auto Steal & Break
-- jadi bisa jalan dari dalam safe zone.
task.spawn(function()
	local list, idx, lastAnchorTry = {}, 0, 0
	while State.alive do
		local active = State.enabled or State.autoSteal
		if active then
			if idx >= #list then
				if next(anchors) == nil and os.clock() - lastAnchorTry > 10 then
					lastAnchorTry = os.clock()
					pcall(buildAnchors)
				end
				list, idx = {}, 0
				if State.area == "All" then
					for _, pos in pairs(anchors) do table.insert(list, pos) end
				elseif anchors[State.area] then
					table.insert(list, anchors[State.area])
				end
			end
			idx = idx + 1
			local pos = list[idx]
			if pos then
				pcall(function() lp:RequestStreamAroundAsync(pos, CONFIG.STREAM_TIMEOUT) end)
				if State.enabled then refresh(false) end
				if State.autoSteal and os.clock() - lastStealScan > 0.5 then scanSteal() end
			end
		end
		task.wait(active and 0.15 or 0.6)
	end
end)

----------------------------------------------------------------
-- Auto Treadmill
----------------------------------------------------------------
local tmEntries, lastTMScan = {}, 0
local tmDir = nil
local tmText = "Treadmill: mati"

local function isTreadmillName(inst)
	local nm = norm(inst.Name)
	return string.find(nm, "treadmill", 1, true) ~= nil and string.find(nm, "vfx", 1, true) == nil
end

local function insideFound(inst, found)
	local cur = inst.Parent
	while cur and cur ~= workspace do
		if found[cur] then return true end
		cur = cur.Parent
	end
	return false
end

local function findTreadmills()
	local out, found = {}, {}
	local function add(inst)
		if found[inst] then return end
		found[inst] = true
		local pp = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
		table.insert(out, { inst = inst, prompt = pp })
	end
	for _, d in ipairs(workspace:GetDescendants()) do
		if not (lp.Character and d:IsDescendantOf(lp.Character)) then
			if (d:IsA("Model") or d:IsA("BasePart")) and isTreadmillName(d) and not insideFound(d, found) then
				add(d)
			elseif d:IsA("Folder") and isTreadmillName(d) then
				for _, c in ipairs(d:GetChildren()) do
					if (c:IsA("Model") or c:IsA("BasePart")) and not insideFound(c, found) then add(c) end
				end
			end
		end
	end
	return out
end

local function treadmillTop(inst)
	local ok, pos = pcall(function()
		if inst:IsA("Model") then
			local cf, size = inst:GetBoundingBox()
			return cf.Position + Vector3.new(0, size.Y / 2 + 3, 0)
		end
		return inst.Position + Vector3.new(0, inst.Size.Y / 2 + 3, 0)
	end)
	return ok and pos or nil
end

local function treadmillLook(inst)
	local ok, look = pcall(function()
		if inst:IsA("Model") then return inst:GetPivot().LookVector end
		return inst.CFrame.LookVector
	end)
	if not ok then return nil end
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.1 then return nil end
	return flat.Unit
end

local function pickTreadmill(root)
	local mine = myPlot()
	local best, bestD, bestMine
	for _, e in ipairs(tmEntries) do
		if e.inst.Parent then
			local top = treadmillTop(e.inst)
			if top then
				local d = (top - root.Position).Magnitude
				local isMine = (mine ~= nil) and e.inst:IsDescendantOf(mine) or false
				local better = false
				if not best then better = true
				elseif isMine and not bestMine then better = true
				elseif isMine == bestMine and d < bestD then better = true end
				if better then best, bestD, bestMine = e, d, isMine end
			end
		end
	end
	return best
end

task.spawn(function()
	local lastPrompt = 0
	local wasOn = false
	while State.alive do
		if State.autoTreadmill then
			while stealing and State.alive do task.wait(0.1) end
			local root = hrp()
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if root and hum then
				if not wasOn or os.clock() - lastTMScan > CONFIG.TREADMILL_RESCAN then
					local ok, res = pcall(findTreadmills)
					if ok then tmEntries = res end
					lastTMScan = os.clock()
				end
				wasOn = true
				local e = pickTreadmill(root)
				if e then
					local top = treadmillTop(e.inst)
					if top then
						if (root.Position - top).Magnitude > CONFIG.TREADMILL_STAY then
							root.CFrame = CFrame.new(top)
							task.wait(0.25)
							lastPrompt = 0
						end
						if e.prompt and e.prompt.Parent and os.clock() - lastPrompt > CONFIG.TREADMILL_PROMPT_EVERY then
							lastPrompt = os.clock()
							holdPrompt(e.prompt)
						end
						tmDir = treadmillLook(e.inst) or Vector3.new(0, 0, -1)
						tmText = "Treadmill: " .. e.inst.Name
					end
				else
					tmDir = nil
					tmText = "Treadmill: tidak ketemu (" .. #tmEntries .. ")"
				end
			end
		else
			wasOn = false
			tmDir = nil
			tmText = "Treadmill: mati"
		end
		task.wait(0.2)
	end
end)

local tmConn = RunService.Heartbeat:Connect(function()
	if State.alive and State.autoTreadmill and tmDir and not stealing then
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:Move(tmDir, false) end) end
	end
end)

----------------------------------------------------------------
-- Performance / FPS Boost
----------------------------------------------------------------
local fpsOrig = { effects = {}, particles = {} }

local function setFps(on)
	if on then
		pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
		pcall(function() Lighting.GlobalShadows = false end)
		pcall(function() workspace.Terrain.Decoration = false end)
		for _, inst in ipairs(Lighting:GetDescendants()) do
			if inst:IsA("BloomEffect") or inst:IsA("SunRaysEffect") or inst:IsA("DepthOfFieldEffect") or inst:IsA("ColorCorrectionEffect") or inst:IsA("BlurEffect") then
				if fpsOrig.effects[inst] == nil then fpsOrig.effects[inst] = inst.Enabled end
				inst.Enabled = false
			end
		end
		for _, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire") or inst:IsA("Smoke") then
				if fpsOrig.particles[inst] == nil then fpsOrig.particles[inst] = inst.Enabled end
				inst.Enabled = false
			end
		end
	else
		pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.Automatic end)
		pcall(function() Lighting.GlobalShadows = true end)
		pcall(function() workspace.Terrain.Decoration = true end)
		for inst, v in pairs(fpsOrig.effects) do if inst.Parent then pcall(function() inst.Enabled = v end) end end
		for inst, v in pairs(fpsOrig.particles) do if inst.Parent then pcall(function() inst.Enabled = v end) end end
		fpsOrig.effects, fpsOrig.particles = {}, {}
	end
end

workspace.DescendantAdded:Connect(function(d)
	if State.fpsBoost and (d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Fire") or d:IsA("Smoke")) then
		task.defer(function() pcall(function() d.Enabled = false end) end)
	end
end)

-- seluruh UI dibungkus fungsi sendiri: batas variabel lokal Lua (200) dihitung per fungsi

do
----------------------------------------------------------------
-- Event
----------------------------------------------------------------
local EVENT_KEYS = { "event", "festival", "meteor", "special", "limited" }
local eventCool = {}

local function scanEvents()
	local out = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") and not (gui and d:IsDescendantOf(gui)) then
			local str = d:GetFullName() .. " " .. d.ActionText .. " " .. d.ObjectText
			if hasAny(str, EVENT_KEYS) then
				local pos = promptPos(d)
				if pos then table.insert(out, { pp = d, pos = pos }) end
			end
		end
	end
	return out
end

local function nearestEvent(list, from)
	local best, bd
	for _, e in ipairs(list) do
		local d = (e.pos - from).Magnitude
		if not bd or d < bd then best, bd = e, d end
	end
	return best
end

local function tpEvent()
	local root = hrp()
	if not root then return false end
	local e = nearestEvent(scanEvents(), root.Position)
	if not e then KH.txt.event = "Event: nggak ada yang aktif / belum ke-load" return false end
	pcall(function() lp:RequestStreamAroundAsync(e.pos, 2) end)
	root.CFrame = CFrame.new(e.pos + Vector3.new(0, 4, 4))
	KH.txt.event = "Event: TP ke " .. e.pp.Parent.Name
	return true
end

task.spawn(function()
	while State.alive do
		if State.autoEvent and not stealing then
			local root = hrp()
			if root then
				local list = scanEvents()
				if #list == 0 then
					KH.txt.event = "Event: nggak ada yang aktif"
				else
					KH.txt.event = "Event: " .. #list .. " ketemu"
					for _, e in ipairs(list) do
						if (eventCool[e.pp] or 0) < os.clock() then
							eventCool[e.pp] = os.clock() + 20
							local back = root.CFrame
							pcall(function() lp:RequestStreamAroundAsync(e.pos, 2) end)
							root.CFrame = CFrame.new(e.pos + Vector3.new(0, 4, 4))
							task.wait(0.3)
							holdPrompt(e.pp)
							task.wait(0.2)
							root.CFrame = back
							KH.txt.event = "Event: diambil (" .. e.pp.Parent.Name .. ")"
							break
						end
					end
				end
			end
			task.wait(3)
		else
			task.wait(0.5)
		end
	end
end)

----------------------------------------------------------------
-- Diamond Shop: beli plot (auto) + Diamond Magnet
----------------------------------------------------------------
local PLOT_BTN_KEYS = { "beli plot", "buy plot", "unlock plot", "buka plot", "beli lahan", "plot" }

local function buyPlotOnce()
	if learned and learned.remote and learned.remote.Parent then
		local ok = pcall(function()
			if learned.method == "InvokeServer" then
				learned.remote:InvokeServer(table.unpack(learned.args, 1, learned.args.n))
			else
				learned.remote:FireServer(table.unpack(learned.args, 1, learned.args.n))
			end
		end)
		KH.txt.shop = (ok and "Beli plot (rekaman): " or "Gagal kirim: ") .. learned.name
		return ok
	end
	local pg = lp:FindFirstChild("PlayerGui")
	if pg then
		for _, d in ipairs(pg:GetDescendants()) do
			if (d:IsA("TextButton") or d:IsA("TextLabel")) and d.Text ~= "" and d.Visible
				and hasAny(d.Text, { "beli plot", "buy plot", "unlock plot", "buka plot", "beli lahan" }) then
				local sg = d:FindFirstAncestorOfClass("ScreenGui")
				if sg and sg.Name ~= "KennHub_UI" then
					local o, btn = d, nil
					for _ = 1, 5 do
						if o and o:IsA("GuiButton") then btn = o break end
						o = o and o.Parent
					end
					if btn then
						KH.pressFirst(btn)
						KH.txt.shop = "Beli plot: klik tombol \"" .. d.Text .. "\""
						return true
					end
				end
			end
		end
	end
	for _, d in ipairs(RS:GetDescendants()) do
		if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and hasAny(d.Name, { "plot" })
			and hasAny(d.Name, { "buy", "purchase", "unlock", "beli" }) then
			pcall(function()
				if d:IsA("RemoteFunction") then d:InvokeServer() else d:FireServer() end
			end)
			KH.txt.shop = "Beli plot (tebak remote): " .. d.Name
			return true
		end
	end
	KH.txt.shop = "Beli plot: belum ketemu. Tekan Rekam, beli plot manual 1x"
	return false
end

task.spawn(function()
	while State.alive do
		if State.autoBuyPlot then
			pcall(buyPlotOnce)
			task.wait(2.5)
		else
			task.wait(0.5)
		end
	end
end)

-- magnet diamond
local GEM_KEYS = { "diamond", "gem", "berlian" }
local gemSet = {}
local function isGemPart(d)
	if not d:IsA("BasePart") then return false end
	if d.Size.Magnitude > 9 then return false end
	if gui and d:IsDescendantOf(gui) then return false end
	if d:FindFirstAncestorOfClass("Tool") then return false end
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl.Character and d:IsDescendantOf(pl.Character) then return false end
	end
	if hasAny(d.Name, GEM_KEYS) then return true end
	local p = d.Parent
	return p ~= nil and p:IsA("Model") and hasAny(p.Name, GEM_KEYS)
end

task.spawn(function()
	for i, d in ipairs(workspace:GetDescendants()) do
		if isGemPart(d) then gemSet[d] = true end
		if i % 4000 == 0 then task.wait() end
	end
end)
workspace.DescendantAdded:Connect(function(d)
	if isGemPart(d) then gemSet[d] = true end
end)
workspace.DescendantRemoving:Connect(function(d) gemSet[d] = nil end)

local gemCool = {}
task.spawn(function()
	while State.alive do
		if State.magnet then
			local root = hrp()
			if root then
				local r, n, now = State.magnetRadius, 0, os.clock()
				for part in pairs(gemSet) do
					if not part.Parent then
						gemSet[part] = nil
					elseif (part.Position - root.Position).Magnitude <= r and (gemCool[part] or 0) < now then
						gemCool[part] = now + 0.6
						n = n + 1
						if firetouchinterest then
							pcall(firetouchinterest, root, part, 0)
							pcall(firetouchinterest, root, part, 1)
						end
						pcall(function() part.CFrame = root.CFrame end)
					end
				end
				KH.txt.magnet = "Magnet: " .. r .. " studs | tarik: " .. n
			end
			task.wait(0.15)
		else
			KH.txt.magnet = "Magnet: mati"
			task.wait(0.4)
		end
	end
end)

KH.tpEvent = tpEvent
KH.buyPlotOnce = buyPlotOnce
end

local function KennHubUI()
----------------------------------------------------------------
-- UI: logo mengambang -> klik = buka panel tools (tab, resize, bg gambar)
----------------------------------------------------------------
local playerGui = lp:WaitForChild("PlayerGui")
for _, n in ipairs({ "CnS_UI", "KennHub_UI" }) do
	local o = playerGui:FindFirstChild(n)
	if o then o:Destroy() end
end

gui = Instance.new("ScreenGui")
gui.Name = "KennHub_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local THEME = {
	bg = Color3.fromRGB(14, 12, 24), card = Color3.fromRGB(30, 28, 46), tab = Color3.fromRGB(20, 18, 34),
	accent = Color3.fromRGB(130, 90, 255), accent2 = Color3.fromRGB(255, 90, 175),
	on = Color3.fromRGB(70, 210, 130), off = Color3.fromRGB(80, 80, 104),
	text = Color3.fromRGB(240, 240, 250), sub = Color3.fromRGB(175, 175, 200),
	red = Color3.fromRGB(235, 75, 85),
}
local WHITE = Color3.new(1, 1, 1)
local LOGO = 52
local PANEL_W, PANEL_H = 340, 260
local MIN_W, MIN_H = 230, 170
local MAX_W, MAX_H = 560, 440
local HEAD_H, TAB_H, FOOT_H = 36, 28, 24
local PAGES_TOP = HEAD_H + TAB_H + 6

local uiConns = {}
local function track(c) table.insert(uiConns, c) return c end

local function corner(o, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o
end

local function label(parent, text, size, color, bold)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size
	l.TextColor3 = color
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function tw(o, t, props, style, dir)
	local tr = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tr:Play()
	return tr
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

-- efek pencet: mengecil pas ditekan, mantul balik pas dilepas
local function addPress(btn, target, down)
	target = target or btn
	local sc = Instance.new("UIScale")
	sc.Parent = target
	btn.InputBegan:Connect(function(i)
		if isPress(i) then tw(sc, 0.08, { Scale = down or 0.92 }) end
	end)
	btn.InputEnded:Connect(function(i)
		if isPress(i) then tw(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end
	end)
end

local function viewport()
	local v = gui.AbsoluteSize
	if v.X < 50 then
		local cam = workspace.CurrentCamera
		v = cam and cam.ViewportSize or Vector2.new(900, 420)
	end
	return v
end

local function clampPos(x, y, w, h)
	local v = viewport()
	return math.clamp(x, 4, math.max(4, v.X - w - 4)), math.clamp(y, 4, math.max(4, v.Y - h - 4))
end

----------------------------------------------------------------
-- Gambar (logo + background) dari URL: download -> writefile -> getcustomasset.
-- Jalan di thread terpisah, UI tampil dulu dengan tampilan cadangan.
----------------------------------------------------------------
local function isJpeg(b) return type(b) == "string" and b:sub(1, 2) == "\255\216" end
local function isPng(b) return type(b) == "string" and b:sub(1, 4) == "\137PNG" end

local function httpGet(url)
	local errs = {}
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok and type(res) == "string" and #res > 100 then return res end
	table.insert(errs, "HttpGet=" .. (ok and (type(res) == "string" and (#res .. "B") or type(res)) or "error"))

	local cand = {}
	if syn and syn.request then table.insert(cand, syn.request) end
	if request then table.insert(cand, request) end
	if http_request then table.insert(cand, http_request) end
	if http and http.request then table.insert(cand, http.request) end
	if fluxus and fluxus.request then table.insert(cand, fluxus.request) end
	for k, f in ipairs(cand) do
		local ok2, r = pcall(f, { Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
		if ok2 and type(r) == "table" and type(r.Body) == "string" and #r.Body > 100 then return r.Body end
		table.insert(errs, "req" .. k .. "=" .. ((ok2 and type(r) == "table") and tostring(r.StatusCode) or "error"))
	end
	return nil, table.concat(errs, " ")
end

-- balik (id, nil) kalau sukses, (nil, alasan) kalau gagal
local function fetchImage(url, base)
	local asset = getcustomasset or getsynasset
	if not writefile then return nil, "executor nggak punya writefile" end
	if not asset then return nil, "executor nggak punya getcustomasset" end
	local ok, id, err = pcall(function()
		for _, ext in ipairs({ ".jpg", ".png" }) do
			local f = base .. ext
			if isfile and readfile and isfile(f) then
				local d = readfile(f)
				if isJpeg(d) or isPng(d) then return asset(f), nil end
			end
		end
		local body, herr = httpGet(url)
		if not body then return nil, "download gagal: " .. tostring(herr) end
		local ext = isJpeg(body) and ".jpg" or (isPng(body) and ".png" or nil)
		if not ext then return nil, "isi bukan gambar (" .. #body .. " byte)" end
		writefile(base .. ext, body)
		local aid = asset(base .. ext)
		if not aid or aid == "" then return nil, "getcustomasset kosong" end
		return aid, nil
	end)
	if not ok then return nil, "error: " .. tostring(id) end
	return id, err
end

----------------------------------------------------------------
-- Logo mengambang (bisa digeser, klik = buka/tutup panel)
----------------------------------------------------------------
local logoX, logoY = 14, 72
local logoBtn = Instance.new("ImageButton")
logoBtn.Name = "Logo"
logoBtn.AnchorPoint = Vector2.new(0.5, 0.5)
logoBtn.Size = UDim2.fromOffset(LOGO, LOGO)
logoBtn.Position = UDim2.fromOffset(logoX + LOGO / 2, logoY + LOGO / 2)
logoBtn.BackgroundColor3 = THEME.accent
logoBtn.AutoButtonColor = false
logoBtn.Image = ""
logoBtn.ScaleType = Enum.ScaleType.Crop
logoBtn.ZIndex = 50
logoBtn.Parent = gui
corner(logoBtn, CONFIG.LOGO_RADIUS)

local logoFallback = Instance.new("UIGradient")
logoFallback.Color = ColorSequence.new(THEME.accent, THEME.accent2)
logoFallback.Rotation = 45
logoFallback.Parent = logoBtn

local logoK = Instance.new("TextLabel")
logoK.Size = UDim2.fromScale(1, 1)
logoK.BackgroundTransparency = 1
logoK.Text = "K"
logoK.Font = Enum.Font.GothamBlack
logoK.TextSize = 24
logoK.TextColor3 = WHITE
logoK.ZIndex = 51
logoK.Parent = logoBtn

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = WHITE
logoStroke.Thickness = 2.4
logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
logoStroke.Parent = logoBtn
local logoSG = Instance.new("UIGradient")
logoSG.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, THEME.accent),
	ColorSequenceKeypoint.new(0.5, THEME.accent2),
	ColorSequenceKeypoint.new(1, THEME.accent),
})
logoSG.Parent = logoStroke

-- titik status: ijo kalau ada fitur yang lagi jalan (kelihatan walau panel ditutup)
local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(14, 14)
dot.Position = UDim2.new(1, -14, 0, -1)
dot.BackgroundColor3 = THEME.off
dot.BorderSizePixel = 0
dot.ZIndex = 52
dot.Parent = logoBtn
corner(dot, 7)
local dotStroke = Instance.new("UIStroke")
dotStroke.Color = Color3.new(0, 0, 0)
dotStroke.Thickness = 2
dotStroke.Transparency = 0.2
dotStroke.Parent = dot

addPress(logoBtn, logoBtn, 0.88)

----------------------------------------------------------------
-- Panel tools
----------------------------------------------------------------
local panelX, panelY, panelW, panelH = 80, 60, PANEL_W, PANEL_H
local panelMoved = false

local panelRoot = Instance.new("Frame")
panelRoot.Name = "Panel"
panelRoot.AnchorPoint = Vector2.new(0.5, 0.5)
panelRoot.BackgroundTransparency = 1
panelRoot.Size = UDim2.fromOffset(panelW, panelH)
panelRoot.Position = UDim2.fromOffset(panelX + panelW / 2, panelY + panelH / 2)
panelRoot.Visible = false
panelRoot.ZIndex = 10
panelRoot.Parent = gui
local panelScale = Instance.new("UIScale")
panelScale.Parent = panelRoot

-- glow di bawah panel: anak panelRoot, jadi ikut resize / ikut hilang pas ditutup
local glow = Instance.new("ImageLabel")
glow.BackgroundTransparency = 1
glow.Image = "rbxasset://textures/ui/Glow.png"
glow.ImageColor3 = THEME.accent
glow.ImageTransparency = 0.7
glow.Size = UDim2.new(1, 44, 1, 44)
glow.Position = UDim2.fromOffset(-22, -22)
glow.ZIndex = 1
glow.Parent = panelRoot

local main = Instance.new("Frame")
main.Size = UDim2.fromScale(1, 1)
main.BackgroundColor3 = THEME.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.ZIndex = 2
main.Parent = panelRoot
corner(main, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = WHITE
stroke.Thickness = 1.6
stroke.Parent = main
local strokeGrad = Instance.new("UIGradient")
strokeGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, THEME.accent),
	ColorSequenceKeypoint.new(0.5, THEME.accent2),
	ColorSequenceKeypoint.new(1, THEME.accent),
})
strokeGrad.Parent = stroke

-- background gambar + lapisan gelap tipis biar tulisan tetap kebaca
local bgImg = Instance.new("ImageLabel")
bgImg.Size = UDim2.fromScale(1, 1)
bgImg.BackgroundTransparency = 1
bgImg.ScaleType = Enum.ScaleType.Crop
bgImg.ZIndex = 1
bgImg.Parent = main
corner(bgImg, 14)

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(8, 6, 16)
shade.BackgroundTransparency = 0.42
shade.BorderSizePixel = 0
shade.ZIndex = 2
shade.Parent = main
corner(shade, 14)

-- header: logo kecil + judul + [-] [X]
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEAD_H)
header.BackgroundTransparency = 1
header.ZIndex = 5
header.Parent = main

local logoMini = Instance.new("ImageLabel")
logoMini.Size = UDim2.fromOffset(24, 24)
logoMini.Position = UDim2.fromOffset(10, (HEAD_H - 24) / 2)
logoMini.BackgroundColor3 = THEME.accent
logoMini.ScaleType = Enum.ScaleType.Crop
logoMini.ZIndex = 6
logoMini.Parent = header
corner(logoMini, math.max(0, CONFIG.LOGO_RADIUS - 1))
local miniK = Instance.new("TextLabel")
miniK.Size = UDim2.fromScale(1, 1)
miniK.BackgroundTransparency = 1
miniK.Text = "K"
miniK.Font = Enum.Font.GothamBlack
miniK.TextSize = 15
miniK.TextColor3 = WHITE
miniK.ZIndex = 7
miniK.Parent = logoMini

local title = label(header, "Kenn Hub", 16, THEME.text, true)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.fromOffset(42, 0)
title.ZIndex = 6

local function barButton(text, xOff, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(28, 26)
	b.Position = UDim2.new(1, xOff, 0.5, -13)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = THEME.text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.AutoButtonColor = false
	b.ZIndex = 7
	b.Parent = header
	corner(b, 7)
	addPress(b, b, 0.85)
	return b
end
local minBtn = barButton("-", -68, THEME.off)
local closeBtn = barButton("X", -36, THEME.red)

local function divider(y, fromBottom)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1, -20, 0, 1)
	d.Position = fromBottom and UDim2.new(0, 10, 1, -y) or UDim2.fromOffset(10, y)
	d.BackgroundColor3 = WHITE
	d.BackgroundTransparency = 0.85
	d.BorderSizePixel = 0
	d.ZIndex = 5
	d.Parent = main
end
divider(HEAD_H, false)
divider(FOOT_H, true)

-- tab
local TABS = { "Farm", "Steal", "Event", "Shop", "Misc", "Info" }
local TAB_ICONS = { Farm = "🌾", Steal = "🐾", Event = "🎉", Shop = "💎", Misc = "🧰", Info = "ℹ️" }
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, TAB_H)
tabBar.Position = UDim2.fromOffset(8, HEAD_H + 4)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 5
tabBar.Parent = main
local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabBar

local pagesHolder = Instance.new("Frame")
pagesHolder.Size = UDim2.new(1, 0, 1, -(PAGES_TOP + FOOT_H))
pagesHolder.Position = UDim2.fromOffset(0, PAGES_TOP)
pagesHolder.BackgroundTransparency = 1
pagesHolder.ClipsDescendants = true
pagesHolder.ZIndex = 5
pagesHolder.Parent = main

local pages, tabBtns, curTab = {}, {}, nil

local function makePage(name)
	local pg = Instance.new("ScrollingFrame")
	pg.Size = UDim2.fromScale(1, 1)
	pg.BackgroundTransparency = 1
	pg.BorderSizePixel = 0
	pg.ScrollBarThickness = 3
	pg.ScrollBarImageColor3 = THEME.accent
	pg.CanvasSize = UDim2.new()
	pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pg.ScrollingDirection = Enum.ScrollingDirection.Y
	pg.Visible = false
	pg.ZIndex = 5
	pg.Parent = pagesHolder
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 10)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 34)
	pad.Parent = pg
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = pg
	pages[name] = pg
	return pg
end

local function selectTab(name, instant)
	if name == curTab then return end
	curTab = name
	for n, pg in pairs(pages) do pg.Visible = (n == name) end
	for n, b in pairs(tabBtns) do
		local on = n == name
		tw(b, 0.18, { BackgroundColor3 = on and THEME.accent or THEME.tab, BackgroundTransparency = on and 0.05 or 0.3, TextColor3 = on and WHITE or THEME.sub })
	end
	local pg = pages[name]
	if pg and not instant then
		pg.Position = UDim2.fromOffset(0, 12)
		tw(pg, 0.22, { Position = UDim2.fromOffset(0, 0) })
	end
end

for i, name in ipairs(TABS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1 / #TABS, -4, 1, 0)
	b.LayoutOrder = i
	b.BackgroundColor3 = THEME.tab
	b.BackgroundTransparency = 0.3
	b.Text = (TAB_ICONS[name] or "") .. " " .. name
	b.TextColor3 = THEME.sub
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextScaled = true
	b.AutoButtonColor = false
	b.ZIndex = 6
	b.Parent = tabBar
	local tsc = Instance.new("UITextSizeConstraint")
	tsc.MaxTextSize = 13
	tsc.MinTextSize = 8
	tsc.Parent = b
	corner(b, 8)
	addPress(b, b, 0.9)
	tabBtns[name] = b
	makePage(name)
	b.Activated:Connect(function() selectTab(name) end)
end

local pgFarm, pgSteal, pgMisc, pgInfo = pages.Farm, pages.Steal, pages.Misc, pages.Info
local pgEvent, pgShop = pages.Event, pages.Shop

-- footer: status satu baris
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, FOOT_H)
footer.Position = UDim2.new(0, 0, 1, -FOOT_H)
footer.BackgroundTransparency = 1
footer.ZIndex = 5
footer.Parent = main
local status = label(footer, "", 12, THEME.text, false)
status.Size = UDim2.new(1, -52, 1, 0)
status.Position = UDim2.fromOffset(10, 0)
status.TextTruncate = Enum.TextTruncate.AtEnd
status.ZIndex = 6

-- pegangan resize (pojok kanan bawah)
local handle = Instance.new("TextButton")
handle.Name = "Resize"
handle.Size = UDim2.fromOffset(36, 36)
handle.Position = UDim2.new(1, -36, 1, -36)
handle.BackgroundTransparency = 1
handle.Text = ""
handle.ZIndex = 30
handle.Parent = main
for _, d in ipairs({ { 7, 7 }, { 7, 14 }, { 14, 7 }, { 7, 21 }, { 14, 14 }, { 21, 7 } }) do
	local g = Instance.new("Frame")
	g.Size = UDim2.fromOffset(4, 4)
	g.AnchorPoint = Vector2.new(1, 1)
	g.Position = UDim2.new(1, -d[1], 1, -d[2])
	g.BackgroundColor3 = THEME.accent2
	g.BackgroundTransparency = 0.1
	g.BorderSizePixel = 0
	g.ZIndex = 31
	g.Parent = handle
	corner(g, 2)
end

----------------------------------------------------------------
-- Komponen: kartu, toggle, tombol
----------------------------------------------------------------
local renderers = {}
local orderCount = {}

local function card(page, h)
	orderCount[page] = (orderCount[page] or 0) + 1
	local c = Instance.new("Frame")
	c.Size = UDim2.new(1, 0, 0, h or 38)
	c.LayoutOrder = orderCount[page]
	c.BackgroundColor3 = THEME.card
	c.BackgroundTransparency = 0.2
	c.BorderSizePixel = 0
	c.ZIndex = 5
	c.Parent = page
	corner(c, 9)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(110, 100, 160)
	s.Thickness = 1
	s.Transparency = 0.6
	s.Parent = c
	return c
end

local function toggleRow(page, text, key, stateFn)
	local row = card(page, 38)

	local l = label(row, text, 14, THEME.text, false)
	l.Size = UDim2.new(1, -70, 1, 0)
	l.Position = UDim2.fromOffset(12, 0)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.ZIndex = 6

	local sw = Instance.new("Frame")
	sw.Size = UDim2.fromOffset(46, 22)
	sw.Position = UDim2.new(1, -58, 0.5, -11)
	sw.BackgroundColor3 = THEME.off
	sw.BorderSizePixel = 0
	sw.ZIndex = 6
	sw.Parent = row
	corner(sw, 11)

	local glowS = Instance.new("ImageLabel")
	glowS.Size = UDim2.fromOffset(64, 40)
	glowS.Position = UDim2.fromOffset(-9, -9)
	glowS.BackgroundTransparency = 1
	glowS.ImageColor3 = THEME.on
	glowS.ImageTransparency = 1
	glowS.Image = "rbxasset://textures/ui/Glow.png"
	glowS.ZIndex = 5
	glowS.Parent = sw

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = THEME.text
	knob.BorderSizePixel = 0
	knob.ZIndex = 7
	knob.Parent = sw
	corner(knob, 9)

	-- seluruh baris bisa ditap
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 9
	hit.Parent = row
	addPress(hit, row, 0.96)

	local lastOn = nil
	local function render()
		local on
		if stateFn then on = stateFn() and true or false else on = State[key] and true or false end
		if lastOn == on then return end
		lastOn = on
		local offColor = stateFn and THEME.red or THEME.off
		tw(sw, 0.15, { BackgroundColor3 = on and THEME.on or offColor })
		tw(knob, 0.18, { Position = on and UDim2.fromOffset(26, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
		glowS.ImageColor3 = on and THEME.on or THEME.red
		tw(glowS, 0.2, { ImageTransparency = (on or stateFn) and 0.5 or 1 })
	end
	renderers[key] = render

	hit.Activated:Connect(function()
		State[key] = not State[key]
		if State[key] then
			if key == "enabled" then
				State.autoSwing = true
				State.eggsLeft = true
				if renderers.autoSwing then renderers.autoSwing() end
			end
			if key == "autoTreadmill" and State.enabled and not State.breakAnywhere then
				State.enabled = false
				renderers.enabled()
			elseif key == "enabled" and State.autoTreadmill and not State.breakAnywhere then
				State.autoTreadmill = false
				renderers.autoTreadmill()
			end
		end
		if key == "breakAnywhere" or key == "enabled" then
			visited = {}
			lastAnywhereStream = 0
		end
		if key == "fpsBoost" then pcall(setFps, State.fpsBoost) end
		render()
	end)
	render()
end

local function cardButton(page, text)
	local b = card(page, 38)
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 9
	hit.Parent = b
	addPress(hit, b, 0.96)
	local l = label(b, text, 14, THEME.text, false)
	l.Size = UDim2.new(1, -40, 1, 0)
	l.Position = UDim2.fromOffset(12, 0)
	l.ZIndex = 6
	l.TextTruncate = Enum.TextTruncate.AtEnd
	local a = label(b, ">", 16, THEME.accent2, true)
	a.Size = UDim2.new(0, 24, 1, 0)
	a.Position = UDim2.new(1, -28, 0, 0)
	a.ZIndex = 6
	return hit, l
end

local function infoCard(page, h, color, size)
	local c = card(page, h)
	local l = label(c, "", size or 12, color, false)
	l.Size = UDim2.new(1, -16, 1, -8)
	l.Position = UDim2.fromOffset(8, 4)
	l.TextWrapped = true
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.ZIndex = 6
	return l
end

-- Farm
toggleRow(pgFarm, "⚡ Enable", "enabled")
toggleRow(pgFarm, "🔨 Auto Swing", "autoSwing", function() return State.enabled and State.autoSwing end)
toggleRow(pgFarm, "🎯 Break Only", "breakOnly")
toggleRow(pgFarm, "🌐 Break Anywhere", "breakAnywhere")
toggleRow(pgFarm, "⏩ Skip Anim", "skipAnim")
local areaBtn, areaLbl = cardButton(pgFarm, "🗺️ Filter Area: All")

-- Steal
State.autoSteal = false
local function lockedRow(page, text, note)
	local row = card(page, 58)
	local l = label(row, text, 14, THEME.sub, false)
	l.Size = UDim2.new(1, -80, 0, 22)
	l.Position = UDim2.fromOffset(12, 6)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.ZIndex = 6

	local tag = Instance.new("TextLabel")
	tag.Size = UDim2.fromOffset(50, 20)
	tag.Position = UDim2.new(1, -60, 0, 7)
	tag.BackgroundColor3 = THEME.red
	tag.BackgroundTransparency = 0.15
	tag.Text = "LOCK"
	tag.Font = Enum.Font.GothamBold
	tag.TextSize = 12
	tag.TextColor3 = WHITE
	tag.ZIndex = 6
	tag.Parent = row
	corner(tag, 6)

	local noteColor = Color3.fromRGB(255, 150, 150)
	local n = label(row, note, 11, noteColor, false)
	n.Size = UDim2.new(1, -20, 0, 26)
	n.Position = UDim2.fromOffset(12, 29)
	n.TextWrapped = true
	n.TextYAlignment = Enum.TextYAlignment.Top
	n.ZIndex = 6

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 9
	hit.Parent = row
	addPress(hit, row, 0.97)
	hit.Activated:Connect(function()
		n.TextColor3 = WHITE
		tw(n, 0.6, { TextColor3 = noteColor })
	end)
end
lockedRow(pgSteal, "🐾 Auto Steal", "(bug) akan di benerkan secepatnya")
lockedRow(pgSteal, "🛡️ Steal Mode: Dodge", "(bug) akan di benerkan secepatnya")

-- Misc
toggleRow(pgMisc, "🏃 Auto Treadmill", "autoTreadmill")
toggleRow(pgMisc, "🥷 Stealth Mode", "stealth")
toggleRow(pgMisc, "🚀 FPS Boost", "fpsBoost")


-- stepper (- / +) buat angka
local function stepperRow(page, text, get, set, minV, maxV, step, unit)
	local row = card(page, 38)
	local l = label(row, "", 13, THEME.text, false)
	l.Size = UDim2.new(1, -90, 1, 0)
	l.Position = UDim2.fromOffset(12, 0)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.ZIndex = 6
	local function upd() l.Text = text .. ": " .. get() .. " " .. unit end
	local function mk(txt, xoff, d)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(30, 26)
		b.Position = UDim2.new(1, xoff, 0.5, -13)
		b.BackgroundColor3 = THEME.accent
		b.Text = txt
		b.TextColor3 = WHITE
		b.Font = Enum.Font.GothamBold
		b.TextSize = 16
		b.AutoButtonColor = false
		b.ZIndex = 9
		b.Parent = row
		corner(b, 7)
		addPress(b, b, 0.85)
		b.Activated:Connect(function()
			set(math.clamp(get() + d * step, minV, maxV))
			upd()
		end)
	end
	mk("-", -74, -1)
	mk("+", -40, 1)
	upd()
end

toggleRow(pgFarm, "💥 Anti Ledakan", "noBlast")
stepperRow(pgFarm, "📏 Jarak Egg", function() return State.standoff end, function(v) State.standoff = v end, 4, 22, 2, "studs")

-- Event
toggleRow(pgEvent, "🎉 Auto Event", "autoEvent")
local evBtn, evLbl = cardButton(pgEvent, "📍 TP ke Event")
local eventLbl = infoCard(pgEvent, 46, THEME.sub, 11)
evBtn.Activated:Connect(function()
	local ok = KH.tpEvent()
	evLbl.Text = ok and "📍 Sudah TP!" or "📍 Event nggak ketemu"
	task.delay(1.5, function() evLbl.Text = "📍 TP ke Event" end)
end)

-- Shop (Diamond)
toggleRow(pgShop, "🛒 Auto Buy Plot", "autoBuyPlot")
local buyBtn, buyLbl = cardButton(pgShop, "🏠 Beli Plot Sekarang")
local recBtn, recLbl = cardButton(pgShop, "🎓 Rekam Beli Plot (manual 1x)")
toggleRow(pgShop, "💎 Diamond Magnet", "magnet")
stepperRow(pgShop, "📏 Radius", function() return State.magnetRadius end, function(v) State.magnetRadius = v end, 5, 300, 5, "studs")
local shopLbl = infoCard(pgShop, 62, THEME.sub, 11)
buyBtn.Activated:Connect(function()
	task.spawn(function() pcall(KH.buyPlotOnce) end)
end)
recBtn.Activated:Connect(function()
	State.learning = true
	learned = nil
	KH.txt.shop = "Merekam: beli plot secara manual SEKARANG (1x)"
	recLbl.Text = "🎓 Merekam... beli plot manual"
	task.spawn(function()
		local t0 = os.clock()
		while State.learning and os.clock() - t0 < 30 do task.wait(0.2) end
		State.learning = false
		recLbl.Text = learned and "🎓 Tersimpan: " .. learned.name or "🎓 Rekam Beli Plot (manual 1x)"
		if learned then KH.txt.shop = "Rekaman: " .. learned.name .. " (siap auto buy)" end
	end)
end)

-- Info
local hint = infoCard(pgInfo, 46, THEME.text, 12)
local reasonLbl = infoCard(pgInfo, 46, THEME.sub, 11)
local imgInfo = infoCard(pgInfo, 62, THEME.sub, 11)
local stallLbl = infoCard(pgInfo, 36, THEME.sub, 11)

local function selectArea(name)
	State.area = name
	areaLbl.Text = "🗺️ Filter Area: " .. name
	visited, ghostCool, blocked, areaRejects = {}, {}, {}, {}
	lastAnywhereStream = 0
	refresh(true, true)
end

local picker = Instance.new("Frame")
picker.Name = "AreaPicker"
picker.Size = UDim2.new(1, -16, 1, -(PAGES_TOP + FOOT_H + 4))
picker.Position = UDim2.fromOffset(8, PAGES_TOP)
picker.BackgroundColor3 = THEME.bg
picker.BackgroundTransparency = 0.02
picker.Visible = false
picker.ZIndex = 30
picker.Parent = main
corner(picker, 10)
local pstroke = Instance.new("UIStroke")
pstroke.Color = THEME.accent
pstroke.Thickness = 1.5
pstroke.Parent = picker
local ptitle = label(picker, "🗺️ Pilih Area", 13, THEME.text, true)
ptitle.Size = UDim2.new(1, -50, 0, 28)
ptitle.Position = UDim2.fromOffset(10, 0)
ptitle.ZIndex = 31
local pclose = Instance.new("TextButton")
pclose.Size = UDim2.fromOffset(28, 22)
pclose.Position = UDim2.new(1, -34, 0, 3)
pclose.BackgroundColor3 = THEME.red
pclose.Text = "X"
pclose.TextColor3 = WHITE
pclose.Font = Enum.Font.GothamBold
pclose.TextSize = 13
pclose.AutoButtonColor = false
pclose.ZIndex = 33
pclose.Parent = picker
corner(pclose, 6)
local plist = Instance.new("ScrollingFrame")
plist.Size = UDim2.new(1, -12, 1, -34)
plist.Position = UDim2.fromOffset(6, 30)
plist.BackgroundTransparency = 1
plist.BorderSizePixel = 0
plist.ScrollBarThickness = 3
plist.ScrollBarImageColor3 = THEME.accent
plist.CanvasSize = UDim2.new()
plist.AutomaticCanvasSize = Enum.AutomaticSize.Y
plist.ZIndex = 31
plist.Parent = picker
local play = Instance.new("UIListLayout")
play.Padding = UDim.new(0, 4)
play.SortOrder = Enum.SortOrder.LayoutOrder
play.Parent = plist

local areaButtons = {}
local function markArea()
	for name, b in pairs(areaButtons) do
		local on = name == State.area
		b.BackgroundColor3 = on and THEME.accent or THEME.card
		b.Text = "  " .. (on and "✓ " or "") .. name
	end
end
for i, name in ipairs(AREAS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 30)
	b.LayoutOrder = i
	b.BackgroundColor3 = THEME.card
	b.TextColor3 = THEME.text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.AutoButtonColor = false
	b.Text = "  " .. name
	b.ZIndex = 32
	b.Parent = plist
	corner(b, 7)
	areaButtons[name] = b
	b.Activated:Connect(function()
		selectArea(name)
		markArea()
		picker.Visible = false
	end)
end
markArea()
pclose.Activated:Connect(function() picker.Visible = false end)
areaBtn.Activated:Connect(function()
	markArea()
	picker.Visible = true
end)

selectTab("Farm", true)

-- loop status
local noEggSince = nil
task.spawn(function()
	while State.alive do
		local n = 0
		for _, t in ipairs(cache) do if inArea(t) and not t.ghost then n = n + 1 end end
		local anyEgg = false
		for _, t in ipairs(cache) do
			if inArea(t) and not t.ghost and isUsable(t) then anyEgg = true break end
		end
		if anyEgg then
			State.eggsLeft = true
			noEggSince = nil
		else
			noEggSince = noEggSince or os.clock()
			if os.clock() - noEggSince > 2.5 then State.eggsLeft = false end
		end
		if renderers.autoSwing then renderers.autoSwing() end
		local s = State.autoTreadmill and tmText or statusText
		if State.autoSteal then s = s .. " | " .. stealText end
		status.Text = s
		hint.Text = "Telur: " .. n .. " | kena: " .. landed .. " | tolak: " .. rejects .. " | steal: " .. stealCount .. " | gain: " .. gains
		local now, names = os.clock(), {}
		for a, untilT in pairs(blocked) do if untilT > now then table.insert(names, a) end end
		if #names > 0 then
			reasonLbl.Text = "Skip (ditolak): " .. table.concat(names, ", ") .. (lastReject ~= "" and (" | " .. lastReject) or "")
		else
			reasonLbl.Text = lastReject ~= "" and ("Tolakan terakhir: " .. lastReject) or ""
		end
		stallLbl.Text = KH.stall .. "\nDelay pukul: " .. string.format("%.2f", hitDelay) .. "s | tolak: " .. rejects
		eventLbl.Text = KH.txt.event
		shopLbl.Text = KH.txt.shop .. "\n" .. KH.txt.magnet
		local active = State.enabled or State.autoSteal or State.autoTreadmill or State.magnet or State.autoEvent or State.autoBuyPlot
		dot.BackgroundColor3 = active and THEME.on or THEME.off
		task.wait(0.4)
	end
end)

-- muat gambar (logo + bg) di belakang layar, coba ulang 3x, hasilnya ditulis di tab Info
local imgStatus = { logo = "memuat...", bg = "memuat..." }
local function refreshImgInfo()
	imgInfo.Text = "Logo: " .. imgStatus.logo .. "\nBG: " .. imgStatus.bg
end
refreshImgInfo()

local function loadWithRetry(name, url, base, apply)
	task.spawn(function()
		local lastErr
		for attempt = 1, 3 do
			local id, err = fetchImage(url, base)
			if id then
				pcall(apply, id)
				imgStatus[name] = "OK"
				refreshImgInfo()
				return
			end
			lastErr = err
			imgStatus[name] = "gagal (" .. tostring(err) .. ") " .. attempt .. "/3"
			refreshImgInfo()
			task.wait(2)
		end
		print("[KennHub] gambar " .. name .. " gagal: " .. tostring(lastErr))
	end)
end

loadWithRetry("logo", CONFIG.LOGO_URL, "KennHub_logo", function(id)
	if not logoBtn.Parent then return end
	logoBtn.Image = id
	logoMini.Image = id
	if KennNotif then KennNotif.setLogo(id) end
	logoBtn.BackgroundTransparency = 1
	logoMini.BackgroundTransparency = 1
	pcall(function() logoFallback:Destroy() end)
	logoK.Visible = false
	miniK.Visible = false
end)
loadWithRetry("bg", CONFIG.BG_URL, "KennHub_bg", function(id)
	if bgImg.Parent then bgImg.Image = id end
end)


----------------------------------------------------------------
-- Buka/tutup panel, drag logo & panel, resize
----------------------------------------------------------------
local function applyLogo()
	logoBtn.Position = UDim2.fromOffset(logoX + LOGO / 2, logoY + LOGO / 2)
end
local function applyPanel()
	panelRoot.Size = UDim2.fromOffset(panelW, panelH)
	panelRoot.Position = UDim2.fromOffset(panelX + panelW / 2, panelY + panelH / 2)
end

local function ripple()
	local r = Instance.new("Frame")
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.fromScale(0.5, 0.5)
	r.Size = UDim2.fromOffset(LOGO, LOGO)
	r.BackgroundTransparency = 1
	r.ZIndex = 49
	r.Parent = logoBtn
	corner(r, CONFIG.LOGO_RADIUS + 6)
	local st = Instance.new("UIStroke")
	st.Color = THEME.accent2
	st.Thickness = 3
	st.Parent = r
	tw(r, 0.5, { Size = UDim2.fromOffset(LOGO * 2.1, LOGO * 2.1) })
	tw(st, 0.5, { Transparency = 1 })
	task.delay(0.55, function() r:Destroy() end)
end

local panelOpen, openToken = false, 0

local function openPanel()
	if panelOpen then return end
	panelOpen = true
	openToken = openToken + 1
	if not panelMoved then
		local px, py = logoX + LOGO + 10, logoY
		if px + panelW > viewport().X - 4 then px = logoX - panelW - 10 end
		panelX, panelY = clampPos(px, py, panelW, panelH)
	else
		panelX, panelY = clampPos(panelX, panelY, panelW, panelH)
	end
	applyPanel()
	panelScale.Scale = 0.55
	panelRoot.Visible = true
	tw(panelScale, 0.34, { Scale = 1 }, Enum.EasingStyle.Back)
	ripple()
end

local function closePanel()
	if not panelOpen then return end
	panelOpen = false
	openToken = openToken + 1
	local my = openToken
	tw(panelScale, 0.16, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.delay(0.18, function()
		if openToken == my and not panelOpen then panelRoot.Visible = false end
	end)
end

local function togglePanel()
	if panelOpen then closePanel() else openPanel() end
end

minBtn.Activated:Connect(closePanel)

-- glow berputar
local rot = 0
local glowConn = track(RunService.Heartbeat:Connect(function(dt)
	rot = (rot + dt * 140) % 360
	logoSG.Rotation = rot
	if panelRoot.Visible then strokeGrad.Rotation = rot end
end))

-- drag: satu input aktif aja (jari lain, mis. joystick, nggak ikut narik)
local drag = nil
local function startDrag(kind, input)
	if drag then return end
	drag = {
		kind = kind, input = input, sx = input.Position.X, sy = input.Position.Y, moved = false,
		ax = (kind == "logo") and logoX or panelX, ay = (kind == "logo") and logoY or panelY,
		aw = panelW, ah = panelH,
	}
end

logoBtn.InputBegan:Connect(function(i) if isPress(i) then startDrag("logo", i) end end)
header.InputBegan:Connect(function(i) if isPress(i) then startDrag("panel", i) end end)
handle.InputBegan:Connect(function(i) if isPress(i) then startDrag("resize", i) end end)

track(UIS.InputChanged:Connect(function(i)
	if not drag then return end
	if drag.input.UserInputType == Enum.UserInputType.Touch then
		if i ~= drag.input then return end
	elseif i.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	local dx, dy = i.Position.X - drag.sx, i.Position.Y - drag.sy
	if not drag.moved and math.abs(dx) + math.abs(dy) > 8 then drag.moved = true end
	if not drag.moved then return end
	if drag.kind == "logo" then
		logoX, logoY = clampPos(drag.ax + dx, drag.ay + dy, LOGO, LOGO)
		applyLogo()
	elseif drag.kind == "panel" then
		panelX, panelY = clampPos(drag.ax + dx, drag.ay + dy, panelW, panelH)
		panelMoved = true
		applyPanel()
	elseif drag.kind == "resize" then
		local v = viewport()
		panelW = math.clamp(drag.aw + dx, MIN_W, math.max(MIN_W, math.min(MAX_W, v.X - panelX - 4)))
		panelH = math.clamp(drag.ah + dy, MIN_H, math.max(MIN_H, math.min(MAX_H, v.Y - panelY - 4)))
		panelMoved = true
		applyPanel()
	end
end))

track(UIS.InputEnded:Connect(function(i)
	if not drag then return end
	local same = (i == drag.input) or (drag.input.UserInputState == Enum.UserInputState.End)
		or (drag.input.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseButton1)
	if not same then return end
	local d = drag
	drag = nil
	if d.kind == "logo" and not d.moved then togglePanel() end
end))

closeBtn.Activated:Connect(function()
	State.alive = false
	State.enabled = false
	State.autoSteal = false
	State.autoTreadmill = false
	if State.fpsBoost then pcall(setFps, false) end
	if tmConn then tmConn:Disconnect() end
	local r = hrp()
	if r then pcall(function() r.Anchored = false end) end
	for _, c in ipairs(uiConns) do pcall(function() c:Disconnect() end) end
	gui:Destroy()
end)

buildAnchors()
refresh(true, true)

print("[KennHub] loaded | remote:", hitRemote ~= nil, "| hitArg:", hitArg)
if KennNotif then KennNotif.finish("Kenn Hub siap dipakai", true) end
end

local okUI, errUI = pcall(KennHubUI)
if not okUI then
	warn("[KennHub] UI error: " .. tostring(errUI))
	if KennNotif then KennNotif.finish("Kenn Hub gagal load", false) end
	print("[KennHub] UI error: " .. tostring(errUI))
end
