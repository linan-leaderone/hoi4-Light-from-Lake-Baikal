Includes = {
	"tno_functions.fxh"
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
			float2 imageSize = float2(vSecondColor.r * 1000.f, vSecondColor.g * 1000.f);
			float2 cutoffPoint = float2((vFirstColor.r * 1000.f)/imageSize.x, (vFirstColor.g * 1000.f)/imageSize.y);
			
			float inverseCheck = vFirstColor.a * 10.f;
			
			float radius = sqrt(pow(1 - cutoffPoint.x,2) + pow(1 - cutoffPoint.y,2));
			float2 usedTexCoords = v.vTexCoord0;
			if(inverseCheck == 1){
				usedTexCoords.x = 1.f - usedTexCoords.x;
				
				radius = sqrt(pow(cutoffPoint.x,2) + pow(1 - cutoffPoint.y,2));
				cutoffPoint.x = 1.f - cutoffPoint.x;
			}
			float bendLength = 3.14159265f * radius/2.f;
			float length = cutoffPoint.x + cutoffPoint.y + bendLength;
			
			float bendBeforeCutoff = cutoffPoint.x/length;
			float bendAfterCutoff = 1.f - (cutoffPoint.y/length);
			
			
			if(CurrentState < bendBeforeCutoff){
				if(CurrentState > (usedTexCoords.x/length)){
					return tex2D( TextureOne, v.vTexCoord0.xy );
				}
				else{
					return tex2D( TextureTwo, v.vTexCoord0.xy );
				}
			}
			else if(CurrentState > bendAfterCutoff){
				if(CurrentState > (-v.vTexCoord0.y)){
					return tex2D( TextureOne, v.vTexCoord0.xy );
				}
				else{
					return tex2D( TextureTwo, v.vTexCoord0.xy );
				}
			}
			else{
				float curveSection = bendAfterCutoff - bendBeforeCutoff;
				float modCurrent = 1.f - ((CurrentState - bendBeforeCutoff)/curveSection);
				float desiredAngle = (3.f * 3.14159265f/2.f) - (modCurrent * (3.14159265f/2.f));
				float2 TexCoordMod = float2(usedTexCoords.x - cutoffPoint.x, usedTexCoords.y + (1.f - cutoffPoint.y));
				float currentAngle = atan2TNO(TexCoordMod) + 3.14159265f;
				if(currentAngle < desiredAngle){
					return tex2D( TextureOne, v.vTexCoord0.xy );
				}
				else{
					return tex2D( TextureTwo, v.vTexCoord0.xy );
				}
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

