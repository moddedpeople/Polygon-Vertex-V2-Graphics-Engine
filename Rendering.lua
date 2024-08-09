local Rendering = {}

Rendering.vertexShadingEnabled = false

function Rendering.DrawPixel(Image, vector1, color, imageSize)
	local x, y = math.floor(vector1.X + 0.5), math.floor(vector1.Y + 0.5)
	if x >= 1 and x <= 144 and y >= 1 and y <= 144 then
		Image:DrawLine(vector1, vector1, color, 0, Enum.ImageCombineType.BlendSourceOver)
	end
end

function Rendering.ClearImage(Image, imageSize)
	local whiteColor = Color3.fromRGB(255, 255, 255)
	Image:DrawRectangle(Vector2.new(0, 0), Vector2.new(imageSize, 144), whiteColor, 0, Enum.ImageCombineType.BlendSourceOver)
end

function Rendering.DrawLine(Image, startVector, endVector, color, thickness, imageSize)
	Image:DrawLine(startVector, endVector, color, 0, Enum.ImageCombineType.BlendSourceOver)
end


function Rendering.IsTriangleVisible(vertices, imageSize)
	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge

	for _, vertex in ipairs(vertices) do
		minX = math.min(minX, vertex[1].X)
		maxX = math.max(maxX, vertex[1].X)
		minY = math.min(minY, vertex[1].Y)
		maxY = math.max(maxY, vertex[1].Y)
	end

	return minX < imageSize and maxX > 0 and minY < imageSize and maxY > 0
end

function Rendering.FillPolygon(Image, vertices, color, imageSize)

	table.sort(vertices, function(a, b)
		return a[1].Y < b[1].Y
	end)

	local function interpolateZ(v1, v2, t)
		return v1[2] + t * (v2[2] - v1[2])
	end

	for y = math.floor(vertices[1][1].Y + 0.5), math.floor(vertices[#vertices][1].Y + 0.5) do
		local xIntersect = {}

		for i = 1, #vertices do
			local v1 = vertices[i]
			local v2 = vertices[(i % #vertices) + 1]
			if (v1[1].Y <= y and v2[1].Y > y) or (v1[1].Y > y and v2[1].Y <= y) then
				local x = v1[1].X + (y - v1[1].Y) * (v2[1].X - v1[1].X) / (v2[1].Y - v1[1].Y)
				table.insert(xIntersect, x)
			end
		end

		table.sort(xIntersect)

		for i = 1, #xIntersect, 2 do
			local xStart = math.floor(xIntersect[i] + 0.5)
			local xEnd = math.floor(xIntersect[i + 1] + 0.5)

			for x = xStart, xEnd - 1 do
				local colorToUse = color
				if Rendering.vertexShadingEnabled then
					local t = (x - xIntersect[i]) / (xIntersect[i + 1] - xIntersect[i])
					local z = interpolateZ(vertices[i], vertices[i + 1], t)
					colorToUse = Color3.fromRGB(
						math.min(255, math.max(0, color.R + z * 0.5)),
						math.min(255, math.max(0, color.G + z * 0.5)),
						math.min(255, math.max(0, color.B + z * 0.5))
					)
				end
				Rendering.DrawPixel(Image, Vector2.new(x, y), colorToUse, imageSize)
			end
		end
	end
end

function Rendering.CrossProduct(u, v)
	return Vector3.new(
		u.Y * v.Z - u.Z * v.Y,
		u.Z * v.X - u.X * v.Z,
		u.X * v.Y - u.Y * v.X
	)
end

function Rendering.CalculateFlatShading(normal, lightDir, baseColor)
	local intensity = math.max(0, normal:Dot(lightDir))
	local shadedColor = Color3.fromRGB(
		math.min(255, math.floor(baseColor.R * intensity)),
		math.min(255, math.floor(baseColor.G * intensity)),
		math.min(255, math.floor(baseColor.B * intensity))
	)
	return shadedColor
end

return Rendering
