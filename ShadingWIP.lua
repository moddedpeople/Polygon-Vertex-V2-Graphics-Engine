local Shading = {}

function Shading.CalculateFlatShading(normal, lightDir, baseColor)
	local intensity = math.max(normal:Dot(lightDir), 0)

	local r = baseColor.R
	local g = baseColor.G
	local b = baseColor.B

	local shadedR = math.clamp(r * intensity, 0, 1)
	local shadedG = math.clamp(g * intensity, 0, 1)
	local shadedB = math.clamp(b * intensity, 0, 1)

	return Color3.fromRGB(
		math.floor(shadedR * 255),
		math.floor(shadedG * 255),
		math.floor(shadedB * 255)
	)
end

return Shading
