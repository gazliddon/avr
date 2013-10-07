#pragma once

#include <array>
#include <vector>
#include <algorithm>

#if defined(_MSC_VER)
#include <SDL.h>
#else
#include <SDL2/SDL.h>
#endif

// Quick hack code for reprresenting chars / charsets / screens
// Tightly and badly bound to specific dimensions, pixel formats and SDL2 surface :(

class cChar
{
public:
	cChar(void);
	bool operator==(cChar const & _rhs) const;
	void grab(SDL_Surface const & _s, unsigned int _x, unsigned int _y);

private:
	static int const WIDTH = 8;
	static int const HEIGHT = 8;
	std::array<uint32_t, WIDTH * HEIGHT>  mPixels;
};

class cCharSet
{
public:

	unsigned int addChar(cChar const & _char);
	private:
		std::vector<cChar> mChars;
};

class cScreen
{
	public:
		cScreen(SDL_Surface const & _s);
	private:
		static unsigned int const WIDTH = 256;
		static unsigned int const HEIGHT = 224;
		static unsigned int const CWIDTH = 8;
		static unsigned int const CHEIGHT = 8;

		std::array<uint8_t, WIDTH * HEIGHT> mScreen;
		cCharSet mCharSet;
};

