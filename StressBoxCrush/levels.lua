local levels = {}
local tLevels = {}

function levels:getDescription(vID) return tLevels[vID] end

function levels:initCurrent(iID)
	tLevels["cur"] = {}
	tLevels["cur"].ID         = tonumber(iID) -- Current levels
	tLevels["cur"].created    = 0
	tLevels["cur"].collide_nn = 0
	tLevels["cur"].collide_wn = 0
	tLevels["cur"].collide_wb = 0
	tLevels["cur"].collide_bn = 0
	tLevels["cur"].collide_bb = 0
	return tLevels["cur"]
end

function levels:playLose()
	
end

function levels:playCongrats()
	
end

tLevels[1] = {
	message        = "Do not make more than 3 boxes man !",
	max_created    = 2,
	max_collide_nn = 0,
	max_collide_wn = 0,
	max_collide_wb = 0,
	max_collide_bn = 0,
	max_collide_bb = 0,
	item_list      = {
		[1] = {100, 100},
		[2] = {100, 180},
		[3] = {100, 260},
		[4] = {100, 340}
	}
}

tLevels[2] = {
	max_created    = 0,
	max_collide_nn = 0,
	max_collide_wn = 1,
	max_collide_wb = 0,
	max_collide_bn = 0,
	max_collide_bb = 0,
	item_list      = {
		[1] = {100, 100},
		[2] = {100, 180},
		[3] = {100, 260},
		[4] = {100, 340},
		[5] = {200, 100},
		[6] = {200, 180},
		[7] = {200, 260},
		[8] = {200, 340}
	}
}

tLevels[3] = {
	max_created    = 0,
	max_collide_nn = 0,
	max_collide_wn = 0,
	max_collide_wb = 0,
	max_collide_bn = 0,
	max_collide_bb = 0,
	item_list      = {
		[1] = {70, 100},
		[2] = {80, 180},
		[3] = {90, 260},
		[4] = {100, 340},
		[5] = {210, 100},
		[6] = {220, 180},
		[7] = {230, 260},
		[8] = {240, 340}
	}
}

return levels