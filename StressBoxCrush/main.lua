--[[

This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
(C) 2010 - 2011 Gideros Mobile

]]
require "box2d"
local levels = require("levels")

local szScreen = {application:getDeviceWidth() , application:getDeviceHeight()}

local szSky   = {320, 480}
local szGrass = {320,  80}

local scSky = {
	 (szScreen[1] / szSky[1]),
	 (szScreen[2] / szSky[2])
}

local scGrass = {
	 (szScreen[1] / szGrass[1]),
	 (szScreen[2] / szGrass[2])
}

local yGrass = szSky[2]*scSky[2] - szGrass[2]

print("szSky  :",scSky[1]  ,scSky[2])
print("scGrass:",scGrass[1],scGrass[2])

b2.setScale(20)

local sky = Bitmap.new(Texture.new("sky.png"))
      sky:setScaleX(scSky[1])
      sky:setScaleY(scSky[2])
stage:addChild(sky)

local grass = Bitmap.new(Texture.new("grass.png"))
      grass:setScaleX(scGrass[1])
      grass:setY(yGrass)
stage:addChild(grass)

-- this table holds the dynamic bodies and their sprites
local actors = {}

local lvcStat = levels:initCurrent(0)
local lvcData = levels:getDescription(lvcStat.ID)

-- create world
local world = b2.World.new(0, 9.8)

local tTouch = {
	isTouched = false,
	strPos    = {0,0},
	endPos    = {0,0},
	hitData   = {}
}

local function onForceBegin(event)
	if(not tTouch.isTouched) then
		tTouch.hitData.isHit = false
		for k, v in pairs(actors) do
			if(v:hitTestPoint(event.touch.x, event.touch.y) and k.name:sub(1,3) == "new") then
				v:setColorTransform(0.5, 1, 0.5, 1)
				tTouch.hitData[1] = k
				tTouch.hitData[2] = v
				tTouch.strPos[1]  = event.touch.x
				tTouch.strPos[2]  = event.touch.y
				tTouch.hitData.isHit = true
			end
		end
		-- print("STR",tTouch.strPos[1],tTouch.strPos[2])
		tTouch.isTouched = true
	end
end

local function onForceEnd(event)
	if(tTouch.isTouched) then
		if(tTouch.hitData.isHit) then
			local body   = tTouch.hitData[1]
			local sprite = tTouch.hitData[2]
			tTouch.endPos[1] = event.touch.x
			tTouch.endPos[2] = event.touch.y
			local mul = body:getMass() * 3
			-- print("END",tTouch.endPos[1],tTouch.endPos[2], mul)
			local fx = (tTouch.endPos[1] - tTouch.strPos[1]) * mul
			local fy = (tTouch.endPos[2] - tTouch.strPos[2]) * mul
			body:applyForce(fx, fy, tTouch.strPos[1], tTouch.strPos[2])
			sprite:setColorTransform(1, 1, 1, 1)
			-- print("Force ["..fx..","..fy.."]")
		end
	end; tTouch.isTouched = false
end

-- this function creates a 80x80 physical box and adds it to the stage
local function createBox(x, y, name)
	local body = world:createBody{type = b2.DYNAMIC_BODY, position = {x = x, y = y}}

	body.name = name

	local shape = b2.PolygonShape.new()
	shape:setAsBox(40, 40)
	body:createFixture{shape = shape, density = 1, restitution = 0.2, friction = 0.3}

	local sprite = Bitmap.new(Texture.new("box.png"))
	sprite:setAnchorPoint(0.5, 0.5)
	stage:addChild(sprite)
 
	sprite:addEventListener(Event.TOUCHES_BEGIN, onForceBegin)
	sprite:addEventListener(Event.TOUCHES_END  , onForceEnd)
	
	actors[body] = sprite
end

-- create ground body
local ground = world:createBody({})

ground.name = "ground"

local shape = b2.EdgeShape.new(-500, yGrass, szScreen[1] + 500, yGrass)
ground:createFixture({shape = shape, density = 0})

function onCreateBox(event)
	if(event.y < yGrass) then
		isSky = sky:hitTestPoint(event.x, event.y)
		if(isSky) then local isBox = false
			for k, v in pairs(actors) do
				isBox = v:hitTestPoint(event.x, event.y)
				if(isBox) then break end
			end
			if(not isBox) then
				createBox(event.x, event.y, "new"..lvcStat.created)
				print("createBox: Done")
				lvcStat.created = lvcStat.created + 1
				if(lvcData.max_created and
				   lvcData.max_created > 0 and
					lvcData.max_created < lvcStat.created) then
					print("Game Over (SPAWN)")
				end
			end
		end
	end
end

local function onCollide(event)
	-- you can get the fixtures and bodies in this contact like:
	local fixtureA = event.fixtureA
	local fixtureB = event.fixtureB
	local bodyA = fixtureA:getBody()
	local bodyB = fixtureB:getBody()
	--print("onCollide: "..bodyA.name.."<->"..bodyB.name)
	if(lvcData and lvcStat) then
		if(bodyA.name:sub(1,3) == "new" and bodyB.name:sub(1,3) == "new") then
			if(lvcData.max_collide_nn and (lvcData.max_collide_nn > 0) and lvcStat.collide_nn and
			   lvcData.max_collide_nn < lvcStat.collide_nn             and
			   bodyA.name:sub(1,3) == "new" and bodyB.name:sub(1,3) == "new") then
				print("Game Over (COLLIDE_NN)", lvcStat.collide_nn)
			else lvcStat.collide_nn = lvcStat.collide_nn + 1 end
		end
		if(lvcData and bodyA.name:sub(1,4) == "base" and bodyB.name:sub(1,4) == "base") then
			if(lvcData.max_collide_bb and (lvcData.max_collide_bb > 0) and lvcStat.collide_bb and
			   lvcData.max_collide_bb < lvcStat.collide_bb             and
			   bodyA.name:sub(1,3) == "new" and bodyB.name:sub(1,3) == "new") then
				print("Game Over (COLLIDE_NN)", lvcStat.collide_bb)
			else lvcStat.collide_bb = lvcStat.collide_bb + 1 end
		end
		if((bodyA.name:sub(1,3) == "new" and bodyB.name:sub(1,6) == "ground") or 
			(bodyA.name:sub(1,6) == "ground" and bodyB.name:sub(1,3) == "new")) then
			if(lvcData.max_collide_wn and (lvcData.max_collide_wn > 0) and lvcStat.collide_wn and
			   lvcData.max_collide_wn < lvcStat.collide_wn) then
				print("Game Over (COLLIDE_NG)", lvcStat.collide_wn)
			else lvcStat.collide_wn = lvcStat.collide_wn + 1 end
		end
		if((bodyA.name:sub(1,6) == "ground" and bodyB.name:sub(1,4) == "base") or 
			(bodyA.name:sub(1,4) == "base" and bodyB.name:sub(1,6) == "ground")) then
			if(lvcData.max_collide_wb and (lvcData.max_collide_wb > 0) and lvcStat.collide_wb and
			   lvcData.max_collide_wb < lvcStat.collide_wb) then
				print("Game Over (COLLIDE_BN)", lvcStat.collide_wb)
			else lvcStat.collide_wb = lvcStat.collide_wb + 1 end
		end
		if((bodyA.name:sub(1,3) == "new" and bodyB.name:sub(1,4) == "base") or 
			(bodyA.name:sub(1,4) == "base" and bodyB.name:sub(1,3) == "new")) then
			if(lvcData.max_collide_bn and (lvcData.max_collide_bn > 0) and lvcStat.collide_bn and
			   lvcData.max_collide_bn < lvcStat.collide_bn) then
				print("Game Over (COLLIDE_BN)", lvcStat.collide_bn)
			else lvcStat.collide_bn = lvcStat.collide_bn + 1 end
		end
	end
end

-- register 4 physics events with the world object
world:addEventListener(Event.BEGIN_CONTACT, onCollide)
world:addEventListener(Event.END_CONTACT  , onCollide)
world:addEventListener(Event.PRE_SOLVE    , onCollide)
world:addEventListener(Event.POST_SOLVE   , onCollide)

sky:addEventListener(Event.MOUSE_DOWN, onCreateBox)

-- step the world and then update the position and rotation of sprites
local function onEnterFrame()
	local actCount = 0
	world:step(1/60, 15, 8)
	for k, v in pairs(actors) do
		v:setPosition(k:getPosition())
		v:setRotation(k:getAngle() * 180 / math.pi)
		actCount = actCount + 1
		local x, y, z = v:getPosition()
		if(not sky:hitTestPoint(x,y)) then
			actors[k] = nil; 
			print("Remove box ["..k.name.."]")
		end
	end
	if(actCount == 0) then
		collectgarbage()
		local lvl = lvcStat.ID + 1
		lvcStat = levels:initCurrent(lvl)
		lvcData = levels:getDescription(lvl)
		if(not lvcData) then
			print("Victory !")
			application:exit()
		else
			print("Level: "..lvcStat.ID)
			for i = 1, #lvcData.item_list do
				local v = lvcData.item_list[i]
				createBox(v[1], v[2], "base"..i)
			end
		end
	end
end

stage:addEventListener(Event.ENTER_FRAME, onEnterFrame)
