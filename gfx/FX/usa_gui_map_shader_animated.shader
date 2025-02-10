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
			
			float value = floor((Offset.x) * 53.f) + 1.f;
			float2 trueOffset = float2((floor(value/1000.f))/53.f, Offset.y);
		    Out.vTexCoord = v.vTexCoord;
			Out.vTexCoord += trueOffset;
		
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
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
			
			if(OutColor.a == 0) {
				return float4(0,0,0,0);
			}
			
			float vTime = (Time - AnimationTime);
			
			float changePoint = 3.f/60.f;
			
			float value = floor((Offset.x) * 53.f) + 1.f;
			float stateNumber = floor(value / 1000.f);
			float stateColour = floor(value / 100.f) - (stateNumber * 10.f);
			
			if (stateColour > 1) {
				OutColor = float4(0.357,0.235,0.102,1);
			}
			else {
				OutColor = float4(0.031,0.443,0.427,1);
			}
			
			if ((vTime > changePoint && vTime <= (changePoint * 2.f)) || (vTime > (changePoint * 3.f) && vTime <= (changePoint * 4.f)) || (vTime > (changePoint * 5.f) && vTime <= (changePoint * 6.f))) {
				OutColor = float4(1,1,1,1);
			}
			
			float relativePixelPos = v.vTexCoord.y * 100;
			float pixelPos = (mod(relativePixelPos, 3.f)) * 100.f;
			pixelPos = floor(pixelPos);
			
			float4 overlayColour = float4(0,0,0,0.06);
			
			if(v.vTexCoord.y > 0.515) {
				pixelPos -= 50.f;
				if(pixelPos < 0) {
					pixelPos += 300.f;
				}
			}
			
			if((pixelPos >= 0 && pixelPos <= 50) || (pixelPos >= 150 && pixelPos <= 200)) {
				overlayColour.r = 1.f;
			}
			else if((pixelPos >= 50 && pixelPos <= 100) || (pixelPos >= 200 && pixelPos <= 250)) {
				overlayColour.g = 1.f;
			}
			else if((pixelPos >= 100 && pixelPos <= 150) || (pixelPos >= 250 && pixelPos <= 300)) {
				overlayColour.b = 1.f;
			}else {
			}
			
			if(v.vTexCoord.y > 0.51 && v.vTexCoord.y < 0.515) {
				overlayColour = float4(0,0,1,0.06);
			}
			
			float4 finalColour = float4(0,0,0,0);
			finalColour.a = 1.f - (1.f - OutColor.a) * (1.f - overlayColour.a);
			finalColour.r = (overlayColour.r * overlayColour.a / finalColour.a) + (OutColor.r * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.g = (overlayColour.g * overlayColour.a / finalColour.a) + (OutColor.g * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.b = (overlayColour.b * overlayColour.a / finalColour.a) + (OutColor.b * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			
			return finalColour;
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
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
			float value = floor((Offset.x) * 53.f) + 1.f;
			float otherVal = floor(value/100.f);
			float randomVal = value - (otherVal * 100.f);
			randomVal = (randomVal/100.f) * 2 * 3.14159265;
			float vTime = (sin(((Time - AnimationTime) + randomVal) * 4.f)) + 1.f;
			
			float4 colourOne = float4(0.031,0.443,0.427,0.58);
			float4 colourTwo = float4(0.357,0.235,0.102,0.58);
			
			float difR = (abs(colourTwo.r - colourOne.r)/2.f);
			float difG = (abs(colourTwo.g - colourOne.g)/2.f);
			float difB = (abs(colourTwo.b - colourOne.b)/2.f);
			
			float4 toAdd = float4(colourOne.r + (difR * vTime), colourOne.g - (difG * vTime), colourOne.b - (difB * vTime), 1.f);
			if(OutColor.a == 0) {
				return float4(0,0,0,0);
			}
			if(OutColor.a > 0) {
				OutColor = toAdd;
				OutColor.a = 0.5f;
			}
			
			float relativePixelPos = v.vTexCoord.y * 100;
			float pixelPos = (mod(relativePixelPos, 3.f)) * 100.f;
			pixelPos = floor(pixelPos);
			
			float4 overlayColour = float4(0,0,0,0.06);
			
			if(v.vTexCoord.y > 0.515) {
				pixelPos -= 50.f;
				if(pixelPos < 0) {
					pixelPos += 300.f;
				}
			}
			
			if((pixelPos >= 0 && pixelPos <= 50) || (pixelPos >= 150 && pixelPos <= 200)) {
				overlayColour.r = 1.f;
			}
			else if((pixelPos >= 50 && pixelPos <= 100) || (pixelPos >= 200 && pixelPos <= 250)) {
				overlayColour.g = 1.f;
			}
			else if((pixelPos >= 100 && pixelPos <= 150) || (pixelPos >= 250 && pixelPos <= 300)) {
				overlayColour.b = 1.f;
			}else {
			}
			
			if(v.vTexCoord.y > 0.51 && v.vTexCoord.y < 0.515) {
				overlayColour = float4(0,0,1,0.06);
			}
			
			float4 finalColour = float4(0,0,0,0);
			finalColour.a = 1.f - (1.f - OutColor.a) * (1.f - overlayColour.a);
			finalColour.r = (overlayColour.r * overlayColour.a / finalColour.a) + (OutColor.r * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.g = (overlayColour.g * overlayColour.a / finalColour.a) + (OutColor.g * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.b = (overlayColour.b * overlayColour.a / finalColour.a) + (OutColor.b * OutColor.a * (1 - overlayColour.a) / finalColour.a);
			
			return finalColour;
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

