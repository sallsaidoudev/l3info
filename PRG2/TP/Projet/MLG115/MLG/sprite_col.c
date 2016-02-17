/* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA */

#include <stdio.h>

#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/bigarray.h>
#include <caml/custom.h>

#ifdef USE_GLSDL
#define HAVE_OPENGL
#include <glSDL.h>
#else
#include <SDL.h>
#endif

/* getpixel & putpixel shamelessly stolen from SDL.
   TODO optimize it by moving the switch outside the for */

static __inline__ Uint32 colgetpixel(SDL_Surface *surface, int x, int y) {
  int bpp = surface->format->BytesPerPixel;
  Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;
  //  printf ("%i",bpp);
  switch(bpp) {
  case 1: return *p;
  case 2: return *(Uint16 *)p;
  case 3: {
    unsigned int shift;
    Uint32 color=0;
    shift = surface->format->Rshift;
    color = *(p+shift/8)<<shift;
    shift = surface->format->Gshift;
    color|= *(p+shift/8)<<shift;
    shift = surface->format->Bshift;
    color|= *(p+shift/8)<<shift;
    shift = surface->format->Ashift;
    color|= *(p+shift/8)<<shift;
    return color;
  }
  case 4: return *(Uint32 *)p;
  default:
    return 0;       /* shouldn't happen, but avoids warnings */
  }
}

static __inline__ void colputpixel(SDL_Surface *surface, int x, int y, Uint32 pixel)
{
  int bpp = surface->format->BytesPerPixel;
  Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp;

  switch(bpp) {
  case 1: *p = pixel;
    break;
  case 2: *(Uint16 *)p = pixel;
    break;
  case 3:
    if(SDL_BYTEORDER == SDL_BIG_ENDIAN) {
      p[0] = (pixel >> 16) & 0xff;
      p[1] = (pixel >> 8) & 0xff;
      p[2] = pixel & 0xff;
    } else {
      p[0] = pixel & 0xff;
      p[1] = (pixel >> 8) & 0xff;
      p[2] = (pixel >> 16) & 0xff;
    }
    break;
  case 4: *(Uint32 *)p = pixel;
    break;
  }
}



typedef void (*sdl_finalizer)(void *);

struct ml_sdl_surf_data {
  SDL_Surface *s ;
  int freeable;
  sdl_finalizer finalizer;
  void *finalizer_data;
};

static __inline__ SDL_Surface *SDL_SURFACE(value v) {
  struct ml_sdl_surf_data *cb_data;
  cb_data = (Tag_val(v) == 0) ?
    Data_custom_val(Field(v, 0)) : Data_custom_val(v);
  return cb_data->s;
}

value ml_collision(value surf1, value surf2, value param_x, value param_y,
    value alpha_bias) {
  SDL_Surface *s1 = SDL_SURFACE(surf1);
  SDL_Surface *s2 = SDL_SURFACE(surf2);
  value ret = Val_false;
  int minx = Int_val(Field(param_x, 0));
  int maxx = Int_val(Field(param_x, 1));
  int s1x = Int_val(Field(param_x, 2));
  int s2x = Int_val(Field(param_x, 3));
  int miny = Int_val(Field(param_y, 0));
  int maxy = Int_val(Field(param_y, 1));
  int s1y = Int_val(Field(param_y, 2));
  int s2y = Int_val(Field(param_y, 3));
  int bias = Int_val(alpha_bias);
  /* Uint8 r, g, b, a; */
  Uint32 pixel1;
  Uint32 pixel2;
  Uint32 pink1 = SDL_MapRGB(s1->format, 255, 0, 255);
  Uint32 pink2 = SDL_MapRGB(s2->format, 255, 0, 255);
  Uint32 mask1 = s1->format->Rmask + s1->format->Gmask + s1->format->Bmask;
  Uint32 mask2 = s2->format->Rmask + s2->format->Gmask + s2->format->Bmask;
  int bx, by;
  SDL_LockSurface(s1);
  SDL_LockSurface(s2);
  for (bx = minx; bx <= maxx; ++bx) {
    for (by = miny; by <= maxy; ++by) {
      pixel1 = colgetpixel(s1, bx - s1x, by - s1y);
      pixel2 = colgetpixel(s2, bx - s2x, by - s2y);
      if (((pixel1 & mask1) != pink1) && ((pixel2 & mask2) != pink2)) {
        Uint32 amask1 = s1->format->Amask;
        Uint32 amask2 = s2->format->Amask;
        if (amask1 | amask2) {
          Uint8 a1 = (pixel1 & amask1) >> s1->format->Ashift;
          Uint8 a2 = (pixel2 & amask2) >> s2->format->Ashift;
          if (!amask1) a1 = ((pixel1 & mask1) == pink1) ? 0 : 255;
          if (!amask2) a2 = ((pixel2 & mask2) == pink2) ? 0 : 255;
          /* printf ("{%x}<%3i,%3i>\n", pixel1, a1, a2); */
          if (a1 + a2 > bias) {
            ret = Val_true;
            break;
          }
        } else {
          ret = Val_true;
          break;
        }
      }
    }
    if (ret == Val_true) break;
  }
  SDL_UnlockSurface(s1);
  SDL_UnlockSurface(s2);
  /*  printf ("%i<%i,%i>{%x|%x,%x}<%i,%i>{%x|%x|%x}\n", ret,
          bx-s1x, by-s1y, pixel1, pink1, pixel1 & mask1,
          bx-s2x, by-s2y, pixel2, pink2, pixel2 & mask2);*/
  return ret;
}

value ml_mask_cut(value surf1, value surf2, value param_x, value param_y,
    value alpha_bias) {
  SDL_Surface *s1 = SDL_SURFACE(surf1);
  SDL_Surface *s2 = SDL_SURFACE(surf2);
  int minx = Int_val(Field(param_x, 0));
  int maxx = Int_val(Field(param_x, 1));
  int s1x = Int_val(Field(param_x, 2));
  int s2x = Int_val(Field(param_x, 3));
  int miny = Int_val(Field(param_y, 0));
  int maxy = Int_val(Field(param_y, 1));
  int s1y = Int_val(Field(param_y, 2));
  int s2y = Int_val(Field(param_y, 3));
  int bias = Int_val(alpha_bias);
  Uint32 pixel2;
  Uint32 pink1 = SDL_MapRGBA(s1->format, 255, 0, 255, 0);
  Uint32 pink2 = SDL_MapRGB(s2->format, 255, 0, 255);
  Uint32 mask2 = s2->format->Rmask + s2->format->Gmask + s2->format->Bmask;
  Uint32 amask2 = s2->format->Amask;
  int bx, by;
  SDL_LockSurface(s1);
  SDL_LockSurface(s2);
  /* printf ("<%i,%i><%i,%i>{%i, %i}\n", minx, miny, maxx, maxy, s2x, s2y);*/
  for (bx = minx; bx <= maxx; ++bx) {
    for (by = miny; by <= maxy; ++by) {
      Uint8 a2;
      pixel2 = colgetpixel(s2, bx - s2x, by - s2y);
      a2 = (pixel2 & amask2) >> s2->format->Ashift;
      if (!amask2) a2 = ((pixel2 & mask2) == pink2) ? 0 : 255;
      if (a2 > bias) {
        /* printf ("<%i,%i>%x\n", bx - s2x, by - s2y, pixel2);*/
        colputpixel (s1, bx - s1x, by - s1y, pink1);
      }
    }
  }
  SDL_UnlockSurface(s1);
  SDL_UnlockSurface(s2);
  return Val_unit;
}

#ifdef linux

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netdb.h>

value mlsetnonblock(value socket) {
  int yes = 1;
  setsockopt(Int_val(socket), IPPROTO_TCP, TCP_NODELAY, (char*)&yes, sizeof(yes));
  yes = 16;
  setsockopt(Int_val(socket), IPPROTO_IP, IP_TOS, (char*)&yes, sizeof(yes));
  return Val_unit;
};

#else

value mlsetnonblock(value socket) {
  return Val_unit;
};

#endif
