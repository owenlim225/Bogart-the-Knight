shader_type canvas_item;

// Ensure that the noise texture is marked as a texture uniform.
uniform sampler2D noise;
uniform vec4 line_color_a: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 line_color_b: source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float line_threshold = 0.6;
uniform float inverse_speed = 10.0;
uniform float line_length = 1000.0;
uniform float angle : hint_range(0.0, 360.0) = 0.0;

void fragment() {
    // Corrected the rotation calculation.
    vec2 uv = vec2(
        UV.x * cos(radians(angle)) - UV.y * sin(radians(angle)),
        UV.x * sin(radians(angle)) + UV.y * cos(radians(angle))
    );

    // Corrected the texture lookup and the calculation of the UV coordinates.
    vec4 noise_line = texture(noise, vec2(uv.x / line_length + TIME / inverse_speed, uv.y));

    // Use a step function to determine if the noise value is below the threshold.
    float threshold_step = step(noise_line.r, line_threshold);

    // Use the step result to interpolate between the two colors.
    vec4 color = mix(line_color_a, line_color_b, threshold_step);

    // Assign the color to the fragment.
    COLOR = color;
}