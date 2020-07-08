note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- model attributes

	galaxy : GALAXY

	game_started : BOOLEAN
	game_over : BOOLEAN
	hasError : BOOLEAN
	victory : BOOLEAN
	sectorFull : BOOLEAN
	status : BOOLEAN

	mode : STRING
	statusMsg : STRING
	errorMsg : STRING
	message : STRING
	deathList : ARRAYED_LIST[TUPLE[STRING, STRING]]
	moveList : ARRAYED_LIST[TUPLE[STRING,STRING]]

	validMoves : INTEGER_32
	invalidMoves : INTEGER_32

	randomizer : RANDOM_GENERATOR_ACCESS
	shared_info_access : SHARED_INFORMATION_ACCESS
	shared_info: SHARED_INFORMATION

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			shared_info := shared_info_access.shared_info
			create movelist.make (100)
			create deathlist.make (100)
			create galaxy.make_dummy
			create mode.make_from_string ("")
			create errorMsg.make_from_string("ok")
			create statusmsg.make_empty
			message := "Welcome! Try test(3,5,7,15,30)"
		end

feature -- commands
	game_begin
		do
			invalidmoves := 0
			shared_info := shared_info_access.shared_info
			shared_info.reset_ids
			game_started := true
			game_over := false
			mode := "play"
			setthresholds (3,5,7,15,30)
			validmoves := validmoves + 1
			movelist.wipe_out
			deathlist.wipe_out
			create galaxy.make
		end

	test(	a_threshold, j_threshold, m_threshold, b_threshold, p_threshold : INTEGER)
		do
			invalidmoves := 0
			shared_info := shared_info_access.shared_info
			shared_info.reset_ids
			game_started := true
			game_over := false
			mode := "test"
			message := ""
			setthresholds (a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
			validmoves := validmoves + 1
			movelist.wipe_out
			deathlist.wipe_out
			create galaxy.make
		end

	abort
		do
			galaxy.playerexplorer.set_deathmessage ("")
			shared_info := shared_info_access.shared_info
			shared_info.reset_ids
			game_started := false
			game_over := true
			mode := ""
			message := "Mission aborted. Try test(3,5,7,15,30)"
			invalidMoves := invalidMoves + 1
		end

	act (action : STRING; direction : INTEGER)
	local
		explorerLoc : TUPLE[row: INTEGER; col : INTEGER; sec : INTEGER]
		t : TUPLE[og: STRING; movement:STRING]
		planets : ARRAY[PLANET]
		planet : PLANET
		counter : INTEGER
		found : BOOLEAN
		Oldrow : INTEGER
		Oldcol : INTEGER
		Oldsec : INTEGER
	do
		if action ~ "pass"  then
			-- Do nothing
		elseif action ~ "move" then
			explorerLoc := findlocationofentity (galaxy.playerexplorer)
			create t.default_create
			t.og := "[" + galaxy.playerexplorer.getid.out + ",E]:[" + explorerloc.row.out + "," + explorerloc.col.out + "," + explorerloc.sec.out + "]"
			oldrow := explorerLoc.row
			oldcol := explorerloc.col
			oldsec := explorerloc.sec
			move(galaxy.playerexplorer, direction)
			explorerLoc := findlocationofentity (galaxy.playerexplorer)
			if oldRow = explorerLoc.row and oldCol = explorerLoc.col and explorerLoc.sec = oldsec then
				t.movement := ""
				t.og := ""
			else
				t.movement := "[" + explorerloc.row.out + "," + explorerloc.col.out + "," + explorerloc.sec.out + "]"
			end
			moveList.force(t)
		elseif action ~ "wormhole"  then
			wormhole (galaxy.playerexplorer)
		elseif action ~ "land" then
			-- Land on the first planet on sector, that has not already been visited
			explorerLoc := findlocationofentity (galaxy.playerexplorer)
			planets := galaxy.grid[explorerLoc.row, explorerLoc.col].getplanetsinsector
			planets := sortPlanetsByID(planets)
			from
				counter := 1
			until
				found or counter > planets.count
			loop
				if planets[counter].getvisted ~ "F" and planets[counter].getattached ~ "T" then
					found := TRUE
					message := ""
					planet := planets[counter]
					planets[counter].setvisited ("T")
					galaxy.playerexplorer.setLanded("T")
					if planets[counter].getsupportlife ~ "F" then
						message := "Explorer found no life as we know it at " + getsector (galaxy.playerexplorer)
					else
						message := "Tranquility base here - we've got a life!"
						game_over := true
						victory := true
					end
				end
				counter := counter + 1
			end
		elseif action ~ "liftoff" then
			galaxy.playerexplorer.setLanded("F")
			message := "Explorer has lifted off from planet at " + getsector (galaxy.playerexplorer)
		end
	end

	turn(command : STRING; direction : INTEGER)
		local
			entityList:ARRAY[ENTITY]
			explorerloc, m_eloc : TUPLE[row:INTEGER; col:INTEGER; sec:INTEGER]
			t : TUPLE[og: STRING; movement:STRING]
			temp : BOOLEAN
			counter : INTEGER
			Oldrow : INTEGER
			Oldcol : INTEGER
			Oldsec : INTEGER
		do
			validmoves := validmoves + 1
			act(command, direction)
			if not sectorfull then
				invalidmoves := 0
				temp  := checkAlive(galaxy.playerexplorer, command)
			end
			entityList := getentitylistsorted

			if not (victory) and not sectorfull then
				across entityList is entity loop
					if not attached {EXPLORER} entity and attached {MOVEABLE_ENTITY} entity as m_e then
						m_eloc := findLocationOfEntity(m_e)
						if m_e.getturnsleft = 0 and m_eloc.row /= 0 and m_eloc.col /= 0 then
							if attached {PLANET} m_e AS planet and galaxy.grid[m_eloc.row, m_eloc.col].has_star > 0 then
								planet.setattached ("T")
								planet.setturnsleft (-1)
								if galaxy.grid[m_eloc.row, m_eloc.col].has_dwarf then
									if randomizer.rchoose (1, 2) = 2 then
										planet.setsupportlife ("T")
									end
								end
							else
								if galaxy.grid[m_eloc.row, m_eloc.col].has_wormhole and (attached {MALEVOLENT} m_e or attached {BENIGN} m_e)  then
									if attached {FUELED_ENTITY} m_e AS fueled then
										wormhole (fueled)
										fueled.setfuel (fueled.getfuel + 1)
									end
								else
									create t.default_create
									t.og := "[" + m_e.getid.out + "," + m_e.getsymbol.out + "]:[" + m_eLoc.row.out + "," + m_eLoc.col.out + "," + m_eLoc.sec.out + "]"
									oldRow := m_eLoc.row
									oldCol := m_eLoc.col
									oldSec := m_eLoc.sec
									move(m_e,  0)
									m_eLoc := findlocationofentity (m_e)
									if oldRow = m_eLoc.row and oldCol = m_eLoc.col and oldSec = m_eLoc.sec then
										t.movement := ""
										if attached {FUELED_ENTITY} m_e AS fueled then
											fueled.setfuel (fueled.getfuel + 1)
										end
									else
										t.movement := "[" + m_eLoc.row.out + "," + m_eLoc.col.out + "," + m_eLoc.sec.out + "]"
									end
									moveList.force (t)
								end
								if checkAlive(m_e, "move") /= TRUE then
									if attached {REPRODUCTIVE_ENTITY} m_e as r_e then
										reproduce (r_e)
									end
									behave(m_e)
								end
							end
						else
							m_e.setturnsleft (m_e.getturnsleft - 1)
						end
					end
				end
			end

			explorerloc := findlocationofentity (galaxy.playerexplorer)
			from
				counter := 0
			until
				temp or counter > 3
			loop
				counter := counter + 1
				if game_over = FALSE and then attached {PLANET} galaxy.grid[explorerloc.row,explorerloc.col].contents.at (counter) AS planet then
					if checkVictory(planet) ~ "Tranquility base here - we've got a life!" then
						temp := true
						game_over := true
						message := checkVictory(planet)
					end
				end
			end
		end

	reproduce (repro_entity : REPRODUCTIVE_ENTITY)
	local
		reproEntityLoc : TUPLE[row : INTEGER; col : INTEGER;  sec: INTEGER]
		moveTuple : TUPLE[og : STRING; next : STRING]
		newEntity : REPRODUCTIVE_ENTITY
	do
		reproEntityLoc := findlocationofentity (repro_entity)
		if not galaxy.grid[reproEntityLoc.row,reproEntityLoc.col].is_full and repro_entity.get_actions_left_until_reproduction = 0 then
			if attached {MALEVOLENT} repro_entity AS malevolent then
				create moveTuple.default_create
				newEntity := create {MALEVOLENT}.make
				newEntity.setturnsleft (randomizer.rchoose (0, 2))
				galaxy.grid[reproentityloc.row, reproentityloc.col].add(newEntity)
				moveTuple.og := "  reproduced [" + newEntity.getid.out + "," + newEntity.getsymbol.out + "] at [" + findlocationofentity (newEntity).row.out + "," + findlocationofentity (newEntity).col.out + "," + findlocationofentity (newEntity).sec.out + "]"
				moveTuple.next := ""
				moveList.force(moveTuple)
			elseif attached {BENIGN} repro_entity AS benign then
				create moveTuple.default_create
				newEntity := create {BENIGN}.make
				newEntity.setturnsleft (randomizer.rchoose (0, 2))
				galaxy.grid[reproentityloc.row, reproentityloc.col].add(newEntity)
				moveTuple.og := "  reproduced [" + newEntity.getid.out + "," + newEntity.getsymbol.out + "] at [" + findlocationofentity (newEntity).row.out + "," + findlocationofentity (newEntity).col.out + "," + findlocationofentity (newEntity).sec.out + "]"
				moveTuple.next := ""
				moveList.force(moveTuple)
			elseif attached {JANITAUR} repro_entity AS janitaur then
				create moveTuple.default_create
				newEntity := create {JANITAUR}.make
				newEntity.setturnsleft (randomizer.rchoose (0, 2))
				galaxy.grid[reproentityloc.row, reproentityloc.col].add(newEntity)
				moveTuple.og := "  reproduced [" + newEntity.getid.out + "," + newEntity.getsymbol.out + "] at [" + findlocationofentity (newEntity).row.out + "," + findlocationofentity (newEntity).col.out + "," + findlocationofentity (newEntity).sec.out + "]"
				moveTuple.next := ""
				moveList.force(moveTuple)
			end

			if attached {JANITAUR} repro_entity then
				repro_entity.set_actions_left_until_reproduction (2)
			else
				repro_entity.set_actions_left_until_reproduction (1)
			end
		else
			if not (repro_entity.get_actions_left_until_reproduction = 0) then
				repro_entity.set_actions_left_until_reproduction (repro_entity.get_actions_left_until_reproduction - 1)
			end
		end
	end
	wormhole(entityF : FUELED_ENTITY)
	local
		added : BOOLEAN
		entityFLocation : TUPLE[row: INTEGER; col: INTEGER; sec :INTEGER]
		t : TUPLE[og: STRING; movement:STRING]
		temp_row : INTEGER
		temp_col : INTEGER
		Oldrow : INTEGER
		Oldcol : INTEGER
		Oldsec : INTEGER
	do
		from
			added := false
		until
			added
		loop
			entityFLocation := findlocationofentity (entityF)
			oldrow := entityFLocation.row
			oldcol := entityFLocation.col
			oldsec := entityFLocation.sec
			create t.default_create
			t.og := "[" + entityF.getid.out + "," + entityF.getsymbol.out +"]:[" + entityFLocation.row.out + "," + entityFLocation.col.out + "," + entityFLocation.sec.out + "]"

			temp_row := randomizer.rchoose (1, 5)
			temp_col := randomizer.rchoose (1, 5)

			if galaxy.grid[temp_row, temp_col].contents.has (void) then
				entityFLocation := findlocationofentity (entityF)
				galaxy.grid[entityFLocation.row,entityFLocation.col].remove (entityFLocation.sec)
				galaxy.grid[temp_row,temp_col].add (entityF)
				added := true
				entityFLocation := findlocationofentity (entityF)
			if oldRow = entityFLocation.row and oldCol = entityFLocation.col and entityFLocation.sec = oldsec then
				t.movement := ""
				moveList.force(t)
			else
				t.movement := "[" + entityFLocation.row.out + "," + entityFLocation.col.out + "," + entityFLocation.sec.out + "]"
				moveList.force(t)
			end
			end
		end
	end

	behave ( moveable : MOVEABLE_ENTITY)
	local
		moveableloc : TUPLE[row : INTEGER; col : INTEGER;  sec: INTEGER]
		deathTuple  : TUPLE[STRING, STRING]
		moveTuple : TUPLE[og : STRING; next : STRING]
	do
		moveableloc := findLocationOfEntity(moveable)

		if attached {ASTEROID} moveable AS asteroid then
			across galaxy.grid[moveableloc.row,moveableloc.col].getcontentssortedbyid is m_e
			loop
				if attached {JANITAUR} m_e AS janitaur then
					create moveTuple.default_create
					moveTuple.og := "  destroyed [" + janitaur.getid.out + "," + janitaur.getsymbol.out + "] at [" + findlocationofentity (janitaur).row.out + "," + findlocationofentity (janitaur).col.out + "," + findlocationofentity (janitaur).sec.out + "]"
					moveTuple.next := ""
					moveList.force(moveTuple)
					deathTuple := [ "[" + janitaur.getid.out + "," + janitaur.getsymbol.out +"]->fuel:"+ janitaur.getfuel.out +"/5, load:" + janitaur.getload.out + "/2, actions_left_until_reproduction:" + janitaur.get_actions_left_until_reproduction.out + "/2, turns_left:N/A,"  ,  janitaur.get_name + " got destroyed by asteroid (id: " + asteroid.getid.out + ") at Sector:" + moveableloc.row.out+ ":" + moveableloc.col.out]
					deathlist.force (deathTuple)
					galaxy.grid[findlocationofentity (janitaur).row,findlocationofentity (janitaur).col].remove (findlocationofentity (janitaur).sec)
				elseif attached {EXPLORER} m_e AS explorer and galaxy.playerexplorer.getlanded ~ "F" then
					create moveTuple.default_create
					game_over := TRUE
					explorer.setlife (0)
					galaxy.playerexplorer.set_deathmessage (explorer.get_name + " got destroyed by asteroid (id: " + asteroid.getid.out + ") at Sector:" + moveableloc.row.out + ":" + moveableloc.col.out)
					moveTuple.og := "  destroyed [" + explorer.getid.out + "," + explorer.getsymbol.out + "] at [" + findlocationofentity (explorer).row.out + "," + findlocationofentity (explorer).col.out + "," + findlocationofentity (explorer).sec.out + "]"
					moveTuple.next := ""
					moveList.force(moveTuple)
					deathTuple := [ "[" + explorer.getid.out + "," + explorer.getsymbol.out +"]->fuel:"+ explorer.getfuel.out +"/3, life:" + explorer.getlife.out + "/3, landed?:" + explorer.getlanded + ","  ,  explorer.get_name + " got destroyed by asteroid (id: " + asteroid.getid.out + ") at Sector:" + moveableloc.row.out+ ":" + moveableloc.col.out]
					deathlist.force (deathTuple)
					galaxy.grid[findlocationofentity (explorer).row,findlocationofentity (explorer).col].remove (findlocationofentity (explorer).sec)
				elseif attached {REPRODUCTIVE_ENTITY} m_e AS fueled_e then
					create moveTuple.default_create
					moveTuple.og := "  destroyed [" + fueled_e.getid.out + "," + fueled_e.getsymbol.out + "] at [" + findlocationofentity (fueled_e).row.out + "," + findlocationofentity (fueled_e).col.out + "," + findlocationofentity (fueled_e).sec.out + "]"
					moveTuple.next := ""
					moveList.force(moveTuple)
					deathTuple := [ "[" + fueled_e.getid.out + "," + fueled_e.getsymbol.out +"]->fuel:"+ fueled_e.getfuel.out +"/3, actions_left_until_reproduction:" + fueled_e.get_actions_left_until_reproduction.out + "/1, turns_left:N/A,"  ,  fueled_e.get_name + " got destroyed by asteroid (id: " + asteroid.getid.out + ") at Sector:" + moveableloc.row.out+ ":" + moveableloc.col.out]
					deathlist.force (deathTuple)
					galaxy.grid[findlocationofentity (fueled_e).row,findlocationofentity (fueled_e).col].remove (findlocationofentity (fueled_e).sec)
				end
			end
		asteroid.setturnsleft (randomizer.rchoose (0, 2))
		elseif attached {JANITAUR} moveable AS janitaur then
			across galaxy.grid[moveableloc.row,moveableloc.col].getcontentssortedbyid  is m_e
			loop
				if attached {ASTEROID} m_e AS asteroid then
					if janitaur.getload < 2 then
						create moveTuple.default_create
						moveTuple.og := "  destroyed [" + asteroid.getid.out + "," + asteroid.getsymbol.out + "] at [" + findlocationofentity (asteroid).row.out + "," + findlocationofentity (asteroid).col.out + "," + findlocationofentity (asteroid).sec.out + "]"
						moveTuple.next := ""
						moveList.force(moveTuple)
						deathTuple := [ "[" + asteroid.getid.out + "," + asteroid.getsymbol.out + "]->turns_left:N/A,",  asteroid.get_name + " got imploded by janitaur (id: " + janitaur.getid.out + ") at Sector:" + moveableloc.row.out+ ":" + moveableloc.col.out]
						deathlist.force (deathTuple)
						galaxy.grid[findlocationofentity (asteroid).row,findlocationofentity (asteroid).col].remove (findlocationofentity (asteroid).sec)
						janitaur.setLoad(janitaur.getload + 1)
					end
				end
			end
			if galaxy.grid[moveableloc.row, moveableloc.col].has_wormhole then
				janitaur.setload (0)
			end
		janitaur.setturnsleft (randomizer.rchoose (0, 2))
		elseif attached {BENIGN} moveable AS benign then
			across galaxy.grid[moveableloc.row,moveableloc.col].getcontentssortedbyid  is m_e loop
				if attached {MALEVOLENT} m_e AS malevolent then
					create moveTuple.default_create
					moveTuple.og := "  destroyed [" + malevolent.getid.out + "," + malevolent.getsymbol.out + "] at [" + findlocationofentity (malevolent).row.out + "," + findlocationofentity (malevolent).col.out + "," + findlocationofentity (malevolent).sec.out + "]"
					moveTuple.next := ""
					moveList.force(moveTuple)
					deathTuple := [ "[" + malevolent.getid.out + "," + malevolent.getsymbol.out +"]->fuel:"+ malevolent.getfuel.out +"/3, actions_left_until_reproduction:" + malevolent.get_actions_left_until_reproduction.out + "/1, turns_left:N/A,"  ,  malevolent.get_name + " got destroyed by benign (id: " + benign.getid.out + ") at Sector:" + moveableloc.row.out+ ":" + moveableloc.col.out]
					deathlist.force (deathTuple)
					galaxy.grid[findlocationofentity (malevolent).row,findlocationofentity (malevolent).col].remove (findlocationofentity (malevolent).sec)
				end
			end
		benign.setturnsleft (randomizer.rchoose (0, 2))
		elseif attached {MALEVOLENT} moveable AS malevolent then
			if galaxy.grid[moveableLoc.row, moveableLoc.col].has_explorer and not galaxy.grid[moveableLoc.row, moveableloc.col].has_benign and galaxy.playerexplorer.getlanded ~ "F" then
				galaxy.playerexplorer.setlife (galaxy.playerexplorer.getlife - 1)
				create moveTuple.default_create
				moveTuple.og := "  attacked [" + galaxy.playerexplorer.getid.out + "," + galaxy.playerexplorer.getsymbol.out + "] at [" + findlocationofentity (galaxy.playerexplorer).row.out + "," + findlocationofentity (galaxy.playerexplorer).col.out + "," + findlocationofentity (galaxy.playerexplorer).sec.out + "]"
				moveTuple.next := ""
				moveList.force(moveTuple)
				if galaxy.playerexplorer.getlife = 0 then
					deathTuple := ["[" + galaxy.playerexplorer.getid.out + "," + galaxy.playerexplorer.getsymbol.out +"]->fuel:"+ galaxy.playerexplorer.getfuel.out +"/3, life:"+ galaxy.playerexplorer.getlife.out +"/3, landed?:" + galaxy.playerexplorer.getlanded.out + "," , "Explorer got lost in space - out of life support at Sector:" + moveableloc.row.out +":"+ moveableloc.col.out]
					deathlist.force (deathTuple)
					game_over := TRUE
					galaxy.playerexplorer.set_deathmessage ("Explorer got lost in space - out of life support at Sector:" + moveableloc.row.out +":"+ moveableloc.col.out)
					galaxy.grid[findlocationofentity (galaxy.playerexplorer).row,findlocationofentity (galaxy.playerexplorer).col].remove (findlocationofentity (galaxy.playerexplorer).sec)
				end
			end
		malevolent.setturnsleft (randomizer.rchoose (0, 2))
		elseif attached {PLANET} moveable AS planet then
			if galaxy.grid[moveableloc.row,moveableloc.col].has_star > 0 then
			planet.setattached ("T")
			planet.setturnsleft(-1)
			if  galaxy.grid[moveableloc.row,moveableloc.col].has_dwarf then
				if randomizer.rchoose (1, 2) = 2 then
					planet.setsupportlife ("T")
				end
			end
			else
				planet.setturnsleft (randomizer.rchoose (0, 2))
			end
		end

	end

	move(entity : MOVEABLE_ENTITY ; direction : INTEGER)
		local
			explorerLocation : TUPLE[row: INTEGER; col: INTEGER; sec: INTEGER]
			explorer_row : INTEGER
			explorer_col : INTEGER
			old_explorer_row : INTEGER
			old_explorer_col : INTEGER
			planetDirection : INTEGER
			usableDirection : INTEGER
		do
			-- We need to move the explorer from one place to another
			-- That is, we will remove the Explorer Entity from its current space
			-- Then, put the entity in the new space.
			-- Remove explorer from galaxy
			sectorFull := false

			if attached {REPRODUCTIVE_ENTITY} entity or attached {NO_FUEL_ENTITY} entity  then
				planetdirection := randomizer.rchoose (1, 8)
				usabledirection := planetdirection
			else
				usabledirection := direction
			end

			explorerLocation := findLocationOfEntity(entity)
			old_explorer_row := explorerLocation.row
			old_explorer_col := explorerLocation.col
			explorer_row := explorerLocation.row
			explorer_col := explorerLocation.col

			inspect usabledirection
			-- N
			when 1 then
				-- Account for looping grid
				if explorer_row = 1 then
					explorer_row := galaxy.grid.height
				else
					explorer_row := explorer_row -1 \\ galaxy.grid.height
				end

			-- NE
			when 2 then
					if explorer_row = 1 or explorer_col = galaxy.grid.width then
						if explorer_row = 1 and explorer_col = galaxy.grid.width  then
							explorer_row := galaxy.grid.height
							explorer_col :=  1
						elseif explorer_row = 1 then
							explorer_row := galaxy.grid.height
							explorer_col := explorer_col + 1
						else
							explorer_row := explorer_row - 1
							explorer_col := 1
						end
					else
						explorer_row := explorer_row - 1
						explorer_col := explorer_col + 1
					end
			-- E	
			when 3 then
				-- Account for looping grid
				if explorer_col = galaxy.grid.width then
					explorer_col := 1
				else
					explorer_col := explorer_col + 1
				end
			-- SE	
			when 4 then
				if explorer_row = galaxy.grid.height or explorer_col = galaxy.grid.width then
					if explorer_row = galaxy.grid.height and explorer_col = galaxy.grid.width then
						explorer_row := 1
						explorer_col :=  1
					elseif explorer_row = galaxy.grid.height then
						explorer_row := 1
						explorer_col := explorer_col + 1
					else
						explorer_row := explorer_row + 1
						explorer_col := 1
					end
				else
					explorer_row := explorer_row + 1
					explorer_col := explorer_col + 1
				end
			-- S
			when 5 then
				-- Account for looping grid
				if explorer_row = galaxy.grid.height then
					explorer_row := 1
				else
					explorer_row := explorer_row + 1
				end

			-- SW	
			when 6 then
				if explorer_row = galaxy.grid.height or explorer_col = 1 then
					if explorer_row = galaxy.grid.height and explorer_col = 1 then
						explorer_row := 1
						explorer_col :=  galaxy.grid.width
					elseif explorer_row = galaxy.grid.height then
						explorer_row := 1
						explorer_col := explorer_col - 1
					else
						explorer_row := explorer_row + 1
						explorer_col := galaxy.grid.width
					end
				else
					explorer_row := explorer_row + 1
					explorer_col := explorer_col - 1
				end
			-- W	
			when 7 then
				-- Account for looping grid
				if explorer_col = 1 then
					explorer_col := galaxy.grid.width
				else
					explorer_col := explorer_col - 1
				end
			-- NW	
			when 8 then
				if explorer_row = 1 or explorer_col = 1 then
						if explorer_row = 1 and explorer_col = 1  then
							explorer_row := galaxy.grid.height
							explorer_col :=  galaxy.grid.width
						elseif explorer_row = 1 then
							explorer_row := galaxy.grid.height
							explorer_col := explorer_col - 1
						else
							explorer_row := explorer_row - 1
							explorer_col := galaxy.grid.width
						end
					else
						explorer_row := explorer_row - 1
						explorer_col := explorer_col - 1
					end
			else
				-- Should never happen, error would be taken care of outside
			end

			if galaxy.grid[explorer_row,explorer_col].contents.has (void) then
				explorerLocation := findLocationOfEntity(entity)
				galaxy.grid[old_explorer_row,old_explorer_col].remove (explorerLocation.sec)
				galaxy.grid[explorer_row,explorer_col].add (entity)
			elseif not(galaxy.grid[explorer_row,explorer_col].contents.has (void)) and attached {EXPLORER} entity then
				sectorFull := true
				validmoves := validmoves - 1
				incrementinvalidmoves
				seterrortrue
				seterrormsg ("Cannot transfer to new location as it is full.")
			end
		end

		reset
			-- Reset model state.
		do
			make
		end

		checkAlive(entity : MOVEABLE_ENTITY; command : STRING) : BOOLEAN
		local
			entityFLocation : TUPLE[row: INTEGER; col: INTEGER; sec: INTEGER]
			entityF_row : INTEGER
			entityF_col : INTEGER
			deathTuple  : TUPLE[STRING, STRING]
		do
			create deathTuple.default_create
			entityFLocation := findLocationOfEntity(entity)
			entityF_row := entityFLocation.row
			entityF_col := entityFLocation.col

			if attached {FUELED_ENTITY} entity AS fueled_e then
				if command ~ "move"  then
					fueled_e.setFuel(fueled_e.getFuel - 1)
				end

				if galaxy.grid[entityF_row, entityF_col].has_star /= 0 then
					if fueled_e.getfuel + galaxy.grid[entityF_row, entityF_col].has_star >  fueled_e.getMaxFuel then
						fueled_e.setfuel (fueled_e.getmaxfuel)
					else
						fueled_e.setfuel (fueled_e.getfuel + galaxy.grid[entityF_row, entityF_col].has_star)
					end
				end

				if fueled_e.getfuel = 0 then
					if attached {EXPLORER} fueled_e AS explorer then
						Result := True
						game_over := TRUE
						galaxy.playerexplorer.setlife (0)
						deathTuple := [ "[" + explorer.getid.out + "," + explorer.getsymbol.out +"]->fuel:"+ explorer.getfuel.out +"/3, life:"+ explorer.getlife.out +"/3, landed?:" + explorer.getlanded.out + ",", "Explorer got lost in space - out of fuel at Sector:"+ entityF_row.out+":" + entityF_col.out]
						deathlist.force (deathTuple)
						explorer.set_deathmessage ("Explorer got lost in space - out of fuel at Sector:"+ entityF_row.out+":" + entityF_col.out )
						galaxy.grid[entityF_row,entityF_col].remove (entityflocation.sec)
					elseif attached {JANITAUR} fueled_e AS janitaur then
						Result := TRUE
						deathTuple := [ "[" + janitaur.getid.out + "," + janitaur.getsymbol.out +"]->fuel:"+ janitaur.getfuel.out + "/5, load:" + janitaur.getload.out  + "/2, actions_left_until_reproduction:"+ janitaur.get_actions_left_until_reproduction.out +"/2, turns_left:" + "N/A," ,  janitaur.get_name + " got lost in space - out of fuel at Sector:"+ entityF_row.out+ ":" + entityF_col.out]
						deathlist.force (deathTuple)
						galaxy.grid[entityF_row,entityF_col].remove (entityflocation.sec)
					elseif attached {REPRODUCTIVE_ENTITY} fueled_e AS repro_e then
						Result := TRUE
						deathTuple := [ "[" + repro_e.getid.out + "," + repro_e.getsymbol.out +"]->fuel:"+ repro_e.getfuel.out + "/3, actions_left_until_reproduction:"+ repro_e.get_actions_left_until_reproduction.out +"/1, turns_left:" + "N/A," ,  repro_e.get_name + " got lost in space - out of fuel at Sector:"+ entityF_row.out+ ":" + entityF_col.out]
						deathlist.force (deathTuple)
						galaxy.grid[entityF_row,entityF_col].remove (entityflocation.sec)
					end
				end
			end

			if galaxy.grid[3,3].contents.has (entity) then
				if attached {EXPLORER} entity AS explorer then
					game_over := TRUE
					Result := TRUE
					galaxy.playerexplorer.setlife (0)
					deathTuple := ["[" + explorer.getid.out + "," + explorer.getsymbol.out +"]->fuel:"+ explorer.getfuel.out +"/3, life:"+ explorer.getlife.out +"/3, landed?:" + explorer.getlanded.out + "," , "Explorer got devoured by blackhole (id: -1) at Sector:3:3"]
					deathlist.force (deathTuple)
					explorer.set_deathmessage ("Explorer got devoured by blackhole (id: -1) at Sector:3:3")
					galaxy.grid[3,3].remove (entityflocation.sec)
				elseif attached {PLANET} entity AS planet then
					Result := TRUE
					deathTuple := ["[" + planet.getid.out + "," + planet.getsymbol.out +"]->attached?:"+ planet.getattached +", support_life?:" + planet.getsupportlife + ", visited?:"+ planet.getvisted +", turns_left:" + "N/A,","Planet got devoured by blackhole (id: -1) at Sector:3:3"]
					deathlist.force (deathTuple)
					galaxy.grid[3,3].remove (entityflocation.sec)
				elseif attached {JANITAUR} entity AS janitaur then
					Result := TRUE
					deathTuple := ["[" + janitaur.getid.out + "," + janitaur.getsymbol.out +"]->fuel:"+ janitaur.getfuel.out + "/5, load:" + janitaur.getload.out + "/2, actions_left_until_reproduction:"+ janitaur.get_actions_left_until_reproduction.out +"/2, turns_left:" + "N/A,","Janitaur got devoured by blackhole (id: -1) at Sector:3:3"]
					deathlist.force (deathTuple)
					galaxy.grid[3,3].remove (entityflocation.sec)
				elseif attached {REPRODUCTIVE_ENTITY} entity AS repro_e then
					Result := TRUE
					deathTuple := ["[" + repro_e.getid.out + "," + repro_e.getsymbol.out +"]->fuel:"+ repro_e.getfuel.out + "/3, actions_left_until_reproduction:"+ repro_e.get_actions_left_until_reproduction.out +"/1, turns_left:" + "N/A,", repro_e.get_name + " got devoured by blackhole (id: -1) at Sector:3:3"]
					deathlist.force (deathTuple)
					galaxy.grid[3,3].remove (entityflocation.sec)
				elseif attached {ASTEROID} entity AS asteroid then
					Result := TRUE
					deathTuple := ["[" + asteroid.getid.out + "," + asteroid.getsymbol.out +"]->turns_left:N/A,", "Asteroid got devoured by blackhole (id: -1) at Sector:3:3"]
					deathlist.force (deathTuple)
					galaxy.grid[3,3].remove (entityflocation.sec)
				end
			end
		end

feature -- Helpers

	setThresholds(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold : INTEGER)
	do
		shared_info_access.shared_info.set_asteroid_threshold (a_threshold)
		shared_info_access.shared_info.set_janitaur_threshold (j_threshold)
		shared_info_access.shared_info.set_malevolent_threshold (m_threshold)
		shared_info_access.shared_info.set_benign_threshold (b_threshold)
		shared_info_access.shared_info.set_planet_threshold (p_threshold)
	end

	findLocationOfEntity (entityInput : ENTITY) : TUPLE[row: INTEGER; col: INTEGER; sec: INTEGER]
	local
		counter : INTEGER
	do
		create Result.default_create
		across 1 |..| galaxy.grid.height is rownum
			loop
				across 1 |..| galaxy.grid.width is colnum
				loop
					across galaxy.grid[rownum,colnum].contents is entity  loop
						counter := counter + 1
						if entity ~ entityInput then
							Result.row := rownum
							Result.col := colnum
							Result.sec := counter
						end
					end
					counter := 0
				end
			end
	end

	printAllMoves : STRING
	local
		t: TUPLE[og: STRING; move: STRING]
	do
		Result := ""
		across movelist is movement loop
			t:= movement
			if t.og /~ "" then
				Result.append("%N    " + t.og )
			end
			if t.move /~ "" then
				Result.append ( "->" + t.move)
			end
		end
		if Result ~ "" then
			Result := "none"
		end
		movelist.wipe_out
	end

	printAllDeaths : STRING
	local t : TUPLE[s1: STRING; s2: STRING]
	do
		create Result.make_empty
		across deathlist is death loop
			t := death
			Result.append ("%N    " + t.s1 + "%N      " + t.s2 )
		end
		if deathlist.is_empty then
			Result := "none"
		end
		deathlist.wipe_out
	end

	printAllSectorList : STRING
	do
		create Result.make_empty
		across 1 |..| galaxy.grid.height is rownum
			loop
				across 1 |..| galaxy.grid.width is colnum
				loop
					Result.append ("%N    [" + rownum.out + "," + colnum.out + "]->")
					Result.append(galaxy.grid[rownum,colnum].out_self)
				end
			end
	end

	printTurnsLeft (planet : PLANET) : STRING
	do
		if planet.getattached ~ "T" or planet.getturnsleft < 0 then
			Result := "N/A"
		else
			Result := planet.getTurnsLeft.out
		end
	end

	printAllDescriptionList : STRING
	local
		listEntities : ARRAY[ENTITY]
	do
		create Result.make_empty
		listEntities := getEntityListSorted
		across listEntities is entity loop
			Result.append ("%N    [" + entity.getid.out + "," + entity.getsymbol.out + "]->")
			if attached {EXPLORER} entity AS explorer then
				Result.append ("fuel:"+ explorer.getfuel.out +"/3, life:"+ explorer.getlife.out +"/3, landed?:" + explorer.getlanded.out)
			elseif attached {ASTEROID} entity AS asteroid then
				Result.append ("turns_left:" + asteroid.getturnsleft.out)
			elseif attached {JANITAUR} entity AS janitaur then
				Result.append ("fuel:" + janitaur.getfuel.out + "/5, load:" + janitaur.getLoad.out + "/2, actions_left_until_reproduction:" + janitaur.get_actions_left_until_reproduction.out + "/2, turns_left:" + janitaur.getturnsleft.out)
			elseif attached {REPRODUCTIVE_ENTITY} entity as r_entity then
				Result.append ("fuel:" + r_entity.getfuel.out + "/3, actions_left_until_reproduction:" + r_entity.get_actions_left_until_reproduction.out + "/1, turns_left:" + r_entity.getturnsleft.out)
			elseif attached {PLANET} entity AS planet then
				Result.append ("attached?:"+ planet.getattached +", support_life?:" + planet.getsupportlife + ", visited?:"+ planet.getvisted +", turns_left:" + printTurnsLeft(planet))
			elseif attached {STAR} entity AS star then
				Result.append ("Luminosity:" + star.getLuminosity.out)
			end
		end
	end

	sortPlanetsByID(planets : ARRAY[PLANET]) : ARRAY[PLANET]
	local
		comparator: ENTITY_COMPARE
		sortist : DS_ARRAY_QUICK_SORTER[ENTITY]
	do
		create Result.make_from_array (planets)
		create comparator.default_create
		create sortist.make(comparator)
		sortist.sort(Result)
	end

	getEntityListSorted : ARRAY[ENTITY]
	local
		comparator: ENTITY_COMPARE
		sortist : DS_ARRAY_QUICK_SORTER[ENTITY]
	do
		create Result.make_empty
		create comparator.default_create
		create sortist.make(comparator)

		across 1 |..| galaxy.grid.height is rownum loop
				across 1 |..| galaxy.grid.width is colnum loop
					across galaxy.grid[rownum,colnum].contents is  entity loop
						if attached entity AS ae then Result.force (ae, Result.count + 1) end
					end
				end
		end
		sortist.sort(Result)
	end

	setErrorTrue
	do
		hasError := true
	end

	setErrorFalse
	do
		hasError := false
	end

	setErrorMsg(inputmessage : STRING)
	do
		errorMsg := inputmessage
	end

	incrementInvalidMoves
	do
		invalidmoves := invalidmoves + 1
	end

	statusOn
	do
		status := true
	end
feature -- queries

	getStatusMessage : STRING
	local
		explorerLoc : TUPLE[row : INTEGER; col : INTEGER;  sec : INTEGER]
	do
		create Result.make_empty
		explorerLoc := findlocationofentity (galaxy.playerexplorer)
		if galaxy.playerexplorer.getlanded ~  "F" then
			Result.append("%N  Explorer status report:Travelling at cruise speed at [" + explorerLoc.row.out + "," + explorerLoc.col.out + "," + explorerLoc.sec.out+ "]")
		else
			Result.append("%N  Explorer status report:Stationary on planet surface at [" + explorerLoc.row.out + "," + explorerLoc.col.out + "," + explorerLoc.sec.out+ "]")
		end
		Result.append("%N  Life units left:" + galaxy.playerexplorer.getlife.out + "," + " Fuel units left:" + galaxy.playerexplorer.getfuel.out)
	end

	getSectorFull : BOOLEAN
	do
		Result := sectorfull
	end

	checkVictory(planet : PLANET) : STRING
	do
		create Result.make_empty
		if planet.getvisted ~ "T" and planet.getattached ~ "T" and planet.getsupportlife ~ "T" then
			Result.append("Tranquility base here - we've got a life!")
			game_over := TRUE
			victory := TRUE
		else
			Result.append("Explorer found no life as we know it at " + getsector (galaxy.playerexplorer))
		end
	end

	getSector(entity : ENTITY) : STRING
	local
		entityLoc : TUPLE[row : INTEGER; col: INTEGER; sec : INTEGER]
		X : INTEGER
		Y : INTEGER
	do
		create Result.make_empty
		entityLoc := findlocationofentity (entity)
		X := entityLoc.row
		Y := entityLoc.col
		Result.append ("Sector:" + X.out + ":" + Y.out)
	end

	hasWormhole (explorer : EXPLORER) : BOOLEAN
	local
		entityLoc : TUPLE[row : INTEGER; col: INTEGER; sec : INTEGER]
	do
		entityLoc := findlocationofentity (explorer)
		across galaxy.grid[entityloc.row, entityloc.col].contents is secspot loop
			if attached {WORMHOLE} secspot then
				Result := TRUE
			end
		end
	end

	hasPlanets(explorer : EXPLORER)  : TUPLE[row : INTEGER; col : INTEGER; has : BOOLEAN]
	local
		entityLoc : TUPLE[row : INTEGER; col: INTEGER; sec : INTEGER]
		X : INTEGER
		Y : INTEGER
	do
		create Result.default_create
		entityLoc := findlocationofentity (explorer)
		X := entityLoc.row
		Y := entityLoc.col

		if across galaxy.grid[X,Y].contents is secspot some attached {PLANET} secspot end then
			Result.row := X
			Result.col := Y
			Result.has := True
		else
			Result.row := 0
			Result.col := 0
			Result.has := False
		end
	end

	hasYellowDwarf(explorer : EXPLORER)  : TUPLE[row : INTEGER; col : INTEGER; has : BOOLEAN]
	local
		entityLoc : TUPLE[row : INTEGER; col: INTEGER; sec : INTEGER]
		X : INTEGER
		Y : INTEGER
	do
		create Result.default_create
		entityLoc := findlocationofentity (explorer)
		X := entityLoc.row
		Y := entityLoc.col

		if across galaxy.grid[X,Y].contents is secspot some attached {YELLOW_DWARF} secspot end then
			Result.row := X
			Result.col := Y
			Result.has := True
		else
			Result.row := 0
			Result.col := 0
			Result.has := False
		end
	end

	hasUnvisitedPlanets(explorer : EXPLORER) : TUPLE[row : INTEGER; col : INTEGER; has : BOOLEAN]
	local
		entityLoc : TUPLE[row : INTEGER; col: INTEGER; sec : INTEGER]
	do
		create Result.default_create
		entityLoc := findlocationofentity (explorer)
		Result.row := entityLoc.row
		Result.col := entityLoc.col

		across galaxy.grid[entityLoc.row, entityLoc.col].contents is secspot loop
			if attached {PLANET} secspot AS planet then
				if planet.getvisted ~ "F" and planet.getattached ~ "T" then
					Result.has := True
				end
			end
		end
	end

	getExplorer : EXPLORER
	do
		Result := galaxy.playerExplorer
	end

	getGameStarted : BOOLEAN
	do
		Result := game_started
	end

	getGameOver : BOOLEAN
	do
		Result := game_over
	end

	out : STRING
		do
			create Result.make_empty
				Result.append ("  state:" + validMoves.out + "." + invalidMoves.out)
				if mode /~ "" and game_started then
					Result.append (", mode:" + mode)
				end
				if hasError then
					Result.append(", error")
					Result.append ("%N  " + errormsg)
				elseif game_over and victory then
					Result.append(", ok")
					Result.append("%N  "  + message)
					game_started := false
				elseif status then
					Result.append(", ok")
					Result.append(getstatusmessage)
				else
					Result.append(", ok")
					if game_over and galaxy.playerexplorer.getdeathmsg /~ "" then
						Result.append ("%N  " + galaxy.playerexplorer.getDeathMsg)
						Result.append("%N  The game has ended. You can start a new game.")
					end
					if message /~ "" then
						Result.append("%N  " + message)
						message := ""
					end
					if game_started and not status then
						Result.append("%N  Movement:")
						Result.append (printAllMoves)
					end
					if mode ~ "test" and not status then
						Result.append("%N  Sectors:")
						Result.append (printAllSectorList)
						Result.append("%N  Descriptions:")
						Result.append (printalldescriptionlist)
						Result.append("%N  Deaths This Turn:")
						Result.append (printAllDeaths)
					end
					if game_started and not Status then
						Result.append (galaxy.out)
						if game_over and mode ~ "play" then
							game_started := false
							mode := ""
						end
					end
					if game_over and not(victory) and mode ~ "test"  then
						Result.append ("%N  " + galaxy.playerexplorer.getDeathMsg)
						Result.append("%N  The game has ended. You can start a new game.")
						mode := ""
						game_started := false
					end
			end
				-- Reset Errors
				message := ""
				errorMsg := ""
				setErrorFalse
				victory := false
				status := false
				sectorfull := false
		end
end




