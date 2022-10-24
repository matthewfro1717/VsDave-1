package;

import flixel.system.FlxAssets.FlxShader;

/*  VS DAVE AND BAMBI SHADERS IMPLEMENTATION
    ALL OF THIS CODE WAS WROTE BY MTM101, ERIZUR AND T5MPLER (BUGFIXES)

    If you see a SHADERS_ENABLED flag here is because of the following reason:
        Apple deprecated OpenGL support back in 2018, leaving it on version 4.1
        Most shaders here don't support this OpenGL version,
        We would fix the errors and make it cross-compatible with ALL platforms,
        but this would take a lot of time and investigation as support for macOS barely exists.

        We are not trying to bully macOS users to "download other os" with this.
        These are things we are can't fix.
        Sorry for any inconvenience.
*/

class GlitchEffect
{
    public var shader(default,null):GlitchShader = new GlitchShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
    public var Enabled(default, set):Bool = true;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }

    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }
    function set_Enabled(v:Bool):Bool
    {
        Enabled = v;
        shader.uEnabled.value = [Enabled];
        return v;
    }
    
    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }
    
    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}

class DistortBGEffect
{
    public var shader(default,null):DistortBGShader = new DistortBGShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }


    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }
    
    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }
    
    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}


class PulseEffect
{
    public var shader(default,null):PulseShader = new PulseShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
    public var Enabled(default, set):Bool = false;

	public function new():Void
	{
		shader.uTime.value = [0];
        shader.uampmul.value = [0];
        shader.uEnabled.value = [false];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }


    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }

    function set_Enabled(v:Bool):Bool
    {
        Enabled = v;
        shader.uEnabled.value = [Enabled];
        return v;
    }
    
    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }
    
    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}


class InvertColorsEffect
{
    public var shader(default,null):InvertShader = new InvertShader();

}

class BlockedGlitchEffect
{
    public var shader(default, null):BlockedGlitchShader = new BlockedGlitchShader();

    #if SHADERS_ENABLED
    public var time(default, set):Float = 0;
    public var resolution(default, set):Float = 0;
    public var colorMultiplier(default, set):Float = 0;
    public var hasColorTransform(default, set):Bool = false;

    public function new(res:Float, time:Float, colorMultiplier:Float, colorTransform:Bool):Void
    {
        set_time(time);
        set_resolution(res);
        set_colorMultiplier(colorMultiplier);
        set_hasColorTransform(colorTransform);
    }
    public function update(elapsed:Float):Void
    {
        shader.time.value[0] += elapsed;
    }
    public function set_resolution(v:Float):Float
    {
        resolution = v;
        shader.screenSize.value = [resolution];
        return this.resolution;
    }
	function set_hasColorTransform(value:Bool):Bool {
		this.hasColorTransform = value;
        shader.hasColorTransform.value = [hasColorTransform];
        return hasColorTransform;
	}

	function set_colorMultiplier(value:Float):Float {
        this.colorMultiplier = value;
        shader.colorMultiplier.value = [value];
        return this.colorMultiplier;
    }

	function set_time(value:Float):Float {
        this.time = value;
        shader.time.value = [value];
        return this.time;
    }
    #end
}

class DitherEffect
{
    public var shader(default,null):DitherShader = new DitherShader();

    public function new():Void
    {

    }
}

class GlitchShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }')
    #end

    public function new()
    {
       super();
    }
}

class InvertShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    

    vec4 sineWave(vec4 pt)
    {
        return vec4(1.0 - pt.x, 1.0 - pt.y, 1.0 - pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv));
    }')
    #end

    public function new()
    {
       super();
    }
}



class DistortBGShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //gives the character a glitchy, distorted outline
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    vec4 makeBlack(vec4 pt)
    {
        return vec4(0, 0, 0, pt.w);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = makeBlack(texture2D(bitmap, uv)) + texture2D(bitmap,openfl_TextureCoordv);
    }')
    #end

    public function new()
    {
       super();
    }
}


class PulseShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    uniform float uampmul;

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec4 sineWave(vec4 pt, vec2 pos)
    {
        if (uampmul > 0.0)
        {
            float offsetX = sin(pt.y * uFrequency + uTime * uSpeed);
            float offsetY = sin(pt.x * (uFrequency * 2.0) - (uTime / 2.0) * uSpeed);
            float offsetZ = sin(pt.z * (uFrequency / 2.0) + (uTime / 3.0) * uSpeed);
            pt.x = mix(pt.x,sin(pt.x / 2.0 * pt.y + (5.0 * offsetX) * pt.z),uWaveAmplitude * uampmul);
            pt.y = mix(pt.y,sin(pt.y / 3.0 * pt.z + (2.0 * offsetZ) - pt.x),uWaveAmplitude * uampmul);
            pt.z = mix(pt.z,sin(pt.z / 6.0 * (pt.x * offsetY) - (50.0 * offsetZ) * (pt.z * offsetX)),uWaveAmplitude * uampmul);
        }
        return vec4(pt.x, pt.y, pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv),uv);
    }')
    #end

    public function new()
    {
       super();
    }
}

class BlockedGlitchShader extends FlxShader
{
    // https://www.shadertoy.com/view/MlVSD3
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header

    // ---- gllock required fields -----------------------------------------------------------------------------------------
    #define RATE 0.75
    
    uniform float time;
    uniform float end;
    uniform sampler2D imageData;
    uniform vec2 screenSize;
    // ---------------------------------------------------------------------------------------------------------------------
    
    float rand(vec2 co){
      return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
    }
    
    float offset(float blocks, vec2 uv) {
      float shaderTime = time*RATE;
      return rand(vec2(shaderTime, floor(uv.y * blocks)));
    }
    
    void main(void) {
      vec2 uv = openfl_TextureCoordv;
      gl_FragColor = flixel_texture2D(bitmap, uv);
      gl_FragColor.r = flixel_texture2D(bitmap, uv + vec2(offset(64.0, uv) * 0.03, 0.0)).r;
      gl_FragColor.g = flixel_texture2D(bitmap, uv + vec2(offset(64.0, uv) * 0.03 * 0.16666666, 0.0)).g;
      gl_FragColor.b = flixel_texture2D(bitmap, uv + vec2(offset(64.0, uv) * 0.03, 0.0)).b;
    }
    ')
    #end

    public function new()
    {
        super();
    }
}

class DitherShader extends FlxShader
{
    // originaly from https://github.com/hughsk/glsl-dither/blob/master/8x8.glsl
    #if SHADERS_ENABLED
    @:glFragmentSource('
        #pragma header

        float dither(vec2 position, float brightness)
        {
            int x = int(mod(position.x, 8.0));
            int y = int(mod(position.y, 8.0));
            int index = x + y * 8;
        
            float limit = 0.0;
        
            if (x < 8)
            {
                if (index == 0)
                    limit = 0.015625;
                if (index == 1)
                    limit = 0.515625;
                if (index == 2)
                    limit = 0.140625;
                if (index == 3)
                    limit = 0.640625;
                if (index == 4)
                    limit = 0.046875;
                if (index == 5)
                    limit = 0.546875;
                if (index == 6)
                    limit = 0.171875;
                if (index == 7)
                    limit = 0.671875;
                if (index == 8)
                    limit = 0.765625;
                if (index == 9)
                    limit = 0.265625;
                if (index == 10)
                    limit = 0.890625;
                if (index == 11)
                    limit = 0.390625;
                if (index == 12)
                    limit = 0.796875;
                if (index == 13)
                    limit = 0.296875;
                if (index == 14)
                    limit = 0.921875;
                if (index == 15)
                    limit = 0.421875;
                if (index == 16)
                    limit = 0.203125;
                if (index == 17)
                    limit = 0.703125;
                if (index == 18)
                    limit = 0.078125;
                if (index == 19)
                    limit = 0.578125;
                if (index == 20)
                    limit = 0.234375;
                if (index == 21)
                    limit = 0.734375;
                if (index == 22)
                    limit = 0.109375;
                if (index == 23)
                    limit = 0.609375;
                if (index == 24)
                    limit = 0.953125;
                if (index == 25)
                    limit = 0.453125;
                if (index == 26)
                    limit = 0.828125;
                if (index == 27)
                    limit = 0.328125;
                if (index == 28)
                    limit = 0.984375;
                if (index == 29)
                    limit = 0.484375;
                if (index == 30)
                    limit = 0.859375;
                if (index == 31)
                    limit = 0.359375;
                if (index == 32)
                    limit = 0.0625;
                if (index == 33)
                    limit = 0.5625;
                if (index == 34)
                    limit = 0.1875;
                if (index == 35)
                    limit = 0.6875;
                if (index == 36)
                    limit = 0.03125;
                if (index == 37)
                    limit = 0.53125;
                if (index == 38)
                    limit = 0.15625;
                if (index == 39)
                    limit = 0.65625;
                if (index == 40)
                    limit = 0.8125;
                if (index == 41)
                    limit = 0.3125;
                if (index == 42)
                    limit = 0.9375;
                if (index == 43)
                    limit = 0.4375;
                if (index == 44)
                    limit = 0.78125;
                if (index == 45)
                    limit = 0.28125;
                if (index == 46)
                    limit = 0.90625;
                if (index == 47)
                    limit = 0.40625;
                if (index == 48)
                    limit = 0.25;
                if (index == 49)
                    limit = 0.75;
                if (index == 50)
                    limit = 0.125;
                if (index == 51)
                    limit = 0.625;
                if (index == 52)
                    limit = 0.21875;
                if (index == 53)
                    limit = 0.71875;
                if (index == 54)
                    limit = 0.09375;
                if (index == 55)
                    limit = 0.59375;
                if (index == 56)
                    limit = 1.0;
                if (index == 57)
                    limit = 0.5;
                if (index == 58)
                    limit = 0.875;
                if (index == 59)
                    limit = 0.375;
                if (index == 60)
                    limit = 0.96875;
                if (index == 61)
                    limit = 0.46875;
                if (index == 62)
                    limit = 0.84375;
                if (index == 63)
                    limit = 0.34375;
            }
        
            return brightness < limit ? 0.0 : 1.0;
        }
        
        vec3 dither(vec2 position, vec3 color)
        {
            return color * dither(position, dot(color, vec3(0.299, 0.587, 0.114)));
        }
        
        vec4 dither(vec2 position, vec4 color)
        {
            return vec4(color.rgb * dither(position, dot(color.rgb, vec3(0.299, 0.587, 0.114))), 1.0);
        }
        
        void main()
        {
            vec4 daTexture = flixel_texture2D(bitmap, openfl_TextureCoordv);
            gl_FragColor = dither(gl_FragCoord.xy, daTexture);
        }
    ')
    #end
    public function new()
    {
        super();
    }
}
