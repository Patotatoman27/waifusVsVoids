shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (length(tex_color.rgb) < 0.1) {
        COLOR = vec4(0.0, 1.0, 0.0, tex_color.a); // Rojo con alpha original
    } else {
        COLOR = tex_color;
    }
}