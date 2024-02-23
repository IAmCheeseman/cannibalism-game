uniform vec4 redChannel;
uniform vec4 greenChannel;
uniform vec4 blueChannel;

vec4 effect(vec4 _, Image tex, vec2 uv, vec2 pixelUv) {
  vec4 texColor = Texel(tex, uv);

  vec4 color = vec4(0.);

  color = mix(color, redChannel * texColor.r, float(texColor.r != 0.));
  color = mix(color, greenChannel * texColor.g, float(texColor.g != 0.));
  color = mix(color, blueChannel * texColor.b, float(texColor.b != 0.));

  return color;
}

