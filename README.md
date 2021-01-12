# eecs-3311--Space-SimOdyssey-


A galactic game written in Eiffel. The story so far for the game is that 
nations of Earth are in a need for a galaxy exploration simulator for deep space exploration. The simulator referred to as SimOdyssey trains space explorers 
to search different sectors of our galaxy containing stars of the same type as our sun. The game is won when a planet capable of supporting life is discovered. 
The simulation which was created in previous lab is updated with new discoveries. A two-dimensional grid (5 by 5) of sectors symbolizes the galaxy. Each sector in the 
grid is identified by its coordinates by its row number and column number. If the explorer is in any sector it is capable of moving in any of the 8 adjacent sectors, 
the grid wraps along its boundaries. 

Space (in the simulations) is inhabited by a variety of entities that have different behaviours. There are two main types of entities. 

They are:

Movable entities - which move throughout the galaxy interacting with other entities.

• Asteroid, benign, planet, malevolent and janitaur.

• The explorer - which is a unique movable entity controlled by the user.

Stationary entities - which stay in one place throughout the game.

• Wormhole, blackhole, blue giant and yellow dwarf (where blue giant and yellow dwarf are
considered to also be a star object).

Entities all have different behaviours which change the mechanics of the game. Software design patterns used (composite, singleton, visitor, command, observer, lazy initialization).
