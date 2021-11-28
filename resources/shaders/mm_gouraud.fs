#version 110

const vec3 LIGHT_TOP_DIR = vec3(-1.0, 0.75, 1.0);
const vec3 LIGHT_BOT_DIR = vec3(-1.0, -0.75, 1.0);
const vec3 LIGHT_BACK_DIR = vec3(0.75, 0.5, -1.0);
#define LIGHT_TOP_DIFFUSE    0.2
#define LIGHT_TOP_SPECULAR   0.1
#define LIGHT_TOP_SHININESS  1.0
#define LIGHT_BACK_DIFFUSE   0.6

#define INTENSITY_AMBIENT    0.4

const vec3  ZERO    = vec3(0.0, 0.0, 0.0);
const float EPSILON = 0.0001;

uniform vec4 uniform_color;

varying vec3 clipping_planes_dots;
varying vec4 model_pos;

uniform bool volume_mirrored;

void main()
{
    if (any(lessThan(clipping_planes_dots, ZERO)))
        discard;
    vec3  color = uniform_color.rgb;
    float alpha = uniform_color.a;

    vec3 triangle_normal = normalize(cross(dFdx(model_pos.xyz), dFdy(model_pos.xyz)));
#ifdef FLIP_TRIANGLE_NORMALS
    triangle_normal = -triangle_normal;
#endif

    if (volume_mirrored)
        triangle_normal = -triangle_normal;

    // First transform the normal into camera space and normalize the result.
    vec3 eye_normal = normalize(gl_NormalMatrix * triangle_normal);

    // Compute the cos of the angle between the normal and lights direction. The light is directional so the direction is constant for every vertex.
    // Since these two are normalized the cosine is the dot product. We also need to clamp the result to the [0,1] range.
    float NdotL = max(dot(eye_normal, LIGHT_TOP_DIR), 0.0);

    // x = diffuse, y = specular;
    vec2 intensity = vec2(0.0, 0.0);
    intensity.x = INTENSITY_AMBIENT + NdotL * LIGHT_TOP_DIFFUSE;
    vec3 position = (gl_ModelViewMatrix * model_pos).xyz;
    intensity.y = LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_TOP_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

    NdotL = max(dot(eye_normal, LIGHT_BOT_DIR), 0.0);

    // x = diffuse, y = specular;
    intensity.x += NdotL * LIGHT_TOP_DIFFUSE;
    intensity.y += LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_BOT_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

    // Perform the same lighting calculation for the 3rd (4th w/ ambient) light source (no specular applied).
    NdotL = max(dot(eye_normal, LIGHT_BACK_DIR), 0.0);
    intensity.x += NdotL * LIGHT_BACK_DIFFUSE;

    gl_FragColor = vec4(vec3(intensity.y) + color * intensity.x, alpha);
}
