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
  private:
    static int const WIDTH = 8;
    static int const HEIGHT = 8;
    std::vector<uint8_t>  mPixels;

  public:
    cChar(void);
    bool operator==(cChar const & _rhs) const;
    void grab(SDL_Surface const & _s, unsigned int _x, unsigned int _y);
    void dump(void) const;

    std::vector<uint8_t> const & getPixels(void) const; 
};


class cCharSet
{
  public:
    unsigned int addChar(cChar const & _char);
    unsigned int numOfChars(void) const;
    cChar const & getChar(unsigned int _i) const;

    std::vector<cChar> const & getChars() const;

  private:
    std::vector<cChar> mChars;
};

class cScreen
{
  public:
    cScreen(SDL_Surface const & _s);
    cCharSet const & charSet(void) const; 
    std::vector<uint8_t> const & getScr(void) const;
  private:
    static unsigned int const WIDTH = 256;
    static unsigned int const HEIGHT = 224;
    static unsigned int const CWIDTH = 8;
    static unsigned int const CHEIGHT = 8;
    static unsigned int const WCHARS = WIDTH/CWIDTH;
    static unsigned int const HCHARS = HEIGHT/CHEIGHT;

    std::vector<uint8_t> mScreen;
    cCharSet mCharSet;

    void set(unsigned int _x, unsigned int _y, uint8_t _c);

};

