/*
    Sjeng - a chess variants playing program
    Copyright (C) 2000 Gian-Carlo Pascutto

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
                                                          
    File: rcfile.c
    Purpose: Read in config file, allocate hash/caches                  

*/

#include "sjeng.h"
#include "protos.h"
#include "extvars.h"
#include "config.h"

FILE *rcfile;
char line[STR_BUFF];

int TTSize;
int ECacheSize;
int PBSize;

int cfg_booklearn;
int cfg_razordrop;
int cfg_cutdrop;
int havercfile;
int cfg_futprune;
int cfg_devscale;
int cfg_onerep;
int cfg_recap;
int cfg_smarteval;
int cfg_attackeval;
float cfg_scalefac;

// taken from rc-file
int cfg_tropism[5][7] =
{
	{  40,  20,  10,   3,   1,   1,   0 },
	{  50,  25,  15,   5,   2,   2,   2 },
	{  50,  70,  35,  10,   2,   1,   0 },
	{  50,  40,  15,   5,   1,   1,   0 },
	{ 100,  60,  20,   5,   2,   0,   0 },
};

// taken from rc-file
int cfg_ksafety[15][9] =
{
	{  -5,   5,  10,  15,  50,  80, 150, 150, 150 },
	{  -5,  15,  20,  25,  70, 150, 200, 200, 200 },
	{  -5,  15,  30,  30, 100, 200, 300, 300, 300 },
	{ -10,  20,  40,  40, 100, 200, 300, 300, 400 },
	{ -10,  30,  50,  80, 150, 300, 400, 400, 500 },
	{ -10,  35,  60, 100, 200, 250, 400, 400, 500 },
	{ -10,  40,  70, 110, 210, 300, 500, 500, 600 },
	{ -10,  45,  75, 125, 215, 300, 500, 600, 700 },
	{ -10,  60,  90, 130, 240, 350, 500, 600, 700 },
	{ -15,  60,  95, 145, 260, 350, 500, 600, 700 },
	{ -15,  60, 100, 150, 270, 350, 500, 600, 700 },
	{ -15,  60, 110, 160, 280, 400, 600, 700, 800 },
	{ -20,  70, 115, 165, 290, 400, 600, 700, 800 },
	{ -20,  80, 120, 170, 300, 450, 700, 800, 900 },
	{ -20,  80, 125, 175, 310, 450, 700, 800, 900 },
};

void read_rcfile (void) 
{
  int i;
  unsigned int setc;
  
  if ((rcfile = fopen ("sjeng.rc", "r")) == NULL)
    {
      printf("No configuration file!\n");

      TTSize = 256;					// intial:  300000 entries
      ECacheSize = 200000;			// rc-file: 4000
      PBSize = 10000000;			// intial:  200000
      EGTBCacheSize = 0;
      strcpy(EGTBDir, "TB");
      
      cfg_devscale = 1;
      cfg_scalefac = 1.0;
      cfg_razordrop = 1;
      cfg_cutdrop = 0;
      cfg_futprune = 1;
      cfg_smarteval = 1;
      cfg_attackeval = 1;     // intial:  0

		cfg_booklearn = 1;
		cfg_onerep = 1;
		cfg_recap = 1;

      havercfile = 0;

      setc =   havercfile 
	    + (cfg_devscale << 1) 
	    + (((cfg_scalefac == 1.0) ? 1 : 0) << 2)
	    + (cfg_razordrop << 3)
	    + (cfg_cutdrop << 4)
	    + (cfg_futprune << 5)
	    + (cfg_smarteval << 6)
	    + (cfg_attackeval << 7);
	    
      
      sprintf(setcode, "%u", setc);
      
      initialize_eval();
      alloc_hash();
      alloc_ecache();
      
      return;
    }

  havercfile = 1;
  
  /* read in values, possibly seperated by # commented lines */
  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &TTSize);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &ECacheSize);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &PBSize);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%f", &cfg_scalefac); 

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_devscale); 

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_razordrop);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_cutdrop);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_booklearn);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_futprune);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_onerep);
    
  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_recap);
  
  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_smarteval);
  
  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  sscanf(line, "%d", &cfg_attackeval);

  fgets(line, STR_BUFF, rcfile);
  while (line[0] == '#') fgets(line, STR_BUFF, rcfile);
  
  for(i = 0; i < 5; i++)
  {
      sscanf(line, "%d %d %d %d %d %d %d", 
	  &cfg_tropism[i][0], &cfg_tropism[i][1], &cfg_tropism[i][2],&cfg_tropism[i][3],
	  &cfg_tropism[i][4], &cfg_tropism[i][5], &cfg_tropism[i][6]);
      
          do { fgets(line, STR_BUFF, rcfile);} while (line[0] == '#');
  }
  

  for(i = 0; i < 15; i++)
  {
      sscanf(line, "%d %d %d %d %d %d %d %d %d",
	  &cfg_ksafety[i][0], &cfg_ksafety[i][1],&cfg_ksafety[i][2],&cfg_ksafety[i][3],
	  &cfg_ksafety[i][4], &cfg_ksafety[i][5],&cfg_ksafety[i][6],&cfg_ksafety[i][7],
	  &cfg_ksafety[i][8]);
      
          do {fgets(line, STR_BUFF, rcfile);} while ((line[0] == '#') && !feof(rcfile));
  }

  setc =   havercfile 
            + (cfg_devscale << 1) 
	    + (((cfg_scalefac == 1.0) ? 1 : 0) << 2)
	    + (cfg_razordrop << 3)
	    + (cfg_cutdrop << 4)
	    + (cfg_futprune << 5)
	    + (cfg_smarteval << 6)
	    + (cfg_attackeval << 7);
	    
      
  sprintf(setcode, "%u", setc);

  initialize_eval();
  alloc_hash();
  alloc_ecache();
      
  return; 
  
}
