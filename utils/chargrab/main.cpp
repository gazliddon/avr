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
#include <fstream>

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

static std::string makeAsm(std::string const & _label, int _align, std::vector<uint8_t> const & _src)
{
  using namespace std;

  stringstream out;
  out << "\t.global\t" << _label << endl;
  out <<  _label << ":" << endl;
  out <<  "\t.align\t" << _align  << endl;
  out << printBytes(_src);
  return out.str();
}

template<class STR>
STR & operator<<(STR & _out, cCharSet const & _rhs)
{
  using namespace std;
  auto const & chrs = _rhs.getChars();
  for (cChar const & c : chrs) {
    _out << printBytes(c.getPixels()) << endl;
  }
  return _out;
}

template<class STR>
STR & operator<<(STR & _out, std::vector<uint8_t> const & _table) {
  _out << printBytes(_table) << std::endl;
  return _out;
}

static std::string makeLabel(std::string const & _name, int _align)
{
  using namespace std;
  stringstream out;
  out << "\t.global\t" << _name << endl << _name << ":" << endl << "\t.align " << _align << endl;
  return out.str();
}

int main(int argc, char** argv){

  using namespace std;
  assert(argc == 3);
  string inFile(argv[1]);
  string outFile(argv[2]);

  auto sdlInit =SDL_Init(SDL_INIT_EVERYTHING); 
  assert (sdlInit == 0);

  SDL_Surface *bmp = SDL_LoadBMP( inFile.c_str() );
  assert(bmp != nullptr);

  cScreen myScr(*bmp);

  ofstream outStream(outFile, ofstream::trunc);
  assert(outStream);

  outStream << makeLabel("characters", 8) << myScr.charSet();
  outStream << makeLabel("screen", 8) << myScr.getScr();
  outStream.close();

  SDL_Quit();

  return 0;
}

