/*
    Sjeng - a chess variants playing program
    Copyright (C) 2001 Gian-Carlo Pascutto

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

    File: see.c                                             
    Purpose: do static exchange evaluation                      
 
*/

#include "sjeng.h"
#include "extvars.h"

typedef struct
{
  int piece;
  int square;
#if SCIDB_VERSION
  int promoted;
#endif
} see_data;

see_data see_attackers[2][16];
int see_num_attackers[2];

void setup_attackers (int square) {

  /* this function calculates attack information for a square */

  static const int rook_o[4] = {12, -12, 1, -1};
  static const int bishop_o[4] = {11, -11, 13, -13};
  static const int knight_o[8] = {10, -10, 14, -14, 23, -23, 25, -25};
  register int a_sq, b_sq, i;
#if SCIDB_VERSION
  int promoted = 0;
  see_data* see;
#endif
  int numw = see_num_attackers[WHITE], numb = see_num_attackers[BLACK];
  
  /* rook-style moves: */
  for (i = 0; i < 4; i++) 
    {
      a_sq = square + rook_o[i];
      b_sq = board[a_sq];
#if SCIDB_VERSION
      if (Variant & (Crazyhouse|Bughouse))
	promoted = is_promoted[squares[a_sq]];
#endif
      
      /* the king can attack from one square away: */
      if (b_sq == wking) 
	{
	  see_attackers[WHITE][numw].piece = b_sq;
	  see_attackers[WHITE][numw].square = a_sq;
	  numw++;
	  break;
	}
      else if (b_sq == bking)
	{
	  see_attackers[BLACK][numb].piece = b_sq;
	  see_attackers[BLACK][numb].square = a_sq;
	  numb++;
	  break;
	}
      else
	{
	  /* otherwise, check for sliding pieces: */
	  while (b_sq != frame) 
	    {
	      if (b_sq == wrook || b_sq == wqueen) 
		{
#if SCIDB_VERSION
		  see = &see_attackers[WHITE][numw];
		  see->piece = b_sq;
		  see->square = a_sq;
		  see->promoted = promoted;
#else
		  see_attackers[WHITE][numw].piece = b_sq;
		  see_attackers[WHITE][numw].square = a_sq;
#endif
		  numw++;
		  break;
		}
	      else if (b_sq == brook || b_sq == bqueen)
		{
#if SCIDB_VERSION
		  see = &see_attackers[BLACK][numb];
		  see->piece = b_sq;
		  see->square = a_sq;
		  see->promoted = promoted;
#else
		  see_attackers[BLACK][numb].piece = b_sq;
		  see_attackers[BLACK][numb].square = a_sq;
#endif
		  numb++;
		  break;
		}
	      else if (b_sq != npiece) break;
	      a_sq += rook_o [i];
	      b_sq = board[a_sq];
#if SCIDB_VERSION
	      if (Variant & (Crazyhouse|Bughouse))
		promoted = is_promoted[squares[a_sq]];
#endif
	    }
	}
    }
  
  /* bishop-style moves: */
  for (i = 0; i < 4; i++) 
    {
      a_sq = square + bishop_o[i];
      b_sq = board[a_sq];
#if SCIDB_VERSION
      if (Variant & (Crazyhouse|Bughouse))
	promoted = is_promoted[squares[a_sq]];
#endif
      /* check for pawn attacks: */
      if (b_sq == wpawn && i%2)
	{
	  see_attackers[WHITE][numw].piece = b_sq;
	  see_attackers[WHITE][numw].square = a_sq;
	  numw++;
	  break;
	}
      else if (b_sq == bpawn && !(i%2))
	{
	  see_attackers[BLACK][numb].piece = b_sq;
	  see_attackers[BLACK][numb].square = a_sq;
	  numb++;
	  break;
	}
      /* the king can attack from one square away: */
      else if (b_sq == wking)
	{
	  see_attackers[WHITE][numw].piece = b_sq;
	  see_attackers[WHITE][numw].square = a_sq;
	  numw++;
	  break;
	}
      else if (b_sq == bking)
	{
	  see_attackers[BLACK][numb].piece = b_sq;
	  see_attackers[BLACK][numb].square = a_sq;
	  numb++;
	  break;
	}
      else
	{
	  while (b_sq != frame) {
	    if (b_sq == wbishop || b_sq == wqueen) 
	      {
#if SCIDB_VERSION
		see = &see_attackers[WHITE][numw];
		see->piece = b_sq;
		see->square = a_sq;
		see->promoted = promoted;
#else
	        see_attackers[WHITE][numw].piece = b_sq;
	        see_attackers[WHITE][numw].square = a_sq;
#endif
		numw++;
		break;
	      }
	    else if (b_sq == bbishop || b_sq == bqueen)
	      {
#if SCIDB_VERSION
		see = &see_attackers[BLACK][numb];
		see->piece = b_sq;
		see->square = a_sq;
		see->promoted = promoted;
#else
	        see_attackers[BLACK][numb].piece = b_sq;
		see_attackers[BLACK][numb].square = a_sq;
#endif
		numb++;
		break;
	      }
	    else if (b_sq != npiece) break;
	    a_sq += bishop_o [i];
	    b_sq = board[a_sq];
#if SCIDB_VERSION
	    if (Variant & (Crazyhouse|Bughouse))
	      promoted = is_promoted[squares[a_sq]];
#endif
	  }
	}
    }
  
  /* knight-style moves: */
  for (i = 0; i < 8; i++) 
    {
      a_sq = square + knight_o[i];
      b_sq = board[a_sq];
#if SCIDB_VERSION
      if (Variant & (Crazyhouse|Bughouse))
	promoted = is_promoted[squares[a_sq]];
#endif
      if (b_sq == wknight)
	{
#if SCIDB_VERSION
	  see = &see_attackers[WHITE][numw];
	  see->piece = b_sq;
	  see->square = a_sq;
	  see->promoted = promoted;
#else
	  see_attackers[WHITE][numw].piece = b_sq;
	  see_attackers[WHITE][numw].square = a_sq;
#endif
	  numw++;
	}
      else if (b_sq == bknight)
	{
#if SCIDB_VERSION
	  see = &see_attackers[BLACK][numb];
	  see->piece = b_sq;
	  see->square = a_sq;
	  see->promoted = promoted;
#else
	  see_attackers[BLACK][numb].piece = b_sq;
	  see_attackers[BLACK][numb].square = a_sq;
#endif
	  numb++;
	}
    }

  see_num_attackers[WHITE] = numw;
  see_num_attackers[BLACK] = numb;
}

void findlowest(int color, int next)
{
  int lowestp;
  int lowestv;
  see_data swap;
  int i;
#if SCIDB_VERSION
  see_data* see;
#endif

  lowestp = next;
#if SCIDB_VERSION
  see = &see_attackers[color][next];
  lowestv = abs(material[see->piece]);
  if (Variant & (Crazyhouse|Bughouse))
    lowestv += abs(material[see->promoted ? wpawn : see->piece]);
#else
  lowestv = abs(material[see_attackers[color][next].piece]);
#endif

  for (i = next; i < see_num_attackers[color]; i++)
    {
      if (abs(material[see_attackers[color][i].piece]) < lowestv)
	{
	  lowestp = i;
#if SCIDB_VERSION
	  see = &see_attackers[color][i];
	  lowestv = abs(material[see->piece]);
	  if (Variant & (Crazyhouse|Bughouse))
	    lowestv += abs(material[see->promoted ? wpawn : see->piece]);
#else
	  lowestv = abs(material[see_attackers[color][i].piece]);
#endif
	}
    } 

  /* lowestp now points to the lowest attacker, which we swap with next */
  swap = see_attackers[color][next];
  see_attackers[color][next] = see_attackers[color][lowestp];
  see_attackers[color][lowestp] = swap;
}


int see(int color, int square, int from)
{
  int sside;
  int caps[2];
  int value;
  int origpiece;
  int ourbestvalue;
  int hisbestvalue;
#if SCIDB_VERSION
  int piece, v;
  see_data* see;
#endif

  /* reset data */
  see_num_attackers[WHITE] = 0;
  see_num_attackers[BLACK] = 0;

  /* remove original capturer from board, exposing his first xray-er */
  origpiece = board[from];
  board[from] = npiece;

  see_num_attackers[color]++;
  see_attackers[color][0].piece = origpiece;
  see_attackers[color][0].square = from;
#if SCIDB_VERSION
  if (Variant & (Crazyhouse|Bughouse))
    see_attackers[color][0].promoted = is_promoted[squares[from]];
  else
    see_attackers[color][0].promoted = 0;
#endif

  /* calculate all attackers to square */
  setup_attackers(square);

  /* initially we gain the piece we are capturing */
#if SCIDB_VERSION
  piece = board[square];
  value = abs(material[piece]);
  if (Variant & (Crazyhouse|Bughouse))
    value += is_promoted[squares[square]] ? material[wpawn] : value;
#else
  value = abs(material[board[square]]);
#endif

  /* free capture ? */
  if (!see_num_attackers[!color])
    {
      board[from] = origpiece;
      return value;
    }
  else
    {
      /* we can never get a higher SEE score than the piece we just captured */
      /* so that is the current best value for our opponent */
      /* we arent sure of anything yet, so -INF */
      hisbestvalue = value;
      ourbestvalue = -INF;
    }

  caps[color] = 1;
  caps[!color] = 0;

  /* start with recapture */
  sside = !color;

  /* continue as long as there are attackers */
  while (caps[sside] < see_num_attackers[sside])
    {
      /* resort capturelist of sside to put lowest attacker in next position */
      findlowest(sside, caps[sside]);

      if (sside == color)
	{
	  /* capturing more */
	  /* we capture the opponents recapturer */
#if SCIDB_VERSION
	  see = &see_attackers[!sside][caps[!sside]-1];
	  value += (v = abs(material[see->piece]));
	  if (Variant & (Crazyhouse|Bughouse))
	    value += see->promoted ? material[wpawn] : v;
#else
	  value += abs(material[see_attackers[!sside][caps[!sside]-1].piece]);
#endif

	  /* if the opp ran out of attackers we can stand pat now! */
	   if (see_num_attackers[!sside] <= caps[!sside] && value > ourbestvalue)
	    ourbestvalue = value;

	  /* our opponent can always stand pat now */
	  if (value < hisbestvalue) hisbestvalue = value;
	}
      else 
	{
	  /* recapture by opp */
	  /* we lose whatever we captured with in last iteration */
#if SCIDB_VERSION
	  see = &see_attackers[!sside][caps[!sside]-1];
	  value -= (v = abs(material[see->piece]));
	  if (Variant & (Crazyhouse|Bughouse))
	    value -= see->promoted ? material[wpawn] : v;
#else
	  value -= abs(material[see_attackers[!sside][caps[!sside]-1].piece]);
#endif

	  /* we can stand pat if we want to now */
	  /* our best score goes up, opponent is unaffected */

	  if (value > ourbestvalue)
	    { 
	      ourbestvalue = value;
	    }

	  if (see_num_attackers[!sside] <= caps[!sside] && value < hisbestvalue)
	    hisbestvalue = value;
	}

      /* keep track of capture count */
      caps[sside]++;

      /* switch sides */
      sside ^= 1;

    }

  /* restore capturer */
  board[from] = origpiece;

  /* we return our best score now, keeping in mind that
     it can never we better than the best for our opponent */
  return (ourbestvalue > hisbestvalue) ? hisbestvalue : ourbestvalue;
}
