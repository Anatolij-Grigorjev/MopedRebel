extends TileMap

export (int) var COPIED_TILE_ID

func _enter_tree():
	var base_map = get_parent()
	set_up_tileset(base_map)

func set_up_tileset(base_map):
	var cells = base_map.get_used_cells_by_id(COPIED_TILE_ID)
	for cell in cells:
		set_cell(cell.x, cell.y, COPIED_TILE_ID)
