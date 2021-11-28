#version 110

const vec3 LIGHT_TOP_DIR = vec3(-1.0, 0.75, 1.0);
const vec3 LIGHT_BOT_DIR = vec3(-1.0, -0.75, 1.0);
const vec3 LIGHT_BACK_DIR = vec3(0.75, 0.5, -1.0);
#define LIGHT_TOP_DIFFUSE    0.2
#define LIGHT_TOP_SPECULAR   0.1
#define LIGHT_TOP_SHININESS  1.0
#define LIGHT_BACK_DIFFUSE   0.6

#define INTENSITY_AMBIENT    0.4

// vertex attributes
attribute vec3 v_position;
attribute vec3 v_normal;
// instance attributes
attribute vec3 i_offset;
attribute vec2 i_scales;

// x = tainted, y = specular;
varying vec2 intensity;

void main()
{
    // First transform the normal into camera space and normalize the result.
    vec3 eye_normal = normalize(gl_NormalMatrix * v_normal);
    
    // Compute the cos of the angle between the normal and lights direction. The light is directional so the direction is constant for every vertex.
    // Since these two are normalized the cosine is the dot product. We also need to clamp the result to the [0,1] range.
    float NdotL = max(dot(eye_normal, LIGHT_TOP_DIR), 0.0);

    intensity.x = INTENSITY_AMBIENT + NdotL * LIGHT_TOP_DIFFUSE;
    vec4 world_position = vec4(v_position * vec3(vec2(1.5 * i_scales.x), 1.5 * i_scales.y) + i_offset - vec3(0.0, 0.0, 0.5 * i_scales.y), 1.0);
    vec3 eye_position = (gl_ModelViewMatrix * world_position).xyz;
    intensity.y = LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(eye_position), reflect(-LIGHT_TOP_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

    NdotL = max(dot(eye_normal, LIGHT_BOT_DIR), 0.0);
    intensity.x += NdotL * LIGHT_TOP_DIFFUSE;
    intensity.y += LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(eye_position), reflect(-LIGHT_BOT_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

    // Perform the same lighting calculation for the 3rd (4th w/ ambient) light source (no specular applied).
    NdotL = max(dot(eye_normal, LIGHT_BACK_DIR), 0.0);
    intensity.x += NdotL * LIGHT_BACK_DIFFUSE;

    gl_Position = gl_ProjectionMatrix * vec4(eye_position, 1.0);
}
