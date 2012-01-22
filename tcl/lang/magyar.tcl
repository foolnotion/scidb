# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

# ======================================================================
# Copyright: (C) 2011-2012 Gregor Cramer
# Copyright: (C) 2011-2012 Zoltan Tibenszky
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

# ======================================================================
# File encoding: utf-8
# ======================================================================

### global #############################################################
::mc::SortMapping		{Á A É E Í I Ó O Ö O Ő O Ú U Ü U Ű U á a é e í i ó o ö o ő o ú u ü u ű u}
::mc::AsciiMapping	{Á A É E Í I Ó O Ö O Ő O Ú U Ü U Ű U á a é e í i ó o ö o ő o ú u ü u ű}

::mc::Alignment		"Sorba rendezés(?)"
::mc::Apply				"Alkalmaz"
::mc::Background		"Háttér"
::mc::Black				"Sötét"
::mc::Bottom			"Bottom"
::mc::Cancel			"Mégse"
::mc::Clear				"Törlése"
::mc::Close				"Bezár"
::mc::Color				"Szín"
::mc::Colors			"Színek"
::mc::Copy				"Másol"
::mc::Cut				"Kivág"
::mc::Dark				"Sötét"
::mc::Database			"Adatbázis"
::mc::Delete			"Töröl"
::mc::Edit				"Szerkeszt"
::mc::Escape			"Kilépés"
::mc::From				"From" ;# NEW
::mc::Game				"Játszma"
::mc::Layout			"Layout"
::mc::Left				"Left"
::mc::Lite				"Világos"
::mc::Modify			"Módosít"
::mc::No					"Nem"
::mc::NotAvailable	"Nem elérhető"
::mc::Number			"Szám"
::mc::OK					"OK"
::mc::Paste				"Beillesztés"
::mc::PieceSet			"Bábukészlet"
::mc::Preview			"Előnézet"
::mc::Redo				"Újra"
::mc::Reset				"Reset"
::mc::Right				"Right"
::mc::SelectAll		"Mindent kijelöl"
::mc::Texture			"Textúra"
::mc::Theme				"Téma"
::mc::To					"To" ;# NEW
::mc::Top				"Top"
::mc::Undo				"Visszavonás"
::mc::Variation		"Variáció"
::mc::White				"Világos"
::mc::Yes				"igen"

::mc::LogicalReset	"Reset" ;# NEW
::mc::LogicalAnd		"And" ;# NEW
::mc::LogicalOr		"Or" ;# NEW
::mc::LogicalNot		"Not" ;# NEW

::mc::King				"Király"
::mc::Queen				"Vezér"
::mc::Rook				"Bástya"
::mc::Bishop			"Futó"
::mc::Knight			"Huszár"
::mc::Pawn				"Gyalog"

### scidb ##############################################################
::scidb::mc::CannotOverwriteTheme	"Cannot overwrite theme %s." ;# NEW

### locale #############################################################
::locale::Pattern(decimalPoint)	"."
::locale::Pattern(thousandsSep)	","
::locale::Pattern(dateY)			"Y"
::locale::Pattern(dateM)			"Y M"
::locale::Pattern(dateD)			"Y. M. D."
::locale::Pattern(time)				"Y. M. D. h:m"
::locale::Pattern(normal:dateY)	"Y"
::locale::Pattern(normal:dateM)	"M/Y"
::locale::Pattern(normal:dateD)	"M/D/Y"

### widget #############################################################
::widget::mc::Apply		"&Alkalmaz"
::widget::mc::Cancel		"&Mégse"
::widget::mc::Clear		"&Törlés"
::widget::mc::Close		"&Bezárás"
::widget::mc::Ok		"&OK"
::widget::mc::Reset		"A&lapbeállítás"
::widget::mc::Update		"&Frissítés"
::widget::mc::Import		"&Importálás"
::widget::mc::Revert		"&Vissza"
::widget::mc::Previous		"Elő&ző"
::widget::mc::Next		"&Következő"
::widget::mc::First		"&Első"
::widget::mc::Last		"&Utolsó"

### util ###############################################################

::util::mc::IOErrorOccurred					"I/O hiba történt"

::util::mc::IOError(OpenFailed)				"Sikertelen megynitási művelet"
::util::mc::IOError(ReadOnly)					"Írásvédett adatbázis"
::util::mc::IOError(UnknownVersion)			"Ismeretlen kiterjesztés (UnknownVersion)"
::util::mc::IOError(UnexpectedVersion)		"unexpected file version"
::util::mc::IOError(Corrupted)				"Hibás fájl"
::util::mc::IOError(WriteFailed)				"Sikertelen írási művelet"
::util::mc::IOError(InvalidData)				"Érvénytelen adat (valószínűleg sérült fájl)"
::util::mc::IOError(ReadError)				"olvasási hiba"
::util::mc::IOError(EncodingFailed)			"namebase fájl nem írható"
::util::mc::IOError(MaxFileSizeExceeded)	"túl nagy fájlméret"
::util::mc::IOError(LoadFailed)				"Betöltési hiba (túl sok bejegyzés)"

### progress ###########################################################
::progress::mc::Progress "Progress" ;# NEW

### menu ###############################################################
::menu::mc::File						"&Fájl"
::menu::mc::Game						"&Játszma"
::menu::mc::View						"&Nézet"
::menu::mc::Help						"&Súgó"

::menu::mc::FileOpen					"Fájl &megnyitása"
::menu::mc::FileOpenURL				"Open &URL" ;# NEW
::menu::mc::FileOpenRecent			"Leg&utóbbi fájlok Megnyitása"
::menu::mc::FileNew					"Ú&j"
::menu::mc::FileExport				"E&xport..."
::menu::mc::FileImport				"PGN fájlok &importálás..."
::menu::mc::FileImportOne			"&PGN fájl importálás..."
::menu::mc::FileClose				"&Bezárás"
::menu::mc::FileQuit					"&Kilépés"

::menu::mc::GameNew					"Új &tábla"
::menu::mc::GameNewChess960		"N&ew Game: Chess 960" ;# NEW
::menu::mc::GameNewChess960Sym	"Ne&w Game: Chess 960 (symmetrical only)" ;# NEW
::menu::mc::GameNewShuffle			"New &Game: Shuffle Chess" ;# NEW
::menu::mc::GameSave					"Ját&szma Mentése"
::menu::mc::GameReplace				"Játszma &Felülírása"
::menu::mc::GameReplaceMoves		"Replace &Moves Only"

::menu::mc::HelpAbout				"&About Scidb" ;# NEW
::menu::mc::HelpContents			"&Tartalom"
::menu::mc::HelpWhatsNew			"&What's new" ;# NEW
::menu::mc::HelpRoadmap				"&Roadmap" ;# NEW
::menu::mc::HelpContactInfo		"C&ontact Information" ;# NEW
::menu::mc::HelpBugReport			"&Hiba jelentés (böngészőből)"
::menu::mc::HelpFeatureRequest	"&Feature Request (böngészőből)"

::menu::mc::ViewShowLog				"&Log fájl mutatása"
::menu::mc::ViewFullscreen			"Teljes képernyő"

::menu::mc::OpenFile					"Scidb fájl megnyitása"
::menu::mc::NewFile					"Scidb fájl létrehozása"
::menu::mc::ImportFiles				"PGN fájlok importálása"

::menu::mc::Theme						"Téma"
::menu::mc::Ctrl						"Ctrl"
::menu::mc::Shift						"Shift"

::menu::mc::AllScidbFiles			"Minden Scidb fájl"
::menu::mc::AllScidbBases			"Minde Scidb adatbázis"
::menu::mc::ScidBases				"Scid adatbázisok"
::menu::mc::ScidbBases				"Scidb adatbázisok"
::menu::mc::ChessBaseBases			"ChessBase adatbázisok"
::menu::mc::PGNFilesArchives		"PGN files/archives" ;# NEW
::menu::mc::PGNFiles					"PGN fájlok"
::menu::mc::PGNArchives				"PGN archives" ;# NEW

::menu::mc::FileNotAllowed			"'%s' féjlnév nem engedélyzett"
::menu::mc::TwoOrMoreDots			"Kettő vagy egymásutáni pontot tartalmaz."
::menu::mc::ForbiddenChars			"Tiltott karaktereket tartalmaz."

::menu::mc::Settings					"&Beállítások"

### load ###############################################################
::load::mc::FileIsCorrupt	"A %s fájl sérült:"

::load::mc::Loading					"%s betöltése"
::load::mc::ReadingOptionsFile	"beállítások beolvasása"
::load::mc::StartupFinished		"A betöltés befejeződött"

::load::mc::ECOFile					"ECO fájl"
::load::mc::EngineFile				"elemző program fájl"
::load::mc::SpellcheckFile			"Játékos-adatbázis fájl"
::load::mc::LocalizationFile		"lokalizációs fájl"
::load::mc::RatingList				"%s erősorrend lista"
::load::mc::WikipediaLinks			"Wikipedia linkek"
::load::mc::ChessgamesComLinks	"chessgames.com linkek"
::load::mc::Cities					"Városok"
::load::mc::PieceSet					"Bábukészlet"
::load::mc::Theme						"Téma"
::load::mc::Icons						"Ikonok"

### application ########################################################
::application::mc::Database				"&Adatbázis"
::application::mc::Board					"&Tábla"

::application::mc::DockWindow				"Ablak dokkolása"
::application::mc::UndockWindow			"Dokkolás visszavonása"
::application::mc::ChessInfoDatabase	"Chess Information Data Base"
::application::mc::Shutdown				"Kilépés..."

### application::board #################################################
::application::board::mc::ShowCrosstable		"Show tournament table for this game"

::application::board::mc::Tools					"Eszközök"
::application::board::mc::Control				"Kezelés"
::application::board::mc::GoIntoNextVar		"Következő variáció"
::application::board::mc::GoIntPrevVar			"Előző variáció"

::application::board::mc::KeyEditAnnotation	"A"
::application::board::mc::KeyEditComment		"C"
::application::board::mc::KeyEditMarks			"M"

### application::database ##############################################
::application::database::mc::Games						"&Játszmák"
::application::database::mc::Players					"&Játékosok"
::application::database::mc::Events						"&Versenyek"
::application::database::mc::Annotators				"&Elemző"

::application::database::mc::File						"Fájl"
::application::database::mc::SymbolSize				"Symbol Size"
::application::database::mc::Large						"Nagy"
::application::database::mc::Medium						"Közepes"
::application::database::mc::Small						"Kicsi"
::application::database::mc::Tiny						"Apró"
::application::database::mc::Empty						"üres"
::application::database::mc::None						"nincs"
::application::database::mc::Failed						"meghiúsult"
::application::database::mc::LoadMessage				"Adatbázis megnyitása: %s"
::application::database::mc::UpgradeMessage			"Upgrading Database %s" ;# NEW
::application::database::mc::CannotOpenFile			"A fájl nem nyitható meg olvasásra: '%s'."
::application::database::mc::EncodingFailed			"Encoding %s failed."
::application::database::mc::DatabaseAlreadyOpen	"Az '%s' adatbázis már meg van nyitva."
::application::database::mc::Properties				"Tulajdonságok"
::application::database::mc::Preload					"Preload"
::application::database::mc::MissingEncoding			"Missing encoding %s (using %s instead)"
::application::database::mc::DescriptionTooLarge	"Túl hosszú leírás."
::application::database::mc::DescrTooLargeDetail	"The entry contains %d characters, but only %d characters are allowed."
::application::database::mc::ClipbaseDescription	"Ideiglenes adatbázis, nincs elmentve a lemezre."
::application::database::mc::HardLinkDetected		"Cannot load file '%file1' because it is already loaded as file '%file2'. This can only happen if hard links are involved." ;# NEW
::application::database::mc::HardLinkDetectedDetail "If we load this database twice the application may crash due to the usage of threads." ;# NEW

::application::database::mc::RecodingDatabase		"Recoding %s from %s to %s"
::application::database::mc::RecodedGames				"%s game(s) recoded"

::application::database::mc::GameCount					"Játszmák"
::application::database::mc::DatabasePath				"Adatbázis elérési útvonala"
::application::database::mc::DeletedGames				"Törölt játszmák"
::application::database::mc::Description				"Leírás"
::application::database::mc::Created					"Létrehozva"
::application::database::mc::LastModified				"Utoljára módosítva"
::application::database::mc::Encoding					"Encoding"
::application::database::mc::YearRange					"Year range"
::application::database::mc::RatingRange				"Rating range"
::application::database::mc::Result						"Result"
::application::database::mc::Score						"Score"
::application::database::mc::Type						"Type"
::application::database::mc::ReadOnly					"Csak olvasható"

::application::database::mc::ChangeIcon				"Ikon cseréje"
::application::database::mc::Recode						"Újrakódolás"
::application::database::mc::EditDescription			"Leírás szerkesztése"
::application::database::mc::EmptyClipbase			"Üres Clipbase"

::application::database::mc::T_Unspecific				"Unspecific"
::application::database::mc::T_Temporary				"Ideiglenes"
::application::database::mc::T_Work						"Munka"
::application::database::mc::T_Clipbase				"Clipbase"
::application::database::mc::T_MyGames					"Játszmáim"
::application::database::mc::T_Informant				"Informátor"
::application::database::mc::T_LargeDatabase			"Nagy adatbázis"
::application::database::mc::T_CorrespondenceChess	"Levelező sakk"  
::application::database::mc::T_EmailChess				"e-mail sakk"
::application::database::mc::T_InternetChess			"internet sakk"
::application::database::mc::T_ComputerChess			"számítógépes sakk"
::application::database::mc::T_Chess960				"Chess 960"
::application::database::mc::T_PlayerCollection		"Játékos adatlapok"
::application::database::mc::T_Tournament				"Verseny"
::application::database::mc::T_TournamentSwiss		"Svájci verseny"
::application::database::mc::T_GMGames					"GM Játszmák"
::application::database::mc::T_IMGames					"IM Játszmák"
::application::database::mc::T_BlitzGames				"Schnell játszmák"
::application::database::mc::T_Tactics					"Taktika"
::application::database::mc::T_Endgames				"Végjátékok"
::application::database::mc::T_Analysis				"Elemzések"
::application::database::mc::T_Training				"Edzések"
::application::database::mc::T_Match					"Match"
::application::database::mc::T_Studies					"Tanulmányok"
::application::database::mc::T_Jewels					"Gyöngyszemek"
::application::database::mc::T_Problems				"Problémák"
::application::database::mc::T_Patzer					"Patzer"
::application::database::mc::T_Gambit					"Gambit"
::application::database::mc::T_Important				"Important"
::application::database::mc::T_Openings				"Megnyitások"
::application::database::mc::T_OpeningsWhite			"Megnyitások világossal"
::application::database::mc::T_OpeningsBlack			"Megnyitások sötéttel"

::application::database::mc::OpenDatabase				"Adatbázis megnyitása"
::application::database::mc::NewDatabase				"Új adatbázis"
::application::database::mc::CloseDatabase			"Adatbázis bezárása: '%s'"
::application::database::mc::SetReadonly				"Set Database '%s' readonly" ;# NEW
::application::database::mc::SetWriteable				"Set Database '%s' writeable" ;# NEW

::application::database::mc::OpenReadonly				"Megynitás olvasásra"
::application::database::mc::OpenWriteable			"Megnyitás írásra"

::application::database::mc::UpgradeDatabase			"%s is an old format database that cannot be opened writeable.\n\nUpgrading will create a new version of the database and after that remove the original files.\n\nThis may take a while, but it only needs to be done one time.\n\nDo you want to upgrade this database now?" ;# NEW
::application::database::mc::UpgradeDatabaseDetail	"\"No\" will open the database readonly, and you cannot set it writeable." ;# NEW

### application::database::games #######################################
::application::database::games::mc::Control						"Control"
::application::database::games::mc::GameNumber					"Játszmaszám"

::application::database::games::mc::GotoFirstPage				"Játszma első lapja"
::application::database::games::mc::GotoLastPage				"Játszma utolsó lapja"
::application::database::games::mc::PreviousPage				"Játszma előző lapja"
::application::database::games::mc::NextPage						"Játszma következő"
::application::database::games::mc::GotoCurrentSelection		"Menj az aktuális kijelöléshez"
::application::database::games::mc::UseVerticalScrollbar		"függőleges csúszka használata"
::application::database::games::mc::UseHorizontalScrollbar	"vízszintes csúszka használata"
::application::database::games::mc::GotoEnteredGameNumber	"Menj a megadott játszmaszámhoz"

### application::database::players #####################################
::application::database::players::mc::EditPlayer				"Játékos adatok szerkesztése"
::application::database::players::mc::Score						"Score"
::application::database::players::mc::TooltipRating			"Rating: %s"

### application::database::annotators ##################################
::application::database::annotators::mc::F_Annotator		"Elemző"
::application::database::annotators::mc::F_Frequency		"Frequency"

::application::database::annotators::mc::Find				"Keres"
::application::database::annotators::mc::FindAnnotator	"elemző keresése"
::application::database::annotators::mc::ClearEntries		"bejegyzések törlése"
::application::database::annotators::mc::NotFound			"Nem található."

### application::pgn ###################################################
::application::pgn::mc::Command(move:comment)			"Set Comment"
::application::pgn::mc::Command(move:marks)				"Set Marks"
::application::pgn::mc::Command(move:annotation)		"Set Annotation/Comment/Marks"
::application::pgn::mc::Command(move:append)				"Lépés hozzáadása"
::application::pgn::mc::Command(move:nappend)			"Add Moves" ;# NEW
::application::pgn::mc::Command(move:exchange)			"Lépés cseréje"
::application::pgn::mc::Command(variation:new)			"Új változat"
::application::pgn::mc::Command(variation:replace)		"Lépések felülírása"
::application::pgn::mc::Command(variation:truncate)	"változat csonkítása"
::application::pgn::mc::Command(variation:first)		"Első változattá emelés"
::application::pgn::mc::Command(variation:promote)		"Változat főváltozattá emelése"
::application::pgn::mc::Command(variation:remove)		"változat törlése"
::application::pgn::mc::Command(variation:mainline)	"új főváltozat"
::application::pgn::mc::Command(variation:insert)		"Lépések beszúrása"
::application::pgn::mc::Command(variation:exchange)	"Lépések cseréje"
::application::pgn::mc::Command(strip:moves)				"Lépések az elejétől"
::application::pgn::mc::Command(strip:truncate)			"Moves to the end"
::application::pgn::mc::Command(strip:annotations)		"Annotations"
::application::pgn::mc::Command(strip:info)				"Move Information" ;# NEW
::application::pgn::mc::Command(strip:marks)				"Marks"
::application::pgn::mc::Command(strip:comments)			"Megjegyzések"
::application::pgn::mc::Command(strip:variations)		"változatok"
::application::pgn::mc::Command(copy:comments)			"Copy Comments" ;# NEW
::application::pgn::mc::Command(move:comments)			"Move Comments" ;# NEW
::application::pgn::mc::Command(game:clear)				"Jétszma törlése"
::application::pgn::mc::Command(game:transpose)			"Transpose Game"

::application::pgn::mc::StartTrialMode						"Start Trial Mode"
::application::pgn::mc::StopTrialMode						"Stop Trial Mode"
::application::pgn::mc::Strip									"Strip"
::application::pgn::mc::InsertDiagram						"Diagram beillesztése"
::application::pgn::mc::InsertDiagramFromBlack			"Diagram beillesztése sötét nézőpontjából"
::application::pgn::mc::SuffixCommentaries				"Suffixed Commentaries"
::application::pgn::mc::StripOriginalComments			"Strip original comments" ;# NEW

::application::pgn::mc::AddNewGame							"Mentés: új játszma hozzáadása %s-hez..."
::application::pgn::mc::ReplaceGame							"Mentés: Játszma felülírása %s-ben..."
::application::pgn::mc::ReplaceMoves						"Mentés: Replace Moves Only in Game"

::application::pgn::mc::ColumnStyle							"Column Style"
::application::pgn::mc::UseParagraphSpacing				"Use Paragraph Spacing"
::application::pgn::mc::ShowMoveInfo						"Show Move Information" ;# NEW
::application::pgn::mc::BoldTextForMainlineMoves		"Főváltozat félkövér betűkkel"
::application::pgn::mc::ShowDiagrams						"Diagramok mutatása"
::application::pgn::mc::Languages							"Nyelvek"
::application::pgn::mc::CollapseVariations				"Változatok elrejtése"
::application::pgn::mc::ExpandVariations					"Változatok kibontása"
::application::pgn::mc::EmptyGame							"Empty Game"

::application::pgn::mc::NumberOfMoves						"(fél)lépésszám (a főváltozatban):"
::application::pgn::mc::InvalidInput						"Érvénytelen input '%d'."
::application::pgn::mc::MustBeEven						"Inputnak páros számnak kell lennie."
::application::pgn::mc::MustBeOdd							"Inputnak páratlan számnak kell lennie."
::application::pgn::mc::ReplaceMovesSucceeded			"Game moves successfully replaced."
::application::pgn::mc::CannotOpenCursorFiles			"Cannot open cursor files: %s" ;# NEW

::application::pgn::mc::EditAnnotation						"Értékelés szerkesztése"
::application::pgn::mc::EditMoveInformation				"Edit move information" ;# NEW
::application::pgn::mc::EditCommentBefore					"Megjegyzés szerkesztése (lépés előtt)"
::application::pgn::mc::EditCommentAfter					"Megjegyzés szerkesztése (lépés után)"
::application::pgn::mc::EditPrecedingComment				"Legutóbbi megjegyzés szerkesztése"
::application::pgn::mc::EditTrailingComment				"Záró megjegyzés szerkesztése"
::application::pgn::mc::EditMarks							"Edit marks"
::application::pgn::mc::Display								"Kijelző"
::application::pgn::mc::None									"none"

### application::tree ##################################################
::application::tree::mc::Total							"Teljes"
::application::tree::mc::Control							"Control"
::application::tree::mc::ChooseReferenceBase			"Válassz referencia adatbázist"
::application::tree::mc::ReferenceBaseSwitcher		"Referencia adatbázis váltó"
::application::tree::mc::Numeric							"Numerikus"
::application::tree::mc::Bar								"Bar"
::application::tree::mc::StartSearch					"Keresés indítása"
::application::tree::mc::StopSearch						"Keresés leállítása"
::application::tree::mc::UseExactMode					"Pozíció keresése"
::application::tree::mc::UseFastMode					"Gyorsított keresés"
::application::tree::mc::UseQuickMode					"Gyors keresés"
::application::tree::mc::AutomaticSearch				"Automatikus keresés"
::application::tree::mc::LockReferenceBase			"Referencia adatbázis zárolása"
::application::tree::mc::TransparentBar				"Transparent bar"

::application::tree::mc::FromWhitesPerspective		"Világos nézőpontjából"
::application::tree::mc::FromBlacksPerspective		"Sötét nézőpontjából"
::application::tree::mc::FromSideToMovePerspective	"A lépésre következő játékos nézőpontjából"
::application::tree::mc::FromWhitesPerspectiveTip		"Score from whites perspective" ;# NEW
::application::tree::mc::FromBlacksPerspectiveTip		"Score from blacks perspective" ;# NEW

::application::tree::mc::TooltipAverageRating		"Average Rating (%s)"
::application::tree::mc::TooltipBestRating		"Best Rating (%s)"

::application::tree::mc::F_Number						"#"
::application::tree::mc::F_Move							"Lépés"
::application::tree::mc::F_Eco							"ECO"
::application::tree::mc::F_Frequency					"Frequency"
::application::tree::mc::F_Ratio							"Ratio"
::application::tree::mc::F_Score							"Score"
::application::tree::mc::F_Draws							"Döntetlenek"
::application::tree::mc::F_Performance					"Teljesítmény"
::application::tree::mc::F_AverageYear					"\u00f8 Év"
::application::tree::mc::F_LastYear						"Utoljára játszva"
::application::tree::mc::F_BestPlayer					"Legjobb játékos"
::application::tree::mc::F_FrequentPlayer				"Gyakori játékos"

::application::tree::mc::T_Number					"Numeration"
::application::tree::mc::T_AverageYear					"Average Year"
::application::tree::mc::T_FrequentPlayer				"Leggyakoribb játékos"

### board ##############################################################
::board::mc::CannotReadFile		"Fájl '%s' nem olvasható"
::board::mc::CannotFindFile		"Fájl '%s' nem található"
::board::mc::FileWillBeIgnored	"'%s' will be ignored (duplicate ID)"
::board::mc::IsCorrupt				"'%s' hibás (ismeretlen %s style '%s')"

::board::mc::ThemeManagement		"Theme Management"
::board::mc::Setup			"Beállítás"

::board::mc::Default				"Alapértelmezett"
::board::mc::WorkingSet				"Working Set"

### board::options #####################################################
::board::options::mc::Coordinates			"Koordináták"
::board::options::mc::SolidColor			"Solid Color"
::board::options::mc::EditList				"Lista szerkesztése"
::board::options::mc::Embossed				"Embossed"
::board::options::mc::Highlighting			"Kijelölés"
::board::options::mc::Border				"Határvonal"
::board::options::mc::SaveWorkingSet		"Save Working Set"
::board::options::mc::SelectedSquare		"Kijelölt mező"
::board::options::mc::ShowBorder			"Határvonal mutatása"
::board::options::mc::ShowCoordinates		"Koordináták mutatása"
::board::options::mc::ShowMaterialValues	"Anyageloszlás mutatása"
::board::options::mc::ShowBar					"Show Bar"
::board::options::mc::ShowSideToMove		"Lépésre jövő fél jelzése"
::board::options::mc::ShowSuggestedMove		"Ajánlott lépés mutatása"
::board::options::mc::SuggestedMove		"Ajánlott lépés"
::board::options::mc::Basic			"Basic"
::board::options::mc::PieceStyle		"Figura stílus"
::board::options::mc::SquareStyle		"Mező stílus"
::board::options::mc::Styles			"Stílusok"
::board::options::mc::Show			"Előnézet"
::board::options::mc::ChangeWorkingSet		"Edit Working Set"
::board::options::mc::CopyToWorkingSet		"Copy to Working Set"
::board::options::mc::NameOfPieceStyle		"Figura stílus nevének megadása"
::board::options::mc::NameOfSquareStyle		"Mező stílus nevének megadása"
::board::options::mc::NameOfThemeStyle		"Téma nevének megadása"
::board::options::mc::PieceStyleSaved		"Figura stílus '%s' elmentve: '%s'"
::board::options::mc::SquareStyleSaved		"Mező stílus '%s' elmentve: '%s'"
::board::options::mc::ChooseColors		"Válassz színeket"
::board::options::mc::SupersedeSuggestion	"Supersede/use suggested colors from square style"
::board::options::mc::CannotDelete		"'%s' nem törölhető."
::board::options::mc::IsWriteProtected		"'%s' fájl írásvédettd."
::board::options::mc::ConfirmDelete		"Biztosan törölni akarod '%s'-t?"
::board::options::mc::NoPermission		"'%s' nem törölhető.\nJogosultság megtagadva."
::board::options::mc::BoardSetup		"Tábla beállítás"
::board::options::mc::OpenTextureDialog		"Open Texture Dialog"

::board::options::mc::YouCannotReverse
	"Ez a művelet nem viszafordítható. '%s'fájl fizikailag törlésre kerül."

::board::options::mc::CannotUsePieceWorkingSet
	"Nem hozható létre új téma a kiválasztott %s figura stílussal.\n Először el kell mentened az új figurastílust vagy egy másik figura stílust kell választanod."

::board::options::mc::CannotUseSquareWorkingSet
	"Nem hozható létre új téma a kiválasztott %s mező stílussal.\n Először el kell mentened az új mező stílust vagy egy másik mező stílust kell választanod."

### board::piece #######################################################
::board::piece::mc::Start						"Start"
::board::piece::mc::Stop						"Stop"
::board::piece::mc::HorzOffset				"Vízszintes eltolás"
::board::piece::mc::VertOffset				"Függőleges eltolás"
::board::piece::mc::Gradient					"Gradiens"
::board::piece::mc::Fill						"Kitöltés"
::board::piece::mc::Stroke						"Stroke"
::board::piece::mc::Contour					"Kontúr"
::board::piece::mc::WhiteShape				"White Shape"
::board::piece::mc::PieceSelection			"Figurák kiválasztása"
::board::piece::mc::BackgroundSelection	"Háttér kiválasztása"
::board::piece::mc::Zoom						"Nagyítás"
::board::piece::mc::Shadow						"Árnyék"
::board::piece::mc::Opacity					"Opacity"
::board::piece::mc::ShadowDiffusion			"Shadow Diffusion"
::board::piece::mc::PieceStyleConf			"Piece Style Configuration"
::board::piece::mc::Offset						"Eltolás"
::board::piece::mc::Rotate						"Forgatás"
::board::piece::mc::CloseDialog				"Close dialog and throw away changes?"
::board::piece::mc::OpenTextureDialog		"Open Texture Dialog"

### board::square ######################################################
::board::square::mc::SolidColor			"Solid Color"
::board::square::mc::CannotReadFile		"Fájl nem olvasható"
::board::square::mc::Zoom					"Nagyítás"
::board::square::mc::Offset				"Eltolás"
::board::square::mc::Rotate				"Forgatás"
::board::square::mc::Borderline			"Borderline"
::board::square::mc::Width					"Szélesség"
::board::square::mc::Opacity				"Opacity"
::board::square::mc::GapBetweenSquares	"Mezők közötti rés"
::board::square::mc::Highlighting		"Kijelölés"
::board::square::mc::Selected				"Kiválasztott"
::board::square::mc::SuggestedMove		"Ajénlott lépés"
::board::square::mc::Show					"Előnézet"
::board::square::mc::SquareStyleConf	"Mező stílus beállítása"
::board::square::mc::CloseDialog			"Close dialog and throw away changes?"

### board::texture #####################################################
::board::texture::mc::PreselectedOnly "Preselected only"

### gametable ##########################################################
::gametable::mc::DeleteGame				"Játszma megjelölése töröltként"
::gametable::mc::UndeleteGame				"Játszma törlésének visszavonása"
::gametable::mc::EditGameFlags			"Játszma flag-ek szerkesztése"
::gametable::mc::Custom						"Egyéni"

::gametable::mc::Monochrome				"Monokróm"
::gametable::mc::Transparent				"Átlátszó"
::gametable::mc::Relief						"Relief"
::gametable::mc::ShowIdn					"Show Chess 960 Position Number"
::gametable::mc::Icons						"Ikonok"
::gametable::mc::Abbreviations			"Rövidítések"

::gametable::mc::SortAscending			"Rendezés (növekvő)"
::gametable::mc::SortDescending			"Rendezés (csökkenő)"
::gametable::mc::SortOnAverageElo		"Rendezés átláagos Elo szerint (csökkenő)"
::gametable::mc::SortOnAverageRating		"Rendezés átlagos rating szerint (csökkenő)"
::gametable::mc::SortOnDate			"Rendezés dátum szerint (csökkenő)"
::gametable::mc::SortOnNumber			"Sort on game number (asscending)"
::gametable::mc::ReverseOrder			"Sorrend megfordítása"
::gametable::mc::NoMoves					"No moves"
::gametable::mc::NoMoreMoves				"No more moves" ;# NEW
::gametable::mc::WhiteRating				"Világos Rating"
::gametable::mc::BlackRating				"Sötét Rating"

::gametable::mc::Flags						"Flags"
::gametable::mc::PGN_CountryCode			"PGN országkód"
::gametable::mc::ISO_CountryCode			"ISO országkód"
::gametable::mc::ExcludeElo				"Exclude Elo"
::gametable::mc::IncludePlayerType		"Include player type"
::gametable::mc::ShowTournamentTable	"Tournament Table"

::gametable::mc::Long						"Hosszú"
::gametable::mc::Short						"Rövid"

::gametable::mc::AccelBrowse				"W"
::gametable::mc::AccelOverview			"O"
::gametable::mc::AccelTournTable			"T"
::gametable::mc::Space						"Space"

::gametable::mc::F_Number					"#"
::gametable::mc::F_White					"Világos"
::gametable::mc::F_Black					"Sötét"
::gametable::mc::F_Event					"Verseny"
::gametable::mc::F_Site						"Helyszín"
::gametable::mc::F_Date						"Dátum"
::gametable::mc::F_Result					"Eredmény"
::gametable::mc::F_Round					"Forduló"
::gametable::mc::F_Annotator				"Elemző"
::gametable::mc::F_Length					"Hossz"
::gametable::mc::F_Termination			"Termination"
::gametable::mc::F_EventMode				"Mode"
::gametable::mc::F_Eco						"ECO"
::gametable::mc::F_Flags					"Flags"
::gametable::mc::F_Material				"Material"
::gametable::mc::F_Acv						"ACV"
::gametable::mc::F_Idn						"960"
::gametable::mc::F_Position				"Position"
::gametable::mc::F_EventDate				"Event Date"
::gametable::mc::F_EventType				"Ev.Type"
::gametable::mc::F_Changed					"Changed"
::gametable::mc::F_Promotion				"Promotion"
::gametable::mc::F_UnderPromo				"Under-Promotion"
::gametable::mc::F_StandardPos			"Standard Position"
::gametable::mc::F_Chess960Pos			"9"
::gametable::mc::F_Opening					"Megynitás"
::gametable::mc::F_Variation				"Változat"
::gametable::mc::F_Subvariation			"Alváltozat"
::gametable::mc::F_Overview				"Áttekintés"
::gametable::mc::F_Key						"Nemzetközi ECO kód"

::gametable::mc::T_Number					"Number"
::gametable::mc::T_Acv						"Értékelések / Megjegyzések / Változatok"
::gametable::mc::T_WhiteRatingType		"White Rating Type"
::gametable::mc::T_BlackRatingType		"Black Rating Type"
::gametable::mc::T_WhiteCountry			"Világos nemzete"
::gametable::mc::T_BlackCountry			"Sötét nemzete"
::gametable::mc::T_WhiteTitle				"Világos címe"
::gametable::mc::T_BlackTitle				"Sötét címe"
::gametable::mc::T_WhiteType				"White Type"
::gametable::mc::T_BlackType				"Black Type"
::gametable::mc::T_WhiteSex				"Világos neme"
::gametable::mc::T_BlackSex				"Sötét neme"
::gametable::mc::T_EventCountry			"Verseny helyszíne (ország)"
::gametable::mc::T_EventType				"Verseny típusa"
::gametable::mc::T_Chess960Pos			"Chess 960 Position"
::gametable::mc::T_Deleted					"Törölve"
::gametable::mc::T_EngFlag					"English Language Flag"
::gametable::mc::T_OthFlag					"Other Language Flag"
::gametable::mc::T_Idn						"Chess 960 Position Number"
::gametable::mc::T_Annotations			"Értékelések"
::gametable::mc::T_Comments				"Megjegyzések"
::gametable::mc::T_Variations				"Változatok"
::gametable::mc::T_TimeMode				"Játékidő"

::gametable::mc::P_Rating					"Rating Score"
::gametable::mc::P_RatingType				"Rating Type"
::gametable::mc::P_Country					"Ország"
::gametable::mc::P_Title					"Cím"
::gametable::mc::P_Type						"Típus"
::gametable::mc::P_Date						"Dátum"
::gametable::mc::P_Mode						"Mód"
::gametable::mc::P_Sex						"Nem"
::gametable::mc::P_Name						"Név"

::gametable::mc::G_White					"Világos"
::gametable::mc::G_Black					"Sötét"
::gametable::mc::G_Event					"Verseny"

::gametable::mc::EventType(game)			"Játszma"
::gametable::mc::EventType(match)		"Match"
::gametable::mc::EventType(tourn)		"Tourn"
::gametable::mc::EventType(swiss)		"Swiss"
::gametable::mc::EventType(team)			"Team"
::gametable::mc::EventType(k.o.)			"K.O."
::gametable::mc::EventType(simul)		"Simul"
::gametable::mc::EventType(schev)		"Schev"

::gametable::mc::PlayerType(human)		"Human"
::gametable::mc::PlayerType(program)	"Computer"

::gametable::mc::GameFlags(w)				"Megnyitás világossal"
::gametable::mc::GameFlags(b)				"Megnyitás sötéttel"
::gametable::mc::GameFlags(m)				"Középjáték"
::gametable::mc::GameFlags(e)				"Végjáték"
::gametable::mc::GameFlags(N)				"Újítás"
::gametable::mc::GameFlags(p)				"Gyalogszerkezet"
::gametable::mc::GameFlags(T)				"Taktika"
::gametable::mc::GameFlags(K)				"Királyszárny"
::gametable::mc::GameFlags(Q)				"Vezérszárny"
::gametable::mc::GameFlags(!)				"Kíváló játszma"
::gametable::mc::GameFlags(?)				"Sakkvakság"
::gametable::mc::GameFlags(U)				"Felhasználó"
::gametable::mc::GameFlags(*)				"Legjobb játszma"
::gametable::mc::GameFlags(D)				"Decided Tournament"
::gametable::mc::GameFlags(G)				"Minta Játszma"
::gametable::mc::GameFlags(S)				"Stratágia"
::gametable::mc::GameFlags(^)				"Támadás"
::gametable::mc::GameFlags(~)				"Áldozat"
::gametable::mc::GameFlags(=)				"Védekezés"
::gametable::mc::GameFlags(M)				"Anyag"
::gametable::mc::GameFlags(P)				"Tisztjáték"
::gametable::mc::GameFlags(t)				"Taktikai hiba"
::gametable::mc::GameFlags(s)				"Stratégiai hiba"
::gametable::mc::GameFlags(C)				"Illegal Castling" ;# NEW
::gametable::mc::GameFlags(I)				"Szabálytalan lépés"

### playertable ########################################################
::playertable::mc::F_LastName					"Családnév"
::playertable::mc::F_FirstName				"Keresztnév"
::playertable::mc::F_FideID					"Fide azonosító"
::playertable::mc::F_Title						"Cím"
::playertable::mc::F_Frequency				"Frequency"

::playertable::mc::T_Federation				"Szövetség"
::playertable::mc::T_RatingType				"Rating Type"
::playertable::mc::T_Type						"Típus"
::playertable::mc::T_Sex						"Neme"
::playertable::mc::T_PlayerInfo				"Info Flag"

::playertable::mc::Find							"Keresés"
::playertable::mc::StartSearch				"Keresés indítása"
::playertable::mc::ClearEntries				"Bejegyzések törlése"
::playertable::mc::NotFound					"Nem található."

::playertable::mc::Name							"Név"
::playertable::mc::HighestRating				"Legmagasabb ELO pontszám"
::playertable::mc::MostRecentRating			"Legutolsó ELO pontszám"
::playertable::mc::DateOfBirth				"Születési dátum"
::playertable::mc::DateOfDeath				"Elhalálozás dátuma"
::playertable::mc::FideID						"Fide azonosító"

::playertable::mc::OpenInWebBrowser			"Mgnyitás böngészőben..."
::playertable::mc::OpenPlayerCard			"%s játékos adatlapjának megynitása"
::playertable::mc::OpenFileCard				"%s fájl adatlapjának megnyitása"
::playertable::mc::OpenFideRatingHistory	"Open Fide rating history"
::playertable::mc::OpenWikipedia				"Open Wikipedia biography"
::playertable::mc::OpenViafCatalog			"Open VIAF catalog"
::playertable::mc::OpenPndCatalog			"Open catalog of Deutsche Nationalbibliothek"
::playertable::mc::OpenChessgames			"chessgames.com game collection"
::playertable::mc::SeachIn365ChessCom		"Search in 365Chess.com" ;# NEW

### eventtable #########################################################
::eventtable::mc::Attendance	"Attendance" ;# NEW

### gamebar ############################################################
::gamebar::mc::StartPosition			"kiinduló állás"
::gamebar::mc::Players				"Játékosok"
::gamebar::mc::Event				"Verseny"
::gamebar::mc::Site				"Helyszín"
::gamebar::mc::SeparateHeader			"Különálló fejléc"
::gamebar::mc::ShowActiveAtBottom		"Aktív játszma mutátsa alul"
::gamebar::mc::ShowPlayersOnSeparateLines	"Játékosok külön sörökban való mutatása"
::gamebar::mc::DiscardChanges			"A játszma megváltozott.\n\nTényleg el akarod vetni a módosításokat?"
::gamebar::mc::DiscardNewGame			"Tényleg el akarod vetni ezt a játszmát?"
::gamebar::mc::NewGameFstPart			"Új"
::gamebar::mc::NewGameSndPart			"Játszma"
::gamebar::mc::Unlock				"Zárolás feloldása"

::gamebar::mc::LockGame					"Lock Game" ;# NEW
::gamebar::mc::CloseGame				"Close Game" ;# NEW

### browser ############################################################
::browser::mc::BrowseGame		"Játszma áttekintése"
::browser::mc::StartAutoplay		"Automatikus lejátszás indítása"
::browser::mc::StopAutoplay		"Automatikus lejátszás megállítása"
::browser::mc::GoForward		"Egy lépés előre"
::browser::mc::GoBackward		"Egy lépés vissza"
::browser::mc::GoForwardFast		"Előretekerés"
::browser::mc::GoBackFast		"Visszatekerés"
::browser::mc::GotoStartOfGame		"A játszma elejére"
::browser::mc::GotoEndOfGame		"A játszma végére"
::browser::mc::IncreaseBoardSize	"Tábla méretánek növelése"
::browser::mc::DecreaseBoardSize	"Tábla méretének növelése"
::browser::mc::GotoFirstGame		"Első játszmához"
::browser::mc::GotoLastGame		"Utolsó játszmához"

::browser::mc::LoadGame			"Játszma betöltése"
::browser::mc::MergeGame		"Játszmák összefésülése"

::browser::mc::IllegalMove		"Szabálytalan lépés"
::browser::mc::NoCastlingRights		"no castling rights"

### overview ###########################################################
::overview::mc::Overview		"Áttekintés"
::overview::mc::RotateBoard		"Tábla forgatása"
::overview::mc::AcceleratorRotate	"R"

### encoding ###########################################################
::encoding::mc::AutoDetect				"auto-detection" ;# NEW

::encoding::mc::Encoding		"Kódolás"
::encoding::mc::Description		"Leírás"
::encoding::mc::Languages		"Nyelvek (Betűtípusok)"
::encoding::mc::UseAutoDetection		"Use Auto-Detection" ;# NEW

::encoding::mc::ChooseEncodingTitle	"Kódolás válastása"

::encoding::mc::CurrentEncoding		"Jelenlegi kódolás:"
::encoding::mc::DefaultEncoding		"Alapértelmezett kódolás:"
::encoding::mc::SystemEncoding		"Rendszer kódolása:"

### setup ##############################################################
::setup::mc::Chess960Position		"Chess 960 position"
::setup::mc::SymmChess960Position	"Symmetrical chess 960 position"
::setup::mc::ShuffleChessPosition	"Shuffle chess position"

### setup board ########################################################
::setup::position::mc::SetStartPosition		"Kezdő pozíció beállítása"
::setup::position::mc::UsePreviousPosition	"Előző pozíció használata"

::setup::board::mc::SetStartBoard		"Set Start Board"
::setup::board::mc::SideToMove			"Lépésre következő fél"
::setup::board::mc::Castling			"Sáncolás"
::setup::board::mc::MoveNumber			"Lépésszám"
::setup::board::mc::EnPassantFile		"Menetközbeni ütés"
::setup::board::mc::StartPosition		"Kiinduló állás"
::setup::board::mc::Fen				"FEN"
::setup::board::mc::Clear			"Törlés"
::setup::board::mc::CopyFen			"Copy FEN to clipboard"
::setup::board::mc::Shuffle			"Keverés..."
::setup::board::mc::StandardPosition		"Standard Position"
::setup::board::mc::Chess960Castling		"Chess 960 castling"

::setup::board::mc::InvalidFen			"Invalid FEN"
::setup::board::mc::CastlingWithoutRook		"You have set castling rights, but at least one rook for castling is missing. This can happen only in handicap games. Are you sure that the castling rights are ok?"
::setup::board::mc::UnsupportedVariant		"Position is a start position but not a Shuffle Chess position. Are you sure?"

::setup::board::mc::Error(InvalidFen)		"Érvénytelen FEN."
::setup::board::mc::Error(NoWhiteKing)		"Világos király hiányzik."
::setup::board::mc::Error(NoBlackKing)		"Sötét király hiányzik."
::setup::board::mc::Error(DoubleCheck)		"Mindkét király sakkban áll."
::setup::board::mc::Error(OppositeCheck)	"A nem lépésre jövő fél királya sakkban áll."
::setup::board::mc::Error(TooManyWhitePawns)	"Túl sok világos gyalog."
::setup::board::mc::Error(TooManyBlackPawns)	"Túl sok sötét gyalog."
::setup::board::mc::Error(TooManyWhitePieces)	"Túl sok világos tiszt."
::setup::board::mc::Error(TooManyBlackPieces)	"Túl sok sötét tiszt."
::setup::board::mc::Error(PawnsOn18)		"Gyalog az 1. vagy a 8. soron."
::setup::board::mc::Error(TooManyKings)		"Több mint két király."
::setup::board::mc::Error(TooManyWhite)		"Túl sok világos figura."
::setup::board::mc::Error(TooManyBlack)		"Túl sok sötét figura."
::setup::board::mc::Error(BadCastlingRights)	"Hibás sáncolási jogok."
::setup::board::mc::Error(InvalidCastlingRights)	"Unreasonable rook file(s) for castling."
::setup::board::mc::Error(InvalidCastlingFile)		"Invalid castling file."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"Castling needs rook files to be disambiguous (possibly they are set wrong)."
::setup::board::mc::Error(InvalidEnPassant)		"Unreasonable en passant file."
::setup::board::mc::Error(MultiPawnCheck)		"Kettő vagy több gyalog ad sakkot."
::setup::board::mc::Error(TripleCheck)			"Három vagy több figura ad sakkot."

### import #############################################################
::import::mc::ImportingPgnFile					"'%s' PGN file importálása"
::import::mc::Line						"Sor"
::import::mc::Column						"Oszlop"
::import::mc::GameNumber					"Játszma"
::import::mc::ImportedGames					"játszma %s  betöltve"
::import::mc::NoGamesImported					"Nem került játszma importálásra"
::import::mc::FileIsEmpty					"A fájl valószínűleg üres"
::import::mc::PgnImport						"PGN Importálás"
::import::mc::ImportPgnGame					"PGN játszma importálása"
::import::mc::ImportPgnVariation				"PGN Változat importálása"
::import::mc::ImportOK						"A PGN szöveg hiba és figyelmeztetés nélkül került betöltésre."
::import::mc::ImportAborted					"Importálás megszakítva."
::import::mc::TextIsEmpty					"PGN szöveg üres."
::import::mc::AbortImport					"Meg akarja szakítani a PGN importálást?"

::import::mc::DifferentEncoding					"Selected encoding %src does not match file encoding %dst."
::import::mc::DifferentEncodingDetails			"Recoding of the database will not be successful anymore after this action."
::import::mc::CannotDetectFigurineSet			"Cannot auto-detect a suitable figurine set." ;# NEW
::import::mc::CheckImportResult					"Please check whether the right figurine set is detected." ;# NEW
::import::mc::CheckImportResultDetail			"In seldom cases the auto-detection fails due to ambiguities." ;# NEW

::import::mc::EnterOrPaste					"Enter or paste a PGN-format %s in the frame above.\nAny errors importing the %s will be displayed here."
::import::mc::EnterOrPaste-Game					"játszma"
::import::mc::EnterOrPaste-Variation				"változat"

::import::mc::MissingWhitePlayerTag				"Hiányzó világos játékos"
::import::mc::MissingBlackPlayerTag				"Hiányzó sötét játékos"
::import::mc::MissingPlayerTags					"Hiányzó játékosok"
::import::mc::MissingResult					"Hiányzó eredmény (at end of move section)"
::import::mc::MissingResultTag					"Hiányzó eredmény (in tag section)"
::import::mc::InvalidRoundTag					"Érvénytelen foduló cimke"
::import::mc::InvalidResultTag					"Érvénytelen eredmény cimke"
::import::mc::InvalidDateTag					"Érvénytelen dátum cimke"
::import::mc::InvalidEventDateTag				"Invalid event date tag"
::import::mc::InvalidTimeModeTag				"Érvénytelen időbosztás cimke"
::import::mc::InvalidEcoTag					"Érvénytelen ECO cimke"
::import::mc::InvalidTagName					"Érvénytelen cimke név (kihagyva)"
::import::mc::InvalidCountryCode				"Érvénytelen országkód"
::import::mc::InvalidRating					"Érvénytelen értékszám"
::import::mc::InvalidNag					"Érvénytelen NAG"
::import::mc::BraceSeenOutsideComment			"\"\}\" seen outisde a comment in game (ignored)"
::import::mc::MissingFen					"Hiányzó FEN (változat cimke kihagyva)"
::import::mc::UnknownEventType					"Ismeretlen verseny típus"
::import::mc::UnknownTitle					"Ismeretlen cím (kihagyva)"
::import::mc::UnknownPlayerType					"Ismeretlen játkos típus (kihagyva)"
::import::mc::UnknownSex					"Ismeretlen nem (kihagyva)"
::import::mc::UnknownTermination				"Unknown termination reason"
::import::mc::UnknownMode					"Ismeretlen mód"
::import::mc::RatingTooHigh					"Túl magas érétkszám (kihagyva))"
::import::mc::TooManyNags					"Túl sok NAG (a későbbiek kihagyva)"
::import::mc::IllegalCastling					"Szabálytalan sáncolás"
::import::mc::IllegalMove					"Szabálytalan lépés"
::import::mc::UnsupportedVariant				"Unsupported chess variant"
::import::mc::DecodingFailed					"Sikertelen dekódolás"
::import::mc::ResultDidNotMatchHeaderResult			"Result did not match header result"
::import::mc::ValueTooLong					"Tag value is too long and will truncated to 255 characacters"
::import::mc::MaximalErrorCountExceeded		"Maximal error count exceeded; no more errors (of previous error type) will be reported"
::import::mc::MaximalWarningCountExceeded		"Maximal warning count exceeded; no more warnings (of previous warning type) will be reported"
::import::mc::InvalidToken					"Invalid token"
::import::mc::InvalidMove					"Érvénytelen lépés"
::import::mc::UnexpectedSymbol					"Váratlan szimbólum"
::import::mc::UnexpectedEndOfInput				"Unexpected end of input"
::import::mc::UnexpectedResultToken				"Unexpected result token"
::import::mc::UnexpectedTag						"Unexpected tag inside game"
::import::mc::UnexpectedEndOfGame				"Unexpected end of game (missing result)"
::import::mc::TagNameExpected						"Syntax error: Tag name expected"
::import::mc::TagValueExpected					"Syntax error: Tag value expected"
::import::mc::InvalidFen							"Invalid FEN"
::import::mc::UnterminatedString					"Unterminated string"
::import::mc::UnterminatedVariation				"Unterminated variation"
::import::mc::TooManyGames							"Too many games in database (aborted)"
::import::mc::GameTooLong							"Game too long (skipped)"
::import::mc::FileSizeExceeded					"Maximal file size (2GB) will be exceeded (aborted)"
::import::mc::TooManyPlayerNames					"Too many player names in database (aborted)"
::import::mc::TooManyEventNames					"Too many event names in database (aborted)"
::import::mc::TooManySiteNames					"Too many site names in database (aborted)"
::import::mc::TooManyRoundNames					"Too many round names in database (aborted)"
::import::mc::TooManyAnnotatorNames				"Too many annotator names in database (aborted)"
::import::mc::TooManySourceNames					"Too many source names in database (aborted)"
::import::mc::SeemsNotToBePgnText				"Seems not to be PGN text"
::import::mc::AbortedDueToInternalError		"Aborted due to an internal error" ;# NEW

### export #############################################################
::export::mc::FileSelection			"&File Selection"
::export::mc::OptionsSetup					"Beállítás&ok"
::export::mc::PageSetup				"&Oldalbeállítás"
::export::mc::DiagramSetup					"&Diagram Setup"
::export::mc::StyleSetup					"Stí&lus"
::export::mc::EncodingSetup				"&Kódolás"
::export::mc::TagsSetup						"&Tags" ;# NEW
::export::mc::NotationSetup				"&Notation" ;# NEW
::export::mc::AnnotationSetup				"&Annotation" ;# NEW
::export::mc::CommentsSetup				"&Comments" ;# NEW

::export::mc::Visibility					"Visibility" ;# NEW
::export::mc::HideDiagrams					"Hide Diagrams" ;# NEW
::export::mc::AllFromWhitePersp			"All From White's Perspective" ;# NEW
::export::mc::AllFromBlackPersp			"All From Black's Perspective" ;# NEW
::export::mc::ShowCoordinates				"Show Coordinates" ;# NEW
::export::mc::ShowSideToMove				"Show Side to Move" ;# NEW
::export::mc::ShowArrows					"Show Arrows" ;# NEW
::export::mc::ShowMarkers					"Show Markers" ;# NEW
::export::mc::Layout							"Layout" ;# NEW
::export::mc::PostscriptSpecials			"Postscript Specialities" ;# NEW
::export::mc::BoardSize						"Board Size" ;# NEW

::export::mc::Notation				"Notation"
::export::mc::Graphic				"Grafika"
::export::mc::Short				"Rövid"
::export::mc::Long				"Hosszú"
::export::mc::Algebraic				"Algebrai"
::export::mc::Correspondence			"Levelezési játszma"
::export::mc::Telegraphic			"Telegraphic"
::export::mc::FontHandling			"Betűk kezelése"
::export::mc::DiagramStyle					"Diagram Style" ;# NEW
::export::mc::UseImagesForDiagram		"Use images for diagram generation" ;# NEW
::export::mc::EmebedTruetypeFonts		"TrueType betűk beágyazása"
::export::mc::UseBuiltinFonts			"Használd a beépített betűkészletet"
::export::mc::SelectExportedTags			"Selection of exported tags" ;# NEW
::export::mc::ExcludeAllTags				"Exclude all tags" ;# NEW
::export::mc::IncludeAllTags				"Include all tags" ;# NEW
::export::mc::ExtraTags						"All other extra tags" ;# NEW
::export::mc::NoComments					"No comments" ;# NEW
::export::mc::AllLanguages					"All languages" ;# NEW
::export::mc::Significant					"Significant" ;# NEW
::export::mc::LanguageSelection			"Language selection" ;# NEW
::export::mc::MapTo							"Map to" ;# NEW
::export::mc::MapNagsToComment			"Map annotations to comments" ;# NEW
::export::mc::UnusualAnnotation			"Unusual annotations" ;# NEW
::export::mc::AllAnnotation				"All annotations" ;# NEW
::export::mc::UseColumnStyle				"Use column style" ;# NEW
::export::mc::MainlineStyle				"Main Line Style" ;# NEW
::export::mc::HideVariations				"Hide variations" ;# NEW

::export::mc::PdfFiles				"PDF fájlok"
::export::mc::HtmlFiles				"HTML fájlok"
::export::mc::TeXFiles				"TeX fájlok"

::export::mc::ExportDatabase			"Adatbázis exportálása"
::export::mc::ExportDatabaseTitle		"'%s' adatbézis exportálása"
::export::mc::ExportingDatabase			"'%s' exportálása '%s'fájlba"
::export::mc::Export				"Exportálás"
::export::mc::ExportedGames			"%s játszmá(k) exportálva"
::export::mc::NoGamesForExport			"Nincs kiválasztva exportálható játszma."
::export::mc::ResetDefaults			"Alapbeállítások visszaállítása"
::export::mc::UnsupportedEncoding		"%s kódolás nem használható PDF documentumokhoz. Kérem válaszzon másik kódolást."
::export::mc::DatabaseIsOpen			"'%s' adatbázis jelenleg meg van nyitva. A művelet végrehajtása előtt be kell zárnia."

::export::mc::BasicStyle			"Alap stílus"
::export::mc::GameInfo				"Játszma információ"
::export::mc::GameText				"Játszma szöveg"
::export::mc::Moves				"Lépések"
::export::mc::MainLine				"Fő változat"
::export::mc::Variation				"Változat"
::export::mc::Subvariation			"Alváltozat"
::export::mc::Figurines				"Figurines"
::export::mc::Hyphenation					"Hyphenation" ;# NEW
::export::mc::None							"(nessuno)"
::export::mc::Symbols				"Szimbólumok"
::export::mc::Comments				"Megjegyzések"
::export::mc::Result				"Eredmény"
::export::mc::Diagram				"Diagramm"
::export::mc::ColumnStyle					"Column Style" ;# NEW

::export::mc::Paper				"Papír"
::export::mc::Orientation			"Orientáció"
::export::mc::Margin				"Margó"
::export::mc::Format				"Formátum"
::export::mc::Size				"Méret"
::export::mc::Custom				"Egyedi"
::export::mc::Potrait				"Álló"
::export::mc::Landscape				"Fekvő"
::export::mc::Justification			"Igazítás"
::export::mc::Even				"Egész"
::export::mc::Columns				"Oszlopok"
::export::mc::One				"Egy"
::export::mc::Two				"Kettő"

::export::mc::DocumentStyle				"Document Style" ;# NEW
::export::mc::Article						"Article" ;# NEW
::export::mc::Report							"Report" ;# NEW
::export::mc::Book							"Book" ;# NEW

::export::mc::FormatName(scidb)			"Scidb"
::export::mc::FormatName(scid)			"Scid"
::export::mc::FormatName(pgn)			"PGN"
::export::mc::FormatName(pdf)			"PDF"
::export::mc::FormatName(html)			"HTML"
::export::mc::FormatName(tex)			"LaTeX"
::export::mc::FormatName(ps)			"Postscript"

::export::mc::Option(pgn,include_varations)		"Változatok exportálása"
::export::mc::Option(pgn,include_comments)		"Megegyzések exportálása"
::export::mc::Option(pgn,include_moveinfo)		"Export move information (as comments)" ;# NEW
::export::mc::Option(pgn,include_marks)			"Export marks (as comments)"
::export::mc::Option(pgn,use_scidb_import_format)	"Scidb Import Formátum használata"
::export::mc::Option(pgn,use_chessbase_format)		"ChessBase formátum használata"
::export::mc::Option(pgn,include_ply_count_tag)		"'PlyCount' cimke írása"
::export::mc::Option(pgn,include_termination_tag)	"'Termination' cimke írása"
::export::mc::Option(pgn,include_mode_tag)		"'Mode' cimke írása"
::export::mc::Option(pgn,include_opening_tag)		"'Opening', 'Variation', 'Subvariation' cimkék írása"
::export::mc::Option(pgn,include_setup_tag)		"'Setup' cimke írása (ha szükséges)"
::export::mc::Option(pgn,include_variant_tag)		"'Variant' cimke írása (ha szükséges"
::export::mc::Option(pgn,include_position_tag)		"'Position' cimke írása (ha szükséges)"
::export::mc::Option(pgn,include_time_mode_tag)		"'TimeMode' cimke írása (ha szükséges)"
::export::mc::Option(pgn,exclude_extra_tags)		"Exclude extraneous tags"
::export::mc::Option(pgn,indent_variations)		"Változatok behúzása"
::export::mc::Option(pgn,indent_comments)		"Megjegyzések behúzása"
::export::mc::Option(pgn,column_style)			"Oszlopstílus (soronként egy lépés)"
::export::mc::Option(pgn,symbolic_annotation_style)	"Symbolic annotation style (!, !?)"
::export::mc::Option(pgn,extended_symbolic_style)	"Extended symbolic annotation style (+=, +/-)"
::export::mc::Option(pgn,convert_null_moves)		"Convert null moves to comments"
::export::mc::Option(pgn,space_after_move_number)	"Add space after move numbers"
::export::mc::Option(pgn,shredder_fen)			"Write Shredder-FEN (default is X-FEN)"
::export::mc::Option(pgn,convert_lost_result_to_comment)	"Write comment for result '0-0'"
::export::mc::Option(pgn,append_mode_to_event_type)	"Add mode after event type"
::export::mc::Option(pgn,comment_to_html)		"Write comment in HTML style"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Exclude games with illegal moves"

### save/replace #######################################################
::dialog::save::mc::SaveGame			"Játszma mentése"
::dialog::save::mc::ReplaceGame			"Játszma kicserélése"
::dialog::save::mc::EditCharacteristics		"Edit Characteristics"
	
::dialog::save::mc::GameData			"Játszma adatai"
::dialog::save::mc::Event			"Esemény"

::dialog::save::mc::MatchesExtraTags		"Matches / Extraneous Tags"
::dialog::save::mc::PressToSelect		"Kiválasztáshoz nyomja meg a Ctrl+0-tól Ctrl+9-ig (vagy bal egérgomb)"
::dialog::save::mc::PressForWhole		"Press Alt-0 to Alt-9 (vagy jobb egérgomb) for whole data set"
::dialog::save::mc::EditTags			"Cimkék szerkesztése"
::dialog::save::mc::DeleteThisTag		"Törölni kívánja a '%s' cimkét?"
::dialog::save::mc::TagAlreadyExists		"'%s' cimke már létezik."
::dialog::save::mc::TagDeleted			"'%s' extra cimke (jelenelgi tartalma: '%s') törlése kerül."
::dialog::save::mc::TagNameIsReserved		"'%s' cimke név foglalt."
::dialog::save::mc::Locked			"Zárolva"
::dialog::save::mc::OtherTag			"Más cike"
::dialog::save::mc::NewTag			"Új cimke"
::dialog::save::mc::DeleteTag			"Cimke törlése"
::dialog::save::mc::SetToGameDate		"Set to game date"
::dialog::save::mc::SaveGameFailed		"A játszma mentése meghiúsult."
::dialog::save::mc::SaveGameFailedDetail	"See log for details."
::dialog::save::mc::SavingGameLogInfo		"(%white - %black, %event) játszma mentése a(z) '%base' adatbézisba"
::dialog::save::mc::CurrentBaseIsReadonly	"A jelenlegi '%s' adatbézis csak olvasható."
::dialog::save::mc::CurrentGameHasTrialMode	"Current game is in trial mode and cannot be saved." ;' NEW

::dialog::save::mc::LocalName			"He&lyi Név"
::dialog::save::mc::EnglishName			"A&ngol Név"
::dialog::save::mc::ShowRatingType		"É&rtékszám mutatása"
::dialog::save::mc::EcoCode			"&ECO"
::dialog::save::mc::Matches			"&Matches"
::dialog::save::mc::Tags			"&Cimkék"

::dialog::save::mc::Name			"Név"
::dialog::save::mc::NameFideID			"Név/Fide-Azonosító"
::dialog::save::mc::Value			"Érték"
::dialog::save::mc::Title			"Title"
::dialog::save::mc::Rating			"Értékszám"
::dialog::save::mc::Federation			"Szövetség"
::dialog::save::mc::Country			"Ország"
::dialog::save::mc::Type			"Típus"
::dialog::save::mc::Sex				"Nem/Típus"
::dialog::save::mc::Date			"Dátum"
::dialog::save::mc::EventDate			"Eseméyn dátuma"
::dialog::save::mc::Round			"Forduló"
::dialog::save::mc::Result			"Eredmény"
::dialog::save::mc::Termination			"Termination"
::dialog::save::mc::Annotator			"Annotator"
::dialog::save::mc::Site			"Helyszín"
::dialog::save::mc::Mode			"Mode"
::dialog::save::mc::TimeMode			"Time Mode"
::dialog::save::mc::Frequency			"Frequency"

::dialog::save::mc::GameBase			"Játszma adatbázis"
::dialog::save::mc::PlayerBase			"Játékos adatbázis"
::dialog::save::mc::EventBase			"Esemény adatbázis"
::dialog::save::mc::SiteBase			"Site Base"
::dialog::save::mc::AnnotatorBase		"Annotator Base"
::dialog::save::mc::History			"History"

::dialog::save::mc::InvalidEntry		"'%s' nem érényes bejegyzés."
::dialog::save::mc::InvalidRoundEntry		"'%s' nem érévnyes forduló bejegyzés."
::dialog::save::mc::InvalidRoundEntryDetail	"Érvényes bejegyzések pl. '4' vagy '6.1'.  nem megengedett"
::dialog::save::mc::RoundIsTooHigh		"A fordulók száma nem haladhatja meg a 256-t"
::dialog::save::mc::SubroundIsTooHigh		"Sub-round should be less than 256."
::dialog::save::mc::ImplausibleDate		"A jétszam dátuma ('%s') korábbi mint az esemény dátuma ('%s')."
::dialog::save::mc::InvalidTagName		"Érénytelen cimke név: '%s' (syntax error)."
::dialog::save::mc::Field			"'%s' mező: "
::dialog::save::mc::ExtraTag			"'%s'Extra cimke : "
::dialog::save::mc::InvalidNetworkAddress	"'%s' érvénytelen hálózati cíim '%s'."
::dialog::save::mc::InvalidCountryCode		"Érvénytelen országkód '%s'."
::dialog::save::mc::InvalidEventRounds		"Invalid number of event rounds '%s' (positive integer expected)."
::dialog::save::mc::InvalidPlyCount		"Invalid move count '%s' (positive integer expected)."
::dialog::save::mc::IncorrectPlyCount		"Incorrect move count '%s' (actual move count is %s)."
::dialog::save::mc::InvalidTimeControl		"Invalid time control field entry in '%s'."
::dialog::save::mc::InvalidDate			"'%s' érvénytelen dátum."
::dialog::save::mc::InvalidYear					"Invalid year '%s'."
::dialog::save::mc::InvalidMonth					"Invalid month '%s'."
::dialog::save::mc::InvalidDay					"Invalid day '%s'."
::dialog::save::mc::MissingYear					"Year is missing."
::dialog::save::mc::MissingMonth					"Month is missing."
::dialog::save::mc::StringTooLong				"Tag %tag%: string '%value%' is too long and will be truncated to '%trunc%'."
::dialog::save::mc::InvalidEventDate			"Cannot accept given event date: The difference between the year of the game and the year of the event should be less than 4 (restriction of Scid's database format)."
::dialog::save::mc::TagIsEmpty					"Tag '%s' is empty (will be discarded)."

### gamehistory ########################################################
::game::history::mc::GameHistory	"Game History" ;# NEW

### game ###############################################################
::game::mc::CloseDatabase				"Close Database" ;# NEW
::game::mc::CloseAllGames				"Close all open games of database '%s'?"
::game::mc::SomeGamesAreModified		"Some games of database '%s' are modified. Close anyway?"
::game::mc::AllSlotsOccupied			"All game slots are occupied."
::game::mc::ReleaseOneGame				"Please release one of the games before loading a new one."
::game::mc::GameAlreadyOpen			"Game is already open but modified. Discard modified version of this game?"
::game::mc::GameAlreadyOpenDetail	"'%s' will open a new game."
::game::mc::GameHasChanged				"Game %s has changed."
::game::mc::GameHasChangedDetail		"Probably this is not the expected game due to database changes."
::game::mc::CorruptedHeader			"Corrupted header in recovery file '%s'."
::game::mc::RenamedFile					"Renamed this file to '%s.bak'."
::game::mc::CannotOpen					"Cannot open recovery file '%s'."
::game::mc::GameRestored				"One game from last session restored."
::game::mc::GamesRestored				"%s games from last session restored."
::game::mc::OldGameRestored			"Egy játszma helyreállítva."
::game::mc::OldGamesRestored			"%s játszmák helyreállítva."
::game::mc::ErrorInRecoveryFile		"Hiba a helyreállító fájlban '%s'"
::game::mc::Recovery						"Recovery"
::game::mc::UnsavedGames		"A játszmabeli változtatások nincsenel elmentve."
::game::mc::DiscardChanges		"'%s' el fogja vetni a változtatásokat."
::game::mc::ShouldRestoreGame		"Legyen ez a játszma helyreállítva a következő indításkor?"
::game::mc::ShouldRestoreGames		"Legyenek ezek a játszmák helyreállítva a következő indításkor?"
::game::mc::NewGame			"Új játszma"
::game::mc::NewGames			"Új játszmák"
::game::mc::Created			"látrehozva"
::game::mc::ClearHistory				"Clear History" ;# NEW
::game::mc::RemoveSelectedGame		"Remove selected game from history" ;# NEW
::game::mc::GameDataCorrupted			"Game data is corrupted." ;# NEW
::game::mc::GameDecodingFailed		"Decoding of this game was not possible." ;# NEW

### languagebox ########################################################
::languagebox::mc::AllLanguages	"All languages"
::languagebox::mc::None				"None" ;# NEW

### datebox ############################################################
::widget::datebox::mc::Today		"Ma"
::widget::datebox::mc::Calendar		"Naptár..."
::widget::datebox::mc::Year		"Év"
::widget::datebox::mc::Month		"Hónap"
::widget::datebox::mc::Day		"Nap"

### genderbox ##########################################################
::genderbox::mc::Gender(m) "Férfi"
::genderbox::mc::Gender(f) "Nő"
::genderbox::mc::Gender(c) "Számítógép"

### terminationbox #####################################################
::terminationbox::mc::Normal		"Normál"
::terminationbox::mc::Unplayed			"Unplayed"
::terminationbox::mc::Abandoned		"Abandoned"
::terminationbox::mc::Adjudication	"Adjudication"
::terminationbox::mc::Death		"Death"
::terminationbox::mc::Emergency		"Emergency"
::terminationbox::mc::RulesInfraction	"Rules infraction"
::terminationbox::mc::TimeForfeit	"Time forfeit"
::terminationbox::mc::Unterminated	"Unterminated"

### eventmodebox #######################################################
::eventmodebox::mc::OTB				"Over the board"
::eventmodebox::mc::PM				"Correspondence"
::eventmodebox::mc::EM				"E-mail"
::eventmodebox::mc::ICS				"Internet Chess Server"
::eventmodebox::mc::TC				"Telecommunication"
::eventmodebox::mc::Analysis		"Analysis"
::eventmodebox::mc::Composition	"Composition"

### eventtypebox #######################################################
::eventtypebox::mc::Type(game)	"Egyedi játszma"
::eventtypebox::mc::Type(match)	"Páros mérkőzés"
::eventtypebox::mc::Type(tourn)	"Körmérkőzés"
::eventtypebox::mc::Type(swiss)	"Svájci verseny"
::eventtypebox::mc::Type(team)	"Csapat verseny"
::eventtypebox::mc::Type(k.o.)	"Kieséses verseny"
::eventtypebox::mc::Type(simul)	"Szimultán"
::eventtypebox::mc::Type(schev)	"Scheveningeni rensdzerű verseny"  

### timemodebox ########################################################
::timemodebox::mc::Mode(normal)	"Hagyományos"
::timemodebox::mc::Mode(rapid)	"Rapid"
::timemodebox::mc::Mode(blitz)	"Schnell"
::timemodebox::mc::Mode(bullet)	"Bullet"
::timemodebox::mc::Mode(corr)	"Levelezési"

### help ###############################################################
::help::mc::Contents					"&Contents" ;# NEW
::help::mc::Index						"&Index" ;# NEW
::help::mc::Search					"&Search" ;# NEW

::help::mc::Help						"Help" ;# NEW
::help::mc::MatchEntireWord		"Match entire word" ;# NEW
::help::mc::MatchCase				"Match case" ;# NEW
::help::mc::TitleOnly				"Search in titles only" ;# NEW
::help::mc::GoBack					"Go back one page (Alt-Left)" ;# NEW
::help::mc::GoForward				"Go forward one page (Alt-Right)" ;# NEW
::help::mc::GotoPage					"Go to page '%s'" ;# NEW
::help::mc::ExpandAllItems			"Expand all items" ;# NEW
::help::mc::CollapseAllItems		"Collapse all items" ;# NEW
::help::mc::SelectLanguage			"Select Language" ;# NEW
::help::mc::NoHelpAvailable		"No help files available for language Hungarian.\nPlease choose an alternative language\nfor the help dialog." ;# NEW
::help::mc::KeepLanguage			"Keep language %s for subsequent sessions?" ;# NEW
::help::mc::ParserError				"Error while parsing file %s." ;# NEW
::help::mc::NoMatch					"No match is found" ;# NEW
::help::mc::MaxmimumExceeded		"Maximal number of matches exceeded in some pages." ;# NEW
::help::mc::OnlyFirstMatches		"Only first %s matches per page will be shown." ;# NEW
::help::mc::HideIndex				"Hide index" ;# NEW
::help::mc::ShowIndex				"Show index" ;# NEW

::help::mc::FileNotFound			"File not found." ;# NEW
::help::mc::CantFindFile			"Can't find the file at %s." ;# NEW
::help::mc::IncompleteHelpFiles	"It seems that the help files are still incomplete. Sorry about that." ;# NEW
::help::mc::ProbablyTheHelp		"Probably the help page in a different language may be an alternative for you" ;# NEW
::help::mc::PageNotAvailable		"This page is not available" ;# NEW

::help::mc::Overview					"Overview" ;# NEW

### crosstable #########################################################
::crosstable::mc::TournamentTable	"Tournament Table"
::crosstable::mc::AverageRating		"Átlagos pontszám"
::crosstable::mc::Category		"Category"
::crosstable::mc::Games			"játszmák"
::crosstable::mc::Game			"játszma"
::crosstable::mc::ScoringSystem			"Scoring System" ;# NEW
::crosstable::mc::Tiebreak		"Tie-Break"
::crosstable::mc::Settings		"Beállítások"
::crosstable::mc::RevertToStart		"Kiinduló értékek visszaállítása"
::crosstable::mc::UpdateDisplay		"Képernyő frissítése"

::crosstable::mc::Traditional				"Traditional" ;# NEW
::crosstable::mc::Bilbao					"Bilbao" ;# NEW

::crosstable::mc::None				"None"
::crosstable::mc::Buchholz			"Buchholz"
::crosstable::mc::MedianBuchholz		"Median-Buchholz"
::crosstable::mc::ModifiedMedianBuchholz 	"Mod. Median-Buchholz"
::crosstable::mc::RefinedBuchholz		"Refined Buchholz"
::crosstable::mc::SonnebornBerger		"Sonneborn-Berger"
::crosstable::mc::Progressive			"Progressive Score"
::crosstable::mc::KoyaSystem			"Koya System"
::crosstable::mc::GamesWon			"Number of Games Won"
::crosstable::mc::GamesWonWithBlack		"Games Won with Black" ;# NEW
::crosstable::mc::ParticularResult		"Particular Result" ;# NEW
::crosstable::mc::TraditionalScoring	"Traditional Scoring" ;# NEW

::crosstable::mc::Crosstable			"Crosstable"
::crosstable::mc::Scheveningen			"Scheveningen"
::crosstable::mc::Swiss				"Swiss System"
::crosstable::mc::Match				"Match"
::crosstable::mc::Knockout			"Knockout"
::crosstable::mc::RankingList			"Ranking List"

::crosstable::mc::Order				"Order"
::crosstable::mc::Type				"Table Type"
::crosstable::mc::Score				"Score"
::crosstable::mc::Alphabetical			"Alphabetical"
::crosstable::mc::Rating			"Rating"
::crosstable::mc::Federation			"Federation"

::crosstable::mc::Debugging			"Hibakeresés"
::crosstable::mc::Display			"Kijelző"
::crosstable::mc::Style				"Stílus"
::crosstable::mc::Spacing			"Spacing"
::crosstable::mc::Padding			"Padding"
::crosstable::mc::ShowLog			"Eseméynnapló megnyitása"
::crosstable::mc::ShowHtml			"HTML megnyitása"
::crosstable::mc::ShowRating			"Rating"
::crosstable::mc::ShowPerformance		"Performance"
::crosstable::mc::ShowTiebreak			"Tiebreak"
::crosstable::mc::ShowOpponent			"Opponent (as Tooltip)"
::crosstable::mc::KnockoutStyle			"Knockout Table Style"
::crosstable::mc::Pyramid			"Pyramid"
::crosstable::mc::Triangle			"Triangle"

::crosstable::mc::CrosstableLimit	"The crosstable limit of %d players will be exceeded."
::crosstable::mc::CrosstableLimitDetail "'%s' is choosing another table mode."

### info ###############################################################
::info::mc::InfoTitle			"About %s"
::info::mc::Info			"Info"
::info::mc::About			"Névjegy"
::info::mc::Contributions		"Contributions"
::info::mc::License			"License"
::info::mc::Localization		"Localization"
::info::mc::Testing			"Testing"
::info::mc::References			"References"
::info::mc::System			"System"
::info::mc::FontDesign			"chess font design"
::info::mc::ChessPieceDesign		"chess piece design"
::info::mc::BoardThemeDesign		"Board theme design"
::info::mc::FlagsDesign			"Miniature flags design"
::info::mc::IconDesign			"Icon design"

::info::mc::Version			"Verzió"
::info::mc::Distributed			"This program is distributed under the terms of the GNU General Public License."
::info::mc::Inspired				"Scidb is inspired by Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
::info::mc::SpecialThanks		"Special thanks to Shane Hudson for his terrific work. His effort is the basis for this application."

::info::mc::Reference(PGN)			"is the accepted standard for textual representation of chess games and transfer between chess databases. Steven J. Edwards created the PGN standard and the document explaining it is available at many chess websites; here is one location for it: %url%."
::info::mc::Reference(Crafty)		"is one of the strongest free chess program. The author is Bob Hyatt. The Crafty ftp site is: %url%. The \"TB\" subdirectory at this site contains many tablebase files which can also be used in Scidb."
::info::mc::Reference(Stockfish)	"is an open-source chess engine based on Glaurung. Probably it is the strongest free chess engine available. Stockfish can be downloaded at %url%"
::info::mc::Reference(Toga)		"is probably the strongest free chess engine available. The authors are Thomas Gaksch and Fabien Letouzey. The Toga II site is %url%."
::info::mc::Reference(Fruit)		"Fruit is a chess engine developed by Fabien Letouzey and Joachim Rang, and is vice world computer chess champion 2005. This engine supports Chess960 and is two times winner of Chess960 Engine League. The Fruit site is %url%."
::info::mc::Reference(Phalanx)	"Phalanx's playing style is quite human-like; when it plays at full strength, it may be compared to a intermediate-to-strong club player; beginners will be right at home with it, too. The author of Phalanx is Dusan Dobes. You may find this chess engine at %url%."
::info::mc::Reference(Gully)		"The Gullydeckel chess playing program allows you to play a game of chess against a not too strong opponent. It has been written by Martin Borriss. The Gullydeckel site is %url%."
::info::mc::Reference(MicroMax)	"is probably the smallest C Chess program in existence. The Micro-Max site is %url%. Micro-Max is written by H.G. Muller."

### comment ############################################################
::comment::mc::CommentBeforeMove	"Megjegyzés lépés elé"
::comment::mc::CommentAfterMove		"Megjegyzés lépés utám"
::comment::mc::PrecedingComment		"Előző megjegyzés"
::comment::mc::TrailingComment		"Utolsó megjegyzés"
::comment::mc::Language			"Nyelv"
::comment::mc::AddLanguage		"Nyelv hozzáadása..."
::comment::mc::SwitchLanguage		"Nyelv váltása"
::comment::mc::FormatText		"Szöveg formázása"
::comment::mc::CopyText					"Copy text to" ;# NEW
::comment::mc::OverwriteContent		"Overwrite existing content?" ;# NEW
::comment::mc::AppendContent			"If \"no\" the text will be appended." ;# NEW

::comment::mc::Bold			"Félkövér"
::comment::mc::Italic			"Dőlt"
::comment::mc::Underline		"Aláhúzott"

::comment::mc::InsertSymbol		"Szimbólum be&illesztése..."
::comment::mc::MiscellaneousSymbols	"Miscellaneous Symbols"
::comment::mc::Figurine			"Figurális"

### annotation #########################################################
::annotation::mc::AnnotationEditor		"Annotation"
::annotation::mc::TooManyNags			"Too many annotations (the last one was ignored)."
::annotation::mc::TooManyNagsDetail		"Maximal %d annotations per ply allowed."

::annotation::mc::PrefixedCommentaries		"Prefixed Commentaries"
::annotation::mc::MoveAssesments		"Lépés értékelések"
::annotation::mc::PositionalAssessments		"Állás értékelések"
::annotation::mc::TimePressureCommentaries	"Időzavar jelölések"
::annotation::mc::AdditionalCommentaries	"További megjegyzések"
::annotation::mc::ChessBaseCommentaries		"ChessBase megjegyzések"

### marks ##############################################################
::marks::mc::MarksPalette			"Marks - Palette"

### move ###############################################################
::move::mc::ReplaceMove				"Lépés felülírása"
::move::mc::AddNewVariation			"Új változat hozzáadása"
::move::mc::NewMainLine				"Új főváltozat"
::move::mc::TryVariation			"Változat kipróbálása"
::move::mc::ExchangeMove			"Lépés cseréje"

::move::mc::GameWillBeTruncated	"Game will be truncated. Continue with '%s'?"

### log ################################################################
::log::mc::LogTitle		"Eseménynapló"
::log::mc::Warning		"Figyelmeztetés"
::log::mc::Error		"Hiba"
::log::mc::Information		"Információ"

### titlebox ############################################################
::titlebox::mc::Title(GM)	"Nagymester (FIDE)"
::titlebox::mc::Title(IM)	"Nemzetközo mester (FIDE)"
::titlebox::mc::Title(FM)	"FIDE mester (FIDE)"
::titlebox::mc::Title(CM)	"Mesterjelölt (FIDE)"
::titlebox::mc::Title(WGM)	"Női nagymester (FIDE)"
::titlebox::mc::Title(WIM)	"Női nemzetközi mester"
::titlebox::mc::Title(WFM)	"Női FIDE mester (FIDE)"
::titlebox::mc::Title(WCM)	"Női mesterjelölt (FIDE)"
::titlebox::mc::Title(HGM)	"Honorary Grandmaster (FIDE)"
::titlebox::mc::Title(NM)	"National Master (USCF)"
::titlebox::mc::Title(SM)	"Senior Master (USCF)"
::titlebox::mc::Title(LM)	"Life Master (USCF)"
::titlebox::mc::Title(CGM)	"Correspondence Grandmaster (ICCF)"
::titlebox::mc::Title(CSM)	"Correspondence Senior International Master (ICCF)"
::titlebox::mc::Title(CIM)	"Correspondence International Master (ICCF)"

### messagebox #########################################################
::dialog::mc::Ok				"&OK"
::dialog::mc::Cancel			"&Mégse"
::dialog::mc::Yes				"&Igen"
::dialog::mc::No				"&Nem"
::dialog::mc::Retry			"&Újra"
::dialog::mc::Abort			"&Megszakítás"
::dialog::mc::Ignore			"&Kihagyás"
::dialog::mc::Continue		"Con&tinue" ;# NEW

::dialog::mc::Error			"Hiba"
::dialog::mc::Warning		"Figyelmeztetés"
::dialog::mc::Information	"Információ"
::dialog::mc::Question		"Kérdés"

::dialog::mc::DontAskAgain	"Ne kérdezd meg újra"

### web ################################################################
::web::mc::CannotFindBrowser			"Nem található megfelelő böngésző."
::web::mc::CannotFindBrowserDetail	"Állítsa be a BROWSER környezeti változótba a hasznáni kívánt böngészőt."

### colormenu ##########################################################
::colormenu::mc::BaseColor			"Alap színek"
::colormenu::mc::UserColor			"Felhasználói színek"
::colormenu::mc::UsedColor			"Használt színek"
::colormenu::mc::RecentColor		"Legutóbbi színek"
::colormenu::mc::Texture			"Mintázat"
::colormenu::mc::OpenColorDialog	"Színek dialógusablak megnyitása"
::colormenu::mc::EraseColor		"Szín törlése"
::colormenu::mc::Close				"Bezár"

### table ##############################################################
::table::mc::Ok							"&Ok"
::table::mc::Cancel						"&Mégse"
::table::mc::Column						"Oszlop"
::table::mc::Table						"Tábla"
::table::mc::Configure					"Beállítás"
::table::mc::Hide							"Elrejt"
::table::mc::ShowColumn					"Oszlopok mutatása"
::table::mc::Foreground					"Előtér"
::table::mc::Background					"Háttér"
::table::mc::DisabledForeground		"Előtér letiltása"
::table::mc::SelectionForeground		"Előtér kiválasztása"
::table::mc::SelectionBackground		"Háttér kiválasztása"
::table::mc::HighlightColor			"Háttér kijelölése"
::table::mc::Stripes				"Csíkok"
::table::mc::MinWidth				"Minimális szélesség"
::table::mc::MaxWidth					"Maximális szélesség"
::table::mc::Separator					"Elválasztó"
::table::mc::AutoStretchColumn		"Oszlop automatikus méretezése"
::table::mc::FillColumn					"- Oszlop kitöltése -"
::table::mc::Preview						"Előnézet"
::table::mc::OptimizeColumn			"Oszlopszélesség optimalizálása"
::table::mc::OptimizeColumns			"Minden oszlop optimalizálása"
::table::mc::FitColumnWidth			"Fit column width"
::table::mc::FitColumns				"Fit all columns"
::table::mc::SqueezeColumns			"Squeeze all columns"
::table::mc::AccelFitColumns			"Ctrl+,"
::table::mc::AccelOptimizeColumns		"Ctrl+."
::table::mc::AccelSqueezeColumns		"Ctrl+#"

### choosecolor ########################################################
::dialog::choosecolor::mc::Ok			"&OK"
::dialog::choosecolor::mc::Cancel		"&Mégse"

::dialog::choosecolor::mc::BaseColors		"Alap színek"
::dialog::choosecolor::mc::UserColors		"Felhasználó színek"
::dialog::choosecolor::mc::RecentColors		"Legutóbbi színek"
::dialog::choosecolor::mc::OldColor		"Régi színek"
::dialog::choosecolor::mc::CurrentColor		"Aktuális színek"
::dialog::choosecolor::mc::Old			"Régi"
::dialog::choosecolor::mc::Current		"Aktuális"
::dialog::choosecolor::mc::Color		"Szín"
::dialog::choosecolor::mc::ColorSelection	"Színválasztás"
::dialog::choosecolor::mc::Red			"Vörös"
::dialog::choosecolor::mc::Green		"Zöld"
::dialog::choosecolor::mc::Blue			"Kék"
::dialog::choosecolor::mc::Hue			"Hue"
::dialog::choosecolor::mc::Saturation		"Saturation"
::dialog::choosecolor::mc::Value		"Érték"
::dialog::choosecolor::mc::Enter		"Bevitel"
::dialog::choosecolor::mc::AddColor		"A kiválasztott szín hozzáadaása a felhasználói színekhez"
::dialog::choosecolor::mc::ClickToEnter		"Kattintson a hexadecimális kódok beviteléhez"

### choosefont #########################################################
::dialog::choosefont::mc::Apply				"&Alkalmaz"
::dialog::choosefont::mc::Cancel				"&Mégse"
::dialog::choosefont::mc::Continue			"Foly&tat"
::dialog::choosefont::mc::FixedOnly			"&Monospaced fonts only"
::dialog::choosefont::mc::Family			"&Család"
::dialog::choosefont::mc::Font				"&Betűtípus"
::dialog::choosefont::mc::Ok				"&OK"
::dialog::choosefont::mc::Reset				"&Alapbeállítás"
::dialog::choosefont::mc::Size				"&Méret"
::dialog::choosefont::mc::Strikeout			"Stri&keout"
::dialog::choosefont::mc::Style				"S&tílus"
::dialog::choosefont::mc::Underline			"&Aláhúzás"
::dialog::choosefont::mc::Color				"Szín"

::dialog::choosefont::mc::Regular			"Regular" ;# NEW
::dialog::choosefont::mc::Bold				"Félkövér"
::dialog::choosefont::mc::Italic			"Dőlt"
{::dialog::choosefont::mc::Bold Italic}	"Félkövér Dőlt"

::dialog::choosefont::mc::Effects			"Effektusok"
::dialog::choosefont::mc::Filter			"Szűrő"
::dialog::choosefont::mc::Sample			"Minta"
::dialog::choosefont::mc::SearchTitle			"Searching for monospaced fonts"
::dialog::choosefont::mc::SeveralMinutes		"Ez a művelet kb. %d percig tart."
::dialog::choosefont::mc::FontSelection			"Betűtypus választása"
::dialog::choosefont::mc::Wait				"Kérem várjon"

### choosedir ##########################################################
::choosedir::mc::FileSystem		"File System" ;# NEW
::choosedir::mc::ShowPredecessor	"Show Predecessor" ;# NEW
::choosedir::mc::ShowTail			"Show Tail" ;# NEW
::choosedir::mc::Folder				"Könyvtár:"

### fsbox ##############################################################
::fsbox::mc::Name								"Name"
::fsbox::mc::Size								"Size"
::fsbox::mc::Modified						"Modified"

::fsbox::mc::Forward							"Forward to '%s'"
::fsbox::mc::Backward						"Backward to '%s'"
::fsbox::mc::Delete							"Delete"
::fsbox::mc::Rename							"Rename"
::fsbox::mc::Duplicate						"Duplicate"
::fsbox::mc::CopyOf							"Copy of %s"
::fsbox::mc::NewFolder						"New Folder"
::fsbox::mc::Layout							"Layout"
::fsbox::mc::ListLayout						"List Layout"
::fsbox::mc::DetailedLayout				"Detailed Layout"
::fsbox::mc::ShowHiddenDirs				"Mutasd a &rejtett könyvtárakat"
::fsbox::mc::ShowHiddenFiles				"Mutasd a &rejtett fájlokat és könyvtárakat"
::fsbox::mc::AppendToExisitingFile		"Játszmák hozzá&adása egy létező fájlhoz"
::fsbox::mc::Cancel							"&Cancel"
::fsbox::mc::Save								"Menté&s"
::fsbox::mc::Open								"&Open"

::fsbox::mc::AddBookmark					"Add Bookmark '%s'"
::fsbox::mc::RemoveBookmark				"Remove Bookmark '%s'"

::fsbox::mc::Filename						"Fájl &név:"
::fsbox::mc::Filenames						"Fájl &nevek:"
::fsbox::mc::FilesType						"Fájl &típusok:"
::fsbox::mc::FileEncoding					"File &encoding:"

::fsbox::mc::Favorites						"Favorites"
::fsbox::mc::LastVisited					"Last Visited"
::fsbox::mc::FileSystem						"Fájlredszer"
::fsbox::mc::Desktop							"Asztal"
::fsbox::mc::Home								"Home" ;# NEW

::fsbox::mc::SelectEncoding				"Select the encoding of the database (opens a dialog)"
::fsbox::mc::SelectWhichType				"Select which type of file are shown"
::fsbox::mc::TimeFormat						"%d/%m/%y %I:%M %p"

::fsbox::mc::CannotChangeDir				"Cannot change to the directory \"%s\".\nPermission denied."
::fsbox::mc::DirectoryRemoved				"Cannot change to the directory \"%s\".\nDirectory is removed."
::fsbox::mc::ReallyMove(file,w)			"Really move file '%s' to trash?"
::fsbox::mc::ReallyMove(file,r)			"Really move write-protected file '%s' to trash?"
::fsbox::mc::ReallyMove(folder,w)		"Really move folder '%s' to trash?"
::fsbox::mc::ReallyMove(folder,r)		"Really move write-protected folder '%s' to trash?"
::fsbox::mc::ReallyDelete(file,w)		"Really delete file '%s'? You cannot undo this operation."
::fsbox::mc::ReallyDelete(file,r)		"Really delete write-protected file '%s'? You cannot undo this operation."
::fsbox::mc::ReallyDelete(link,w)		"Really delete link to '%s'?"
::fsbox::mc::ReallyDelete(link,r)		"Really delete link to '%s'?"
::fsbox::mc::ReallyDelete(folder,w)		"Really delete folder '%s'? You cannot undo this operation."
::fsbox::mc::ReallyDelete(folder,r)		"Really delete write-protected folder '%s'? You cannot undo this operation."
::fsbox::mc::DeleteFailed					"Deletion of '%s' failed."
::fsbox::mc::CommandFailed					"Command '%s' failed."
::fsbox::mc::CopyFailed						"Copying of file '%s' failed: permission denied."
::fsbox::mc::CannotCopy						"Cannot create a copy because file '%s' is already exisiting."
::fsbox::mc::ReallyDuplicateFile			"Really duplicate this file?"
::fsbox::mc::ReallyDuplicateDetail		"This file has about %s. Duplicating this file may take some time."
::fsbox::mc::ErrorRenaming(folder)		"Error renaming folder '%old' to '%new': permission denied."
::fsbox::mc::ErrorRenaming(file)			"Error renaming file '%old' to '%new': permission denied."
::fsbox::mc::InvalidFileExt				"Cannot rename because '%s' has an invalid file extension."
::fsbox::mc::CannotRename					"Cannot rename to '%s' because this folder/file already exists."
::fsbox::mc::CannotCreate					"Cannot create folder '%s' because this folder/file already exists."
::fsbox::mc::ErrorCreate					"Error creating folder: permission denied."
::fsbox::mc::FilenameNotAllowed			"Filename '%s' is not allowed."
::fsbox::mc::ContainsTwoDots				"Contains two consecutive dots."
::fsbox::mc::ContainsReservedChars		"Contains reserved characters: %s."
::fsbox::mc::IsReservedName				"On some operating systems this is an reserved name."
::fsbox::mc::InvalidFileExtension		"Invalid file extension in '%s'."
::fsbox::mc::MissingFileExtension		"Missing file extension in '%s'."
::fsbox::mc::FileAlreadyExists			"File \"%s\" already exists.\n\nDo you want to overwrite it?"
::fsbox::mc::CannotOverwriteDirectory	"Cannot overwite directory '%s'."
::fsbox::mc::FileDoesNotExist				"File \"%s\" does not exist."
::fsbox::mc::DirectoryDoesNotExist		"Directory \"%s\" does not exist."
::fsbox::mc::CannotOpenOrCreate			"Cannot open/create '%s'. Please choose a directory."
::fsbox::mc::WaitWhileDuplicating		"Please wait while duplicating file..."

### toolbar ############################################################
::toolbar::mc::Toolbar		"Toolbar"
::toolbar::mc::Orientation	"Orientation"
::toolbar::mc::Alignment	"Alignment"
::toolbar::mc::IconSize		"Icon Size"

::toolbar::mc::Default		"Default"
::toolbar::mc::Small			"Small"
::toolbar::mc::Medium		"Medium"
::toolbar::mc::Large			"Large"

::toolbar::mc::Top			"Top"
::toolbar::mc::Bottom		"Bottom"
::toolbar::mc::Left			"Left"
::toolbar::mc::Right			"Right"
::toolbar::mc::Center		"Center"

::toolbar::mc::Flat			"Flat"
::toolbar::mc::Floating		"Floating"
::toolbar::mc::Hide			"Hide"

::toolbar::mc::Expand		"Expand"

### Countries ##########################################################
::country::mc::Afghanistan											"Afghanistan"
::country::mc::Netherlands_Antilles								"Netherlands Antilles"
::country::mc::Anguilla												"Anguilla"
::country::mc::Aboard_Aircraft									"Aboard Aircraft"
::country::mc::Aaland_Islands										"Aaland Islands"
::country::mc::Albania												"Albania"
::country::mc::Algeria												"Algeria"
::country::mc::Andorra												"Andorra"
::country::mc::Angola												"Angola"
::country::mc::Antigua												"Antigua and Barbuda"
::country::mc::Australasia											"Australasia"
::country::mc::Argentina											"Argentina"
::country::mc::Armenia												"Armenia"
::country::mc::Aruba													"Aruba"
::country::mc::American_Samoa										"American Samoa"
::country::mc::Antarctica											"Antarctica"
::country::mc::French_Southern_Territories					"French Southern Territories"
::country::mc::Australia											"Australia"
::country::mc::Austria												"Austria"
::country::mc::Azerbaijan											"Azerbaijan"
::country::mc::Bahamas												"Bahamas"
::country::mc::Bangladesh											"Bangladesh"
::country::mc::Barbados												"Barbados"
::country::mc::Basque												"Basque"
::country::mc::Burundi												"Burundi"
::country::mc::Belgium												"Belgium"
::country::mc::Benin													"Benin"
::country::mc::Bermuda												"Bermuda"
::country::mc::Bhutan												"Bhutan"
::country::mc::Bosnia_and_Herzegovina							"Bosnia and Herzegovina"
::country::mc::Belize												"Belize"
::country::mc::Belarus												"Belarus"
::country::mc::Bolivia												"Bolivia"
::country::mc::Brazil												"Brazil"
::country::mc::Bahrain												"Bahrain"
::country::mc::Brunei												"Brunei"
::country::mc::Botswana												"Botswana"
::country::mc::Bulgaria												"Bulgaria"
::country::mc::Burkina_Faso										"Burkina Faso"
::country::mc::Bouvet_Islands										"Bouvet Islands"
::country::mc::Central_African_Republic						"Central African Republic"
::country::mc::Cambodia												"Cambodia"
::country::mc::Canada												"Canada"
::country::mc::Catalonia											"Catalonia"
::country::mc::Cayman_Islands										"Cayman Islands"
::country::mc::Cocos_Islands										"Cocos Islands"
::country::mc::Congo													"Congo (Brazzaville)"
::country::mc::Chad													"Chad"
::country::mc::Chile													"Chile"
::country::mc::China													"China"
::country::mc::Ivory_Coast											"Ivory Coast"
::country::mc::Cameroon												"Cameroon"
::country::mc::DR_Congo												"DR Congo"
::country::mc::Cook_Islands										"Cook Islands"
::country::mc::Colombia												"Colombia"
::country::mc::Comoros												"Comoros"
::country::mc::Cape_Verde											"Cape Verde"
::country::mc::Costa_Rica											"Costa Rica"
::country::mc::Croatia												"Croatia"
::country::mc::Cuba													"Cuba"
::country::mc::Christmas_Island									"Christmas Island"
::country::mc::Cyprus												"Cyprus"
::country::mc::Czech_Republic										"Czech Republic"
::country::mc::Denmark												"Denmark"
::country::mc::Djibouti												"Djibouti"
::country::mc::Dominica												"Dominica"
::country::mc::Dominican_Republic								"Dominican Republic"
::country::mc::Ecuador												"Ecuador"
::country::mc::Egypt													"Egypt"
::country::mc::England												"England"
::country::mc::Eritrea												"Eritrea"
::country::mc::El_Salvador											"El Salvador"
::country::mc::Western_Sahara										"Western Sahara"
::country::mc::Spain													"Spain"
::country::mc::Estonia												"Estonia"
::country::mc::Ethiopia												"Ethiopia"
::country::mc::Faroe_Islands										"Faroe Islands"
::country::mc::Fiji													"Fiji"
::country::mc::Finland												"Finland"
::country::mc::Falkland_Islands									"Falkland Islands"
::country::mc::France												"France"
::country::mc::West_Germany										"West Germany"
::country::mc::Micronesia											"Micronesia"
::country::mc::Gabon													"Gabon"
::country::mc::Gambia												"Gambia"
::country::mc::Great_Britain										"Great Britain"
::country::mc::Guinea_Bissau										"Guinea-Bissau"
::country::mc::Gibraltar											"Gibraltar"
::country::mc::Guernsey												"Guernsey"
::country::mc::East_Germany										"East Germany"
::country::mc::Georgia												"Georgia"
::country::mc::Equatorial_Guinea									"Equatorial Guinea"
::country::mc::Germany												"Germany"
::country::mc::Ghana													"Ghana"
::country::mc::Guadeloupe											"Guadeloupe"
::country::mc::Greece												"Greece"
::country::mc::Grenada												"Grenada"
::country::mc::Greenland											"Greenland"
::country::mc::Guatemala											"Guatemala"
::country::mc::French_Guiana										"French Guiana"
::country::mc::Guinea												"Guinea"
::country::mc::Guam													"Guam"
::country::mc::Guyana												"Guyana"
::country::mc::Haiti													"Haiti"
::country::mc::Hong_Kong											"Hong Kong"
::country::mc::Heard_Island_and_McDonald_Islands			"Heard Island and McDonald Islands"
::country::mc::Honduras												"Honduras"
::country::mc::Hungary												"Hungary"
::country::mc::Isle_of_Man											"Isle of Man"
::country::mc::Indonesia											"Indonesia"
::country::mc::India													"India"
::country::mc::British_Indian_Ocean_Territory				"British Indian Ocean Territory"
::country::mc::Iran													"Iran"
::country::mc::Ireland												"Ireland"
::country::mc::Iraq													"Iraq"
::country::mc::Iceland												"Iceland"
::country::mc::Israel												"Israel"
::country::mc::Italy													"Italy"
::country::mc::British_Virgin_Islands							"British Virgin Islands"
::country::mc::Jamaica												"Jamaica"
::country::mc::Jersey												"Jersey"
::country::mc::Jordan												"Jordan"
::country::mc::Japan													"Japan"
::country::mc::Kazakhstan											"Kazakhstan"
::country::mc::Kenya													"Kenya"
::country::mc::Kosovo												"Kosovo"
::country::mc::Kyrgyzstan											"Kyrgyzstan"
::country::mc::Kiribati												"Kiribati"
::country::mc::South_Korea											"South Korea"
::country::mc::Saudi_Arabia										"Saudi Arabia"
::country::mc::Kuwait												"Kuwait"
::country::mc::Laos													"Laos"
::country::mc::Latvia												"Latvia"
::country::mc::Libya													"Libya"
::country::mc::Liberia												"Liberia"
::country::mc::Saint_Lucia											"Saint Lucia"
::country::mc::Lesotho												"Lesotho"
::country::mc::Lebanon												"Lebanon"
::country::mc::Liechtenstein										"Liechtenstein"
::country::mc::Lithuania											"Lithuania"
::country::mc::Luxembourg											"Luxembourg"
::country::mc::Macao													"Macao"
::country::mc::Madagascar											"Madagascar"
::country::mc::Morocco												"Morocco"
::country::mc::Malaysia												"Malaysia"
::country::mc::Malawi												"Malawi"
::country::mc::Moldova												"Moldova"
::country::mc::Maldives												"Maldives"
::country::mc::Mexico												"Mexico"
::country::mc::Mongolia												"Mongolia"
::country::mc::Marshall_Islands									"Marshall Islands"
::country::mc::Macedonia											"Macedonia"
::country::mc::Mali													"Mali"
::country::mc::Malta													"Malta"
::country::mc::Montenegro											"Montenegro"
::country::mc::Northern_Mariana_Islands						"Northern Mariana Islands"
::country::mc::Monaco												"Monaco"
::country::mc::Mozambique											"Mozambique"
::country::mc::Mauritius											"Mauritius"
::country::mc::Montserrat											"Montserrat"
::country::mc::Mauritania											"Mauritania"
::country::mc::Martinique											"Martinique"
::country::mc::Myanmar												"Myanmar"
::country::mc::Mayotte												"Mayotte"
::country::mc::Namibia												"Namibia"
::country::mc::Nicaragua											"Nicaragua"
::country::mc::New_Caledonia										"New Caledonia"
::country::mc::Netherlands											"Netherlands"
::country::mc::Nepal													"Nepal"
::country::mc::The_Internet										"The Internet"
::country::mc::Norfolk_Island										"Norfolk Island"
::country::mc::Nigeria												"Nigeria"
::country::mc::Niger													"Niger"
::country::mc::Northern_Ireland									"Northern Ireland"
::country::mc::Niue													"Niue"
::country::mc::Norway												"Norway"
::country::mc::Nauru													"Nauru"
::country::mc::New_Zealand											"New Zealand"
::country::mc::Oman													"Oman"
::country::mc::Pakistan												"Pakistan"
::country::mc::Panama												"Panama"
::country::mc::Paraguay												"Paraguay"
::country::mc::Pitcairn_Islands									"Pitcairn Islands"
::country::mc::Peru													"Peru"
::country::mc::Philippines											"Philippines"
::country::mc::Palestine											"Palestine"
::country::mc::Palau													"Palau"
::country::mc::Papua_New_Guinea									"Papua New Guinea"
::country::mc::Poland												"Poland"
::country::mc::Portugal												"Portugal"
::country::mc::North_Korea											"North Korea"
::country::mc::Puerto_Rico											"Puerto Rico"
::country::mc::French_Polynesia									"French Polynesia"
::country::mc::Qatar													"Qatar"
::country::mc::Reunion												"Reunion"
::country::mc::Romania												"Romania"
::country::mc::South_Africa										"South Africa"
::country::mc::Russia												"Russia"
::country::mc::Rwanda												"Rwanda"
::country::mc::Samoa													"Samoa"
::country::mc::Serbia_and_Montenegro							"Serbia and Montenegro"
::country::mc::Scotland												"Scotland"
::country::mc::At_Sea												"At Sea"
::country::mc::Senegal												"Senegal"
::country::mc::Seychelles											"Seychelles"
::country::mc::South_Georgia_and_South_Sandwich_Islands	"South Georgia and South Sandwich Islands"
::country::mc::Saint_Helena										"Saint Helena"
::country::mc::Singapore											"Singapore"
::country::mc::Jan_Mayen_and_Svalbard							"Svalbard and Jan Mayen"
::country::mc::Saint_Kitts_and_Nevis							"Saint Kitts and Nevis"
::country::mc::Sierra_Leone										"Sierra Leone"
::country::mc::Slovenia												"Slovenia"
::country::mc::San_Marino											"San Marino"
::country::mc::Solomon_Islands									"Solomon Islands"
::country::mc::Somalia												"Somalia"
::country::mc::Aboard_Spacecraft									"Aboard Spacecraft"
::country::mc::Saint_Pierre_and_Miquelon						"Saint Pierre and Miquelon"
::country::mc::Serbia												"Serbia"
::country::mc::Sri_Lanka											"Sri Lanka"
::country::mc::Sao_Tome_and_Principe							"Sao Tome and Principe"
::country::mc::Sudan													"Sudan"
::country::mc::Switzerland											"Switzerland"
::country::mc::Suriname												"Suriname"
::country::mc::Slovakia												"Slovakia"
::country::mc::Sweden												"Sweden"
::country::mc::Swaziland											"Swaziland"
::country::mc::Syria													"Syria"
::country::mc::Tanzania												"Tanzania"
::country::mc::Turks_and_Caicos_Islands						"Turks and Caicos Islands"
::country::mc::Czechoslovakia										"Czechoslovakia"
::country::mc::Tonga													"Tonga"
::country::mc::Thailand												"Thailand"
::country::mc::Tibet													"Tibet"
::country::mc::Tajikistan											"Tajikistan"
::country::mc::Tokelau												"Tokelau"
::country::mc::Turkmenistan										"Turkmenistan"
::country::mc::Timor_Leste											"Timor Leste"
::country::mc::Togo													"Togo"
::country::mc::Chinese_Taipei										"Taiwan"
::country::mc::Trinidad_and_Tobago								"Trinidad and Tobago"
::country::mc::Tunisia												"Tunisia"
::country::mc::Turkey												"Turkey"
::country::mc::Tuvalu												"Tuvalu"
::country::mc::United_Arab_Emirates								"United Arab Emirates"
::country::mc::Uganda												"Uganda"
::country::mc::Ukraine												"Ukraine"
::country::mc::United_States_Minor_Outlying_Islands		"United States Minor Outlying Islands"
::country::mc::Unknown												"(Unknown)"
::country::mc::Soviet_Union										"Soviet Union"
::country::mc::Uruguay												"Uruguay"
::country::mc::United_States_of_America						"United States of America"
::country::mc::Uzbekistan											"Uzbekistan"
::country::mc::Vanuatu												"Vanuatu"
::country::mc::Vatican												"Vatican"
::country::mc::Venezuela											"Venezuela"
::country::mc::Vietnam												"Vietnam"
::country::mc::Saint_Vincent_and_the_Grenadines				"Saint Vincent and the Grenadines"
::country::mc::US_Virgin_Islands									"US Virgin Islands"
::country::mc::Wallis_and_Futuna									"Wallis and Futuna"
::country::mc::Wales													"Wales"
::country::mc::Yemen													"Yemen"
::country::mc::Yugoslavia											"Yugoslavia"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzibar"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Mixed Team"

::country::mc::Africa_North										"Africa, North"
::country::mc::Africa_Sub_Saharan								"Africa, Sub-Saharan"
::country::mc::America_Caribbean									"America, Caribbean"
::country::mc::America_Central									"America, Central"
::country::mc::America_North										"America, North"
::country::mc::America_South										"America, South"
::country::mc::Antarctic											"Antarctic"
::country::mc::Asia_East											"Asia, East"
::country::mc::Asia_South_South_East							"Asia, South-South-East"
::country::mc::Asia_West_Central									"Asia, West-Central"
::country::mc::Europe												"Europe"
::country::mc::Europe_East											"Europe, East"
::country::mc::Oceania												"Oceania"
::country::mc::Stateless											"Stateless"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"Afrikaans"
::encoding::mc::Lang(ar)	"Arabic"
::encoding::mc::Lang(ast)	"Leonese"
::encoding::mc::Lang(az)	"Azerbaijani"
::encoding::mc::Lang(bat)	"Baltic"
::encoding::mc::Lang(be)	"Belarusian"
::encoding::mc::Lang(bg)	"Bulgarian"
::encoding::mc::Lang(br)	"Breton"
::encoding::mc::Lang(bs)	"Bosnian"
::encoding::mc::Lang(ca)	"Catalan"
::encoding::mc::Lang(cs)	"Czech"
::encoding::mc::Lang(cy)	"Welsh"
::encoding::mc::Lang(da)	"Danish"
::encoding::mc::Lang(de)	"German"
::encoding::mc::Lang(de+)	"Deutsch (reformed)" ;# NEW
::encoding::mc::Lang(el)	"Greek"
::encoding::mc::Lang(en)	"English"
::encoding::mc::Lang(eo)	"Esperanto"
::encoding::mc::Lang(es)	"Spanish"
::encoding::mc::Lang(et)	"Estonian"
::encoding::mc::Lang(eu)	"Basque"
::encoding::mc::Lang(fi)	"Finnish"
::encoding::mc::Lang(fo)	"Faroese"
::encoding::mc::Lang(fr)	"French"
::encoding::mc::Lang(fy)	"Frisian"
::encoding::mc::Lang(ga)	"Irish"
::encoding::mc::Lang(gd)	"Scottish"
::encoding::mc::Lang(gl)	"Galician"
::encoding::mc::Lang(he)	"Hebrew"
::encoding::mc::Lang(hi)	"Hindi"
::encoding::mc::Lang(hr)	"Croatian"
::encoding::mc::Lang(hu)	"Hungarian"
::encoding::mc::Lang(hy)	"Armenian"
::encoding::mc::Lang(ia)	"Interlingua"
::encoding::mc::Lang(is)	"Icelandic"
::encoding::mc::Lang(it)	"Italian"
::encoding::mc::Lang(iu)	"Inuktitut"
::encoding::mc::Lang(ja)	"Japanese"
::encoding::mc::Lang(ka)	"Georgian"
::encoding::mc::Lang(kk)	"Kazakh"
::encoding::mc::Lang(kl)	"Greenlandic"
::encoding::mc::Lang(ko)	"Korean"
::encoding::mc::Lang(ku)	"Kurdish"
::encoding::mc::Lang(ky)	"Kirghiz"
::encoding::mc::Lang(la)	"Latin"
::encoding::mc::Lang(lb)	"Luxembourgish"
::encoding::mc::Lang(lt)	"Lithuanian"
::encoding::mc::Lang(lv)	"Latvian"
::encoding::mc::Lang(mk)	"Macedonian"
::encoding::mc::Lang(mo)	"Moldovan"
::encoding::mc::Lang(ms)	"Malay"
::encoding::mc::Lang(mt)	"Maltese"
::encoding::mc::Lang(nl)	"Dutch"
::encoding::mc::Lang(no)	"Norwegian"
::encoding::mc::Lang(oc)	"Occitan"
::encoding::mc::Lang(pl)	"Polish"
::encoding::mc::Lang(pt)	"Portuguese"
::encoding::mc::Lang(rm)	"Romansh"
::encoding::mc::Lang(ro)	"Romanian"
::encoding::mc::Lang(ru)	"Russian"
::encoding::mc::Lang(se)	"Sami"
::encoding::mc::Lang(sk)	"Slovak"
::encoding::mc::Lang(sl)	"Slovenian"
::encoding::mc::Lang(sq)	"Albanian"
::encoding::mc::Lang(sr)	"Serbian"
::encoding::mc::Lang(sv)	"Swedish"
::encoding::mc::Lang(sw)	"Swahili"
::encoding::mc::Lang(tg)	"Tajik"
::encoding::mc::Lang(th)	"Thai"
::encoding::mc::Lang(tk)	"Turkmen"
::encoding::mc::Lang(tl)	"Tagalog"
::encoding::mc::Lang(tr)	"Turkish"
::encoding::mc::Lang(uk)	"Ukrainian"
::encoding::mc::Lang(uz)	"Uzbek"
::encoding::mc::Lang(vi)	"Vietnamese"
::encoding::mc::Lang(wa)	"Walloon"
::encoding::mc::Lang(wen)	"Sorbian"
::encoding::mc::Lang(hsb)	"Upper Sorbian" ;# NEW
::encoding::mc::Lang(dsb)	"Lower Sorbian" ;# NEW
::encoding::mc::Lang(zh)	"Chinese"

::encoding::mc::Font(hi)	"Devanagari"

### Calendar ###########################################################
::calendar::mc::OneMonthForward	"One month forward (Shift-Right)"
::calendar::mc::OneMonthBackward	"One month backward (Shift-Left)"
::calendar::mc::OneYearForward	"One year forward (Ctrl-Right)"
::calendar::mc::OneYearBackward	"One year backward (Ctrl-Left)"

::calendar::mc::Su	"Su"
::calendar::mc::Mo	"Mo"
::calendar::mc::Tu	"Tu"
::calendar::mc::We	"We"
::calendar::mc::Th	"Th"
::calendar::mc::Fr	"Fr"
::calendar::mc::Sa	"Sa"

::calendar::mc::Jan	"Jan"
::calendar::mc::Feb	"Feb"
::calendar::mc::Mar	"Mar"
::calendar::mc::Apr	"Apr"
::calendar::mc::May	"May"
::calendar::mc::Jun	"Jun"
::calendar::mc::Jul	"Jul"
::calendar::mc::Aug	"Aug"
::calendar::mc::Sep	"Sep"
::calendar::mc::Oct	"Oct"
::calendar::mc::Nov	"Nov"
::calendar::mc::Dec	"Dec"

::calendar::mc::MonthName(1)		"January"
::calendar::mc::MonthName(2)		"February"
::calendar::mc::MonthName(3)		"March"
::calendar::mc::MonthName(4)		"April"
::calendar::mc::MonthName(5)		"May"
::calendar::mc::MonthName(6)		"June"
::calendar::mc::MonthName(7)		"July"
::calendar::mc::MonthName(8)		"August"
::calendar::mc::MonthName(9)		"September"
::calendar::mc::MonthName(10)		"October"
::calendar::mc::MonthName(11)		"November"
::calendar::mc::MonthName(12)		"December"

::calendar::mc::WeekdayName(0)	"Sunday"
::calendar::mc::WeekdayName(1)	"Monday"
::calendar::mc::WeekdayName(2)	"Tuesday"
::calendar::mc::WeekdayName(3)	"Wednesday"
::calendar::mc::WeekdayName(4)	"Thursday"
::calendar::mc::WeekdayName(5)	"Friday"
::calendar::mc::WeekdayName(6)	"Saturday"

### remote #############################################################
::remote::mc::PostponedMessage "Opening of database \"%s\" is postponed until current operation will be finished."

# vi:set ts=3 sw=3:
