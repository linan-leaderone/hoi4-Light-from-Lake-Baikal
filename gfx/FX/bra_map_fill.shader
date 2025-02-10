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
			if (CurrentState < 0.01f) {
				return float4(0, 0, 0, 0);
			}

			float4 texColor =  tex2D( TextureOne, v.vTexCoord0.xy );

			float xDimension = vFirstColor.r * 1000.f;
			float yDimension = vFirstColor.g * 1000.f;

			float numParties = vFirstColor.b * 1000.f;

			if (CurrentState == 0) {
				return float4(0, 0, 0, 0);
			}

			float inVal = CurrentState * 10000.f;
			float secondParty = mod(inVal, 100);
			float party = (inVal - secondParty) / 100.f;
			party = mod(party - 1, numParties);
			secondParty = mod(secondParty - 1, numParties);
			
			float2 scale = float2(xDimension, yDimension);

			float2 adjustedSize = v.vTexCoord0.xy * scale + float2(0.1f, 1500.f);

			if (texColor.a == 0) {
				return float4(0, 0, 0, 0);
			}

			float4 partyColor = tex2D(TextureTwo, float2((party + 0.5f) / numParties, 0.0f));
			float4 secondaryPartyColor = tex2D(TextureTwo, float2((secondParty + 0.5f) / numParties, 0.0f));

			float val = mod((adjustedSize.x + adjustedSize.y), 9);

			float overlay = 0.2f;
			float brightness = 0.4f;
			float base = 0.0f;

			float3 blended = texColor.rgb * overlay + partyColor.rgb * (1-overlay);
			if (val < 3) {
				blended = texColor.rgb * overlay + secondaryPartyColor.rgb * (1-overlay);
			}

			return float4(base + blended.r * (1 - base), base + blended.g * (1 - base), base + blended.b * (1 - base), brightness);
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

