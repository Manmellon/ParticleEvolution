--love.graphics.clear = function() end
require "imgui"

function dist_1d(x1, x2)
	return (x2-x1)*(x2-x1)
end

function dist_2d(x1, x2, y1, y2)
	return (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)
end

ABSOLUTE_POSITIVE = 2--RED
VERY_POSITIVE = 1
NEUTRAL_ZERO = 0
VERY_NEGATIVE = -1
ABSOLUTE_NEGATIVE = -2--BLUE


COMMON = 0
NUCLEUS = 1
FACTORY = 2


Particle = {}
Particle.__index = Particle
function Particle:create(x, y, vx, vy, mass, radius, movetype, interact_type)
	local particle = {}
	setmetatable(particle, Particle)
	--particle.x = x
	--particle.y = y
	--particle.vx = vx
	--particle.vy = vy
	particle.mass = mass
	particle.radius = radius
	
	particle.color = {}
	--[[particle.color.r = math.random()
	particle.color.g = math.random()
	particle.color.b = math.random()]]--
	
	--particle.color.g = 0
	if interact_type>0 then
		particle.color.r = 0.5*math.abs(interact_type)
		particle.color.g = 0.25*(2-math.abs(interact_type))
		particle.color.b = 0.25*(2-math.abs(interact_type))
	elseif interact_type<0 then
		particle.color.r = 0.25*(2-math.abs(interact_type))
		particle.color.g = 0.25*(2-math.abs(interact_type))
		particle.color.b = 0.5*math.abs(interact_type)
	else
		particle.color.r = 0.5
		particle.color.g = 0.5
		particle.color.b = 0.5
	end
	
	particle.body = {}
    particle.body.b = love.physics.newBody(world, x, y, movetype)
    --particle.body.b:setAngle(math.rad(angle))
    particle.body.b:setMass(mass)
    --particle.body.s = love.physics.newRectangleShape(width, height)
    particle.body.shape = love.physics.newCircleShape(particle.radius)
    particle.body.fixture = love.physics.newFixture(particle.body.b, particle.body.shape)
    particle.body.fixture:setFriction(0.5)
	
	
	
	particle.connections = {}
	particle.connectCount = 0
	--particle.maxConnectCount = 6 - math.abs(interact_type)*2
	particle.maxConnectCount = 3 - math.abs(interact_type) + 1
	
	particle.energy = math.random()
	
	particle.maxEnergy = 1
	
	particle.interact_type = interact_type
	particle.type = COMMON
	
	return particle
end

function Particle:update()
end

function Particle:getX()
	return self.body.b:getX()
end

function Particle:getY()
	return self.body.b:getY()
end

function Particle:getVelocityX()
	x,y = self.body.b:getLinearVelocity()
	return x
end

function Particle:getVelocityY()
	x,y = self.body.b:getLinearVelocity()
	return y
end

function Particle:getVelocity()
	return self.body.b:getLinearVelocity()
end

function Particle:setVelocity(x, y)
	self.body.b:setLinearVelocity(x,y)
end

function Particle:checkRect(rectX, rectY, rectW, rectH)
	x = self:getX()
	y = self:getY()
	
	--[[if x<rectX then
		self.body.b:setX(rectX)
	end
	if x>rectX+rectW then
		self.body.b:setX(rectX+rectW)
	end
	if y<rectY then
		self.body.b:setY(rectY)
	end
	if y>rectY+rectH then
		self.body.b:setY(rectY+rectH)
	end]]--
	
	--[[if x<rectX then
		self.body.b:setX(x+rectW)
	end
	if x>rectX+rectW then
		self.body.b:setX(x-rectW)
	end
	if y<rectY then
		self.body.b:setY(y+rectH)
	end
	if y>rectY+rectH then
		self.body.b:setY(y-rectH)
	end]]--
end

SpacePart = {}
SpacePart.__index = SpacePart
function SpacePart:create()
	local spacepart = {}
	setmetatable(spacepart, SpacePart)
	
	spacepart.indexes = {}
	
	return spacepart
end

Connect = {}
Connect.__index = Connect
function Connect:create(a, b)
	local connect = {}
	setmetatable(connect, Connect)
	
	connect.particleIndexA = a
	connect.particleIndexB = b
	
	connect.joint = love.physics.newRopeJoint( particles[a].body.b, 
												particles[b].body.b, 
												particles[a]:getX(), 
												particles[a]:getY(), 
												particles[b]:getX(), 
												particles[b]:getY(), 
												40, 
												true)
	
	--connect.jointIndex = #joints
	
	return connect
end

function Connect:delete()
	--joints[jointIndex]:destroy()
	--table.remove(joints, jointIndex)
	self.joint:destroy()
	
	particles[self.particleIndexA].connectCount = particles[self.particleIndexA].connectCount - 1
	particles[self.particleIndexB].connectCount = particles[self.particleIndexB].connectCount - 1
end


CODE_START = 0
CODE_AP = 1
CODE_VP = 2
CODE_NZ = 3
CODE_PARAM = 4--or make it CODE_SPLIT?
CODE_VN = 5
CODE_AN = 6
CODE_STOP = 7

Nucleus = {}
Nucleus.__index = Nucleus
function Nucleus:create(x, y, vx, vy)
	local nucleus = {}
	setmetatable(nucleus, Nucleus)
	
	nucleus.particle = Particle:create(x, y, vx, vy, 23, 15, "dynamic", NEUTRAL_ZERO)
	
	--nucleus.particle.radius = 15
	
	nucleus.particle.color.r = 0
	nucleus.particle.color.g = 1
	nucleus.particle.color.b = 0
	
	nucleus.particle.maxConnectCount = 1
	
	nucleus.particle.type = NUCLEUS
	
	--[[nucleus.code = {}
	nucleus.code_size = math.random(0, 100)
	for i=1, nucleus.code_size do
		nucleus.code[i] = math.random(CODE_START, CODE_STOP)
	end]]--
	nucleus.particle.code = {}
	nucleus.particle.code_size = math.random(0, 100)
	for i=1, nucleus.particle.code_size do
		nucleus.particle.code[i] = math.random(CODE_START, CODE_STOP)
	end
	
	return nucleus
end

function Nucleus:split()
	--[[childNucleus = Nucleus:create(self.particle:getX(), self.particle:getY(), self.particle:getVelocityX(), self.particle:getVelocityY())
	nucleuses_count = nucleuses_count + 1
	nucleuses[nucleuses_count] = childNucleus
	particles_count = particles_count + 1
	particles[particles_count] = childNucleus.particle]]--
end


STATE_IDLE = 0
STATE_GET_CODE = 1--STATE_WAIT_START
STATE_FIND_PARTICLE = 2

Factory = {}
Factory.__index = Factory
function Factory:create(x, y, vx, vy)
	local factory = {}
	setmetatable(factory, Factory)
	
	factory.particle = Particle:create(x, y, vx, vy, 23, 15, "dynamic", NEUTRAL_ZERO)
	
	--factory.particle.radius = 15
	
	factory.particle.color.r = 1
	factory.particle.color.g = 1
	factory.particle.color.b = 0

	factory.particle.maxConnectCount = 1
	
	factory.particle.type = FACTORY
	
	factory.particle.state = STATE_IDLE
	
	factory.particle.nucleus_id = 0
	factory.particle.code_offset = 1
	
	return factory
end

function put_indexes_in_parts()
	for i=1, spacePartHeightCount do
		for j=1, spacePartHeightCount do
			space_parts[i][j].indexes = {}
		end
	end
	
	for i=1, particles_count do
		row = math.ceil((particles[i]:getY()-spaceY)/spacePartHeight)
		column = math.ceil((particles[i]:getX()-spaceX)/spacePartWidth)
		
		if row < 1 then row = 1 end
		if row > spacePartHeightCount then row = spacePartHeightCount end
		if column < 1 then column = 1 end
		if column > spacePartWidthCount then column = spacePartWidthCount end
		
		--print(i, particles[i]:getY(), particles[i]:getX())
		--print(row, column)
		
		table.insert(space_parts[row][column].indexes, i)
	end
end

function isConnectPossible(a, b)

end

function interactParticles(p, o)
	dist_x = particles[o]:getX()-particles[p]:getX()
	dist_y = particles[o]:getY()-particles[p]:getY()
	dist = dist_x*dist_x + dist_y*dist_y
	r = 1/(dist)--it is 1/r^2
	--print(p, o)
	if --p<o and 
	--dist < 40*40 and
	 dist < 2*(particles[o].radius+particles[p].radius) * 2*(particles[o].radius+particles[p].radius) and
	( (particles[p].interact_type>=0 and particles[o].interact_type<=0) or 
	(particles[o].interact_type>=0 and particles[p].interact_type<=0) ) and
	particles[p].connectCount < particles[p].maxConnectCount and 
	particles[o].connectCount < particles[o].maxConnectCount then
		isJoint = false
		pBodyJoints = particles[p].body.b:getJoints()
		for jo=1, table.getn(pBodyJoints) do
			bodyA, bodyB = pBodyJoints[jo]:getBodies()
			if (particles[p].body.b == bodyA and particles[o].body.b == bodyB) or 
			(particles[p].body.b == bodyB and particles[o].body.b == bodyA) then
				isJoint = true
				break
			end
		end
		if not isJoint then
			connects[#connects+1] = Connect:create(p,o)
	
			particles[p].connectCount = particles[p].connectCount + 1
			particles[o].connectCount = particles[o].connectCount + 1
			--print(particles[p].connectCount,particles[p].maxConnectCount,particles[o].connectCount,particles[o].maxConnectCount)
		end
	end
	
	dist_sum = dist_sum + r
	r1 = particles[o].mass*r
	
	
	if (particles[p].interact_type>0 and particles[o].interact_type<0) or 
		(particles[p].interact_type<0 and particles[o].interact_type>0) then
		new_vx = new_vx + dist_x*r1
		new_vy = new_vy + dist_y*r1
	elseif particles[p].interact_type~=0 and particles[o].interact_type~=0 then
		new_vx = new_vx - 2*dist_x*r1
		new_vy = new_vy - 2*dist_y*r1
	end
	--new_vx = new_vx + dist_x*r1
	--new_vy = new_vy + dist_y*r1
end

function calcAllParticlesInsideSpacePart(h, w)
	check_indexes = {}
	if h>1 then
		if w>1 then
			tableConcat(check_indexes, space_parts[h-1][w-1].indexes)
		end
		tableConcat(check_indexes, space_parts[h-1][w].indexes)
		if w<spacePartWidthCount then
			tableConcat(check_indexes, space_parts[h-1][w+1].indexes)
		end
	end
	
	if w>1 then
		tableConcat(check_indexes, space_parts[h][w-1].indexes)
	end
	tableConcat(check_indexes, space_parts[h][w].indexes)
	if w<spacePartWidthCount then
		tableConcat(check_indexes, space_parts[h][w+1].indexes)
	end 
	
	if h<spacePartHeightCount then
		if w>1 then
			tableConcat(check_indexes, space_parts[h+1][w-1].indexes)
		end
		tableConcat(check_indexes, space_parts[h+1][w].indexes)
		if w<spacePartWidthCount then
			tableConcat(check_indexes, space_parts[h+1][w+1].indexes)
		end
	end
	
	ind_size = table.getn(check_indexes)
	--ind_size = table.getn(space_parts[h][w].indexes)
	
	--avrg_dist = 0
	
	for i=1, ind_size do
		p = check_indexes[i]
		new_vx = 0
		new_vy = 0
		
		dist_sum = 0
		
		for j=1, ind_size do
			o = check_indexes[j]
			if p~=o then
				interactParticles(p, o)
			end
		end
		
		--k = 10
		
		old_vx, old_vy = particles[p]:getVelocity()
		particles[p]:setVelocity(old_vx + 1*new_vx, old_vy + 1*new_vy)
		--print(dist_sum)
		--if dist_sum < 0.02 then
		--	particles[p]:setVelocity(old_vx + new_vx, old_vy + new_vy)
		--elseif dist_sum > 0.03 then
		--	particles[p]:setVelocity(old_vx - new_vx, old_vy - new_vy)
		--end
		
		
		
		
		if particles[p].type == FACTORY then
			isNucleusNearby = false
			nucleus_id = 0
			for j=1, ind_size do
				o = check_indexes[j]
				if particles[o].type==NUCLEUS then
					isNucleusNearby = true
					nucleus_id = o
					break
				end
			end
			
			if isNucleusNearby then
				if particles[p].state == STATE_IDLE then
					if nucleus_id ~= particles[p].nucleus_id then
						particles[p].nucleus_id = nucleus_id
						particles[p].code_offset = 1
						particles[p].state = STATE_GET_CODE
					end
				end
			else
				particles[p].state = STATE_IDLE
			end
			
			if particles[p].state == STATE_GET_CODE then
				code = particles[particles[p].nucleus_id].code[particles[p].code_offset]
				if code == CODE_START then
				end
			end
			
			if particles[p].state == STATE_FIND_PARTICLE then
			end
			
		end
		
	end
end

function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]  --corrected bug. if t1[#t1+i] is used, indices will be skipped
    end
    return t1
end


function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
	
	--love.physics.setMeter(10)--??????
	world = love.physics.newWorld(0, 0, true)
	
	math.randomseed(os.time())
	
	cameraX = 0
	cameraY = 0
	cameraSpeed = 20
	
	cameraScaleX = 1
	cameraScaleY = 1
	
	cameraWidth = width
	cameraHeight = height
	
	
	spaceX = 0
	spaceY = 0
	spaceWidth = 3000
	spaceHeight = 3000
	
	
	spacePartWidth = 50
	spacePartHeight = 50
	
	spacePartWidthCount = spaceWidth/spacePartWidth
	spacePartHeightCount = spaceHeight/spacePartHeight
	
	space_parts = {}
	for i=1, spacePartHeightCount do
		space_parts[i] = {}
		for j=1, spacePartWidthCount do
			space_parts[i][j] = SpacePart:create()
		end
	end
	
	particles_count = 1000
	particles = {}
	
	connects = {}
	--joints = {}
	
	for i=1, particles_count do
		particles[i] = Particle:create(spaceX + math.random(0, spaceWidth), spaceY + math.random(0, spaceHeight), 0, 0, 10, 10, "dynamic", math.random(-2,2))
		--particles[i].body.b:setLinearVelocity(math.random(-100, 100), math.random(-100, 100))
	end
	
	
	nucleuses_count = 10
	nucleuses = {}
	
	for i=1, nucleuses_count do
		nucleuses[i] = Nucleus:create(spaceX + math.random(0, spaceWidth), spaceY + math.random(0, spaceHeight), 0, 0)
		--nucleuses[i] = Nucleus:create(spaceX + 1500, spaceY + 1500, 0, 0)
		particles[particles_count+i] = nucleuses[i].particle
	end
	
	particles_count = particles_count + nucleuses_count
	
	
	factories_count = 10
	factories = {}
	
	for i=1, factories_count do
		--factories[i] = Factory:create(spaceX + math.random(0, spaceWidth), spaceY + math.random(0, spaceHeight), 0, 0)
		--factories[i] = Factory:create(nucleuses[i].particle:getX() + math.random(-spacePartWidth, spacePartWidth), nucleuses[i].particle:getY() + math.random(-spacePartHeight, spacePartHeight), 0, 0)
		factories[i] = Factory:create(nucleuses[i].particle:getX() + math.random(-40, 40), nucleuses[i].particle:getY() + math.random(-40, 40), 0, 0)
		particles[particles_count+i] = factories[i].particle
	end
	
	particles_count = particles_count + factories_count
	
	landscape = {}
	landscape[1] = {}
	landscape[1].body = love.physics.newBody(world, 0, 0, "static")
	landscape[1].shape = love.physics.newEdgeShape(spaceX, spaceY, spaceX, spaceY+spaceHeight)
	landscape[1].fixture = love.physics.newFixture(landscape[1].body, landscape[1].shape)
	
	landscape[2] = {}
	landscape[2].body = love.physics.newBody(world, 0, 0, "static")
	landscape[2].shape = love.physics.newEdgeShape(spaceX, spaceY, spaceX+spaceWidth, spaceY)
	landscape[2].fixture = love.physics.newFixture(landscape[2].body, landscape[2].shape)
	
	landscape[3] = {}
	landscape[3].body = love.physics.newBody(world, 0, 0, "static")
	landscape[3].shape = love.physics.newEdgeShape(spaceX+spaceWidth, spaceY, spaceX+spaceWidth, spaceY+spaceHeight)
	landscape[3].fixture = love.physics.newFixture(landscape[3].body, landscape[3].shape)
	
	landscape[4] = {}
	landscape[4].body = love.physics.newBody(world, 0, 0, "static")
	landscape[4].shape = love.physics.newEdgeShape(spaceX, spaceY+spaceHeight, spaceX+spaceWidth, spaceY+spaceHeight)
	landscape[4].fixture = love.physics.newFixture(landscape[4].body, landscape[4].shape)
	
	put_indexes_in_parts()
	
end

function love.update(dt)
	--dt = dt/8
	
	imgui.NewFrame()
	
	if love.keyboard.isDown('left') then
		cameraX = cameraX + cameraSpeed
	end
	if love.keyboard.isDown('right') then
		cameraX = cameraX - cameraSpeed
	end
	if love.keyboard.isDown('up') then
		cameraY = cameraY + cameraSpeed
	end
	if love.keyboard.isDown('down') then
		cameraY = cameraY - cameraSpeed
	end
	
	if love.keyboard.isDown('=') then
		cameraScaleX = cameraScaleX*1.1
		cameraScaleY = cameraScaleY*1.1
		cameraSpeed = cameraSpeed / 1.1
		
		cameraX = cameraX - math.abs(cameraWidth/1.1 - cameraWidth)/2.
		cameraY = cameraY - math.abs(cameraHeight/1.1 - cameraHeight)/2.
		
		cameraWidth = cameraWidth / 1.1
		cameraHeight = cameraHeight / 1.1
		
		--print(cameraX, cameraY)
	end
	if love.keyboard.isDown('-') then
		cameraScaleX = cameraScaleX*0.9
		cameraScaleY = cameraScaleY*0.9
		
		cameraSpeed = cameraSpeed /0.9
		
		cameraX = cameraX + math.abs(cameraWidth/0.9 - cameraWidth)/2.
		cameraY = cameraY + math.abs(cameraHeight/0.9 - cameraHeight)/2.
		
		cameraWidth = cameraWidth / 0.9
		cameraHeight = cameraHeight / 0.9
		
		--print(cameraX, cameraY)
	end
	
	--dont even try to understand it
	for h=1, spacePartHeightCount do
		for w=1, spacePartWidthCount do
			
			calcAllParticlesInsideSpacePart(h,w)
			
			--[[check_indexes = {}
			if h>1 then
				if w>1 then
					tableConcat(check_indexes, space_parts[h-1][w-1].indexes)
				end
				tableConcat(check_indexes, space_parts[h-1][w].indexes)
				if w<spacePartWidthCount then
					tableConcat(check_indexes, space_parts[h-1][w+1].indexes)
				end
			end
			
			if w>1 then
				tableConcat(check_indexes, space_parts[h][w-1].indexes)
			end
			tableConcat(check_indexes, space_parts[h][w].indexes)
			if w<spacePartWidthCount then
				tableConcat(check_indexes, space_parts[h][w+1].indexes)
			end 
			
			if h<spacePartHeightCount then
				if w>1 then
					tableConcat(check_indexes, space_parts[h+1][w-1].indexes)
				end
				tableConcat(check_indexes, space_parts[h+1][w].indexes)
				if w<spacePartWidthCount then
					tableConcat(check_indexes, space_parts[h+1][w+1].indexes)
				end
			end
			
			ind_size = table.getn(check_indexes)
			--ind_size = table.getn(space_parts[h][w].indexes)
			
			--avrg_dist = 0
			for i=1, ind_size do
				--p = space_parts[h][w].indexes[i]
				p = check_indexes[i]
				new_vx = 0
				new_vy = 0
				
				dist_sum = 0
				
				for j=1, ind_size do
					--o = space_parts[h][w].indexes[j]
					o = check_indexes[j]
					
					if p~=o then
						dist_x = particles[o]:getX()-particles[p]:getX()
						dist_y = particles[o]:getY()-particles[p]:getY()
						dist = dist_x*dist_x + dist_y*dist_y
						r = 1/(dist)--it is 1/r^2
						--print(p, o)
						if --p<o and 
						--dist < 40*40 and
						 dist < 2*(particles[o].radius+particles[p].radius) * 2*(particles[o].radius+particles[p].radius) and
						( (particles[p].interact_type>=0 and particles[o].interact_type<=0) or 
						(particles[o].interact_type>=0 and particles[p].interact_type<=0) ) and
						particles[p].connectCount < particles[p].maxConnectCount and 
						particles[o].connectCount < particles[o].maxConnectCount then
							isJoint = false
							pBodyJoints = particles[p].body.b:getJoints()
							for jo=1, table.getn(pBodyJoints) do
								bodyA, bodyB = pBodyJoints[jo]:getBodies()
								if (particles[p].body.b == bodyA and particles[o].body.b == bodyB) or 
								(particles[p].body.b == bodyB and particles[o].body.b == bodyA) then
									isJoint = true
									break
								end
							end
							if not isJoint then
								connects[#connects+1] = Connect:create(p,o)
						
								particles[p].connectCount = particles[p].connectCount + 1
								particles[o].connectCount = particles[o].connectCount + 1
								--print(particles[p].connectCount,particles[p].maxConnectCount,particles[o].connectCount,particles[o].maxConnectCount)
							end
						end
						
						dist_sum = dist_sum + r
						r1 = particles[o].mass*r
						
						
						
						if (particles[p].interact_type>0 and particles[o].interact_type<0) or 
							(particles[p].interact_type<0 and particles[o].interact_type>0) then
							new_vx = new_vx + dist_x*r1
							new_vy = new_vy + dist_y*r1
						elseif particles[p].interact_type~=0 and particles[o].interact_type~=0 then
							new_vx = new_vx - 2*dist_x*r1
							new_vy = new_vy - 2*dist_y*r1
						end
						--new_vx = new_vx + dist_x*r1
						--new_vy = new_vy + dist_y*r1
					end
				end
				
				--k = 10
				
				old_vx, old_vy = particles[p]:getVelocity()
				particles[p]:setVelocity(old_vx + 1*new_vx, old_vy + 1*new_vy)
				--print(dist_sum)
				--if dist_sum < 0.02 then
				--	particles[p]:setVelocity(old_vx + new_vx, old_vy + new_vy)
				--elseif dist_sum > 0.03 then
				--	particles[p]:setVelocity(old_vx - new_vx, old_vy - new_vy)
				--end
			end--]]
		end
	end
	
	--[[for i=1, particles_count do
		--particles[i]:update()
		particles[i]:checkRect(spaceX, spaceY, spaceWidth, spaceHeight)
	end]]--
	
	put_indexes_in_parts()
	
    world:update(dt)

end

function love.draw()
	love.graphics.push()
	
	love.graphics.scale(cameraScaleX, cameraScaleY)
	love.graphics.translate(cameraX, cameraY)
	
	love.graphics.setColor(0.5,0.5,0.5)
	love.graphics.rectangle("line", spaceX, spaceY, spaceWidth, spaceHeight)
	
	for i=1, spacePartHeightCount do
		for j=1, spacePartWidthCount do
			love.graphics.rectangle("line", spaceX+(j-1)*spacePartWidth, spaceY+(i-1)*spacePartHeight, spacePartWidth, spacePartHeight)
		end
	end
	
	love.graphics.setColor(1,0,0)
	for i=1, 4 do
		x1, y1, x2, y2 = landscape[i].shape:getPoints()
		love.graphics.line(x1, y1, x2, y2)
	end
	
	for i=1, particles_count do
		love.graphics.setColor(particles[i].color.r, particles[i].color.g, particles[i].color.b)
		love.graphics.circle("fill", particles[i]:getX(), particles[i]:getY(), particles[i].radius)
		--love.graphics.circle("fill", particles[i]:getX()+cameraX, particles[i]:getY()+cameraY, particles[i].radius)
		
		--love.graphics.points(particles[i]:getX()+cameraX, particles[i]:getY()+cameraY)
		--print(particles[i].connectCount)
	end
	
	
	--[[for i=1, table.getn(joints) do
		love.graphics.setColor(1,1,1)
		d = joints[i]:isDestroyed()
		if not d then
			bodyA, bodyB = joints[i]:getBodies()
			if dist_2d(bodyA:getX(), bodyB:getX(), bodyA:getY(), bodyB:getY()) > 80*80 then
				joints[i]:destroy()
			end
		end
		d = joints[i]:isDestroyed()
		if not d then
			love.graphics.line(bodyA:getX(), bodyA:getY(), bodyB:getX(), bodyB:getY())
		end
	end]]--
	
	delete_connects = {}
	
	for i=1, table.getn(connects) do
		love.graphics.setColor(1,1,1)
		bodyA, bodyB = connects[i].joint:getBodies()
		if dist_2d(bodyA:getX(), bodyB:getX(), bodyA:getY(), bodyB:getY()) > 80*80 then
			delete_connects[#delete_connects+1] = i
		else
			love.graphics.line(bodyA:getX(), bodyA:getY(), bodyB:getX(), bodyB:getY())
		end
	end
	
	--table.sort(delete_connects)
	
	for i=1, table.getn(delete_connects) do
		d = delete_connects[#delete_connects-i+1]
		connects[d]:delete()
		table.remove(connects, d)
		print("Really deleted!")
	end
	
    --love.graphics.circle("line", x1, y1, r1)
    --love.graphics.circle("line", x2, y2, r2)
    
    love.graphics.pop()
    
    
    imgui.SetNextWindowPos(0, 0)
    
    for i=1, factories_count do
		imgui.Text("Factory " .. i)
		imgui.Text("State " .. factories[i].particle.state)
		
		n_id = factories[i].particle.nucleus_id
		imgui.Text("Connected to Nucleus " .. n_id)
		if n_id > 0 then
			s = ""
			for j=1, particles[n_id].code_size do
				s = s .. particles[n_id].code[j] .. ", "
			end
			imgui.TextWrapped(s)
		end
    end
    --[[
    for i=1, nucleuses_count do
		imgui.Text("Nucleus " .. i)
		s = ""
		for j=1, nucleuses[i].particle.code_size do
			s = s .. nucleuses[i].particle.code[j] .. ", "
		end
		imgui.TextWrapped(s)
    end
    ]]--
    imgui.Render()
    
end

function love.quit()
  imgui.ShutDown()
end


function love.textinput(text)
  imgui.TextInput(text)
  if not imgui.GetWantCaptureKeyboard() then
  end
end

function love.keypressed(key, scancode, isrepat)
  imgui.KeyPressed(key)
  if not imgui.GetWantCaptureKeyboard() then
  end
end

function love.keyreleased(key, scancode, isrepat)
  imgui.KeyReleased(key)
  if not imgui.GetWantCaptureKeyboard() then
  end
end

function love.mousemoved(x, y, dx, dy)
  imgui.MouseMoved(x, y)
  if not imgui.GetWantCaptureMouse() then
  end
end

function love.mousepressed(x, y, button)
  imgui.MousePressed(button)
  if not imgui.GetWantCaptureMouse() then
  end
end

function love.mousereleased(x, y, button)
  imgui.MouseReleased(button)
  if not imgui.GetWantCaptureMouse() then
  end
end

function love.wheelmoved(x, y)
  imgui.WheelMoved(y)
  if not imgui.GetWantCaptureMouse() then
  end
end
