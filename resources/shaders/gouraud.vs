#version 110

const vec3 LIGHT_TOP_DIR = vec3(-1.0, 0.75, 1.0);
const vec3 LIGHT_BOT_DIR = vec3(-1.0, -0.75, 1.0);
const vec3 LIGHT_BACK_DIR = vec3(0.75, 0.5, -1.0);
#define LIGHT_TOP_DIFFUSE    0.2
#define LIGHT_TOP_SPECULAR   0.1
#define LIGHT_TOP_SHININESS  1.0
#define LIGHT_BACK_DIFFUSE   0.6

#define INTENSITY_AMBIENT    0.4

const vec3 ZERO = vec3(0.0, 0.0, 0.0);

struct SlopeDetection
{
    bool actived;
	float normal_z;
    mat3 volume_world_normal_matrix;
};

uniform mat4 volume_world_matrix;
uniform SlopeDetection slope;

// Clipping plane, x = min z, y = max z. Used by the FFF and SLA previews to clip with a top / bottom plane.
uniform vec2 z_range;
// Clipping plane - general orientation. Used by the SLA gizmo.
uniform vec4 clipping_plane;

// x = diffuse, y = specular;
varying vec2 intensity;

varying vec3 clipping_planes_dots;

varying vec4 model_pos;
varying vec4 world_pos;
varying float world_normal_z;
varying vec3 eye_normal;

void main()
{
	// First transform the normal into camera space and normalize the result.
	eye_normal = normalize(gl_NormalMatrix * gl_Normal);

	// Compute the cos of the angle between the normal and lights direction. The light is directional so the direction is constant for every vertex.
	// Since these two are normalized the cosine is the dot product. We also need to clamp the result to the [0,1] range.
	float NdotL = max(dot(eye_normal, LIGHT_TOP_DIR), 0.0);

	intensity.x = INTENSITY_AMBIENT + NdotL * LIGHT_TOP_DIFFUSE;
	vec3 position = (gl_ModelViewMatrix * gl_Vertex).xyz;
	intensity.y = LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_TOP_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

	NdotL = max(dot(eye_normal, LIGHT_BOT_DIR), 0.0);

	intensity.x += NdotL * LIGHT_TOP_DIFFUSE;
	intensity.y += LIGHT_TOP_SPECULAR * pow(max(dot(-normalize(position), reflect(-LIGHT_BOT_DIR, eye_normal)), 0.0), LIGHT_TOP_SHININESS);

	// Perform the same lighting calculation for the 3rd (4th w/ ambient) light source (no specular applied).
	NdotL = max(dot(eye_normal, LIGHT_BACK_DIR), 0.0);
	intensity.x += NdotL * LIGHT_BACK_DIFFUSE;

    model_pos = gl_Vertex;
    // Point in homogenous coordinates.
    world_pos = volume_world_matrix * gl_Vertex;

    // z component of normal vector in world coordinate used for slope shading
    world_normal_z = slope.actived ? (normalize(slope.volume_world_normal_matrix * gl_Normal)).z : 0.0;

    gl_Position = ftransform();
    // Fill in the scalars for fragment shader clipping. Fragments with any of these components lower than zero are discarded.
    clipping_planes_dots = vec3(dot(world_pos, clipping_plane), world_pos.z - z_range.x, z_range.y - world_pos.z);
}
