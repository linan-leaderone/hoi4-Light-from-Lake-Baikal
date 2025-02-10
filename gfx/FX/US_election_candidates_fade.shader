Includes = {
	"buttonstate.fxh"
	"sprite_animation.fxh"
}

PixelShader =
{
	Samplers =
	{
		MapTexture =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
			MipMapLodBias = -0.8
		}
		MaskTexture =
		{
			Index = 1
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		AnimatedTexture =
		{
			Index = 2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		MaskTexture2 =
		{
			Index = 3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		AnimatedTexture2 =
		{
			Index = 4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Wrap"
			AddressV = "Wrap"
		}
		#This masking texture is the ACTUAL masking texture. The others are for animation
		MaskingTexture =
		{
			Index = 5
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}




	}
}


VertexStruct VS_OUTPUT
{
	float4  vPosition : PDX_POSITION;
	float2  vTexCoord : TEXCOORD0;
@ifdef ANIMATED
	float4  vAnimatedTexCoord : TEXCOORD1;
@endif
@ifdef MASKING
	float2  vMaskingTexCoord : TEXCOORD2;
@endif
};


VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  = mul( WorldViewProjectionMatrix, float4( v.vPosition.xyz, 1 ) );
		    Out.vTexCoord = v.vTexCoord;
		
		    return Out;
		}
	]]
}

PixelShader =
{
	MainCode PixelShaderUp
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float vTime = (Time - AnimationTime);
			float timeCos = vTime - floor(vTime);
			float firstPort = floor(vTime * 1);
			float timeCheck = floor(vTime * 1);
			float value = (Offset.x * 15.f) + 1.f;
			float lastPort = floor(value/10000.f);
			float penPort = floor(value/100.f) - (lastPort * 100.f);
			float threePort = floor(value - (lastPort * 10000.f) - (penPort * 100.f));
			float firstPortOffset = (firstPort - 1.f)/15.f;
			float secondPortOffset = (firstPort)/15.f;
			if(timeCheck > 5 && timeCheck < 7) {
				firstPortOffset = (5)/15.f;
				secondPortOffset = (threePort - 1.f)/15.f;
			}
			else if(timeCheck > 6 && timeCheck < 8) {
				firstPortOffset = (threePort - 1.f)/15.f;
				secondPortOffset = (penPort - 1.f)/15.f;
			}
			else if(timeCheck > 7 && timeCheck < 9) {
				firstPortOffset = (penPort - 1.f)/15.f;
				secondPortOffset = (lastPort - 1.f)/15.f;
			}
			else if(timeCheck > 8) {
				secondPortOffset = (lastPort - 1.f)/15.f;
				return tex2D( MapTexture, float2(v.vTexCoord.x + secondPortOffset, v.vTexCoord.y) );
			}
			float4 portOne = tex2D( MapTexture, float2(v.vTexCoord.x + firstPortOffset, v.vTexCoord.y) );
			float4 portTwo = tex2D( MapTexture, float2(v.vTexCoord.x + secondPortOffset, v.vTexCoord.y) );
			if(timeCheck == 0) {
				portOne = float4(0,0,0,0);
			}
			
			portOne.a *= (cos(timeCos * 3.14159265) + 1.f)/2.f;
			portTwo.a *= 1.f - portOne.a;
			
			float4 OutColor = float4(0,0,0,0);
			OutColor.a = 1 - (1 - portTwo.a) * (1 - portOne.a);
			OutColor.r = ((portTwo.r * portTwo.a) / OutColor.a) + (portOne.r * portOne.a * (1 - portTwo.a)) / OutColor.a;
			OutColor.g = ((portTwo.g * portTwo.a) / OutColor.a) + (portOne.g * portOne.a * (1 - portTwo.a)) / OutColor.a;
			OutColor.b = ((portTwo.b * portTwo.a) / OutColor.a) + (portOne.b * portOne.a * (1 - portTwo.a)) / OutColor.a;
			
			//if(portOne.r == portTwo.r && portOne.g == portTwo.g && portOne.b == portTwo.b) {
			//	OutColor =  float4(portTwo.r, portTwo.g, portTwo.b, 1.f);
			//}
			
			return OutColor;
		}
	]]

	MainCode PixelShaderDown
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
					
		#ifdef ANIMATED
			OutColor = Animate(OutColor, v.vTexCoord, v.vAnimatedTexCoord, MaskTexture, AnimatedTexture, MaskTexture2, AnimatedTexture2);
		#endif

		#ifdef MASKING
			float4 MaskColor = tex2D( MaskingTexture, v.vTexCoord );
			OutColor.a *= MaskColor.a;
		#endif
			
			OutColor *= Color;

			float vTime = 0.9 - saturate( (Time - AnimationTime) * 16 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    OutColor.rgb -= ( 0.5 + OutColor.rgb ) * MixColor.rgb;

			return OutColor;
		}
	]]

	MainCode PixelShaderDisable
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float value = (Offset.x * 15.f) + 1.f;
			float newOffset = Offset.x;
			if(value > 100) {
				value = floor(value / 100.f);
				value = (value - 1.f)/15.f;
				newOffset = value;
			}
			
			float4 OutColor = tex2D( MapTexture, float2(v.vTexCoord.x + newOffset, v.vTexCoord.y) );
			
		    return OutColor;
		}	
	]]

	MainCode PixelShaderOver
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
				
		#ifdef ANIMATED
			OutColor = Animate(OutColor, v.vTexCoord, v.vAnimatedTexCoord, MaskTexture, AnimatedTexture, MaskTexture2, AnimatedTexture2);
		#endif

		#ifdef MASKING
			float4 MaskColor = tex2D( MaskingTexture, v.vTexCoord );
			OutColor.a *= MaskColor.a;
		#endif

			OutColor *= Color;
			
			float vTime = 0.9 - saturate( (Time - AnimationTime) * 4 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    OutColor.rgb += ( 0.5 + OutColor.rgb ) * MixColor.rgb;
			
			return OutColor;
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDown"
}

Effect Disable
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDisable"
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderOver"
}

