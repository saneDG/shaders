float4 mainImage(VertData v_in) : TARGET
{
    float2 p = v_in.uv;
    
	float4 col = image.Sample(textureSampler, p);
	

		float2 offset = float2(.01,.01);
		col.r = image.Sample(textureSampler, p+offset.xy).r;
		col.g = image.Sample(textureSampler, p          ).g;
		col.b = image.Sample(textureSampler, p+offset.yx).b;


    return  col;
}
