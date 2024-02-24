uniform vec2 texSize;
uniform float width;
uniform vec4 outlineColor;

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 screenCoords) {
  vec2 o = vec2(width) / texSize;
  vec4 color = Texel(tex, uv);

  float right = Texel(tex, vec2(uv.x + o.x, uv.y)).a;
  float left  = Texel(tex, vec2(uv.x - o.x, uv.y)).a;
  float down  = Texel(tex, vec2(uv.x, uv.y + o.y)).a;
  float up    = Texel(tex, vec2(uv.x, uv.y - o.y)).a;

  color = mix(color, vec4(outlineColor.rgb, color.a), 1. - right);
  color = mix(color, vec4(outlineColor.rgb, color.a), 1. - left);
  color = mix(color, vec4(outlineColor.rgb, color.a), 1. - down);
  color = mix(color, vec4(outlineColor.rgb, color.a), 1. - up);

  return color;
}
