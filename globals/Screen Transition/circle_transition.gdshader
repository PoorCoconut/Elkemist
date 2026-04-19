shader_type canvas_item;

/** Circle position in [0, 1]² */
uniform vec2 _CirclePosition = vec2(0.5);
/** Progress of the transition */
uniform float _Progress : hint_range(0.0, 1.0, 0.01) = 0.0;
/** Edge smoothness of the circle (not visible at the end) */
uniform float _Smoothness : hint_range(0.0, 0.1, 0.01) = 0.03;
/** Background color of the transition */
uniform vec3 _Background : source_color;

const float _Ratio = 1.77777;

void fragment()
{
	float r = _Ratio;
	vec2 position = _CirclePosition * vec2(r, 1.0);
	vec2 new_uv = UV * vec2(r, 1.0);
	
	float far_x = float(_CirclePosition.x < 0.5) * r;
	float far_y = float(_CirclePosition.y < 0.5);
	float r_max = distance(position, vec2(far_x,far_y));
	
	// FIX 1: Clamp the progress to prevent animation overshoots from creating negative numbers
	float safe_progress = clamp(_Progress, 0.0, 1.0);
	float new_progress = r_max * (1.0 - safe_progress);
	
	// FIX 2: Replace the dangerous `mix()` function.
	// Multiplying by new_progress preserves the original author's intent (fading out the smoothness at the end)
	// The max(..., 0.0001) prevents Division by Zero errors when the circle shrinks to nothing
	float safe_smoothness = max(_Smoothness * new_progress, 0.0001);
	float f = new_progress + safe_smoothness;
	
	float mask = smoothstep(new_progress, f, distance(new_uv, position));

	COLOR = vec4(_Background, mask);
}