--------------------------------------------------
-- TOGGLE
--------------------------------------------------
if getgenv().AUTO_SHERIFF then
	getgenv().AUTO_SHERIFF = false
	return
end

getgenv().AUTO_SHERIFF = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- determinar equipo contrario
--------------------------------------------------
local function getEnemyTeam()
	local team = LocalPlayer.Team
	if not team then return nil end

	if team.Name == "Sheriffs" then
		return "Criminals"
	elseif team.Name == "Criminals" then
		return "Sheriffs"
	end

	return nil
end

--------------------------------------------------
-- buscar target enemigo
--------------------------------------------------
local function getTarget()
	local enemyTeamName = getEnemyTeam()
	if not enemyTeamName then return nil end

	for _, player in pairs(Players:GetPlayers()) do
		if player.Team and player.Team.Name == enemyTeamName then
			local model = workspace:FindFirstChild(player.Name)
			if model and model:IsA("Model") then
				local head = model:FindFirstChild("Head")
				local humanoid = model:FindFirstChildOfClass("Humanoid")
				local audio = model:FindFirstChildWhichIsA("AudioEmitter", true)

				if head and humanoid and humanoid.Health > 0 and audio then
					return model, head
				end
			end
		end
	end
end

--------------------------------------------------
-- disparo
--------------------------------------------------
local function shoot()
	if not getgenv().AUTO_SHERIFF then return end
	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local target, head = getTarget()
	if not target then return end

	local startPos = hrp.Position
	local direction = (head.Position - startPos).Unit
	local hitPart = target:FindFirstChildWhichIsA("BasePart")

	-- si eres Sheriff, dispara solo si tienes GunSource
	if LocalPlayer.Team.Name == "Sheriffs" then
		local gunSource = character:FindFirstChild("GunSource")
		if gunSource and gunSource:FindFirstChild("Events") and gunSource.Events:FindFirstChild("Fire") then
			gunSource.Events.Fire:FireServer(startPos, direction, hitPart, head.Position)
		end
	end

	-- si eres Criminal, dispara siempre (aunque no tengas GunSource)
	if LocalPlayer.Team.Name == "Criminals" then
		-- usa GunSource si existe
		local gunSource = character:FindFirstChild("GunSource")
		if gunSource and gunSource:FindFirstChild("Events") and gunSource.Events:FindFirstChild("Fire") then
			gunSource.Events.Fire:FireServer(startPos, direction, hitPart, head.Position)
		else
			-- si no hay GunSource, dispara con un RemoteEvent genérico
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("RemoteEvent") and v.Name:lower():find("fire") then
					v:FireServer(startPos, direction, hitPart, head.Position)
					break
				end
			end
		end
	end
end

--------------------------------------------------
-- loop
--------------------------------------------------
task.spawn(function()
	while getgenv().AUTO_SHERIFF do
		task.wait(0.2)
		shoot()
	end
end)
