extends TileMap

export (PoolIntArray) var COPIED_TILE_IDs = []

func _enter_tree():
	var base_map = get_parent()
	set_up_tileset(base_map)

func set_up_tileset(base_map):
	for cell_type_id in COPIED_TILE_IDs:
		var cells = base_map.get_used_cells_by_id(cell_type_id)
		for cell in cells:
			set_cell(cell.x, cell.y, cell_type_id)
