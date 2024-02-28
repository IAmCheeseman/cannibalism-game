uniform float whiteness = 0.;

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 screenCoords) {
  vec4 color = Texel(tex, uv);
  return mix(color, vec4(1.), whiteness * color.a);
}
