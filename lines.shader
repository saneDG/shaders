#ifndef OPENGL
#define mod(x,y) (x - y * floor(x / y))
#endif
float4 mainImage(VertData v_in) : TARGET
{
	float4 fragColor = float4(0.0,0.0,0.0,1.0);

    float blocksize = 5.0 + uv_size.y / 25.0;
    float2 within_block = mod((v_in.uv * uv_size).xy, blocksize) - float2(0.5 * blocksize,0.5 * blocksize);
    float2 block = (v_in.uv * uv_size).xy - within_block;
	float2 uv = block.xy / uv_size;
	float2 flow  = image.Sample(textureSampler, uv, 2.0).rg - float2(0.5,0.5);
    float lineness = abs(dot(normalize(flow.yx * float2(-1.0, 1.0)), within_block)); //  / dot(flow, flow);
    float alongness = (dot(flow, within_block)/blocksize);
    float dark = smoothstep(0.2 * blocksize, 0.0, lineness) *
        step(alongness, dot(flow, flow)) * step(0.0, alongness);
    float ballness = smoothstep(3.0, 1.0, dot(within_block, within_block));
    if (dot(flow, flow) < 1.0e-6) {
        fragColor = float4(float3(ballness,ballness,ballness), 1.0);
    } else {
	    return  float4(float3(dark + ballness,dark + ballness,dark + ballness), 1.0);
	}
}
