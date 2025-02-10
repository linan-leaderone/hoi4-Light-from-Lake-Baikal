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
		
		VS_OUTPUT main(const VS_INPUT v )
		{
			VS_OUTPUT Out;
		   	Out.vPosition  = mul( WorldViewProjectionMatrix, v.vPosition );
			Out.vTexCoord0  = v.vTexCoord;
			Out.vTexCoord0.y = -Out.vTexCoord0.y;
		
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
			float lowerEnd = (CurrentState * 100.f) * 0.9f;
			float upperEnd = CurrentState;
			if (CurrentState < 0.1f){
				upperEnd = (CurrentState * 100.f) * 1.1f;
			}
			else {
				upperEnd = (CurrentState - 0.1f) * 100.f;
			}
			
			float4 colour = float4(0,0,0,0);
			float4 vOne = vFirstColor;
			float4 vTwo = vSecondColor;
			
			float blurDist = 0.015f;
			float d = (lowerEnd - v.vTexCoord0.x);
			float d2 = (v.vTexCoord0.x - lowerEnd);
			
			if (d < blurDist && d2 < blurDist && CurrentState < 0.1f){
				if (v.vTexCoord0.x < lowerEnd){
					colour = lerp(vOne, vTwo, (d + blurDist) / (blurDist * 2.f));
				}
				else {
					colour = lerp(vTwo, vOne, (d2 + blurDist) / (blurDist * 2.f));
				}
			}
			else if (v.vTexCoord0.x > lowerEnd && CurrentState < 0.1f) {
				colour = vOne;
			}
			else {
				colour = vTwo;
			}
			
			if (v.vTexCoord0.x > upperEnd) {
				return float4(0, 0, 0, 0);
			}
			
			return colour;
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

