note
	description: "Represents a sector in the galaxy."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SECTOR

create
	make, make_dummy

feature -- attributes
	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	gen: RANDOM_GENERATOR_ACCESS

	contents: ARRAYED_LIST [detachable ENTITY] --holds 4 quadrants

	row: INTEGER

	column: INTEGER

feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer: ENTITY)
		--initialization
		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)
		do
			row := row_input
			column := column_input
			create contents.make (shared_info.max_capacity) -- Each sector should have 4 quadrants
			contents.compare_objects
			from
			until
				contents.count > 3
			loop
				contents.extend (void)
			end

			if (row = 3) and (column = 3) then
				put (create {BLACKHOLE}.make) -- If this is the sector in the middle of the board, place a black hole
			else
				if (row = 1) and (column = 1) then
					put (a_explorer) -- If this is the top left corner sector, place the explorer there
				end
				populate -- Run the populate command to complete setup
			end -- if
		end

feature -- commands

	add(entity : ENTITY)
	do
		contents[nextavailablespot] := entity
	end

	remove(spot : INTEGER)
	do
		contents[spot] := void
	end

	nextAvailableSpot : INTEGER
	local
		counter : INTEGER
		found : BOOLEAN
	do
		from
			counter := 0
		until
			found or counter > 4
		loop
			counter := counter + 1
			if contents.at (counter) = void then
				found := true
				Result := counter
			end
		end
	end

	getContentsSortedByID : ARRAY[ENTITY]
	local
		comparator: ENTITY_COMPARE
		sorter: DS_ARRAY_QUICK_SORTER[ENTITY]
	do
		create comparator.default_create
		create sorter.make(comparator)
		create Result.make_empty
		across contents  is entity loop
			if attached {ENTITY} entity AS entityAttached then
				Result.force (entityAttached, Result.count + 1)
			end
		end
		sorter.sort (Result)
	end

	getPlanetsInSector : ARRAY[PLANET]
	do
		create Result.make_empty
		across contents is sectorspot  loop
			if attached {PLANET} sectorspot AS planet then
				Result.force (planet, Result.count + 1)
			end
		end
	end

	feature -- Queries

	get_explorer : EXPLORER
	do
		create Result.make
		from
			contents.start
		until
			contents.after
		loop
			if attached {EXPLORER} contents.item AS explorer_copy then
				Result := explorer_copy
			end
			contents.forth
		end
	end

	make_dummy
		--initialization without creating entities in quadrants
		do
			create contents.make (shared_info.max_capacity)
			contents.compare_objects
		end

	populate
			-- this feature creates 1 to max_capacity-1 components to be intially stored in the
			-- sector. The component may be a planet or nothing at all.
		local
			threshold: INTEGER
			number_items: INTEGER
			loop_counter: INTEGER
			component: ENTITY
		do
			number_items := gen.rchoose (1, shared_info.max_capacity-1)  -- MUST decrease max_capacity by 1 to leave space for Explorer (so a max of 3)
			from
				loop_counter := 1
			until
				loop_counter > number_items
			loop
				threshold := gen.rchoose (1, 100) -- each iteration, generate a new value to compare against the threshold values provided by `test` or `play`

				if threshold < shared_info.asteroid_threshold then
					component := create {ASTEROID}.make
					if attached {ASTEROID} component AS asteroid then
						asteroid.setturnsleft (gen.rchoose (0, 2))
						put(asteroid)
					end
				elseif threshold < shared_info.janitaur_threshold then
					component := create {JANITAUR}.make
					if attached {JANITAUR} component AS janitaur then
						janitaur.setturnsleft (gen.rchoose (0, 2))
						put(janitaur)
					end
				elseif threshold < shared_info.malevolent_threshold then
					component := create {MALEVOLENT}.make
					if attached {MALEVOLENT} component AS malevolent then
						malevolent.setturnsleft (gen.rchoose (0, 2))
						put(malevolent)
					end
				elseif threshold < shared_info.benign_threshold then
					component := create {BENIGN}.make
					if attached {BENIGN} component AS benign then
					benign.setturnsleft (gen.rchoose (0, 2))
					put(benign)
					end
				elseif threshold < shared_info.planet_threshold then
					component := create {PLANET}.make
					if attached {PLANET} component AS planet then
					planet.setturnsleft (gen.rchoose (0, 2))
					put(planet)
					end
				end

				component := void -- reset component object
				loop_counter := loop_counter + 1

			end
		end

feature {GALAXY} --command

	put (new_component: ENTITY)
			-- put `new_component' in contents array
		local
			loop_counter: INTEGER
			found: BOOLEAN
		do
			from
				loop_counter := 1
			until
				loop_counter > contents.count or found
			loop
				if contents [loop_counter] = new_component then
					found := TRUE
				end --if
				loop_counter := loop_counter + 1
			end -- loop

			if not found and not is_full then
				add(new_component)
			end

		ensure
			component_put: not is_full implies contents.has (new_component)
		end

feature -- Queries

	print_sector: STRING
			-- Printable version of location's coordinates with different formatting
		do
			Result := ""
			Result.append (row.out)
			Result.append (":")
			Result.append (column.out )
		end

	is_full: BOOLEAN
			-- Is the location currently full?
		local
			loop_counter: INTEGER
			occupant: ENTITY
			empty_space_found: BOOLEAN
		do
			if contents.count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > contents.count or empty_space_found
			loop
				occupant := contents [loop_counter]
				if not attached occupant  then
					empty_space_found := TRUE
				end
				loop_counter := loop_counter + 1
			end

			if contents.count = shared_info.max_capacity and then not empty_space_found then
				Result := TRUE
			else
				Result := FALSE
			end
		end

	has_stationary: BOOLEAN
			-- returns whether the location contains any stationary item
		local
			loop_counter: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > contents.count or Result
			loop
				if attached contents [loop_counter] as temp_item  then
					Result := attached {UNMOVEABLE_ENTITY} temp_item
				end -- if
				loop_counter := loop_counter + 1
			end
		end

		has_dwarf : BOOLEAN
		do
			across contents is entity loop
				if attached {YELLOW_DWARF} entity AS star then
					Result := True
				end
			end
		end

		has_wormhole : BOOLEAN
		do
			across contents is entity loop
				if attached {WORMHOLE} entity then
					Result := True
				end
			end
		end

		has_benign : BOOLEAN
		do
			across contents is entity loop
				if attached {BENIGN} entity then
					Result := True
				end
			end
		end

		has_explorer : BOOLEAN
		do
			across contents is entity loop
				if attached {EXPLORER} entity then
					Result := True
				end
			end
		end

		has_star : INTEGER
		do
			across contents is entity loop
				if attached {STAR} entity AS star then
					Result := star.getluminosity
				end
			end
		end

		out_self : STRING
		do
			create Result.make_empty
			across 1 |..| 4 is secspot loop
				if secspot <= contents.count and then attached {ENTITY} contents.at (secspot) AS entity then
					Result.append ("[" + entity.getid.out + "," + entity.getsymbol.out + "]")
				else
					Result.append ("-")
				end

				if secspot < 4 then
					Result.append(",")
				end
			end
		end

invariant
	contents.count < 5
end

