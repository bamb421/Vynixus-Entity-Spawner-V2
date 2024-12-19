--[[
    __      __          _            _       ______       _   _ _            _____                                       __      _____  
    \ \    / /         (_)          ( )     |  ____|     | | (_) |          / ____|                                      \ \    / /__ \ 
     \ \  / /   _ _ __  ___  ___   _|/ ___  | |__   _ __ | |_ _| |_ _   _  | (___  _ __   __ ___      ___ __   ___ _ __   \ \  / /   ) |
      \ \/ / | | | '_ \| \ \/ / | | | / __| |  __| | '_ \| __| | __| | | |  \___ \| '_ \ / _` \ \ /\ / / '_ \ / _ \ '__|   \ \/ /   / / 
       \  /| |_| | | | | |>  <| |_| | \__ \ | |____| | | | |_| | |_| |_| |  ____) | |_) | (_| |\ V  V /| | | |  __/ |       \  /   / /_ 
        \/  \__, |_| |_|_/_/\_\\__,_| |___/ |______|_| |_|\__|_|\__|\__, | |_____/| .__/ \__,_| \_/\_/ |_| |_|\___|_|        \/   |____|
             __/ |                                                   __/ |        | |                                                   
            |___/                                                   |___/         |_|
]]--

if VynixuEntitySpawnerV2 then return VynixuEntitySpawnerV2 end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local l_TweenService_0 = game:GetService("TweenService"); -- too lazy to replace mentions of tweenservice in the decompiled code
local l_CollectionService_0 = game:GetService("CollectionService");

-- Variables
local v0 = {};
local l_Children_0 = game:GetService("ReplicatedStorage").Misc.Shards:GetChildren();
local v6 = nil;
local localPlayer = Players.LocalPlayer
local localChar = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localHum = localChar:WaitForChild("Humanoid")
local localCollision = localChar:WaitForChild("Collision")
local localCamera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")
local gameStats = ReplicatedStorage:WaitForChild("GameStats")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local floorReplicated = ReplicatedStorage:WaitForChild("FloorReplicated")
local remotesFolder = ReplicatedStorage:WaitForChild("RemotesFolder")

local lastRespawn;
local BaseEntitySpeed = 65
local colourGuiding = Color3.fromRGB(137, 207, 255)
local colourCurious = Color3.fromRGB(253, 255, 133)

local vynixuModules = {
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
}
local assets = {
	Repentance = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Entity%20Spawner/Assets/Repentance.rbxm?raw=true")
}

local defaultEntityAttributes = {
	Running = false,
	CustomEntity = true,
	Paused = false,
	BeingBanished = false,
	Despawning = false,
	Damage = true,
	LastEnteredRoom = -1
}
local defaultPlayerAttributes = {
	SpawnProtection = 5
}
local defaultDebug = {
	OnSpawned = function() end,
	OnStartMoving = function() end,
	OnReachedNode = function() end,
	OnEnterRoom = function() end,
	OnLookAt = function() end,
	OnRebounding = function() end,
	OnDespawning = function() end,
	OnDespawned = function() end,
	OnDamagePlayer = function() end,
	CrucifixionOverwrite = ""
}
local defaultConfig = {
	Entity = {
		Name = "Template Entity",
		Asset = "https://github.com/RegularVynixu/Utilities/blob/main/Doors%20Entity%20Spawner/Models/Rush.rbxm?raw=true",
		HeightOffset = 0
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Damage = {
		Enabled = true,
		Range = 40,
		Amount = 125
	},
	Rebounding = {
		Enabled = true,
		Type = "Ambush", -- "Blitz"
		Min = 2,
		Max = 4,
		Delay = 2
	},
	Lights = {
		Flicker = {
			Enabled = true,
			Duration = 1
		},
		Shatter = true,
		Repair = false
	},
	Crucifixion = {
		Type = "Curious", -- "Guiding"
		Enabled = true,
		Range = 40,
		Resist = false,
		Break = true
	},
	Death = {
		Cause = ""
	}
}
local ambientStorage = {}

local spawner = {}

-- Functions

local v0 = {};
local l_TweenService_0 = game:GetService("TweenService");
local l_CollectionService_0 = game:GetService("CollectionService");

v0.flicker = function(v71, v72, v73, v74) -- flicker lights
	pcall(function()
		task.spawn(function()
			if not (typeof(v71) == "Instance") then
				if typeof(v71) == "number" then
					v71 = workspace.CurrentRooms:FindFirstChild(v71);
				else
					v71 = nil;
				end;
			end;
			if v71 == nil or v71:GetAttribute("CannotFlicker") or v71:GetAttribute("IsDark") then
				return;
			else
				local v75 = {};
				for _, v77 in pairs(v71:GetDescendants()) do
					if v77:IsA("Model") and l_CollectionService_0:HasTag(v77, "LightSource") and v77:GetAttribute("Shattered") ~= true then
						for _, v79 in pairs(v77:GetDescendants()) do
							if v79:IsA("Light") and v79:GetAttribute("OGBrightness") == nil then
								v79:SetAttribute("OGBrightness", v79.Brightness);
							end;
						end;
						table.insert(v75, v77);
					end;
				end;
				v73 = math.min(v73 or 100, #v75);
				v72 = v72 or 0.5;
				v74 = v74 or Random.new(tick());
				if v73 < 100 then
					local v80 = {};
					for _ = 1, 100 do
						local v82 = v75[v74:NextInteger(1, #v75)];
						local v83 = true;
						for _, v85 in pairs(v80) do
							if v85 == v82 then
								v83 = false;
							end;
						end;
						if v83 then
							table.insert(v80, v82);
						end;
						if not (#v80 < v73) then
							break;
						end;
					end;
					v75 = v80;
				end;
				if v73 > 5 then
					l_TweenService_0:Create(game.Lighting, TweenInfo.new(v72 / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true), {
						Ambient = Color3.new(0, 0, 0)
					}):Play();
				end;
				local v86 = tick();
				for _, v88 in v75 do
					task.spawn(function()
						pcall(function()
							task.wait(v74:NextNumber(1, 30) / 100);
							local v89 = v72 + v74:NextNumber(-100, 100) / 250;
							for _ = 1, 1000 do
								local v91 = v74:NextNumber(3, 12) / 100;
								local v92 = v91 + v74:NextNumber(-20, 20) / 100;
								if not v88:GetAttribute("Shattered") and not v71:GetAttribute("IsDark") then
									if tick() >= v86 + v89 then
										for _, v94 in pairs(v88:GetDescendants()) do
											if v94:IsA("Light") then
												v94.Brightness = 0;
												l_TweenService_0:Create(v94, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
													Brightness = v94:GetAttribute("OGBrightness")
												}):Play();
											elseif v94:HasTag("LightBeam") then
												local _ = l_TweenService_0:Create(v94, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
													Brightness = 1
												});
											end;
											if v94.Name == "Neon" then
												v94.Transparency = 0.8;
												l_TweenService_0:Create(v94, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
													Transparency = 0.1
												}):Play();
											end;
										end;
										return;
									else
										local l_FirstChild_0 = v88.PrimaryPart:FindFirstChild("BulbZap", true);
										if not l_FirstChild_0 then
											l_FirstChild_0 = game:GetService("ReplicatedStorage").Sounds.BulbZap:Clone();
											l_FirstChild_0.Parent = v88.PrimaryPart;
										end;
										if l_FirstChild_0 then
											l_FirstChild_0.TimePosition = math.random(0, 13) / 20;
											l_FirstChild_0.Pitch = l_FirstChild_0.Pitch + math.random(-100, 100) / 5000;
											l_FirstChild_0:Play();
										end;
										for _, v98 in pairs(v88:GetDescendants()) do
											if v98:IsA("Light") then
												v98.Brightness = v98:GetAttribute("OGBrightness");
												l_TweenService_0:Create(v98, TweenInfo.new(v91, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
													Brightness = 0
												}):Play();
											elseif v98:HasTag("LightBeam") then
												local _ = l_TweenService_0:Create(v98, TweenInfo.new(v91, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0), {
													Brightness = 0
												});
											end;
										end;
										local l_v88_FirstChild_0 = v88:FindFirstChild("Neon", true);
										if l_v88_FirstChild_0 and l_v88_FirstChild_0.Name == "Neon" then
											l_v88_FirstChild_0.Transparency = 0;
											l_TweenService_0:Create(l_v88_FirstChild_0, TweenInfo.new(v91, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
												Transparency = 0.7
											}):Play();
										end;
										task.wait(v92);
									end;
								else
									break;
								end;
							end;
						end);
					end);
				end;
				return;
			end;
		end);
	end);
end;

v0.shatter = function(v20, v21, v22, v23) --shatter lights
	pcall(function()
		task.spawn(function()
			if not (typeof(v20) == "Instance") then
				if typeof(v20) == "number" then
					v20 = workspace.CurrentRooms:FindFirstChild(v20);
				else
					v20 = nil;
				end;
			end;
			if v20 == nil or v20:GetAttribute("CannotFlicker") then
				return;
			else
				local v24 = {};
				for _, v26 in pairs(v20:GetDescendants()) do
					if v26:IsA("Model") and l_CollectionService_0:HasTag(v26, "LightSource") and v26:GetAttribute("Shattered") ~= true then
						for _, v28 in pairs(v26:GetDescendants()) do
							if v28:IsA("Light") and v28:GetAttribute("OGBrightness") == nil then
								v28:SetAttribute("OGBrightness", v28.Brightness);
							end;
						end;
						table.insert(v24, v26);
					end;
				end;
				v21 = math.min(v21 or 100, #v24);
				v22 = v22 or 60;
				v23 = v23 or Random.new(tick());
				local v29 = false;
				if v22 < 0 then
					v22 = math.abs(v22);
					v29 = true;
				end;
				local v30 = 120 / v22;
				if v21 < 50 then
					local v31 = {};
					for _ = 1, 100 do
						local v33 = v24[v23:NextInteger(1, #v24)];
						local v34 = true;
						for _, v36 in pairs(v31) do
							if v36 == v33 then
								v34 = false;
							end;
						end;
						if v34 then
							table.insert(v31, v33);
						end;
						if not (#v31 < v21) then
							break;
						end;
					end;
					v24 = v31;
				end;
				if v21 > 5 then
					v20:SetAttribute("Ambient", Color3.new(0, 0, 0));
				end;
				local _ = tick();
				for _, v39 in pairs(v24) do
					local v40 = (v20.RoomEntrance.Position - v39.PrimaryPart.Position).Magnitude / v22 + v23:NextInteger(-10, 10) / 50;
					if v29 then
						v40 = (v20.RoomExit.Position - v39.PrimaryPart.Position).Magnitude / v22;
					end;
					local v41 = v23:NextInteger(5, 20) / 100;
					if v21 <= 5 and v21 < #v24 then
						v40 = v23:NextInteger(5, 300) / 10;
						v41 = v23:NextInteger(5, 70) / 100;
					end;
					do
						local l_v41_0 = v41;
						task.delay(v40, function()
							local l_v39_FirstChild_0 = v39:FindFirstChild("Neon", true);
							if v39:GetAttribute("Shattered") or l_v39_FirstChild_0 and l_v39_FirstChild_0.Material ~= Enum.Material.Neon then
								return;
							else
								v39:SetAttribute("Shattered", true);
								for _, v45 in v39:GetDescendants() do
									if v45:HasTag("LightBeam") or v45.Name == "LightCenterParticle" then
										v45:Destroy();
									end;
								end;
								local v46 = game:GetService("ReplicatedStorage").Sounds.BulbCharge:Clone();
								v46.Parent = v39.PrimaryPart;
								v46.Pitch = v46.Pitch + math.random(-140, 140) / 800;
								v46:Play();
								game.Debris:AddItem(v46, 2);
								if l_v39_FirstChild_0 then
									l_TweenService_0:Create(l_v39_FirstChild_0, TweenInfo.new(l_v41_0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
										Transparency = 0, 
										Color = Color3.new(1, 1, 1)
									});
								end;
								for _, v48 in pairs(v39:GetDescendants()) do
									if v48:IsA("Light") then
										l_TweenService_0:Create(v48, TweenInfo.new(l_v41_0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
											Brightness = v48:GetAttribute("OGBrightness") * 2
										}):Play();
									end;
								end;
								wait(l_v41_0 + 0.01);
								if l_v39_FirstChild_0 then
									l_v39_FirstChild_0.Transparency = 1;
								end;
								for _, v50 in pairs(v39:GetDescendants()) do
									if v50:IsA("Light") then
										l_TweenService_0:Create(v50, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
											Brightness = 0
										}):Play();
									end;
								end;
								v46:Stop();
								local v51 = game:GetService("ReplicatedStorage").Sounds.BulbBreak:Clone();
								v51.Parent = v39.PrimaryPart;
								v51.Pitch = v51.Pitch + math.random(-140, 140) / 1000;
								v51.TimePosition = math.random(0, 7) * 3;
								v51:Play();
								game.Debris:AddItem(v51, 2);
								pcall(function()
									v6.shakerel(v39.PrimaryPart.Position, 2, 12, 0, 0.4, (Vector3.new(0, 0, 0, 0)));
									for _ = 1, 5 do
										local v53 = l_Children_0[math.random(1, #l_Children_0)]:Clone();
										local v54 = l_v39_FirstChild_0 or v39.PrimaryPart;
										local v55 = v54.Size / 2;
										v53.CFrame = v54.CFrame * CFrame.new(v23:NextNumber(-v55.X, v55.X), v23:NextNumber(-v55.Y, v55.Y), v23:NextNumber(-v55.Z, v55.Z));
										v53.Velocity = Vector3.new(math.random(-6, 6), math.random(-6, 6), math.random(-6, 6));
										v53.RotVelocity = Vector3.new(math.random(-3, 3) / 5, math.random(-3, 3) / 5, math.random(-3, 3) / 5);
										v53.Parent = workspace.CurrentCamera;
										game.Debris:AddItem(v53, math.random(20, 35));
									end;
								end);
								return;
							end;
						end);
					end;
				end;
				if v20:GetAttribute("IsDark") then
					local function _(v56)
						local v57 = 2;
						local l_v56_FirstAncestorWhichIsA_0 = v56:FindFirstAncestorWhichIsA("BasePart");
						if l_v56_FirstAncestorWhichIsA_0 then
							v57 = (v20.RoomEntrance.Position - l_v56_FirstAncestorWhichIsA_0.Position).Magnitude / v22;
						end;
						return v57;
					end;
					for _, v61 in pairs(v20:GetDescendants()) do
						if v61:IsA("Light") and v61:GetAttribute("ForceOn") ~= true then
							if not (v61.Parent.Name == "LightBase") then
								local l_delay_0 = task.delay;
								local v63 = 2;
								local l_v61_FirstAncestorWhichIsA_0 = v61:FindFirstAncestorWhichIsA("BasePart");
								if l_v61_FirstAncestorWhichIsA_0 then
									v63 = (v20.RoomEntrance.Position - l_v61_FirstAncestorWhichIsA_0.Position).Magnitude / v22;
								end;
								l_delay_0(v63, function()
									l_TweenService_0:Create(v61, TweenInfo.new(v30 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
										Brightness = 0
									}):Play();
								end);
							end;
						elseif v61:IsA("ParticleEmitter") and v61:GetAttribute("Light") == true then
							local l_delay_1 = task.delay;
							local v66 = 2;
							local l_v61_FirstAncestorWhichIsA_1 = v61:FindFirstAncestorWhichIsA("BasePart");
							if l_v61_FirstAncestorWhichIsA_1 then
								v66 = (v20.RoomEntrance.Position - l_v61_FirstAncestorWhichIsA_1.Position).Magnitude / v22;
							end;
							l_delay_1(v66, function()
								v61.Enabled = false;
							end);
						elseif v61:IsA("Sound") and v61:GetAttribute("Light") == true then
							local l_delay_2 = task.delay;
							local v69 = 2;
							local l_v61_FirstAncestorWhichIsA_2 = v61:FindFirstAncestorWhichIsA("BasePart");
							if l_v61_FirstAncestorWhichIsA_2 then
								v69 = (v20.RoomEntrance.Position - l_v61_FirstAncestorWhichIsA_2.Position).Magnitude / v22;
							end;
							l_delay_2(v69, function()
								v61:Stop();
							end);
						end;
					end;
				end;
				wait(v30 / 2);
				if v21 >= 5 then
					l_TweenService_0:Create(game.Lighting, TweenInfo.new(v30 / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						Ambient = Color3.new(0, 0, 0)
					}):Play();
					v20:SetAttribute("Ambient", Color3.new(0, 0, 0));
				end;
				return;
			end;
		end);
	end);
end;

function CloneTable(tbl)
	local cloned = {}
	for key, value in pairs(tbl) do
		if typeof(value) == "table" then
			cloned[key] = CloneTable(value)
		else
			cloned[key] = value
		end
	end
	return cloned
end

function OnCharacterAdded(char)
	lastRespawn = tick()
	localChar = char
	localHum = char:WaitForChild("Humanoid")
	localCollision = char:WaitForChild("Collision")
end

function GetCurrentRoom(latest)
	if latest then
		return workspace.CurrentRooms:GetChildren()[#workspace.CurrentRooms:GetChildren()]
	end
	return workspace.CurrentRooms:FindFirstChild(localPlayer:GetAttribute("CurrentRoom"))
end

function GetNodesFromRoom(room, reversed)
	local nodes = {}
	local roomEntrance = room:FindFirstChild("RoomEntrance")
	if roomEntrance then
		local n = roomEntrance:Clone()
		n.Name = "0"
		n.CFrame -= Vector3.new(0, 3, 0)
		nodes[1] = n
	end

	local nodesFolder = room:FindFirstChild("PathfindNodes")
	if nodesFolder then
		for _, n in nodesFolder:GetChildren() do
			nodes[#nodes + 1] = n
		end
	end

	local roomExit = room:FindFirstChild("RoomExit")
	if roomExit then
		local index = #nodes + 1
		local n = roomExit:Clone()
		n.Name = index
		n.CFrame -= Vector3.new(0, 3, 0)
		nodes[index] = n
	end

	table.sort(nodes, function(a, b)
		if reversed then
			return tonumber(a.Name) > tonumber(b.Name)
		else
			return tonumber(a.Name) < tonumber(b.Name)
		end
	end)

	return nodes
end

function GetPathfindNodesAmbush(config)
	local pathfindNodes = {}
	local rooms = workspace.CurrentRooms:GetChildren()
	if config.Movement.Reversed == false then
		for i = 1, #rooms, 1 do
			local room = rooms[i]
			local roomNodes = GetNodesFromRoom(room, false)
			for _, node in roomNodes do
				pathfindNodes[#pathfindNodes + 1] = node
			end
		end
	else
		for i = #rooms, 1, -1 do
			local room = rooms[i]
			local roomNodes = GetNodesFromRoom(room, true)
			for _, node in roomNodes do
				pathfindNodes[#pathfindNodes + 1] = node
			end
		end
	end
	return pathfindNodes
end

function GetPathfindNodesBlitz(config)
	local nodesToCurrent, nodesToEnd = {}, {}
	local currentRoomIndex = localPlayer:GetAttribute("CurrentRoom")
	local rooms = workspace.CurrentRooms:GetChildren()

	if config.Movement.Reversed == false then
		for _, room in rooms do
			local roomNodes = GetNodesFromRoom(room, false)
			local roomIndex = tonumber(room.Name)

			for _, node in roomNodes do
				if roomIndex <= currentRoomIndex then
					nodesToCurrent[#nodesToCurrent + 1] = node
				else
					nodesToEnd[#nodesToEnd + 1] = node
				end
			end
		end
	else
		for i = #rooms, 1, -1 do
			local room = rooms[i]
			local roomNodes = GetNodesFromRoom(room, true)
			local roomIndex = tonumber(room.Name)

			for _, node in roomNodes do
				if roomIndex >= currentRoomIndex then
					nodesToCurrent[#nodesToCurrent + 1] = node
				else
					nodesToEnd[#nodesToEnd + 1] = node
				end
			end
		end 
	end

	return nodesToCurrent, nodesToEnd
end

function PlayerInLineOfSight(model, config)
	local origin = model:GetPivot().Position
	local charOrigin = localCollision.Position

	if (charOrigin - origin).Magnitude <= config.Damage.Range then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {localChar, model}

		local result = workspace:Raycast(origin, charOrigin - origin, params)
		return (result == nil), result
	end
	return false
end

function PlayerHasItemEquipped(name)
	local tool = localChar:FindFirstChildOfClass("Tool")
	if tool and tool.Name == name then
		return true, tool
	end
	return false
end

function CrucifixEntity(entityTable, tool)
	local model = entityTable.Model
	local config = entityTable.Config

	local resist = config.Crucifixion.Resist

	local toolPivot = tool:GetPivot()
	local entityPivot = model:GetPivot()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {localChar, model}
	local result = workspace:Raycast(entityPivot.Position, Vector3.new(0, -1000, 0), params)
	if not result then return end

	-- Setup
	model:SetAttribute("BeingBanished", true)

	local repentance = assets.Repentance:Clone()
	local crucifix = repentance.Crucifix
	local pentagram = repentance.Pentagram
	local entityPart = repentance.Entity
	local sound = (config.Crucifixion.Resist and crucifix.SoundFail or crucifix.Sound)

	local function waitUntil(t)
		repeat RunService.RenderStepped:Wait() until sound.TimePosition >= t
	end
	local function fadeOut()
		for _, c in pentagram:GetChildren() do
			if c.Name == "BeamFlat" then
				task.delay(c:GetAttribute("Delay"), function()
					TweenService:Create(c, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Brightness = 0
					}):Play()
				end)
			end
		end
	end

	repentance:PivotTo(CFrame.new(result.Position))
	crucifix.CFrame = toolPivot
	repentance.Entity.CFrame = entityPivot
	crucifix.BodyPosition.Position = (localCollision.CFrame * CFrame.new(0.5, 3, -6)).Position
	repentance.Parent = workspace
	sound:Play()

	task.spawn(function()
		while model.Parent and repentance.Parent do
			model:PivotTo(entityPart.CFrame)
			task.wait()
		end
		model:Destroy()
	end)

	-- Animation
	TweenService:Create(pentagram.Circle, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { CFrame = pentagram.Circle.CFrame - Vector3.new(0, 25, 0) }):Play()
	TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { AngularVelocity = Vector3.new(0, 40, 0) }):Play()
	task.delay(2, pentagram.Circle.Destroy, pentagram.Circle)

	task.spawn(function()
		waitUntil(2.625)
		TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 5,
			Range = 40
		}):Play()
		TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 11.25,
			Range = 30
		}):Play()
		task.wait(1.5)
		TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()
		TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()

		if resist == false then
			TweenService:Create(crucifix.Light, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 15, Range = 40 }):Play()
			--shaker:StartFadeOut(3)
			fadeOut()
			TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { AngularVelocity = Vector3.new() }):Play()
		end
	end)

	-- Actions
	if resist == false then
		waitUntil(2)
		TweenService:Create(entityPart, TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { CFrame = repentance.Entity.CFrame - Vector3.new(0, 25, 0) }):Play()
		waitUntil(6.75)
	else
		waitUntil(4)
		TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { AngularVelocity = Vector3.new() }):Play()
		TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }):Play()
		TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }):Play()
		--shaker:StartFadeOut(3)
		task.spawn(function()
			local color = Instance.new("Color3Value")
			color.Value = Color3.fromRGB(137, 207, 255)

			local tween = TweenService:Create(color, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { Value = Color3.fromRGB(255, 116, 130) })
			tween:Play()

			while tween.PlaybackState == Enum.PlaybackState.Playing do
				for _, d in repentance:GetDescendants() do
					if d.ClassName == "Beam" then
						d.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color.Value), ColorSequenceKeypoint.new(1, color.Value)}

					elseif d.Name == "Crucifix" then
						d.Color = color.Value
					end
				end
				task.wait()
			end
		end)
		waitUntil(9.625)
	end

	-- Crucifix explode
	TweenService:Create(repentance.Crucifix, TweenInfo.new(1), { Size = repentance.Crucifix.Size * 3, Transparency = 1 }):Play()
	TweenService:Create(repentance.Pentagram.Base.LightAttach.LightBright, TweenInfo.new(1), { Brightness = 0, Range = 0 }):Play()
	TweenService:Create(repentance.Crucifix.Light, TweenInfo.new(1), { Brightness = 0, Range = 0 }):Play()

	if not resist then
		repentance.Crucifix.ExplodeParticle:Emit(math.random(20, 30))
		--moduleScripts.Main_Game.camShaker:ShakeOnce(7.5, 7.5, 0.25, 1.5)
	else
		model:SetAttribute("BeingBanished", false)
		model:SetAttribute("Paused", false)
		fadeOut()
	end
	task.delay(5, repentance.Destroy, repentance)
end

function PlayerIsProtected()
	return (tick() - lastRespawn) <= localPlayer:GetAttribute("SpawnProtection")
end

function DamagePlayer(entityTable)
	if localHum.Health > 0 and not PlayerIsProtected() then
		local config = entityTable.Config
		local newHealth = math.clamp(localHum.Health - config.Damage.Amount, 0, localHum.MaxHealth)

		if newHealth == 0 then
			-- Set death cause
			local deathCause = config.Entity.Name
			if config.Death.Cause ~= "" then
				deathCause = config.Death.Cause
			end
			gameStats["Player_".. localPlayer.Name].Total.DeathCause.Value = deathCause
		end

		-- Update health
		localHum.Health = newHealth
		task.spawn(entityTable.RunCallback, entityTable, "OnDamagePlayer", newHealth) -- OnDamagePlayer
	end
end

function GetRoomAtPoint(vector3)
	local whitelist = {}
	for _, room in workspace.CurrentRooms:GetChildren() do
		local p = room:FindFirstChild(room.Name)
		if p then
			whitelist[#whitelist + 1] = p
		end
	end

	if #whitelist > 0 then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = whitelist
		params.CollisionGroup = "BaseCheck"

		local result = workspace:Raycast(vector3, Vector3.new(0, -100, 0), params)
		if result then
			for _, room in workspace.CurrentRooms:GetChildren() do
				if result.Instance.Parent == room then
					return room
				end
			end
		end
	end
end

function FixRoomLights(room)
	if not room:FindFirstChild("RoomEntrance") then
		return
	end

	-- Clear shards
	for _, c in localCamera:GetChildren() do
		if c.Name == "Piece" then
			c:Destroy()
		end
	end

	-- Set room ambient
	require(ReplicatedStorage.ClientModules.Module_Events).toggle(room, true, ambientStorage[room])

	-- Fix lights
	local stuff = {}
	for _, d in room:GetDescendants() do
		if d:IsA("Model") and (d.Name == "LightStand" or d.Name == "Chandelier") then
			table.insert(stuff, d)
		end
	end

	local random = Random.new(tick())
	for _, v in stuff do
		if v:GetAttribute("Shattered") then
			local r1 = random:NextInteger(-10, 10) / 50
			local r2 = random:NextInteger(5, 20) / 100

			task.delay((room.RoomEntrance.Position - v.PrimaryPart.Position).Magnitude / 150 + r1, function()
				local neon = v:FindFirstChild("Neon", true)
				for _, d in pairs(v:GetDescendants()) do
					if d:IsA("Light") then
						TweenService:Create(d, TweenInfo.new(r2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Brightness = d:GetAttribute("OGBrightness")
						}):Play()
					elseif d:IsA("Sound") then
						TweenService:Create(d, TweenInfo.new(r2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Volume = d:GetAttribute("OGVolume")
						}):Play()
					end
				end
				if neon then
					neon.Transparency = 0.9
					neon.Material = Enum.Material.Neon
					TweenService:Create(neon, TweenInfo.new(r2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						Transparency = 0.2
					}):Play()
					task.wait(r2)
				end
				v:SetAttribute("Shattered", nil)
			end)
		end
	end
end

function EntityMoveTo(model, cframe, speed)
	local reached = false
	local connection; connection = RunService.Stepped:Connect(function(_, step)
		if not model:GetAttribute("Paused") then
			local pivot = model:GetPivot()
			local difference = (cframe.Position - pivot.Position)
			local unit = difference.Unit
			local magnitude = difference.Magnitude

			if magnitude > 0.1 then
				model:PivotTo(pivot + unit * math.min(step * speed, magnitude))
			else
				connection:Disconnect()
				reached = true
			end
		end
	end)
	repeat RunService.Stepped:Wait() until reached
end

function ApplyConfigDefaults(tbl, defaults)
	for key, value in defaults do
		if tbl[key] == nil then
			tbl[key] = value

		elseif typeof(value) == "table" then
			if not tbl[key] or typeof(tbl[key]) ~= "table" then
				tbl[key] = {}
			end
			ApplyConfigDefaults(tbl[key], value)
		end
	end
end

function GetAllDatatypes(config, datatype, ignoreList) -- thanks ChatGPT lmao
	ignoreList = ignoreList or {}

	local function traverseConfig(tbl, path, results)
		for key, value in tbl do
			local newPath = path ~= "" and (path .. "." .. key) or key
			if type(value) == datatype then
				table.insert(results, {path = newPath, value = value})
			elseif type(value) == "table" then
				traverseConfig(value, newPath, results)
			end
		end
	end

	local results = {}
	traverseConfig(config, "", results)

	-- Exclude paths from ignoreList
	local filteredResults = {}
	for _, item in results do
		local shouldIgnore = false
		for _, ignorePath in ignoreList do
			if item.path:find(ignorePath, 1, true) then
				shouldIgnore = true
				break
			end
		end
		if not shouldIgnore then
			table.insert(filteredResults, item)
		end
	end

	return filteredResults
end

--[[
function PrerunCheck(entityTable)
	local config = entityTable.Config
	local rebounding = config.Rebounding

	if entityTable:WaitForChild("Model"):GetAttribute("Running") then
		warn("Entity awweady wunnying :3 sowwy")
		return false

	elseif rebounding.Enabled and (rebounding.Min <= 0 or rebounding.Max <= 0 or rebounding.Min > rebounding.Max) then
		warn("Invalid rebounding values, returning.")
		return false
	end

	-- Check for invalid number values
	for _, v in GetAllDatatypes(config, "number", {"Entity.HeightOffset", "CameraShake.Values", "Delay"}) do
		if v.value <= 0 then
			warn(("Invalid number value: '%s', returning."):format(v.path))
			return false
		end
	end

	return true
end
--]]

spawner.Create = function(config)
	ApplyConfigDefaults(config, defaultConfig)
	config.Movement.Speed = BaseEntitySpeed / 100 * config.Movement.Speed

	-- Load and set up entity model
	local asset = config.Entity.Asset
	local success, entityModel;

	if typeof(asset) == "Instance" and asset:IsA("Model") then
		success, entityModel = true, asset

	elseif typeof(asset) == "string" then
		success, entityModel = pcall(function()
			local m = LoadCustomInstance(asset)
			if m then
				if m.ClassName ~= "Model" then
					warn("Entity asset is not a model, returning.")
					return
				end
			else
				warn("Failed to load entity asset, returning.")
				return
			end
			return m
		end)
	else
		warn("Invalid entity asset type, returning.")
		return
	end

	-- Construct and return entityTable
	if success and entityModel then
		local root = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")
		if root then
			root.Anchored = true
			entityModel.PrimaryPart = root

			-- Entity custom name
			local c = config.Entity
			if c.Name and c.Name ~= "" then
				entityModel.Name = c.Name
			end

			-- Entity default attributes
			for name, value in defaultEntityAttributes do
				entityModel:SetAttribute(name, value)
			end
		end

		-- RoomsEntered folder
		local f = Instance.new("Configuration")
		f.Name = "RoomsEntered"
		f.Parent = entityModel

		-- EntityTable
		local entityTable = {
			Model = entityModel,
			Config = config,
			Debug = CloneTable(defaultDebug),
			SetCallback = function(self, key, callback)
				if self.Debug[key] then
					if typeof(callback) == "function" then
						self.Debug[key] = callback
					else
						warn("Failed to set callback, invalid callback datatype.")
					end
				else
					warn("Failed to set callback, invalid callback key.")
				end
			end,
			RunCallback = function(self, key, ...)
				local callback = self.Debug[key]
				if callback then
					local success, result = pcall(callback, ...)
					if not success then
						warn(("Error in callback: '%s' for entity: '%s':\n%s"):format(key, self.Config.Entity.Name, result))
					end
				end
			end,
			Pause = function(self, bool)
				if self.Model then
					self.Model:SetAttribute("Paused", bool)
				end
			end,
			Despawn = function(self)
				if self.Model then
					self.Model:Destroy()
					self.Model = nil
					task.spawn(self.RunCallback, self, "OnDespawned") -- OnDespawned
				end
			end
		}

		entityTable.Run = function(self)
			spawner.Run(self)
		end

		return entityTable
	end
end

spawner.Run = function(entityTable)
	task.spawn(function()
		--[[
		if PrerunCheck(entityTable) == false then
			return
		end
--]]
		local model = entityTable.Model
		local config = entityTable.Config
		local debug = entityTable.Debug

		model:SetAttribute("Running", true)

		-- Spawning
		local spawnPoint;
		do
			local rooms = workspace.CurrentRooms:GetChildren()
			if config.Movement.Reversed then
				spawnPoint = rooms[#rooms]:FindFirstChild("RoomExit")
			else
				spawnPoint = rooms[1]:FindFirstChild("RoomEntrance")
			end
		end

		if spawnPoint then
			-- Spawning
			model:PivotTo(spawnPoint.CFrame + Vector3.new(0, config.Entity.HeightOffset, 0))
			model.Parent = workspace
			task.spawn(entityTable.RunCallback, entityTable, "OnSpawned") -- OnSpawned

			-- Flickering lights
			if config.Lights.Flicker.Enabled then
				local currentRoom = GetCurrentRoom(false)
				if currentRoom then
					v0.flicker(currentRoom, config.Lights.Flicker.Duration)
				end
			end

			-- Movement detection handling
			task.wait(config.Movement.Delay)
			task.spawn(entityTable.RunCallback, entityTable, "OnStartMoving") -- OnStartMoving
			task.spawn(function()
				while model.Parent do
					if not model:GetAttribute("Paused") then
						local pivot = model:GetPivot()
						local charPivot = localCollision.CFrame
						local inSight = PlayerInLineOfSight(model, config)

						-- Player look detection
						if localHum.Health > 0 then
							local _, isVisible = localCamera:WorldToViewportPoint(pivot.Position)
							if isVisible then
								task.spawn(entityTable.RunCallback, entityTable, "OnLookAt", inSight) -- OnLookAt
							end
						end

						-- Room detection
						do
							local room = GetRoomAtPoint(pivot.Position)
							if room then
								local index = tonumber(room.Name)
								if index ~= model:GetAttribute("LastEnteredRoom") then
									model:SetAttribute("LastEnteredRoom", index)

									local roomsEntered = model:FindFirstChild("RoomsEntered")
									if roomsEntered then
										local firstTime = (roomsEntered:GetAttribute(room.Name) == nil)
										task.spawn(entityTable.RunCallback, entityTable, "OnEnterRoom", room, firstTime) -- OnEnterRoom

										if firstTime then
											roomsEntered:SetAttribute(room.Name, true)
										end

										local latestRoom = GetCurrentRoom(true)
										if room ~= latestRoom then
											if config.Lights.Shatter then -- Shatter lights
												v0.shatter(room)
													--[[
											elseif config.Lights.Repair then -- Repair lights
												FixRoomLights(room)
											--]]
											end
										end
									end
								end
							end
						end

						-- Crucifixion detection
						local usedCrucifix = false
						do
							local c = config.Crucifixion
							if c.Enabled and c.Range > 0 and (charPivot.Position - pivot.Position).Magnitude <= c.Range and inSight then
								local hasTool, tool = PlayerHasItemEquipped("Crucifix")
								if hasTool and tool and not model:GetAttribute("BeingBanished") then
									-- Crucifixion
									if typeof(debug.CrucifixionOverwrite) == "function" then
										entityTable:RunCallback("CrucifixionOverwrite") -- CrucifixionOverwrite
									else
										model:SetAttribute("Paused", true)
										CrucifixEntity(entityTable, tool)
									end
									usedCrucifix = true
								end
							end
						end

						-- Damage detection
						if not model:GetAttribute("Paused") and not usedCrucifix then
							local c = config.Damage
							if c.Enabled and c.Range > 0 and localHum.Health > 0 and not localChar:GetAttribute("Hiding") and model:GetAttribute("Damage") and not model:GetAttribute("BeingBanished") and (charPivot.Position - pivot.Position).Magnitude <= c.Range and inSight then
								model:SetAttribute("Damage", false)
								DamagePlayer(entityTable)
							end
						end

					end
					task.wait()
				end
			end)

			-- Pathfinding
			task.spawn(function()
				local reboundType = config.Rebounding.Type:lower()
				if reboundType == "blitz" then
					-- Blitz rebounding
					local nodesToCurrent, nodesToEnd = GetPathfindNodesBlitz(config)

					for _, n in nodesToCurrent do
						local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
					end

					-- Rebounding handling
					if config.Rebounding.Enabled then
						local currentRoom = GetCurrentRoom(false)
						if not currentRoom then
							warn("Failed to obtain current room, returning.")
							return
						end
						local roomNodes = GetNodesFromRoom(currentRoom, config.Movement.Reversed)
						if #roomNodes == 1 then
							warn("Failed to obtain current room nodes, returning.")
							return
						end
						local randomNode;
						if config.Movement.Reversed == false then
							randomNode = roomNodes[math.random(1, #roomNodes - 1)]
						else
							randomNode = roomNodes[math.random(2, #roomNodes)]
						end
						if not randomNode then
							warn("Failed to obtain current room Blitz node, returning.")
							return
						end

						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding

							local nodeIndex = tonumber(randomNode.Name)
							for i = #roomNodes, nodeIndex, -1 do
								local cframe = roomNodes[math.clamp(i, 1, #roomNodes)].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end

							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding

							for i = nodeIndex, #roomNodes, 1 do
								local cframe = roomNodes[math.clamp(i, 1, #roomNodes)].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end
						end
					end

					local _, updatedToEnd = GetPathfindNodesBlitz(config)
					for _, n in updatedToEnd do
						local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
					end
				else
					-- Ambush rebounding
					local pathfindNodes = GetPathfindNodesAmbush(config)
					for _, n in pathfindNodes do
						local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
					end

					-- Rebounding handling
					if config.Rebounding.Enabled then
						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding

							-- Run backwards through nodes
							for i = #pathfindNodes, 1, -1 do
								local cframe = pathfindNodes[i].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							pathfindNodes = GetPathfindNodesAmbush(config)

							-- Run forwards through nodes
							for _, n in pathfindNodes do
								local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding

							-- Delay unless last rebound
							if i < reboundsCount then
								task.wait(config.Rebounding.Delay)
							end
						end
					end
				end

				-- Despawning
				if not model:GetAttribute("Despawning") then
					model:SetAttribute("Despawning", true)
					task.spawn(entityTable.RunCallback, entityTable, "OnDespawning") -- OnDespawning
					EntityMoveTo(model, model:GetPivot() - Vector3.new(0, 300, 0), config.Movement.Speed)
					entityTable:Despawn()
				end
			end)
		end
	end)
end

-- Main
localPlayer.CharacterAdded:Connect(OnCharacterAdded)

for name, value in defaultPlayerAttributes do
	localPlayer:SetAttribute(name, value)
end
lastRespawn = tick() - localPlayer:GetAttribute("SpawnProtection")

if not vynixu_SpawnerLoaded then
	getgenv().vynixu_SpawnerLoaded = true

	local function getAmbient(room)
		return room:GetAttribute("AmbientOriginal") or room:GetAttribute("Ambient") or Color3.fromRGB(67, 51, 56)
	end
	for _, c in workspace.CurrentRooms:GetChildren() do
		ambientStorage[c] = getAmbient(c)
	end
	workspace.CurrentRooms.ChildAdded:Connect(function(c)
		ambientStorage[c] = getAmbient(c)
	end)

	workspace.DescendantRemoving:Connect(function(d)
		if d.Name == "PathfindNodes" then
			d:Clone().Parent = d.Parent
		end
	end)
end

-- Return spawner
getgenv().VynixuEntitySpawnerV2 = spawner
return spawner
