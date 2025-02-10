Includes = {
}

PixelShader =
{
	Samplers =
	{
		TextureOne =
		{
			Index = 0
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		TextureTwo =
		{
			Index = 1
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
	}
}


VertexStruct VS_INPUT
{
    float4 vPosition  : POSITION;
    float2 vTexCoord  : TEXCOORD0;
};

VertexStruct VS_OUTPUT
{
    float4  vPosition : PDX_POSITION;
    float2  vTexCoord0 : TEXCOORD0;
};


ConstantBuffer( 0, 0 )
{
	float4x4 WorldViewProjectionMatrix; 
	float4 vFirstColor;
	float4 vSecondColor;
	float CurrentState;
};


VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT main(const VS_INPUT v ) {
			VS_OUTPUT Out;
		   	Out.vPosition  = mul( WorldViewProjectionMatrix, v.vPosition );
			Out.vTexCoord0  = v.vTexCoord;
		
			return Out;
		}
		
	]]
}

PixelShader =
{
	MainCode PixelColor
	[[
		
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			if( v.vTexCoord0.x <= CurrentState )
				return vFirstColor;
			else
				return vSecondColor;
		}
	]]

	MainCode PixelTexture
	[[
		
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float input = CurrentState * 2000000.f;
			float yDiff = mod(input, 1000);
			float xDiff = (mod(input, 1000000) - yDiff) / 1000.f;

			float2 p1 = float2(0, 0.f);
            float2 p2 = float2(xDiff * 10.f, yDiff * 10.f);

			if (CurrentState > 0.5f) {
				p1 = float2(xDiff * 10.f, 0.f);
				p2 = float2(0.f, yDiff * 10.f);
			}

            float2 currentP = float2(10000.f * v.vTexCoord0.x, 10000.f - 10000.f * v.vTexCoord0.y);
			
            float lineWidth = vSecondColor.r * 10.f;
           	float gap = vSecondColor.g * 100.f;

            float2 lineDir = p2 - p1;
            float2 perpDir = float2(lineDir.y, -lineDir.x);

            float2 dir1 = p1 + float2(0.f, 0.f) - currentP;
            float dist = abs(dot(normalize(perpDir), dir1));

            if (currentP.y > max(p1.y, p2.y) || currentP.y < min(p1.y, p2.y)) {
                dist = max(dist, min(abs(p1.y - currentP.y), abs(p2.y - currentP.y)));
            }

            float4 toRet = float4(vFirstColor.r, vFirstColor.g, vFirstColor.b, 1);
			if (mod(distance(p1, currentP), gap) < gap / 2.f) {
				toRet = float4(0, 0, 0, 1);
			}


            float intensity = saturate((lineWidth - dist) / 1.4f);
            float shadowIntensity = saturate((lineWidth + 1.5f - dist) / 1.4f);

            toRet.a *= intensity;

            float4 black = float4(0, 0, 0, 1);
			black.a *= shadowIntensity;
			
			float3 mixed = toRet.rgb * toRet.a + black.rgb * (1 - toRet.a) * black.a;
			return float4(mixed.r, mixed.g, mixed.b, vFirstColor.a * (toRet.a + (1 - toRet.a) * black.a));
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}


Effect Color
{
	VertexShader = "VertexShader"
	PixelShader = "PixelColor"
}

Effect Texture
{
	VertexShader = "VertexShader"
	PixelShader = "PixelTexture"
}

