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
::mc::SortOrder		{A Á B C D E É F G H I Í J K L M N O Ó Ö Ő P Q R S T U Ú Ü Ű V W X Y Z a á b c d e é f g h i í j k l m n o ó ö ő p q r s t u ú ü ű v w x y z}

::mc::Key(Alt)			"Alt" ;# NEW
::mc::Key(Ctrl)		"Ctrl" ;# NEW
::mc::Key(Down)		"\u2193"
::mc::Key(End)			"End" ;# NEW
::mc::Key(Home)		"Home" ;# NEW
::mc::Key(Left)		"\u2190"
::mc::Key(Next)		"Page\u2193"	;# Page Down NEW
::mc::Key(Prior)		"Page\u2191"	;# Page Up NEW
::mc::Key(Right)		"\u2192"
::mc::Key(Shift)		"Shift" ;# NEW
::mc::Key(Up)			"\u2191"

::mc::Alignment		"Sorba rendezés(?)"
::mc::Apply				"Alkalmaz"
::mc::Archive			"Archive" ;# NEW
::mc::Background		"Háttér"
::mc::Black				"Sötét"
::mc::Bottom			"Alsó"	;#Alul??
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
::mc::Left				"Bal"
::mc::Lite				"Világos"
::mc::Modify			"Módosít"
::mc::No					"Nem"
::mc::NotAvailable	"Nem elérhető" ;# I put it back, since n/e has no meaning in hungarian, unlike n/a in english; Zoltan 2010.02.11
::mc::Number			"Szám"
::mc::OK					"OK"
::mc::Paste				"Beillesztés"
::mc::PieceSet			"Bábukészlet"
::mc::Preview			"Előnézet"
::mc::Redo				"Újra"
::mc::Remove			"Remove" ;# NEW
::mc::Reset				"Reset"
::mc::Right				"Jobb"
::mc::SelectAll		"Mindent kijelöl"
::mc::Texture			"Textúra"
::mc::Theme				"Téma"
::mc::To					"To" ;# NEW
::mc::Top				"Felső"  ;# felül
::mc::Undo				"Visszavonás"
::mc::Variation		"Variáció"
::mc::White				"Világos"
::mc::Yes				"igen"

::mc::LogicalReset	"Reset" ;# NEW
::mc::LogicalAnd		"És"
::mc::LogicalOr		"Vagy"
::mc::LogicalNot		"Nem"

::mc::King				"Király"
::mc::Queen				"Vezér"
::mc::Rook				"Bástya"
::mc::Bishop			"Futó"
::mc::Knight			"Huszár"
::mc::Pawn				"Gyalog"

### scidb ##############################################################
::scidb::mc::CannotOverwriteTheme	"A %s témát nem lehet felülírni."

### locale #############################################################
::locale::Pattern(decimalPoint)	"."
::locale::Pattern(thousandsSep)	","
::locale::Pattern(dateY)			"Y"
::locale::Pattern(dateM)			"Y M"
::locale::Pattern(dateD)			"Y. M. D."
::locale::Pattern(time)				"Y. M. D. h:m"
::locale::Pattern(normal:dateY)	"Y"
::locale::Pattern(normal:dateM)	"Y/M"
::locale::Pattern(normal:dateD)	"Y/M/D"

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
::widget::mc::Help		"&Help" ;# NEW

::widget::mc::Control(minimize)	"Minimize" ;# NEW
::widget::mc::Control(restore)	"Leave Full-screen" ;# NEW
::widget::mc::Control(close)	"Bezár"

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

::util::mc::SelectionOwnerDidntRespond		"Timeout during drop action: selection owner didn't respond." ;# NEW

### progress ###########################################################
::progress::mc::Progress							"Állapot"

::progress::mc::Message(preload-namebase)		"Pre-loading namebase data" ;# NEW
::progress::mc::Message(preload-tournament)	"Pre-loading tournament index" ;# NEW
::progress::mc::Message(preload-player)		"Pre-loading player index" ;# NEW
::progress::mc::Message(preload-annotator)	"Pre-loading annotator index" ;# NEW

::progress::mc::Message(read-index)				"Loading index data" ;# NEW
::progress::mc::Message(read-game)				"Loading game data" ;# NEW
::progress::mc::Message(read-namebase)			"Loading namebase data" ;# NEW
::progress::mc::Message(read-tournament)		"Loading tournament index" ;# NEW
::progress::mc::Message(read-player)			"Loading player index" ;# NEW
::progress::mc::Message(read-annotator)		"Loading annotator index" ;# NEW
::progress::mc::Message(read-source)			"Loading source index" ;# NEW
::progress::mc::Message(read-team)				"Loading team index" ;# NEW
::progress::mc::Message(read-init)				"Loading initialization data" ;# NEW

::progress::mc::Message(write-index)			"Writing index data" ;# NEW
::progress::mc::Message(write-game)				"Writing game data" ;# NEW
::progress::mc::Message(write-namebase)		"Writing namebase data" ;# NEW

### menu ###############################################################
::menu::mc::Theme							"Téma"

::menu::mc::AllScidbFiles				"Minden Scidb fájl"
::menu::mc::AllScidbBases				"Minde Scidb adatbázis"
::menu::mc::ScidBases					"Scid adatbázisok"
::menu::mc::ScidbBases					"Scidb adatbázisok"
::menu::mc::ChessBaseBases				"ChessBase adatbázisok"
::menu::mc::ScidbArchives				"Scidb archives" ;# NEW
::menu::mc::PGNFilesArchives			"PGN fájlok/arhívumok"
::menu::mc::PGNFiles						"PGN fájlok"
::menu::mc::PGNArchives					"PGN arhívumok"

::menu::mc::Language						"L&anguage" ;# NEW
::menu::mc::Toolbars						"&Toolbars" ;# NEW
::menu::mc::ShowLog						"&Log fájl mutatása"
::menu::mc::AboutScidb					"Scidb &Névjegy"
::menu::mc::Fullscreen					"&Teljes képernyő"
::menu::mc::LeaveFullscreen			"Leave &Teljes képernyő" ;# NEW "Leave Full-Screen"
::menu::mc::Help							"&Súgó"
::menu::mc::Contact						"&Contact (Web Browser)" ;# NEW
::menu::mc::Quit							"&Kilépés"
::menu::mc::Extras						"E&xtras" ;# NEW

::menu::mc::ContactBugReport			"&Hiba jelentés"
::menu::mc::ContactFeatureRequest	"&Feature Request" ;# NEW
::menu::mc::InstallChessBaseFonts	"Install ChessBase Fonts" ;# NEW

::menu::mc::OpenFile						"Scidb fájl megnyitása"
::menu::mc::NewFile						"Scidb fájl létrehozása"
::menu::mc::ImportFiles					"PGN fájlok importálása"
::menu::mc::Archiving					"Archiving" ;# NEW
::menu::mc::CreateArchive				"Create Archive" ;# NEW
::menu::mc::BuildArchive				"Create archive %s" ;# NEW
::menu::mc::Data							"%s data" ;# NEW

### load ###############################################################
::load::mc::SevereError				"Severe error during load of ECO file" ;# NEW
::load::mc::FileIsCorrupt			"A %s fájl sérült:"
::load::mc::ProgramAborting		"Program is aborting." ;# NEW

::load::mc::Loading					"%s betöltése"
::load::mc::ReadingOptionsFile	"beállítások beolvasása"
::load::mc::StartupFinished		"A betöltés befejeződött"
::load::mc::SystemEncoding	"System encoding is '%s'" ;# NEW

::load::mc::ECOFile					"ECO fájl"
::load::mc::EngineFile				"Elemző program fájl"
::load::mc::SpellcheckFile			"Játékos-adatbázis fájl"
::load::mc::LocalizationFile		"Lokalizációs fájl"
::load::mc::RatingList				"%s erősorrend lista"
::load::mc::WikipediaLinks			"Wikipedia linkek"
::load::mc::ChessgamesComLinks	"chessgames.com linkek"
::load::mc::Cities					"Városok"
::load::mc::PieceSet					"Bábukészlet"
::load::mc::Theme						"Téma"
::load::mc::Icons						"Ikonok"

### archive ############################################################
::archive::mc::CorruptedArchive			"Archive '%s' is corrupted." ;# NEW
::archive::mc::NotAnArchive				"'%s' is not an archive." ;# NEW
::archive::mc::CorruptedHeader			"Archive header in '%s' is corrupted." ;# NEW
::archive::mc::CannotCreateFile			"Failed to create file '%s'." ;# NEW
::archive::mc::FailedToExtractFile		"Failed to extract file '%s'." ;# NEW
::archive::mc::UnknownCompression		"Unknown compression method '%s'." ;# NEW
::archive::mc::ChecksumError				"Checksum error while extracting '%s'." ;# NEW
::archive::mc::ChecksumErrorDetail		"The extracted file '%s' will be corrupted." ;# NEW
::archive::mc::FileNotReadable			"File '%s' is not readable." ;# NEW
::archive::mc::UsingRawInstead			"Using compression method 'raw' instead." ;# NEW
::archive::mc::CannotOpenArchive			"Cannot open archive '%s'." ;# NEW
::archive::mc::CouldNotCreateArchive	"Could not create archive '%s'." ;# NEW

::archive::mc::PackFile						"Pack %s" ;# NEW
::archive::mc::UnpackFile					"Unpack %s" ;# NEW

### application ########################################################
::application::mc::Database				"&Adatbázis"
::application::mc::Board					"&Tábla"
::application::mc::MainMenu				"&Main Menu" ;# NEW

::application::mc::DockWindow				"Ablak dokkolása"
::application::mc::UndockWindow			"Dokkolás visszavonása"
::application::mc::ChessInfoDatabase	"Chess Information Data Base"
::application::mc::Shutdown				"Kilépés..."

### application::board #################################################
::application::board::mc::ShowCrosstable	"Mutasd a verseny kereszttábláját"

::application::board::mc::Tools				"Eszközök"
::application::board::mc::Control			"Kezelés"
::application::board::mc::GoIntoNextVar	"Következő variáció"
::application::board::mc::GoIntPrevVar		"Előző variáció"

::application::board::mc::Accel(edit-annotation)	"A"
::application::board::mc::Accel(edit-comment)		"C"
::application::board::mc::Accel(edit-marks)			"M"
::application::board::mc::Accel(add-new-game)		"S" ;# NEW
::application::board::mc::Accel(replace-game)		"R" ;# NEW
::application::board::mc::Accel(replace-moves)		"V" ;# NEW
::application::board::mc::Accel(trial-mode)			"T" ;# NEW

### application::database ##############################################
::application::database::mc::FileOpen						"Fájl megnyitása"
::application::database::mc::FileOpenRecent				"Legutóbbi fájlok Megnyitása"
::application::database::mc::FileNew						"Új"
::application::database::mc::FileExport					"Export..."
::application::database::mc::FileImport					"PGN fájlok importálás..."
::application::database::mc::FileCreate					"Create Archive..." ;# NEW
::application::database::mc::FileCreate					"Create archive..." ;# NEW
::application::database::mc::FileClose						"Bezárás"
::application::database::mc::FileCompact					"Compact" ;# NEW
::application::database::mc::HelpSwitcher					"Help for Database Switcher" ;# NEW

::application::database::mc::Games							"&Játszmák"
::application::database::mc::Players						"&Játékosok"
::application::database::mc::Events							"&Versenyek"
::application::database::mc::Annotators					"&Elemző"

::application::database::mc::File							"Fájl"
::application::database::mc::SymbolSize					"Szimvólum méret"
::application::database::mc::Large							"Nagy"
::application::database::mc::Medium							"Közepes"
::application::database::mc::Small							"Kicsi"
::application::database::mc::Tiny							"Apró"
::application::database::mc::Empty							"üres"
::application::database::mc::None							"nincs"
::application::database::mc::Failed							"meghiúsult"
::application::database::mc::LoadMessage					"Adatbázis megnyitása: %s"
::application::database::mc::UpgradeMessage				"Adatbázis frissítése %s"
::application::database::mc::CompactMessage				"Compacting database %s" ;# NEW
::application::database::mc::CannotOpenFile				"A fájl nem nyitható meg olvasásra: '%s'."
::application::database::mc::EncodingFailed				"%s kódolása sikertelen."
::application::database::mc::DatabaseAlreadyOpen		"Az '%s' adatbázis már meg van nyitva."
::application::database::mc::Properties					"Tulajdonságok"
::application::database::mc::Preload						"Preload"
::application::database::mc::MissingEncoding				"Hiányos kódolás %s (használd inkább %s-t)"
::application::database::mc::DescriptionTooLarge		"Túl hosszú leírás."
::application::database::mc::DescrTooLargeDetail		"A mező %d karaktert tartalmaz, de csak %d megengedett."
::application::database::mc::ClipbaseDescription		"Ideiglenes adatbázis, nincs elmentve a lemezre."
::application::database::mc::HardLinkDetected			"'%file1' betöltése sikertelen. Már '%file2'-ként betöltődött. This can only happen if hard links are involved." ;# ? NEW
::application::database::mc::HardLinkDetectedDetail "If we load this database twice the application may crash due to the usage of threads." ;# NEW
::application::database::mc::CannotOpenUri				"Cannot open the following URI:" ;# NEW
::application::database::mc::InvalidUri					"Drop content is not a valid URI list." ;# NEW
::application::database::mc::UriRejected					"The following files are rejected:" ;# NEW
::application::database::mc::UriRejectedDetail			"Only Scidb databases can be opened:" ;# NEW
::application::database::mc::EmptyUriList					"Drop content is empty." ;# NEW
::application::database::mc::OverwriteExistingFiles	"Overwrite exisiting files in directory '%s'?" ;# NEW
::application::database::mc::SelectDatabases				"Select the databases to be opened" ;# NEW
::application::database::mc::ExtractArchive				"Extract archive %s" ;# NEW
::application::database::mc::CompactDetail				"All games must been closed before a compaction can be done." ;# NEW

::application::database::mc::RecodingDatabase			"Recoding %s from %s to %s"
::application::database::mc::RecodedGames					"%s game(s) recoded"

::application::database::mc::GameCount						"Játszmák"
::application::database::mc::DatabasePath					"Adatbázis elérési útvonala"
::application::database::mc::DeletedGames					"Törölt játszmák"
::application::database::mc::Description					"Leírás"
::application::database::mc::Created						"Létrehozva"
::application::database::mc::LastModified					"Utoljára módosítva"
::application::database::mc::Encoding						"Kódolás"
::application::database::mc::YearRange						"Év tartomány" ;#?
::application::database::mc::RatingRange					"Értékszám tartomány"
::application::database::mc::Result							"Eredmény"
::application::database::mc::Score							"Pontszám"
::application::database::mc::Type							"Típus"
::application::database::mc::ReadOnly						"Csak olvasható"

::application::database::mc::ChangeIcon					"Ikon cseréje"
::application::database::mc::Recode							"Újrakódolás"
::application::database::mc::EditDescription				"Leírás szerkesztése"
::application::database::mc::EmptyClipbase				"Üres vágólap"

::application::database::mc::T_Unspecific					"Nem specifikus"
::application::database::mc::T_Temporary					"Ideiglenes"
::application::database::mc::T_Work							"Munka"
::application::database::mc::T_Clipbase					"Vágólap"
::application::database::mc::T_MyGames						"Játszmáim"
::application::database::mc::T_Informant					"Informátor"
::application::database::mc::T_LargeDatabase				"Nagy adatbázis"
::application::database::mc::T_CorrespondenceChess		"Levelező sakk"  
::application::database::mc::T_EmailChess					"e-mail sakk"
::application::database::mc::T_InternetChess				"internet sakk"
::application::database::mc::T_ComputerChess				"számítógépes sakk"
::application::database::mc::T_Chess960					"Chess 960"
::application::database::mc::T_PlayerCollection			"Játékos adatlapok"
::application::database::mc::T_Tournament					"Verseny"
::application::database::mc::T_TournamentSwiss			"Svájci verseny"
::application::database::mc::T_GMGames						"GM Játszmák"
::application::database::mc::T_IMGames						"IM Játszmák"
::application::database::mc::T_BlitzGames					"Schnell játszmák"
::application::database::mc::T_Tactics						"Taktika"
::application::database::mc::T_Endgames					"Végjátékok"
::application::database::mc::T_Analysis					"Elemzések"
::application::database::mc::T_Training					"Edzések"
::application::database::mc::T_Match						"Match"
::application::database::mc::T_Studies						"Tanulmányok"
::application::database::mc::T_Jewels						"Gyöngyszemek"
::application::database::mc::T_Problems					"Problémák"
::application::database::mc::T_Patzer						"Patzer"
::application::database::mc::T_Gambit						"Gambit"
::application::database::mc::T_Important					"Important"
::application::database::mc::T_Openings					"Megnyitások"
::application::database::mc::T_OpeningsWhite				"Megnyitások világossal"
::application::database::mc::T_OpeningsBlack				"Megnyitások sötéttel"

::application::database::mc::OpenDatabase					"Adatbázis megnyitása"
::application::database::mc::NewDatabase					"Új adatbázis"
::application::database::mc::CloseDatabase				"Adatbázis bezárása: '%s'"
::application::database::mc::SetReadonly					"'%s' adatbázis módosítása írásvédette"
::application::database::mc::SetWriteable					"'%s' adatbázis módosítása írhatóvá"

::application::database::mc::OpenReadonly					"Megynitás olvasásra"
::application::database::mc::OpenWriteable				"Megnyitás írásra"

::application::database::mc::UpgradeDatabase				"%s egy régi formátum ami nem nyitható meg írásra.\n\nÚj formátumra kell konvertálni, hogy írható legyen.\n\nEz eltarthat egy kis ideig.\n\nÁt akarod konvertálni az adatbázist?"
::application::database::mc::UpgradeDatabaseDetail		"\"Nem\" olvasásra niytja meg az adatbázist."

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
::application::database::players::mc::Score						"Pont"
::application::database::players::mc::TooltipRating			"Értékszám: %s"

### application::database::annotators ##################################
::application::database::annotators::mc::F_Annotator		"Elemző"
::application::database::annotators::mc::F_Frequency		"Gyakoriság"

::application::database::annotators::mc::Find				"Keres"
::application::database::annotators::mc::FindAnnotator	"Elemző keresése"
::application::database::annotators::mc::ClearEntries		"Bejegyzések törlése"
::application::database::annotators::mc::NotFound			"Nem található."

### application::pgn ###################################################
::application::pgn::mc::Command(move:comment)			"Megjegyzés hozzáadása"
::application::pgn::mc::Command(move:marks)				"Jelölés hozzáadása"
::application::pgn::mc::Command(move:annotation)		"Értékelés/megjegyzés/jelölés hozzáadása"
::application::pgn::mc::Command(move:append)				"Lépés hozzáadása"
::application::pgn::mc::Command(move:nappend)			"Lépés hozzáadása"
::application::pgn::mc::Command(move:exchange)			"Lépés cseréje"
::application::pgn::mc::Command(variation:new)			"Új változat"
::application::pgn::mc::Command(variation:replace)		"Lépések felülírása"
::application::pgn::mc::Command(variation:truncate)	"Változat csonkítása"
::application::pgn::mc::Command(variation:first)		"Első változattá emelés"
::application::pgn::mc::Command(variation:promote)		"Változat főváltozattá emelése"
::application::pgn::mc::Command(variation:remove)		"változat törlése"
::application::pgn::mc::Command(variation:mainline)	"Új főváltozat"
::application::pgn::mc::Command(variation:insert)		"Lépések beszúrása"
::application::pgn::mc::Command(variation:exchange)	"Lépések cseréje"
::application::pgn::mc::Command(strip:moves)				"Lépések az elejétől"
::application::pgn::mc::Command(strip:truncate)			"Lépések a végéig"
::application::pgn::mc::Command(strip:annotations)		"Értékelő jelek"
::application::pgn::mc::Command(strip:info)				"Lépés információ"
::application::pgn::mc::Command(strip:marks)				"Jelölések"
::application::pgn::mc::Command(strip:comments)			"Megjegyzések"
::application::pgn::mc::Command(strip:variations)		"Változatok"
::application::pgn::mc::Command(copy:comments)			"Megjegyzések másolása"
::application::pgn::mc::Command(move:comments)			"Megjegyzések áthelyezése"
::application::pgn::mc::Command(game:clear)				"Játszma törlése"
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

::application::pgn::mc::ColumnStyle							"Oszlop stílus"
::application::pgn::mc::UseParagraphSpacing				"Bekezdés stílus"
::application::pgn::mc::ShowMoveInfo						"Lépés információ mutatása"
::application::pgn::mc::BoldTextForMainlineMoves		"Főváltozat félkövér betűkkel"
::application::pgn::mc::ShowDiagrams						"Diagramok mutatása"
::application::pgn::mc::Languages							"Nyelvek"
::application::pgn::mc::CollapseVariations				"Változatok elrejtése"
::application::pgn::mc::ExpandVariations					"Változatok kibontása"
::application::pgn::mc::EmptyGame							"Üres játszma"

::application::pgn::mc::NumberOfMoves						"(fél)lépésszám (a főváltozatban):"
::application::pgn::mc::InvalidInput						"Érvénytelen input '%d'."
::application::pgn::mc::MustBeEven						"Inputnak páros számnak kell lennie."
::application::pgn::mc::MustBeOdd							"Inputnak páratlan számnak kell lennie."
::application::pgn::mc::ReplaceMovesSucceeded			"Game moves successfully replaced."
::application::pgn::mc::CannotOpenCursorFiles			"Cannot open cursor files: %s" ;# NEW

::application::pgn::mc::EditAnnotation						"Értékelés szerkesztése"
::application::pgn::mc::EditMoveInformation				"Lépés információ szerkesztése"
::application::pgn::mc::EditCommentBefore					"Megjegyzés (lépés előtt)"
::application::pgn::mc::EditCommentAfter					"Megjegyzés (lépés után)"
::application::pgn::mc::EditPrecedingComment				"Legutóbbi megjegyzés szerkesztése"
::application::pgn::mc::EditTrailingComment				"Záró megjegyzés szerkesztése"
::application::pgn::mc::EditMarks							"Edit marks"
::application::pgn::mc::Display								"Kijelző"
::application::pgn::mc::None									"none"

### application::tree ##################################################
::application::tree::mc::Total							"Teljes"
::application::tree::mc::Control							"Vezérlés"
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
::application::tree::mc::FromWhitesPerspectiveTip		"Világos nézőpontjából"
::application::tree::mc::FromBlacksPerspectiveTip		"Sötét nézőpontjából"

::application::tree::mc::TooltipAverageRating		"Átlagos értékszám (%s)"
::application::tree::mc::TooltipBestRating		"Legjobb értékszám (%s)"

::application::tree::mc::F_Number						"#"
::application::tree::mc::F_Move							"Lépés"
::application::tree::mc::F_Eco							"ECO"
::application::tree::mc::F_Frequency					"Gyakoriság"
::application::tree::mc::F_Ratio							"Arány"
::application::tree::mc::F_Score							"Pont"
::application::tree::mc::F_Draws							"Döntetlenek"
::application::tree::mc::F_Performance					"Teljesítmény"
::application::tree::mc::F_AverageYear					"\u00f8 Év"
::application::tree::mc::F_LastYear						"Utoljára játszva"
::application::tree::mc::F_BestPlayer					"Legjobb játékos"
::application::tree::mc::F_FrequentPlayer				"Gyakori játékos"

::application::tree::mc::T_Number					"Számozás"
::application::tree::mc::T_AverageYear					"Average Year"
::application::tree::mc::T_FrequentPlayer				"Leggyakoribb játékos"

### board ##############################################################
::board::mc::CannotReadFile		"Fájl '%s' nem olvasható"
::board::mc::CannotFindFile		"Fájl '%s' nem található"
::board::mc::FileWillBeIgnored	"'%s' figyelmen kívül hagyva (duplicate ID)"
::board::mc::IsCorrupt				"'%s' hibás (ismeretlen %s style '%s')"

::board::mc::ThemeManagement		"Téma beállítások"
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
::board::options::mc::ShowMaterialBar		"Show Material Bar"
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
::board::piece::mc::ShadowDiffusion			"Árnyék elmosás"
::board::piece::mc::PieceStyleConf			"Bábustílus Beállítás"
::board::piece::mc::Offset						"Eltolás"
::board::piece::mc::Rotate						"Forgatás"
::board::piece::mc::CloseDialog				"Bezárod a dialógusablakot és elveted változtatásokat?"
::board::piece::mc::OpenTextureDialog		"Textúra dialógus megnyitása"

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
::board::square::mc::SuggestedMove		"Ajánlott lépés"
::board::square::mc::Show					"Előnézet"
::board::square::mc::SquareStyleConf	"Mező stílus beállítása"
::board::square::mc::CloseDialog			"Bezárod a dialógusablakot és elveted változtatásokat?"

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
::gametable::mc::WhiteRating				"Világos értékszáma"
::gametable::mc::BlackRating				"Sötét értékszáma"

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
::gametable::mc::F_Position				"Pozíció"
::gametable::mc::F_EventDate				"Esemény dátuma"
::gametable::mc::F_EventType				"Esemény típusa"
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
::gametable::mc::EventType(match)		"Mérkőzés"
::gametable::mc::EventType(tourn)		"Torna"
::gametable::mc::EventType(swiss)		"Svájci"
::gametable::mc::EventType(team)			"Csapat"
::gametable::mc::EventType(k.o.)			"Kieséses"
::gametable::mc::EventType(simul)		"Szimultán"
::gametable::mc::EventType(schev)		"Schev"

::gametable::mc::PlayerType(human)		"Ember"
::gametable::mc::PlayerType(program)	"Számítógép"

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
::gametable::mc::GameFlags(C)				"Érvénytelen sáncolás"
::gametable::mc::GameFlags(I)				"Szabálytalan lépés"

### playertable ########################################################
::playertable::mc::F_LastName					"Családnév"
::playertable::mc::F_FirstName				"Keresztnév"
::playertable::mc::F_FideID					"Fide azonosító"
::playertable::mc::F_Title						"Cím"
::playertable::mc::F_Frequency				"Gyakorisg"

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
::playertable::mc::OpenFideRatingHistory	"Fide értékszámának alakulása"
::playertable::mc::OpenWikipedia				"Wikipédia életrajz megnyitása"
::playertable::mc::OpenViafCatalog			"VIAF katalógus megnyitása"
::playertable::mc::OpenPndCatalog			"A Német Országos Könyvtár katalógusának megynitása"
::playertable::mc::OpenChessgames			"chessgames.com játszmagyűjtemény"
::playertable::mc::SeachIn365ChessCom		"Keresés a 365Chess.com -on"

### eventtable #########################################################
::eventtable::mc::Attendance	"Attendance" ;# NEW

### twm - tiled window manager #########################################
::twm::mc::Undock	"Undock" ;# NEW
::twm::mc::Close	"Bezár"

### fonts ##############################################################
::font::mc::ChessBaseFontsInstalled		"ChessBase fonts successfully installed." ;# NEW
::font::mc::ChessBaseFontsInstallationFailed	"Installation of ChessBase fonts failed." ;# NEW
::font::mc::NoChessBaseFontFound		"No ChessBase font found in folder '%s'." ;# NEW
::font::mc::ChessBaseFontsAlreadyInstalled	"ChessBase fonts already installed. Install anyway?" ;# NEW

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

::gamebar::mc::LockGame					"Játszma zárolása"
::gamebar::mc::CloseGame				"Játszma bezárása"

::gamebar::mc::GameNew					"Új tábla"
::gamebar::mc::GameNewChess960		"Új játszma: Chess 960" ;# NEW
::gamebar::mc::GameNewChess960Sym	"Új játszma: Chess 960 (symmetrical only)" ;# NEW
::gamebar::mc::GameNewShuffle			"Új játszma: Shuffle Chess" ;# NEW

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
::browser::mc::MaximizeBoardSize	"Maximize board size" ;# NEW
::browser::mc::MinimizeBoardSize	"Minimize board size" ;# NEW
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
::encoding::mc::AutoDetect				"automatikus felismerés"

::encoding::mc::Encoding		"Kódolás"
::encoding::mc::Description		"Leírás"
::encoding::mc::Languages		"Nyelvek (Betűtípusok)"
::encoding::mc::UseAutoDetection		"Automatikus felismerés használata"

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

::setup::board::mc::SetStartBoard		"Kiinduló állás beállítása"
::setup::board::mc::SideToMove			"Lépésre következő fél"
::setup::board::mc::Castling			"Sáncolás"
::setup::board::mc::MoveNumber			"Lépésszám"
::setup::board::mc::EnPassantFile		"Menetközbeni ütés"
::setup::board::mc::StartPosition		"Kiinduló állás"
::setup::board::mc::Fen				"FEN"
::setup::board::mc::Clear			"Törlés"
::setup::board::mc::CopyFen			"FEN másolása a vágólapra"
::setup::board::mc::Shuffle			"Keverés..."
::setup::board::mc::StandardPosition		"Standard Position"
::setup::board::mc::Chess960Castling		"Chess 960 castling"

::setup::board::mc::InvalidFen			"Érvénytelen FEN"
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
::setup::board::mc::Error(InvalidCastlingRights)	"Értelmetlen bástya vonal(ak) sáncoláshoz."
::setup::board::mc::Error(InvalidCastlingFile)		"Érvénytelen sáncolási vonal."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"Castling needs rook files to be disambiguous (possibly they are set wrong)."
::setup::board::mc::Error(InvalidEnPassant)		"Értelmetlen menetközbeni ütés vonal." ;#?
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

::import::mc::DifferentEncoding					"A kiválasztott %src kódolás nem illeszkedik %dst fájl kódoláshoz."
::import::mc::DifferentEncodingDetails			"Az adatbázis kódolásának megváltoztatása ez után a művelet után már nem lesz lehetséges." ;#?
::import::mc::CannotDetectFigurineSet			"Nem sikerült felismerni egyetlen megfelelő bábukészletet sem."
::import::mc::CheckImportResult					"Kérlek ellenőrizd, hogy a megfelelő bábukészlet lett-e felismerve."
::import::mc::CheckImportResultDetail			"Néhány esetben előfordulhat, hogy kétértelmű bejegyzések miatt az automatikus felismerés nem sikeres."

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
::import::mc::InvalidEventDateTag				"Érvénytelen esemény-dátum címke"
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
::import::mc::UnknownTermination				"Ismeretlen megszakítási ok"
::import::mc::UnknownMode					"Ismeretlen mód"
::import::mc::RatingTooHigh					"Túl magas érétkszám (kihagyva))"
::import::mc::TooManyNags					"Túl sok NAG (a későbbiek kihagyva)"
::import::mc::IllegalCastling					"Szabálytalan sáncolás"
::import::mc::IllegalMove					"Szabálytalan lépés"
::import::mc::CastlingCorrection				"Castling correction" ;# NEW
::import::mc::UnsupportedVariant				"Unsupported chess variant"
::import::mc::DecodingFailed					"Sikertelen dekódolás"
::import::mc::ResultDidNotMatchHeaderResult			"Az eredmény nem egyezik meg a fejlécben megadott eredménnyel"
::import::mc::ValueTooLong					"A cimke értéke túl hosszú és 255 karakterre csonkolódik"
::import::mc::MaximalErrorCountExceeded		"A maximális hibaszám túllépve; több hiba (az előző hibatípusból) nem lesz közölve"
::import::mc::MaximalWarningCountExceeded		"A maximális figyelmeztetés-szám túllépve; több figyelmeztetés (az előző figyelmeztetés-típusból) nem lesz közölve"
::import::mc::InvalidToken					"Érvénytelen token"
::import::mc::InvalidMove					"Érvénytelen lépés"
::import::mc::UnexpectedSymbol					"Váratlan szimbólum"
::import::mc::UnexpectedEndOfInput				"A bement váratlanul véget ért" ;# ? Unexpected end of input"
::import::mc::UnexpectedResultToken				"Váratlan eredmény token"
::import::mc::UnexpectedTag						"Váratlan cimke a játszmában"
::import::mc::UnexpectedEndOfGame				"A játszma váratlanul véget ért (hiényzó eredmény)"
::import::mc::TagNameExpected						"Szintaktikai hiba: meg kell adni a cimke nevét"
::import::mc::TagValueExpected					"Szintaktikai hiba: meg kell adni a cimke értékét"
::import::mc::InvalidFen							"Érvénytelen FEN"
::import::mc::UnterminatedString					"Befejezetlen string"
::import::mc::UnterminatedVariation				"Befejezetlen változat"
::import::mc::TooManyGames							"Az adatbézis túl sok játszmát tartalmaz (aborted)"
::import::mc::GameTooLong							"A játszma túl hosszú (átugorva)"
::import::mc::FileSizeExceeded					"A legnagyobb kezelhető ájlméret (2GB) túllépésre került (aborted)"
::import::mc::TooManyPlayerNames					"Túl sok játékos az adatbázisban (aborted)"
::import::mc::TooManyEventNames					"Túl sok esemény az adatbázisban (aborted)"
::import::mc::TooManySiteNames					"Túl sok helyzín az adatbázisban (aborted)"
::import::mc::TooManyRoundNames					"Túl sok forduló az adatbázisban (aborted)"
::import::mc::TooManyAnnotatorNames				"Túl sok elemző az adatbázisban (aborted)"
::import::mc::TooManySourceNames					"Túl sok forrás az adatbázisban (aborted)"
::import::mc::SeemsNotToBePgnText				"Nem tűnik PGN szövegnek"
::import::mc::AbortedDueToInternalError		"Beslő hiba miatt Aborted"

### export #############################################################
::export::mc::FileSelection			"&Fájl Kiválasztás"
::export::mc::OptionsSetup					"Beállítás&ok"
::export::mc::PageSetup				"&Oldalbeállítás"
::export::mc::DiagramSetup					"&Diagramm Beállítások"
::export::mc::StyleSetup					"Stí&lus"
::export::mc::EncodingSetup				"&Kódolás"
::export::mc::TagsSetup						"&Cimkék"
::export::mc::NotationSetup				"&Notation" ;# NEW
::export::mc::AnnotationSetup				"&Értékelés"
::export::mc::CommentsSetup				"&Megjegyzés"

::export::mc::Visibility					"Láthatóság"
::export::mc::HideDiagrams					"Diagramm elrejtése"
::export::mc::AllFromWhitePersp			"Minden Világos nézőpontjából"
::export::mc::AllFromBlackPersp			"Minden Sötét nézőpontjából"
::export::mc::ShowCoordinates				"Koordináták mutatása"
::export::mc::ShowSideToMove				"Lépésre jövő fél mutatása"
::export::mc::ShowArrows					"Nyilak mutatása"
::export::mc::ShowMarkers					"Jelölések mutatása"
::export::mc::Layout							"Layout" ;# NEW
::export::mc::PostscriptSpecials			"Postscript Specialities" ;# NEW
::export::mc::BoardSize						"Tábla méret"

::export::mc::Notation				"Notation"
::export::mc::Graphic				"Grafika"
::export::mc::Short				"Rövid"
::export::mc::Long				"Hosszú"
::export::mc::Algebraic				"Algebrai"
::export::mc::Correspondence			"Levelezési játszma"
::export::mc::Telegraphic			"Telegraphic"
::export::mc::FontHandling			"Betűk kezelése"
::export::mc::DiagramStyle					"Diagramm Stílus"
::export::mc::UseImagesForDiagram		"Képek használata a diagrammok előállításához"
::export::mc::EmebedTruetypeFonts		"TrueType betűk beágyazása"
::export::mc::UseBuiltinFonts			"Használd a beépített betűkészletet"
::export::mc::SelectExportedTags			"Selection of exported tags" ;# NEW
::export::mc::ExcludeAllTags				"Minden cimke kizárása"
::export::mc::IncludeAllTags				"Minden cimke kiválasztása"
::export::mc::ExtraTags						"Minden más további cimkék"
::export::mc::NoComments					"No comments" ;# NEW
::export::mc::AllLanguages					"Minden nyelv"
::export::mc::Significant					"Jelentős"
::export::mc::LanguageSelection			"Nyelv választás"
::export::mc::MapTo							"Map to" ;# NEW
::export::mc::MapNagsToComment			"Map annotations to comments" ;# NEW
::export::mc::UnusualAnnotation			"Szokatlan értékelése"
::export::mc::AllAnnotation				"Minden értékelés"
::export::mc::UseColumnStyle				"Oszlop stílus használata"
::export::mc::MainlineStyle				"Főváltozat stílusa"
::export::mc::HideVariations				"Változatok elrejtése"

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
::export::mc::Hyphenation					"Elválasztása"
::export::mc::None							"(nessuno)"
::export::mc::Symbols				"Szimbólumok"
::export::mc::Comments				"Megjegyzések"
::export::mc::Result				"Eredmény"
::export::mc::Diagram				"Diagramm"
::export::mc::ColumnStyle					"Oszlopstílus"

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

::export::mc::DocumentStyle				"Dokumentum stílus"
::export::mc::Article						"Cikk"
::export::mc::Report							"Jelentés"
::export::mc::Book							"Könyv"

::export::mc::FormatName(scidb)			"Scidb"
::export::mc::FormatName(scid)			"Scid"
::export::mc::FormatName(pgn)			"PGN"
::export::mc::FormatName(pdf)			"PDF"
::export::mc::FormatName(html)			"HTML"
::export::mc::FormatName(tex)			"LaTeX"
::export::mc::FormatName(ps)			"Postscript"

::export::mc::Option(pgn,include_varations)		"Változatok exportálása"
::export::mc::Option(pgn,include_comments)		"Megegyzések exportálása"
::export::mc::Option(pgn,include_moveinfo)		"Lépés információk exportálása (megjegyzésként)"
::export::mc::Option(pgn,include_marks)			"Export marks (megjegyzésként)"
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
::export::mc::Option(pgn,space_after_move_number)	"Lépésszám után szóköz"
::export::mc::Option(pgn,shredder_fen)			"Write Shredder-FEN (default is X-FEN)"
::export::mc::Option(pgn,convert_lost_result_to_comment)	"Megjegyzés írása a '0-0'-ás eredményhez"
::export::mc::Option(pgn,append_mode_to_event_type)	"Add mode after event type"
::export::mc::Option(pgn,comment_to_html)		"Megjegyzés írása HTML stílusban"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Érvénytelen lépést tartalmazó játszmák elvetése"

### save/replace #######################################################
::dialog::save::mc::SaveGame			"Játszma mentése"
::dialog::save::mc::ReplaceGame			"Játszma kicserélése"
::dialog::save::mc::EditCharacteristics		"Tulajdonságok beállítása"
	
::dialog::save::mc::GameData			"Játszma adatai"
::dialog::save::mc::Event			"Esemény"

::dialog::save::mc::MatchesExtraTags		"Játszmák / Extraneous Tags"
::dialog::save::mc::PressToSelect		"Kiválasztáshoz nyomja meg a Ctrl+0-tól Ctrl+9-ig (vagy bal egérgomb)"
::dialog::save::mc::PressForWhole		"Nyomj Alt-0-9 -et (vagy jobb egérgomb) az egész adathalmazhoz"
::dialog::save::mc::EditTags			"Cimkék szerkesztése"
::dialog::save::mc::RemoveThisTag		"Törölni kívánja a '%s' cimkét?"
::dialog::save::mc::TagAlreadyExists		"'%s' cimke már létezik."
::dialog::save::mc::TagRemoved			"'%s' extra cimke (jelenelgi tartalma: '%s') törlése kerül."
::dialog::save::mc::TagNameIsReserved		"'%s' cimke név foglalt."
::dialog::save::mc::Locked			"Zárolva"
::dialog::save::mc::OtherTag			"Más cike"
::dialog::save::mc::NewTag			"Új cimke" ;# NEW change to "Add tag"
::dialog::save::mc::RemoveTag			"Cimke törlése"
::dialog::save::mc::SetToGameDate		"Set to game date"
::dialog::save::mc::SaveGameFailed		"A játszma mentése meghiúsult."
::dialog::save::mc::SaveGameFailedDetail	"Lásd az eseménynaplót a részletekért."
::dialog::save::mc::SavingGameLogInfo		"(%white - %black, %event) játszma mentése a(z) '%base' adatbázisba"
::dialog::save::mc::CurrentBaseIsReadonly	"A jelenlegi '%s' adatbázis csak olvasható."
::dialog::save::mc::CurrentGameHasTrialMode	"Current game is in trial mode and cannot be saved." ;' NEW

::dialog::save::mc::LocalName			"He&lyi Név"
::dialog::save::mc::EnglishName			"A&ngol Név"
::dialog::save::mc::ShowRatingType		"É&rtékszám mutatása"
::dialog::save::mc::EcoCode			"&ECO"
::dialog::save::mc::Matches			"&Játszmák"
::dialog::save::mc::Tags			"&Cimkék"

::dialog::save::mc::Label(name)			"Név"
::dialog::save::mc::Label(fideID)		"Név/Fide-Azonosító"
::dialog::save::mc::Label(value)		"Érték"
::dialog::save::mc::Label(title)		"Title"
::dialog::save::mc::Label(rating)		"Értékszám"
::dialog::save::mc::Label(federation)		"Szövetség"
::dialog::save::mc::Label(country)		"Ország"
::dialog::save::mc::Label(eventType)		"Típus"
::dialog::save::mc::Label(sex)			"Nem/Típus"
::dialog::save::mc::Label(date)			"Dátum"
::dialog::save::mc::Label(eventDate)		"Eseméyn dátuma"
::dialog::save::mc::Label(round)		"Forduló"
::dialog::save::mc::Label(result)		"Eredmény"
::dialog::save::mc::Label(termination)		"Termination"
::dialog::save::mc::Label(annotator)		"Annotator"
::dialog::save::mc::Label(site)			"Helyszín"
::dialog::save::mc::Label(eventMode)		"Mode"
::dialog::save::mc::Label(timeMode)		"Time Mode"
::dialog::save::mc::Label(frequency)		"Gyakoriság"
::dialog::save::mc::Label(score)		"Second rating" ;# NEW

::dialog::save::mc::GameBase			"Játszma adatbázis"
::dialog::save::mc::PlayerBase			"Játékos adatbázis"
::dialog::save::mc::EventBase			"Esemény adatbázis"
::dialog::save::mc::SiteBase			"Helyzín adatbázis"
::dialog::save::mc::AnnotatorBase		"Annotator Base"
::dialog::save::mc::History			"Előzmények"

::dialog::save::mc::InvalidEntry		"'%s' nem érényes bejegyzés."
::dialog::save::mc::InvalidRoundEntry		"'%s' nem érévnyes forduló bejegyzés."
::dialog::save::mc::InvalidRoundEntryDetail	"Érvényes bejegyzések pl. '4' vagy '6.1'.  nem megengedett"
::dialog::save::mc::RoundIsTooHigh		"A fordulók száma nem haladhatja meg a 256-t"
::dialog::save::mc::SubroundIsTooHigh		"Sub-round should be less than 256."
::dialog::save::mc::ImplausibleDate		"A játszma dátuma ('%s') korábbi mint az esemény dátuma ('%s')."
::dialog::save::mc::InvalidTagName		"Érénytelen cimke név: '%s' (syntax error)."
::dialog::save::mc::Field			"'%s' mező: "
::dialog::save::mc::ExtraTag			"'%s'Extra cimke : "
::dialog::save::mc::InvalidNetworkAddress	"'%s' érvénytelen hálózati cíim '%s'."
::dialog::save::mc::InvalidCountryCode		"Érvénytelen országkód '%s'."
::dialog::save::mc::InvalidEventRounds		"Érvénytelen fordulószám '%s' (pozitív egésznek kell lennie)."
::dialog::save::mc::InvalidPlyCount		"Érvénytelen lépésszám '%s' (pozitív egésznek kell lennie)."
::dialog::save::mc::IncorrectPlyCount		"Érvénytelen lépésszám '%s' (az aktuális lépésszám %s)."
::dialog::save::mc::InvalidTimeControl		"Érvénytelen időellenőrzés mező '%s'-ban/ben."
::dialog::save::mc::InvalidDate			"'%s' érvénytelen dátum."
::dialog::save::mc::InvalidYear					"Érvénytelen évszám '%s'."
::dialog::save::mc::InvalidMonth					"Érvénytelen hónap '%s'."
::dialog::save::mc::InvalidDay					"Érvénytelen nap '%s'."
::dialog::save::mc::MissingYear					"Az évszám hiányzik."
::dialog::save::mc::MissingMonth					"A hónap hiányzik."
::dialog::save::mc::StringTooLong				"Tag %tag%: string '%value%' is too long and will be truncated to '%trunc%'."
::dialog::save::mc::InvalidEventDate			"Cannot accept given event date: The difference between the year of the game and the year of the event should be less than 4 (restriction of Scid's database format)."
::dialog::save::mc::TagIsEmpty					"'%s' címke üres (kihagyva)."

### gamehistory ########################################################
::game::history::mc::GameHistory	"Játszma történet"

### game ###############################################################
::game::mc::CloseDatabase				"Adatbázis bezárása"
::game::mc::CloseAllGames				"Close all open games of database '%s'?"
::game::mc::SomeGamesAreModified		"Some games of database '%s' are modified. Close anyway?"
::game::mc::AllSlotsOccupied			"All game slots are occupied."
::game::mc::ReleaseOneGame				"Please release one of the games before loading a new one."
::game::mc::GameAlreadyOpen			"Game is already open but modified. Discard modified version of this game?"
::game::mc::GameAlreadyOpenDetail	"'%s' egy új játszmát fog megynitni."
::game::mc::GameHasChanged				"%s játszma megváltozott."
::game::mc::GameHasChangedDetail		"Az adatbázis változásai miatt valószínűleg nem ezt a játszmát akartad megnyitni."
::game::mc::CorruptedHeader			"Corrupted header in recovery file '%s'."
::game::mc::RenamedFile					"Renamed this file to '%s.bak'."
::game::mc::CannotOpen					"A visszaállító fájl '%s' nem nyitható meg."
::game::mc::GameRestored				"One game from last session restored."
::game::mc::GamesRestored				"%s games from last session restored."
::game::mc::OldGameRestored			"Egy játszma helyreállítva."
::game::mc::OldGamesRestored			"%s játszmák helyreállítva."
::game::mc::ErrorInRecoveryFile		"Hiba a helyreállító fájlban '%s'"
::game::mc::Recovery						"Visszaállítás"
::game::mc::UnsavedGames		"A játszmabeli változtatások nincsenel elmentve."
::game::mc::DiscardChanges		"'%s' el fogja vetni a változtatásokat."
::game::mc::ShouldRestoreGame		"Legyen ez a játszma helyreállítva a következő indításkor?"
::game::mc::ShouldRestoreGames		"Legyenek ezek a játszmák helyreállítva a következő indításkor?"
::game::mc::NewGame			"Új játszma"
::game::mc::NewGames			"Új játszmák"
::game::mc::Created			"létrehozva"
::game::mc::ClearHistory				"Előzmények törlése"
::game::mc::RemoveSelectedGame		"Kijelölt játszmák törlése az előzmények közül"
::game::mc::GameDataCorrupted			"Játszma sérült."
::game::mc::GameDecodingFailed		"Ennek a jástszmának a dekódolása nem lehetséges."
::game::mc::GameDecodingChanged		"The database is opened with character set '%base%', but this game seems to be encoded with character set '%game%', therefore this game is loaded with the detected character set." ;# NEW
::game::mc::GameDecodingChangedDetail	"Probably you have opened the database with the wrong character set. Note that the automatic detection of the character set is limited." ;# NEW

### languagebox ########################################################
::languagebox::mc::AllLanguages	"Összes nyelv"
::languagebox::mc::None				"Egyik sem"

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
::terminationbox::mc::TimeForfeit	"Leesett"
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
::help::mc::Contents					"&Tartalom"
::help::mc::Index						"&Tárgymutató"
::help::mc::Search					"&Keresés"

::help::mc::Help						"Súgó"
::help::mc::MatchEntireWord		"Teljes szó keresése"
::help::mc::MatchCase				"Match case" ;# NEW
::help::mc::TitleOnly				"Keresés csak a címek között"
::help::mc::CurrentPageOnly		"Search in current page only" ;# NEW
::help::mc::GoBack					"Egy oldallal vissza"
::help::mc::GoForward				"Egy oldallal előre"
::help::mc::GotoPage					"Menj a '%s'-dik oldalra"
::help::mc::ExpandAllItems			"Kibontás"
::help::mc::CollapseAllItems		"Összecsukás"
::help::mc::SelectLanguage			"Nyelv választás"
::help::mc::NoHelpAvailable		"Nincs elérhető súgó fájl magyar nyelven.\nVálaszz másik nyelvet\na súgó számára."
::help::mc::KeepLanguage			"Őrizzem meg a %s nyelvet a következő alkalmakra is?"
::help::mc::ParserError				"Error while parsing file %s." ;# NEW
::help::mc::NoMatch					"Nincs találat"
::help::mc::MaxmimumExceeded		"Maximal number of matches exceeded in some pages." ;# NEW
::help::mc::OnlyFirstMatches		"Csak az első %s találat jelenik meg."
::help::mc::HideIndex				"Tárgymutató elrejtése"
::help::mc::ShowIndex				"Tárgymutató mutatása"

::help::mc::FileNotFound			"Fájl nem található."
::help::mc::CantFindFile			"Fájl nem található %s könyvtárban."
::help::mc::IncompleteHelpFiles	"Úgy tűnik, hogy a súgó fájlok még nem véglegesek. Bocs!"
::help::mc::ProbablyTheHelp		"Valószínűleg egy más nylevű súgó segíthet"
::help::mc::PageNotAvailable		"Ez az oldal nem elérhető"

::help::mc::Overview					"Áttekintés"

### crosstable #########################################################
::crosstable::mc::TournamentTable	"Verseny tabella"
::crosstable::mc::AverageRating		"Átlagos pontszám"
::crosstable::mc::Category		"Kategória"
::crosstable::mc::Games			"játszmák"
::crosstable::mc::Game			"játszma"
::crosstable::mc::ScoringSystem			"Scoring System" ;# NEW
::crosstable::mc::Tiebreak		"Rövidített játszma"
::crosstable::mc::Settings		"Beállítások"
::crosstable::mc::RevertToStart		"Kiinduló értékek visszaállítása"
::crosstable::mc::UpdateDisplay		"Képernyő frissítése"

::crosstable::mc::Traditional				"Hagyományos"
::crosstable::mc::Bilbao					"Bilbao" ;# NEW

::crosstable::mc::None				"nincs"
::crosstable::mc::Buchholz			"Buchholz"
::crosstable::mc::MedianBuchholz		"Median-Buchholz"
::crosstable::mc::ModifiedMedianBuchholz 	"Mod. Median-Buchholz"
::crosstable::mc::RefinedBuchholz		"Refined Buchholz"
::crosstable::mc::SonnebornBerger		"Sonneborn-Berger"
::crosstable::mc::Progressive			"Progresszív"
::crosstable::mc::KoyaSystem			"Koya rendszer"
::crosstable::mc::GamesWon			"Nyert játszmák"
::crosstable::mc::GamesWonWithBlack		"Sötéttel nyert játszmákGames Won with Black" ;# NEW
::crosstable::mc::ParticularResult		"Particular Result" ;# NEW
::crosstable::mc::TraditionalScoring	"Traditional Scoring" ;# NEW

::crosstable::mc::Crosstable			"Kereszttábla"
::crosstable::mc::Scheveningen			"Scheveningeni"
::crosstable::mc::Swiss				"Svájci rendszer"
::crosstable::mc::Match				"Match"
::crosstable::mc::Knockout			"Kieséses"
::crosstable::mc::RankingList			"Rangsor"

::crosstable::mc::Order				"Order"
::crosstable::mc::Type				"Tábla típus"
::crosstable::mc::Score				"Pont"
::crosstable::mc::Alphabetical			"Alphabetical"
::crosstable::mc::Rating			"Értékszám"
::crosstable::mc::Federation			"Szövetség"

::crosstable::mc::Debugging			"Hibakeresés"
::crosstable::mc::Display			"Kijelző"
::crosstable::mc::Style				"Stílus"
::crosstable::mc::Spacing			"Spacing"
::crosstable::mc::Padding			"Padding"
::crosstable::mc::ShowLog			"Eseméynnapló megnyitása"
::crosstable::mc::ShowHtml			"HTML megnyitása"
::crosstable::mc::ShowRating			"Értékszám"
::crosstable::mc::ShowPerformance		"Teljesítmény"
::crosstable::mc::ShowTiebreak			"Rövidített játszma"
::crosstable::mc::ShowOpponent			"Ellenfél (as Tooltip)"
::crosstable::mc::KnockoutStyle			"Kiütéses Táblázat Stílus" ;# ?
::crosstable::mc::Pyramid			"Piramis"
::crosstable::mc::Triangle			"Háromszög"

::crosstable::mc::CrosstableLimit	"Túl sok a játékos (>%d) a kereszttáblához."
::crosstable::mc::CrosstableLimitDetail "'%s' is choosing another table mode."

### info ###############################################################
::info::mc::InfoTitle			"Névjegy %s"
::info::mc::Info			"Info"
::info::mc::About			"Névjegy"
::info::mc::Contributions		"Készítők" ;#Contributions
::info::mc::License			"Liszenc"
::info::mc::Localization		"Regionális beállítások" ;#"Localization"
::info::mc::Testing			"Tesztelés"
::info::mc::References			"Referenciák"
::info::mc::System			"Rendszer"
::info::mc::FontDesign			"sakk betűtípus terv" ;#chess font design
::info::mc::ChessPieceDesign		"Figurakészlet terv" ;# "chess piece design"
::info::mc::BoardThemeDesign		"Tábla terv" ;#"Board theme design"
::info::mc::FlagsDesign			"Miniatűr zászló terv" ;#"Miniature flags design"
::info::mc::IconDesign			"Ikon terv"

::info::mc::Version			"Verzió"
::info::mc::Distributed			"This program is distributed under the terms of the GNU General Public License."
::info::mc::Inspired				"Scidb is inspired by Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
::info::mc::SpecialThanks		"Special thanks to Shane Hudson for his terrific work. His effort is the basis for this application."

### comment ############################################################
::comment::mc::CommentBeforeMove	"Megjegyzés lépés elé"
::comment::mc::CommentAfterMove		"Megjegyzés lépés utám"
::comment::mc::PrecedingComment		"Előző megjegyzés"
::comment::mc::TrailingComment		"Utolsó megjegyzés"
::comment::mc::Language			"Nyelv"
::comment::mc::AddLanguage		"Nyelv hozzáadása..."
::comment::mc::SwitchLanguage		"Nyelv váltása"
::comment::mc::FormatText		"Szöveg formázása"
::comment::mc::CopyText					"Szöveg másolása"
::comment::mc::OverwriteContent		"Felülírod a meglévő tartalmat?"
::comment::mc::AppendContent			"Ha \"nem\" , akkor a szöveg hozzáasódik."

::comment::mc::LanguageSelection		"Language selection" ;# NEW
::comment::mc::Formatting				"Formatting" ;# NEW

::comment::mc::Bold			"Félkövér"
::comment::mc::Italic			"Dőlt"
::comment::mc::Underline		"Aláhúzott"

::comment::mc::InsertSymbol		"Szimbólum be&illesztése..."
::comment::mc::MiscellaneousSymbols	"Vegyes szimbólumok"
::comment::mc::Figurine			"Figurális"

### annotation #########################################################
::annotation::mc::AnnotationEditor		"Értékelő jelek"
::annotation::mc::TooManyNags			"Túl sok értékelő jel (az utolsó elvetve)."
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

::move::mc::GameWillBeTruncated	"Játszma megcsonkításra kerül. Folytatod? '%s'"

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
::titlebox::mc::Title(CIM)	"Correspondence International Master (ICCF)"
::titlebox::mc::Title(CLGM)	"Correspondence Lady Grandmaster (ICCF)"
::titlebox::mc::Title(CILM)	"Correspondence Lady International Master (ICCF)"
::titlebox::mc::Title(CSIM)	"Correspondence Senior International Master (ICCF)"

### messagebox #########################################################
::dialog::mc::Ok				"&OK"
::dialog::mc::Cancel			"&Mégse"
::dialog::mc::Yes				"&Igen"
::dialog::mc::No				"&Nem"
::dialog::mc::Retry			"&Újra"
::dialog::mc::Abort			"&Megszakítás"
::dialog::mc::Ignore			"&Kihagyás"
::dialog::mc::Continue		"Foly&tatás"

::dialog::mc::Error			"Hiba"
::dialog::mc::Warning		"Figyelmeztetés"
::dialog::mc::Information	"Információ"
::dialog::mc::Question		"Kérdés" ;# NEW english content is "Confirm"

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

### fileselectionbox ###################################################
::dialog::fsbox::mc::ScidbDatabase			"Scidb Database" ;# NEW
::dialog::fsbox::mc::ScidDatabase			"Scid Database" ;# NEW
::dialog::fsbox::mc::ChessBaseDatabase		"ChessBase Database" ;# NEW
::dialog::fsbox::mc::PortableGameFile		"Portable Game File" ;# NEW
::dialog::fsbox::mc::ZipArchive				"ZIP Archive" ;# NEW
::dialog::fsbox::mc::ScidbArchive			"Scidb Arvchive" ;# NEW
::dialog::fsbox::mc::PortableDocumentFile	"Portable Document File" ;# NEW
::dialog::fsbox::mc::HypertextFile			"Hypertext File" ;# NEW
::dialog::fsbox::mc::TypesettingFile		"Typesetting File" ;# NEW
::dialog::fsbox::mc::LinkTo					"Link to %s" ;# NEW
::dialog::fsbox::mc::LinkTarget				"Link target" ;# NEW
::dialog::fsbox::mc::Directory				"Directory" ;# NEW

::dialog::fsbox::mc::Content					"Content" ;# NEW
::dialog::fsbox::mc::Open						"Open" ;# NEW

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

::dialog::choosefont::mc::Regular			"Hagyományos"
::dialog::choosefont::mc::Bold				"Félkövér"
::dialog::choosefont::mc::Italic			"Dőlt"
{::dialog::choosefont::mc::Bold Italic}	"Félkövér Dőlt"

::dialog::choosefont::mc::Effects			"Effektusok"
::dialog::choosefont::mc::Filter			"Szűrő"
::dialog::choosefont::mc::Sample			"Minta"
::dialog::choosefont::mc::SearchTitle			"Azonos szélességű betűtípusok keresése"
::dialog::choosefont::mc::SeveralMinutes		"Ez a művelet kb. %d percig tart."
::dialog::choosefont::mc::FontSelection			"Betűtypus választása"
::dialog::choosefont::mc::Wait				"Kérem várjon"

### choosedir ##########################################################
::choosedir::mc::ShowPredecessor	"Show Predecessor" ;# NEW
::choosedir::mc::ShowTail			"Show Tail" ;# NEW
::choosedir::mc::Folder				"Könyvtár"

### fsbox ##############################################################
::fsbox::mc::Name								"Név"
::fsbox::mc::Size								"Dátum"
::fsbox::mc::Modified						"Módosítva"

::fsbox::mc::Forward							"Forward to '%s'"
::fsbox::mc::Backward						"Backward to '%s'"
::fsbox::mc::Delete							"Töröl"
::fsbox::mc::Restore							"Restore" ;# NEW
::fsbox::mc::Rename							"Átnevez"
::fsbox::mc::Duplicate						"Duplicate"
::fsbox::mc::CopyOf							"Copy of %s"
::fsbox::mc::NewFolder						"Új könyvtár"
::fsbox::mc::Layout							"Nézet"
::fsbox::mc::ListLayout						"Lista nézet"
::fsbox::mc::DetailedLayout				"Részletes nézet"
::fsbox::mc::ShowHiddenDirs				"Mutasd a &rejtett könyvtárakat"
::fsbox::mc::ShowHiddenFiles				"Mutasd a &rejtett fájlokat és könyvtárakat"
::fsbox::mc::AppendToExisitingFile		"Játszmák hozzá&adása egy létező fájlhoz"
::fsbox::mc::Cancel							"&Mégse"
::fsbox::mc::Save								"Menté&s"
::fsbox::mc::Open								"&Megynitás"

::fsbox::mc::AddBookmark					"Könyvjelző hozzáadása '%s'"
::fsbox::mc::RemoveBookmark				"Könyvjelző eltávolítása '%s'"
::fsbox::mc::RenameBookmark				"Rename Bookmark '%s'" ;# NEW

::fsbox::mc::Filename						"Fájl &név:"
::fsbox::mc::Filenames						"Fájl &nevek:"
::fsbox::mc::FilesType						"Fájl &típusok:"
::fsbox::mc::FileEncoding					"Fájl &kódolás:"

::fsbox::mc::Favorites						"Kedvencek"
::fsbox::mc::LastVisited					"Utoljára használt"  ;#?
::fsbox::mc::FileSystem						"Fájlredszer"
::fsbox::mc::Desktop							"Asztal"
::fsbox::mc::Trash							"Trash" ;# NEW
::fsbox::mc::Home								"Home" ;# NEW

::fsbox::mc::SelectEncoding				"Adatbázis kódolásának kiválasztása"
::fsbox::mc::SelectWhichType				"Megjelenítendő fájltípusok kiválasztása"
::fsbox::mc::TimeFormat						"%Y.%m.%d %H:%M"

::fsbox::mc::CannotChangeDir				"Cannot change to the directory \"%s\".\nHozzáférés megtagadva."
::fsbox::mc::DirectoryRemoved				"Cannot change to the directory \"%s\".\nKönyvtár nem létezik."
::fsbox::mc::ReallyMove(file,w)			"Biztos hogy a kukába dobod a(z) '%s' fájlt?"
::fsbox::mc::ReallyMove(file,r)			"Biztos hogy a kukába dobod a(z) '%s' írásvédett fájlt?"
::fsbox::mc::ReallyMove(folder,w)		"Biztos hogy a kukába dobod a(z) '%s' könyvtárat"
::fsbox::mc::ReallyMove(folder,r)		"Biztos hogy a kukába dobod a(z) '%s' írásvédett könyvtárat?"
::fsbox::mc::ReallyDelete(file,w)		"Biztos hogy törlöd a(z) '%s' fájlt? Ez a művelet később nem vonható vissza." ;# You cannot undo this operation."
::fsbox::mc::ReallyDelete(file,r)		"Biztos hogy törlöd a(z) '%s' írásvédett fájlt? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(link,w)		"Biztos hogy törlöd a(z) '%s' linket?"
::fsbox::mc::ReallyDelete(link,r)		"Biztos hogy törlöd a(z) '%s' linket?"
::fsbox::mc::ReallyDelete(folder,w)		"Biztos hogy törlöd a(z) '%s' könyvtárat? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(folder,r)		"Biztos hogy törlöd a(z) '%s' írásvédett könyvtárat? Ez a művelet később nem vonható vissza."
::fsbox::mc::DeleteFailed					"'%s' törlése meghiúsult."
::fsbox::mc::RestoreFailed					"Restoring of '%s' failed." ;# NEW
::fsbox::mc::CommandFailed					"'%s' utasítás nem hajtható vége."
::fsbox::mc::CopyFailed						"'%s' fájl másolása meghiúsult: hozzáférés megtagadva"
::fsbox::mc::CannotCopy						"'%s' már létezik. A másolás meghiúsult."
::fsbox::mc::CannotDuplicate				"Cannot duplicate file '%s' due to the lack of read permission." ;# NEW
::fsbox::mc::ReallyDuplicateFile			"Really duplicate this file?"
::fsbox::mc::ReallyDuplicateDetail		"This file has about %s. Duplicating this file may take some time."
::fsbox::mc::ErrorRenaming(folder)		"Error renaming folder '%old' to '%new': permission denied."
::fsbox::mc::ErrorRenaming(file)			"Error renaming file '%old' to '%new': permission denied."
::fsbox::mc::InvalidFileExt				"A művelet meghiúsult: '%s' kiterjesztése érvénytelen."
::fsbox::mc::CannotRename					"'%s' nem nevezhető át, mert a könyvtár/fájl már létezik."
::fsbox::mc::CannotCreate					"'%s' könyvtár nem hozható létre, mert a könyvtár/fájl már létezik."
::fsbox::mc::ErrorCreate					"Hiba a könyvtár létrehozás közben: hozzáférés megtagadva."
::fsbox::mc::FilenameNotAllowed			"'%s' fájlnév nem engedélyezett."
::fsbox::mc::ContainsTwoDots				"Két egymásutáni pontot tartalmaz."
::fsbox::mc::ContainsReservedChars		"Contains reserved characters: %s, or a control character (ASCII 0-31)." ;# NEW previously: "Fenntartott karaktereket tartalmaz: %s."
::fsbox::mc::InvalidFileName				"A filename cannot start with a hyphen, and cannot end with a space or a period." ;# NEW
::fsbox::mc::ReservedCharsDetails		"Control characters (ASCII 0-31) are also forbidden." ;# NEW
::fsbox::mc::IsReservedName				"Ez egy fenntartott név néhány operációs rendszeren."
::fsbox::mc::FilenameTooLong				"A file name should have less than 256 characters." ;# NEW
::fsbox::mc::InvalidFileExtension		"'%s': érvénytelen kiterjesztés."
::fsbox::mc::MissingFileExtension		"'%s': hiányzó kiterjesztés."
::fsbox::mc::FileAlreadyExists			"\"%s\" fájl már létezik.\n\nFelül akarod írni?"
::fsbox::mc::CannotOverwriteDirectory	"'%s' könyvtár nem írható felül."
::fsbox::mc::FileDoesNotExist				"\"%s\" fájl nem létezik."
::fsbox::mc::DirectoryDoesNotExist		"\"%s\" könyvtár nem létezik."
::fsbox::mc::CannotOpenOrCreate			"Cannot open/create '%s'. Please choose a directory."
::fsbox::mc::WaitWhileDuplicating		"Please wait while duplicating file..."
::fsbox::mc::FileHasDisappeared			"File '%s' has disappeared." ;# NEW
::fsbox::mc::CannotDelete					"Cannot delete file '%s'." ;# NEW
::fsbox::mc::CannotRename					"Cannot rename file '%s'." ;# NEW
::fsbox::mc::CannotDeleteDetail			"This file is currently in use." ;# NEW
::fsbox::mc::CannotOverwrite			"Cannot overwrite file '%s'." ;# NEW

### toolbar ############################################################
::toolbar::mc::Toolbar		"Eszköztár"
::toolbar::mc::Orientation	"Orientation"
::toolbar::mc::Alignment	"Igazítás"
::toolbar::mc::IconSize		"Ikon méret"

::toolbar::mc::Default		"Default"
::toolbar::mc::Small			"Kicsi"
::toolbar::mc::Medium		"Közepes"
::toolbar::mc::Large			"Nagy"

::toolbar::mc::Top			"Felső"
::toolbar::mc::Bottom		"Alsó"
::toolbar::mc::Left			"Bal"
::toolbar::mc::Right			"Jobb"
::toolbar::mc::Center		"Középső"

::toolbar::mc::Flat			"Lapos"
::toolbar::mc::Floating		"Lebegő"
::toolbar::mc::Hide			"Elrejt"

::toolbar::mc::Expand		"Kibont" ;#?

### Countries ##########################################################
::country::mc::Afghanistan											"Afganisztán"
::country::mc::Netherlands_Antilles								"Holland Antillák"
::country::mc::Anguilla												"Anguilla"
::country::mc::Aboard_Aircraft									"Aboard Aircraft"
::country::mc::Aaland_Islands										"Aaland Islands"
::country::mc::Albania												"Albánia"
::country::mc::Algeria												"Algéria"
::country::mc::Andorra												"Andorra"
::country::mc::Angola												"Angola"
::country::mc::Antigua												"Antigua and Barbuda"
::country::mc::Australasia											"Australasia"
::country::mc::Argentina											"Argentína"
::country::mc::Armenia												"Örményország"
::country::mc::Aruba													"Aruba"
::country::mc::American_Samoa										"American Samoa"
::country::mc::Antarctica											"Antarktisz"
::country::mc::French_Southern_Territories					"French Southern Territories"
::country::mc::Australia											"Ausztrália"
::country::mc::Austria												"Ausztria"
::country::mc::Azerbaijan											"Azerbajdzsán"
::country::mc::Bahamas												"Bahamák"
::country::mc::Bangladesh											"Banglades"
::country::mc::Barbados												"Barbadosz"
::country::mc::Basque												"Baszkföld"
::country::mc::Burundi												"Burundi"
::country::mc::Belgium												"Belgium"
::country::mc::Benin													"Benin"
::country::mc::Bermuda												"Bermuda"
::country::mc::Bhutan												"Bhutan"
::country::mc::Bosnia_and_Herzegovina							"Bosznia and Herzegovina"
::country::mc::Belize												"Belize"
::country::mc::Belarus												"Fehéroroszország"
::country::mc::Bolivia												"Bolívia"
::country::mc::Brazil												"Brazília"
::country::mc::Bahrain												"Bahrein"
::country::mc::Brunei												"Brunei"
::country::mc::Botswana												"Botswana"
::country::mc::Bulgaria												"Bulgária"
::country::mc::Burkina_Faso										"Burkina Faso"
::country::mc::Bouvet_Islands										"Bouvet Islands"
::country::mc::Central_African_Republic						"Central African Republic"
::country::mc::Cambodia												"Kambodzsa"
::country::mc::Canada												"Kanada"
::country::mc::Catalonia											"Katalónia"
::country::mc::Cayman_Islands										"Kajmán szigetek"
::country::mc::Cocos_Islands										"Cocos Islands"
::country::mc::Congo													"Kongo (Brazzaville)"
::country::mc::Chad													"Csád"
::country::mc::Chile													"Csíle"
::country::mc::China													"Kína"
::country::mc::Ivory_Coast											"Elefántcsontpart"
::country::mc::Cameroon												"Kamerun"
::country::mc::DR_Congo												"Kongó"
::country::mc::Cook_Islands										"Cook Islands"
::country::mc::Colombia												"Kolumbia"
::country::mc::Comoros												"Comoros"
::country::mc::Cape_Verde											"Cape Verde"
::country::mc::Costa_Rica											"Costa Rica"
::country::mc::Croatia												"Horvátország"
::country::mc::Cuba													"Kuba"
::country::mc::Christmas_Island									"Christmas Island"
::country::mc::Cyprus												"Ciprus"
::country::mc::Czech_Republic										"Cseh Köztársaság"
::country::mc::Denmark												"Dánia"
::country::mc::Djibouti												"Djibouti"
::country::mc::Dominica												"Dominica"
::country::mc::Dominican_Republic								"Dominican Republic"
::country::mc::Ecuador												"Ecuador"
::country::mc::Egypt													"Egyiptom"
::country::mc::England												"Anglia"
::country::mc::Eritrea												"Eritrea"
::country::mc::El_Salvador											"El Salvador"
::country::mc::Western_Sahara										"Nyugat Szahara"
::country::mc::Spain													"Spanyolország"
::country::mc::Estonia												"Észtország"
::country::mc::Ethiopia												"Etiópia"
::country::mc::Faroe_Islands										"Feröer Szigetek"
::country::mc::Fiji													"Fiji"
::country::mc::Finland												"Finnország"
::country::mc::Falkland_Islands									"Falkland Szigetek"
::country::mc::France												"Franciaország"
::country::mc::West_Germany										"Nyugat Németország"
::country::mc::Micronesia											"Micronesia"
::country::mc::Gabon													"Gabon"
::country::mc::Gambia												"Gambia"
::country::mc::Great_Britain										"Nagy Britannia"
::country::mc::Guinea_Bissau										"Guinea-Bissau"
::country::mc::Gibraltar											"Gibraltár"
::country::mc::Guernsey												"Guernsey"
::country::mc::East_Germany										"Kelet Németország"
::country::mc::Georgia												"Grúzia"
::country::mc::Equatorial_Guinea									"Egyenlítői Guinea"
::country::mc::Germany												"Németország"
::country::mc::Ghana													"Gána"
::country::mc::Guadeloupe											"Guadeloupe"
::country::mc::Greece												"Görögország"
::country::mc::Grenada												"Granada"
::country::mc::Greenland											"Grönland"
::country::mc::Guatemala											"Guatemala"
::country::mc::French_Guiana										"Francia Guiana"
::country::mc::Guinea												"Guinea"
::country::mc::Guam													"Guam"
::country::mc::Guyana												"Guyana"
::country::mc::Haiti													"Haiti"
::country::mc::Hong_Kong											"Hong Kong"
::country::mc::Heard_Island_and_McDonald_Islands			"Heard Island and McDonald Islands"
::country::mc::Honduras												"Honduras"
::country::mc::Hungary												"Magyarország"
::country::mc::Isle_of_Man											"Isle of Man"
::country::mc::Indonesia											"Indonézia"
::country::mc::India													"India"
::country::mc::British_Indian_Ocean_Territory				"British Indian Ocean Territory"
::country::mc::Iran													"Irán"
::country::mc::Ireland												"Irország"
::country::mc::Iraq													"Irak"
::country::mc::Iceland												"Izland"
::country::mc::Israel												"Izrael"
::country::mc::Italy													"Olaszország"
::country::mc::British_Virgin_Islands							"British Virgin Islands"
::country::mc::Jamaica												"Jamaika"
::country::mc::Jersey												"Jersey"
::country::mc::Jordan												"Jordánia"
::country::mc::Japan													"Japan"
::country::mc::Kazakhstan											"Kazakhstan"
::country::mc::Kenya													"Kenya"
::country::mc::Kosovo												"Koszovó"
::country::mc::Kyrgyzstan											"Kirgizisztán"
::country::mc::Kiribati												"Kiribati"
::country::mc::South_Korea											"Dél-Korea"
::country::mc::Saudi_Arabia										"Szaúd-Arábia"
::country::mc::Kuwait												"Kuwait"
::country::mc::Laos													"Laosz"
::country::mc::Latvia												"Lettország"
::country::mc::Libya													"Líbia"
::country::mc::Liberia												"Liberia"
::country::mc::Saint_Lucia											"Saint Lucia"
::country::mc::Lesotho												"Lesotho"
::country::mc::Lebanon												"Libanon"
::country::mc::Liechtenstein										"Liechtenstein"
::country::mc::Lithuania											"Litvánia"
::country::mc::Luxembourg											"Luxemburg"
::country::mc::Macao													"Macao"
::country::mc::Madagascar											"Madagaszkár"
::country::mc::Morocco												"Marokkó"
::country::mc::Malaysia												"Malajzia"
::country::mc::Malawi												"Malawi"
::country::mc::Moldova												"Moldova"
::country::mc::Maldives												"Maldíve Szigetek"
::country::mc::Mexico												"Mexikó"
::country::mc::Mongolia												"Mongólia"
::country::mc::Marshall_Islands									"Marshall Islands"
::country::mc::Macedonia											"Macedónia"
::country::mc::Mali													"Mali"
::country::mc::Malta													"Málta"
::country::mc::Montenegro											"Montenegró"
::country::mc::Northern_Mariana_Islands						"Northern Mariana Islands"
::country::mc::Monaco												"Monakó"
::country::mc::Mozambique											"Mozambik"
::country::mc::Mauritius											"Mauritius"
::country::mc::Montserrat											"Montserrat"
::country::mc::Mauritania											"Mauritania"
::country::mc::Martinique											"Martinique"
::country::mc::Myanmar												"Myanmar"
::country::mc::Mayotte												"Mayotte"
::country::mc::Namibia												"Namíbia"
::country::mc::Nicaragua											"Nikaragua"
::country::mc::New_Caledonia										"Új Caledónia"
::country::mc::Netherlands											"Hollandia"
::country::mc::Nepal													"Nepál"
::country::mc::The_Internet										"The Internet"
::country::mc::Norfolk_Island										"Norfolk Island"
::country::mc::Nigeria												"Nigéria"
::country::mc::Niger													"Niger"
::country::mc::Northern_Ireland									"Észak-Írország"
::country::mc::Niue													"Niue"
::country::mc::Norway												"Norvégia"
::country::mc::Nauru													"Nauru"
::country::mc::New_Zealand											"Új-Zéland"
::country::mc::Oman													"Omán"
::country::mc::Pakistan												"Pakisztán"
::country::mc::Panama												"Panama"
::country::mc::Paraguay												"Paraguay"
::country::mc::Pitcairn_Islands									"Pitcairn Islands"
::country::mc::Peru													"Peru"
::country::mc::Philippines											"Fülöp-szigetek"
::country::mc::Palestine											"Palesztína"
::country::mc::Palau													"Palau"
::country::mc::Papua_New_Guinea									"Papua Új Guinea"
::country::mc::Poland												"Lengyelország"
::country::mc::Portugal												"Portugália"
::country::mc::North_Korea											"Észak-Korea"
::country::mc::Puerto_Rico											"Puerto Rico"
::country::mc::French_Polynesia									"Francia Polinézia"
::country::mc::Qatar													"Katar"
::country::mc::Reunion												"Reunion"
::country::mc::Romania												"Románia"
::country::mc::South_Africa										"Dél Afrika"
::country::mc::Russia												"Oroszország"
::country::mc::Rwanda												"Ruanda"
::country::mc::Samoa													"Szamoa"
::country::mc::Serbia_and_Montenegro							"Szerbia és Montenegro"
::country::mc::Scotland												"Skócia"
::country::mc::At_Sea												"At Sea"
::country::mc::Senegal												"Szenegál"
::country::mc::Seychelles											"Seychelle szigetek"
::country::mc::South_Georgia_and_South_Sandwich_Islands	"South Georgia and South Sandwich Islands"
::country::mc::Saint_Helena										"Saint Helena"
::country::mc::Singapore											"Szingapúr"
::country::mc::Jan_Mayen_and_Svalbard							"Svalbard and Jan Mayen"
::country::mc::Saint_Kitts_and_Nevis							"Saint Kitts and Nevis"
::country::mc::Sierra_Leone										"Sierra Leone"
::country::mc::Slovenia												"Szlovénia"
::country::mc::San_Marino											"San Marino"
::country::mc::Solomon_Islands									"Salamon Szigetek"
::country::mc::Somalia												"Szomália"
::country::mc::Aboard_Spacecraft									"Aboard Spacecraft"
::country::mc::Saint_Pierre_and_Miquelon						"Saint Pierre and Miquelon"
::country::mc::Serbia												"Szerbia"
::country::mc::Sri_Lanka											"Sri Lanka"
::country::mc::Sao_Tome_and_Principe							"Sao Tome and Principe"
::country::mc::Sudan													"Szudán"
::country::mc::Switzerland											"Svájc"
::country::mc::Suriname												"Suriname"
::country::mc::Slovakia												"Szlovákia"
::country::mc::Sweden												"Svédország"
::country::mc::Swaziland											"Szváziföld"
::country::mc::Syria													"Szíria"
::country::mc::Tanzania												"Tanzánia"
::country::mc::Turks_and_Caicos_Islands						"Turks and Caicos Islands"
::country::mc::Czechoslovakia										"Csehszlovákia"
::country::mc::Tonga													"Tonga"
::country::mc::Thailand												"Taiföld"
::country::mc::Tibet													"Tibet"
::country::mc::Tajikistan											"Tadzsikisztán"
::country::mc::Tokelau												"Tokelau"
::country::mc::Turkmenistan										"Türkmenisztán"
::country::mc::Timor_Leste											"Timor Leste"
::country::mc::Togo													"Togo"
::country::mc::Chinese_Taipei										"Tajvan"
::country::mc::Trinidad_and_Tobago								"Trinidad és Tobago"
::country::mc::Tunisia												"Tunézia"
::country::mc::Turkey												"Törökország"
::country::mc::Tuvalu												"Tuvalu"
::country::mc::United_Arab_Emirates								"Egyesült Arab Emirátusok"
::country::mc::Uganda												"Uganda"
::country::mc::Ukraine												"Ukrajna"
::country::mc::United_States_Minor_Outlying_Islands		"United States Minor Outlying Islands"
::country::mc::Unknown												"(Ismeretlen)"
::country::mc::Soviet_Union										"Szovjetúnió"
::country::mc::Uruguay												"Uruguay"
::country::mc::United_States_of_America						"Amerikai Egyesült Államok"
::country::mc::Uzbekistan											"Üzbegisztán"
::country::mc::Vanuatu												"Vanuatu"
::country::mc::Vatican												"Vatikán"
::country::mc::Venezuela											"Venezuela"
::country::mc::Vietnam												"Vietnám"
::country::mc::Saint_Vincent_and_the_Grenadines				"Saint Vincent and the Grenadines"
::country::mc::US_Virgin_Islands									"US Virgin Islands"
::country::mc::Wallis_and_Futuna									"Wallis and Futuna"
::country::mc::Wales													"Wales"
::country::mc::Yemen													"Jemen"
::country::mc::Yugoslavia											"Jugoszlávia"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzibár"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Mixed Team"

::country::mc::Africa_North										"Észak Afrika"
::country::mc::Africa_Sub_Saharan								"Afrika, Sub-Saharan"
::country::mc::America_Caribbean									"Amerika, Karibi térség"
::country::mc::America_Central									"Amerika, Közép"
::country::mc::America_North										"Amerika, Észak"
::country::mc::America_South										"Amerika, Dél"
::country::mc::Antarctic											"Antarktisz"
::country::mc::Asia_East											"Ázsia, Kelet"
::country::mc::Asia_South_South_East							"Ázsia, Dél-Dél-Kelet"
::country::mc::Asia_West_Central									"Ázsia, Nyugat-Közép"
::country::mc::Europe												"Európa"
::country::mc::Europe_East											"Európa, Kelet"
::country::mc::Oceania												"Óceánia"
::country::mc::Stateless											"Stateless"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"Afrikaans"
::encoding::mc::Lang(ar)	"arab"
::encoding::mc::Lang(ast)	"Leonese"
::encoding::mc::Lang(az)	"azerbajdzsáni"
::encoding::mc::Lang(bat)	"Baltic"
::encoding::mc::Lang(be)	"fehérorosz"
::encoding::mc::Lang(bg)	"bolgár"
::encoding::mc::Lang(br)	"Breton"
::encoding::mc::Lang(bs)	"bosnyák"
::encoding::mc::Lang(ca)	"katalán"
::encoding::mc::Lang(cs)	"cseh"
::encoding::mc::Lang(cy)	"Walesi"
::encoding::mc::Lang(da)	"dán"
::encoding::mc::Lang(de)	"német"
::encoding::mc::Lang(de+)	"német (új)"
::encoding::mc::Lang(el)	"görög"
::encoding::mc::Lang(en)	"angol"
::encoding::mc::Lang(eo)	"eszperantó"
::encoding::mc::Lang(es)	"spanyol"
::encoding::mc::Lang(et)	"észt"
::encoding::mc::Lang(eu)	"baszk"
::encoding::mc::Lang(fi)	"finn"
::encoding::mc::Lang(fo)	"Faroese"
::encoding::mc::Lang(fr)	"francia"
::encoding::mc::Lang(fy)	"Frisian"
::encoding::mc::Lang(ga)	"ír"
::encoding::mc::Lang(gd)	"skót"
::encoding::mc::Lang(gl)	"Galician"
::encoding::mc::Lang(he)	"héber"
::encoding::mc::Lang(hi)	"hindi"
::encoding::mc::Lang(hr)	"horvát"
::encoding::mc::Lang(hu)	"magyar"
::encoding::mc::Lang(hy)	"örmény"
::encoding::mc::Lang(ia)	"Interlingua"
::encoding::mc::Lang(is)	"izlandi"
::encoding::mc::Lang(it)	"olasz"
::encoding::mc::Lang(iu)	"Inuktitut"
::encoding::mc::Lang(ja)	"japán"
::encoding::mc::Lang(ka)	"grúz"
::encoding::mc::Lang(kk)	"kazak"
::encoding::mc::Lang(kl)	"grönlandi"
::encoding::mc::Lang(ko)	"koreai"
::encoding::mc::Lang(ku)	"kurd"
::encoding::mc::Lang(ky)	"kirgiz"
::encoding::mc::Lang(la)	"latin"
::encoding::mc::Lang(lb)	"luxemburgi"
::encoding::mc::Lang(lt)	"litván"
::encoding::mc::Lang(lv)	"lett"
::encoding::mc::Lang(mk)	"macedón"
::encoding::mc::Lang(mo)	"moldáv"
::encoding::mc::Lang(ms)	"maláj"
::encoding::mc::Lang(mt)	"máltai"
::encoding::mc::Lang(nl)	"holand"
::encoding::mc::Lang(no)	"norvég"
::encoding::mc::Lang(oc)	"Occitan"
::encoding::mc::Lang(pl)	"lengyel"
::encoding::mc::Lang(pt)	"portugál"
::encoding::mc::Lang(rm)	"Romansh"
::encoding::mc::Lang(ro)	"román"
::encoding::mc::Lang(ru)	"orosz"
::encoding::mc::Lang(se)	"Sami"
::encoding::mc::Lang(sk)	"szlovák"
::encoding::mc::Lang(sl)	"szlovén"
::encoding::mc::Lang(sq)	"albán"
::encoding::mc::Lang(sr)	"szerb"
::encoding::mc::Lang(sv)	"svéd"
::encoding::mc::Lang(sw)	"Swahili"
::encoding::mc::Lang(tg)	"tadzsik"
::encoding::mc::Lang(th)	"thai"
::encoding::mc::Lang(tk)	"türkmén"
::encoding::mc::Lang(tl)	"Tagalog"
::encoding::mc::Lang(tr)	"török"
::encoding::mc::Lang(uk)	"ukrán"
::encoding::mc::Lang(uz)	"üzbég"
::encoding::mc::Lang(vi)	"vietnámi"
::encoding::mc::Lang(wa)	"Walloon"
::encoding::mc::Lang(wen)	"Sorbian"
::encoding::mc::Lang(hsb)	"Upper Sorbian" ;# NEW
::encoding::mc::Lang(dsb)	"Lower Sorbian" ;# NEW
::encoding::mc::Lang(zh)	"Kínai"

::encoding::mc::Font(hi)	"Devanagari"

### Calendar ###########################################################
::calendar::mc::OneMonthForward	"Egy hónappal előre (Shift \u2192)"
::calendar::mc::OneMonthBackward	"Egy hónappal vissza (Shift \u2190)"
::calendar::mc::OneYearForward	"Egy évvel előre (Ctrl \u2192)"
::calendar::mc::OneYearBackward	"Egy évvel vissza (Ctrl \u2190)"

::calendar::mc::Su	"Va"
::calendar::mc::Mo	"Hé"
::calendar::mc::Tu	"Ke"
::calendar::mc::We	"Sze"
::calendar::mc::Th	"Cs"
::calendar::mc::Fr	"Pé"
::calendar::mc::Sa	"Szo"

::calendar::mc::Jan	"jan"
::calendar::mc::Feb	"feb"
::calendar::mc::Mar	"már"
::calendar::mc::Apr	"ápr"
::calendar::mc::May	"máj"
::calendar::mc::Jun	"jún"
::calendar::mc::Jul	"júl"
::calendar::mc::Aug	"aug"
::calendar::mc::Sep	"szept"
::calendar::mc::Oct	"okt"
::calendar::mc::Nov	"nov"
::calendar::mc::Dec	"dec"

::calendar::mc::MonthName(1)		"Január"
::calendar::mc::MonthName(2)		"Február"
::calendar::mc::MonthName(3)		"Március"
::calendar::mc::MonthName(4)		"Április"
::calendar::mc::MonthName(5)		"Május"
::calendar::mc::MonthName(6)		"Június"
::calendar::mc::MonthName(7)		"Július"
::calendar::mc::MonthName(8)		"Augusztus"
::calendar::mc::MonthName(9)		"Szeptember"
::calendar::mc::MonthName(10)		"Október"
::calendar::mc::MonthName(11)		"November"
::calendar::mc::MonthName(12)		"December"

::calendar::mc::WeekdayName(0)	"Vasárnap"
::calendar::mc::WeekdayName(1)	"Hétfő"
::calendar::mc::WeekdayName(2)	"Kedd"
::calendar::mc::WeekdayName(3)	"Szerda"
::calendar::mc::WeekdayName(4)	"Csütörtök"
::calendar::mc::WeekdayName(5)	"Péntek"
::calendar::mc::WeekdayName(6)	"Szombat"

### remote #############################################################
::remote::mc::PostponedMessage "\"%s\" adatbázis megnyitása elhalasztva, amíg az aktuális művelet be nem fejeződik."

# vi:set ts=8 sw=8:
