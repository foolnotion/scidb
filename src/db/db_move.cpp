// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_move.h"

#include "m_assert.h"
#include "m_string.h"
#include "m_stdio.h"

#include <ctype.h>

using namespace db;


Move const Move::m_null			= Move(uint32_t(Bit_Legality));
Move const Move::m_empty		= Move(uint32_t(0));
Move const Move::m_invalid		= Move(uint32_t(Invalid | Bit_Legality));
Move const Move::m_undefined	= Move(uint32_t(Undefined));


static void
printPiece(mstl::string& s, piece::Type piece, encoding::CharSet charSet, int (*letterCase)(int))
{
	if (charSet == encoding::Utf8)
		s += piece::utf8::asString(piece);
	else
		s += letterCase(piece::print(piece));
}


void
Move::transpose()
{
	M_ASSERT(!isEmpty());

	if (isNull())
		return;

	setFrom(sq::flipFyle(sq::ID(from())));
	setTo(sq::flipFyle(sq::ID(to())));

	if (preparedForUndo())
	{
		sq::ID epSquare = sq::ID(prevEpSquare());

		if (epSquare != sq::Null)
			epSquare = sq::flipFyle(epSquare);

		setUndo(	prevHalfMoves(),
					epSquare,
					castling::transpose(prevCastlingRights()),
					prevKingHasMoved(),
					prevCapturePromoted());
	}
}


mstl::string&
Move::printCAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	M_REQUIRE(!isInvalid());

	if (isNull())
	{
		char const* t = 0;

		switch (protocol)
		{
			case protocol::Scidb:		t = "----"; break;
			case protocol::UCI:			t = "0000"; break; // conforms to UCI protocol
			case protocol::Standard:	t = "null"; break; // conforms to WinBoard protocol
		}

		s.append(t, 4);
	}
	else if (isPieceDrop())
	{
		s += sq::printAlgebraic(to());
//		if (protocol == protocol::UCI)
//			s += '*';
		::printPiece(s, dropped(), charSet, ::tolower);
	}
	else if (isCastling() && protocol != protocol::Scidb)
	{
		sq::Fyle fyle = isShortCastling() ? sq::FyleG : sq::FyleC;

		// UCI/WinBoard requires "e1g1" instead of our notation "e1h1"
		s += sq::printAlgebraic(from());
		s += sq::printAlgebraic(sq::make(fyle, sq::rank(to())));
	}
	else if (!isEmpty())
	{
		s += sq::printAlgebraic(from());
		s += sq::printAlgebraic(to());

		if (isPromotion())
			::printPiece(s, promoted(), charSet, protocol == protocol::UCI ? ::tolower : ::toupper);
	}

	return s;
}


mstl::string&
Move::printSAN(mstl::string& s,
					protocol::ID protocol,
					encoding::CharSet charSet,
					bool compact,
					bool useGermanCaptureSign) const
{
	M_REQUIRE(!isInvalid());
	M_REQUIRE(isPrintable() || isEmpty());

	if (isNull())
	{
		s.append("--", 2);	// used in ChessBase
	}
	else if (!isEmpty())
	{
		if (isCastling())
		{
			s.append("O-O", 3);
			if (isLongCastling())
				s.append("-O", 2);
		}
		else if (isPieceDrop())
		{
			if (protocol != protocol::Scidb || dropped() != piece::Pawn)
				::printPiece(s, dropped(), charSet, ::toupper);

			s += (protocol == protocol::UCI) ? '*' : '@';
			s += sq::printFyle(to());
			s += sq::printRank(to());
		}
		else
		{
			if (moved() != piece::Pawn)
			{
				::printPiece(s, moved(), charSet, ::toupper);

				if (needsFyle())
					s += sq::printFyle(from());
				if (needsRank())
					s += sq::printRank(from());
			}

			M_ASSERT(!isEnPassant() || isCapture());

			if (isCapture())
			{
				if (moved() == piece::Pawn)
					s += sq::printFyle(from());

				if (!compact && !useGermanCaptureSign)
					s += 'x';
			}

			s += sq::printFyle(to());
			s += sq::printRank(to());

			if (!compact && isCapture() && useGermanCaptureSign)
				s += ':';

			if (isPromotion())
			{
				if (!compact)
					s += '=';
				::printPiece(s, promoted(), charSet, ::toupper);
			}
		}

		if (!compact && protocol == protocol::Scidb)
		{
			if (givesMate())
				s += '#';
			else if (givesCheck())
				s += '+';
		}
	}

	return s;
}


mstl::string&
Move::printLAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet, bool reversible) const
{
	M_REQUIRE(!isInvalid());
	M_REQUIRE(isPrintable() || isEmpty());

	if (isNull())
	{
		s.append("----", 4);
	}
	else if (!isEmpty())
	{
		if (isPieceDrop())
		{
			::printPiece(s, dropped(), charSet, ::toupper);
			s += protocol == protocol::UCI ? '*' : '@';
			s += sq::printFyle(to());
			s += sq::printRank(to());
		}
		else
		{
			if (moved() != piece::Pawn)
				::printPiece(s, moved(), charSet, ::toupper);

			s += sq::printFyle(from());
			s += sq::printRank(from());

			if (isCapture())
			{
				s += 'x';

				if (reversible)
					::printPiece(s, captured(), charSet, ::toupper);
			}
			else
			{
				s += '-';
			}

			s += sq::printFyle(to());
			s += sq::printRank(to());

			if (isPromotion())
			{
				s += '=';
				::printPiece(s, promoted(), charSet, ::toupper);
			}
		}

		if (protocol == protocol::Scidb)
		{
			if (givesMate())
				s += '#';
			else if (givesCheck())
				s += '+';
		}
	}

	return s;
}


mstl::string&
Move::printSmith(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	if (isNull())
	{
		s.append("----");	// arbitrarely choosen, but fit's with the syntax
	}
	else if (!isEmpty())
	{
		if (isPieceDrop())
		{
			s += piece::print(dropped());
			s += protocol == protocol::UCI ? '*' : '@';
			s += sq::printFyle(to());
			s += sq::printRank(to());
		}
		else
		{
			s += sq::printFyle(from());
			s += sq::printRank(from());
			s += sq::printFyle(to());
			s += sq::printRank(to());

			if (isCastling())
				s += isShortCastling() ? 'c' : 'C';
			else if (isEnPassant())
				s += 'E';
			else if (isCapture())
				::printPiece(s, captured(), charSet, ::tolower);

			if (isPromotion())
				::printPiece(s, promoted(), charSet, ::toupper);
		}

		if (protocol == protocol::Scidb)
		{
			if (givesMate())
				s += '#';
			else if (givesCheck())
				s += '+';
		}
	}

	return s;
}


mstl::string&
Move::printDescriptive(mstl::string& s, sq::Language lang) const
{
	if (isNull())
	{
		s.append("null");	// arbitrarely choosen
	}
	else if (isCastling())
	{
		s.append("O-O", 3);
		if (isLongCastling())
			s.append("-O", 2);
	}
	else if (!isEmpty())
	{
		if (isPieceDrop())
		{
			s += piece::print(dropped(), lang);
			s += '@';
			s += sq::printDescriptive(to(), color(), lang);
		}
		else
		{
			if (isCapture())
			{
				s += piece::print(moved(), lang);

				if (!isDisambiguated() && (needsFyle() || needsRank()))
				{
					s += '(';
					s += sq::printDescriptive(from(), color(), lang);
					s += ')';
				}

				s += 'x';
				s += piece::print(captured(), lang);

				if (needsDestinationSquare())
				{
					s += '(';
					s += sq::printDescriptive(to(), color(), lang);
					s += ')';
				}
			}
			else
			{
				s += piece::print(moved(), lang);

				if (!isDisambiguated() && (needsFyle() || needsRank()))
				{
					s += '(';
					s += sq::printDescriptive(from(), color(), lang);
					s += ')';
				}

				if (lang == sq::English)
					s += '-';
				s += sq::printDescriptive(to(), color(), lang);
			}

			if (isPromotion())
			{
				s += '(';
				s += piece::print(promoted(), lang);
				s += ')';
			}
		}

		if (givesMate())
			s.append("++", 2);	// English: "mate"
		else if (givesCheck())
			s += '+';				// English: "ch"

		if (isEnPassant())
			s.append(lang == sq::English ? " e.p." : " d.p.", 5);
	}

	return s;
}


mstl::string&
Move::printNumeric(mstl::string& s) const
{
	if (isNull())
	{
		s.append("0000", 4);	// arbitrarely choosen
	}
	else if (isPieceDrop())
	{
		s += sq::printNumeric(to());
		s += piece::printNumeric(dropped());
	}
	else if (!isEmpty())
	{
		s += sq::printNumeric(from());
		s += sq::printNumeric(to());

		if (isPromotion())
			s += piece::printNumeric(promoted());
	}

	return s;
}


mstl::string&
Move::printAlphabetic(mstl::string& s, encoding::CharSet charSet) const
{
	if (isNull())
	{
		s.append("XXXX", 4);	// arbitrarely choosen
	}
	else if (isPieceDrop())
	{
		s += sq::printAlphabetic(to());
		::printPiece(s, dropped(), charSet, ::tolower);
	}
	else if (!isEmpty())
	{
		s += sq::printAlphabetic(from());
		s += sq::printAlphabetic(to());

		if (isPromotion())
			::printPiece(s, promoted(), charSet, ::tolower);
	}

	return s;
}


mstl::string&
Move::print(mstl::string& s,
				move::Notation style,
				protocol::ID protocol,
				encoding::CharSet charSet) const
{
	switch (style)
	{
		case move::CAN:			printCAN(s, protocol, charSet); break;
		case move::SAN:			printSAN(s, protocol, charSet); break;
		case move::LAN:			printLAN(s, protocol, charSet); break;
		case move::GAN:			printGAN(s, protocol, charSet); break;
		case move::MAN:			printMAN(s, protocol, charSet); break;
		case move::RAN:			printRAN(s, protocol, charSet); break;
		case move::Smith:			printSmith(s, protocol, charSet); break;
		case move::EDN:			printDescriptive(s, sq::English); break;
		case move::SDN:			printDescriptive(s, sq::Spanish); break;
		case move::Numeric:		printNumeric(s); break;
		case move::Alphabetic:	printAlphabetic(s, charSet); break;
	}

	return s;
}


mstl::string&
Move::printForDisplay(mstl::string& s, move::Notation style) const
{
	print(s, style, protocol::Scidb, encoding::Utf8);

	if (style == move::SAN || style == move::LAN)
	{
		if (!givesMate())
		{
			if (givesDoubleCheck())
				s += '+';

			if (givesCheck())
			{
				switch (checksGiven())
				{
					case 1: s.append("\xc2\xb9", 2); break;
					case 2: s.append("\xc2\xb2", 2); break;
					case 3: s.append("\xc2\xb3", 2); break;
				}
			}
		}
	}

	return s;
}


mstl::string&
Move::dump(mstl::string& result) const
{
	if (isEmpty())
	{
		result = "<Empty>";
	}
	else if (isNull())
	{
		result = "<Null>";
	}
	else if (isInvalid())
	{
		result = "<Invalid>";
	}
	else
	{
		if (isCastling())
		{
			if (isShortCastling())
				result = "O-O";
			else
				result = "O-O-O";
		}
		else if (isPieceDrop())
		{
			result += piece::print(dropped());
			result += '@';
			result += sq::printFyle(to());
			result += sq::printRank(to());
		}
		else
		{
			if (moved() != piece::Pawn)
				result += piece::print(moved());

			result += sq::printFyle(from());
			result += sq::printRank(from());

			result += isCapture() ? "x" : "-";

			result += sq::printFyle(to());
			result += sq::printRank(to());

			if (isPromotion())
			{
				result += '=';
				result += piece::print(promoted());
			}

			if (isCapture())
			{
				result += " x ";
				result += piece::print(captured());
			}
		}
	}

	return result;
}


Move
Move::genMove(	uint32_t from,
					uint32_t to,
					uint32_t pieceType,
					uint32_t captured,
					uint32_t promotedType)
{
	if (from == to && pieceType != piece::None)
		return genPieceDrop(to, pieceType);
	
	switch (pieceType)
	{
		case piece::King:
		case piece::Queen:
		case piece::Rook:
		case piece::Bishop:
		case piece::Knight:
			return genMove(from, to, pieceType, captured);

		case piece::Pawn:
			if (promotedType != piece::None)
				return genCapturePromote(from, to, promotedType, captured);

			return genPawnCapture(from, to, captured);
	}

	return m_null;
}


void
Move::dump() const
{
	mstl::string s;
	::printf("%s\n", dump(s).c_str());
	::fflush(stdout);
}


mstl::string
Move::asString() const
{
	mstl::string result;
	return dump(result);
}

// vi:set ts=3 sw=3:
