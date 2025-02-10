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
			float blurPos = CurrentState * 100.f;
			float blurDist = 0.1f;
			
			float4 colour = float4(0,0,0,0);
			
			float4 vOne = vFirstColor;
			float4 vTwo = vSecondColor;
			
			float2 vPos = float2(v.vTexCoord0.x, v.vTexCoord0.y);
			
			float d = (CurrentState - vPos.x);
			float d2 = (vPos.x - CurrentState);
			
			float4 texCheck = tex2D(TextureOne, float2(v.vTexCoord0.x,v.vTexCoord0.y));
			
			float4 Overlay = tex2D(TextureTwo, float2(v.vTexCoord0.x,v.vTexCoord0.y));
			
			if (texCheck.a == 0) {
				return float4 (0,0,0,0);
			}
			
			if (d < blurDist && d2 < blurDist ) {
				if (vPos.x < CurrentState) {
					colour = lerp(vTwo, vOne, (d + blurDist) / (blurDist * 2.f));
				} else {
					colour = lerp(vOne, vTwo, (d2 + blurDist) / (blurDist * 2.f));
				}
			}
					
			else if(vPos.x < CurrentState) {
				colour = vOne;
			}
			else {
				colour = vTwo;
			}
			
			float finalRed = (Overlay.r * Overlay.a / 1) + (colour.r * colour.a * (1 - Overlay.a) / 1);
			float finalGreen = (Overlay.g * Overlay.a / 1) + (colour.g * colour.a * (1 - Overlay.a) / 1);
			float finalBlue = (Overlay.b * Overlay.a / 1) + (colour.b * colour.a * (1 - Overlay.a) / 1);
			
			float4 finalColour = float4(finalRed,finalGreen,finalBlue,1);
			
			return finalColour;
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

