shader_type canvas_item;

// Colori personalizzabili
uniform vec4 background_color: source_color = vec4(0.1, 0.1, 0.1, 0.3);  // Grigio trasparente
uniform vec4 fill_color: source_color = vec4(0.26, 0.56, 1.0, 1.0);    // Blu Windows 11
uniform vec4 glow_color: source_color = vec4(0.4, 0.7, 1.0, 0.6);     // Glow azzurro
uniform float edge_glow_strength: hint_range(0, 1) = 0.4;             // Intensità del bordo glow
uniform float wave_speed: hint_range(0, 5) = 2.0;                      // Velocità delle onde
uniform float wave_height: hint_range(0, 0.1) = 0.02;                 // Altezza delle onde

uniform float progress_value: hint_range(0.0, 1.0) = 0.0;  // Valore di progresso (0-1)

void fragment() {
    float progress = progress_value;
    
    // Effetto glow ai bordi
    float edge_glow = smoothstep(0.0, 0.05, UV.x) * smoothstep(1.0, 0.95, UV.x);
    vec4 edge_effect = mix(vec4(0.0), glow_color, edge_glow * edge_glow_strength);
    
    // Effetto onda dinamico
    float wave = sin(TIME * wave_speed + UV.x * 20.0) * wave_height * (1.0 - progress);
    float fill_position = UV.x / (progress + 0.0001); // Evita divisione per zero
    
    // Seleziona colore in base al riempimento
    if (progress <= 0.001) {
        COLOR = background_color;
    } else if (fill_position <= 1.0 + wave) {
        COLOR = fill_color + edge_effect;
    } else {
        COLOR = background_color;
    }
}