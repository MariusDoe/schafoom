extends Node2D

var start_velocity_min = 1.0
var start_velocity_max = 1000.0
var max_spin = deg2rad(180)
var gravity = Vector2(0, 500.0)
var lifetime = 5.0

var triangles: Array
var velocities: Array

var timer: float

func _physics_process(delta: float) -> void:
	if triangles:
		move_triangles(delta)
		timer += delta
		if timer > lifetime:
			queue_free()

func create(rect: Rect2, texture: Texture, num_points: int):
	var points = PoolVector2Array()
	points.resize(4 + num_points)
	points[0] = rect.position
	points[1] = rect.position + Vector2(rect.size.x, 0)
	points[2] = rect.position + Vector2(0, rect.size.y)
	points[3] = rect.position + rect.size
	
	for i in range(num_points):
		var x = rand_range(rect.position.x, rect.position.x + rect.size.x)
		var y = rand_range(rect.position.y, rect.position.y + rect.size.y)
		var point = Vector2(x, y)
		points[4 + i] = point
	
	var triangle_indices = Geometry.triangulate_delaunay_2d(points)
	triangles = []
	velocities = []
	for i in range(triangle_indices.size() / 3):
		var vertices = PoolVector2Array()
		vertices.resize(3)
		for j in range(3):
			var vertex_index = triangle_indices[i * 3 + j]
			var vertex = points[vertex_index]
			vertices[j] = vertex
		var triangle = Polygon2D.new()
		triangle.polygon = vertices
		triangle.texture = texture
		add_child(triangle)
		triangles.push_back(triangle)
		var velocity_angle = rand_range(0, TAU)
		var velocity = Vector2(cos(velocity_angle), sin(velocity_angle))
		velocity *= rand_range(start_velocity_min, start_velocity_max)
		velocities.push_back(velocity)
	
	timer = 0.0

func move_triangles(delta: float) -> void:
	for i in range(triangles.size()):
		var triangle = triangles[i] as Polygon2D
		var velocity = velocities[i]
		triangle.translate(velocity * delta)
		velocity += gravity * delta
		velocities[i] = velocity
