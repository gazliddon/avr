#include <cCharStuff.h>
#include <assert.h>
#include <iostream>

// ----------------------------------------------------------------------------
// Utils
static uint8_t mkCol(uint8_t _r, uint8_t _g, uint8_t _b) {
  _r >>= 6;  _g >>= 6;  _b >>= 6;
  return _r + (_g << 2) + (_b << 4);
}

// ----------------------------------------------------------------------------
// cChar
cChar::cChar(void) {
  mPixels.resize(WIDTH*HEIGHT);
  for (auto & p : mPixels)
    p = mkCol(0xff, 0x00,0xff);
}

bool cChar::operator==(cChar const & _rhs) const {
  bool isEqual = true;

  for (int f=0; f<WIDTH * HEIGHT && isEqual; f++)
    isEqual = mPixels[f] == _rhs.mPixels[f];

  return isEqual;
}

std::vector<uint8_t> const & cChar::getPixels(void) const {
  return mPixels; }

void cChar::dump(void) const {
  using namespace std;
  cout  << hex;;

  for(auto const & p : mPixels )
    cout << p << " ";
  
  cout << endl;
}

void cChar::grab(SDL_Surface const & _s, unsigned int _x, unsigned int _y) {
  auto const & format = *_s.format;
  using namespace std;

  assert(format.BitsPerPixel == 24);
  assert(format.BytesPerPixel == 3);
  assert(format. palette == nullptr);

  auto pitch = _s.pitch;

  for(int y = 0; y< HEIGHT; y++) {
    auto ty = y + _y;
    uint8_t const * ptr =(uint8_t const *) (_s.pixels) + ( pitch * ty) + 3 * _x;

    for(int x = 0 ; x <WIDTH; x++){
      uint32_t p = mkCol(ptr[0], ptr[1],ptr[2]);
      mPixels[x+y*WIDTH] = p;
      ptr+=3;
    }
  }
}

// ----------------------------------------------------------------------------
// cCharSet
unsigned int cCharSet::addChar(cChar const & _char)
{
  bool found = false;
  int index;

  for(index=0; index < mChars.size(); index++) {
    if (_char == mChars[index]) {
      found = true;
      break;
    }
  }
  if (!found) {
    mChars.push_back(_char);
  }

  return index;
}
unsigned int cCharSet::numOfChars(void) const {
  return mChars.size();
}

cChar const & cCharSet::getChar(unsigned int _i) const {
  return mChars[_i];
}

std::vector<cChar> const & cCharSet::getChars() const {
  return mChars; }
// ----------------------------------------------------------------------------
// cScreen
cScreen::cScreen(SDL_Surface const & _s) {
  using namespace std;

  int wInChars = WCHARS;
  int hInChars = HCHARS;
  
  mScreen.resize(WCHARS * HCHARS);

  cChar thisChar;

  for (int x=0; x<wInChars; x++) {
    for(int y =0; y<hInChars; y++) {
      thisChar.grab(_s, x*CWIDTH, y*CHEIGHT);
      set(x, y, mCharSet.addChar(thisChar) );
    }
  }
  cout << "Grabbed " << mCharSet.numOfChars() << endl;
}

void cScreen::set(unsigned int _x, unsigned int _y, uint8_t _c) {
  assert( _x < WCHARS);
  assert( _y < HCHARS);
  mScreen[_x + _y * WCHARS] = _c;
}

cCharSet const & cScreen::charSet(void) const {
  return mCharSet;
}

std::vector<uint8_t> const & cScreen::getScr(void) const {
  return mScreen;
}
  
// ----------------------------------------------------------------------------
// ends
