note
	description: "[
		Common variables such as threshold for planet
		and constants such as number of stationary items for generation of the board.
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_INFORMATION

create {SHARED_INFORMATION_ACCESS}
	make

feature{NONE}
	make
		do
				unmoveable := -1
				planets := 0
		end

feature

	number_rows: INTEGER = 5
        	-- The number of rows in the grid

	number_columns: INTEGER = 5
        	-- The number of columns in the  grid

	number_of_stationary_items: INTEGER = 10
			-- The number of stationary_items in the grid

	asteroid_threshold:INTEGER
	janitaur_threshold:INTEGER
	malevolent_threshold: INTEGER
	benign_threshold: INTEGER
    planet_threshold: INTEGER
		-- used to determine the chance of an entity being put in a location
--		attribute
--			Result := 50
--		end



	max_capacity: INTEGER = 4
		 -- max number of objects that can be stored in a location

	unmoveable : INTEGER
	planets : INTEGER

feature --commands
		set_planet_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			planet_threshold:=threshold
		end

		set_asteroid_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			asteroid_threshold:=threshold
		end

		set_janitaur_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			janitaur_threshold:=threshold
		end

		set_malevolent_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			malevolent_threshold:=threshold
		end

		set_benign_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			benign_threshold:=threshold
		end

	reset_ids
	do
		unmoveable := -1
		planets := 0
	end
	generateID(entity : ENTITY) : INTEGER
	do
		if attached {BLACKHOLE} entity then
			Result := -1
		elseif attached {EXPLORER} entity then
			Result := 0
		elseif attached {UNMOVEABLE_ENTITY} entity then
			Result := unmoveable - 1
			unmoveable := unmoveable - 1
		elseif attached {MOVEABLE_ENTITY} entity then
			Result := planets + 1
			planets := planets + 1
		end
	end
end
