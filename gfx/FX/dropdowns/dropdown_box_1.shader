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
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
			float vTime = (Time - AnimationTime);
			float value = (Offset.x * 1.f) + 1.f;
			float commaVal = floor(value/10000.f);
			float position = floor(value/100.f) - (commaVal * 100.f);
			float total = value - (commaVal * 10000.f) - (position * 100.f);
			if(commaVal == 1) {
				position = (total - position) + 1.f;
			}
			float yPos = 1.f - (position/total);
			float yGap = -sin(vTime * 2.f) * total;
			float pos = floor(yGap);
			yGap = yGap - floor(yGap);
			float startPos;
			float yTexCoord = (yGap + v.vTexCoord.y);
			if(commaVal == 1) {
				yTexCoord = (v.vTexCoord.y - yGap);
			}
			startPos = ((position - 1.f)/(total));
			if(vTime > 0.75) {
				return tex2D( MapTexture, float2(v.vTexCoord.x + startPos, v.vTexCoord.y) );
			}
			startPos += (1.f - (-pos/total));
			if(yTexCoord < 0 && commaVal == 1) {
				startPos += 1.f/total;
				yTexCoord = yTexCoord + 1.f;
			}
			if(yTexCoord > 1 && commaVal == 0) {
				startPos += 1.f/total;
				yTexCoord = yTexCoord - 1.f;
			}
			if(startPos >= 1) {
				return float4(0,0,0,0);
			}
			OutColor = tex2D( MapTexture, float2(v.vTexCoord.x + startPos, yTexCoord) );
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
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
			float vTime = (Time - AnimationTime);
			float value = (Offset.x * 1.f) + 1.f;
			float commaVal = floor(value/10000.f);
			float position = floor(value/100.f) - (commaVal * 100.f);
			float total = value - (commaVal * 10000.f) - (position * 100.f);
			if(commaVal == 2) {
				return float4(0,0,0,0);
			}
			if(commaVal == 1) {
				position = (total - position) + 1.f;
			}
			float yPos = 1.f - (position/total);
			float yGap = -cos(vTime * 2.f) * total;
			float pos = floor(yGap);
			yGap = yGap - floor(yGap);
			float startPos;
			float yTexCoord = (yGap + v.vTexCoord.y);
			if(commaVal == 1) {
				yTexCoord = (v.vTexCoord.y - yGap);
			}
			startPos = ((position - 1.f)/(total));
			
			if(vTime > 0.75) {
				return float4(0,0,0,0);
			}
			startPos += (1.f - (-pos/total));
			if(yTexCoord < 0 && commaVal == 1) {
				startPos += 1.f/total;
				yTexCoord = yTexCoord + 1.f;
			}
			if(yTexCoord > 1 && commaVal == 0) {
				startPos += 1.f/total;
				yTexCoord = yTexCoord - 1.f;
			}
			if(startPos >= 1) {
				return float4(0,0,0,0);
			}
			OutColor = tex2D( MapTexture, float2(v.vTexCoord.x + startPos, yTexCoord) );
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

