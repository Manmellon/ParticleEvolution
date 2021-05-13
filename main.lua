--love.graphics.clear = function() end

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


Particle = {}
Particle.__index = Particle
function Particle:create(x, y, vx, vy, mass, movetype, interact_type)
	local particle = {}
	setmetatable(particle, Particle)
	--particle.x = x
	--particle.y = y
	--particle.vx = vx
	--particle.vy = vy
	particle.mass = mass
	particle.radius = 10
	
	particle.interact_type = interact_type
	
	particle.color = {}
	--[[particle.color.r = math.random()
	particle.color.g = math.random()
	particle.color.b = math.random()]]--
	particle.color.g = 0
	if interact_type>0 then
		particle.color.r = 0.5*interact_type
		particle.color.b = 0
	elseif interact_type<0 then
		particle.color.b = 0.5*math.abs(interact_type)
		particle.color.r = 0
	else
		particle.color.r = 0.5
		particle.color.g = 0.5
		particle.color.b = 0.5
	end
	
	particle.connections = {}
	particle.connectCount = 0
	--particle.maxConnectCount = 6 - math.abs(interact_type)*2
	particle.maxConnectCount = 3 - math.abs(interact_type)
	
	
	
	particle.body = {}
    particle.body.b = love.physics.newBody(world, x, y, movetype)
    --particle.body.b:setAngle(math.rad(angle))
    particle.body.b:setMass(mass)
    --particle.body.s = love.physics.newRectangleShape(width, height)
    particle.body.shape = love.physics.newCircleShape(particle.radius)
    particle.body.fixture = love.physics.newFixture(particle.body.b, particle.body.shape)
    particle.body.fixture:setFriction(0.5)
	
	
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
	
	if x<rectX then
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
	end
end

SpacePart = {}
SpacePart.__index = SpacePart
function SpacePart:create()
	local spacepart = {}
	setmetatable(spacepart, SpacePart)
	
	spacepart.indexes = {}
	
	return spacepart
end

function put_indexes_in_parts()
	for i=1, spacePartHeightCount do
		for j=1, spacePartHeightCount do
			space_parts[i][j].indexes = {}
		end
	end
	
	for i=1, particles_count do
		row = math.floor((particles[i]:getY()-spaceY)/spacePartHeight)
		column = math.floor((particles[i]:getX()-spaceX)/spacePartWidth)
		--print(row+1, column+1, space_parts[row+1][column+1].indexes)
		table.insert(space_parts[row+1][column+1].indexes, i)
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
	spaceWidth = 1000
	spaceHeight = 1000
	
	
	spacePartWidth = 100
	spacePartHeight = 100
	
	spacePartWidthCount = spaceWidth/spacePartWidth
	spacePartHeightCount = spaceHeight/spacePartHeight
	
	space_parts = {}
	for i=1, spacePartHeightCount do
		space_parts[i] = {}
		for j=1, spacePartWidthCount do
			space_parts[i][j] = SpacePart:create()
		end
	end
	
	particles_count = 300
	particles = {}
	joints = {}
	for i=1, particles_count do
		particles[i] = Particle:create(spaceX + math.random(0, spaceWidth), spaceY + math.random(0, spaceHeight), 0, 0, 10, "dynamic", math.random(-2,2))
		--if i>1 then
		--	joints[i] = love.physics.newRopeJoint( particles[1].body.b, particles[i].body.b, particles[1]:getX(), particles[1]:getY(), particles[i]:getX(), particles[i]:getY(), 100, true)
		--end
		--particles[i].body.b:setLinearVelocity(math.random(-100, 100), math.random(-100, 100))
	end
	--particles[1].body.b:setLinearVelocity(1000, 0)
	
	--particles[1].mass = 10
	
	--particles[1].color.r = 1
	--particles[2].color.g = 1
	--particles[3].color.b = 1
	put_indexes_in_parts()
	
end

function love.update(dt)
	--dt = dt/8
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
	
	--[[avrg_dist = 0
	for i=1, particles_count do
		new_i_vx = 0
		new_i_vy = 0
		
		dist_sum = 0
		
		for j=1, particles_count do
			if not (i==j) then
				--new_j_vx = 0
				--new_j_vy = 0
				dist_x = particles[j]:getX()-particles[i]:getX()
				dist_y = particles[j]:getY()-particles[i]:getY()
				r = 1/(dist_x*dist_x + dist_y*dist_y)--it is 1/r^2
				
				dist_sum = dist_sum + r
				
				r1 = particles[j].mass*r
				--r2 = particles[i].mass*r
				new_i_vx = new_i_vx + dist_x*r1
				--new_j_vx = new_j_vx - dist_x*r2
				
				new_i_vy = new_i_vy + dist_y*r1
				--new_j_vy = new_j_vy - dist_y*r2
			end
		end
		old_i_vx, old_i_vy = particles[i]:getVelocity()
		particles[i]:setVelocity(old_i_vx + new_i_vx, old_i_vy + new_i_vy)
		--print(dist_sum)
		--avrg_dist = avrg_dist+dist_sum
		
		if dist_sum < 0.02 then
			particles[i]:setVelocity(old_i_vx + new_i_vx, old_i_vy + new_i_vy)
		elseif dist_sum > 0.03 then
			particles[i]:setVelocity(old_i_vx - new_i_vx, old_i_vy - new_i_vy)
		end
	end
	]]--
	
	--dont even try to understand it
	for h=1, spacePartHeightCount do
		for w=1, spacePartWidthCount do
		
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
						if p<o and 
						dist<40*40 and 
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
								joints[#joints+1] = love.physics.newRopeJoint( particles[p].body.b, 
																				particles[o].body.b, 
																				particles[p]:getX(), 
																				particles[p]:getY(), 
																				particles[o]:getX(), 
																				particles[o]:getY(), 
																				40, 
																				true)
								--[[joints[#joints+1] = love.physics.newWeldJoint( particles[p].body.b, 
																				particles[o].body.b, 
																				particles[p]:getX(), 
																				particles[p]:getY(), 
																				particles[o]:getX(), 
																				particles[o]:getY(), 
																				true)		]]--								
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
							new_vx = new_vx - dist_x*r1
							new_vy = new_vy - dist_y*r1
						end
						--new_vx = new_vx + dist_x*r1
						--new_vy = new_vy + dist_y*r1
					end
				end
				
				--k = 10
				
				old_vx, old_vy = particles[p]:getVelocity()
				particles[p]:setVelocity(old_vx + new_vx, old_vy + new_vy)
				--print(dist_sum)
				--[[if dist_sum < 0.02 then
					particles[p]:setVelocity(old_vx + new_vx, old_vy + new_vy)
				elseif dist_sum > 0.03 then
					particles[p]:setVelocity(old_vx - new_vx, old_vy - new_vy)
				end--]]
			end
		end
	end
	
	
	for i=1, particles_count do
		--particles[i]:update()
		particles[i]:checkRect(spaceX, spaceY, spaceWidth, spaceHeight)
	end
	
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
	
	for i=1, particles_count do
		love.graphics.setColor(particles[i].color.r, particles[i].color.g, particles[i].color.b)
		love.graphics.circle("fill", particles[i]:getX(), particles[i]:getY(), particles[i].radius)
		--love.graphics.circle("fill", particles[i]:getX()+cameraX, particles[i]:getY()+cameraY, particles[i].radius)
		
		--love.graphics.points(particles[i]:getX()+cameraX, particles[i]:getY()+cameraY)
		--print(particles[i].connectCount)
	end
	
	
	for i=1, table.getn(joints) do
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
	end
    --love.graphics.circle("line", x1, y1, r1)
    --love.graphics.circle("line", x2, y2, r2)
    
    love.graphics.pop()
    
end

