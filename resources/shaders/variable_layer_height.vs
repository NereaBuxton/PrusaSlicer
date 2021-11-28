#version 110

const vec3 LIGHT_TOP_DIR = vec3(-1.0, 0.75, 1.0);
const vec3 LIGHT_BOT_DIR = vec3(-1.0, -0.75, 1.0);
const vec3 LIGHT_BACK_DIR = vec3(0.75, 0.5, -1.0);
#define LIGHT_TOP_DIFFUSE    0.2
#define LIGHT_TOP_SPECULAR   0.1
#define LIGHT_TOP_SHININESS  1.0
#define LIGHT_BACK_DIFFUSE   0.6

#define INTENSITY_AMBIENT    0.4

uniform mat4 volume_world_matrix;
uniform float object_max_z;

// x = tainted, y = specular;
varying vec2 intensity;

varying float object_z;

void main()
{
    // First transform the normal into camera space and normalize the result.
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    
    // Compute the cos of the angle between the normal and lights direction. The light is directional so the direction is constant for every vertex.
    // Since these two are normalized the cosine is the dot product. We also need to clamp the result to the [0,1] range.
    float NdotL = max(dot(normal, LIGHT_TOP_DIR), 0.0);

    intensity.x = INTENSITY_AMBIENT + NdotL * LIGHT_TOP_DIFFUSE;
    vec3 position = (gl_ModelViewMatrix * gl_Vertex).xyz;
    intensity.y = LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_TOP_DIR, normal)), 0.0), LIGHT_TOP_SHININESS);

    NdotL = max(dot(normal, LIGHT_BOT_DIR), 0.0);

    intensity.x += NdotL * LIGHT_TOP_DIFFUSE;
    intensity.y += LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_BOT_DIR, normal)), 0.0), LIGHT_TOP_SHININESS);

    // Perform the same lighting calculation for the 3rd (4th w/ ambient) light source (no specular)
    NdotL = max(dot(normal, LIGHT_BACK_DIR), 0.0);
    
    intensity.x += NdotL * LIGHT_BACK_DIFFUSE;

    // Scaled to widths of the Z texture.
    if (object_max_z > 0.0)
        // when rendering the overlay
        object_z = object_max_z * gl_MultiTexCoord0.y;
    else
        // when rendering the volumes
        object_z = (volume_world_matrix * gl_Vertex).z;
        
    gl_Position = ftransform();
}
