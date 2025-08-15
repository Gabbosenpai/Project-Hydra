shader_type canvas_item;

// Colori personalizzabili
uniform vec4 background_color : source_color = vec4(0.1, 0.1, 0.1, 0.30); // sfondo
uniform vec4 fill_color       : source_color = vec4(0.26, 0.56, 1.00, 1.0); // blu
uniform vec4 glow_color       : source_color = vec4(0.40, 0.70, 1.00, 0.6);
uniform float edge_glow_strength : hint_range(0.0, 1.0) = 0.4;

uniform float wave_speed  : hint_range(0.0, 5.0) = 2.0;
uniform float wave_height : hint_range(0.0, 0.1) = 0.02;

// 0..1
uniform float progress_value : hint_range(0.0, 1.0) = 0.0;

// raggio angoli arrotondati, come % del lato minore (0..0.5 consigliato)
uniform float corner_radius : hint_range(0.0, 0.5) = 0.25;

// maschera rettangolo arrotondato su UV 0..1
float rounded_mask(vec2 uv, float r) {
    vec2 d = min(uv, 1.0 - uv);
    float k = min(d.x, d.y);
    return smoothstep(r - 0.002, r + 0.002, k);
}

void fragment() {
    vec2 uv = UV;
    float p = clamp(progress_value, 0.0, 1.0);

    // Maschera angoli arrotondati
    float mask = rounded_mask(uv, corner_radius);
    if (mask <= 0.0) {
        discard;
    }

    // Base: sfondo
    vec4 col = background_color;

    // Riempimento principale
    float filled = step(uv.x, p);
    col = mix(col, fill_color, filled);

    // Onda e glow solo sul bordo della barra
    float wave = sin(TIME * wave_speed + uv.x * 20.0) * wave_height;
    float edge_wave = smoothstep(p - wave_height, p + wave_height, uv.x + wave);
    col += glow_color * edge_wave * edge_glow_strength;

    // Applica maschera per arrotondamento
    col.a *= mask;

    COLOR = col;
}
