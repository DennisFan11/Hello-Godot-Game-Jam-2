class_name SampleableGradientTexture2D extends GradientTexture2D


var image_cache:Image = null
var pixel_cache = {}

func samp_with_uv(uv: Vector2)-> Color:
	if pixel_cache.has(uv):
		return pixel_cache[uv]
	
	if not image_cache:
		image_cache = get_image()
		pixel_cache.clear()
		#print("re cache")
	image_cache = get_image()
	var fix_uv = uv.clamp(Vector2.ZERO, Vector2.ONE) \
		* Vector2(image_cache.get_size())
	
	var ret = image_cache.get_pixelv(fix_uv)
	pixel_cache[uv] = ret
	return ret
