local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Camera = require(script.Parent.PolygonFramework.Camera)
local Rendering = require(script.Parent.PolygonFramework.Rendering)
local Shading = require(script.Parent.PolygonFramework.Shading)

local imageSize = 144
local Image = Instance.new("EditableImage", script.Parent.ImageLabel)
Image.Size = Vector2.new(imageSize, 144)

local lightDir = Camera.Normalize(Vector3.new(1, -1, 1))
local keys = {W = false, A = false, S = false, D = false}

local function ProjectTo2D(v, imageSize, focalLength)
	local scale = focalLength / (focalLength + v.Z)
	local x = v.X * scale + imageSize / 2
	local y = -v.Y * scale + imageSize / 2
	return Vector2.new(math.floor(x + 0.5), math.floor(y + 0.5))
end

local function DrawSphere(radius, centerX, centerY, centerZ, cameraX, cameraY, cameraZ, lightDir, cameraAngle)
	local vertices = {}
	local indices = {}
	local numSegments = 30
	local numStacks = 15
	local focalLength = 100

	for i = 0, numStacks do
		local theta = i * math.pi / numStacks
		local sinTheta = math.sin(theta)
		local cosTheta = math.cos(theta)

		for j = 0, numSegments do
			local phi = j * 2 * math.pi / numSegments
			local sinPhi = math.sin(phi)
			local cosPhi = math.cos(phi)

			local x = radius * cosPhi * sinTheta
			local y = radius * sinPhi * sinTheta
			local z = radius * cosTheta

			local worldPos = Vector3.new(centerX + x, centerY + y, centerZ + z)
			local screenPos = Camera.RotatePointAroundYAxis(worldPos - Vector3.new(Camera.cameraX, Camera.cameraY, Camera.cameraZ), cameraAngle)
			local projectedVector = ProjectTo2D(screenPos, imageSize, focalLength)
			table.insert(vertices, {projectedVector, screenPos.Z})

			if i < numStacks and j < numSegments then
				local first = i * (numSegments + 1) + j
				local second = first + numSegments + 1
				table.insert(indices, {first, second, first + 1})
				table.insert(indices, {second, second + 1, first + 1})
			end
		end
	end

	for _, face in ipairs(indices) do
		local v1, v2, v3 = vertices[face[1] + 1], vertices[face[2] + 1], vertices[face[3] + 1]

		local edge1 = Vector3.new(v2[1].X - v1[1].X, v2[1].Y - v1[1].Y, v2[2] - v1[2])
		local edge2 = Vector3.new(v3[1].X - v1[1].X, v3[1].Y - v1[1].Y, v3[2] - v1[2])
		local normal = Camera.Normalize(Rendering.CrossProduct(edge1, edge2))

		local viewDir = Camera.Normalize(Vector3.new(Camera.cameraX - (v1[1].X - imageSize / 2), Camera.cameraY - (v1[1].Y - imageSize / 2), Camera.cameraZ - v1[2]))
		if normal:Dot(viewDir) > 0 then
			local shadedColor = Shading.CalculateFlatShading(normal, lightDir, Color3.fromRGB(255, 0, 0))
			Rendering.FillPolygon(Image, {v1, v2, v3}, shadedColor)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	Camera.HandleInput(input, gameProcessed, keys)
end)

UserInputService.InputEnded:Connect(function(input)
	Camera.HandleInputRelease(input, keys)
end)

UserInputService.InputChanged:Connect(Camera.HandleMouseMove)

RunService.Heartbeat:Connect(function()
	Camera.Update(keys)
	Rendering.ClearImage(Image, imageSize)
	DrawSphere(50, 0, 0, 0, Camera.cameraX, Camera.cameraY, Camera.cameraZ, lightDir, Camera.cameraAngleX)
end)
