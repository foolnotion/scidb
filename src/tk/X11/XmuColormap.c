// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// This source is adopted from Xorg:
// 	CmapAlloc.c
// 	CrCmap.c
// 	DelCmap.c
// 	LookupCmap.c
// 	StdCmap.c
//
// Copyright 1989, 1998  The Open Group
// ======================================================================

#include "X11/XmuColormap.h"

#include <X11/Xatom.h>

#include <stdlib.h>


static unsigned long lowbit(unsigned long x) { return x & (~x + 1); }


void
XmuDeleteStandardColormap(Display* dpy, int screen, Atom property)
{
	XStandardColormap*	stdcmaps;
	XStandardColormap*	s;
	int						count = 0;

	if (XGetRGBColormaps(dpy, RootWindow(dpy, screen), &stdcmaps, &count, property))
	{
		for (s = stdcmaps; count > 0; count--, s++)
		{
			if (	s->killid == ReleaseByFreeingColormap
				&& s->colormap != None
				&& s->colormap != DefaultColormap(dpy, screen))
			{
				XFreeColormap(dpy, s->colormap);
			}
			else if (s->killid != None)
			{
				XKillClient(dpy, s->killid);
			}
		}

		XDeleteProperty(dpy, RootWindow(dpy, screen), property);
		XFree((char*)stdcmaps);
		XSync(dpy, False);
	}
}


static Status
lookup(Display* dpy, int screen, VisualID visualid, Atom property, XStandardColormap* cnew, Bool replace)
{
	int						i;
	int						count;
	XStandardColormap*	stdcmaps;
	XStandardColormap*	s;
	Window					win = RootWindow(dpy, screen);

	// The property does not already exist.

	if (!XGetRGBColormaps(dpy, win, &stdcmaps, &count, property))
	{
		if (cnew)
			XSetRGBColormaps(dpy, win, cnew, 1, property);
		return 0;
	}

	// The property exists and is not describing the RGB_DEFAULT_MAP.

	if (property != XA_RGB_DEFAULT_MAP)
	{
		if (replace)
		{
			XmuDeleteStandardColormap(dpy, screen, property);
			if (cnew)
				XSetRGBColormaps(dpy, win, cnew, 1, property);
		}

		XFree((char*)stdcmaps);
		return 1;
	}

	// The property exists and is RGB_DEFAULT_MAP.

	for (i = 0, s = stdcmaps; i < count && s->visualid != visualid; i++, s++)
		;

	// No RGB_DEFAULT_MAP property matches the given visualid.

	if (i == count)
	{
		if (cnew)
		{
			XStandardColormap* m;
			XStandardColormap* maps;

			s = (XStandardColormap*)malloc((count + 1)*sizeof(XStandardColormap));

			for (i = 0, m = s, maps = stdcmaps; i < count; i++, m++, maps++)
			{
				m->colormap   = maps->colormap;
				m->red_max    = maps->red_max;
				m->red_mult   = maps->red_mult;
				m->green_max  = maps->green_max;
				m->green_mult = maps->green_mult;
				m->blue_max   = maps->blue_max;
				m->blue_mult  = maps->blue_mult;
				m->base_pixel = maps->base_pixel;
				m->visualid   = maps->visualid;
				m->killid     = maps->killid;
			}

			m->colormap   = cnew->colormap;
			m->red_max    = cnew->red_max;
			m->red_mult   = cnew->red_mult;
			m->green_max  = cnew->green_max;
			m->green_mult = cnew->green_mult;
			m->blue_max   = cnew->blue_max;
			m->blue_mult  = cnew->blue_mult;
			m->base_pixel = cnew->base_pixel;
			m->visualid   = cnew->visualid;
			m->killid     = cnew->killid;

			XSetRGBColormaps(dpy, win, s, ++count, property);
			free((char*)s);
		}

		XFree((char*)stdcmaps);
		return 0;
	}

	// Found an RGB_DEFAULT_MAP property with a matching visualid.

	if (replace)
	{
		// Free old resources first - we may need them, particularly in
		// the default colormap of the screen.  However, because of this,
		// it is possible that we will destroy the old resource and fail
		// to create a new one if XmuStandardColormap() fails.

		if (count == 1)
		{
			XmuDeleteStandardColormap(dpy, screen, property);
			if (cnew)
				XSetRGBColormaps(dpy, win, cnew, 1, property);
		}
		else
		{
			XStandardColormap	*map;

			// s still points to the matching standard colormap

			if (s->killid == ReleaseByFreeingColormap)
			{
				if (s->colormap != None && s->colormap != DefaultColormap(dpy, screen))
					XFreeColormap(dpy, s->colormap);
			}
			else if (s->killid != None)
			{
				XKillClient(dpy, s->killid);
			}

			map = cnew ? cnew : stdcmaps + --count;

			s->colormap   = map->colormap;
			s->red_max    = map->red_max;
			s->red_mult   = map->red_mult;
			s->green_max  = map->green_max;
			s->green_mult = map->green_mult;
			s->blue_max   = map->blue_max;
			s->blue_mult  = map->blue_mult;
			s->visualid   = map->visualid;
			s->killid     = map->killid;

			XSetRGBColormaps(dpy, win, stdcmaps, count, property);
		}
	}

	XFree((char*)stdcmaps);
	return 1;
}


static void
gray_allocation(int n, unsigned long* red_max, unsigned long* green_max, unsigned long* blue_max)
{
	*red_max    = (n*30)/100;
	*green_max  = (n*59)/100;
	*blue_max   = (n*11)/100;
	*green_max += (n - 1) - (*red_max + *green_max + *blue_max);
}


static int
icbrt_with_bits(int a, int bits)
{
	int icbrt_with_guess(int a, int guess)
	{
		int delta;

		if (a <= 0)
			return 0;

		if (guess < 1)
			guess = 1;

		do
		{
			delta = (guess - a/(guess*guess))/3;
			guess -= delta;
		}
		while (delta != 0);

		if (guess*guess*guess > a)
			guess--;

		return guess;
	}

	return icbrt_with_guess(a, a >> 2*bits/3);
}


static int
default_allocation(XVisualInfo* vinfo, unsigned long* red, unsigned long* green, unsigned long* blue)
{
	int icbrt(int a)
	{
		int bits = 0;
		unsigned n = a;

		while (n)
		{
			bits++;
			n >>= 1;
		}

		return icbrt_with_bits(a, bits);
	}

	int ngrays;		// number of gray cells

	switch (vinfo->class)
	{
		case PseudoColor:
			if (vinfo->colormap_size > 65000)
			{
				// intended for displays with 16 planes
				*red = *green = *blue = (unsigned long)27;
			}
			else if (vinfo->colormap_size > 4000)
			{
				// intended for displays with 12 planes
				*red = *green = *blue = (unsigned long) 12;
			}
			else if (vinfo->colormap_size < 250)
			{
				return 0;
			}
			else
			{
				// intended for displays with 8 planes
				*red = *green = *blue = icbrt(vinfo->colormap_size - 125) - 1;
			}
			break;

		case DirectColor:
			if (vinfo->colormap_size < 10)
				return 0;
			*red = *green = *blue = vinfo->colormap_size/2 - 1;
			break;

		case TrueColor:
			*red = vinfo->red_mask/lowbit(vinfo->red_mask);
			*green = vinfo->green_mask/lowbit(vinfo->green_mask);
			*blue = vinfo->blue_mask/lowbit(vinfo->blue_mask);
			break;

		case GrayScale:
			if (vinfo->colormap_size > 65000)
				ngrays = 4096;
			else if (vinfo->colormap_size > 4000)
				ngrays = 512;
			else if (vinfo->colormap_size < 250)
				return 0;
			else
				ngrays = 12;
			gray_allocation(ngrays, red, green, blue);
			break;

		default:
			return 0;
	}

	return 1;
}


static void
best_allocation(XVisualInfo* vinfo, unsigned long* red, unsigned long* green, unsigned long* blue)
{
	if (vinfo->class == DirectColor || vinfo->class == TrueColor)
	{
		*red = vinfo->red_mask;
		while ((*red & 01) == 0)
			*red >>= 1;

		*green = vinfo->green_mask;
		while ((*green & 01) == 0)
			*green >>=1;

		*blue = vinfo->blue_mask;
		while ((*blue & 01) == 0)
			*blue >>= 1;
	}
	else
	{
		int bits	= 0;
		int n		= 1;

		// Determine n such that n is the least integral power of 2 which is
		// greater than or equal to the number of entries in the colormap.
		while (vinfo->colormap_size > n)
		{
			n = n << 1;
			bits++;
		}

		// If the number of entries in the colormap is a power of 2, determine
		// the allocation by "dealing" the bits, first to green, then red, then
		// blue.  If not, find the maximum integral red, green, and blue values
		// which, when multiplied together, do not exceed the number of
		// colormap entries.

		if (n == vinfo->colormap_size)
		{
			int b = bits/3;
			int g = b + (bits % 3 ? 1 : 0);
			int r = b + (bits % 3 == 2 ? 1 : 0);

			*red = 1 << r;
			*green = 1 << g;
			*blue = 1 << b;
		}
		else
		{
			*red = icbrt_with_bits(vinfo->colormap_size, bits);
			*blue = *red;
			*green = (vinfo->colormap_size / ((*red) * (*blue)));
		}

		(*red)--;
		(*green)--;
		(*blue)--;
	}
}


Status
XmuGetColormapAllocation(	XVisualInfo* vinfo,
									Atom property,
									unsigned long* red_max,
									unsigned long* green_max,
									unsigned long* blue_max)
{
	Status status = 1;

	if (vinfo->colormap_size <= 2)
		return 0;

	switch (property)
	{
		case XA_RGB_DEFAULT_MAP:
			status = default_allocation(vinfo, red_max, green_max, blue_max);
			break;

		case XA_RGB_BEST_MAP:
			best_allocation(vinfo, red_max, green_max, blue_max);
			break;

		case XA_RGB_GRAY_MAP:
			gray_allocation(vinfo->colormap_size, red_max, green_max, blue_max);
			break;

		case XA_RGB_RED_MAP:
			*red_max = vinfo->colormap_size - 1;
			*green_max = *blue_max = 0;

		break;
			case XA_RGB_GREEN_MAP:
			*green_max = vinfo->colormap_size - 1;
			*red_max = *blue_max = 0;
			break;

		case XA_RGB_BLUE_MAP:
			*blue_max = vinfo->colormap_size - 1;
			*red_max = *green_max = 0;
			break;

		default:
			status = 0;
			break;
	}

	return status;
}


static int
ROmap(Display* dpy, Colormap cmap, unsigned long pixels[], int m, int n)
{
	int p;

	// first try to allocate the entire colormap
	if (XAllocColorCells(dpy, cmap, 1, (unsigned long*)NULL, (unsigned)0, pixels, (unsigned)m))
		return m;

	// Allocate all available cells in the colormap, using a binary
	// algorithm to discover how many cells we can allocate in the colormap.
	m--;

	while (n <= m)
	{
		p = n + ((m - n + 1)/2);

		if (XAllocColorCells(dpy, cmap, 1, (unsigned long*)NULL, (unsigned)0, pixels, (unsigned) p))
		{
			if (p == m)
			{
				return p;
			}
			else
			{
				XFreeColors(dpy, cmap, pixels, p, (unsigned long)0);
				n = p;
			}
		}
		else
		{
			m = p - 1;
		}
	}

	return 0;
}


static Status
contiguous(unsigned long pixels[], int npixels, int ncolors, unsigned long delta, int* first, int* rem)
{
	int i			= 1;	// walking index into the pixel array
	int count	= 1;	// length of sequence discovered so far

	*first = 0;

	if (npixels == ncolors)
	{
		*rem = 0;
		return 1;
	}

	*rem = npixels - 1;

	while (count < ncolors && ncolors - count <= *rem)
	{
		if (pixels[i-1] + delta == pixels[i])
		{
			count++;
		}
		else
		{
			count = 1;
			*first = i;
		}

		i++;
		(*rem)--;
	}

	if (count != ncolors)
		return 0;

	return 1;
}


static void
free_cells(Display* dpy, Colormap cmap, unsigned long pixels[], int npixels, int p)
{
	// One of the npixels allocated has already been freed.
	// p is the index of the freed pixel.
	// First free the pixels preceeding p, and there are p of them;
	// then free the pixels following p, there are npixels - p - 1 of them.
	XFreeColors(dpy, cmap, pixels, p, (unsigned long)0);
	XFreeColors(dpy, cmap, &(pixels[p+1]), npixels - p - 1, (unsigned long)0);
	free((char*)pixels);
}


static Status
RWcell(Display* dpy, Colormap cmap, XColor* color, XColor* request, unsigned long *pixel)
{
	unsigned long n = *pixel;

	XFreeColors(dpy, cmap, &(color->pixel), 1, (unsigned long)0);

	if (!XAllocColorCells(dpy, cmap, (Bool)0, (unsigned long*) NULL, (unsigned)0, pixel, (unsigned)1))
		return 0;

	if (*pixel != n)
	{
		XFreeColors(dpy, cmap, pixel, 1, (unsigned long)0);
		return 0;
	}

	color->pixel = *pixel;
	color->flags = DoRed | DoGreen | DoBlue;
	color->red = request->red;
	color->green = request->green;
	color->blue = request->blue;
	XStoreColors(dpy, cmap, color, 1);

	return 1;
}


static Status
ROorRWcell(	Display* dpy,
				Colormap cmap,
				unsigned long pixels[],
				int npixels,
				XColor* color,
				unsigned long p)
{
	unsigned long	pixel;
	XColor			request;

	// Free the read/write allocation of one cell in the colormap.
	// Request a read only allocation of one cell in the colormap.
	// If the read only allocation cannot be granted, give up, because
	// there must be no free cells in the colormap.
	// If the read only allocation is granted, but gives us a cell which
	// is not the one that we just freed, it is probably the case that
	// we are trying allocate White or Black or some other color which
	// already has a read-only allocation in the map.  So we try to
	// allocate the previously freed cell with a read/write allocation,
	// because we want contiguous cells for image processing algorithms.

	pixel = color->pixel;
	request.red = color->red;
	request.green = color->green;
	request.blue = color->blue;

	XFreeColors(dpy, cmap, &pixel, 1, (unsigned long)0);

	if (	!XAllocColor(dpy, cmap, color)
		|| (	color->pixel != pixel
			&& !RWcell(dpy, cmap, color, &request, &pixel)))
	{
		free_cells(dpy, cmap, pixels, npixels, (int)p);
		return 0;
	}

	return 1;
}


static Status
readwrite_map(Display* dpy, XVisualInfo* vinfo, XStandardColormap* colormap)
{
	int compare(void const* e1, void const* e2)
	{
		return ((int)(*(long*)e1 - *(long*)e2));
	}

	unsigned long	i, n;				// index counters
	unsigned long	ncolors;			// number of colors to be defined
	int				npixels;			// number of pixels allocated
	int				first_index;	// first index of pixels to use
	int				remainder;		// first index of remainder
	XColor			color;			// the definition of a color
	unsigned long*	pixels;			// array of colormap pixels
	unsigned long	delta;

	// Determine ncolors, the number of colors to be defined.
	// Insure that 1 < ncolors <= the colormap size.
	if (vinfo->class == DirectColor)
	{
		ncolors = colormap->red_max;
		if (colormap->green_max > ncolors)
			ncolors = colormap->green_max;
		if (colormap->blue_max > ncolors)
			ncolors = colormap->blue_max;
		ncolors++;
		delta = lowbit(vinfo->red_mask) + lowbit(vinfo->green_mask) + lowbit(vinfo->blue_mask);
	}
	else
	{
		ncolors =	colormap->red_max*colormap->red_mult +
						colormap->green_max*colormap->green_mult +
						colormap->blue_max*colormap->blue_mult +
						1;
		delta = 1;
	}

	if (ncolors <= 1 || (int)ncolors > vinfo->colormap_size)
		return 0;

	// Allocate Read/Write as much of the colormap as we can possibly get.
	// Then insure that the pixels we were allocated are given in
	// monotonically increasing order, using a quicksort.  Next, insure
	// that our allocation includes a subset of contiguous pixels at least
	// as long as the number of colors to be defined.  Now we know that
	// these conditions are met:
	//	1) There are no free cells in the colormap.
	// 2) We have a contiguous sequence of pixels, monotonically
	//    increasing, of length >= the number of colors requested.
	//
	// One cell at a time, we will free, compute the next color value,
	// then allocate read only.  This takes a long time.
	// This is done to insure that cells are allocated read only in the
	// contiguous order which we prefer.  If the server has a choice of
	// cells to grant to an allocation request, the server may give us any
	// cell, so that is why we do these slow gymnastics.

	if ((pixels = (unsigned long*)calloc((unsigned) vinfo->colormap_size, sizeof(unsigned long))) == NULL)
		return 0;

	if ((npixels = ROmap(dpy, colormap->colormap, pixels, vinfo->colormap_size, ncolors)) == 0)
	{
		free((char*)pixels);
		return 0;
	}

	qsort((char*)pixels, npixels, sizeof(unsigned long), compare);

	if (!contiguous(pixels, npixels, ncolors, delta, &first_index, &remainder))
	{
		// can't find enough contiguous cells, give up.
		XFreeColors(dpy, colormap->colormap, pixels, npixels, (unsigned long)0);
		free((char*)pixels);
		return 0;
	}

	colormap->base_pixel = pixels[first_index];

	// construct a gray map
	if (colormap->red_mult == 1 && colormap->green_mult == 1 && colormap->blue_mult == 1)
	{
		for (n=colormap->base_pixel, i=0; i < ncolors; i++, n += delta)
		{
			color.pixel = n;
			color.blue = color.green = color.red =
				(unsigned short)((i*65535)/(colormap->red_max + colormap->green_max + colormap->blue_max));

			if (!ROorRWcell(dpy, colormap->colormap, pixels, npixels, &color, first_index + i))
				return 0;
		}
	}
	// construct a red ramp map
	else if (colormap->green_max == 0 && colormap->blue_max == 0)
	{
		for (n=colormap->base_pixel, i=0; i < ncolors; i++, n += delta)
		{
			color.pixel = n;
			color.red = (unsigned short)((i*65535)/colormap->red_max);
			color.green = color.blue = 0;

			if (!ROorRWcell(dpy, colormap->colormap, pixels, npixels, &color, first_index + i))
				return 0;
		}
	}
	// construct a green ramp map
	else if (colormap->red_max == 0 && colormap->blue_max == 0)
	{
		for (n=colormap->base_pixel, i=0; i < ncolors; i++, n += delta)
		{
			color.pixel = n;
			color.green = (unsigned short)((i*65535)/colormap->green_max);
			color.red = color.blue = 0;

			if (!ROorRWcell(dpy, colormap->colormap, pixels, npixels, &color, first_index + i))
				return 0;
		}
	}
	/* construct a blue ramp map */
	else if (colormap->red_max == 0 && colormap->green_max == 0)
	{
		for (n=colormap->base_pixel, i=0; i < ncolors; i++, n += delta)
		{
			color.pixel = n;
			color.blue = (unsigned short)((i*65535)/colormap->blue_max);
			color.red = color.green = 0;

			if (!ROorRWcell(dpy, colormap->colormap, pixels, npixels, &color, first_index + i))
				return 0;
		}
	}
	// construct a standard red green blue cube map */
	else
	{
#define calc(max,mult) (((n/colormap->mult) % (colormap->max + 1))*65535)/colormap->max

	for (n=0, i=0; i < ncolors; i++, n += delta)
	{
		color.pixel = n + colormap->base_pixel;
		color.red = calc(red_max, red_mult);
		color.green = calc(green_max, green_mult);
		color.blue = calc(blue_max, blue_mult);

		if (!ROorRWcell(dpy, colormap->colormap, pixels, npixels, &color, first_index + i))
			return 0;
	}
#undef calc
	}

	// We have a read-only map defined.  Now free unused cells,
	// first those occuring before the contiguous sequence begins,
	// then any following the contiguous sequence.

	if (first_index)
		XFreeColors(dpy, colormap->colormap, pixels, first_index, (unsigned long)0);

	if (remainder)
	{
		XFreeColors(dpy,
						colormap->colormap,
						&(pixels[first_index + ncolors]),
						remainder,
						(unsigned long)0);
	}

	free((char*)pixels);
	return 1;
}


static Status
readonly_map(Display* dpy, XVisualInfo* vinfo, XStandardColormap* colormap)
{
	int		i;
	int		last_pixel;
	XColor	color;

	last_pixel = (colormap->red_max + 1)*(colormap->green_max + 1)*(colormap->blue_max + 1) +
						colormap->base_pixel - 1;

	for (i = colormap->base_pixel; i <= last_pixel; i++)
	{
		color.pixel = (unsigned long)i;
		color.red = (unsigned short)(((i/colormap->red_mult)*65535)/colormap->red_max);

		if (vinfo->class == StaticColor)
		{
			color.green = (unsigned short)
					((((i/colormap->green_mult) % (colormap->green_max + 1))*65535)/colormap->green_max);
			color.blue = (unsigned short)(((i%colormap->green_mult)*65535)/colormap->blue_max);
		}
		else	// vinfo->class == GrayScale, old style allocation XXX
		{
			color.green = color.blue = color.red;
		}

		XAllocColor(dpy, colormap->colormap, &color);

		if (color.pixel != (unsigned long)i)
			return 0;
	}

	return 1;
}


Status
XmuCreateColormap(Display* dpy, XStandardColormap* colormap)
{
	XVisualInfo		vinfo_template;	// template visual information
	XVisualInfo*	vinfo;				// matching visual information
	XVisualInfo*	vpointer;			// for freeing the entire list
	long				vinfo_mask;			// specifies the visual mask value
	int				n;						// number of matching visuals
	int				status;

	vinfo_template.visualid = colormap->visualid;
	vinfo_mask = VisualIDMask;

	if ((vinfo = XGetVisualInfo(dpy, vinfo_mask, &vinfo_template, &n)) == NULL)
		return 0;

	// A visual id may be valid on multiple screens.  Also, there may
	// be multiple visuals with identical visual ids at different depths.
	// If the colormap is the Default Colormap, use the Default Visual.
	// Otherwise, arbitrarily, use the deepest visual.
	vpointer = vinfo;

	if (n > 1)
	{
		int	i;
		int	screen_number;
		Bool 	def_cmap;

		def_cmap = False;

		for (screen_number = ScreenCount(dpy); --screen_number >= 0;)
		{
			if (colormap->colormap == DefaultColormap(dpy, screen_number))
			{
				def_cmap = True;
				break;
			}
		}

		if (def_cmap)
		{
			for (i=0; i < n; i++, vinfo++)
			{
				if (vinfo->visual == DefaultVisual(dpy, screen_number))
					break;
			}
		}
		else
		{
			int				maxdepth	= 0;
			XVisualInfo*	v			= NULL;

			for (i=0; i < n; i++, vinfo++)
			{
				if (vinfo->depth > maxdepth)
				{
					maxdepth = vinfo->depth;
					v = vinfo;
				}
			}

			vinfo = v;
		}
	}

	if (vinfo->class == PseudoColor || vinfo->class == DirectColor || vinfo->class == GrayScale)
	{
		status = readwrite_map(dpy, vinfo, colormap);
	}
	else if (vinfo->class == TrueColor)
	{
#define TRUEMATCH(mult,max,mask) \
    (colormap->max*colormap->mult <= vinfo->mask && lowbit(vinfo->mask) == colormap->mult)

     status =	TRUEMATCH(red_mult, red_max, red_mask)
				&& TRUEMATCH(green_mult, green_max, green_mask)
				&& TRUEMATCH(blue_mult, blue_max, blue_mask);

#undef TRUEMATCH
	}
	else
	{
		status = readonly_map(dpy, vinfo, colormap);
	}

	XFree((char*)vpointer);
	return status;
}


static Status
valid_args(	XVisualInfo* vinfo,
				unsigned long red_max,
				unsigned long green_max,
				unsigned long blue_max,
				Atom property)
{
	unsigned long ncolors;	// number of colors requested

	// Determine that the number of colors requested is <= map size.

	if (vinfo->class == DirectColor || vinfo->class == TrueColor)
	{
		unsigned long mask;

		mask = vinfo->red_mask;
		while (!(mask & 1))
			mask >>= 1;

		if (red_max > mask)
			return 0;

		mask = vinfo->green_mask;
		while (!(mask & 1))
			mask >>= 1;

		if (green_max > mask)
			return 0;

		mask = vinfo->blue_mask;
		while (!(mask & 1))
			mask >>= 1;

		if (blue_max > mask)
			return 0;
	}
	else if (property == XA_RGB_GRAY_MAP)
	{
		ncolors = red_max + green_max + blue_max + 1;

		if (ncolors > vinfo->colormap_size)
			return 0;
	}
	else
	{
		ncolors = (red_max + 1)*(green_max + 1)*(blue_max + 1);

		if (ncolors > vinfo->colormap_size)
			return 0;
	}

	// Determine that the allocation and visual make sense for the property.

	switch (property)
	{
		case XA_RGB_DEFAULT_MAP:
			if (red_max == 0 || green_max == 0 || blue_max == 0)
				return 0;
			break;

		case XA_RGB_RED_MAP:
			if (red_max == 0)
				return 0;
			break;

		case XA_RGB_GREEN_MAP:
			if (green_max == 0)
				return 0;
			break;

		case XA_RGB_BLUE_MAP:
			if (blue_max == 0)
				return 0;
			break;

		case XA_RGB_BEST_MAP:
			if (red_max == 0 || green_max == 0 || blue_max == 0)
				return 0;
			break;

		case XA_RGB_GRAY_MAP:
			if (red_max == 0 || blue_max == 0 || green_max == 0)
				return 0;
			break;

		default:
			return 0;
	}

	return 1;
}


XStandardColormap*
XmuStandardColormap(	Display* dpy,
							int screen,
							VisualID visualid,
							unsigned depth,
							Atom property,
							Colormap cmap,
							unsigned long red_max,
							unsigned long green_max,
							unsigned long blue_max)
{
	XStandardColormap*	stdcmap;
	Status					status;
	XVisualInfo				vinfo_template;
	XVisualInfo*			vinfo;
	long						vinfo_mask;
	int						n;

	// Match the required visual information to an actual visual.
	vinfo_template.visualid = visualid;
	vinfo_template.screen = screen;
	vinfo_template.depth = depth;
	vinfo_mask = VisualIDMask | VisualScreenMask | VisualDepthMask;

	if ((vinfo = XGetVisualInfo(dpy, vinfo_mask, &vinfo_template, &n)) == NULL)
		return 0;

	// Check the validity of the combination of visual characteristics,
	// allocation, and colormap property.  Create an XStandardColormap
	// structure.

	if (	!valid_args(vinfo, red_max, green_max, blue_max, property)
		|| ((stdcmap = XAllocStandardColormap()) == NULL))
	{
		XFree((char*)vinfo);
		return 0;
	}

	// Fill in the XStandardColormap structure.

	if (cmap == DefaultColormap(dpy, screen))
	{
		// Allocating out of the default map, cannot use XFreeColormap().
		Window win = XCreateWindow(dpy,
											RootWindow(dpy, screen),
											1,
											1,
											1,
											1,
											0,
											0,
											InputOnly,
											vinfo->visual,
											(unsigned long)0,
											(XSetWindowAttributes*)NULL);
		stdcmap->killid  = (XID)XCreatePixmap(dpy, win, 1, 1, depth);
		XDestroyWindow(dpy, win);
		stdcmap->colormap = cmap;
	}
	else
	{
		stdcmap->killid = ReleaseByFreeingColormap;
		stdcmap->colormap = XCreateColormap(dpy, RootWindow(dpy, screen), vinfo->visual, AllocNone);
	}

	stdcmap->red_max = red_max;
	stdcmap->green_max = green_max;
	stdcmap->blue_max = blue_max;

	if (property == XA_RGB_GRAY_MAP)
	{
		stdcmap->red_mult = stdcmap->green_mult = stdcmap->blue_mult = 1;
	}
	else if (vinfo->class == TrueColor || vinfo->class == DirectColor)
	{
		stdcmap->red_mult = lowbit(vinfo->red_mask);
		stdcmap->green_mult = lowbit(vinfo->green_mask);
		stdcmap->blue_mult = lowbit(vinfo->blue_mask);
	}
	else
	{
		stdcmap->red_mult = red_max > 0 ? (green_max + 1)*(blue_max + 1) : 0;
		stdcmap->green_mult = green_max > 0 ? blue_max + 1 : 0;
		stdcmap->blue_mult = blue_max > 0 ? 1 : 0;
	}
	stdcmap->base_pixel = 0;					// base pixel may change */
	stdcmap->visualid = vinfo->visualid;

	// Make the colormap.

	status = XmuCreateColormap(dpy, stdcmap);

	// Clean up.

	XFree((char*)vinfo);

	if (!status)
	{
		// Free the colormap or the pixmap, if we created one.
		if (stdcmap->killid == ReleaseByFreeingColormap)
			XFreeColormap(dpy, stdcmap->colormap);
		else if (stdcmap->killid != None)
			XFreePixmap(dpy, stdcmap->killid);

		XFree((char*)stdcmap);
		return (XStandardColormap*)NULL;
	}

	return stdcmap;
}


Status
XmuLookupStandardColormap(	Display* dpy,
									int screen,
									VisualID visualid,
									unsigned depth,
									Atom property,
									Bool replace,
									Bool retain)
{
	Display*					odpy;						// original display connection
	XStandardColormap*	colormap;
	XVisualInfo				vinfo_template;
	XVisualInfo*			vinfo;
	long						vinfo_mask;
	unsigned long			r_max, g_max, b_max;	// allocation
	int						count;
	Colormap					cmap;						// colormap ID
	Status					status = 0;

	// Match the requested visual.

	vinfo_template.visualid = visualid;
	vinfo_template.screen = screen;
	vinfo_template.depth = depth;
	vinfo_mask = VisualIDMask | VisualScreenMask | VisualDepthMask;

	if ((vinfo = XGetVisualInfo(dpy, vinfo_mask, &vinfo_template, &count)) == NULL)
		return 0;

	// Monochrome visuals have no standard maps.

	if (vinfo->colormap_size <= 2)
	{
		XFree((char *) vinfo);
		return 0;
	}

	// If the requested property already exists on this screen, and,
	// if the replace flag has not been set to true, return success.
	// lookup() will remove a pre-existing map if replace is true.

	if (lookup(dpy, screen, visualid, property, (XStandardColormap *) NULL,replace) && !replace)
	{
		XFree((char *) vinfo);
		return 1;
	}

	// Determine the best allocation for this property under the requested
	// visualid and depth, and determine whether or not to use the default
	// colormap of the screen.

	if (!XmuGetColormapAllocation(vinfo, property, &r_max, &g_max, &b_max))
	{
		XFree((char *) vinfo);
		return 0;
	}

	cmap = (	property == XA_RGB_DEFAULT_MAP
			&& visualid == XVisualIDFromVisual(DefaultVisual(dpy, screen)))
				? DefaultColormap(dpy, screen) : None;

	// If retaining resources, open a new connection to the same server.

	if (retain)
	{
		odpy = dpy;

		if ((dpy = XOpenDisplay(XDisplayString(odpy))) == NULL)
		{
			XFree((char *) vinfo);
			return 0;
		}
	}

	// Create the standard colormap.

	colormap = XmuStandardColormap(dpy, screen, visualid, depth, property, cmap, r_max, g_max, b_max);

	// Set the standard colormap property.

	if (colormap)
	{
		XGrabServer(dpy);

		if (lookup(dpy, screen, visualid, property, colormap, replace) && !replace)
		{
			// Someone has defined the property since we last looked.
			// Since we will not replace it, release our own resources.
			// If this is the default map, our allocations will be freed
			// when this connection closes.
			if (colormap->killid == ReleaseByFreeingColormap)
				XFreeColormap(dpy, colormap->colormap);
		}
		else if (retain)
		{
			XSetCloseDownMode(dpy, RetainPermanent);
		}

		XUngrabServer(dpy);
		XFree((char*)colormap);
		status = 1;
	}

	if (retain)
		XCloseDisplay(dpy);
	XFree((char*)vinfo);

	return status;
}

// vi:set ts=3 sw=3:
