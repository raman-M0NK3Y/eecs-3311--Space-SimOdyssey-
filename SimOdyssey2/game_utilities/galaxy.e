note
	description: "Galaxy represents a game board in simodyssey."
	author: "Kevin B"
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY

inherit ANY
	redefine
		out
	end

create
	make,
	make_dummy

feature -- attributes

	playerExplorer : EXPLORER

	grid: ARRAY2 [SECTOR]
			-- the board

	gen: RANDOM_GENERATOR_ACCESS

	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

feature --constructor
	make
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
		do
			create playerexplorer.make
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			from
				row := 1
			until
				row > shared_info.number_rows
			loop

				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					grid[row,column] := create {SECTOR}.make(row,column, playerexplorer )
					column:= column + 1;
				end
				row := row + 1
			end
			set_stationary_items

	end

	make_dummy
		do
			create playerexplorer.make
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
		end
feature --commands

	set_stationary_items
			-- distribute stationary items amongst the sectors in the grid.
			-- There can be only one stationary item in a sector
		local
			loop_counter: INTEGER
			check_sector: SECTOR
			temp_row: INTEGER
			temp_column: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > shared_info.number_of_stationary_items
			loop

				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]
				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					grid[temp_row,temp_column].put(create_stationary_item)
					loop_counter := loop_counter + 1
				end -- if
			end -- loop
		end -- feature set_stationary_items

	create_stationary_item: ENTITY
			-- this feature randomly creates one of the possible types of stationary actors
		local
			chance: INTEGER
		do
			chance := gen.rchoose (1, 3)
			inspect chance
			when 1 then
				create {YELLOW_DWARF} Result.make
			when 2 then
				create {BLUE_GIANT} Result.make
			when 3 then
				create {WORMHOLE} Result.make
			else
				create {YELLOW_DWARF} Result.make -- create more yellow dwarfs this will never happen, but create by default
			end -- inspect
		end

feature -- queries

	entities: ARRAY[ENTITY]
		do
			create Result.make_empty
			across 1 |..| grid.height is row loop
				across 1 |..| grid.width is col loop
					across 1 |..| grid[row, col].contents.count is i loop
						if attached {ENTITY} grid[row, col].contents[i] as entity then
							Result.force(entity, Result.count + 1)
						end
					end
				end
			end
		end


	sorted_entities: ARRAY[ENTITY]
		local
			comparator: ENTITY_COMPARE
			sorter: DS_ARRAY_QUICK_SORTER[ENTITY]
		do
			create Result.make_from_array(entities)
			create comparator.default_create
			create sorter.make(comparator)
			sorter.sort(Result)
		end


	sorted_planets: LINKED_LIST[PLANET]
		do
			create Result.make
			across sorted_entities is entity loop
				if attached {PLANET} entity as planet then
					Result.extend(planet)
				end
			end
		end

	sorted_m_e: LINKED_LIST[MOVEABLE_ENTITY]
		do
			create Result.make
			across sorted_entities is entity loop
				if attached {MOVEABLE_ENTITY} entity as m_e then
					Result.extend(m_e)
				end
			end
		end


	sector_info: STRING
		do
			create Result.make_empty
			across 1 |..| grid.height is row loop
				across 1 |..| grid.width is col loop
					Result.append("    " + grid[row, col].out)
				end
			end
		end


	out: STRING
		--Returns grid in string form
		local
			string1: STRING
			string2: STRING
			row_counter: INTEGER
			column_counter: INTEGER
			contents_counter: INTEGER
			temp_sector: SECTOR
			temp_component: ENTITY
			printed_symbols_counter: INTEGER
		do
			create Result.make_empty
			create string1.make(7*shared_info.number_rows)
			create string2.make(7*shared_info.number_columns)
			string1.append("%N")

			from
				row_counter := 1
			until
				row_counter > shared_info.number_rows
			loop
				string1.append("    ")
				string2.append("    ")

				from
					column_counter := 1
				until
					column_counter > shared_info.number_columns
				loop
					temp_sector:= grid[row_counter, column_counter]
				    string1.append("(")
	            	string1.append(temp_sector.print_sector)
	                string1.append(")")
				    string1.append("  ")
					from
						contents_counter := 1
						printed_symbols_counter:=0
					until
						contents_counter > temp_sector.contents.count
					loop
						temp_component := temp_sector.contents[contents_counter]
						if attached temp_component as character then
							string2.append_character(character.getsymbol)
						else
							string2.append("-")
						end -- if
						printed_symbols_counter:=printed_symbols_counter+1
						contents_counter := contents_counter + 1
					end -- loop

					from
					until (shared_info.max_capacity - printed_symbols_counter)=0
					loop
							string2.append("-")
							printed_symbols_counter:=printed_symbols_counter+1

					end
					string2.append("   ")
					column_counter := column_counter + 1
				end -- loop
				string1.append("%N")
				if not (row_counter = shared_info.number_rows) then
					string2.append("%N")
				end
				Result.append (string1.twin)
				Result.append (string2.twin)

				row_counter := row_counter + 1
				string1.wipe_out
				string2.wipe_out
			end
		end


end
