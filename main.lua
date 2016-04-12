vector = require 'vector'
require("player")
   stars = {} -- table which will hold our stars
  
 
-------------------------
-- LOVE callbacks
--
function love.load()
   music = love.audio.newSource("ningaGhost.mp3")
   music:play()
   music:setVolume(0.02)
   fire = love.audio.newSource("laser.mp3")   
   fire:setVolume(0.06)
   asteroid = love.audio.newSource("ae.mp3")
   asteroid:setVolume(0.07)




   love.graphics.setFont(love.graphics.newFont("BADABB__.TTF",18))
   storehighscore={}
  
   p = Player:new()
   bullets = {}
   targets = {}
    z=1
    w=2
   targetImage = love.graphics.newImage("ent.png")
   turret= love.graphics.newImage("turret.png")
   turretspeed=10
   turretx = 50
   turrety = 50
      COLLISION_DISTANCE = targetImage:getWidth()/2
    screenWidth =love.window.getWidth()
   screenHeight =love.window.getHeight()
   uniquifier = 0
   -- setup targets
   spawnTargets (math.random(1,50) )
   lastSpawnTime = love.timer.getTime()
   spawnDelay = 5

   max_stars = 100 -- how many stars we want
   for i=1, max_stars do -- generate the coords of our stars
      local x = math.random(5, love.graphics.getWidth()-5) -- generate a "random" number for the x coord of this star
      local y = math.random(5, love.graphics.getHeight()-5) -- both coords are limited to the screen size, minus 5 pixels of padding
      stars[i] = {x, y} -- stick the values into the table
      end
   love.graphics.setPointSize ( 3 )
   love.graphics.setPointStyle ( "smooth" )

-----------------------------------------------------------------------
   if not love.filesystem.exists("scores.lua")then
   scores = love.filesystem.newFile("scores.lua")
end
   
 



for lines in love.filesystem.lines("scores.lua") do
   table.insert(storehighscore,lines)
  
end
love.filesystem.write("scores.lua", "p.highscore\n=\n" ..p.highscore)
 p.highscore =storehighscore[3]
-------------------------------------------------------------------------
end

function love.mousepressed( x, y, button )
   fire:play()
   local start = vector.new(love.window.getWidth()/2, love.window.getHeight())
   local speed = 1000
   local dir = vector.new(x,y) - start
   dir:normalize_inplace()
   createNewBullet ( start, dir * speed )
 
end

function love.draw()
   love.graphics.print("SCORE " .. p.score,16,15)
   love.graphics.print("HIGHSCORE " .. p.highscore,love.window.getWidth()-110,15)
   for i=1, #stars do -- loop through all of our stars
      love.graphics.point(stars[i][1], stars[i][2]) -- draw each point

   end
 for id,ent in pairs(targets) do
     ent:draw()
   end
   for id,ent in pairs(bullets) do
     ent:draw()
   end


   
   love.graphics.draw(turret,love.window.getWidth()/2,640,angletomouse , 1, 1,turret:getWidth()/2,turret:getHeight()/2)
--love.graphics.print(angletomouse, 250, 0)


end

function love.update(dt)

   if p.score > tonumber(p.highscore) then
      p.highscore=p.score
      love.filesystem.write("scores.lua", "p.highscore\n=\n" ..p.highscore)

   end

   --------------------------------------------------------

   time = love.timer.getTime()
   if time  > lastSpawnTime + spawnDelay then
      lastSpawnTime = time
      spawnTargets ( math.random(1,10))
   end
   
     stars:update(dt)
   
   for id,ent in pairs(targets) do
     ent:update(dt)
   end
   for id,ent in pairs(bullets) do
     ent:update(dt)
   end
      --Sets mouse variables--
mousex = love.mouse.getX()
mousey = love.mouse.getY()
turretx = turretx + (turretspeed * dt)
turrety = turrety + (turretspeed * dt)
angletomouse = -math.atan2(-(mousey-love.window.getHeight()),mousex-(love.window.getWidth()/2))+(math.pi/2)


end
function love.keypressed(key)
  



  --Arrow keys--
if love.keyboard.isDown("right") then
turretx = turretx + (turretspeed )
elseif love.keyboard.isDown("left") then
turretx = turretx - (turretspeed )
end
end

-----------------------------------
-- bullets
--


function createNewBullet ( pos, vel )
   local bullet = {}
   bullet.pos = vector.new(pos.x, pos.y)
   bullet.lastpos = pos
   bullet.vel = vector.new(vel.x,vel.y)
   bullet.id = getUniqueId()
   bullets[bullet.id] = bullet

   function bullet:checkForCollision ()
      -- return id of collided object (first found)
      for id,target in pairs(targets) do
         if (target.pos - self.pos):len() < COLLISION_DISTANCE then
            asteroid:play()
            p.score = p.score +1
            return id
         end
      end
      return nil
   end

   function bullet:boundary()
   
      if self.pos.y<0 then
        bullets[self.id]=nil
      end

   -- body
end

   function bullet:update ( dt ) 
      self.lastpos = self.pos
      self.pos = self.pos + self.vel * dt
      local hit = self:checkForCollision ()
      if hit then 
	     bullets[self.id] = nil
	     targets[hit] = nil
      end
      self:boundary()
      -- also check if off-screen 
   end

   function bullet:draw ()
     -- love.graphics.setColor( 255, 0, 0)
      love.graphics.line ( self.lastpos.x, self.lastpos.y, 
                           self.pos.x, self.pos.y )
   end

   return bullet
end


--------------------------
-- target
--

function createNewTarget ( pos, vel )
   local target = {}
   target.pos = vector.new(pos.x, pos.y)
   target.vel = vector.new(vel.x, vel.y)
   target.angle = love.math.random(1,360)
   target.rotationspeed=(love.math.random(0,2)-1)*0.05
   target.id = getUniqueId()
   targets[target.id] = target


   

function target:boundary()
   
        if self.pos.y>screenHeight then
            p.score = p.score -3
            if p.score < 0 then
               p.score=0
            end
        targets[self.id]=nil
      end

end

   function target:update (dt)
      self.pos = self.pos + self.vel * dt
      self.angle = self.angle + self.rotationspeed    
      self:boundary()
      -- also check for off-screen...
   end

   

   function target:draw ()
      love.graphics.draw ( targetImage, self.pos.x, self.pos.y , self.angle , 1,1,
         targetImage:getWidth()/2, targetImage:getHeight()/2 )
   end

   return target
end

function stars:update(dt)
  
   z=z+1*dt
   w=w+2
 for i=1, #stars do -- loop through all of our stars
      stars[i][2]= stars[i][2]+10*dt -- draw each point
      stars[i][2]=stars[i][2]%love.window.getHeight()
   end
end
-----------------------
-- helpers
--

function getUniqueId ()
   uniquifier = uniquifier + 1
   return uniquifier
end

function spawnTargets ( N )
   for i = 1,N do
      local pos = vector.new ( love.math.random( 10, love.window.getWidth()-10), 
                               -love.math.random(10,100) )
      local vel = vector.new ( 0,math.random(50,100))
      createNewTarget ( pos, vel )
   end
end

function love.quit()
   love.filesystem.write("scores.lua","p.highscore\n=\n" ..p.highscore)
end