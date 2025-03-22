local button = script.Parent
local isLocked = false
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- Cho phép di chuyển UI
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

runService.RenderStepped:Connect(function()
	if dragging and dragInput then
		update(dragInput)
	end
end)

-- Tìm NPC gần nhất
local function findNearestNPC()
	local nearestNPC = nil
	local shortestDistance = math.huge
	local playerChar = player.Character
	if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return nil end
	
	local playerPos = playerChar.HumanoidRootPart.Position
	for _, npc in pairs(workspace:GetChildren()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			local distance = (npc.HumanoidRootPart.Position - playerPos).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestNPC = npc
			end
		end
	end
	
	return nearestNPC
end

-- Khi nhấn nút, bật/tắt chế độ NPC Lock
button.MouseButton1Click:Connect(function()
	isLocked = not isLocked
	local npc = findNearestNPC()
	if isLocked and npc then
		local npcHead = npc:FindFirstChild("Head")
		if npcHead then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.lookAt(camera.CFrame.Position, npcHead.Position + Vector3.new(0, 2, 0))
		end
		button.Text = "NPC Lock: ON"
	else
		camera.CameraType = Enum.CameraType.Custom
		button.Text = "NPC Lock: OFF"
	end
end)