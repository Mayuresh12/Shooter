Modify the LOVE game in this directory to:

1. replace the target image with an image of your choosing.
2. add code to delete bullets and targets when they leave the screen
3. fire a new bullet every frame while the mouse button is held down
4. add a global variable "spawnCount", set in love.load(), and used as the number of targets to spawn each time.
5. set spawnCount to 500 and see if it runs any slower.  Experiment to find the largest value of spawnCount with acceptable performance.
6. add a BSP tree (bsp.lua) to speed up collision testing. (see bsp-test.lua for an example of using it. note that the bsp builder wants an 'array' with indices from 1 to N with no gaps. Each frame, in update(), make a new bsp tree from a table holding the target positions(as an 'array'). Then use that bsp tree to test each bullet for a collision with a target, handling the collision as usual.)
