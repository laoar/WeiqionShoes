# data plane.
class Board
	def initialize(width, height, nway) 
		@cstate = 1 #black first
		@way = nway
		size = [height - 60, width - 60].min
   		@unit = size / (@way - 1) 
		
		# @point : 0 -> NULL, 1 -> black, -1 : white.
		@point = Array.new(@way) {Array.new(@way, 0)}

		@step = 0
		# records the steps of each coordinate
		@steps = [] 
		
		# four directions, perheps they aren't connected.
		# means, at most there're four arrays. 
		@enemies = Array.new(4) {Array.new} 

		@breath = Array.new(@way) {Array.new(@way, 4)}
   		# set the initial breath of each point.
    	# looks a little ugly, but this is the most fast method.
		# seems we don't need do it, but it provides us another way.

		# common edges
    	for j in 1...@way-1 do
			for i in [0, @way - 1] do
				@breath[i][j] = 3
			end
    	end
    	for i in 1...@way-1 do
			for j in [0, @way - 1] do
				@breath[i][j] = 3
			end
    	end
		# four corners
		for i in [0, @way - 1] do
			for j in [0, @way - 1] do
				@breath[i][j] = 2
			end
		end

		# mark this point is checked or not.
		# I don't thinks whether it is proper to use a class variable or not,
		# just do it, in case of something.
		@checked = Array.new(@way) {Array.new(@way, 0)} 
		clear_checked

		@recover = []

		# eat list.
		@eatlist = []
		for i in 0...(@way * @way) do
			@eatlist[i] = [] 
		end
	end
	

	# Pheheps the four directions are four different blocks.
	# that's why we should check one by one and at least four arrays.
	def get_enemy(m, n, killed_array)
		breath = 0
		# check up 
		if n > 0 && @checked[m][n - 1] == 0 && @point[m][n - 1] == -1 * @cstate
			@checked[m][n - 1] = 1
			@enemies[0] << position_hash(m, n - 1)
			breath = check_enemy(m, n - 1, @enemies[0])
			if @enemies[0].size > 0 && breath == 1# kill them
				@enemies[0].each {|x|
					killed_array << x
				}
			end
		end
		@recover.each {|x|
			i,j = get_position(x)
			@checked[i][j] = 0
		}
		@recover = []
		# check down
		if n < @way - 1 && @checked[m][n + 1] == 0 && @point[m][n + 1] == -1 * @cstate
			@checked[m][n + 1] = 1
			@enemies[1] << position_hash(m, n + 1)
			breath = check_enemy(m, n + 1, @enemies[1])
			if @enemies[1].size > 0 && breath == 1
				@enemies[1].each {|x|
					killed_array << x
				}
			end
		end
		@recover.each {|x|
			i,j = get_position(x)
			@checked[i][j] = 0
		}
		@recover = []
		# check right
		if m < @way - 1 && @checked[m + 1][n] == 0 && @point[m + 1][n] == -1 * @cstate
			@checked[m + 1][n] = 1
			@enemies[2] << position_hash(m + 1, n)
			breath = check_enemy(m + 1, n, @enemies[2])
			if @enemies[2].size > 0 && breath == 1
				@enemies[2].each {|x|
					killed_array << x
				}
			end
		end
		@recover.each {|x|
			i,j = get_position(x)
			@checked[i][j] = 0
		}
		@recover = []
		# check left
		if m > 0 && @checked[m - 1][n] == 0 && @point[m - 1][n] == -1 * @cstate
			@checked[m - 1][n] = 1
			@enemies[3] << position_hash(m - 1, n)
			breath = check_enemy(m - 1, n, @enemies[3])
			if @enemies[3].size > 0 && breath == 1
				@enemies[3].each {|x|
					killed_array << x
				}
			end
		end
		@recover.each {|x|
			i,j = get_position(x)
			@checked[i][j] = 0
		}
		@recover = []

		clear_checked
	
		# clear enemies
		for i in 0...4 do
			@enemies[i] = []
		end
			
	end

	def get_breath(m, n, flag)
		breath = check_breath(m, n, flag)
		clear_checked
		return breath 
	end

	def position_hash(m, n)
		return m * @way + n
	end

	def get_position(hash_value)
		m = hash_value / @way
		n = hash_value % @way
		return m, n
	end

	attr_reader :unit, :way
	attr_accessor :point, :cstate, :breath, :checked, :steps, :step, :enemies, :eatlist

	private

	# m in 0...way
	# n in 0...way
	def clear_checked
		for i in 0...@way do
			for j in 0...@way do
				@checked[i][j] = 0
			end
		end

		return 1
	end

	# depth first or bridth first ? 
	def check_enemy(m, n, array)
		#ortherwise it is enemy.
	   	# it's boring. 
		breath = 0
		# check up
		if n > 0 && @checked[m][n - 1] == 0 
			@checked[m][n - 1] = 1
			if @point[m][n - 1] == -1 * @cstate
				array << position_hash(m, n - 1)	
				breath += check_enemy(m, n - 1, array)
			elsif @point[m][n - 1] == 0
				@recover << position_hash(m, n - 1)
				breath += 1
			end
		end	
		# check down
		if n < @way - 1 && @checked[m][n + 1] == 0
			@checked[m][n + 1] = 1
			if @point[m][n + 1] == -1 * @cstate
				array << position_hash(m, n + 1)
				breath += check_enemy(m, n + 1, array)
			elsif @point[m][n + 1] == 0
				@recover << position_hash(m, n + 1)
				breath += 1
			end
		end
		# check left
		if m > 0 && @checked[m - 1][n] == 0
			@checked[m - 1][n] = 1
			if @point[m - 1][n] == -1 * @cstate
				array << position_hash(m - 1, n)
				breath += check_enemy(m - 1, n, array)
			elsif @point[m - 1][n] == 0
				@recover << position_hash(m - 1, n)
				breath += 1
			end
		end
		# check right	
		if m < @way - 1 && @checked[m + 1][n] == 0
			@checked[m + 1][n] = 1
			if @point[m + 1][n] == -1 * @cstate
				array << position_hash(m + 1, n)
				breath += check_enemy(m + 1, n, array)
			elsif @point[m + 1][n] == 0
				@recover << position_hash(m + 1, n)
				breath += 1
			end
		end
		return breath
	end
	# We should compute all the points in the block at each click.
	# not only get the breath, but also do the eating. 
	def check_breath(m, n, flag)
		if @checked[m][n] == 1 
			return 0
		end
		@checked[m][n] = 1
		breath = 0
		# check left.
		if m > 0 && @checked[m - 1][n] == 0 
			if @point[m - 1][n] == 0 # no point.
				@checked[m - 1][n] = 1 
				breath += 1
			elsif @point[m - 1][n] == flag * @cstate # friend
				breath += check_breath(m - 1, n, flag)
			end	
		end

		# check right
		if m < @way - 1 && @checked[m + 1][n] == 0
			if @point[m + 1][n] == 0
				@checked[m + 1][n] = 1
				breath += 1
			elsif @point[m + 1][n] == flag * @cstate
				breath += check_breath(m + 1, n, flag)
			end
		end
		# check up
		if n > 0 && @checked[m][n - 1] == 0
	   		if @point[m][n - 1] == 0
				@checked[m][n - 1] = 1
				breath += 1
			elsif @point[m][n - 1] == flag * @cstate
				breath += check_breath(m, n - 1, flag)
			end	
		end
		# check down
		if n < @way - 1 && @checked[m][n + 1] == 0
			if @point[m][n + 1] == 0
				breath += 1
				@checked[m][n + 1] = 1
			elsif @point[m][n + 1] == flag * @cstate
				breath += check_breath(m, n + 1, flag)
			end
		end
		return breath
	end

end

# control plane
Shoes.app width: 800, height: 600, resizable: false do  
	background burlywood, width: 600 

	@board = Board.new(self.width, self.height, 19)
	def draw_board
		u = 0
		u = @board.unit
		stroke black 
		strokewidth 2
		for i in 0...@board.way do
			line u, (i + 1) * u, @board.way * u, (i + 1) * u
			line (i + 1) * u, u, (i + 1) * u, @board.way * u
		end

		point_size = @board.unit * (3.0 / 12.0)
		# TODO: hard code. only compitible with 19-way  
		for i in [3, 9, 15] do
			for j in [3, 9, 15] do	
				oval (i + 1) * @board.unit - point_size / 2, (j + 1) * @board.unit - point_size / 2, point_size
			end
		end
	end

	draw_board

	# catch the mouse once it right on the point
	piece_size = (11.0 / 12.0) * @board.unit
	mouse_size = @board.unit / 3

	animate do
		left_m = 0
		top_n = 0
		button, left_m, top_n = self.mouse
		#Caculate the mouse in which stack 
		m = (left_m + @board.unit / 2) / @board.unit
		n = (top_n + @board.unit / 2) / @board.unit
		if m > 0 && m < 20 && n > 0 && n < 20 && @board.point[m - 1][n - 1] != 1 
   			s = stack hidden: false, width: 2 * mouse_size, height: 2 * mouse_size, left: m * @board.unit - mouse_size , top: n * @board.unit - mouse_size  do

    			hover do
					if @board.point[m-1][n-1] == 0
      					s.clear { background blue }
					end
    			end

				leave do
      				s.clear { }
    			end 

				click do
					loot = false
					killed = []
					if @board.point[m - 1][n - 1] == 0  
						@board.get_enemy(m - 1, n - 1, killed)
						# looks ugly here? 
						if killed.size == 1 # have to judge whether it is loot. 
							#if @board.eatlist[killed[0]].size == 1
							if @board.eatlist[killed[0]].size == 1
								if @board.eatlist[killed[0]][0] == @board.position_hash(m - 1, n - 1)
									if @board.steps[@board.step] == killed[0]
										if @board.get_breath(m - 1, n - 1, 1) == 0
											loot = true
										end
									end
								end
							end
						end
						if  (loot == false) && (killed.size > 0 || @board.get_breath(m - 1, n - 1, 1)  > 0)
							@board.step += 1
							@board.steps[@board.step] = @board.position_hash(m - 1, n - 1) 
							@board.point[m - 1][n - 1] = @board.cstate
							color = @board.cstate == 1 ? black : snow
							@board.cstate *= -1 
							stroke color 
							strokewidth 2
							fill color
							oval m * @board.unit - piece_size / 2, n * @board.unit - piece_size / 2, piece_size 
							# mark the killed point.
							hash_val = @board.position_hash(m - 1, n - 1)
							if killed.size > 0
								# only record the latest eat list.
								if @board.eatlist[hash_val].size != 0
									@board.eatlist[hash_val] = []
								end
								killed.each { |x|
									@board.eatlist[hash_val] << x
									i,j = @board.get_position(x)
									stroke burlywood
									strokewidth 4
							   		fill burlywood
									oval (i + 1) * @board.unit - piece_size / 2, (j + 1) * @board.unit - piece_size / 2, piece_size 
									@board.point[i][j] = 0
									# recover the line
									stroke black
									strokewidth 2  
									x  = (i + 1) * @board.unit
									y = (j + 1) * @board.unit
									adjust = 13.2 / 12.0 # hmm, don't ask me why.
									line(x - piece_size / 2 * adjust, y, x + piece_size / 2 * adjust, y)
									line(x, y - piece_size / 2 * adjust, x, y + piece_size / 2 * adjust)
								}	
							end
						end
						killed = []
					end
					s.clear {}
				end
			end
   		end
 	end
end

