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
			float4 texColor =  tex2D( TextureOne, v.vTexCoord0.xy );
			if (texColor.a == 0)
				return float4(0, 0, 0, 0);
			float4 progressColor1 = lerp(vSecondColor, vFirstColor, (CurrentState - 0.5) * 2);
			float4 progressColor2 = lerp(vSecondColor, vFirstColor, (CurrentState ) * 2);


			float2 vDiff = 0.5f - v.vTexCoord0;
			float vAngle = atan2( vDiff.x, vDiff.y ) + 3.14159265f;
			
			float vLerp = saturate( ( vAngle - CurrentState* 3.14159265f * 2.f) * 50.f );
			float4 vOne = tex2D( TextureOne, v.vTexCoord0.xy );
			float4 vTwo = tex2D( TextureTwo, v.vTexCoord0.xy );
			if(CurrentState >= 0.5)
				return lerp( progressColor1, vTwo, vLerp );
			else
				return lerp( progressColor2, vTwo, vLerp );
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

