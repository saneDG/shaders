uniform int scale<
    string label = "Scale";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 20;
    int step = 2;
> = 2;

uniform float4 base_color<
    string label = "Base color";
> = {0.0,1.0,0.0,1.0};

uniform bool monochrome<
    string label = "Monochrome";
> = false;

uniform int character_set<
    string label = "Character set";
    string widget_type = "select";
    int    option_0_value = 0;
    string option_0_label = "Non-letter glyphs";
    int    option_1_value = 1;
    string option_1_label = "Capital letters";
> = 0;

uniform float light_strength<
    string label = "Light Strength";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.0;
    float step = 0.1;
> = 1.0;

float character(int n, float2 p)
{
    p = floor(p * 4.0 + 2.5);
    if (all(greaterThanEqual(p, float2(0.0))) && all(lessThan(p, float2(5.0))))
    {
        int idx = int(p.x + 5.0 * p.y);
        return ((n >> idx) & 1) != 0 ? 1.0 : 0.0;
    }
    return 0.0;
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 resolution = uv_size * uv_scale;
    float2 pixel = v_in.pos.xy;
    float2 uv = pixel / resolution;

    float2 cellSize = float2(scale * 8.0, scale * 8.0);
    float2 cellOrigin = floor(pixel / cellSize) * cellSize;

    float4 c = image.Sample(textureSampler, cellOrigin / resolution);
    float gray = dot(c.rgb, float3(0.3, 0.59, 0.11));

    int charset = clamp(character_set, 0, 1);
    int n = 0;

    if (charset == 0)
    {
        if (gray <= 0.2) n = 4096;
        else if (gray <= 0.3) n = 65600;
        else if (gray <= 0.4) n = 332772;
        else if (gray <= 0.5) n = 15255086;
        else if (gray <= 0.6) n = 23385164;
        else if (gray <= 0.7) n = 15252014;
        else if (gray <= 0.8) n = 13199452;
        else n = 11512810;
    }
    else
    {
        if (gray <= 0.1) n = 0;
        else if (gray <= 0.3) n = 9616687;
        else if (gray <= 0.5) n = 32012382;
        else if (gray <= 0.7) n = 16303663;
        else n = 16301615;
    }

    float2 glyphUV = mod(pixel / (cellSize / 2.0), 2.0) - 1.0;

    float glyph = character(n, glyphUV);

    // 3D lighting - enhanced
    float sx = character(n, glyphUV + float2(0.1, 0.0));
    float sy = character(n, glyphUV + float2(0.0, 0.1));
    float dx = glyph - sx;
    float dy = glyph - sy;

    float3 normal = normalize(float3(dx, dy, 0.5));
    float3 lightDir = normalize(float3(-0.4, -0.4, 1.0));
    float diff = saturate(dot(normal, lightDir));

    float3 viewDir = normalize(float3(0.0, 0.0, 1.0));
    float3 halfVec = normalize(lightDir + viewDir);
    float spec = pow(saturate(dot(normal, halfVec)), 16.0);

    float lighting = 0.3 + diff * 0.6 + spec * 0.6; // Ambient + diffuse + specular
    lighting *= light_strength;

    float3 base = monochrome ? base_color.rgb : c.rgb;
    float3 finalColor = base * lighting * glyph;

    return float4(finalColor, 1.0);
}
