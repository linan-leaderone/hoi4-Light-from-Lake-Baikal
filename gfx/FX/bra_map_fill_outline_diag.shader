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

			float xDimension = vFirstColor.r * 1000.f;
			float yDimension = vFirstColor.g * 1000.f;

			float numParties = vFirstColor.b * 1000.f;
			float party = mod(CurrentState * 100.f - 1, numParties);

			float2 scale = float2(xDimension, yDimension);

			float2 adjustedSize = v.vTexCoord0.xy * scale;

			if (texColor.a == 0 ) {
				return float4(0, 0, 0, 0);
			}
			
		

			int distance = 2;
			float4 adjColor1 = tex2D( TextureOne, (adjustedSize + float2(distance, 0.f)) / scale );
			float4 adjColor2 = tex2D( TextureOne, (adjustedSize + float2(-distance, 0.f)) / scale );
			float4 adjColor3 = tex2D( TextureOne, (adjustedSize + float2(0.f, distance)) / scale );
			float4 adjColor4 = tex2D( TextureOne, (adjustedSize + float2(0.f, -distance)) / scale );

			float4 adjColor5 = tex2D( TextureOne, (adjustedSize + float2(distance, distance)) / scale );
			float4 adjColor6 = tex2D( TextureOne, (adjustedSize + float2(-distance, distance)) / scale );
			float4 adjColor7 = tex2D( TextureOne, (adjustedSize + float2(-distance, -distance)) / scale );
			float4 adjColor8 = tex2D( TextureOne, (adjustedSize + float2(distance, -distance)) / scale );

			bool foundEdge = adjColor1.a == 0
					|| adjColor2.a == 0
					|| adjColor3.a == 0
					|| adjColor4.a == 0
					|| adjColor5.a == 0
					|| adjColor6.a == 0
					|| adjColor7.a == 0
					|| adjColor8.a == 0;
				
			if (!foundEdge) {
				return float4(0, 0, 0, 0);
			}

			float4 partyColor = tex2D(TextureTwo, float2((party + 0.5f) / numParties, 0.0f));

			return float4(partyColor.r * 0.9f + texColor.r * 0.1f, partyColor.g * 0.9f + texColor.g * 0.1f, partyColor.b * 0.9f + texColor.b * 0.1f, 1); 
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

