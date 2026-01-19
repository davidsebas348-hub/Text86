-- AUTO COLLECT CASH / MONEY FLOTANTE CON BOTÓN, DRAG Y LOADSTRING
-- RAW / LocalScript

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- ================= TOGGLE DESTRUCCIÓN =================
if _G.AutoCollectGUI then
	_G.AutoCollectActivo = false
	
	-- Destruir GUI
	_G.AutoCollectGUI:Destroy()
	_G.AutoCollectGUI = nil

	-- Eliminar BodyVelocity si existe
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local body = hrp:FindFirstChild("FloatBody")
		if body then body:Destroy() end
	end

	print("AutoCollect destruido ❌")
	return
end

-- ================= VARIABLES =================
local cashKeywords = {"cash", "money"} -- palabras clave
local collectRange = 400 -- rango máximo para detectar objetos
local floatSpeed = 50 -- velocidad de flotación
local waitTime = 0.1 -- espera entre chequeos

local AutoCollectActivo = false -- toggle inicial
_G.AutoCollectActivo = AutoCollectActivo

-- ================= GUI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoCollectGui"
gui.ResetOnSpawn = false
_G.AutoCollectGUI = gui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 60)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0

local autoCollectButton = Instance.new("TextButton", frame)
autoCollectButton.Size = UDim2.new(0.9, 0, 0.7, 0)
autoCollectButton.Position = UDim2.new(0.05, 0, 0.15, 0)
autoCollectButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
autoCollectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoCollectButton.Font = Enum.Font.SourceSansBold
autoCollectButton.TextSize = 18
autoCollectButton.Text = "AUTO COLLECT OFF"

-- ================= FUNCIONES =================
local function isCashItem(obj)
	for _, keyword in ipairs(cashKeywords) do
		if obj.Name:lower():find(keyword:lower()) then
			return true
		end
	end
	return false
end

local function getCashObjects()
	local cashObjects = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and isCashItem(obj) then
			table.insert(cashObjects, obj)
		elseif obj:IsA("Model") then
			local part = obj:FindFirstChildWhichIsA("BasePart")
			if part and isCashItem(part) then
				table.insert(cashObjects, part)
			end
		end
	end
	return cashObjects
end

-- ================= LOOP AUTO COLLECT =================
spawn(function()
	local body
	while true do
		if AutoCollectActivo then
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				if not hrp:FindFirstChild("FloatBody") then
					body = Instance.new("BodyVelocity")
					body.Name = "FloatBody"
					body.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					body.Velocity = Vector3.new(0,0,0)
					body.Parent = hrp
				else
					body = hrp:FindFirstChild("FloatBody")
				end

				local cashList = getCashObjects()
				for _, cash in ipairs(cashList) do
					if cash.Parent then
						local distance = (hrp.Position - cash.Position).Magnitude
						if distance <= collectRange then
							local direction = (cash.Position + Vector3.new(0, -5, 0) - hrp.Position).Unit
							body.Velocity = direction * floatSpeed
							break
						end
					end
				end
			end
		else
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local body = hrp:FindFirstChild("FloatBody")
				if body then body:Destroy() end
			end
		end
		task.wait(waitTime)
	end
end)

-- ================= TOGGLE BOTÓN =================
autoCollectButton.MouseButton1Click:Connect(function()
	AutoCollectActivo = not AutoCollectActivo
	_G.AutoCollectActivo = AutoCollectActivo
	autoCollectButton.Text = AutoCollectActivo and "AUTO COLLECT ON" or "AUTO COLLECT OFF"
	
	loadstring(game:HttpGet("https://raw.githubusercontent.com/davidsebas348-hub/Text74/refs/heads/main/Text74.lua", true))()
end)

-- ================= DRAG =================
local dragging, dragInput, dragStart, startPos
autoCollectButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = autoCollectButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

autoCollectButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		autoCollectButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
