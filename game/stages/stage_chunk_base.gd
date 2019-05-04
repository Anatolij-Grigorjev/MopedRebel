extends Node2D


var chunk_edge_left
var chunk_edge_right


func _ready():
	
	F.assert_not_null(chunk_edge_left)
	F.assert_not_null(chunk_edge_right)
	
	chunk_edge_left.connect("body_entered", self, "_on_body_entered_chunk_edge_left")
	chunk_edge_left.connect("body_exited", self, "_on_body_exited_chunk_edge_left")
	chunk_edge_right.connect("body_entered", self, "_on_body_entered_chunk_edge_right")
	chunk_edge_right.connect("body_exited", self, "_on_body_exited_chunk_edge_right")
	pass
	
	
func _on_body_entered_chunk_edge_left(body):
	if (_body_at_area_left(chunk_edge_left, body)):
		#body just entered this stage chunk
		S.emit_signal3(S.SIGNAL_BODY_ENTERING_CHUNK, body, chunk_idx, C.FACING.RIGHT)
	else:
		#body leaving this stage chunk
		S.emit_signal3(S.SIGNAL_BODY_LEAVING_CHUNK, body, chunk_idx, C.FACING.LEFT)

func _on_body_exited_chunk_edge_left(body):
	if (_body_at_area_left(chunk_edge_left, body)):
		#body fully exited stage chunk
		S.emit_signal3(S.SIGNAL_BODY_LEFT_CHUNK, body, chunk_idx, C.FACING.LEFT)
	else:
		#body fully entered stage chunk
		S.emit_signal3(S.SIGNAL_BODY_ENTERED_CHUNK, body, chunk_idx, C.FACING.RIGHT)

func _on_body_entered_chunk_edge_right(body):
	if (_body_at_area_left(chunk_edge_right, body)):
		#body exiting stage chunk
		S.emit_signal3(S.SIGNAL_BODY_LEAVING_CHUNK, body, chunk_idx, C.FACING.RIGHT)
	else:
		#body entered stage chunk
		S.emit_signal3(S.SIGNAL_BODY_ENTERING_CHUNK, body, chunk_idx, C.FACING.LEFT)
			
func _on_body_exited_chunk_edge_right(body):
	if (_body_at_area_left(chunk_edge_right, body)):
		#body fully exited stage chunk
		S.emit_signal3(S.SIGNAL_BODY_ENTERED_CHUNK, body, chunk_idx, C.FACING.LEFT)
	else:
		#body fully entered stage chunk
		S.emit_signal3(S.SIGNAL_BODY_LEFT_CHUNK, body, chunk_idx, C.FACING.RIGHT)
		

func _body_at_area_left(area, body):
	var area_collider = area.get_node('collider')
	var area_shape_center_position = (
		area_collider.global_position + 
		area_collider.shape.extents
	)
	return body.global_position.x < area_shape_center_position.x
