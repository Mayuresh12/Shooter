Player={}
function Player:new()

	o = {
	score=0,
	highscore =0,

	}
setmetatable(o, {__index =Player})
return o
end