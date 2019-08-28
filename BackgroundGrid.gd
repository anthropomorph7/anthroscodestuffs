extends Node2D

# Grid Variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;
export (int) var y_offset;

export (PoolVector2Array) var empty_spaces
#export (PoolStringArray) var possible_pieces;
var possible_pieces = preload("res://Scenes/TileBlank.tscn");
var empty_tiles = preload("res://Scenes/TileEmpty.tscn");

var all_pieces = []

#Camera Stuff
signal place_camera;

func _ready():
	all_pieces = make_2d_array();
	spawn_pieces();
	change_pieces();

func make_2d_array():
    var array = [];
    for i in width:
        array.append([]);
        for j in height:
            array[i].append(null);
    return array;

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y);

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y);

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true;
	return false;

func is_in_array(array, item):
    if array !=null:
        for i in array.size():
            if array[i] == item:
                return true
    return false

func restricted_fill(place):
	# check the empty pieces
	if is_in_array(empty_spaces, place):
		return true;
	return false;

func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i, j)) and all_pieces[i][j] == null:
				var piece = possible_pieces.instance();
				add_child(piece);
				piece.position = grid_to_pixel(i, j);
				all_pieces[i][j] = piece;
			if restricted_fill(Vector2(i,j)) and all_pieces[i][j] == null:
				var otherpiece = empty_tiles.instance();
				add_child(otherpiece);
				otherpiece.position = grid_to_pixel(i,j);
				all_pieces[i][j] = otherpiece;

func change_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if !restricted_fill(Vector2(i,j)): #not an empty space
				
					#this is for the background tiles that go UNDER the pieces
					if !is_in_grid(Vector2(i-1,j)): #if left is off grid
						if !is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up is off grid, but down is in
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_left();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_left_peninsula();
							elif restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_peninsula();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_island();
						elif !is_in_grid(Vector2(i,j-1)) and is_in_grid(Vector2(i,j+1)): #if down is off grid, but up is in
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_left();
								elif restricted_fill(Vector2(i,j+1)): #if down up not exist
									all_pieces[i][j].make_left_peninsula();
							elif restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_peninsula();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_island();
						elif is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up and down are both in grid
							if !restricted_fill(Vector2(i,j+1)): #if up exists
								if !restricted_fill(Vector2(i+1,j)): #if right exists
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_middle_or_side();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_bottom_left();
								if restricted_fill(Vector2(i+1,j)): #if right does not exist
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_middle_or_side();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_bottom_peninsula();
							if restricted_fill(Vector2(i,j+1)): #if up does not exist
								if !restricted_fill(Vector2(i+1,j)): #if right exists
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_top_left();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_left_peninsula();
								if restricted_fill(Vector2(i+1,j)): #if right does not exist
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_top_peninsula();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_island();
				
					if !is_in_grid(Vector2(i+1,j)): #if right is off grid
						if !is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up is off grid, but down is in
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_right();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_right_peninsula();
							elif restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_peninsula();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_island();
						elif !is_in_grid(Vector2(i,j-1)) and is_in_grid(Vector2(i,j+1)): #if down is off grid, but up is in
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_right();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_right_peninsula();
							elif restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_peninsula();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_island();
						elif is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up and down are both in grid
							if !restricted_fill(Vector2(i,j+1)): #if up exists
								if !restricted_fill(Vector2(i-1,j)): #if left exists
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_middle_or_side();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_bottom_right();
								if restricted_fill(Vector2(i-1,j)): #if left does not exist
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_middle_or_side();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_bottom_peninsula();
							if restricted_fill(Vector2(i,j+1)): #if up does not exist
								if !restricted_fill(Vector2(i-1,j)): #if left exists
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_top_right();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_right_peninsula();
								if restricted_fill(Vector2(i-1,j)): #if left does not exist
									if !restricted_fill(Vector2(i,j-1)): #if down exists
										all_pieces[i][j].make_top_peninsula();
									elif restricted_fill(Vector2(i,j-1)): #if down does not exist
										all_pieces[i][j].make_island();
				
					if !is_in_grid(Vector2(i,j+1)): #if up is off grid
						if !is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if left is off grid, but right is in
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_left();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_left_peninsula();
							elif restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_peninsula();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_island();
						elif !is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i-1,j)): #if right is off grid, but left is in
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_right();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_right_peninsula();
							if restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									all_pieces[i][j].make_top_peninsula();
								elif restricted_fill(Vector2(i,j-1)): #if down does not exist
									all_pieces[i][j].make_island();
						elif is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if right and left are both in grid
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_top_right();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_right_peninsula();
							if restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_top_left();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_top_peninsula();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_left_peninsula();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_island();
				
					if !is_in_grid(Vector2(i,j-1)): #if down is off grid
						if !is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if left is off grid, but right is in
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_left();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_left_peninsula();
							elif restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_peninsula();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_island();
						elif !is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i-1,j)): #if right is off grid, but left is in
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_right();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_right_peninsula();
							if restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									all_pieces[i][j].make_bottom_peninsula();
								elif restricted_fill(Vector2(i,j+1)): #if up does not exist
									all_pieces[i][j].make_island();
						elif is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if right and left are both in grid
							if !restricted_fill(Vector2(i-1,j)): #if left exists
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_bottom_right();
								if restricted_fill(Vector2(i,j+1)): #if up does not exist
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_right_peninsula();
							if restricted_fill(Vector2(i-1,j)): #if left does not exist
								if !restricted_fill(Vector2(i,j+1)): #if up exists
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_bottom_left();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_bottom_peninsula();
								if restricted_fill(Vector2(i,j+1)): #if up does not exist
									if !restricted_fill(Vector2(i+1,j)): #if right exists
										all_pieces[i][j].make_left_peninsula();
									if restricted_fill(Vector2(i+1,j)): #if right does not exist
										all_pieces[i][j].make_island();
				
					if is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i,j-1)) and is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i,j+1)): #if all sides are in grid
						if !restricted_fill(Vector2(i,j+1)): #if up exists
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_middle_or_side();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_bottom_left();
							if restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_middle_or_side();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_bottom_right();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_bottom_peninsula();
						if restricted_fill(Vector2(i,j+1)): #if up does not exist
							if !restricted_fill(Vector2(i+1,j)): #if right exists
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_top_left();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_middle_or_side();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_left_peninsula();
							if restricted_fill(Vector2(i+1,j)): #if right does not exist
								if !restricted_fill(Vector2(i,j-1)): #if down exists
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_top_right();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_top_peninsula();
								if restricted_fill(Vector2(i,j-1)): #if down does not exist
									if !restricted_fill(Vector2(i-1,j)): #if left exists
										all_pieces[i][j].make_right_peninsula();
									if restricted_fill(Vector2(i-1,j)): #if left does not exist
										all_pieces[i][j].make_island();
			
			#This starts the empty spaces
			if restricted_fill(Vector2(i,j)) and all_pieces[i][j] != null: #if it's an empty space
			
				if !is_in_grid(Vector2(i, j-1)): #if down is off grid
					if is_in_grid(Vector2(i-1,j)): #if left is in grid
						if is_in_grid(Vector2(i+1,j)): #if right is in grid
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i,j+1)): #up exists
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_ne_nw();
											elif restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_nw();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_nw();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_nw();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exists
								if !restricted_fill(Vector2(i,j+1)): #up exists
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j+1)): #upright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
												all_pieces[i][j].make_empty();
												
						if !is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i-1,j)): #if right is off grid, but left is in
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i,j+1)): #up exists
									if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
										all_pieces[i][j].make_nw();
									if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
									if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
										all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i,j+1)): #up exists
									if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
									if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
										all_pieces[i][j].make_empty();
										
					if !is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if left is NOT in grid but right is
						if !restricted_fill(Vector2(i,j+1)): #up exists
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_ne();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
						if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
									
									
				if !is_in_grid(Vector2(i, j+1)) and all_pieces[i][j] != null: #if up is off grid
					if is_in_grid(Vector2(i-1,j)): #if left is in grid
						if is_in_grid(Vector2(i+1,j)): #if right is in grid
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_sw_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_sw();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_sw();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i+1,j)): #right exists
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
										if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
						if !is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i-1,j)): #if right is NOT in grid but left is
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_sw();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
					if !is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i+1,j)): #if left is NOT in grid but right is
						if !restricted_fill(Vector2(i,j-1)): #down exists
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j-1)): #downright exists
									all_pieces[i][j].make_se();
								if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j-1)): #downright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
									all_pieces[i][j].make_empty();
						if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j-1)): #downright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j-1)): #downright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
									all_pieces[i][j].make_empty();
												
												
				if !is_in_grid(Vector2(i-1, j)) and all_pieces[i][j] != null: #if left is off grid
					if is_in_grid(Vector2(i,j-1)): #if down is in grid
						if is_in_grid(Vector2(i,j+1)): #if up is in grid
							if !restricted_fill(Vector2(i,j+1)): #up exists
								if !restricted_fill(Vector2(i+1,j)): #right exists
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se_ne();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_ne();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_ne();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
								if !restricted_fill(Vector2(i+1,j)): #right exists
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i+1,j+1)): #upright exists
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
											if !restricted_fill(Vector2(i+1,j-1)): #downright exists
												all_pieces[i][j].make_empty()
											if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
												all_pieces[i][j].make_empty();
						if !is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up is NOT in grid but down is
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i+1,j-1)): #downright exists
										all_pieces[i][j].make_se();
									if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i+1,j-1)): #downright exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
										all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i+1,j-1)): #downright exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i+1,j-1)): #downright exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
										all_pieces[i][j].make_empty();
					if !is_in_grid(Vector2(i,j-1)): #if down is NOT in grid
						if !restricted_fill(Vector2(i,j+1)): #up exists
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_ne();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
						if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
							if !restricted_fill(Vector2(i+1,j)): #right exists
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
								if !restricted_fill(Vector2(i+1,j+1)): #upright exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
									all_pieces[i][j].make_empty();
												
												
				if !is_in_grid(Vector2(i+1, j)) and all_pieces[i][j] != null: #if right is off grid
					if is_in_grid(Vector2(i,j-1)): #if down is in grid
						if is_in_grid(Vector2(i,j+1)): #if up is in grid
							if !restricted_fill(Vector2(i,j+1)): #up exists
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_nw_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_nw();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_nw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_nw();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty()
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i,j-1)): #down exists
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
										if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												all_pieces[i][j].make_empty();
						if !is_in_grid(Vector2(i,j+1)) and is_in_grid(Vector2(i,j-1)): #if up is NOT in grid but down is
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_sw();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i,j-1)): #down exists
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
									if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
										all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
										all_pieces[i][j].make_empty();
					if !is_in_grid(Vector2(i,j-1)) and is_in_grid(Vector2(i,j+1)): #if down is NOT in grid and up is
						if !restricted_fill(Vector2(i,j+1)): #up exists
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
									all_pieces[i][j].make_nw();
								if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
									all_pieces[i][j].make_empty();
						if restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
							if !restricted_fill(Vector2(i-1,j)): #left exists
								if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
									all_pieces[i][j].make_empty();
							if restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
								if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
									all_pieces[i][j].make_empty();
								if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
									all_pieces[i][j].make_empty();
								
								
				elif all_pieces[i][j] != null and is_in_grid(Vector2(i-1,j)) and is_in_grid(Vector2(i,j-1)) and is_in_grid(Vector2(i+1,j)) and is_in_grid(Vector2(i,j+1)):
					if !restricted_fill(Vector2(i,j+1)): #up exists
						if !restricted_fill(Vector2(i+1,j)): #right exists
							if !restricted_fill(Vector2(i,j-1)): #down exists
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_all_corners();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw_se_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se_ne();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se_ne();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
							elif restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_ne();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_ne();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
						elif restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
							if !restricted_fill(Vector2(i,j-1)): #down exists
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
							elif restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_nw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
					elif restricted_fill(Vector2(i,j+1)): #up DOES NOT exist
						if !restricted_fill(Vector2(i+1,j)): #right exists
							if !restricted_fill(Vector2(i,j-1)): #down exists
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_se();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_se();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
							elif restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
						elif restricted_fill(Vector2(i+1,j)): #right DOES NOT exist
							if !restricted_fill(Vector2(i,j-1)): #down exists
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_sw();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_sw();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
							elif restricted_fill(Vector2(i,j-1)): #down DOES NOT exist
								if !restricted_fill(Vector2(i-1,j)): #left exists
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
								elif restricted_fill(Vector2(i-1,j)): #left DOES NOT exist
									if !restricted_fill(Vector2(i+1,j+1)): #upright exists
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
									if restricted_fill(Vector2(i+1,j+1)): #upright DOES NOT exist
										if !restricted_fill(Vector2(i+1,j-1)): #downright exists
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
										if restricted_fill(Vector2(i+1,j-1)): #downright DOES NOT exist
											if !restricted_fill(Vector2(i-1,j-1)): #downleft exists
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();
											if restricted_fill(Vector2(i-1,j-1)): #downleft DOES NOT exist
												if !restricted_fill(Vector2(i-1,j+1)): #upleft exists
													all_pieces[i][j].make_empty();
												if restricted_fill(Vector2(i-1,j+1)): #upleft DOES NOT exist
													all_pieces[i][j].make_empty();


func move_camera():
	var new_pos = grid_to_pixel(width/2 - .5, height/2 - .5);
	emit_signal("place_camera", new_pos);
	pass;

func _on_GameManager_set_dimensions(new_width, new_height):
	width = new_width;
	height = new_height;

func _on_GameManager_empty_spaces(new_empty_spaces):
	empty_spaces = new_empty_spaces;