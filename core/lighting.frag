#define MAX_LIGHTS 16

uniform vec2 screenSize;
uniform vec4 ambientLight;
uniform vec2 lightPositions[MAX_LIGHTS];
uniform vec4 lightColors[MAX_LIGHTS];
uniform float lightStrengths[MAX_LIGHTS];
uniform float pointLightTint = 0.4;

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 screenUv) {
  vec4 lightColor = vec4(0.);
  vec2 screen = uv * screenSize;
  for (int i = 0; i < MAX_LIGHTS; i++) {
    vec2 lPos = floor(lightPositions[i]);
    vec4 lColor = lightColors[i];
    float lStrength = lightStrengths[i];
    if (lStrength == 0.) {
      continue;
    }

    float avg = 1 - (lightColor.r + lightColor.g + lightColor.b) / 3;
    float dist = distance(screen, lPos);
    float strength = max(lStrength - dist, 0.) / lStrength;
    vec4 tinted = mix(lColor, ambientLight, pointLightTint);
    lightColor = mix(
        lightColor, vec4(tinted.rgb, 1.),
        strength * tinted.a * avg);
  }

  float avg = (lightColor.r + lightColor.g + lightColor.b) / 3;

  return Texel(tex, uv) * (ambientLight + lightColor);
}
