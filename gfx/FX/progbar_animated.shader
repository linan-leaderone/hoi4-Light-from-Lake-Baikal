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
			
		#ifdef ANIMATED
			//Out.vAnimatedTexCoord = GetAnimatedTexcoord(v.vTexCoord);	
		#endif

		#ifdef MASKING
			A bit hacky, but we want the masking texture coordinates to be in the range [0,1]. We turn all 0's to 0 and all nonzero to 1.
			Out.vMaskingTexCoord = saturate(v.vTexCoord * 1000); 
		#endif
		
		    return Out;
		}
	]]
	
	MainCode VertexShader2
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  = mul( WorldViewProjectionMatrix, float4( v.vPosition.xyz, 1 ) );
		
		    Out.vTexCoord = v.vTexCoord;
			
		#ifdef ANIMATED
			//Out.vAnimatedTexCoord = GetAnimatedTexcoord(v.vTexCoord);	
		#endif

		#ifdef MASKING
			A bit hacky, but we want the masking texture coordinates to be in the range [0,1]. We turn all 0's to 0 and all nonzero to 1.
			Out.vMaskingTexCoord = saturate(v.vTexCoord * 1000); 
		#endif
		
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
		    float value = Offset.x + 1.f;
			float commaVal = floor(value / 1000000.f);
			float endVal = floor(value / 1000.f) - (commaVal * 1000.f);
			float startVal = value - (endVal * 1000.f) - (commaVal * 1000000.f);
			float gap = (endVal - startVal)/100.f;
			float xPos = (startVal/100.f);
			xPos += gap * sin(vTime* 3.f);
			if(commaVal == 0) {
				if (vTime < 0.5) {
					if (v.vTexCoord.x > xPos) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
				}
				else {
					if (v.vTexCoord.x > endVal/100.f) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
				}
			}
			else {
				float LHSgap = startVal;
				float RHSgap = 100.f - endVal;
				if(endVal == 0) {
					endVal = 100.f;
					RHSgap = 100.f - startVal;
				}
				float endLineGap = 100.f - startVal;
				LHSgap *= sin(vTime);
				RHSgap *= sin(vTime);
				endLineGap *= sin(vTime);
				float LHSpos = LHSgap;
				float RHSpos = 100.f - RHSgap;
				float endLinePos = 100.f - endLineGap;
				if (vTime < 1.5) {
					if (v.vTexCoord.x > RHSpos/100.f) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x < LHSpos/100.f) {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x < RHSpos/100.f && v.vTexCoord.x > endLinePos/100.f) {
						return tex2D(MapTexture, float2(0.5 ,v.vTexCoord.y));
					}
					else{
						return float4(0,0,0,0);
					}
				}
				else {
					if(endVal == 100) {
						endVal = startVal;
					}
					if (v.vTexCoord.x < startVal/100.f) {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x > endVal/100.f) {
						return tex2D(MapTexture, float2(0.85 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.5 ,v.vTexCoord.y));
					}
				}
			}
		}
	]]

	MainCode PixelShaderDown
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
					
		#ifdef ANIMATED
			OutColor = Animate(OutColor, v.vTexCoord, v.MapTexture, MapTexture, MapTexture, MapTexture, MapTexture);
		#endif

		#ifdef MASKING
			float4 MaskColor = tex2D( MaskingTexture, v.vTexCoord );
			OutColor.a *= MaskColor.a;
		#endif
			
			OutColor *= Color;

			return OutColor;
		}
	]]

	MainCode PixelShaderDisable
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
			float vTime = (Time - AnimationTime);
		    float value = Offset.x + 1.f;
			float commaVal = floor(value / 1000000.f);
			float endVal = floor(value / 1000.f) - (commaVal * 1000.f);
			float startVal = value - (endVal * 1000.f) - (commaVal * 1000000.f);
			float gap = (endVal - startVal)/100.f;
			float xPos = (startVal/100.f);
			xPos += gap * sin(vTime* 3.f);
			if(commaVal == 0) {
				if (vTime < 0.5) {
					if (v.vTexCoord.x > xPos) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
				}
				else {
					if (v.vTexCoord.x > endVal/100.f) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
				}
			}
			else {
				float LHSgap = startVal;
				float RHSgap = 100.f - endVal;
				if(endVal == 0) {
					endVal = 100.f;
					RHSgap = 100.f - startVal;
				}
				float endLineGap = 100.f - startVal;
				LHSgap *= sin(vTime);
				RHSgap *= sin(vTime);
				endLineGap *= sin(vTime);
				float LHSpos = LHSgap;
				float RHSpos = 100.f - RHSgap;
				float endLinePos = 100.f - endLineGap;
				if (vTime < 1.5) {
					if (v.vTexCoord.x > RHSpos/100.f) {
						return tex2D(MapTexture, float2(0.75 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x < LHSpos/100.f) {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x < RHSpos/100.f && v.vTexCoord.x > endLinePos/100.f) {
						return tex2D(MapTexture, float2(0.5 ,v.vTexCoord.y));
					}
					else{
						return float4(0,0,0,0);
					}
				}
				else {
					if(endVal == 100) {
						endVal = startVal;
					}
					if (v.vTexCoord.x < startVal/100.f) {
						return tex2D(MapTexture, float2(0.25 ,v.vTexCoord.y));
					}
					else if(v.vTexCoord.x > endVal/100.f) {
						return tex2D(MapTexture, float2(0.85 ,v.vTexCoord.y));
					}
					else {
						return tex2D(MapTexture, float2(0.5 ,v.vTexCoord.y));
					}
				}
			}
		}	
	]]

	MainCode PixelShaderOver
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float vTime = (Time - AnimationTime);
		    float value = Offset.x + 1.f;
			float endVal = floor(value / 1000.f);
			float startVal = value - (endVal * 1000.f);
			float gap = (endVal - startVal)/100.f;
			float yPos = 1.f -  (startVal/100.f);
			yPos += gap * sin(vTime);
			float timeCheck = saturate(vTime);
			if (startVal == 5) {
				return float4(1,0,1,1);
			}
			else {
				return float4(1,1,1,1);
			}
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
	VertexShader = "VertexShader2"
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