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
			Out.vTexCoord0.y = 1.f-Out.vTexCoord0.y;
		
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
			float value = CurrentState * 100000.f;
			float start = round(value / 1000.f) / 100.f;
			float end = (value % 1000.f) / 100.f;
			
			float4 vOne = tex2D( TextureOne,  v.vTexCoord0 );
			float4 vTwo = float4(0,0,0,0);
			
			vOne.a = 1.0f;
			
			float4 color = float4(0,0,0,0);
			
			float2 vPos = float2(v.vTexCoord0.x, v.vTexCoord0.y);
			float midway = ((end - start) * 0.5f + start);
			
			float2 lhsMidpoint = (midway, 0.5f);
			float2 lhsImgPos = (lhsMidpoint - vPos) + float2(midway, 0.5f);

			float rhsMidWay = ((1.0f - end) * 0.5f + end);
			float2 rhsMidpoint = (rhsMidWay, 0.5f);
			float2 rhsImgPos = (rhsMidpoint - vPos) + float2(rhsMidWay, 0.5f);
			
			if (end > start + 0.01f && lhsImgPos.x >= 0.0f && lhsImgPos.x <= 1.0f && lhsImgPos.y >= 0.0f
				&& lhsImgPos.y <= 1.0f && tex2D( TextureTwo, float2(1.f - lhsImgPos.x,1.f - lhsImgPos.y) ).a > 0) {
				vOne.rgb = vOne.rgb * 0.65;
			}
			
			if (end < 1 && rhsImgPos.x >= 0.0f && rhsImgPos.x <= 1.0f && rhsImgPos.y >= 0.0f
				&& rhsImgPos.y <= 1.0f && tex2D( TextureTwo,  float2(1.f - rhsImgPos.x,1.f - rhsImgPos.y) ).a > 0) {
				vTwo.rgb = vTwo.rgb * 0.65;
			}
			
			if(vPos.x < end) {
				color = vOne;
			}
			else {
				color = vTwo;
			}
			
			return color;
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

