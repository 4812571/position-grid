local PositionGridObject = {}
PositionGridObject.__index = PositionGridObject

function PositionGridObject.new(positionGrid, position)
	local self = setmetatable({}, PositionGridObject)
	self._positionGrid = positionGrid
	self.Position = position
	return self
end

function PositionGridObject:Free()
	self._positionGrid:Free(self)
end

local PositionGrid = {}
PositionGrid.__index = PositionGrid

function PositionGrid:_calculateWorldOffset(baseCFrame, cellPosition, incrementSize)
	local gridOffset = cellPosition * incrementSize
	return baseCFrame:PointToWorldSpace(gridOffset)
end

function PositionGrid.new(baseCFrame, gridSize, incrementSize)
	local self = setmetatable({}, PositionGrid)

	self._allocated = {}
	self._freePositions = {}
	self._cellCount = gridSize.X * gridSize.Y * gridSize.Z

	for x = 1, gridSize.X do
		for y = 1, gridSize.Y do
			for z = 1, gridSize.Z do
				local cellPosition = Vector3.new(x - 1, y - 1, z - 1)
				local worldOffset = self:_calculateWorldOffset(baseCFrame, cellPosition, incrementSize)
				table.insert(self._freePositions, worldOffset)
			end
		end
	end

    return self
end

function PositionGrid:Allocate()
    local nextPosition = table.remove(self._freePositions)
    local positionGridObject = PositionGridObject.new(self, nextPosition)
    self._allocated[positionGridObject] = nextPosition

    return positionGridObject
end

function PositionGrid:Free(positionGridObject)
	local position = self._allocated[positionGridObject]
	self._allocated[positionGridObject] = nil
	table.insert(self._freePositions, position)
end

function PositionGrid:GetCellCount()
	return self._cellCount
end

function PositionGrid:GetFreeCellCount()
	return #self._freePositions
end

return PositionGrid