// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//  _/|            __
// // o\         /    )           ,        /    /
// || ._)    ----\---------__----------__-/----/__-
// //__\          \      /   '  /    /   /    /   )
// )___(     _(____/____(___ __/____(___/____(___/_
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

#include "db_bpgn_reader.h"

#include "u_progress.h"

#include "m_istream.h"

#include <math.h>

using namespace db;


unsigned
BpgnReader::estimateNumberOfGames(unsigned fileSize)
{
	if (fileSize == 0)
		return 0;

	return mstl::max(1u, unsigned(::ceil(fileSize/696.0)));
}


unsigned
BpgnReader::estimateNumberOfGames()
{
	return estimateNumberOfGames(m_stream.size());
}


unsigned
BpgnReader::process(util::Progress& progress)
{
	M_REQUIRE(hasConsumer());

#if 0
	try
	{
		Token		token			= m_readMode == Text ? kTag : searchTag();
		unsigned	streamSize	= m_stream.size();
		unsigned	numGames		= estimateNumberOfGames(streamSize);
		unsigned	frequency	= progress.frequency(numGames, 1000);
		unsigned	reportAfter	= frequency;
		unsigned	count			= 0;

		ProgressWatcher watcher(progress, streamSize);

		while (token == kTag)
		{
			if (reportAfter == count++)
			{
				progress.update(m_stream.goffset());

				if (progress.interrupted())
					return m_gameCount;

				reportAfter += frequency;
			}

			try
			{
				m_noResult = false;
				m_parsingFirstHdr = false;
				m_comments.clear();
				m_annotation.clear();
				m_timeMode = time::Unknown;
				m_parsingComment = false;
				m_idn = variant::Standard;
				m_ignoreNags = false;
				m_hasNote = false;
				m_atStart = true;
				m_postIndex = 0;
				m_bughouseDBGameNo = false;
				m_checkShufflePosition = false;
				m_resultCorrection = false;
				m_warnings.clear();

				if (m_readMode == File)
				{
					m_parsingTags = true;
					readTags();
					m_parsingTags = false;
				}

				if (!consumer().startGame(m_tags))
					sendError(UnsupportedVariant, m_currPos, m_tags.value(tag::Variant));

				token = nextToken(kTag);
				consumer().startMoveSection();

				unsigned nestedVar = 0;

				while (token == kSan)
				{
					m_ignoreNags = false;
					token = nextToken(token);

					// We want to detect constructions like "((...) (...) ...)".
					// The PGN standard does not forbid such things.
					while (token & (kStartVariation | kEndVariation))
					{
						putMove(true);

						if (token == kEndVariation)
						{
							if (consumer().variationLevel() == 0)
								sendError(UnexpectedSymbol, m_prevPos, ")");

							if (m_hasNote)
							{
								::join(m_comments.begin(), m_comments.end());

								if (consumer().variationIsEmpty())
								{
									consumer().putPrecedingComment(m_comments[0], m_annotation, m_marks);
									m_comments.clear();
									m_annotation.clear();
									m_marks.clear();
								}
								else if (!m_comments.empty())
								{
									consumer().putTrailingComment(m_comments[0]);
									m_comments.clear();
									m_postIndex = 0;
								}

								m_hasNote = false;
							}

							consumer().finishVariation();

							if (nestedVar)
							{
								token = kStartVariation;
								--nestedVar;
							}
							else
							{
								token = nextToken(kEndVariation);
							}
						}
						else
						{
							consumer().startVariation();
							m_atStart = true;
							token = nextToken(kStartVariation);

							if (token == kStartVariation)
							{
								++nestedVar;
								token = nextToken(kStartVariation);
							}
						}
					}
				}

				putLastMove();

				if (!m_warnings.empty())
				{
					for (Warnings::const_iterator i = m_warnings.begin(); i != m_warnings.end(); ++i)
						sendWarning(IllegalMove, i->m_pos, i->m_move);
				}

				if (token == kError)
					unexpectedSymbol(kError, get());

				if (consumer().variationLevel() > 0)
					sendError(UnterminatedVariation);

				if (token == kEoi)
				{
					if (m_readMode == Text)
						return 0;

					sendError(UnexpectedEndOfInput);
				}
				else if (token == kTag)
				{
					if (m_readMode == Text)
						sendError(UnexpectedTag, m_currPos);

					if (m_currPos.column == 1)
					{
						putback('[');
						sendError(UnexpectedEndOfGame, m_currPos);
					}

					m_prevPos = m_currPos;
					sendError(UnexpectedTag, m_prevPos);
				}
				else
				{
					M_ASSERT(token == kResult);

					if (m_noResult || m_resultMode == InMoveSection)
					{
						m_tags.set(Result, result::toString(m_result));
						checkResult();
					}
					else if (checkResult())
					{
						result::ID r = result::fromString(m_tags.value(Result));

						if (m_result != r)
						{
							sendWarning(ResultDidNotMatchHeaderResult, m_prevPos, result::toString(m_result));
							m_result = r;
						}
					}
				}

				finishGame();
			}
			catch (Interruption const& exc)
			{
				if (m_parsingTags)
				{
					findNextEmptyLine();
				}
				else
				{
					putLastMove();
					handleError(exc.error, exc.message);
				}

				token = kResult;
			}

			if (token != kTag)
			{
				m_parsingTags = true;
				token = searchTag();
			}
		}
	}
	catch (Termination const&)
	{
	}

	return ::total(m_gameCount);
#endif
	return 0;
}

// vi:set ts=3 sw=3:
