
local ok, err = pcall(function()
	local Players = game:GetService("Players");
	local RunService = game:GetService("RunService");
	local UserInputService = game:GetService("UserInputService");
	local LP = Players.LocalPlayer;
	local function getChar()
		return LP.Character;
	end
	local function getHRP()
		local c = getChar();
		return c and c:FindFirstChild("HumanoidRootPart");
	end
	local function getHum()
		local c = getChar();
		return c and c:FindFirstChildOfClass("Humanoid");
	end
	local VALID_KEY = "KoenigseggOnTop";
	local KEY_LINK = "https://link-target.net/2967900/RVl7e6c7RcvG";
	local Unlocked = false;
	local State = {Speed=16,Jump=50,SpeedEnabled=false,JumpEnabled=false,Fly=false,Noclip=false,LockOn=false,LockTarget=nil,FlySpeed=40,ESP=false,ESPColor=Color3.fromRGB(34, 211, 238),ESPHealth=true,ESPName=true,ESPTeamName=true,Aimbot=false,WallCheck=true,TeamCheck=true,FOVSize=120,FOVColor=Color3.fromRGB(255, 60, 60),AimbotSmooth=12};
	local C = {accent=Color3.fromRGB(255, 140, 0),accentDark=Color3.fromRGB(180, 90, 0),accentGlow=Color3.fromRGB(255, 180, 80),bg0=Color3.fromRGB(14, 12, 10),bg1=Color3.fromRGB(24, 20, 14),bg2=Color3.fromRGB(34, 28, 18),bg3=Color3.fromRGB(46, 38, 22),white=Color3.fromRGB(255, 245, 230),subtext=Color3.fromRGB(170, 150, 120),green=Color3.fromRGB(52, 211, 153),red=Color3.fromRGB(239, 68, 68),yellow=Color3.fromRGB(251, 191, 36),cyan=Color3.fromRGB(34, 211, 238),pink=Color3.fromRGB(244, 114, 182)};
	local function applyStats()
		local h = getHum();
		if not h then
			return;
		end
		h.WalkSpeed = (State.SpeedEnabled and State.Speed) or 16;
		h.JumpPower = (State.JumpEnabled and State.Jump) or 50;
	end
	LP.CharacterAdded:Connect(function()
		task.wait(1);
		if Unlocked then
			applyStats();
			State.Fly = false;
			State.Noclip = false;
			State.LockOn = false;
		end
	end);
	task.spawn(function()
		while true do
			task.wait(0.5);
			if Unlocked then
				pcall(applyStats);
			end
		end
	end);
	local flyConn, bodyVel, bodyGyro;
	local function enableFly()
		local hrp = getHRP();
		local hum = getHum();
		if (not hrp or not hum) then
			return;
		end
		for _, n in ipairs({"__KFlyVel","__KFlyGyro"}) do
			local old = hrp:FindFirstChild(n);
			if old then
				old:Destroy();
			end
		end
		hum.PlatformStand = true;
		bodyVel = Instance.new("BodyVelocity");
		bodyVel.Name = "__KFlyVel";
		bodyVel.Velocity = Vector3.zero;
		bodyVel.MaxForce = Vector3.new(100000, 100000, 100000);
		bodyVel.Parent = hrp;
		bodyGyro = Instance.new("BodyGyro");
		bodyGyro.Name = "__KFlyGyro";
		bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000);
		bodyGyro.D = 100;
		bodyGyro.Parent = hrp;
		flyConn = RunService.RenderStepped:Connect(function()
			if not State.Fly then
				return;
			end
			local cam = workspace.CurrentCamera;
			local dir = Vector3.zero;
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				dir += cam.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				dir -= cam.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				dir -= cam.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				dir += cam.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				dir += Vector3.yAxis
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				dir -= Vector3.yAxis
			end
			if bodyVel then
				bodyVel.Velocity = ((dir.Magnitude > 0) and (dir.Unit * State.FlySpeed)) or Vector3.zero;
			end
			if bodyGyro then
				bodyGyro.CFrame = cam.CFrame;
			end
		end);
	end
	local function disableFly()
		if flyConn then
			flyConn:Disconnect();
			flyConn = nil;
		end
		if bodyVel then
			bodyVel:Destroy();
			bodyVel = nil;
		end
		if bodyGyro then
			bodyGyro:Destroy();
			bodyGyro = nil;
		end
		local hum = getHum();
		if hum then
			hum.PlatformStand = false;
			task.delay(0.05, function()
				hum.PlatformStand = false;
				applyStats();
			end);
		end
	end
	local noclipConn;
	local noclipActive = false;
	local function enableNoclip()
		if noclipActive then
			return;
		end
		noclipActive = true;
		noclipConn = RunService.PreSimulation:Connect(function()
			if not noclipActive then
				return;
			end
			local c = getChar();
			if not c then
				return;
			end
			for _, p in c:GetDescendants() do
				if p:IsA("BasePart") then
					p.CanCollide = false;
				end
			end
			local hrp = c:FindFirstChild("HumanoidRootPart");
			if hrp then
				hrp.CanCollide = false;
			end
		end);
	end
	local function disableNoclip()
		if not noclipActive then
			return;
		end
		noclipActive = false;
		if noclipConn then
			noclipConn:Disconnect();
			noclipConn = nil;
		end
		local restoreConn;
		restoreConn = RunService.PreSimulation:Connect(function()
			restoreConn:Disconnect();
			local c = getChar();
			if not c then
				return;
			end
			for _, p in c:GetDescendants() do
				if p:IsA("BasePart") then
					p.CanCollide = true;
				end
			end
			local hrp = c:FindFirstChild("HumanoidRootPart");
			if hrp then
				hrp.CanCollide = true;
			end
		end);
	end
	local lockConn;
	local function startLockOn(target)
		State.LockTarget = target;
		if lockConn then
			lockConn:Disconnect();
		end
		lockConn = RunService.RenderStepped:Connect(function()
			if (not State.LockOn or not State.LockTarget) then
				return;
			end
			local tc = State.LockTarget.Character;
			if not tc then
				return;
			end
			local head = tc:FindFirstChild("Head");
			if not head then
				return;
			end
			workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, head.Position);
		end);
	end
	local function stopLockOn()
		if lockConn then
			lockConn:Disconnect();
			lockConn = nil;
		end
		State.LockTarget = nil;
	end
	local function teleportToPlayer(target)
		local tc = target.Character;
		if not tc then
			return;
		end
		local tHRP = tc:FindFirstChild("HumanoidRootPart");
		if not tHRP then
			return;
		end
		local hrp = getHRP();
		if not hrp then
			return;
		end
		hrp.CFrame = tHRP.CFrame + Vector3.new(2, 0, 2);
	end
	local function isTeammate(player)
		if not State.TeamCheck then
			return false;
		end
		if not LP.Team then
			return false;
		end
		if not player.Team then
			return false;
		end
		return LP.Team == player.Team;
	end
	local function isVisible(targetChar, headPos)
		if not State.WallCheck then
			return true;
		end
		local cam = workspace.CurrentCamera;
		local origin = cam.CFrame.Position;
		local dir = headPos - origin;
		local params = RaycastParams.new();
		params.FilterType = Enum.RaycastFilterType.Exclude;
		local myChar = getChar();
		params.FilterDescendantsInstances = (myChar and {myChar}) or {};
		local result = workspace:Raycast(origin, dir, params);
		if not result then
			return true;
		end
		return result.Instance:IsDescendantOf(targetChar);
	end
	local function closestInFOV()
		local cam = workspace.CurrentCamera;
		local vp = cam.ViewportSize;
		local center = Vector2.new(vp.X / 2, vp.Y / 2);
		local best, bestDist = nil, math.huge;
		for _, p in ipairs(Players:GetPlayers()) do
			if (p == LP) then
				continue;
			end
			if isTeammate(p) then
				continue;
			end
			local char = p.Character;
			if not char then
				continue;
			end
			local head = char:FindFirstChild("Head");
			if not head then
				continue;
			end
			local hum = char:FindFirstChildOfClass("Humanoid");
			if (hum and (hum.Health <= 0)) then
				continue;
			end
			local sp, on = cam:WorldToViewportPoint(head.CFrame.Position);
			if not on then
				continue;
			end
			local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude;
			if (d >= State.FOVSize) then
				continue;
			end
			if not isVisible(char, head.CFrame.Position) then
				continue;
			end
			if (d < bestDist) then
				bestDist = d;
				best = p;
			end
		end
		return best;
	end
	local espData = {};
	local espConn;
	local fovStroke = nil;
	local BB_W, BB_H = 108, 46;
	local LBL_NAME_H = 13;
	local LBL_TEAM_H = 10;
	local LBL_DIST_H = 9;
	local TXT_NAME_SIZE = 11;
	local TXT_TEAM_SIZE = 9;
	local TXT_DIST_SIZE = 8;
	local function espColor(player)
		if (State.TeamCheck and player.Team and LP.Team and (player.Team == LP.Team)) then
			return Color3.fromRGB(52, 211, 153);
		end
		return State.ESPColor;
	end
	local function makeESPGui(player)
		local sg = Instance.new("ScreenGui");
		sg.Name = "KESP_" .. player.UserId;
		sg.ResetOnSpawn = false;
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
		sg.IgnoreGuiInset = true;
		sg.DisplayOrder = 5;
		local ok2 = pcall(function()
			sg.Parent = game:GetService("CoreGui");
		end);
		if not ok2 then
			sg.Parent = LP:WaitForChild("PlayerGui");
		end
		return sg;
	end
	local function buildESPFor(player)
		if (player == LP) then
			return;
		end
		if espData[player] then
			return;
		end
		local col = espColor(player);
		local data = {};
		local hl = Instance.new("Highlight");
		hl.FillColor = col;
		hl.OutlineColor = Color3.fromRGB(255, 255, 255);
		hl.FillTransparency = 0.55;
		hl.OutlineTransparency = 0;
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
		data.hl = hl;
		local bb = Instance.new("BillboardGui");
		bb.Name = "KESPBB";
		bb.Size = UDim2.new(0, BB_W, 0, BB_H);
		bb.StudsOffset = Vector3.new(0, 3.6, 0);
		bb.AlwaysOnTop = true;
		data.bb = bb;
		local bg = Instance.new("Frame");
		bg.Size = UDim2.new(1, 0, 1, 0);
		bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		bg.BackgroundTransparency = 0.45;
		bg.BorderSizePixel = 0;
		bg.Parent = bb;
		Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4);
		local function makeLbl(yPos, h, text, color, bold, size)
			local l = Instance.new("TextLabel");
			l.Size = UDim2.new(1, 0, 0, h);
			l.Position = UDim2.new(0, 0, 0, yPos);
			l.BackgroundTransparency = 1;
			l.Text = text;
			l.TextColor3 = color;
			l.TextStrokeTransparency = 0;
			l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0);
			l.Font = (bold and Enum.Font.GothamBold) or Enum.Font.Gotham;
			l.TextSize = size;
			l.TextScaled = false;
			l.Parent = bg;
			return l;
		end
		data.nameLbl = makeLbl(1, LBL_NAME_H, player.Name, col, true, TXT_NAME_SIZE);
		data.nameLbl.Visible = State.ESPName;
		data.teamLbl = makeLbl(1 + LBL_NAME_H, LBL_TEAM_H, (player.Team and player.Team.Name) or "No Team", (player.Team and player.Team.TeamColor and player.Team.TeamColor.Color) or Color3.fromRGB(200, 200, 200), false, TXT_TEAM_SIZE);
		data.teamLbl.Visible = State.ESPTeamName;
		data.distLbl = makeLbl(1 + LBL_NAME_H + LBL_TEAM_H, LBL_DIST_H, "", Color3.fromRGB(200, 200, 200), false, TXT_DIST_SIZE);
		local hpTrack = Instance.new("Frame");
		hpTrack.Size = UDim2.new(1, -6, 0, 4);
		hpTrack.Position = UDim2.new(0, 3, 1, -5);
		hpTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
		hpTrack.BackgroundTransparency = 0.2;
		hpTrack.BorderSizePixel = 0;
		hpTrack.Visible = State.ESPHealth;
		hpTrack.Parent = bg;
		Instance.new("UICorner", hpTrack).CornerRadius = UDim.new(1, 0);
		data.hpTrack = hpTrack;
		local hpFill = Instance.new("Frame");
		hpFill.Size = UDim2.new(1, 0, 1, 0);
		hpFill.BackgroundColor3 = C.green;
		hpFill.BorderSizePixel = 0;
		hpFill.Parent = hpTrack;
		Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0);
		data.hpFill = hpFill;
		data.sg = makeESPGui(player);
		bb.Parent = data.sg;
		data.char = nil;
		data.lastHealth = -1;
		espData[player] = data;
	end
	local function attachESPTo(player, char)
		local d = espData[player];
		if not d then
			return;
		end
		local hrp = char:FindFirstChild("HumanoidRootPart");
		if not hrp then
			return;
		end
		d.hl.Adornee = char;
		d.hl.Parent = char;
		d.bb.Parent = hrp;
		d.char = char;
		d.lastHealth = -1;
	end
	local function removeESPFor(player)
		local d = espData[player];
		if not d then
			return;
		end
		pcall(function()
			d.hl:Destroy();
		end);
		pcall(function()
			d.bb:Destroy();
		end);
		pcall(function()
			d.sg:Destroy();
		end);
		espData[player] = nil;
	end
	local function refreshESPColors()
		for p, d in pairs(espData) do
			local col = espColor(p);
			if d.hl then
				d.hl.FillColor = col;
			end
			if d.nameLbl then
				d.nameLbl.TextColor3 = col;
			end
		end
	end
	local myHRPCache = nil;
	local function tickESP()
		myHRPCache = getHRP();
		local cam = workspace.CurrentCamera;
		for p, d in pairs(espData) do
			local char = d.char;
			if (not char or not char.Parent) then
				continue;
			end
			local hrp = char:FindFirstChild("HumanoidRootPart");
			if (not hrp or not hrp.Parent) then
				continue;
			end
			local _, onScreen = cam:WorldToViewportPoint(hrp.Position);
			if not onScreen then
				continue;
			end
			local hum = char:FindFirstChildOfClass("Humanoid");
			local col = espColor(p);
			if (myHRPCache and d.distLbl) then
				d.distLbl.Text = math.floor((myHRPCache.Position - hrp.Position).Magnitude) .. " studs";
			end
			d.hpTrack.Visible = State.ESPHealth;
			if (hum and State.ESPHealth) then
				local hp = hum.Health;
				if (hp ~= d.lastHealth) then
					d.lastHealth = hp;
					local ratio = math.clamp(hp / math.max(hum.MaxHealth, 1), 0, 1);
					d.hpFill.Size = UDim2.new(ratio, 0, 1, 0);
					d.hpFill.BackgroundColor3 = ((ratio > 0.5) and C.green) or ((ratio > 0.25) and C.yellow) or C.red;
				end
			end
			d.nameLbl.Visible = State.ESPName;
			d.nameLbl.TextColor3 = col;
			d.teamLbl.Visible = State.ESPTeamName;
			d.teamLbl.Text = (p.Team and p.Team.Name) or "No Team";
			d.teamLbl.TextColor3 = (p.Team and p.Team.TeamColor and p.Team.TeamColor.Color) or Color3.fromRGB(200, 200, 200);
			d.hl.FillColor = col;
		end
	end
	local ESP_TICK_INTERVAL = 0.1;
	local espTickAccum = 0;
	local function enableESP()
		for _, p in ipairs(Players:GetPlayers()) do
			if (p == LP) then
				continue;
			end
			buildESPFor(p);
			if p.Character then
				attachESPTo(p, p.Character);
			end
		end
		espTickAccum = 0;
		espConn = RunService.Heartbeat:Connect(function(dt)
			for _, p in ipairs(Players:GetPlayers()) do
				if (p == LP) then
					continue;
				end
				if not espData[p] then
					buildESPFor(p);
				end
				local d = espData[p];
				if (d and p.Character and (p.Character ~= d.char)) then
					attachESPTo(p, p.Character);
				end
			end
			espTickAccum += dt
			if (espTickAccum >= ESP_TICK_INTERVAL) then
				espTickAccum = 0;
				tickESP();
			end
		end);
	end
	local function disableESP()
		if espConn then
			espConn:Disconnect();
			espConn = nil;
		end
		for p in pairs(espData) do
			removeESPFor(p);
		end
	end
	Players.PlayerAdded:Connect(function(p)
		p.CharacterAdded:Connect(function(char)
			if State.ESP then
				if not espData[p] then
					buildESPFor(p);
				end
				attachESPTo(p, char);
			end
		end);
	end);
	local fovCircle;
	local function removeOld()
		local cg = game:GetService("CoreGui"):FindFirstChild("KoenigseggHub");
		if cg then
			cg:Destroy();
		end
		local pg = LP:FindFirstChild("PlayerGui");
		if pg then
			local o1 = pg:FindFirstChild("KoenigseggHub");
			if o1 then
				o1:Destroy();
			end
			local o2 = pg:FindFirstChild("UniversalHub");
			if o2 then
				o2:Destroy();
			end
		end
	end
	removeOld();
	local SG = Instance.new("ScreenGui");
	SG.Name = "KoenigseggHub";
	SG.ResetOnSpawn = false;
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	SG.IgnoreGuiInset = true;
	local sgOk = pcall(function()
		SG.Parent = game:GetService("CoreGui");
	end);
	if not sgOk then
		SG.Parent = LP:WaitForChild("PlayerGui");
	end
	local function createFOVCircle()
		if fovCircle then
			fovCircle:Destroy();
		end
		local r = State.FOVSize;
		fovCircle = Instance.new("Frame");
		fovCircle.Name = "FOVRing";
		fovCircle.Size = UDim2.fromOffset(r * 2, r * 2);
		fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r);
		fovCircle.BackgroundTransparency = 1;
		fovCircle.BorderSizePixel = 0;
		fovCircle.Parent = SG;
		Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0);
		fovStroke = Instance.new("UIStroke", fovCircle);
		fovStroke.Color = State.FOVColor;
		fovStroke.Thickness = 1.5;
	end
	local function updateFOVCircle()
		if fovCircle then
			local r = State.FOVSize;
			fovCircle.Size = UDim2.fromOffset(r * 2, r * 2);
			fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r);
		end
		if fovStroke then
			fovStroke.Color = State.FOVColor;
		end
	end
	local function destroyFOVCircle()
		if fovCircle then
			fovCircle:Destroy();
			fovCircle = nil;
		end
		fovStroke = nil;
	end
	local aimbotConn;
	local aimbotTarget = nil;
	local targetHoldTime = 0;
	local function isTargetValid(p)
		if (not p or not p.Character) then
			return false;
		end
		if isTeammate(p) then
			return false;
		end
		local hum = p.Character:FindFirstChildOfClass("Humanoid");
		if (not hum or (hum.Health <= 0)) then
			return false;
		end
		local head = p.Character:FindFirstChild("Head");
		if not head then
			return false;
		end
		local sp, on = workspace.CurrentCamera:WorldToViewportPoint(head.CFrame.Position);
		if not on then
			return false;
		end
		local vp = workspace.CurrentCamera.ViewportSize;
		if ((Vector2.new(sp.X, sp.Y) - Vector2.new(vp.X / 2, vp.Y / 2)).Magnitude >= (State.FOVSize * 1.3)) then
			return false;
		end
		return isVisible(p.Character, head.CFrame.Position);
	end
	local function enableAimbot()
		createFOVCircle();
		aimbotTarget = nil;
		targetHoldTime = 0;
		aimbotConn = RunService.RenderStepped:Connect(function(dt)
			if not State.Aimbot then
				return;
			end
			if (aimbotTarget and isTargetValid(aimbotTarget)) then
				targetHoldTime += dt
			else
				aimbotTarget = closestInFOV();
				targetHoldTime = 0;
			end
			if (targetHoldTime > 0.5) then
				local nt = closestInFOV();
				if (nt and (nt ~= aimbotTarget)) then
					local cam = workspace.CurrentCamera;
					local vp = cam.ViewportSize;
					local ctr = Vector2.new(vp.X / 2, vp.Y / 2);
					local function sd(p2)
						local c2 = p2.Character;
						if not c2 then
							return math.huge;
						end
						local h2 = c2:FindFirstChild("Head");
						if not h2 then
							return math.huge;
						end
						local s2, o2 = cam:WorldToViewportPoint(h2.CFrame.Position);
						return (o2 and (Vector2.new(s2.X, s2.Y) - ctr).Magnitude) or math.huge;
					end
					if (sd(nt) < (sd(aimbotTarget) - 30)) then
						aimbotTarget = nt;
						targetHoldTime = 0;
					end
				end
			end
			if not aimbotTarget then
				return;
			end
			local char = aimbotTarget.Character;
			if not char then
				return;
			end
			local head = char:FindFirstChild("Head");
			if not head then
				return;
			end
			local cam = workspace.CurrentCamera;
			local from = cam.CFrame;
			local to = CFrame.lookAt(from.Position, head.CFrame.Position);
			local s = State.AimbotSmooth / 100;
			local a = math.clamp(s * 60 * (1 / math.max(dt * 60, 0.001)) * dt, 0, 1);
			cam.CFrame = from:Lerp(to, a);
		end);
	end
	local function disableAimbot()
		if aimbotConn then
			aimbotConn:Disconnect();
			aimbotConn = nil;
		end
		aimbotTarget = nil;
		destroyFOVCircle();
	end
	local function makeDraggable(frame, handle)
		local dragging, dragStart, startPos = false;
		handle.InputBegan:Connect(function(i)
			if ((i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch)) then
				dragging = true;
				dragStart = i.Position;
				startPos = frame.Position;
				i.Changed:Connect(function()
					if (i.UserInputState == Enum.UserInputState.End) then
						dragging = false;
					end
				end);
			end
		end);
		UserInputService.InputChanged:Connect(function(i)
			if not dragging then
				return;
			end
			if ((i.UserInputType == Enum.UserInputType.MouseMovement) or (i.UserInputType == Enum.UserInputType.Touch)) then
				local d = i.Position - dragStart;
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y);
			end
		end);
	end
	local KF = Instance.new("Frame");
	KF.Size = UDim2.new(0, 320, 0, 210);
	KF.Position = UDim2.new(0.5, -160, 0.5, -105);
	KF.BackgroundColor3 = C.bg1;
	KF.BorderSizePixel = 0;
	KF.Parent = SG;
	Instance.new("UICorner", KF).CornerRadius = UDim.new(0, 14);
	do
		local s = Instance.new("UIStroke", KF);
		s.Color = C.accent;
		s.Thickness = 1.5;
	end
	makeDraggable(KF, KF);
	do
		local a = Instance.new("Frame");
		a.Size = UDim2.new(1, 0, 0, 4);
		a.BackgroundColor3 = C.accent;
		a.BorderSizePixel = 0;
		a.Parent = KF;
		Instance.new("UICorner", a).CornerRadius = UDim.new(0, 14);
	end
	local function kLabel(txt, yOff, size, color, bold, xAlign)
		local l = Instance.new("TextLabel");
		l.Size = UDim2.new(1, -30, 0, size or 16);
		l.Position = UDim2.new(0, 15, 0, yOff);
		l.BackgroundTransparency = 1;
		l.Text = txt;
		l.TextColor3 = color or C.white;
		l.Font = (bold and Enum.Font.GothamBold) or Enum.Font.Gotham;
		l.TextSize = size or 12;
		l.TextXAlignment = xAlign or Enum.TextXAlignment.Left;
		l.Parent = KF;
		return l;
	end
	kLabel("🔑  Key Required", 6, 17, C.white, true, Enum.TextXAlignment.Center);
	kLabel("Enter your access key to unlock the hub", 44, 11, C.subtext);
	local KBox = Instance.new("TextBox");
	KBox.Size = UDim2.new(1, -30, 0, 34);
	KBox.Position = UDim2.new(0, 15, 0, 62);
	KBox.BackgroundColor3 = C.bg2;
	KBox.BorderSizePixel = 0;
	KBox.PlaceholderText = "Enter key...";
	KBox.PlaceholderColor3 = C.subtext;
	KBox.TextColor3 = C.accentGlow;
	KBox.Font = Enum.Font.Gotham;
	KBox.TextSize = 14;
	KBox.Text = "";
	KBox.Parent = KF;
	Instance.new("UICorner", KBox).CornerRadius = UDim.new(0, 8);
	do
		local s = Instance.new("UIStroke", KBox);
		s.Color = C.bg3;
		s.Thickness = 1.2;
	end
	local KErr = kLabel("", 102, 11, C.red, false, Enum.TextXAlignment.Left);
	local KLinkBox = Instance.new("TextBox");
	KLinkBox.Size = UDim2.new(1, -80, 0, 28);
	KLinkBox.Position = UDim2.new(0, 15, 0, 120);
	KLinkBox.BackgroundColor3 = C.bg2;
	KLinkBox.BorderSizePixel = 0;
	KLinkBox.Text = KEY_LINK;
	KLinkBox.TextColor3 = C.accentGlow;
	KLinkBox.Font = Enum.Font.Gotham;
	KLinkBox.TextSize = 10;
	KLinkBox.ClearTextOnFocus = false;
	KLinkBox.TextEditable = false;
	KLinkBox.Parent = KF;
	Instance.new("UICorner", KLinkBox).CornerRadius = UDim.new(0, 6);
	local KCopyF = Instance.new("Frame");
	KCopyF.Size = UDim2.new(0, 56, 0, 28);
	KCopyF.Position = UDim2.new(1, -71, 0, 120);
	KCopyF.BackgroundColor3 = C.accent;
	KCopyF.BorderSizePixel = 0;
	KCopyF.Parent = KF;
	Instance.new("UICorner", KCopyF).CornerRadius = UDim.new(0, 6);
	local KCopyTxt = Instance.new("TextLabel");
	KCopyTxt.Size = UDim2.new(1, 0, 1, 0);
	KCopyTxt.BackgroundTransparency = 1;
	KCopyTxt.Text = "Copy Link";
	KCopyTxt.TextColor3 = C.white;
	KCopyTxt.Font = Enum.Font.GothamBold;
	KCopyTxt.TextSize = 10;
	KCopyTxt.Parent = KCopyF;
	local KCopyBtn = Instance.new("TextButton");
	KCopyBtn.Size = UDim2.new(1, 0, 1, 0);
	KCopyBtn.BackgroundTransparency = 1;
	KCopyBtn.Text = "";
	KCopyBtn.Parent = KCopyF;
	KCopyBtn.MouseButton1Click:Connect(function()
		KLinkBox:CaptureFocus();
		KLinkBox.CursorPosition = 1;
		KLinkBox.SelectionStart = #KEY_LINK + 1;
		KCopyTxt.Text = "Ctrl+C now";
		task.delay(2, function()
			KCopyTxt.Text = "Copy Link";
		end);
	end);
	local KBtn = Instance.new("TextButton");
	KBtn.Size = UDim2.new(1, -30, 0, 34);
	KBtn.Position = UDim2.new(0, 15, 0, 156);
	KBtn.BackgroundColor3 = C.accent;
	KBtn.BorderSizePixel = 0;
	KBtn.Text = "Unlock Hub";
	KBtn.TextColor3 = C.white;
	KBtn.Font = Enum.Font.GothamBold;
	KBtn.TextSize = 14;
	KBtn.Parent = KF;
	Instance.new("UICorner", KBtn).CornerRadius = UDim.new(0, 8);
	local MF = Instance.new("Frame");
	MF.Size = UDim2.new(0, 420, 0, 700);
	MF.Position = UDim2.new(0.5, -210, 0.5, -350);
	MF.BackgroundColor3 = C.bg0;
	MF.BorderSizePixel = 0;
	MF.Visible = false;
	MF.Parent = SG;
	Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 14);
	do
		local s = Instance.new("UIStroke", MF);
		s.Color = C.bg3;
		s.Thickness = 1;
	end
	local TB = Instance.new("Frame");
	TB.Size = UDim2.new(1, 0, 0, 44);
	TB.BackgroundColor3 = C.bg1;
	TB.BorderSizePixel = 0;
	TB.Parent = MF;
	Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 14);
	do
		local ln = Instance.new("Frame");
		ln.Size = UDim2.new(1, 0, 0, 2);
		ln.Position = UDim2.new(0, 0, 1, -2);
		ln.BackgroundColor3 = C.accent;
		ln.BorderSizePixel = 0;
		ln.Parent = TB;
	end
	do
		local dot = Instance.new("Frame");
		dot.Size = UDim2.new(0, 10, 0, 10);
		dot.Position = UDim2.new(0, 14, 0.5, -5);
		dot.BackgroundColor3 = C.accent;
		dot.BorderSizePixel = 0;
		dot.Parent = TB;
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0);
	end
	do
		local tbl = Instance.new("TextLabel");
		tbl.Size = UDim2.new(0.6, 0, 1, 0);
		tbl.Position = UDim2.new(0, 32, 0, 0);
		tbl.BackgroundTransparency = 1;
		tbl.Text = "KoenigseggHub";
		tbl.TextColor3 = C.white;
		tbl.Font = Enum.Font.GothamBold;
		tbl.TextSize = 15;
		tbl.TextXAlignment = Enum.TextXAlignment.Left;
		tbl.Parent = TB;
		local sub = Instance.new("TextLabel");
		sub.Size = UDim2.new(0.5, 0, 0, 13);
		sub.Position = UDim2.new(0, 32, 0, 26);
		sub.BackgroundTransparency = 1;
		sub.Text = "v4.6 · drag to move";
		sub.TextColor3 = C.subtext;
		sub.Font = Enum.Font.Gotham;
		sub.TextSize = 10;
		sub.TextXAlignment = Enum.TextXAlignment.Left;
		sub.Parent = TB;
	end
	local MinB = Instance.new("TextButton");
	MinB.Size = UDim2.new(0, 28, 0, 20);
	MinB.Position = UDim2.new(1, -38, 0.5, -10);
	MinB.BackgroundColor3 = C.bg3;
	MinB.BorderSizePixel = 0;
	MinB.Text = "—";
	MinB.TextColor3 = C.subtext;
	MinB.Font = Enum.Font.GothamBold;
	MinB.TextSize = 13;
	MinB.Parent = TB;
	Instance.new("UICorner", MinB).CornerRadius = UDim.new(0, 6);
	makeDraggable(MF, TB);
	local SF = Instance.new("ScrollingFrame");
	SF.Size = UDim2.new(1, -12, 1, -52);
	SF.Position = UDim2.new(0, 6, 0, 49);
	SF.BackgroundTransparency = 1;
	SF.BorderSizePixel = 0;
	SF.ScrollBarThickness = 3;
	SF.ScrollBarImageColor3 = C.accent;
	SF.CanvasSize = UDim2.new(0, 0, 0, 0);
	SF.AutomaticCanvasSize = Enum.AutomaticSize.Y;
	SF.Parent = MF;
	do
		local ll = Instance.new("UIListLayout");
		ll.SortOrder = Enum.SortOrder.LayoutOrder;
		ll.Padding = UDim.new(0, 4);
		ll.Parent = SF;
		local pad = Instance.new("UIPadding");
		pad.PaddingLeft = UDim.new(0, 4);
		pad.PaddingRight = UDim.new(0, 4);
		pad.PaddingTop = UDim.new(0, 6);
		pad.PaddingBottom = UDim.new(0, 10);
		pad.Parent = SF;
	end
	local function section(txt, icon)
		local f = Instance.new("Frame");
		f.Size = UDim2.new(1, 0, 0, 28);
		f.BackgroundColor3 = C.bg2;
		f.BorderSizePixel = 0;
		f.Parent = SF;
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7);
		local dot = Instance.new("Frame");
		dot.Size = UDim2.new(0, 4, 0, 14);
		dot.Position = UDim2.new(0, 10, 0.5, -7);
		dot.BackgroundColor3 = C.accent;
		dot.BorderSizePixel = 0;
		dot.Parent = f;
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0);
		local l = Instance.new("TextLabel");
		l.Size = UDim2.new(1, -24, 1, 0);
		l.Position = UDim2.new(0, 22, 0, 0);
		l.BackgroundTransparency = 1;
		l.Text = (icon or "") .. "  " .. txt;
		l.TextColor3 = C.subtext;
		l.Font = Enum.Font.GothamBold;
		l.TextSize = 11;
		l.TextXAlignment = Enum.TextXAlignment.Left;
		l.Parent = f;
	end
	local function toggle(lbl, sub, onEnable, onDisable, startOn)
		local row = Instance.new("Frame");
		row.Size = UDim2.new(1, 0, 0, 46);
		row.BackgroundColor3 = C.bg1;
		row.BorderSizePixel = 0;
		row.Parent = SF;
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9);
		local title = Instance.new("TextLabel");
		title.Size = UDim2.new(0.65, 0, 0, 20);
		title.Position = UDim2.new(0, 12, 0, 7);
		title.BackgroundTransparency = 1;
		title.Text = lbl;
		title.TextColor3 = C.white;
		title.Font = Enum.Font.GothamBold;
		title.TextSize = 13;
		title.TextXAlignment = Enum.TextXAlignment.Left;
		title.Parent = row;
		if (sub and (sub ~= "")) then
			local s = Instance.new("TextLabel");
			s.Size = UDim2.new(0.65, 0, 0, 14);
			s.Position = UDim2.new(0, 12, 0, 27);
			s.BackgroundTransparency = 1;
			s.Text = sub;
			s.TextColor3 = C.subtext;
			s.Font = Enum.Font.Gotham;
			s.TextSize = 10;
			s.TextXAlignment = Enum.TextXAlignment.Left;
			s.Parent = row;
		end
		local active = startOn or false;
		local pill = Instance.new("Frame");
		pill.Size = UDim2.new(0, 46, 0, 24);
		pill.Position = UDim2.new(1, -58, 0.5, -12);
		pill.BackgroundColor3 = (active and C.accent) or C.bg3;
		pill.BorderSizePixel = 0;
		pill.Parent = row;
		Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0);
		local knob = Instance.new("Frame");
		knob.Size = UDim2.new(0, 18, 0, 18);
		knob.Position = (active and UDim2.new(1, -21, 0.5, -9)) or UDim2.new(0, 3, 0.5, -9);
		knob.BackgroundColor3 = (active and C.white) or C.subtext;
		knob.BorderSizePixel = 0;
		knob.Parent = pill;
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0);
		local btn = Instance.new("TextButton");
		btn.Size = UDim2.new(1, 0, 1, 0);
		btn.BackgroundTransparency = 1;
		btn.Text = "";
		btn.Parent = pill;
		local function setActive(v)
			active = v;
			pill.BackgroundColor3 = (v and C.accent) or C.bg3;
			knob.BackgroundColor3 = (v and C.white) or C.subtext;
			knob.Position = (v and UDim2.new(1, -21, 0.5, -9)) or UDim2.new(0, 3, 0.5, -9);
			if v then
				pcall(onEnable);
			else
				pcall(onDisable);
			end
		end
		btn.MouseButton1Click:Connect(function()
			setActive(not active);
		end);
		return row, function()
			return active;
		end;
	end
	local function statRowWithToggle(lbl, stateKey, enableKey, minV, maxV, step, defaultV, onChange)
		local row = Instance.new("Frame");
		row.Size = UDim2.new(1, 0, 0, 50);
		row.BackgroundColor3 = C.bg1;
		row.BorderSizePixel = 0;
		row.Parent = SF;
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9);
		local pill = Instance.new("Frame");
		pill.Size = UDim2.new(0, 40, 0, 20);
		pill.Position = UDim2.new(1, -50, 0, 8);
		pill.BackgroundColor3 = C.bg3;
		pill.BorderSizePixel = 0;
		pill.Parent = row;
		Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0);
		local knob = Instance.new("Frame");
		knob.Size = UDim2.new(0, 15, 0, 15);
		knob.Position = UDim2.new(0, 3, 0.5, -7);
		knob.BackgroundColor3 = C.subtext;
		knob.BorderSizePixel = 0;
		knob.Parent = pill;
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0);
		local pillBtn = Instance.new("TextButton");
		pillBtn.Size = UDim2.new(1, 0, 1, 0);
		pillBtn.BackgroundTransparency = 1;
		pillBtn.Text = "";
		pillBtn.Parent = pill;
		local function setPill(v)
			State[enableKey] = v;
			pill.BackgroundColor3 = (v and C.accent) or C.bg3;
			knob.BackgroundColor3 = (v and C.white) or C.subtext;
			knob.Position = (v and UDim2.new(1, -18, 0.5, -7)) or UDim2.new(0, 3, 0.5, -7);
			if onChange then
				pcall(onChange);
			end
		end
		pillBtn.MouseButton1Click:Connect(function()
			setPill(not State[enableKey]);
		end);
		local l = Instance.new("TextLabel");
		l.Size = UDim2.new(0.28, 0, 0, 20);
		l.Position = UDim2.new(0, 12, 0, 6);
		l.BackgroundTransparency = 1;
		l.Text = lbl;
		l.TextColor3 = C.white;
		l.Font = Enum.Font.Gotham;
		l.TextSize = 12;
		l.TextXAlignment = Enum.TextXAlignment.Left;
		l.Parent = row;
		local vb = Instance.new("TextBox");
		vb.Size = UDim2.new(0, 50, 0, 26);
		vb.Position = UDim2.new(0, 12, 0, 18);
		vb.BackgroundColor3 = C.bg2;
		vb.BorderSizePixel = 0;
		vb.Text = tostring(State[stateKey]);
		vb.TextColor3 = C.accentGlow;
		vb.Font = Enum.Font.GothamBold;
		vb.TextSize = 13;
		vb.ClearTextOnFocus = true;
		vb.Parent = row;
		Instance.new("UICorner", vb).CornerRadius = UDim.new(0, 6);
		do
			local s = Instance.new("UIStroke", vb);
			s.Color = C.bg3;
			s.Thickness = 1;
		end
		vb.FocusLost:Connect(function()
			local n = tonumber(vb.Text);
			if n then
				n = math.clamp(math.floor(n), minV, maxV);
				State[stateKey] = n;
				vb.Text = tostring(n);
				if onChange then
					pcall(onChange);
				end
			else
				vb.Text = tostring(State[stateKey]);
			end
		end);
		local function mkBtn(txt, xOff, col)
			local b = Instance.new("TextButton");
			b.Size = UDim2.new(0, 26, 0, 26);
			b.Position = UDim2.new(0, 66 + xOff, 0, 18);
			b.BackgroundColor3 = col or C.bg2;
			b.BorderSizePixel = 0;
			b.Text = txt;
			b.TextColor3 = C.white;
			b.Font = Enum.Font.GothamBold;
			b.TextSize = 14;
			b.Parent = row;
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6);
			return b;
		end
		local mb = mkBtn("−", 0, C.bg3);
		local pb = mkBtn("+", 30, C.accent);
		local rb = Instance.new("TextButton");
		rb.Size = UDim2.new(0, 32, 0, 22);
		rb.Position = UDim2.new(0, 128, 0, 21);
		rb.BackgroundColor3 = C.bg2;
		rb.BorderSizePixel = 0;
		rb.Text = "RST";
		rb.TextColor3 = C.subtext;
		rb.Font = Enum.Font.GothamBold;
		rb.TextSize = 10;
		rb.Parent = row;
		Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 5);
		mb.MouseButton1Click:Connect(function()
			State[stateKey] = math.max(minV, State[stateKey] - step);
			vb.Text = tostring(State[stateKey]);
			if onChange then
				pcall(onChange);
			end
		end);
		pb.MouseButton1Click:Connect(function()
			State[stateKey] = math.min(maxV, State[stateKey] + step);
			vb.Text = tostring(State[stateKey]);
			if onChange then
				pcall(onChange);
			end
		end);
		rb.MouseButton1Click:Connect(function()
			State[stateKey] = defaultV;
			vb.Text = tostring(defaultV);
			if onChange then
				pcall(onChange);
			end
		end);
		return vb;
	end
	local function statRow(lbl, stateKey, minV, maxV, step, defaultV, onChange)
		local row = Instance.new("Frame");
		row.Size = UDim2.new(1, 0, 0, 40);
		row.BackgroundColor3 = C.bg1;
		row.BorderSizePixel = 0;
		row.Parent = SF;
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9);
		local l = Instance.new("TextLabel");
		l.Size = UDim2.new(0.3, 0, 1, 0);
		l.Position = UDim2.new(0, 12, 0, 0);
		l.BackgroundTransparency = 1;
		l.Text = lbl;
		l.TextColor3 = C.white;
		l.Font = Enum.Font.Gotham;
		l.TextSize = 12;
		l.TextXAlignment = Enum.TextXAlignment.Left;
		l.Parent = row;
		local vb = Instance.new("TextBox");
		vb.Size = UDim2.new(0, 50, 0, 26);
		vb.Position = UDim2.new(0.32, 0, 0.5, -13);
		vb.BackgroundColor3 = C.bg2;
		vb.BorderSizePixel = 0;
		vb.Text = tostring(State[stateKey]);
		vb.TextColor3 = C.accentGlow;
		vb.Font = Enum.Font.GothamBold;
		vb.TextSize = 13;
		vb.ClearTextOnFocus = true;
		vb.Parent = row;
		Instance.new("UICorner", vb).CornerRadius = UDim.new(0, 6);
		do
			local s = Instance.new("UIStroke", vb);
			s.Color = C.bg3;
			s.Thickness = 1;
		end
		vb.FocusLost:Connect(function()
			local n = tonumber(vb.Text);
			if n then
				n = math.clamp(math.floor(n), minV, maxV);
				State[stateKey] = n;
				vb.Text = tostring(n);
				if onChange then
					pcall(onChange);
				end
			else
				vb.Text = tostring(State[stateKey]);
			end
		end);
		local function mkBtn(txt, xOff, col)
			local b = Instance.new("TextButton");
			b.Size = UDim2.new(0, 26, 0, 26);
			b.Position = UDim2.new(0.32, 54 + xOff, 0.5, -13);
			b.BackgroundColor3 = col or C.bg2;
			b.BorderSizePixel = 0;
			b.Text = txt;
			b.TextColor3 = C.white;
			b.Font = Enum.Font.GothamBold;
			b.TextSize = 14;
			b.Parent = row;
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6);
			return b;
		end
		local mb = mkBtn("−", 0, C.bg3);
		local pb = mkBtn("+", 30, C.accent);
		local rb = Instance.new("TextButton");
		rb.Size = UDim2.new(0, 32, 0, 22);
		rb.Position = UDim2.new(1, -40, 0.5, -11);
		rb.BackgroundColor3 = C.bg2;
		rb.BorderSizePixel = 0;
		rb.Text = "RST";
		rb.TextColor3 = C.subtext;
		rb.Font = Enum.Font.GothamBold;
		rb.TextSize = 10;
		rb.Parent = row;
		Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 5);
		mb.MouseButton1Click:Connect(function()
			State[stateKey] = math.max(minV, State[stateKey] - step);
			vb.Text = tostring(State[stateKey]);
			if onChange then
				pcall(onChange);
			end
		end);
		pb.MouseButton1Click:Connect(function()
			State[stateKey] = math.min(maxV, State[stateKey] + step);
			vb.Text = tostring(State[stateKey]);
			if onChange then
				pcall(onChange);
			end
		end);
		rb.MouseButton1Click:Connect(function()
			State[stateKey] = defaultV;
			vb.Text = tostring(defaultV);
			if onChange then
				pcall(onChange);
			end
		end);
		return vb;
	end
	local function colorPickerRow(lbl, getColor, setColor)
		local wrap = Instance.new("Frame");
		wrap.Size = UDim2.new(1, 0, 0, 110);
		wrap.BackgroundColor3 = C.bg1;
		wrap.BorderSizePixel = 0;
		wrap.Parent = SF;
		Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 9);
		local hdr = Instance.new("TextLabel");
		hdr.Size = UDim2.new(1, -16, 0, 20);
		hdr.Position = UDim2.new(0, 12, 0, 6);
		hdr.BackgroundTransparency = 1;
		hdr.Text = lbl;
		hdr.TextColor3 = C.white;
		hdr.Font = Enum.Font.GothamBold;
		hdr.TextSize = 12;
		hdr.TextXAlignment = Enum.TextXAlignment.Left;
		hdr.Parent = wrap;
		local swatch = Instance.new("Frame");
		swatch.Size = UDim2.new(0, 28, 0, 28);
		swatch.Position = UDim2.new(1, -40, 0, 6);
		swatch.BackgroundColor3 = getColor();
		swatch.BorderSizePixel = 0;
		swatch.Parent = wrap;
		Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 6);
		do
			local s = Instance.new("UIStroke", swatch);
			s.Color = C.bg3;
			s.Thickness = 1;
		end
		local channels = {{"R","r"},{"G","g"},{"B","b"}};
		local function getRGB()
			local col = getColor();
			return {r=math.floor(col.R * 255),g=math.floor(col.G * 255),b=math.floor(col.B * 255)};
		end
		local function applyRGB(rgb)
			local col = Color3.fromRGB(rgb.r, rgb.g, rgb.b);
			setColor(col);
			swatch.BackgroundColor3 = col;
		end
		local cur = getRGB();
		for i, ch in ipairs(channels) do
			local y = 28 + ((i - 1) * 26);
			local cl = Instance.new("TextLabel");
			cl.Size = UDim2.new(0, 14, 0, 20);
			cl.Position = UDim2.new(0, 12, 0, y + 3);
			cl.BackgroundTransparency = 1;
			cl.Text = ch[1];
			cl.TextColor3 = C.subtext;
			cl.Font = Enum.Font.GothamBold;
			cl.TextSize = 11;
			cl.Parent = wrap;
			local track = Instance.new("Frame");
			track.Size = UDim2.new(1, -100, 0, 8);
			track.Position = UDim2.new(0, 30, 0, y + 9);
			track.BackgroundColor3 = C.bg3;
			track.BorderSizePixel = 0;
			track.Parent = wrap;
			Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0);
			local fill = Instance.new("Frame");
			fill.Size = UDim2.new(cur[ch[2]] / 255, 0, 1, 0);
			fill.BackgroundColor3 = C.accent;
			fill.BorderSizePixel = 0;
			fill.Parent = track;
			Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0);
			local thumb = Instance.new("Frame");
			thumb.Size = UDim2.new(0, 14, 0, 14);
			thumb.Position = UDim2.new(cur[ch[2]] / 255, -7, 0.5, -7);
			thumb.BackgroundColor3 = C.white;
			thumb.BorderSizePixel = 0;
			thumb.Parent = track;
			Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0);
			local vbox = Instance.new("TextBox");
			vbox.Size = UDim2.new(0, 40, 0, 22);
			vbox.Position = UDim2.new(1, -48, 0, y + 5);
			vbox.BackgroundColor3 = C.bg2;
			vbox.BorderSizePixel = 0;
			vbox.Text = tostring(cur[ch[2]]);
			vbox.TextColor3 = C.accentGlow;
			vbox.Font = Enum.Font.GothamBold;
			vbox.TextSize = 11;
			vbox.ClearTextOnFocus = true;
			vbox.Parent = wrap;
			Instance.new("UICorner", vbox).CornerRadius = UDim.new(0, 5);
			local drag = false;
			local function upd(ratio)
				ratio = math.clamp(ratio, 0, 1);
				local val = math.floor(ratio * 255);
				cur[ch[2]] = val;
				fill.Size = UDim2.new(ratio, 0, 1, 0);
				thumb.Position = UDim2.new(ratio, -7, 0.5, -7);
				vbox.Text = tostring(val);
				applyRGB(cur);
			end
			track.InputBegan:Connect(function(inp)
				if ((inp.UserInputType == Enum.UserInputType.MouseButton1) or (inp.UserInputType == Enum.UserInputType.Touch)) then
					drag = true;
					upd((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X);
				end
			end);
			UserInputService.InputChanged:Connect(function(inp)
				if not drag then
					return;
				end
				if ((inp.UserInputType == Enum.UserInputType.MouseMovement) or (inp.UserInputType == Enum.UserInputType.Touch)) then
					upd((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X);
				end
			end);
			UserInputService.InputEnded:Connect(function(inp)
				if ((inp.UserInputType == Enum.UserInputType.MouseButton1) or (inp.UserInputType == Enum.UserInputType.Touch)) then
					drag = false;
				end
			end);
			vbox.FocusLost:Connect(function()
				local n = tonumber(vbox.Text);
				if n then
					n = math.clamp(math.floor(n), 0, 255);
					cur[ch[2]] = n;
					local r = n / 255;
					fill.Size = UDim2.new(r, 0, 1, 0);
					thumb.Position = UDim2.new(r, -7, 0.5, -7);
					vbox.Text = tostring(n);
					applyRGB(cur);
				else
					vbox.Text = tostring(cur[ch[2]]);
				end
			end);
		end
		return wrap;
	end
	local function fovSliderRow()
		local row = Instance.new("Frame");
		row.Size = UDim2.new(1, 0, 0, 60);
		row.BackgroundColor3 = C.bg1;
		row.BorderSizePixel = 0;
		row.Parent = SF;
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9);
		local l = Instance.new("TextLabel");
		l.Size = UDim2.new(0.5, 0, 0, 18);
		l.Position = UDim2.new(0, 12, 0, 6);
		l.BackgroundTransparency = 1;
		l.Text = "FOV Radius";
		l.TextColor3 = C.white;
		l.Font = Enum.Font.Gotham;
		l.TextSize = 12;
		l.TextXAlignment = Enum.TextXAlignment.Left;
		l.Parent = row;
		local vb = Instance.new("TextBox");
		vb.Size = UDim2.new(0, 50, 0, 22);
		vb.Position = UDim2.new(1, -62, 0, 6);
		vb.BackgroundColor3 = C.bg2;
		vb.BorderSizePixel = 0;
		vb.Text = tostring(State.FOVSize);
		vb.TextColor3 = C.accentGlow;
		vb.Font = Enum.Font.GothamBold;
		vb.TextSize = 12;
		vb.ClearTextOnFocus = true;
		vb.Parent = row;
		Instance.new("UICorner", vb).CornerRadius = UDim.new(0, 5);
		local track = Instance.new("Frame");
		track.Size = UDim2.new(1, -24, 0, 8);
		track.Position = UDim2.new(0, 12, 0, 38);
		track.BackgroundColor3 = C.bg3;
		track.BorderSizePixel = 0;
		track.Parent = row;
		Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0);
		local mn, mx = 20, 600;
		local r0 = (State.FOVSize - mn) / (mx - mn);
		local fill = Instance.new("Frame");
		fill.Size = UDim2.new(r0, 0, 1, 0);
		fill.BackgroundColor3 = C.accent;
		fill.BorderSizePixel = 0;
		fill.Parent = track;
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0);
		local thumb = Instance.new("Frame");
		thumb.Size = UDim2.new(0, 14, 0, 14);
		thumb.Position = UDim2.new(r0, -7, 0.5, -7);
		thumb.BackgroundColor3 = C.white;
		thumb.BorderSizePixel = 0;
		thumb.Parent = track;
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0);
		local drag = false;
		local function upd(r)
			r = math.clamp(r, 0, 1);
			local val = math.floor(mn + (r * (mx - mn)));
			val = math.floor(val / 10) * 10;
			State.FOVSize = val;
			vb.Text = tostring(val);
			local r2 = (val - mn) / (mx - mn);
			fill.Size = UDim2.new(r2, 0, 1, 0);
			thumb.Position = UDim2.new(r2, -7, 0.5, -7);
			updateFOVCircle();
		end
		track.InputBegan:Connect(function(inp)
			if ((inp.UserInputType == Enum.UserInputType.MouseButton1) or (inp.UserInputType == Enum.UserInputType.Touch)) then
				drag = true;
				upd((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X);
			end
		end);
		UserInputService.InputChanged:Connect(function(inp)
			if not drag then
				return;
			end
			if ((inp.UserInputType == Enum.UserInputType.MouseMovement) or (inp.UserInputType == Enum.UserInputType.Touch)) then
				upd((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X);
			end
		end);
		UserInputService.InputEnded:Connect(function(inp)
			if ((inp.UserInputType == Enum.UserInputType.MouseButton1) or (inp.UserInputType == Enum.UserInputType.Touch)) then
				drag = false;
			end
		end);
		vb.FocusLost:Connect(function()
			local n = tonumber(vb.Text);
			if n then
				n = math.clamp(math.floor(n / 10) * 10, mn, mx);
				State.FOVSize = n;
				vb.Text = tostring(n);
				local r2 = (n - mn) / (mx - mn);
				fill.Size = UDim2.new(r2, 0, 1, 0);
				thumb.Position = UDim2.new(r2, -7, 0.5, -7);
				updateFOVCircle();
			else
				vb.Text = tostring(State.FOVSize);
			end
		end);
	end
	local playerListFrame;
	local function buildPlayerList()
		if playerListFrame then
			for _, c in ipairs(playerListFrame:GetChildren()) do
				if (not c:IsA("UIListLayout") and not c:IsA("TextButton")) then
					c:Destroy();
				end
			end
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if (p == LP) then
				continue;
			end
			local row = Instance.new("Frame");
			row.Size = UDim2.new(1, 0, 0, 38);
			row.BackgroundColor3 = C.bg2;
			row.BorderSizePixel = 0;
			row.Parent = playerListFrame;
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8);
			local av = Instance.new("Frame");
			av.Size = UDim2.new(0, 26, 0, 26);
			av.Position = UDim2.new(0, 6, 0.5, -13);
			av.BackgroundColor3 = C.accent;
			av.BorderSizePixel = 0;
			av.Parent = row;
			Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0);
			local il = Instance.new("TextLabel");
			il.Size = UDim2.new(1, 0, 1, 0);
			il.BackgroundTransparency = 1;
			il.Text = string.upper(string.sub(p.Name, 1, 1));
			il.TextColor3 = C.white;
			il.Font = Enum.Font.GothamBold;
			il.TextSize = 12;
			il.Parent = av;
			local nl = Instance.new("TextLabel");
			nl.Size = UDim2.new(0.35, 0, 1, 0);
			nl.Position = UDim2.new(0, 38, 0, 0);
			nl.BackgroundTransparency = 1;
			nl.Text = p.Name;
			nl.TextColor3 = C.white;
			nl.Font = Enum.Font.Gotham;
			nl.TextSize = 12;
			nl.TextXAlignment = Enum.TextXAlignment.Left;
			nl.Parent = row;
			local function sb(txt, xOff, col)
				local b = Instance.new("TextButton");
				b.Size = UDim2.new(0, 44, 0, 24);
				b.Position = UDim2.new(1, -142 + xOff, 0.5, -12);
				b.BackgroundColor3 = col;
				b.BorderSizePixel = 0;
				b.Text = txt;
				b.TextColor3 = C.white;
				b.Font = Enum.Font.GothamBold;
				b.TextSize = 11;
				b.Parent = row;
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6);
				return b;
			end
			local tpBtn = sb("TP", 0, C.accentDark);
			local lockBtn = sb("Lock", 48, C.bg3);
			tpBtn.MouseButton1Click:Connect(function()
				pcall(teleportToPlayer, p);
			end);
			lockBtn.MouseButton1Click:Connect(function()
				if (State.LockOn and (State.LockTarget == p)) then
					State.LockOn = false;
					stopLockOn();
					lockBtn.BackgroundColor3 = C.bg3;
					lockBtn.Text = "Lock";
				else
					State.LockOn = true;
					startLockOn(p);
					lockBtn.BackgroundColor3 = C.green;
					lockBtn.Text = "ON";
					for _, r in ipairs(playerListFrame:GetChildren()) do
						if ((r ~= row) and r:IsA("Frame")) then
							for _, ch in ipairs(r:GetChildren()) do
								if (ch:IsA("TextButton") and (ch.Text == "ON")) then
									ch.BackgroundColor3 = C.bg3;
									ch.Text = "Lock";
								end
							end
						end
					end
				end
			end);
		end
	end
	section("MOVEMENT", "⚡");
	statRowWithToggle("Speed", "Speed", "SpeedEnabled", 2, 500, 5, 16, applyStats);
	statRowWithToggle("Jump", "Jump", "JumpEnabled", 10, 1000, 10, 50, applyStats);
	section("FLY", "✈");
	toggle("Fly Mode", "WASD · Space/Shift", function()
		State.Fly = true;
		enableFly();
	end, function()
		State.Fly = false;
		disableFly();
	end);
	statRow("Fly Speed", "FlySpeed", 5, 500, 10, 40, nil);
	section("UTILITY", "🛠");
	toggle("Noclip", "Punches through server-side collision restore", function()
		State.Noclip = true;
		enableNoclip();
	end, function()
		State.Noclip = false;
		disableNoclip();
	end);
	section("ESP", "👁");
	toggle("Player ESP", "Highlight · name · team · health · distance", function()
		State.ESP = true;
		enableESP();
	end, function()
		State.ESP = false;
		disableESP();
	end);
	toggle("  Health Bar", "HP bar under name", function()
		State.ESPHealth = true;
		for _, d in pairs(espData) do
			d.hpTrack.Visible = true;
		end
	end, function()
		State.ESPHealth = false;
		for _, d in pairs(espData) do
			d.hpTrack.Visible = false;
		end
	end);
	toggle("  Name Tag", "Player username", function()
		State.ESPName = true;
		for _, d in pairs(espData) do
			d.nameLbl.Visible = true;
		end
	end, function()
		State.ESPName = false;
		for _, d in pairs(espData) do
			d.nameLbl.Visible = false;
		end
	end);
	toggle("  Team Name", "Team label from scoreboard", function()
		State.ESPTeamName = true;
		for _, d in pairs(espData) do
			d.teamLbl.Visible = true;
		end
	end, function()
		State.ESPTeamName = false;
		for _, d in pairs(espData) do
			d.teamLbl.Visible = false;
		end
	end);
	colorPickerRow("ESP Color", function()
		return State.ESPColor;
	end, function(col)
		State.ESPColor = col;
		if State.ESP then
			refreshESPColors();
		end
	end);
	section("AIMBOT", "🎯");
	toggle("Aimbot", "Camera lerp to nearest head in FOV", function()
		State.Aimbot = true;
		enableAimbot();
	end, function()
		State.Aimbot = false;
		disableAimbot();
	end);
	toggle("  Wall Check", "Skip targets behind geometry", function()
		State.WallCheck = true;
	end, function()
		State.WallCheck = false;
	end, true);
	toggle("  Team Check", "Skip teammates · color them green in ESP", function()
		State.TeamCheck = true;
		if State.ESP then
			refreshESPColors();
		end
	end, function()
		State.TeamCheck = false;
		if State.ESP then
			refreshESPColors();
		end
	end, true);
	fovSliderRow();
	statRow("Smoothness", "AimbotSmooth", 1, 50, 1, 12, nil);
	colorPickerRow("FOV Circle Color", function()
		return State.FOVColor;
	end, function(col)
		State.FOVColor = col;
		updateFOVCircle();
	end);
	section("PLAYERS", "👥");
	playerListFrame = Instance.new("Frame");
	playerListFrame.Size = UDim2.new(1, 0, 0, 10);
	playerListFrame.AutomaticSize = Enum.AutomaticSize.Y;
	playerListFrame.BackgroundTransparency = 1;
	playerListFrame.BorderSizePixel = 0;
	playerListFrame.Parent = SF;
	do
		local pl = Instance.new("UIListLayout");
		pl.SortOrder = Enum.SortOrder.LayoutOrder;
		pl.Padding = UDim.new(0, 4);
		pl.Parent = playerListFrame;
	end
	local rfBtn = Instance.new("TextButton");
	rfBtn.Size = UDim2.new(1, 0, 0, 30);
	rfBtn.BackgroundColor3 = C.bg2;
	rfBtn.BorderSizePixel = 0;
	rfBtn.Text = "⟳  Refresh List";
	rfBtn.TextColor3 = C.subtext;
	rfBtn.Font = Enum.Font.GothamBold;
	rfBtn.TextSize = 12;
	rfBtn.Parent = playerListFrame;
	Instance.new("UICorner", rfBtn).CornerRadius = UDim.new(0, 7);
	rfBtn.MouseButton1Click:Connect(buildPlayerList);
	buildPlayerList();
	Players.PlayerAdded:Connect(function()
		task.wait(0.5);
		buildPlayerList();
	end);
	Players.PlayerRemoving:Connect(function()
		task.wait(0.3);
		buildPlayerList();
	end);
	local mini = false;
	MinB.MouseButton1Click:Connect(function()
		mini = not mini;
		SF.Visible = not mini;
		MF.Size = (mini and UDim2.new(0, 420, 0, 46)) or UDim2.new(0, 420, 0, 700);
		MinB.Text = (mini and "+") or "—";
	end);
	KBtn.MouseButton1Click:Connect(function()
		if (KBox.Text == VALID_KEY) then
			Unlocked = true;
			KF.Visible = false;
			MF.Visible = true;
			applyStats();
		else
			KErr.Text = "✗  Incorrect key — try again";
			task.delay(2.5, function()
				KErr.Text = "";
			end);
		end
	end);
	KBox.FocusLost:Connect(function(enter)
		if enter then
			KBtn:activate();
		end
	end);
end);
if not ok then
	local Players = game:GetService("Players");
	local LP = Players.LocalPlayer;
	local pg = LP:WaitForChild("PlayerGui");
	local sg = Instance.new("ScreenGui");
	sg.ResetOnSpawn = false;
	sg.Parent = pg;
	local f = Instance.new("Frame");
	f.Size = UDim2.new(0, 340, 0, 80);
	f.Position = UDim2.new(0.5, -170, 0.5, -40);
	f.BackgroundColor3 = Color3.fromRGB(20, 10, 5);
	f.Parent = sg;
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10);
	local l = Instance.new("TextLabel");
	l.Size = UDim2.new(1, -16, 1, 0);
	l.Position = UDim2.new(0, 8, 0, 0);
	l.BackgroundTransparency = 1;
	l.TextColor3 = Color3.fromRGB(255, 80, 80);
	l.Font = Enum.Font.GothamBold;
	l.TextScaled = true;
	l.TextWrapped = true;
	l.Text = "Hub Error: " .. tostring(err);
	l.Parent = f;
end
