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
			float value = CurrentState * 1000000.f;
			float lowerEnd = floor(value/1000.f);
			float upperEnd = value - (lowerEnd * 1000.f);
			
			float4 colour = float4(0,0,0,0);
			float4 vOne = tex2D( TextureOne, v.vTexCoord0);
			float4 vTwo = tex2D( TextureTwo, v.vTexCoord0);
			float4 blank = float4(0,0,0,0);
			
			lowerEnd /= 100.f;
			upperEnd /= 100.f;
			
			float blurDist = 0.015f;
			float d = (lowerEnd - v.vTexCoord0.y);
			float d2 = (v.vTexCoord0.y - lowerEnd);
			
			float blurDist2 = 0.015f;
			float d1 = (upperEnd - v.vTexCoord0.y);
			float d12 = (v.vTexCoord0.y - upperEnd);
			
			if (d < blurDist && d2 < blurDist){
				if (v.vTexCoord0.y < lowerEnd){
					colour = lerp(vTwo, vOne, (d + blurDist) / (blurDist * 2.f));
				}
				else {
					colour = lerp(vOne, vTwo, (d2 + blurDist) / (blurDist * 2.f));
				}
			}
			else if (d1 < blurDist2 && d12 < blurDist2){
				if (v.vTexCoord0.y < upperEnd){
					float dFromPoint = d1 * (0.5f/blurDist2);
					dFromPoint += 0.5f;
					colour = vTwo;
					colour.a = dFromPoint;
				}
				else {
					float dFromPoint = d12 * (0.5f/blurDist2);
					dFromPoint = (1.f - dFromPoint) - 0.5f;
					colour = vTwo;
					colour.a = dFromPoint;
				}
			}
			else if (v.vTexCoord0.y > lowerEnd) {
				colour = vTwo;
			}
			else {
				colour = vOne;
			}
			
			if (v.vTexCoord0.y > upperEnd) {
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

