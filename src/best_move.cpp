// best_move.cpp

#include "db_board.h"
#include "db_guess.h"
#include "db_move.h"
#include "db_eco_table.h"

#include "tk_init.h"
#include "tcl_base.h"

#include "u_zstream.h"

#include "m_string.h"
#include "m_ifstream.h"

#include <tcl.h>
#include <tk.h>

#include <stdio.h>
#include <stdlib.h>

using namespace db;


static void
best_move()
{
	char const* moves = "1.e4 g6 2.d4 Bg7 3.Nc3 d6 4.f4 Nc6 5.Be3 Nf6 6.Nf3 e6 7.h3 O-O 8.Qd2 Ne7 9.Bd3 b6 10.O-O-O Bb7 11.Rhe1 c5 12.Bf2 Rc8 13.Kb1 c4 14.Bf1 d5 15.e5 Ne4 16.Nxe4 dxe4 17.Ng5 c3 18.bxc3 b5 19.Ka1 Bd5 20.Nxe4 Bxe4 21.Rxe4 Nd5 22.c4 bxc4 23.c3 Qa5 24.Be1 Qa4 25.Rc1 Rb8 26.Qc2 Qc6 27.Bd2 Rb6 28.Ree1 Rfb8 29.Rb1 Nc7 30.Rxb6 Rxb6 31.Rb1 Nb5 32.Bc1 Bf8 33.g4 Ra6 34.f5 Ra5 35.fxe6 fxe6 36.h4 Ba3 37.h5 Bxc1 38.Qxc1 Rxa2+ 39.Kxa2 Qa6+ 40.Kb2 Qa3+ 41.Kc2 Qxc3+ 42.Kd1 Qf3+ 43.Be2 Nc3+ 44.Kd2 Ne4+ 45.Kd1";

	Board board(Board::standardBoard());

	board.doMoves(moves);
	Guess guess(board, chess960::StandardIdn);

	Move move = guess.bestMove(sq::f3, 1);

	if (move)
	{
		mstl::string m;
		board.prepareForSan(move);
		move.printSan(m);
		printf("best move: %s\n", m.c_str());
	}
	else
	{
		printf("no move possible\n");
	}
}


static int
init(Tcl_Interp* ti)
{
	util::ZStream::setZipFileSuffixes(util::ZStream::Strings(1, "pgn"));

	char const* ecoPath = "/home/gregor/development/c++/scidb/src/data/eco.bin";
	mstl::ifstream stream(ecoPath, mstl::ios_base::in | mstl::ios_base::binary);
	db::EcoTable::specimen().load(stream);

	if (Tcl_Init(ti) == TCL_ERROR || Tk_Init(ti) == TCL_ERROR)
		return TCL_ERROR;

	Tcl_PkgProvide(ti, "tkscidb", "1.0");

	tcl::init(ti);
	tk::init(ti);

	best_move();
	exit(0);

	return TCL_OK;
}


int
main(int argc, char* argv[])
{
	Tk_Main(argc, argv, init);
	return 0;
}

// vi:set ts=3 sw=3:
