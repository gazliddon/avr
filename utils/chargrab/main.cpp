#include <iostream>

#if defined(_MSC_VER)
#include <SDL.h>
#else
#include <SDL2/SDL.h>
#endif

#include "cCharStuff.h"
#include <assert.h>
#include <string>
#include <sstream>
template<class T>
std::string printBytes(T const & _src)
{
  using namespace std;

  stringstream out;

  const int prWidth = 8;

  for (int i = 0; i < _src.size(); ++i)
  {
    if ((i % prWidth) ==  0)
      out <<  "\n\t.byte\t"; 
    else 
      out << ",";

    out << int(_src[i]);
  }

  return out.str();
}

std::string makeAsm(std::string const & _label, int _align, std::vector<uint8_t> const & _src)
{
  using namespace std;

  stringstream out;
  out << "\t.global\t" << _label << endl;
  out <<  "\t.align\t" << _align  << endl;
  out <<  _label << ":" << endl;
  out << printBytes(_src);
  return out.str();
}

std::ostream & operator<<(std::ostream & _out, cCharSet const & _rhs)
{
  using namespace std;
  auto const & chrs = _rhs.getChars();
  for (cChar const & c : chrs) {
    _out << printBytes(c.getPixels()) << endl;
  }
  return _out;
}

class cLabel
{
  public:
    cLabel(std::string const & _name, int _align = 1) : mAlign(_align), mLabel(_name) {}

    std::ostream & operator << (std::ostream & _out) {
      using namespace std;
      _out << "\t.global\t" << mLabel << endl << mLabel << ":" << endl << "\t.align " << mAlign;
      return _out;
    }

  private:
    std::string         mLabel;
    int                 mAlign;
};


std::vector<uint8_t> test = {1,2,3,4,5,6,7,8,99,10,11,11,12};

int main(int argc, char** argv){
  using namespace std;
  assert(argc == 3);
  auto inFile = argv[1];
  auto outFile = argv[2];

  auto sdlInit =SDL_Init(SDL_INIT_EVERYTHING); 
  assert (sdlInit == 0);

  SDL_Surface *bmp = SDL_LoadBMP( inFile );
  assert(bmp != nullptr);

  cScreen myScr(*bmp);

  SDL_Quit();
  string  x = makeAsm("hello", 8, test);

  cout << x << endl;

  return 0;
}
