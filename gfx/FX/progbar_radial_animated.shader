Includes = {
	"buttonstate.fxh"
	"sprite_animation.fxh"
	"tno_functions.fxh"
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
		    float value = determineValue(Offset, NextOffset);
			
			float2 vDiff = float2(0.25f - v.vTexCoord.x, v.vTexCoord.y - 0.5f);
			float vAngle = atan2TNO(vDiff) +  3.14159265f;
			
			float start = floor(value/1000.f);
			float end = value - (start * 1000.f);
			float difference = end - start;
			
			
			float fTime = 1.f - (cos(vTime * 6.5f) + 1.f)/2.f;
			float truepoint = (difference * fTime) + start;
			if(vTime > 0.5f){
				truepoint = end;
			}
			truepoint /= 100.f;
			
			float trueAngle = truepoint * 3.14159265f * 2.f;
			
			float4 outColour = float4(0,0,0,0);
			if(vAngle < trueAngle){
				outColour = tex2D( MapTexture, v.vTexCoord.xy );
			}
			else{
				outColour = tex2D( MapTexture, float2(v.vTexCoord.x + 0.5f, v.vTexCoord.y) );
			}
			return outColour;
			//float vLerp = saturate( ( vAngle - truepoint* 3.14159265f * 2.f) * 50.f );
			//float4 vOne = tex2D( MapTexture, v.vTexCoord.xy );
			//float4 vTwo = tex2D( MapTexture, float2(v.vTexCoord.x + 0.5f, v.vTexCoord.y) );
			//return lerp( vOne, vTwo, vLerp );
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
		    float value = determineValue(Offset, NextOffset);
			
			float2 vDiff = float2(0.25f - v.vTexCoord.x, v.vTexCoord.y - 0.5f);
			float vAngle = atan2TNO(vDiff) +  3.14159265f;
			
			float start = floor(value/1000.f);
			float end = value - (start * 1000.f);
			float difference = end - start;
			
			//if(v.vTexCoord.y < 0.5){
			//	return float4(1,1,1,1);
			//}
			
			float fTime = 1.f - (cos(vTime * 6.5f) + 1.f)/2.f;
			float truepoint = (difference * fTime) + start;
			if(vTime > 0.5f){
				truepoint = end;
			}
			truepoint /= 100.f;
			
			float trueAngle = truepoint * 3.14159265f * 2.f;
			
			float4 outColour = float4(0,0,0,0);
			if(vAngle < trueAngle){
				outColour = tex2D( MapTexture, v.vTexCoord.xy );
			}
			else{
				outColour = tex2D( MapTexture, float2(v.vTexCoord.x + 0.5f, v.vTexCoord.y) );
			}
			return outColour;
			//float vLerp = saturate( ( vAngle - truepoint* 3.14159265f * 2.f) * 50.f );
			//float4 vOne = tex2D( MapTexture, v.vTexCoord.xy );
			//float4 vTwo = tex2D( MapTexture, float2(v.vTexCoord.x + 0.5f, v.vTexCoord.y) );
			//return lerp( vOne, vTwo, vLerp );
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