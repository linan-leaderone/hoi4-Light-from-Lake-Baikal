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
			float2 vDiff = 0.5f - v.vTexCoord0;
			float vAngle = (atan2( vDiff.x, vDiff.y ) + 3.14159265f);
			
			float firstPoint = floor(CurrentState * 100.f) / 100.f;
			float secondPoint = floor((CurrentState * 10000.f) - (firstPoint * 10000.f)) / 100.f;
			float thirdPoint = floor((CurrentState * 1000000.f) - (firstPoint * 1000000.f) - (secondPoint * 10000.f)) / 100.f;
			
			float firstAngle = firstPoint * (2 * 3.14159265f);
			float secondAngle = secondPoint * (2 * 3.14159265f);
			float thirdAngle = thirdPoint * (2 * 3.14159265f);
			
			float4 firstTex = tex2D( TextureOne, v.vTexCoord0 );
			if (firstTex.a > 0) {
				if (vAngle < firstAngle || vAngle == firstAngle) {
					return tex2D( TextureTwo, float2(0.15, v.vTexCoord0.y) );
				} else if (vAngle > thirdAngle || vAngle == thirdAngle) {
					return tex2D( TextureTwo, float2(0.9, v.vTexCoord0.y) );
				}
				else {
					if (vAngle < secondAngle || vAngle == secondAngle) {
						return tex2D( TextureTwo, float2(0.4, v.vTexCoord0.y) );
					}
					else {
						return tex2D( TextureTwo, float2(0.65, v.vTexCoord0.y) );
					}
				}
			} 
			else {
				return float4(0,0,0,0);
			}
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

