attribute vec3 attPosition;
attribute vec2 attUV;

varying vec2 textureCoordinate;

void main() {
    gl_Position = vec4( attPosition.x, attPosition.y, 0.0, 1.0 );
    // textureCoordinate = vec2( attPosition.x * 0.5 + 0.5, attPosition.y * 0.5 + 0.5 );
    textureCoordinate = attUV;
}
