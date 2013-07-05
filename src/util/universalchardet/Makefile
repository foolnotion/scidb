# ======================================================================
# Makefile for universalchardet
# ======================================================================

include ../../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE  = -I.
CXXFLAGS += $(SYS_CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING) #-DDEBUG_chardet

SRC_CXX = \
	CharDistribution.cpp \
	JpCntx.cpp \
	LangBulgarianModel.cpp \
	LangCyrillicModel.cpp \
	LangGreekModel.cpp \
	LangHebrewModel.cpp \
	LangHungarianModel.cpp \
	LangThaiModel.cpp \
	nsBig5Prober.cpp \
	nsCharSetProber.cpp \
	nsEUCJPProber.cpp \
	nsEUCKRProber.cpp \
	nsEUCTWProber.cpp \
	nsEscCharsetProber.cpp \
	nsEscSM.cpp \
	nsGB2312Prober.cpp \
	nsHebrewProber.cpp \
	nsLatin1Prober.cpp \
	nsMBCSGroupProber.cpp \
	nsMBCSSM.cpp \
	nsSBCSGroupProber.cpp \
	nsSBCharSetProber.cpp \
	nsSJISProber.cpp \
	nsUTF8Prober.cpp \
	nsUniversalDetector.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libchardet

all: $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	@$(RANLIB) $(LIB).a

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c -o $@ $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

CharDistribution.o: CharDistribution.h
CharDistribution.o: nscore.h
CharDistribution.o: prtypes.h
CharDistribution.o: nstypes.h
CharDistribution.o: nsError.h
CharDistribution.o: JISFreq.tab
CharDistribution.o: Big5Freq.tab
CharDistribution.o: EUCKRFreq.tab
CharDistribution.o: EUCTWFreq.tab
CharDistribution.o: GB2312Freq.tab
JpCntx.o: nscore.h
JpCntx.o: prtypes.h
JpCntx.o: nstypes.h
JpCntx.o: nsError.h
JpCntx.o: JpCntx.h
LangBulgarianModel.o: nsSBCharSetProber.h
LangBulgarianModel.o: nsCharSetProber.h
LangBulgarianModel.o: nscore.h
LangBulgarianModel.o: prtypes.h
LangBulgarianModel.o: nstypes.h
LangBulgarianModel.o: nsError.h
LangBulgarianModel.o: encodingNames.h
LangCyrillicModel.o: nsSBCharSetProber.h
LangCyrillicModel.o: nsCharSetProber.h
LangCyrillicModel.o: nscore.h
LangCyrillicModel.o: prtypes.h
LangCyrillicModel.o: nstypes.h
LangCyrillicModel.o: nsError.h
LangCyrillicModel.o: encodingNames.h
LangGreekModel.o: nsSBCharSetProber.h
LangGreekModel.o: nsCharSetProber.h
LangGreekModel.o: nscore.h
LangGreekModel.o: prtypes.h
LangGreekModel.o: nstypes.h
LangGreekModel.o: nsError.h
LangGreekModel.o: encodingNames.h
LangHebrewModel.o: nsSBCharSetProber.h
LangHebrewModel.o: nsCharSetProber.h
LangHebrewModel.o: nscore.h
LangHebrewModel.o: prtypes.h
LangHebrewModel.o: nstypes.h
LangHebrewModel.o: nsError.h
LangHebrewModel.o: encodingNames.h
LangHungarianModel.o: nsSBCharSetProber.h
LangHungarianModel.o: nsCharSetProber.h
LangHungarianModel.o: nscore.h
LangHungarianModel.o: prtypes.h
LangHungarianModel.o: nstypes.h
LangHungarianModel.o: nsError.h
LangHungarianModel.o: encodingNames.h
LangThaiModel.o: nsSBCharSetProber.h
LangThaiModel.o: nsCharSetProber.h
LangThaiModel.o: nscore.h
LangThaiModel.o: prtypes.h
LangThaiModel.o: nstypes.h
LangThaiModel.o: nsError.h
LangThaiModel.o: encodingNames.h
nsBig5Prober.o: nsBig5Prober.h
nsBig5Prober.o: nsCharSetProber.h
nsBig5Prober.o: nscore.h
nsBig5Prober.o: prtypes.h
nsBig5Prober.o: nstypes.h
nsBig5Prober.o: nsError.h
nsBig5Prober.o: encodingNames.h
nsBig5Prober.o: nsCodingStateMachine.h
nsBig5Prober.o: nsPkgInt.h
nsBig5Prober.o: CharDistribution.h
nsCharSetProber.o: nsCharSetProber.h
nsCharSetProber.o: nscore.h
nsCharSetProber.o: prtypes.h
nsCharSetProber.o: nstypes.h
nsCharSetProber.o: nsError.h
nsCharSetProber.o: encodingNames.h
nsCharSetProber.o: prmem.h
nsEUCJPProber.o: nsEUCJPProber.h
nsEUCJPProber.o: nsCharSetProber.h
nsEUCJPProber.o: nscore.h
nsEUCJPProber.o: prtypes.h
nsEUCJPProber.o: nstypes.h
nsEUCJPProber.o: nsError.h
nsEUCJPProber.o: encodingNames.h
nsEUCJPProber.o: nsCodingStateMachine.h
nsEUCJPProber.o: nsPkgInt.h
nsEUCJPProber.o: JpCntx.h
nsEUCJPProber.o: CharDistribution.h
nsEUCKRProber.o: nsEUCKRProber.h
nsEUCKRProber.o: nsCharSetProber.h
nsEUCKRProber.o: nscore.h
nsEUCKRProber.o: prtypes.h
nsEUCKRProber.o: nstypes.h
nsEUCKRProber.o: nsError.h
nsEUCKRProber.o: encodingNames.h
nsEUCKRProber.o: nsCodingStateMachine.h
nsEUCKRProber.o: nsPkgInt.h
nsEUCKRProber.o: CharDistribution.h
nsEUCTWProber.o: nsEUCTWProber.h
nsEUCTWProber.o: nsCharSetProber.h
nsEUCTWProber.o: nscore.h
nsEUCTWProber.o: prtypes.h
nsEUCTWProber.o: nstypes.h
nsEUCTWProber.o: nsError.h
nsEUCTWProber.o: encodingNames.h
nsEscCharsetProber.o: nsEscCharsetProber.h
nsEscCharsetProber.o: nsCharSetProber.h
nsEscCharsetProber.o: nscore.h
nsEscCharsetProber.o: prtypes.h
nsEscCharsetProber.o: nstypes.h
nsEscCharsetProber.o: nsError.h
nsEscCharsetProber.o: encodingNames.h
nsEscCharsetProber.o: nsCodingStateMachine.h
nsEscCharsetProber.o: nsPkgInt.h
nsEscCharsetProber.o: nsUniversalDetector.h
nsEscSM.o: nsCodingStateMachine.h
nsEscSM.o: nsPkgInt.h
nsEscSM.o: nscore.h
nsEscSM.o: prtypes.h
nsEscSM.o: nstypes.h
nsEscSM.o: nsError.h
nsEscSM.o: encodingNames.h
nsGB2312Prober.o: nsGB2312Prober.h
nsGB2312Prober.o: nsCharSetProber.h
nsGB2312Prober.o: nscore.h
nsGB2312Prober.o: prtypes.h
nsGB2312Prober.o: nstypes.h
nsGB2312Prober.o: nsError.h
nsGB2312Prober.o: encodingNames.h
nsGB2312Prober.o: nsCodingStateMachine.h
nsGB2312Prober.o: nsPkgInt.h
nsGB2312Prober.o: CharDistribution.h
nsHebrewProber.o: nsHebrewProber.h
nsHebrewProber.o: nsSBCharSetProber.h
nsHebrewProber.o: nsCharSetProber.h
nsHebrewProber.o: nscore.h
nsHebrewProber.o: prtypes.h
nsHebrewProber.o: nstypes.h
nsHebrewProber.o: nsError.h
nsHebrewProber.o: encodingNames.h
nsLatin1Prober.o: nsLatin1Prober.h
nsLatin1Prober.o: nsCharSetProber.h
nsLatin1Prober.o: nscore.h
nsLatin1Prober.o: prtypes.h
nsLatin1Prober.o: nstypes.h
nsLatin1Prober.o: nsError.h
nsLatin1Prober.o: encodingNames.h
nsLatin1Prober.o: prmem.h
nsMBCSGroupProber.o: nsMBCSGroupProber.h
nsMBCSGroupProber.o: encodingNames.h
nsMBCSGroupProber.o: nsSJISProber.h
nsMBCSGroupProber.o: nsCharSetProber.h
nsMBCSGroupProber.o: nscore.h
nsMBCSGroupProber.o: prtypes.h
nsMBCSGroupProber.o: nstypes.h
nsMBCSGroupProber.o: nsError.h
nsMBCSGroupProber.o: nsCodingStateMachine.h
nsMBCSGroupProber.o: nsPkgInt.h
nsMBCSGroupProber.o: JpCntx.h
nsMBCSGroupProber.o: CharDistribution.h
nsMBCSGroupProber.o: nsUTF8Prober.h
nsMBCSGroupProber.o: nsEUCJPProber.h
nsMBCSGroupProber.o: nsGB2312Prober.h
nsMBCSGroupProber.o: nsEUCKRProber.h
nsMBCSGroupProber.o: nsBig5Prober.h
nsMBCSGroupProber.o: nsUniversalDetector.h
nsMBCSSM.o: nsCodingStateMachine.h
nsMBCSSM.o: nsPkgInt.h
nsMBCSSM.o: nscore.h
nsMBCSSM.o: prtypes.h
nsMBCSSM.o: nstypes.h
nsMBCSSM.o: nsError.h
nsMBCSSM.o: encodingNames.h
nsSBCSGroupProber.o: prmem.h
nsSBCSGroupProber.o: prtypes.h
nsSBCSGroupProber.o: nstypes.h
nsSBCSGroupProber.o: nsSBCharSetProber.h
nsSBCSGroupProber.o: nsCharSetProber.h
nsSBCSGroupProber.o: nscore.h
nsSBCSGroupProber.o: nsError.h
nsSBCSGroupProber.o: encodingNames.h
nsSBCSGroupProber.o: nsSBCSGroupProber.h
nsSBCSGroupProber.o: nsHebrewProber.h
nsSBCharSetProber.o: nsSBCharSetProber.h
nsSBCharSetProber.o: nsCharSetProber.h
nsSBCharSetProber.o: nscore.h
nsSBCharSetProber.o: prtypes.h
nsSBCharSetProber.o: nstypes.h
nsSBCharSetProber.o: nsError.h
nsSBCharSetProber.o: encodingNames.h
nsSJISProber.o: nsSJISProber.h
nsSJISProber.o: nsCharSetProber.h
nsSJISProber.o: nscore.h
nsSJISProber.o: prtypes.h
nsSJISProber.o: nstypes.h
nsSJISProber.o: nsError.h
nsSJISProber.o: encodingNames.h
nsSJISProber.o: nsCodingStateMachine.h
nsSJISProber.o: nsPkgInt.h
nsSJISProber.o: JpCntx.h
nsSJISProber.o: CharDistribution.h
nsUTF8Prober.o: nsUTF8Prober.h
nsUTF8Prober.o: nsCharSetProber.h
nsUTF8Prober.o: nscore.h
nsUTF8Prober.o: prtypes.h
nsUTF8Prober.o: nstypes.h
nsUTF8Prober.o: nsError.h
nsUTF8Prober.o: encodingNames.h
nsUTF8Prober.o: nsCodingStateMachine.h
nsUTF8Prober.o: nsPkgInt.h
nsUniversalDetector.o: nscore.h
nsUniversalDetector.o: prtypes.h
nsUniversalDetector.o: nstypes.h
nsUniversalDetector.o: nsError.h
nsUniversalDetector.o: nsUniversalDetector.h
nsUniversalDetector.o: nsMBCSGroupProber.h
nsUniversalDetector.o: encodingNames.h
nsUniversalDetector.o: nsSJISProber.h
nsUniversalDetector.o: nsCharSetProber.h
nsUniversalDetector.o: nsCodingStateMachine.h
nsUniversalDetector.o: nsPkgInt.h
nsUniversalDetector.o: JpCntx.h
nsUniversalDetector.o: CharDistribution.h
nsUniversalDetector.o: nsUTF8Prober.h
nsUniversalDetector.o: nsEUCJPProber.h
nsUniversalDetector.o: nsGB2312Prober.h
nsUniversalDetector.o: nsEUCKRProber.h
nsUniversalDetector.o: nsBig5Prober.h
nsUniversalDetector.o: nsSBCSGroupProber.h
nsUniversalDetector.o: nsEscCharsetProber.h
nsUniversalDetector.o: nsLatin1Prober.h
