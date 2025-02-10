Includes = {
	"buttonstate.fxh"
	"sprite_animation.fxh"
}

PixelShader =
{
	Samplers =
	{
		TextureOne =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
		TextureTwo =
		{
			Index = 1
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
    float2  vTexCoord0 : TEXCOORD0;
};


ConstantBuffer( 0, 0 )
{
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
			float value = CurrentState * 1000000.f;
			float stateNumber = floor(value/10000.f);
			float firstParty = floor(value / 1000.f) - (stateNumber * 10.f);
			float secondParty = floor(value/100.f) - (stateNumber * 100.f) - (firstParty * 10.f);
			float progress = floor(value - (stateNumber * 10000.f) - (firstParty * 1000.f) - (secondParty * 100.f));
			if(progress == 99) {
				secondParty += 1.f;
				progress = 0.f;
			}
			
			float imageHeight = vSecondColor.g * 1000.f;
			float pixelHeight = 1.f/imageHeight;
			
			float relativePixelPos = v.vTexCoord0.y * 100;
			float pixelPos = (mod(relativePixelPos, 3.f)) * 100.f;
			pixelPos = floor(pixelPos);
			
			float4 overlayColour = float4(0,0,0,0.06);
			
			if(v.vTexCoord0.y > 0.515) {
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
			
			if(v.vTexCoord0.y > 0.51 && v.vTexCoord0.y < 0.515) {
				overlayColour = float4(0,0,1,0.06);
			}
			
			float noOfRows = vFirstColor.r * 100.f;
			float noOfColumns = vFirstColor.g * 100.f;
			
			float columnPos = floor((stateNumber - 1.f)/noOfRows);
			float2 iconPos = float2((stateNumber - 1.f) - (columnPos * noOfRows), columnPos);
			float2 iconSize = float2(1.f/noOfRows, 1.f/noOfColumns);
			
			float2 startPos = iconPos * iconSize;
			
			float4 firstPartyColour = tex2D(TextureTwo, float2(((firstParty / 8.f) - 0.01f), 0.0f));
			float4 secondPartyColour = tex2D(TextureTwo, float2(((secondParty / 8.f) - 0.01f), 0.0f));
			float4 Outcolour;
			
			float4 texColor =  tex2D( TextureOne, float2(startPos.x + (v.vTexCoord0.x * iconSize.x), ((columnPos + 1.f) * iconSize.y) - (v.vTexCoord0.y * iconSize.y)));
			if (texColor.a == 0) {
				return float4(0, 0, 0, 0);
			}
			
			float progVar = progress/100.f;
			if (texColor.r > 0.19 && texColor.r < 0.22 && texColor.g < 0.22 && progVar > 0.13f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			} else if (texColor.r > 0.29 && texColor.r < 0.32 && texColor.g < 0.22 && progVar > 0.28f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			} else if (texColor.r > 0.41 && texColor.r < 0.44 && texColor.g < 0.22 && progVar > 0.38f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else if (texColor.r > 0.55 && texColor.r < 0.58 && texColor.g < 0.22 && progVar > 0.48f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else if (texColor.r > 0.68 && texColor.r < 0.72 && texColor.g < 0.22 && progVar > 0.58f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else if (texColor.r > 0.77 && texColor.r < 0.80 && texColor.g < 0.22 && progVar > 0.68f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else if (texColor.r < 0.18 && texColor.g > 0.29 && texColor.g < 0.31 && progVar > 0.78f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else if (texColor.r < 0.18 && texColor.g > 0.41 && texColor.g < 0.44 && progVar > 0.88f) {
				Outcolour = float4(secondPartyColour.r, secondPartyColour.g, secondPartyColour.b, 0.58f);
			}else {
				Outcolour = float4(firstPartyColour.r, firstPartyColour.g, firstPartyColour.b, 0.58f);
			}
			
			if (firstParty == 0 && secondParty == 0) {
				Outcolour = float4 (0,0,0,1);
			}
			
			float4 finalColour = float4(0,0,0,0);
			finalColour.a = 1.f - (1.f - Outcolour.a) * (1.f - overlayColour.a);
			finalColour.r = (overlayColour.r * overlayColour.a / finalColour.a) + (Outcolour.r * Outcolour.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.g = (overlayColour.g * overlayColour.a / finalColour.a) + (Outcolour.g * Outcolour.a * (1 - overlayColour.a) / finalColour.a);
			finalColour.b = (overlayColour.b * overlayColour.a / finalColour.a) + (Outcolour.b * Outcolour.a * (1 - overlayColour.a) / finalColour.a);
			
			return finalColour;
		}
		
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelTexture"
}

