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
			float4 texColor =  tex2D( TextureOne, v.vTexCoord0.xy );
			float2 rounded = round(v.vTexCoord0.xy * 250.f + float2(0.1f, 1500.f));
			int val = mod((rounded.x + rounded.y), 11);

			float4 adjColor1 = tex2D( TextureOne, v.vTexCoord0.xy + float2(3/250.f, 0.f) );
			float4 adjColor2 = tex2D( TextureOne, v.vTexCoord0.xy + float2(-3/250.f, 0.f) );
			float4 adjColor3 = tex2D( TextureOne, v.vTexCoord0.xy + float2(0.f, 3/250.f) );
			float4 adjColor4 = tex2D( TextureOne, v.vTexCoord0.xy + float2(0.f, -3/250.f) );

			if (texColor.a == 0 || adjColor1.a == 0 || adjColor2.a == 0 || adjColor3.a == 0 || adjColor4.a == 0 || val < 7  || CurrentState < 0.05f) {
				return float4(0, 0, 0, 0);
			}
			
			return float4(vSecondColor.r, vSecondColor.g, vSecondColor.b, 0.25f + 0.75f * CurrentState); 
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

