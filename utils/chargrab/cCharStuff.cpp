#include <cCharStuff.h>
#include <assert.h>

static uint32_t mkCol(uint8_t _r, uint8_t _g, uint8_t _b) {
	return _r + (_g << 8) + (_b << 16);
}

cChar::cChar(void) {
	for (int f=0;f<WIDTH*HEIGHT; f++)
		mPixels[f] = mkCol(0xff, 0x00,0xff);
}

bool cChar::operator==(cChar const & _rhs) const {
	bool isEqual = true;
	for (int f=0; f<WIDTH * HEIGHT && isEqual; f++)
		isEqual = mPixels[f] == _rhs.mPixels[f];
	return isEqual;
}

void cChar::grab(SDL_Surface const & _s, unsigned int _x, unsigned int _y) {
	auto const & format = *_s.format;
	assert(format.BitsPerPixel == 8);
	assert(format.BytesPerPixel == 3);
	assert(format. palette == nullptr);

	auto pitch = _s.pitch;

	for(int y = 0; y< WIDTH; y++) {
		auto ty = y + _y;
		uint8_t const * ptr =(uint8_t const *) (_s.pixels) + ( pitch * ty) + 3 * _x;
		
		for(int x = 0 ; x <WIDTH; x++)
			uint32_t p = mkCol(ptr[0], ptr[1],ptr[2]);
	}
}

unsigned int cCharSet::addChar(cChar const & _char)
{
	int index = -1;

	for(int f=0; f<mChars.size() && index == -1; f++) {
		if (_char == mChars[f])
			index = f;
	}

	if (index == -1) {
		index = mChars.size();
		mChars.push_back(_char);
	}

	return index;
}

cScreen::cScreen(SDL_Surface const & _s) {
	for (int x=0; x<WIDTH; x+=CWIDTH) {
		for(int y =0; y<HEIGHT; y+=CHEIGHT) {
			cChar thisChar;
			thisChar.grab(_s, x, y);
			mScreen[x + y * WIDTH] = mCharSet.addChar(thisChar);
		}
	}
}


