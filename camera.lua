local Camera = {}

Camera.cameraX = 0
Camera.cameraY = 0
Camera.cameraZ = 0
Camera.cameraAngleX = 0
Camera.cameraAngleY = 0
Camera.movementSpeed = 0.5
Camera.lookSensitivity = 0.005
Camera.fov = math.rad(70)
Camera.aspectRatio = 16 / 9
Camera.nearClip = 0.1
Camera.farClip = 1000

function Camera.Normalize(v)
	local magnitude = math.sqrt(v.X^2 + v.Y^2 + v.Z^2)
	if magnitude > 0 then
		return v / magnitude
	else
		return Vector3.new(0, 0, 0)
	end
end

function Camera.UpdateCameraPosition(radius, angle)
	local x = radius * math.cos(angle)
	local z = radius * math.sin(angle)
	return x, Camera.cameraY, z
end

function Camera.RotatePointAroundYAxis(point, angle)
	local x = point.X * math.cos(angle) - point.Z * math.sin(angle)
	local z = point.X * math.sin(angle) + point.Z * math.cos(angle)
	return Vector3.new(x, point.Y, z)
end

function Camera.HandleInput(input, gameProcessed, keys)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.W then
		keys.W = true
	elseif input.KeyCode == Enum.KeyCode.A then
		keys.A = true
	elseif input.KeyCode == Enum.KeyCode.S then
		keys.S = true
	elseif input.KeyCode == Enum.KeyCode.D then
		keys.D = true
	end
end

function Camera.HandleInputRelease(input, keys)
	if input.KeyCode == Enum.KeyCode.W then
		keys.W = false
	elseif input.KeyCode == Enum.KeyCode.A then
		keys.A = false
	elseif input.KeyCode == Enum.KeyCode.S then
		keys.S = false
	elseif input.KeyCode == Enum.KeyCode.D then
		keys.D = false
	end
end

function Camera.HandleMouseMove(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local deltaX = input.Delta.X
		local deltaY = input.Delta.Y

		Camera.cameraAngleX = Camera.cameraAngleX + deltaX * Camera.lookSensitivity
		Camera.cameraAngleY = Camera.cameraAngleY - deltaY * Camera.lookSensitivity
		Camera.cameraAngleY = math.clamp(Camera.cameraAngleY, -math.pi / 2, math.pi / 2)
	end
end

function Camera.Update(keys)
	local forward = Vector3.new(math.sin(Camera.cameraAngleX), 0, math.cos(Camera.cameraAngleX)).unit
	local right = Vector3.new(-math.cos(Camera.cameraAngleX), 0, math.sin(Camera.cameraAngleX)).unit

	if keys.W then
		Camera.cameraX = Camera.cameraX + forward.X * Camera.movementSpeed
		Camera.cameraZ = Camera.cameraZ + forward.Z * Camera.movementSpeed
	end
	if keys.S then
		Camera.cameraX = Camera.cameraX - forward.X * Camera.movementSpeed
		Camera.cameraZ = Camera.cameraZ - forward.Z * Camera.movementSpeed
	end
	if keys.A then
		Camera.cameraX = Camera.cameraX - right.X * Camera.movementSpeed
		Camera.cameraZ = Camera.cameraZ - right.Z * Camera.movementSpeed
	end
	if keys.D then
		Camera.cameraX = Camera.cameraX + right.X * Camera.movementSpeed
		Camera.cameraZ = Camera.cameraZ + right.Z * Camera.movementSpeed
	end
end

function Camera.GetViewMatrix()
	local cameraPos = Vector3.new(Camera.cameraX, Camera.cameraY, Camera.cameraZ)
	local cameraForward = Camera.Normalize(Vector3.new(math.sin(Camera.cameraAngleX), 0, math.cos(Camera.cameraAngleX)))
	local cameraRight = Camera.Normalize(Vector3.new(-math.cos(Camera.cameraAngleX), 0, math.sin(Camera.cameraAngleX)))
	local cameraUp = Camera.Normalize(Vector3.new(0, 1, 0))

	local viewMatrix = {
		{cameraRight.X, cameraRight.Y, cameraRight.Z, -Vector3.new(cameraRight.X, cameraRight.Y, cameraRight.Z):Dot(cameraPos)},
		{cameraUp.X, cameraUp.Y, cameraUp.Z, -Vector3.new(cameraUp.X, cameraUp.Y, cameraUp.Z):Dot(cameraPos)},
		{-cameraForward.X, -cameraForward.Y, -cameraForward.Z, Vector3.new(-cameraForward.X, -cameraForward.Y, -cameraForward.Z):Dot(cameraPos)},
		{0, 0, 0, 1}
	}
	return viewMatrix
end

function Camera.GetProjectionMatrix()
	local f = 1 / math.tan(Camera.fov / 2)
	local rangeInv = 1 / (Camera.nearClip - Camera.farClip)

	local projectionMatrix = {
		{f / Camera.aspectRatio, 0, 0, 0},
		{0, f, 0, 0},
		{0, 0, (Camera.nearClip + Camera.farClip) * rangeInv, -1},
		{0, 0, Camera.nearClip * (Camera.farClip * rangeInv), 0}
	}

	return projectionMatrix
end

return Camera
