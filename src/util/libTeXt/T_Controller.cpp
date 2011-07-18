// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_Controller.h"
#include "T_Environment.h"
#include "T_Consumer.h"
#include "T_FileInput.h"
#include "T_InputOutput.h"
#include "T_TokenP.h"
#include "T_Messages.h"

#include "m_string.h"
#include "m_assert.h"
#include "m_iostream.h"
#include "m_ofstream.h"
#include "m_ifstream.h"
#include "m_stdio.h"

#if defined(__unix__) || defined(__MaxOSX__)

# include <sys/stat.h>
# include <unistd.h>
# include <time.h>

#elif defined(WIN32)

# include <windows.h>

#else

# error "unsupported platform"

#endif

using namespace TeXt;


namespace {

class MyConsumer : public Consumer
{
public:

	MyConsumer(mstl::ostream& dst, mstl::ostream* out, mstl::ostream* log)
		:fDst(dst)
		,fOut(out)
		,fLog(log)
		,fCount(0)
	{
		if (fOut == 0)
			fOut = &mstl::cerr;
	}

	int count() const { return fCount; }

	void put(unsigned char c) override
	{
		fDst.put(c);

		if (c != '\n')
			++fCount;
	}

	void put(mstl::string const& s) override
	{
		fDst.write(s);
		fCount += s.size();
	}

	void out(mstl::string const& text) override
	{
		if (fOut && fOut != fLog)
		{
			fOut->write(text);
			fOut->flush();
		}
	}

	void log(mstl::string const& text, bool copyToOut) override
	{
		if (fLog)
			fLog->write(text);

		if (copyToOut)
			out(text);
	}

private:

	mstl::ostream&	fDst;
	mstl::ostream*	fOut;
	mstl::ostream*	fLog;
	int				fCount;
};


struct MyReceptacle : public Receptacle
{
	MyReceptacle(Environment& env) :Receptacle(env) {}
	~MyReceptacle() {}

	void add(mstl::string const& name, TokenP const& token) override
	{
		M_REQUIRE(!name.empty());
		M_REQUIRE(name[0] != Token::EscapeChar);
		M_REQUIRE(!env().containsToken(Token::EscapeChar + name));
		M_REQUIRE(token);

		env().bindMacro(Token::EscapeChar + name, token);
	}
};

} // namespace


static Environment::ErrorMode
mapErrorMode(Controller::ErrorMode e)
{
	switch (e)
	{
		case Controller::ErrorStopMode:	return Environment::ErrorStopMode;
		case Controller::ScrollMode:		return Environment::ScrollMode;
		case Controller::NonStopMode:		return Environment::NonStopMode;
		case Controller::AbortMode:		return Environment::AbortMode;
		case Controller::BatchMode:		return Environment::BatchMode;
	}

	return Environment::ErrorStopMode;	// satisfies the compiler
}


Controller::Log::~Log() throw() {}


Controller::Controller(mstl::string const& searchDirs, ErrorMode errorMode, LogP log)
	:m_env(new Environment(searchDirs, ::mapErrorMode(errorMode)))
	,m_receptacle(new MyReceptacle(*m_env))
	,m_log(log)
	,m_continued(false)
{
	addPackages();
}


Controller::~Controller()
{
	// no action
}


Receptacle&
Controller::receptacle()
{
	return *m_receptacle;
}


int
Controller::processInput(mstl::istream& inp, mstl::ostream& dst, mstl::ostream* out, mstl::ostream* log)
{
	mstl::ref_counted_ptr<MyConsumer> consumer(new MyConsumer(dst, out, log));

	m_env->setConsumer(consumer);
	m_env->pushInput(Environment::InputP(new FileInput(&inp)));

	bool emergencyStop = false;
	bool errorOccurred = false;

	try
	{
		TokenP token;

		do
		{
			try
			{
				if ((token = m_env->getFinalToken(Environment::AllowNull)))
					m_env->execute(token);
			}
			catch (Token::BreakExecutionException)
			{
				errorOccurred = true;
			}
		}
		while (token);
	}
	catch (Token::UnexpectedEndOfInputException)
	{
		Messages::printTrace(*m_env, "Unexpected end of input");
		errorOccurred = true;
	}
	catch (Token::EmergencyStopException)
	{
		Messages::printTrace(*m_env, "Emergency stop");
		errorOccurred = true;
		emergencyStop = true;
	}
	catch (Token::AbortException)
	{
		errorOccurred = true;
		emergencyStop = true;
	}
	catch (...)
	{
		Messages::printTrace(*m_env, "Interrupted");
		throw;
	}

	if (!emergencyStop && !m_continued)
	{
		try
		{
			m_env->finishPackages();
			m_continued = true;

			if (m_env->groupLevel() > 0)
			{
				Messages::printTrace(
						*m_env,
						"Unexpected end of input occurred inside a group at level "
							+ mstl::string::cast(m_env->groupLevel()));
				errorOccurred = true;
			}
		}
		catch (Token::AbortException)
		{
			errorOccurred = true;
		}
	}

	return errorOccurred ? -consumer->count() : consumer->count();
}


int
Controller::processInput(	mstl::istream& inp,
									mstl::ostream& dst,
									mstl::string const& pathName,
									unsigned flags,
									mstl::string const& logHdr)
{
	int count;

	mstl::ostream*	out = (flags & UseConsole) ? &mstl::cout : 0;
	mstl::string	msg;

	if (flags & UseLog)
	{
		mstl::string myPath(pathName);

		mstl::string::size_type dot = myPath.rfind('.');
#if defined(__unix__) || defined(__MaxOSX__)
		mstl::string::size_type sep = myPath.rfind('/');
#elif defined (WIN32)
		mstl::string::size_type sep = myPath.rfind('\\');
#else
# error "unsupported platform"
#endif

		if (	dot != mstl::string::npos
			&& dot < myPath.size() - 1
			&& (sep == mstl::string::npos || sep < dot - 1))
		{
			myPath.erase(dot);
		}

		myPath.append(".log", 4);

		mstl::ofstream logStream(myPath);

		if (!logStream)
		{
			if (m_log)
				m_log->error("[TeXt::Controller] cannot open log file '" + myPath + "'");

			return OpenLogFileFailed;
		}

		logStream.writenl(logHdr);
		count = processInput(inp, dst, out, &logStream);
		logStream.writenl(logHdr);

		msg = mstl::string::cast(mstl::abs(count)) + " character(s) of output.";
		if (out)
			((msg += "\nTranscript written on '") += myPath.data()) += "'.";
	}
	else
	{
		count = processInput(inp, dst, out);
		msg = mstl::string::cast(mstl::abs(count)) + " character(s) of output.";
	}

	if (out && !(flags & UseConsole))
		out->writenl(msg);

	return count;
}


mstl::string
Controller::setupStream(mstl::string const& inputPath, mstl::ifstream& inStream)
{
	mstl::string const& ioSuffix(InputOutput::suffix());

	mstl::string inPath(inputPath);
	mstl::string fullPath(inPath);

	if (	!InputOutput::searchFile(m_env->searchDirs(), inPath)
		&& inPath.size() > ioSuffix.size()
		&& inPath.substr(inPath.size() - ioSuffix.size()) != ioSuffix)
	{
		inPath += ioSuffix;
		InputOutput::searchFile(m_env->searchDirs(), inPath);
	}

	inStream.open(inPath);

	if (inStream)
		return inPath;

	if (m_log)
		m_log->error("[TeXt::Controller] cannot open input file '" + inPath + "'");

	return mstl::string::empty_string;
}


int
Controller::processInput(	mstl::string const& inputPath,
									mstl::ostream& dst,
									mstl::ostream* out,
									mstl::ostream* log)
{
	mstl::ifstream	inStream;
	mstl::string	inPath = setupStream(inputPath, inStream);

	if (inPath.empty())
		return OpenInputFileFailed;

	return processInput(inStream, dst, out, log);
}


int
Controller::processInput(	mstl::string const& inputPath,
									mstl::string const& outputPath,
									unsigned flags)
{
	mstl::ifstream	inStream;
	mstl::string	inPath = setupStream(inputPath, inStream);

	if (inPath.empty())
		return OpenInputFileFailed;

	mstl::string logHdr;

	if (flags & UseLog)
	{
		{
			int	mon, day, hour, min;
			int	year		= -1;
			int	fildes	= inStream.fildes();

#if defined(__unix__) || defined(__MaxOSX__)

			struct ::stat st;

			if (::fstat(fildes, &st) != -1)
			{
				struct tm* lt = ::localtime(&st.st_mtime);

				year	= lt->tm_year;
				mon	= lt->tm_mon;
				day	= lt->tm_mday;
				hour	= lt->tm_hour;
				min	= lt->tm_min;
			}

#elif defined(WIN32)

			HANDLE fh = (HANDLE)::_get_osfhandle(fildes);

			BY_HANDLE_FILE_INFORMATION info;
			SYSTEMTIME st, lt;

			if (	fh != INVALID_HANDLE_VALUE
				&& ::GetFileType(fh) != FILE_TYPE_DISK
				&& ::GetFileInformationByHandle(fh, &info)
				&& ::FileTimeToSystemTime(info.ftLastWriteTime, &st))
			{
				if (::SystemTimeToTzSpecificLocalTime(&st, &lt) == 0)
					lt = st;

				year	= lt.wYear;
				mon	= lt.wMonth;
				day	= lt.wDay;
				hour	= lt.wHour;
				min	= lt.wMinute;
			}

#else

# error "unsupported platform"

#endif

			if (year == -1)
			{
				if (m_log)
					m_log->error("[TeXt::Controller] error while reading input file '" + inPath + "'");

				return OpenInputFileFailed;
			}

			char buf[100];
			::snprintf(buf, sizeof(buf), "%d-%d-%d %d:%d", year, mon, day, hour, min);

			logHdr += "Input '";
			logHdr += inPath;
			logHdr += "'  ";
			logHdr += buf;
		}
	}

	unsigned count;

	if (flags & UseConsole)
	{
		count = processInput(inStream, mstl::cout, outputPath, flags, logHdr);
	}
	else
	{
		mstl::ofstream outStream(outputPath);

		if (!outStream)
		{
			if (m_log)
				m_log->error("[TeXt::Controller] cannot open output file '" + outputPath + "'");

			return OpenOutputFileFailed;
		}

		count = processInput(inStream, outStream, outputPath, flags, logHdr);
	}

	return count;
}


void
Controller::addPackage(PackageP package)
{
	m_env->addPackage(package);
}


void
Controller::addPackage(Package* package)
{
	addPackage(PackageP(package));
}


#include "T_Alignment.h"
#include "T_Arithmetic.h"
#include "T_Char.h"
#include "T_Conditional.h"
#include "T_DateTime.h"
#include "T_Diagnostic.h"
#include "T_Errormode.h"
#include "T_Expansion.h"
#include "T_Format.h"
#include "T_Grouping.h"
#include "T_InputOutput.h"
#include "T_List.h"
#include "T_Macros.h"
#include "T_Messages.h"
#include "T_Miscellaneous.h"
#include "T_Nothing.h"
#include "T_Tracing.h"
#include "T_Unicode.h"
#include "T_Values.h"


void
Controller::addPackages()
{
	addPackage(new Alignment);
	addPackage(new Arithmetic);
	addPackage(new Char);
	addPackage(new Conditional);
	addPackage(new DateTime);
	addPackage(new Diagnostic);
	addPackage(new Errormode);
	addPackage(new Expansion);
	addPackage(new Format);
	addPackage(new Grouping);
	addPackage(new InputOutput);
	addPackage(new List);
	addPackage(new Macros);
	addPackage(new Messages);
	addPackage(new Miscellaneous);
	addPackage(new Nothing);
	addPackage(new Tracing);
	addPackage(new Unicode);
	addPackage(new Values);
}

// vi:set ts=3 sw=3:
