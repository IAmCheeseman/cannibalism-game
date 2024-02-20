#define MAX_LIGHTS 64
uniform vec2 screenSize;
uniform vec4 ambientLight;
uniform vec2 lightPositions[MAX_LIGHTS];
uniform vec4 lightColors[MAX_LIGHTS];
uniform float lightRadii[MAX_LIGHTS];
uniform float pointLightTint = 0.4;

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 screenUv) {
  vec4 lightColor = vec4(0.);
  vec2 screen = uv * screenSize;
  for (int i = 0; i < MAX_LIGHTS; i++) {
    vec2 position = floor(lightPositions[i]);
    vec4 color = lightColors[i];
    float radius = lightRadii[i];
    if (radius == 0.) {
      continue;
    }

    float avg = 1 - (lightColor.r + lightColor.g + lightColor.b) / 3;
    float dist = distance(screen, position);
    float strength = max(radius - dist, 0.) / radius;

    float b = (
        ambientLight.r
      + ambientLight.r
      + ambientLight.b
      + ambientLight.g
      + ambientLight.g
      + ambientLight.g) / 6;
    b = pow(1. - b, 2);

    vec4 tinted = mix(color, ambientLight, pointLightTint);
    lightColor = mix(
        lightColor, vec4(tinted.rgb, 1.),
        strength * tinted.a * avg * b);
  }

  return Texel(tex, uv) * (ambientLight + lightColor);
}
