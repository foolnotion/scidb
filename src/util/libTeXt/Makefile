# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

include ../../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE	= -I. -I../../mstl
CXXFLAGS	= $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)

SRC_CXX = \
	T_ActiveToken.cpp \
	T_Alignment.cpp \
	T_Arithmetic.cpp \
	T_AsciiToken.cpp \
	T_Char.cpp \
	T_Conditional.cpp \
	T_ConditionalToken.cpp \
	T_Consumer.cpp \
	T_Controller.cpp \
	T_DateTime.cpp \
	T_Diagnostic.cpp \
	T_Environment.cpp \
	T_Errormode.cpp \
	T_ExpandableToken.cpp \
	T_Expansion.cpp \
	T_FileInput.cpp \
	T_FinalToken.cpp \
	T_Format.cpp \
	T_Generic.cpp \
	T_GenericAssignmentToken.cpp \
	T_GenericConditionalToken.cpp \
	T_GenericExpandableToken.cpp \
	T_GenericFinalToken.cpp \
	T_GenericToken.cpp \
	T_GenericValueToken.cpp \
	T_Grouping.cpp \
	T_Input.cpp \
	T_InputOutput.cpp \
	T_InvalidToken.cpp \
	T_LeftBraceToken.cpp \
	T_List.cpp \
	T_ListToken.cpp \
	T_MacroToken.cpp \
	T_Macros.cpp \
	T_Messages.cpp \
	T_Miscellaneous.cpp \
	T_Nothing.cpp \
	T_NumberToken.cpp \
	T_OutputFilter.cpp \
	T_Package.cpp \
	T_ParameterToken.cpp \
	T_Producer.cpp \
	T_ReadAgainProducer.cpp \
	T_Receptacle.cpp \
	T_RightBraceToken.cpp \
	T_TextConsumer.cpp \
	T_TextProducer.cpp \
	T_TextToken.cpp \
	T_Token.cpp \
	T_TokenBuffer.cpp \
	T_Tokenizer.cpp \
	T_Tracing.cpp \
	T_UnboundToken.cpp \
	T_UndefinedToken.cpp \
	T_Unicode.cpp \
	T_UserInput.cpp \
	T_ValueBuffer.cpp \
	T_Values.cpp \
	T_VariableToken.cpp \
	T_Verify.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libTeXt

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
