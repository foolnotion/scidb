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
# Copyright: (C) 2011-2013 Zoltan Tibenszky
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
::mc::SortMapping	{Á A É E Í I Ó O Ú U á a é e í i ó o ú u}
::mc::AsciiMapping	{Á A É E Í I Ó O Ö O Ő O Ú U Ü U Ű U á a é e í i ó o ö o ő o ú u ü u ű u}
::mc::SortOrder		{{c cs} {d dz dzs} {g gy} {l ly} {n ny} {o {ö ő}} {s sz} {t ty} {u {ü ű}} {z zs}}

::mc::Key(Alt)			"Alt" ;# NEW
::mc::Key(BS)			"\u27fb" ;# "\u232b" is correct, but difficult to read
::mc::Key(Ctrl)			"Ctrl" ;# NEW
::mc::Key(Del)			"Delete" ;# NEW
::mc::Key(Down)			"\u2193"
::mc::Key(End)			"End" ;# NEW
::mc::Key(Enter)		"\u23ce"
::mc::Key(Esc)			"Kilépés"
::mc::Key(Home)			"Home" ;# NEW
::mc::Key(Ins)			"Ins" ;# NEW
::mc::Key(Left)			"\u2190"
::mc::Key(Next)			"Page\u2193"	;# Page Down NEW
::mc::Key(Option)		"option"	;# Mac
::mc::Key(Prior)		"Page\u2191"	;# Page Up NEW
::mc::Key(Right)		"\u2192"
::mc::Key(Shift)		"Shift" ;# NEW
::mc::Key(Space)		"\u2423"
::mc::Key(Up)			"\u2191"

::mc::Alignment			"Sorba rendezés(?)"
::mc::Apply			"Alkalmaz"
::mc::Archive			"Archive" ;# NEW
::mc::Background		"Háttér"
::mc::Black			"Sötét"
::mc::Bottom			"Alsó"	;#Alul??
::mc::Cancel			"Mégse"
::mc::Clear			"Törlése"
::mc::Close			"Bezár"
::mc::Color			"Szín"
::mc::Colors			"Színek"
::mc::Configuration		"Beállítás" ;#"Configuration"
::mc::Copy			"Másol"
::mc::Cut			"Kivág"
::mc::Dark			"Sötét"
::mc::Database			"Adatbázis"
::mc::Default			"Alapértelmezett"
::mc::Delete			"Töröl"
::mc::Edit			"Szerkeszt"
::mc::Empty			"Empty" ;# NEW
::mc::File			"Fájl"
::mc::Filter			"Filter" ;# NEW
::mc::From			"From" ;# NEW
::mc::Game			"Játszma"
::mc::Layout			"Layout"
::mc::Left			"Bal"
::mc::Lite			"Világos"
::mc::Low					"Low" ;# NEW
::mc::Modify			"Módosít"
::mc::No			"Nem"
::mc::Normal			"Normal" ;# NEW
::mc::Number			"Szám"
::mc::OK			"OK"
::mc::Order			"Rendezés"
::mc::Paste			"Beillesztés"
::mc::PieceSet			"Bábukészlet"
::mc::Preview			"Előnézet"
::mc::Redo			"Újra"
::mc::Remove			"Eltávolítás"
::mc::Reset			"Reset"
::mc::Right			"Jobb"
::mc::SelectAll			"Mindent kijelöl"
::mc::Texture			"Textúra"
::mc::Theme			"Téma"
::mc::To			"To" ;# NEW
::mc::Top			"Felső"  ;# felül
::mc::Undo			"Visszavonás"
::mc::Variant			"Variant" ;# NEW different from "Variation"
::mc::Variation			"Variáció"
::mc::White			"Világos"
::mc::Yes			"igen"

::mc::Piece(K)			"Király"
::mc::Piece(Q)			"Vezér"
::mc::Piece(R)			"Bástya"
::mc::Piece(B)			"Futó"
::mc::Piece(N)			"Huszár"
::mc::Piece(P)			"Gyalog"

::mc::Logical(reset)		"Reset" ;# NEW
::mc::Logical(or)		"Vagy"
::mc::Logical(and)		"És"
::mc::Logical(null)		"None" ;# NEW
::mc::Logical(remove)		"Remove" ;# NEW
::mc::Logical(not)		"Nem"

::mc::LogicalDetail(reset)	"Clear filter / Reset display" ;# NEW
::mc::LogicalDetail(or)		"Remove from filter / Add to display" ;# NEW
::mc::LogicalDetail(and)	"Extend filter / Restrict display" ;# NEW
::mc::LogicalDetail(null)	"Fill filter / Clear display" ;# NEW
::mc::LogicalDetail(remove)	"Add to filter / Remove from display" ;# NEW
::mc::LogicalDetail(not)	"Restrict filter / Extent display" ;# NEW

::mc::VariantName(Undetermined)	"Undetermined" ;# NEW
::mc::VariantName(Normal)	"Normal Chess" ;# NEW
::mc::VariantName(Bughouse)	"Bughouse Chess" ;# NEW
::mc::VariantName(Crazyhouse)	"Crazyhouse Chess" ;# NEW
::mc::VariantName(ThreeCheck)	"Three-check Chess" ;# NEW
::mc::VariantName(Antichess)	"Antichess" ;# NEW
::mc::VariantName(Suicide)	"Suicide" ;# NEW
::mc::VariantName(Giveaway)	"Giveaway" ;# NEW
::mc::VariantName(Losers)	"Losers" ;# NEW
::mc::VariantName(Chess960)	"Chess 960" ;# NEW
::mc::VariantName(Symm960)	"Chess 960 (symmetrical only)" ;# NEW
::mc::VariantName(Shuffle)	"Shuffle Chess" ;# NEW

### themes #############################################################
::scidb::themes::mc::CannotOverwriteTheme	"A %s témát nem lehet felülírni."

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
::widget::mc::Help		"&Súgó"
::widget::mc::Start		"&Start"  ;#NEW

::widget::mc::New		"&Új"
::widget::mc::Save		"Menté&s"
::widget::mc::Delete		"&Töröl"

::widget::mc::Control(minimize)	"Minimálizálás" ;#"Minimize"
::widget::mc::Control(restore)	"Teljes képernyő bezárása"
::widget::mc::Control(close)	"Bezár"

### util ###############################################################

::util::mc::IOErrorOccurred			"I/O hiba történt"

::util::mc::IOError(CreateFailed)		"no permissions to create files" ;# NEW
::util::mc::IOError(OpenFailed)			"Sikertelen megynitási művelet"
::util::mc::IOError(ReadOnly)			"Írásvédett adatbázis"
::util::mc::IOError(UnknownVersion)		"Ismeretlen kiterjesztés (UnknownVersion)"
::util::mc::IOError(UnexpectedVersion)		"unexpected file version"
::util::mc::IOError(Corrupted)			"Hibás fájl"
::util::mc::IOError(WriteFailed)		"Sikertelen írási művelet"
::util::mc::IOError(InvalidData)		"Érvénytelen adat (valószínűleg sérült fájl)"
::util::mc::IOError(ReadError)			"olvasási hiba"
::util::mc::IOError(EncodingFailed)		"namebase fájl nem írható"
::util::mc::IOError(MaxFileSizeExceeded)	"túl nagy fájlméret"
::util::mc::IOError(LoadFailed)			"Betöltési hiba (túl sok bejegyzés)"
::util::mc::IOError(NotOriginalVersion)		"file has changed outside from this session since last open" ;# NEW

::util::mc::SelectionOwnerDidntRespond		"Timeout during drop action: selection owner didn't respond." ;# NEW

### progress ###########################################################
::progress::mc::Progress			"Állapot"

;# Nem biztos, hogy a lista az "index" jó fordítása
::progress::mc::Message(preload-namebase)	"Játékos adatbázis olvasásának előkészítése"
::progress::mc::Message(preload-tournament)	"Verseny lista előkészítése"
::progress::mc::Message(preload-player)		"Játékos lista előkészítése"
::progress::mc::Message(preload-annotator)	"Szerkesztők listájának előkészítése"

::progress::mc::Message(read-index)		"Indexek betöltése"
::progress::mc::Message(read-game)		"Játszma adatok betöltése"
::progress::mc::Message(read-namebase)		"Játékos adatbázis betöltése"
::progress::mc::Message(read-tournament)	"Verseny lista betöltése"
::progress::mc::Message(read-player)		"Játékos lista betöltése"
::progress::mc::Message(read-annotator)		"Szerkesztő lista betöltése"
::progress::mc::Message(read-source)		"Forrás lista betöltése"
::progress::mc::Message(read-team)		"Csapat lista betöltése"
::progress::mc::Message(read-init)		"Inicializálás"

::progress::mc::Message(write-index)		"Lista írása"
::progress::mc::Message(write-game)		"Játszma adatok írása"
::progress::mc::Message(write-namebase)		"Játékos adatbázis írása"

::progress::mc::Message(print-game)		"%s játszmá(k) nyomtatása"
::progress::mc::Message(copy-game)		"%s játszná(k) másolása"

### menu ###############################################################
::menu::mc::Theme			"Téma"
::menu::mc::ColorScheme			"Color Scheme" ;# NEW
::menu::mc::CustomStyleMenu		"Scidb's Style Menu" ;# NEW
::menu::mc::DefaultStyleMenu		"Default Style Menu" ;# NEW
::menu::mc::OrdinaryMonitor		"Ordinary Monitor" ;# NEW
::menu::mc::HighQualityMonitor		"High Quality Monitor" ;# NEW
::menu::mc::RestartRequired		"A restart of the application is required before this change can be applied everyplace." ;# NEW

::menu::mc::AllScidbFiles		"Minden Scidb fájl"
::menu::mc::AllScidbBases		"Minde Scidb adatbázis"
::menu::mc::ScidBases			"Scid adatbázisok"
::menu::mc::ScidbBases			"Scidb adatbázisok"
::menu::mc::ChessBaseBases		"ChessBase adatbázisok"
::menu::mc::ScidbArchives		"Scidb archívumok"
::menu::mc::PGNFilesArchives		"PGN fájlok/arhívumok"
::menu::mc::PGNFiles			"PGN fájlok"
::menu::mc::PGNFilesCompressed		"PGN fájlok (tömörített)"
::menu::mc::BPGNFilesArchives		"BPGN fájlok/arhívumok"
::menu::mc::BPGNFiles			"BPGN fájlok"
::menu::mc::BPGNFilesCompressed		"BPGN fájlok (tömörített)"
::menu::mc::PGNArchives			"PGN arhívumok"

::menu::mc::Language			"N&yelv"
::menu::mc::Toolbars			"&Eszköztár"
::menu::mc::ShowLog			"&Log fájl mutatása"
::menu::mc::AboutScidb			"Scidb &Névjegy"
::menu::mc::Fullscreen			"&Teljes képernyő"
::menu::mc::LeaveFullscreen		"Leave &Teljes képernyő" ;# NEW "Leave Full-Screen"
::menu::mc::Help			"&Súgó"
::menu::mc::Contact			"&Elérhetőség (Web böngésző)"
::menu::mc::Quit			"&Kilépés"
::menu::mc::Tools			"&Tools" ;# NEW
::menu::mc::Extras						"E&xtras" ;# NEW
::menu::mc::Setup						"&Beállítások"

# Contact
::menu::mc::ContactBugReport		"&Hiba jelentés"
::menu::mc::ContactFeatureRequest	"&Feature Request" ;# NEW

# Extras
::menu::mc::InstallChessBaseFonts	"ChessBase betűtípusok telepítése" ;#"Install ChessBase Fonts"  ;#NEW
::menu::mc::OpenEngineLog		"&Elemző konzol megnyitása"  ;#NEW
::menu::mc::AssignFileTypes		"Assign File &Types" ;# NEW

# Tools
::menu::mc::OpenEngineDictionary	"Open Engine &Dictionary" ;# NEW
::menu::mc::OpenPlayerDictionary	"Open &Player Dictionary" ;# NEW

# Setup
::menu::mc::Engines			"Elemző &modulok"
::menu::mc::PgnOptions			"Setup &PGN export options" ;# NEW
::menu::mc::PrivatePlayerCard		"&Private Player Card" ;# NEW

::menu::mc::OpenFile			"Scidb fájl megnyitása"
::menu::mc::NewFile			"Scidb fájl létrehozása"
::menu::mc::Archiving			"Archíválás"
::menu::mc::CreateArchive		"Archívum készítése"
::menu::mc::BuildArchive		"Archívum %s készítése"
::menu::mc::Data			"%s adat"

# Default Application
::menu::mc::Assign			"assign" ;# NEW
::menu::mc::FailedSettingDefaultApp	"Failed to set Scidb as a default application for %s." ;# NEW
::menu::mc::SuccessSettingDefaultApp	"Successfully set Scidb as a default application for %s." ;# NEW
::menu::mc::CommandFailed		"Command '%s' failed." ;# NEW

### load ###############################################################
::load::mc::SevereError				"Az ECO fájl beolvasása közben súlyos hiba történt"
::load::mc::FileIsCorrupt			"A %s fájl sérült:"
::load::mc::ProgramAborting		"A program kilép (aborting)."
::load::mc::EngineSetupFailed		"Elemző modul konfigurációs fájljának betöltése meghiúsult"

::load::mc::Loading					"%s betöltése"
::load::mc::StartupFinished		"A betöltés befejeződött"
::load::mc::SystemEncoding	"A rendszer által használt kódolás: '%s'"

::load::mc::ReadingFile(options)	"beállítások beolvasása"
::load::mc::ReadingFile(engines)	"Elemző modul fájljainak beolvasása"

::load::mc::ECOFile					"ECO adatbázis"
::load::mc::EngineFile				"Elemző modul"
::load::mc::SpellcheckFile			"Játékos-adatbázis"  ;#"Játékos-adatbázis fájl"
::load::mc::LocalizationFile		"Lokalizációs fájl"
::load::mc::RatingList				"%s erősorrend lista"
::load::mc::WikipediaLinks			"Wikipedia linkek"
::load::mc::ChessgamesComLinks	"chessgames.com linkek"
::load::mc::Cities					"Városok"
::load::mc::PieceSet					"Bábukészlet"
::load::mc::Theme						"Téma"
::load::mc::Icons						"Ikonok"

### archive ############################################################
::archive::mc::CorruptedArchive			"'%s' archívum hibás."
::archive::mc::NotAnArchive				"'%s' nem archívum."
::archive::mc::CorruptedHeader			"'%s' archívum fejléce hibás."
::archive::mc::CannotCreateFile			"'%s' létrehozása meghiúsult."
::archive::mc::FailedToExtractFile		"'%s' kicsomagolása meghiúsult."
::archive::mc::UnknownCompression		"Ismeretlen tömörítési eljárás: '%s'."
::archive::mc::ChecksumError				"Ellenörző kód (Checksum) hiba '%s' kicsomagolásánál."
::archive::mc::ChecksumErrorDetail		"A kicsomagolt '%s' fájl hibás lehet."
::archive::mc::FileNotReadable			"'%s' fájl nem olvasható."
::archive::mc::UsingRawInstead			"'raw' tömörítési eljárás használata"
::archive::mc::CannotOpenArchive			"'%s' archívum megnyitása nem sikerült."
::archive::mc::CouldNotCreateArchive	"'%s' archívum létrehozása meghiúsult."

::archive::mc::PackFile						"%s csomagolása"
::archive::mc::UnpackFile					"%s kicsomagolása"

### player photos ######################################################
::util::photos::mc::InstallPlayerPhotos		"Játékos fotók telepítése/frissítése"
::util::photos::mc::TimeOut			"Időtúllépés"  ;#"Timeout occurred."
::util::photos::mc::EnterPassword		"Jelszó"
::util::photos::mc::Download			"Letöltés"
# A következő kettő nem biztos, hogy pontos... 
::util::photos::mc::SharedInstallation		"Mehosztott (shared) telepítés"
::util::photos::mc::LocalInstallation		"Saját telepítés"
::util::photos::mc::RetryLater			"Kérjük próbálja meg újra később."
::util::photos::mc::DownloadStillInProgress	"Fényképek letöltése folyamatban."
::util::photos::mc::PhotoFiles			"Fényképek"

::util::photos::mc::RequiresSuperuserRights	"A telepítés rendszergazdai jogosultságot igényel.\n\nHa a felhasználói fiókod nincs a sudoers fájlban, akkor nem szerezhetsz rendszergazdai jogosultságot a sudo paranccsal."
::util::photos::mc::RequiresInternetAccess	"A játékosok fényképeinek telepítéshez/frissétéséhez internet kapcsolatot szükséges."
::util::photos::mc::AlternativelyDownload(0)	"A fényképek a %link%-ről is letölthetőek. Ezeket a fájlokat másold a %local% könyvtárba."
::util::photos::mc::AlternativelyDownload(1)	"Alternatively you may download the photo files from %link%. Install these files into the shared directory %shared%, or into the private directory %local%."  ;#NEW

::util::photos::mc::Error(nohttp)		"Internet kapcsolat nem hozható létre a TclHttp csomag hiánya miatt."
::util::photos::mc::Error(busy)			"Telepítés/frissítés folyamatban." ;#"The installation/update is already running."  ;#NEW
::util::photos::mc::Error(failed)		"Unexpected error: The invocation of the sub-process has failed."  ;#NEW
::util::photos::mc::Error(passwd)		"A jelszó hibás."
::util::photos::mc::Error(nosudo)		"Cannot invoke 'sudo' command because your user is not in the sudoers file."  ;#NEW
::util::photos::mc::Detail(nosudo)		"As a workaround you may do a private installation, or start this application as a super-user."  ;#NEW

::util::photos::mc::Message(uptodate)		"A fényképek naprakészek"
::util::photos::mc::Message(finished)		"A fényképek telepítése/frissítése befejeződött"
::util::photos::mc::Message(broken)		"Sérült Tcl könyvtár verzió"
::util::photos::mc::Message(noperm)		"A '%s' könyvtárhoz nincs írási jogosultsága."
::util::photos::mc::Message(missing)		"'%s' könyvtár nem található."
::util::photos::mc::Message(httperr)		"HTTP hiba: %s"
::util::photos::mc::Message(httpcode)		"Váratlan HTTP utasítás: %s."
::util::photos::mc::Message(noconnect)		"HTTP kapcsolat megszakadt."
::util::photos::mc::Message(timeout)		"HTTP kapcsolat túllépte az időkeretet."
::util::photos::mc::Message(crcerror)		"Checksum error occurred. Possibly the file server is currently in maintenance mode." ;# NEW
::util::photos::mc::Message(maintenance)	"Photo file server maintenance is currently in progress." ;# NEW
::util::photos::mc::Message(notfound)		"Download aborted because photo file server maintenance is currently in progress." ;# NEW
::util::photos::mc::Message(aborted)		"User has aborted download." ;# NEW
::util::photos::mc::Message(killed)		"Unexpected termination of download. The sub-process has died." ;# NEW

::util::photos::mc::Detail(nohttp)		"Kérem telepítse a TclHttp csomagot. Pl.: %s."
::util::photos::mc::Detail(noconnect)		"Probably you don't have an internet connection." ;# NEW
::util::photos::mc::Detail(badhost)		"Another possibility is a bad host, or a bad port." ;# NEW

::util::photos::mc::Log(started)		"Installation/update of photo files started at %s." ;# NEW
::util::photos::mc::Log(finished)		"Installation/update of photo files finished at %s." ;# NEW
::util::photos::mc::Log(destination)		"Destination directory for photo file download is '%s'." ;# NEW
::util::photos::mc::Log(created:1)		"%s fájl létrehozva."
::util::photos::mc::Log(created:N)		"%s fájlok létrehozva."
::util::photos::mc::Log(deleted:1)		"%s fájl törölve."
::util::photos::mc::Log(deleted:N)		"%s fájlok törölve."
::util::photos::mc::Log(skipped:1)		"%s fájl kihagyva."
::util::photos::mc::Log(skipped:N)		"%s fájlok kihagyva."
::util::photos::mc::Log(updated:1)		"%s fájl frissítve."
::util::photos::mc::Log(updated:N)		"%s fájlok frissítve."

### application ########################################################
::application::mc::Database			"&Adatbázis"
::application::mc::Board			"&Tábla"
::application::mc::MainMenu			"Fő&menü"

::application::mc::DockWindow			"Ablak dokkolása"
::application::mc::UndockWindow			"Dokkolás visszavonása"
::application::mc::ChessInfoDatabase		"Chess Information Data Base"
::application::mc::Shutdown			"Kilépés..."
::application::mc::QuitAnyway			"Biztos ki akar lépni?"
::application::mc::CancelLogout			"Cancel Logout" ;# NEW
::application::mc::AbortWriteOperation		"Abort write operation" ;# NEW

::application::mc::UpdatesAvailable		"Új frissítés érhető el"

::application::mc::WriteOperationInProgress	"Write operation in progress: currently Scidb is modifying/writing database '%s'." ;# NEW
::application::mc::LogoutNotPossible		"Logout is currently not possible, the result would be a corrupted database." ;# NEW
::application::mc::RestartLogout		"Aborting the write operation will restart the logout process." ;# NEW
::application::mc::UnsavedFiles			"The following PGN files are unsaved:" ;# NEW
::application::mc::ThrowAwayAllChanges		"Do you really want to throw away all changes?" ;# NEW

::application::mc::Deleted			"Games deleted: %d" ;# NEW
::application::mc::Changed			"Games changed: %d" ;# NEW
::application::mc::Added			"Games added: %d" ;# NEW
::application::mc::DescriptionHasChanged	"Description has changed" ;# NEW

### application::board #################################################
::application::board::mc::ShowCrosstable		"Mutasd a verseny kereszttábláját"
::application::board::mc::StartEngine			"Elemzőmodul indítása"
::application::board::mc::StopEngine			"Elemzőmodul leállítása"
::application::board::mc::InsertNullMove		"Insert null move" ;# NEW
::application::board::mc::SelectStartPosition		"Select Start Position" ;# NEW
::application::board::mc::LoadRandomGame		"Load random game" ;# NEW

::application::board::mc::Tools				"Eszközök"
::application::board::mc::Control			"Kezelés"
::application::board::mc::Game				"Játszma"
::application::board::mc::GoIntoNextVar			"Következő variáció"
::application::board::mc::GoIntPrevVar			"Előző variáció"

::application::board::mc::LoadGame(next)		"Következő játszma betöltése"
::application::board::mc::LoadGame(prev)		"Előző játszma betöltése"
::application::board::mc::LoadGame(first)		"Első játszma betöltése"
::application::board::mc::LoadGame(last)		"Utolsó játszma betöltése"

::application::board::mc::SwitchView(base)		"Switch to database view" ;# NEW
::application::board::mc::SwitchView(list)		"Switch to game list view" ;# NEW

::application::board::mc::Accel(edit-annotation)	"A"
::application::board::mc::Accel(edit-comment)		"C"
::application::board::mc::Accel(edit-marks)		"M"
::application::board::mc::Accel(add-new-game)		"S" ;# NEW
::application::board::mc::Accel(replace-game)		"R" ;# NEW
::application::board::mc::Accel(replace-moves)		"V" ;# NEW
::application::board::mc::Accel(trial-mode)		"T" ;# NEW

### application::database ##############################################
::application::database::mc::FileOpen			"Fájl megnyitása"
::application::database::mc::FileOpenRecent		"Legutóbbi fájlok Megnyitása"
::application::database::mc::FileNew			"Új"
::application::database::mc::FileExport			"Exportálás"
::application::database::mc::FileImport(pgn)		"PGN fájlok importálás..."
::application::database::mc::FileImport(db)		"Adatbázis importálása "
::application::database::mc::FileCreate			"Archívum létrehozása"
::application::database::mc::FileSaveChanges		"Save Changes" ;# NEW
::application::database::mc::FileClose			"Bezárás"
::application::database::mc::FileMaintenance		"Karbantartás"
::application::database::mc::FileCompact		"Kompakt"
::application::database::mc::FileStripMoveInfo		"Strip Move Information" ;# NEW
::application::database::mc::FileStripPGNTags		"Strip PGN Tags" ;# NEW
::application::database::mc::HelpSwitcher		"Adatbázis váltó(?) Súgó"

::application::database::mc::Games			"&Játszmák"
::application::database::mc::Players			"Já&tékosok"
::application::database::mc::Events			"&Versenyek"
::application::database::mc::Sites			"&Helyszín"  ;#NEW
::application::database::mc::Annotators			"&Elemző"

::application::database::mc::File			"Fájl"
::application::database::mc::SymbolSize			"Szimvólum méret"
::application::database::mc::Large			"Nagy"
::application::database::mc::Medium			"Közepes"
::application::database::mc::Small			"Kicsi"
::application::database::mc::Tiny			"Apró"
::application::database::mc::LoadMessage		"Adatbázis megnyitása: %s"
::application::database::mc::UpgradeMessage		"Adatbázis frissítése %s"
::application::database::mc::CompactMessage		"%s adatbázis tömörítése"
::application::database::mc::CannotOpenFile		"A fájl nem nyitható meg olvasásra: '%s'."
::application::database::mc::EncodingFailed		"%s kódolása sikertelen." ;# "Character decoding %s failed."
::application::database::mc::DatabaseAlreadyOpen	"Az '%s' adatbázis már meg van nyitva."
::application::database::mc::Properties			"Tulajdonságok"
::application::database::mc::Preload			"Előtöltés"
::application::database::mc::MissingEncoding		"Hiányos kódolás %s (használd inkább %s-t)" ;# NEW "Missing character encoding %s (using %s instead)"
::application::database::mc::DescriptionTooLarge	"Túl hosszú leírás."
::application::database::mc::DescrTooLargeDetail	"A mező %d karaktert tartalmaz, de csak %d megengedett."
::application::database::mc::ClipbaseDescription	"Ideiglenes adatbázis, nincs elmentve a lemezre."
::application::database::mc::HardLinkDetected		"'%file1' betöltése sikertelen. Már '%file2'-ként betöltődött. Ez csak \"hard linkek\" esetén történhet meg."
::application::database::mc::HardLinkDetectedDetail	"If we load this database twice the application may crash due to the usage of threads."  ;#NEW
::application::database::mc::OverwriteExistingFiles	"Felül kívánja írni a %s könyvtárban lévő fájlokat?"
::application::database::mc::SelectDatabases		"Válassza ki a megnyitni kívánt adatbázist"
::application::database::mc::ExtractArchive		"%s archívum kicsomagolása"
::application::database::mc::SelectVariant		"Select Variant" ;# NEW
::application::database::mc::Example			"Example" ;# NEW
::application::database::mc::UnsavedFiles		"This PGN file is unsaved." ;# NEW
::application::database::mc::FileIsRemoved		"File '%s' is removed. Please use the export dialog if you like to save this database." ;# NEW
::application::database::mc::FileIsNotWritable		"File '%s' is not writeable. Please use the export dialog if you like to save this database, or set this file writeable." ;# NEW
::application::database::mc::OverwriteOriginalFile	"Important note: The original file '%s' will be overwritten." ;# NEW
::application::database::mc::SetupPgnOptions		"Probably the PGN options should be set before saving." ;# NEW

::application::database::mc::RecodingDatabase		"Recoding %s from %s to %s"
::application::database::mc::RecodedGames		"%s game(s) recoded"

::application::database::mc::ChangeIcon			"Ikon cseréje"
::application::database::mc::Recode			"Újrakódolás"
::application::database::mc::EditDescription		"Leírás szerkesztése"
::application::database::mc::EmptyClipbase		"Üres vágólap"

::application::database::mc::Maintenance		"Maintenance" ;# NEW
::application::database::mc::StripMoveInfo		"Strip move information from database '%s'" ;# NEW
::application::database::mc::StripPGNTags		"Strip PGN tags from database '%s'" ;# NEW
::application::database::mc::GamesStripped(0)		"No game stripped." ;# NEW
::application::database::mc::GamesStripped(1)		"One game stripped." ;# NEW
::application::database::mc::GamesStripped(N)		"%s games stripped." ;# NEW
::application::database::mc::GamesRemoved(0)		"No game removed." ;# NEW
::application::database::mc::GamesRemoved(1)		"One game removed." ;# NEW
::application::database::mc::GamesRemoved(N)		"%s games removed." ;# NEW
::application::database::mc::AllGamesMustBeClosed	"All games must been closed before this operation can be done." ;# NEW
::application::database::mc::ReallyCompact		"Biztos össze akarja tömöríteni a(z) %s adatbázist?"
::application::database::mc::ReallyCompactDetail(1)	"Egyetlen játszma fog törlődni"  ;#"Only one game will be deleted."  ;#NEW
::application::database::mc::ReallyCompactDetail(N)	"%s játszmák fognak törlődni"  ;#"%s games will be deleted."  ;#NEW
::application::database::mc::RemoveSpace		"Some empty spaces will be removed." ;# NEW
::application::database::mc::CompactionRecommended	"It is recommended to compact the database." ;# NEW
::application::database::mc::SearchPGNTags		"Searching for PGN tags" ;# NEW
::application::database::mc::SelectSuperfluousTags	"Select superfluous tags:" ;# NEW
::application::database::mc::WillBePermanentlyDeleted	"Please note: This action will permanently delete the concerned information from database." ;# NEW
::application::database::mc::ReadWriteFailed		"Setting the database writable failed:" ;# NEW
::application::database::mc::NoExtraTagsFound		"No tags found for deletion." ;# NEW

::application::database::mc::T_Unspecific		"Nem specifikus"
::application::database::mc::T_Temporary		"Ideiglenes"
::application::database::mc::T_Work			"Munka"
::application::database::mc::T_Clipbase			"Vágólap"
::application::database::mc::T_MyGames			"Játszmáim"
::application::database::mc::T_Informant		"Informátor"
::application::database::mc::T_LargeDatabase		"Nagy adatbázis"
::application::database::mc::T_CorrespondenceChess	"Levelező sakk"  
::application::database::mc::T_EmailChess		"e-mail sakk"
::application::database::mc::T_InternetChess		"internet sakk"
::application::database::mc::T_ComputerChess		"számítógépes sakk"
::application::database::mc::T_Chess960			"Chess 960"
::application::database::mc::T_PlayerCollection		"Játékos adatlapok"
# Female version of "Player Collection"
# Be sure that the translation starts with same term as the translation above.
::application::database::mc::T_PlayerCollectionFemale	"Játékos gyűjtemény"
::application::database::mc::T_Tournament		"Verseny"
::application::database::mc::T_TournamentSwiss		"Svájci verseny"
::application::database::mc::T_GMGames			"GM Játszmák"
::application::database::mc::T_IMGames			"IM Játszmák"
::application::database::mc::T_BlitzGames		"Schnell játszmák"
::application::database::mc::T_Tactics			"Taktika"
::application::database::mc::T_Endgames			"Végjátékok"
::application::database::mc::T_Analysis			"Elemzések"
::application::database::mc::T_Training			"Edzések"
::application::database::mc::T_Match			"Match"
::application::database::mc::T_Studies			"Tanulmányok"
::application::database::mc::T_Jewels			"Gyöngyszemek"
::application::database::mc::T_Problems			"Problémák"
::application::database::mc::T_Patzer			"Patzer"
::application::database::mc::T_Gambit			"Gambit"
::application::database::mc::T_Important		"Important"
::application::database::mc::T_Openings			"Megnyitások"
::application::database::mc::T_OpeningsWhite		"Megnyitások világossal"
::application::database::mc::T_OpeningsBlack		"Megnyitások sötéttel"
::application::database::mc::T_Bughouse			"Tandem"
::application::database::mc::T_Antichess		"Francia sakk"
::application::database::mc::T_PGNFile			"PGN fájl"
::application::database::mc::T_ThreeCheck		"Three-check" ;# NEW
::application::database::mc::T_Crazyhouse		"Crazyhouse" ;# NEW

::application::database::mc::OpenDatabase		"Adatbázis megnyitása"
::application::database::mc::OpenRecentDatabase		"Open Recent Database" ;# NEW
::application::database::mc::NewDatabase		"Új adatbázis"
::application::database::mc::CloseDatabase		"Adatbázis bezárása: '%s'"
::application::database::mc::SetReadonly		"'%s' adatbázis módosítása írásvédette"
::application::database::mc::SetWriteable		"'%s' adatbázis módosítása írhatóvá"

::application::database::mc::OpenReadonly		"Megynitás olvasásra"
::application::database::mc::OpenWriteable		"Megnyitás írásra"

::application::database::mc::UpgradeDatabase		"%s egy régi formátum ami nem nyitható meg írásra.\n\nÚj formátumra kell konvertálni, hogy írható legyen.\n\nEz eltarthat egy kis ideig.\n\nÁt akarod konvertálni az adatbázist?"
::application::database::mc::UpgradeDatabaseDetail	"\"Nem\" olvasásra niytja meg az adatbázist."

::application::database::mc::MoveInfo(evaluation)	"Evaluation" ;# NEW
::application::database::mc::MoveInfo(playersClock)	"Players Clock" ;# NEW
::application::database::mc::MoveInfo(elapsedGameTime)	"Elapsed Game Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMoveTime)	"Elapsed Move Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMilliSecs)	"Elapsed Milliseconds" ;# NEW
::application::database::mc::MoveInfo(clockTime)	"Clock Time" ;# NEW
::application::database::mc::MoveInfo(corrChessSent)	"Correspondence Chess Sent" ;# NEW
::application::database::mc::MoveInfo(videoTime)	"Video Time" ;# NEW

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
::application::pgn::mc::Command(variation:remove:n)	"Delete Variations" ;# NEW
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
::application::pgn::mc::Command(game:merge)				"Merge Game" ;# NEW
::application::pgn::mc::Command(game:transpose)			"Transpose Game"

::application::pgn::mc::StartTrialMode						"Start Trial Mode"
::application::pgn::mc::StopTrialMode						"Stop Trial Mode"
::application::pgn::mc::Strip							"Törlés"
::application::pgn::mc::InsertDiagram						"Diagram beillesztése"
::application::pgn::mc::InsertDiagramFromBlack			"Diagram beillesztése sötét nézőpontjából"
::application::pgn::mc::SuffixCommentaries				"Lépés utáni szimbólumok"
::application::pgn::mc::StripOriginalComments			"Eredeti megjegyzések törlése"

::application::pgn::mc::LanguageSelection				"Nyelvek" ;# NEW change to "Language Selection"
::application::pgn::mc::MoveInfoSelection				"Move Info Selection" ;# NEW
::application::pgn::mc::MoveNotation					"Lépésjegyzés"
::application::pgn::mc::CollapseVariations				"Változatok elrejtése"
::application::pgn::mc::ExpandVariations					"Változatok kibontása"
::application::pgn::mc::EmptyGame							"Üres játszma"

::application::pgn::mc::NumberOfMoves						"(fél)lépésszám (a főváltozatban):"
::application::pgn::mc::InvalidInput						"Érvénytelen input '%d'."
::application::pgn::mc::MustBeEven						"Inputnak páros számnak kell lennie."
::application::pgn::mc::MustBeOdd							"Inputnak páratlan számnak kell lennie."
::application::pgn::mc::CannotOpenCursorFiles			"Cannot open cursor files: %s" ;# NEW
::application::pgn::mc::ReallyReplaceMoves			"Tényleg felül akarja írni az aktuális játszma lépéseit?"
::application::pgn::mc::CurrentGameIsNotModified		"Az aktuális játszma nem lett módosítva"
::application::pgn::mc::ShufflePosition				"Pozíció keverése..."

::application::pgn::mc::EditAnnotation						"Értékelés szerkesztése"
::application::pgn::mc::EditMoveInformation				"Lépés információ szerkesztése"
::application::pgn::mc::EditCommentBefore					"Megjegyzés (lépés előtt)"
::application::pgn::mc::EditCommentAfter					"Megjegyzés (lépés után)"
::application::pgn::mc::EditPrecedingComment				"Legutóbbi megjegyzés szerkesztése"
::application::pgn::mc::EditTrailingComment				"Záró megjegyzés szerkesztése"
::application::pgn::mc::EditMarks							"Jelek szerkesztése (?Edit marks)"
::application::pgn::mc::Display								"Megjelenítés"
::application::pgn::mc::None									"none"

::application::pgn::mc::MoveInfo(eval)					"Evaluation" ;# NEW
::application::pgn::mc::MoveInfo(clk)					"Players Clock" ;# NEW
::application::pgn::mc::MoveInfo(emt)					"Elapsed Time" ;# NEW
::application::pgn::mc::MoveInfo(ccsnt)					"Correspondence Chess Sent" ;# NEW
::application::pgn::mc::MoveInfo(video)					"Video Time" ;# NEW

### application::tree ##################################################
::application::tree::mc::Total				"Teljes"
::application::tree::mc::Control			"Vezérlés"
::application::tree::mc::ChooseReferenceBase		"Válassz referencia adatbázist"
::application::tree::mc::ReferenceBaseSwitcher		"Referencia adatbázis váltó"
::application::tree::mc::Numeric			"Numerikus"
::application::tree::mc::Bar				"Bar"
::application::tree::mc::StartSearch			"Keresés indítása"
::application::tree::mc::StopSearch			"Keresés leállítása"
::application::tree::mc::UseExactMode			"Pozíció keresése"
::application::tree::mc::UseFastMode			"Gyorsított keresés"
::application::tree::mc::UseQuickMode			"Gyors keresés"
::application::tree::mc::AutomaticSearch		"Automatikus keresés"
::application::tree::mc::LockReferenceBase		"Referencia adatbázis zárolása"
::application::tree::mc::SwitchReferenceBase		"Referencia adatbázis váltás"
::application::tree::mc::TransparentBar			"Transparent bar"
::application::tree::mc::NoGamesFound			"Nem található játszma"
::application::tree::mc::NoGamesAvailable		"Nincs elérhető játszma"
::application::tree::mc::Searching			"Keresés"
::application::tree::mc::VariantsNotYetSupported	"Chess variants not yet supported." ;# NEW
::application::tree::mc::End				"end" ;# NEW

::application::tree::mc::FromWhitesPerspective		"Világos nézőpontjából"
::application::tree::mc::FromBlacksPerspective		"Sötét nézőpontjából"
::application::tree::mc::FromSideToMovePerspective	"A lépésre következő játékos nézőpontjából"
::application::tree::mc::FromWhitesPerspectiveTip	"Világos nézőpontjából"
::application::tree::mc::FromBlacksPerspectiveTip	"Sötét nézőpontjából"
::application::tree::mc::EmphasizeMoveOfGame		"Emphasize move of game" ;# NEW

::application::tree::mc::TooltipAverageRating		"Átlagos értékszám (%s)"
::application::tree::mc::TooltipBestRating		"Legjobb értékszám (%s)"

::application::tree::mc::F_Number			"#"
::application::tree::mc::F_Move				"Lépés"
::application::tree::mc::F_Eco				"ECO"
::application::tree::mc::F_Frequency			"Gyakoriság"
::application::tree::mc::F_Ratio			"Arány"
::application::tree::mc::F_Score			"Pont"
::application::tree::mc::F_Draws			"Döntetlenek"
::application::tree::mc::F_Performance			"Teljesítmény"
::application::tree::mc::F_AverageYear			"\u00f8 Év"
::application::tree::mc::F_LastYear			"Utoljára játszva"
::application::tree::mc::F_BestPlayer			"Legjobb játékos"
::application::tree::mc::F_FrequentPlayer		"Gyakori játékos"

::application::tree::mc::T_Number			"Számozás"
::application::tree::mc::T_AverageYear			"Átlag év"
::application::tree::mc::T_FrequentPlayer		"Leggyakoribb játékos"

### database::switcher #################################################
::database::switcher::mc::Empty				"üres"
::database::switcher::mc::None				"nincs"
::database::switcher::mc::Failed			"meghiúsult"

::database::switcher::mc::UriRejectedDetail(open)	"Csak Scidb adabázisok nyithatóak meg:"
::database::switcher::mc::UriRejectedDetail(import)	"Only Scidb databases, but no ChessBase databases, can be imported:" ;# NEW
::database::switcher::mc::EmptyUriList			"Drop content is empty." ;# NEW
::database::switcher::mc::CopyGames			"Játszmák másolása"
::database::switcher::mc::CopyGamesFromTo		"Játszmák másolása '%src'-ból/-ből '%dst'-ba/-be"
::database::switcher::mc::CopiedGames			"%s játszmák átmásolva"
::database::switcher::mc::NoGamesCopied			"No games copied"
::database::switcher::mc::CopyGamesFrom			"Játszmák másolása '%s'-ból/-ből"
::database::switcher::mc::ImportGames			"Játszmák importálása"
::database::switcher::mc::ImportFiles			"Fájlok importálása:"

::database::switcher::mc::ImportOneGameTo(0)		"Egyetlen játszma másolása '%dst'-be/-ba?"
::database::switcher::mc::ImportOneGameTo(1)		"Copy about one game to '%dst'?" ;# NEW
::database::switcher::mc::ImportGamesTo(0)		"%num játszmák másolása '%dst'-be/-ba?"
::database::switcher::mc::ImportGamesTo(1)		"Copy about %num games to '%dst'-be/-ba?"

::database::switcher::mc::NumGames(0)			"none" ;# NEW
::database::switcher::mc::NumGames(1)			"egy játszma"
::database::switcher::mc::NumGames(N)			"%s játszmák"

::database::switcher::mc::SelectGames(all)		"Összes játszma"
::database::switcher::mc::SelectGames(filter)		"Csak a szűrt játszmák"
::database::switcher::mc::SelectGames(all,variant)	"Only variant %s" ;# NEW
::database::switcher::mc::SelectGames(filter,variant)	"Only filtered games of variant %s" ;# NEW
::database::switcher::mc::SelectGames(complete)		"Teljes adatbázis"

::database::switcher::mc::GameCount			"Játszmák"
::database::switcher::mc::DatabasePath			"Adatbázis elérési útvonala"
::database::switcher::mc::DeletedGames			"Törölt játszmák"
::database::switcher::mc::ChangedGames			"Changed Games" ;# NEW
::database::switcher::mc::AddedGames			"Added Games" ;# NEW
::database::switcher::mc::Description			"Leírás"
::database::switcher::mc::Created			"Létrehozva"
::database::switcher::mc::LastModified			"Utoljára módosítva"
::database::switcher::mc::Encoding			"Kódolás"
::database::switcher::mc::YearRange			"Év tartomány" ;#?
::database::switcher::mc::RatingRange			"Értékszám tartomány"
::database::switcher::mc::Result			"Eredmény"
::database::switcher::mc::Score				"Pontszám"
::database::switcher::mc::Type				"Típus"
::database::switcher::mc::ReadOnly			"Csak olvasható"

### board ##############################################################
::board::mc::CannotReadFile		"Fájl '%s' nem olvasható"
::board::mc::CannotFindFile		"Fájl '%s' nem található"
::board::mc::FileWillBeIgnored		"'%s' figyelmen kívül hagyva (duplicate ID)" ;# ;# NEW
::board::mc::IsCorrupt			"'%s' hibás (ismeretlen %s style '%s')"
::board::mc::SquareStyleIsUndefined	"Mező stílus '%s' már nem létezik"
::board::mc::PieceStyleIsUndefined	"Figura stílus '%s' már nem létezik"
::board::mc::ThemeIsUndefined		"Tábla stílus(téma?) '%s' már nem létezik"

::board::mc::ThemeManagement		"Téma beállítások"
::board::mc::Setup			"Beállítás"

::board::mc::WorkingSet			"Working Set"

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
::board::options::mc::ShowMaterialBar		"Anyageloszlás háttércsík"
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

::board::options::mc::YouCannotReverse		"Ez a művelet nem viszafordítható. '%s'fájl fizikailag törlésre kerül."

::board::options::mc::CannotUsePieceWorkingSet "Nem hozható létre új téma a kiválasztott %s figura stílussal."
::board::options::mc::CannotUsePieceWorkingSet "Először el kell mentened az új figurastílust vagy egy másik figura stílust kell választanod."

::board::options::mc::CannotUseSquareWorkingSet "Nem hozható létre új téma a kiválasztott %s mező stílussal."
::board::options::mc::CannotUseSquareWorkingSet "Először el kell mentened az új mező stílust vagy egy másik mező stílust kell választanod."

### board::piece #######################################################
::board::piece::mc::Start						"Start"
::board::piece::mc::Stop						"Stop"
::board::piece::mc::HorzOffset				"Vízszintes eltolás"
::board::piece::mc::VertOffset				"Függőleges eltolás"
::board::piece::mc::Gradient					"Gradiens"
::board::piece::mc::Fill						"Kitöltés"
::board::piece::mc::Stroke						"Stroke"
::board::piece::mc::Contour					"Kontúr"
::board::piece::mc::WhiteShape				"Fehér alak"
::board::piece::mc::PieceSelection			"Figurák kiválasztása"
::board::piece::mc::BackgroundSelection	"Háttér kiválasztása"
::board::piece::mc::Zoom						"Nagyítás"
::board::piece::mc::Shadow						"Árnyék"
::board::piece::mc::Opacity					"Átlátszóság"
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

### pgn-setup ##########################################################
::pgn::setup::mc::Configure(editor)			"Szerkesztő testreszabása"
::pgn::setup::mc::Configure(browser)			"Szöveg kimenet testreszabása" ;# NEW "Customize Text Display"
::pgn::setup::mc::TakeOver(editor)			"A játszma böngésző beállításainak használata"
::pgn::setup::mc::TakeOver(browser)			"A játszma szerkesztő beállításainak használata"
::pgn::setup::mc::Pixel					"pixel"  ;#NEW
::pgn::setup::mc::Spaces				"távolságok"
::pgn::setup::mc::RevertSettings			"Változtatások elvetése"
::pgn::setup::mc::ResetSettings				"Eredeti beállítások visszaállítása"
::pgn::setup::mc::DiscardAllChanges			"Elvet minden változtatást?"
::pgn::setup::mc::ThreefoldRepetition			"Háromszori ismétlés"
::pgn::setup::mc::FiftyMoveRule				"50 lépéses szabály"

::pgn::setup::mc::Setup(Appearance)			"Megjelenítés"
::pgn::setup::mc::Setup(Layout)				"Layout"
::pgn::setup::mc::Setup(Diagrams)			"Diagrammok"
::pgn::setup::mc::Setup(MoveStyle)			"Lépés jegyzése"

::pgn::setup::mc::Setup(Fonts)				"Betűtípus"
::pgn::setup::mc::Setup(font-and-size)			"Betűtípus és méret"
::pgn::setup::mc::Setup(figurine-font)			"Figurális" ;# "(normal)"
::pgn::setup::mc::Setup(figurine-bold)			"Figurális (félkövér)"
::pgn::setup::mc::Setup(symbol-font)			"Szimbólumok"

::pgn::setup::mc::Setup(Colors)				"Színek"
::pgn::setup::mc::Setup(Highlighting)			"Kiemelés"
::pgn::setup::mc::Setup(start-position)			"Kiinduló állás"
::pgn::setup::mc::Setup(variations)			"Változatok"
::pgn::setup::mc::Setup(numbering)			"Számozás"
::pgn::setup::mc::Setup(brackets)			"Zárójelek"
::pgn::setup::mc::Setup(illegal-move)			"Szabálytalan lépés"
::pgn::setup::mc::Setup(comments)			"Megjegyzések"
::pgn::setup::mc::Setup(annotation)			"Annotation"  ;#NEW
::pgn::setup::mc::Setup(nagtext)			"NAG-Text"  ;#NEW
::pgn::setup::mc::Setup(marks)				"Marks"  ;#NEW
::pgn::setup::mc::Setup(move-info)			"Lépés információ"
::pgn::setup::mc::Setup(result)				"Eredmény"
::pgn::setup::mc::Setup(current-move)			"Előző lépés"
::pgn::setup::mc::Setup(next-moves)			"Következő lépés"
::pgn::setup::mc::Setup(empty-game)			"Üres játszma"

::pgn::setup::mc::Setup(Hovers)				"Hovers"  ;#NEW
::pgn::setup::mc::Setup(hover-move)			"Lépés"
::pgn::setup::mc::Setup(hover-comment)			"Kommentár"
::pgn::setup::mc::Setup(hover-move-info)		"Lépés információ"

::pgn::setup::mc::Section(ParLayout)			"Paragraph Layout" ;# NEW
::pgn::setup::mc::ParLayout(use-spacing)		"Bekezdés stílus"
::pgn::setup::mc::ParLayout(column-style)		"Oszlop stílus"
::pgn::setup::mc::ParLayout(tabstop-1)			"Behúzás világos lépésinek"
::pgn::setup::mc::ParLayout(tabstop-2)			"Behúzás sötét lépésinek"
::pgn::setup::mc::ParLayout(mainline-bold)		"Főváltozat félkövér betűkkel"

::pgn::setup::mc::Section(Variations)			"Változatok megjelenítése"
::pgn::setup::mc::Variations(width)			"Behúzás szélessége"
::pgn::setup::mc::Variations(level)			"Behúzás szintje"

::pgn::setup::mc::Section(Display)			"Megjelenítés"
::pgn::setup::mc::Display(numbering)			"Változatok számozása"
::pgn::setup::mc::Display(moveinfo)			"Lépés információ kijelzése"
::pgn::setup::mc::Display(nagtext)			"Show text for unusual NAG comments"  ;#NEW

::pgn::setup::mc::Section(Diagrams)			"Diagrammok"  ;#"Diagrams"
::pgn::setup::mc::Diagrams(show)			"Diagrammok mutatása"
# Note for translators: "Emoticons" can be simply translated to "Smileys"
::pgn::setup::mc::Emoticons(show)				"Detect Emoticons" ;# NEW
::pgn::setup::mc::Diagrams(square-size)			"Mező méret"
::pgn::setup::mc::Diagrams(indentation)			"Behúzás szélessége"

### engine #############################################################
::engine::mc::Information		"Információ"
::engine::mc::Features			"Leírás"
::engine::mc::Options			"Beállítások"

::engine::mc::Name			"Név"
::engine::mc::Identifier		"Azonosító"
::engine::mc::Author			"Szerző"
::engine::mc::Webpage			"Honlap"
::engine::mc::Email			"Email"
::engine::mc::Country			"Ország"
::engine::mc::Rating			"Értékszám"
::engine::mc::Logo			"Logo"  ;#NEW
::engine::mc::Protocol			"Protokol"
::engine::mc::Parameters		"Paraméterek"
::engine::mc::Command			"Parancs"
::engine::mc::Directory			"Könyvtár"
::engine::mc::Variants			"Sakkváltozatok"
::engine::mc::LastUsed			"Utoljára használt"

::engine::mc::Variant(standard)		"Hagyományos"
::engine::mc::Variant(chess960)		"Fischer-sakk"
::engine::mc::Variant(bughouse)		"Tandem"
::engine::mc::Variant(crazyhouse)	"Crazyhouse"  ;#NEW
# NOTE: Suicide is Antichess according to FICS rules
# NOTE: "Giveaway" is Antichess according to internatianal rules.
# NOTE: "Losers" is Antichess according to ICC rules
# NOTE: You may translate "Suicide", "Giveaway", anmd "Losers" with the same term.
::engine::mc::Variant(suicide)		"Franciasakk"
::engine::mc::Variant(giveaway)		"Franciasakk"
::engine::mc::Variant(losers)		"Franciasakk"
::engine::mc::Variant(3check)		"Three-check"  ;#NEW

::engine::mc::Edit			"Szerkesztés"
::engine::mc::View			"Nézet"
::engine::mc::New			"Új"
::engine::mc::Rename			"Átnevezés"
::engine::mc::Delete			"Törlés"
::engine::mc::Select(engine)		"Elemző modul választása"
::engine::mc::Select(profile)		"Profil választása"
::engine::mc::ProfileName		"Profilnév"
::engine::mc::NewProfileName		"Új profilnév"
::engine::mc::OldProfileName		"Régi? profilnév"
::engine::mc::CopyFrom			"Másolás innen"
::engine::mc::NewProfile		"Új profil"
::engine::mc::RenameProfile		"Profil átnevezése"
::engine::mc::EditProfile		"%s profil szerkesztése"
::engine::mc::ProfileAlreadyExists	"'%s' profilnév már létezik"
::engine::mc::ChooseDifferentName	"Kérem válasszon más nevet."
::engine::mc::ReservedName		"'%s' fenntartott név ezért nem használható"
::engine::mc::ReallyDeleteProfile	"Biztos törli a '%s' profilt?"
::engine::mc::SortName			"Név szerinti rendezés"
::engine::mc::SortElo			"ELO szerinti rendezés"
::engine::mc::SortRating		"Sort by CCRL rating" ;# NEW
::engine::mc::OpenUrl			"Link megnyitása böngészőben"

::engine::mc::AdminEngines		"Elemző modulok kezelése"
::engine::mc::SetupEngine		"%s modul beállításai"
::engine::mc::ImageFiles		"Képfájlok"
::engine::mc::SelectEngine		"Elemzőmodul választása"
::engine::mc::SelectEngineLogo		"Logó választása az elemző modul számára"
::engine::mc::EngineDictionary		"Engine Dictionary" ;# NEW
::engine::mc::EngineFilter		"Elemző modul szűrő"
::engine::mc::EngineLog			"Elemző modul terminál"
::engine::mc::Probing			"Probing"  ;#NEW
::engine::mc::NeverUsed			"Sohasem használt"
::engine::mc::OpenFsbox			"Fájl kiválasztás dialógus megnyitása"
::engine::mc::ResetToDefault		"Alapértelmezett értékek visszaállítása"
::engine::mc::ShowInfo			"\"Info\" mutatása"  ;# don't translate "Info"
::engine::mc::TotalUsage		"összesen %s-szer"
::engine::mc::Memory			"Memória (MB)"
::engine::mc::CPUs			"Processzorok"
::engine::mc::Priority			"Processzor prioritás"
::engine::mc::ClearHash			"Hash tábla törlése"

::engine::mc::ConfirmNewEngine		"Új elemző modul megerősítése (?)"
::engine::mc::EngineAlreadyExists	"Már létezik ezen elemzőmodulhoz tartozó bejegyzés"
::engine::mc::CopyFromEngine		"Bejegyzés másolása"
::engine::mc::CannotOpenProcess		"Folyamat nem indítható."
::engine::mc::DoesNotRespond		"Ez az elemzőmodul nem reagál sem az UCI sem az XBoard/WinBoard protokolra"
::engine::mc::DiscardChanges		"The current item has changed.\n\nReally discard changes?"
::engine::mc::ReallyDelete		"Tényleg törli a(z) '%s' elemzőmodult?"
::engine::mc::EntryAlreadyExists	"Már létezik egy '%s' nevű bejegyzés."
::engine::mc::NoFeaturesAvailable	"This engine does not provide any feature, not even an analyze mode is available. You cannot use this engine for the analysis of positions." ;# NEW
::engine::mc::NoStandardChess		"Ez a modul nem támogatja a hagyományos sakkot."
::engine::mc::NoEngineAvailable		"Nincs elérhető elemző modul."
::engine::mc::FailedToCreateDir		"'%s' könyvtár létrehozása meghiúsult."
::engine::mc::ScriptErrors		"Any errors while saving will be displayed here." ;# NEW
::engine::mc::CommandNotAllowed		"A(z) '%s' utasítás itt nem használható."
::engine::mc::ThrowAwayChanges		"Az összes változtatás elvetése?"
::engine::mc::ResetToDefaultContent	"Alapbeállítások visszaállítása"

::engine::mc::ProbeError(registration)		"Ez a modul előzetes regosztrációt igényel."
::engine::mc::ProbeError(copyprotection)	"Ez a modul másolás-védett."

::engine::mc::FeatureDetail(analyze)		"This engine provides an analyze mode." ;# NEW
::engine::mc::FeatureDetail(multiPV)		"Allows you to see the engine evaluations and principal variations (PVs) from the highest ranked candidate moves. This engines can show up to %s principal variations." ;# NEW
::engine::mc::FeatureDetail(pause)		"This provides a proper handling of pause/resume: the engine does not think, ponder, or otherwise consume significant CPU time. The current thinking or pondering (if any) is suspended and both player's clocks are stopped." ;# NEW
::engine::mc::FeatureDetail(playOther)		"The engine is capable to play your move. Your clock wiil run while the engine is thinking about your move." ;# NEW
::engine::mc::FeatureDetail(hashSize)		"This feature allows to inform the engine on how much memory it is allowed to use maximally for the hash tables. This engine allows a range between %min and %max MB." ;# NEW
::engine::mc::FeatureDetail(clearHash)		"The user may clear the hash tables whlle the engine is running." ;# NEW
::engine::mc::FeatureDetail(threads)		"It allows you to configure the number of threads the chess engine will use during its thinking. This engine is using between %min and %max threads." ;# NEW
::engine::mc::FeatureDetail(smp)		"More than one CPU (core) can be used by this engine." ;# NEW
::engine::mc::FeatureDetail(limitStrength)	"The engine is able to limit its strength to a specific Elo number between %min-%max." ;# NEW
::engine::mc::FeatureDetail(skillLevel)		"The engine provides the possibility to lower the skill down, where it can be beaten quite easier." ;# NEW
::engine::mc::FeatureDetail(ponder)		"Pondering is simply using the user's move time to consider likely user moves and thus gain a pre-processing advantage when it is our turn to move, also referred as Permanent brain." ;# NEW
::engine::mc::FeatureDetail(chess960)		"Chess960 (or Fischer Random Chess) is a variant of chess. The game employs the same board and pieces as standard chess, but the starting position of the pieces along the players' home ranks is randomized, with a few restrictions which preserves full castling options in all starting positions, resulting in 960 unique positions." ;# NEW
::engine::mc::FeatureDetail(bughouse)		"Bughouse chess (also called Exchange chess, Siamese chess, Tandem chess, Transfer chess, or Double Bughouse) is a chess variant played on two chessboards by four players in teams of two. Normal chess rules apply, except that captured pieces on one board are passed on to the players of the other board, who then have the option of putting these pieces on their board." ;# NEW
::engine::mc::FeatureDetail(crazyhouse)		"Crazyhouse (also known as Drop Chess) is a chess variant similar to bughouse chess, but with only two players. It effectively incorporates a rule in shogi (Japanese chess), in which a player can introduce a captured piece back to the board as his own." ;# NEW
::engine::mc::FeatureDetail(suicide)		"Suicide Chess (also called Antichess, Take Me Chess, Must Kill, Reverse Chess) has simple rules: capturing moves are mandatory and the object is to lose all pieces. There is no check, the king is captured like an ordinary piece. In case of stalemate the side with fewer pieces will win (according to FICS rules)." ;# NEW
::engine::mc::FeatureDetail(giveaway)		"Giveaway Chess (a variant of Antichess) is like Suicide Chess, but in case of stalemate the side which is stalemate wins (according to international rules)." ;# NEW
::engine::mc::FeatureDetail(losers)		"Losing Chess is a variant of Antichess, where the goal is to lose the chess game, but with several conditions attached to the rules. The goal is to lose all of your pieces (except the king), although in Losers Chess, you can also win by getting checkmated (according to ICC rules)." ;# NEW
::engine::mc::FeatureDetail(3check)		"The characteristic of this chess variant: a player wins if he checks his opponent three times." ;# NEW
::engine::mc::FeatureDetail(playingStyle)	"This engine provides different playing styles, namely %s. See the handbook of the engine for an explanation of the different styles." ;# NEW

### analysis ###########################################################
::application::analysis::mc::Control			"Control" ;# NEW
::application::analysis::mc::Information		"Information" ;# NEW
::application::analysis::mc::Setup			"Setup" ;# NEW
::application::analysis::mc::Pause			"Pause" ;# NEW
::application::analysis::mc::Resume			"Resume" ;# NEW
::application::analysis::mc::LockEngine			"Lock engine to current position" ;# NEW
::application::analysis::mc::MultipleVariations		"Multiple variations (multi-pv)" ;# NEW
::application::analysis::mc::HashFullness		"Hash fullness" ;# NEW
::application::analysis::mc::Hash			"Hash:" ;# NEW
::application::analysis::mc::Lines			"Lines:" ;# NEW
::application::analysis::mc::MateIn			"%color mate in %n" ;# NEW
::application::analysis::mc::BestScore			"Best score (of current lines)" ;# NEW
::application::analysis::mc::CurrentMove		"Currently searching this move" ;# NEW
::application::analysis::mc::TimeSearched		"Time searched" ;# NEW
::application::analysis::mc::SearchDepth		"Search depth in plies (Selective search depth)" ;# NEW
::application::analysis::mc::IllegalPosition		"Illegal position - Cannot analyze" ;# NEW
::application::analysis::mc::IllegalMoves		"Illegal moves in game - Cannot analyze" ;# NEW
::application::analysis::mc::DidNotReceivePong		"Engine is not responding to \"ping\" command - Engine aborted" ;# NEW
::application::analysis::mc::SearchMateNotSupported	"This engine is not supporting search for mate." ;# NEW
::application::analysis::mc::Stopped			"stopped" ;# NEW

::application::analysis::mc::LinesPerVariation		"Lines per variation" ;# NEW
::application::analysis::mc::BestFirstOrder		"Sort by evaluation" ;# NEW
::application::analysis::mc::Engine			"Engine" ;# NEW

# Note for translators: don't use more than 4 characters
::application::analysis::mc::Ply			"ply" ;# NEW
::application::analysis::mc::Seconds			"sec" ;# NEW
::application::analysis::mc::Minutes			"min" ;# NEW

::application::analysis::mc::Status(checkmate)		"%s is checkmate" ;# NEW
::application::analysis::mc::Status(stalemate)		"%s is stalemate" ;# NEW
::application::analysis::mc::Status(threechecks)	"%s got three checks" ;# NEW
::application::analysis::mc::Status(losing)		"%s lost all pieces" ;# NEW

::application::analysis::mc::NotSupported(standard)	"This engine does not support standard chess." ;# NEW
::application::analysis::mc::NotSupported(chess960)	"This engine does not support chess 960." ;# NEW
::application::analysis::mc::NotSupported(variant)	"This engine does not support variant '%s'." ;# NEW
::application::analysis::mc::NotSupported(analyze)	"This engine does not have an analysis mode." ;# NEW

::application::analysis::mc::Signal(stopped)		"Engine stopped by signal." ;# NEW
::application::analysis::mc::Signal(resumed)		"Engine resumed by signal." ;# NEW
::application::analysis::mc::Signal(killed)		"Engine crashed or killed by signal." ;# NEW
::application::analysis::mc::Signal(crashed)		"Engine crashed." ;# NEW
::application::analysis::mc::Signal(closed)		"Engine has closed connection." ;# NEW
::application::analysis::mc::Signal(terminated)		"Engine terminated with exit code %s." ;# NEW

::application::analysis::mc::Add(move)			"Add move" ;# NEW
::application::analysis::mc::Add(var)			"Add move as new variation" ;# NEW
::application::analysis::mc::Add(line)			"Add variation" ;# NEW
::application::analysis::mc::Add(all)			"Add all variations" ;# NEW

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
::gametable::mc::SortOnNumber			"Sort on game number (ascending)"
::gametable::mc::ReverseOrder			"Sorrend megfordítása"
::gametable::mc::CancelSort			"Cancel sort" ;# NEW
::gametable::mc::NoMoves				"No moves"
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
::gametable::mc::T_Changed					"Changed"
::gametable::mc::T_Added					"Added" ;# NEW
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
::playertable::mc::F_LastName			"Családnév"
::playertable::mc::F_FirstName			"Keresztnév"
::playertable::mc::F_FideID			"Fide azonosító"
::playertable::mc::F_DSBID			"DSB ID" ;# NEW
::playertable::mc::F_ECFID			"ECF ID" ;# NEW
::playertable::mc::F_ICCFID			"ICCF ID" ;# NEW
::playertable::mc::F_Title			"Cím"
::playertable::mc::F_Frequency			"Gyakorisg"

::playertable::mc::T_Federation			"Szövetség"
::playertable::mc::T_NativeCountry		"Native Country" ;# NEW
::playertable::mc::T_RatingType			"Rating Type"
::playertable::mc::T_Type			"Típus"
::playertable::mc::T_Sex			"Neme"
::playertable::mc::T_PlayerInfo			"Info Flag"

::playertable::mc::Find				"Keresés"
::playertable::mc::Options			"Options" ;# NEW
::playertable::mc::StartSearch			"Keresés indítása"
::playertable::mc::ClearEntries			"Bejegyzések törlése"
::playertable::mc::NotFound			"Nem található."
::playertable::mc::UsePlayerBase		"Use Player Base" ;# NEW

::playertable::mc::Name				"Név"
::playertable::mc::HighestRating		"Legmagasabb ELO pontszám"
::playertable::mc::MostRecentRating		"Legutolsó ELO pontszám"
::playertable::mc::DateOfBirth			"Születési dátum"
::playertable::mc::DateOfDeath			"Elhalálozás dátuma"

::playertable::mc::ShowPlayerCard		"Show Player Card..." ;# NEW

### eventtable #########################################################
::eventtable::mc::Attendance	"Attendance" ;# NEW

### player dictionary ##################################################
::playerdict::mc::PlayerDictionary	"Player Dictionary" ;# NEW
::playerdict::mc::PlayerFilter		"Player Filter" ;# NEW
::playerdict::mc::Count			"Count" ;# NEW
::playerdict::mc::Ignore		"Ignore" ;# NEW
::playerdict::mc::FederationID		"Federation ID" ;# NEW
::playerdict::mc::BirthYear		"Birth Year" ;# NEW
::playerdict::mc::DeathYear		"Death Year" ;# NEW
::playerdict::mc::Ratings		"Ratings" ;# NEW
::playerdict::mc::Titles		"Titles" ;# NEW
::playerdict::mc::None			"None" ;# NEW
::playerdict::mc::Operation		"Operation" ;# NEW

### player-card ########################################################
::playercard::mc::PlayerCard		"Player Card" ;# NEW
::playercard::mc::Latest		"Latest" ;# NEW
::playercard::mc::Highest		"Highest" ;# NEW
::playercard::mc::Minimal		"Minimal" ;# NEW
::playercard::mc::Maximal		"Maximal" ;# NEW
::playercard::mc::Win			"Win" ;# NEW
::playercard::mc::Draw			"Draw" ;# NEW
::playercard::mc::Loss			"Loss" ;# NEW
::playercard::mc::Total			"Total" ;# NEW
::playercard::mc::FirstGamePlayed	"First game played" ;# NEW
::playercard::mc::LastGamePlayed	"Last game played" ;# NEW
::playercard::mc::WhiteMostPlayed	"Most common openings as White" ;# NEW
::playercard::mc::BlackMostPlayed	"Most common openings as Black" ;# NEW

::playercard::mc::OpenInWebBrowser	"Mgnyitás böngészőben"
::playercard::mc::OpenPlayerCard	"%s játékos adatlapjának megynitása"
::playercard::mc::OpenFileCard		"%s fájl adatlapjának megnyitása"
::playercard::mc::OpenFideRatingHistory	"Fide értékszámának alakulása"
::playercard::mc::OpenWikipedia		"Wikipédia életrajz megnyitása"
::playercard::mc::OpenViafCatalog	"VIAF katalógus megnyitása"
::playercard::mc::OpenPndCatalog	"A Német Országos Könyvtár katalógusának megynitása"
::playercard::mc::OpenChessgames	"chessgames.com játszmagyűjtemény"
::playercard::mc::SeachIn365ChessCom	"Keresés a 365Chess.com -on"

### twm - tiled window manager #########################################
::twm::mc::Undock	"Undock" ;# NEW
::twm::mc::Close	"Bezár"

### fonts ##############################################################
::font::mc::ChessBaseFontsInstalled		"ChessBase fonts successfully installed." ;# NEW
::font::mc::ChessBaseFontsInstallationFailed	"Installation of ChessBase fonts failed." ;# NEW
::font::mc::NoChessBaseFontFound		"No ChessBase font found in folder '%s'." ;# NEW
::font::mc::ChessBaseFontsAlreadyInstalled	"ChessBase fonts already installed. Install anyway?" ;# NEW
::font::mc::ChooseMountPoint			"Mount point of Windows installation partition" ;# NEW
::font::mc::CopyingChessBaseFonts		"Copying ChessBase fonts" ;# NEW
::font::mc::CopyFile				"Copy file %s" ;# NEW
::font::mc::UpdateFontCache			"Updating font cache" ;# NEW

::font::mc::ChooseFigurineFont			"Choose figurine font" ;# NEW
::font::mc::ChooseSymbolFont			"Choose symbol font" ;# NEW
::font::mc::IncreaseFontSize			"Betűméret növelése"
::font::mc::DecreaseFontSize			"Betűméret csökkentése"

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
::gamebar::mc::EnterGameNumber			"Enter game number" ;# NEW

::gamebar::mc::CopyThisGameToClipbase		"Copy this game to Clipbase" ;# NEW
::gamebar::mc::CopyThisGameToClipboard		"Copy this game to Clipboard (PGN format)" ;# NEW
::gamebar::mc::ExportThisGame			"Export this game" ;# NEW
::gamebar::mc::PasteLastClipbaseGame		"Paste last Clipbase game" ;# NEW
::gamebar::mc::PasteGameFrom			"Paste game" ;# NEW
::gamebar::mc::LoadGameNumber			"Load game number" ;# NEW
::gamebar::mc::ReloadCurrentGame		"Re-load current game" ;# NEW
::gamebar::mc::OriginalVersion			"Original version from database" ;# NEW
::gamebar::mc::ModifiedVersion			"Modified version in game editor" ;# NEW
::gamebar::mc::WillCopyModifiedGame		"This operation will copy the modified game in editor. The original version cannot be copied because the associated database is not open." ;# NEW

::gamebar::mc::CopyGame				"Copy Game" ;# NEW
::gamebar::mc::ExportGame			"Export Game" ;# NEW
::gamebar::mc::LockGame				"Játszma zárolása"
::gamebar::mc::UnlockGame			"Zárolás feloldása"
::gamebar::mc::CloseGame			"Játszma bezárása"

::gamebar::mc::GameNew				"Új tábla"
::gamebar::mc::AddNewGame			"Mentés: új játszma hozzáadása %s-hez..."
::gamebar::mc::ReplaceGame			"Mentés: Játszma felülírása %s-ben..."
::gamebar::mc::ReplaceMoves			"Mentés: Replace Moves Only in Game..."

::gamebar::mc::Tip(Antichess)			"There is no check, no castling, the king\nis captured like an ordinary piece." ;# NEW
::gamebar::mc::Tip(Suicide)			"In case of stalemate the side with fewer\npieces will win (according to FICS rules)." ;# NEW
::gamebar::mc::Tip(Giveaway)			"In case of stalemate the side which is\nstalemate wins (according to international rules)." ;# NEW
::gamebar::mc::Tip(Losers)			"The king is like in normal chess, and you can also\nwin by getting checkmated or stalemated." ;# NEW

### merge ##############################################################
::merge::mc::MergeLastClipbaseGame		"Merge last Clipbase game" ;# NEW
::merge::mc::MergeGameFrom			"Merge game" ;# NEW

::merge::mc::MergeTitle				"Merge with games" ;# NEW
::merge::mc::StartFromCurrentPosition		"Start merge from current position" ;# NEW
::merge::mc::StartFromInitialPosition		"Start merge from initial position" ;# NEW
::merge::mc::NoTranspositions			"No transpositions" ;# NEW
::merge::mc::IncludeTranspositions		"Include transpositions" ;# NEW
::merge::mc::VariationDepth			"Variation depth" ;# NEW
::merge::mc::VariationLength			"Maximal variation length (plies)" ;# NEW
::merge::mc::UpdatePreview			"Update preview" ;# NEW
::merge::mc::SelectedGame			"Selected Game" ;# NEW
::merge::mc::SaveAs				"Save as new game" ;# NEW
::merge::mc::Save				"Merge into game" ;# NEW
::merge::mc::GameisLocked			"Game is locked by Merge-Dialog" ;# NEW

::merge::mc::AlreadyInUse			"Merge dialog is already in use with game #%d." ;# NEW
::merge::mc::AlreadyInUseDetail			"Please finish merge of this game before merging into another game. This means you have to switch to game #%d for continuing." ;# NEW
::merge::mc::CannotMerge			"Cannot merge games with different variants." ;# NEW

### validate ###########################################################
::validate::mc::Unlimited	"unlimited" ;# NEW

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
::browser::mc::LoadPrevGame		"Load previous game" ;# NEW
::browser::mc::LoadNextGame		"Load next game" ;# NEW

::browser::mc::GotoGame(first)		"Első játszmához"
::browser::mc::GotoGame(last)		"Utolsó játszmához"
::browser::mc::GotoGame(next)		"Goto next game" ;# NEW
::browser::mc::GotoGame(prev)		"Goto previous game" ;# NEW

::browser::mc::LoadGame			"Játszma betöltése into editor" ;# NEW
::browser::mc::ReloadGame		"Reload game" ;# NEW
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
::setup::mc::Position(Chess960)	"Chess 960 position"
::setup::mc::Position(Symm960)	"Symmetrical chess 960 position"
::setup::mc::Position(Shuffle)	"Shuffle chess position"

### setup board ########################################################
::setup::position::mc::SetStartPosition			"Kezdő pozíció beállítása"
::setup::position::mc::UsePreviousPosition		"Előző pozíció használata"

::setup::board::mc::SetStartBoard			"Kiinduló állás beállítása"
::setup::board::mc::SideToMove				"Lépésre következő fél"
::setup::board::mc::Castling				"Sáncolás"
::setup::board::mc::MoveNumber				"Lépésszám"
::setup::board::mc::EnPassantFile			"Menetközbeni ütés"
::setup::board::mc::HalfMoves				"Half move clock" ;# NEW
::setup::board::mc::StartPosition			"Kiinduló állás"
::setup::board::mc::Fen					"FEN"
::setup::board::mc::Promoted				"Promoted" ;# NEW
::setup::board::mc::Holding				"Holding" ;# NEW
::setup::board::mc::ChecksGiven				"Checks Given" ;# NEW
::setup::board::mc::Clear				"Törlés"
::setup::board::mc::CopyFen				"FEN másolása a vágólapra"
::setup::board::mc::Shuffle				"Keverés..."
::setup::board::mc::FICSPosition			"FICS Start Position..." ;# NEW
::setup::board::mc::StandardPosition			"Standard Position" ;# NEW
::setup::board::mc::Chess960Castling			"Chess 960 castling" ;# NEW
::setup::board::mc::InvalidFen				"Érvénytelen FEN"

::setup::board::mc::ChangeToFormat(xfen)		"Change to X-Fen format" ;# NEW
::setup::board::mc::ChangeToFormat(shredder)		"Change to Shredder format" ;# NEW

::setup::board::mc::Error(InvalidFen)			"Érvénytelen FEN."
::setup::board::mc::Error(EmptyBoard)			"Board is empty." ;# NEW
::setup::board::mc::Error(NoWhiteKing)			"Világos király hiányzik."
::setup::board::mc::Error(NoBlackKing)			"Sötét király hiányzik."
::setup::board::mc::Error(BothInCheck)			"Mindkét király sakkban áll."
::setup::board::mc::Error(OppositeCheck)		"A nem lépésre jövő fél királya sakkban áll."
::setup::board::mc::Error(OppositeLosing)		"Side not to move has no pieces." ;# NEW
::setup::board::mc::Error(TooManyWhitePawns)		"Túl sok világos gyalog."
::setup::board::mc::Error(TooManyBlackPawns)		"Túl sok sötét gyalog."
::setup::board::mc::Error(TooManyWhitePieces)		"Túl sok világos tiszt."
::setup::board::mc::Error(TooManyBlackPieces)		"Túl sok sötét tiszt."
::setup::board::mc::Error(PawnsOn18)			"Gyalog az 1. vagy a 8. soron."
::setup::board::mc::Error(TooManyKings)			"Több mint két király."
::setup::board::mc::Error(TooManyWhite)			"Túl sok világos figura."
::setup::board::mc::Error(TooManyBlack)			"Túl sok sötét figura."
::setup::board::mc::Error(BadCastlingRights)		"Hibás sáncolási jogok."
::setup::board::mc::Error(InvalidCastlingRights)	"Értelmetlen bástya vonal(ak) sáncoláshoz."
::setup::board::mc::Error(InvalidCastlingFile)		"Érvénytelen sáncolási vonal."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"Castling needs rook files to be disambiguous (possibly they are set wrong)."
::setup::board::mc::Error(TooManyPiecesInHolding)	"Too many pieces in holding." ;# NEW
::setup::board::mc::Error(TooManyPromotedPieces)	"Too many pieces marked as promoted." ;# NEW
::setup::board::mc::Error(TooFewPromotedPieces)		"Too few pieces marked as promoted." ;# NEW
::setup::board::mc::Error(InvalidEnPassant)		"Értelmetlen menetközbeni ütés vonal." ;#?
::setup::board::mc::Error(MultiPawnCheck)		"Kettő vagy több gyalog ad sakkot."
::setup::board::mc::Error(TripleCheck)			"Három vagy több figura ad sakkot."

::setup::board::mc::Warning(TooFewPiecesInHolding)	"Too few pieces marked as promoted. Are you sure that this is ok?" ;# NEW
::setup::board::mc::Warning(CastlingWithoutRook)	"You have set castling rights, but at least one rook for castling is missing. This can happen only in handicap games. Are you sure that the castling rights are ok?"
::setup::board::mc::Warning(UnsupportedVariant)		"Position is a start position but not a Shuffle Chess position. Are you sure?"

### import #############################################################
::import::mc::ImportingPgnFile			"'%s' PGN file importálása"
::import::mc::ImportingDatabase			"Importing database '%s'" ;# NEW
::import::mc::Line				"Sor"
::import::mc::Column				"Oszlop"
::import::mc::GameNumber			"Játszma"
::import::mc::ImportedGames			"játszma %s  betöltve"
::import::mc::NoGamesImported			"Nem került játszma importálásra"
::import::mc::FileIsEmpty			"A fájl valószínűleg üres"
::import::mc::DatabaseImport			"Adatbázis Importálás"
::import::mc::ImportPgnGame			"PGN játszma importálása"
::import::mc::ImportPgnVariation		"PGN Változat importálása"
::import::mc::ImportOK				"A PGN szöveg hiba és figyelmeztetés nélkül került betöltésre."
::import::mc::ImportAborted			"Importálás megszakítva."
::import::mc::TextIsEmpty			"PGN szöveg üres."
::import::mc::AbortImport			"Meg akarja szakítani a PGN importálást?"
::import::mc::UnsupportedVariantRejected	"Unsuported variant '%s' rejected" ;# NEW
::import::mc::Accepted				"accepted" ;# NEW
::import::mc::Rejected				"rejected" ;# NEW

::import::mc::DifferentEncoding			"A kiválasztott %src kódolás nem illeszkedik %dst fájl kódoláshoz."
::import::mc::DifferentEncodingDetails		"Az adatbázis kódolásának megváltoztatása ez után a művelet után már nem lesz lehetséges." ;#?
::import::mc::CannotDetectFigurineSet		"Nem sikerült felismerni egyetlen megfelelő bábukészletet sem."
::import::mc::TryAgainWithEnglishSet		"Try again with English figurines?" ;# NEW
::import::mc::TryAgainWithEnglishSetDetail	"It may be helpful to use English figurines, because this is standard in PGN format." ;# NEW
::import::mc::CheckImportResult			"Kérlek ellenőrizd, hogy a megfelelő bábukészlet lett-e felismerve: %s."
::import::mc::CheckImportResultDetail		"Néhány esetben előfordulhat, hogy kétértelmű bejegyzések miatt az automatikus felismerés nem sikeres."

::import::mc::EnterOrPaste			"Enter or paste a PGN-format %s in the frame above.\nAny errors importing the %s will be displayed here."
::import::mc::EnterOrPaste-Game			"játszma"
::import::mc::EnterOrPaste-Variation		"változat"

::import::mc::AbortedDueToInternalError		"Beslő hiba miatt Aborted"
::import::mc::AbortedDueToIoError		"Aborted due to an read/write error" ;# NEW
::import::mc::UserHasInterrupted		"User has interrupted" ;# NEW

::import::mc::State(UnsupportedVariant)		"Unsuported variant rejected" ;# NEW
::import::mc::State(DecodingFailed)		"Sikertelen dekódolás"
::import::mc::State(TooManyGames)		"Az adatbézis túl sok játszmát tartalmaz (aborted)"
::import::mc::State(GameTooLong)		"A játszma túl hosszú (átugorva)"
::import::mc::State(FileSizeExceeded)		"A legnagyobb kezelhető ájlméret (2GB) túllépésre került (aborted)"
::import::mc::State(TooManyPlayerNames)		"Túl sok játékos az adatbázisban (aborted)"
::import::mc::State(TooManyEventNames)		"Túl sok esemény az adatbázisban (aborted)"
::import::mc::State(TooManySiteNames)		"Túl sok helyzín az adatbázisban (aborted)"
::import::mc::State(TooManyRoundNames)		"Túl sok forduló az adatbázisban (aborted)"
::import::mc::State(TooManyAnnotatorNames)	"Túl sok elemző az adatbázisban (aborted)"
::import::mc::State(TooManySourceNames)		"Túl sok forrás az adatbázisban (aborted)"

::import::mc::Warning(MissingWhitePlayerTag)		"Hiányzó világos játékos"
::import::mc::Warning(MissingBlackPlayerTag)		"Hiányzó sötét játékos"
::import::mc::Warning(MissingPlayerTags)		"Hiányzó játékosok"
::import::mc::Warning(MissingResult)			"Hiányzó eredmény (at end of move section)"
::import::mc::Warning(MissingResultTag)			"Hiányzó eredmény (in tag section)"
::import::mc::Warning(InvalidRoundTag)			"Érvénytelen foduló cimke"
::import::mc::Warning(InvalidResultTag)			"Érvénytelen eredmény cimke"
::import::mc::Warning(InvalidDateTag)			"Érvénytelen dátum cimke"
::import::mc::Warning(InvalidEventDateTag)		"Érvénytelen esemény-dátum címke"
::import::mc::Warning(InvalidTimeModeTag)		"Érvénytelen időbosztás cimke"
::import::mc::Warning(InvalidEcoTag)			"Érvénytelen ECO cimke"
::import::mc::Warning(InvalidTagName)			"Érvénytelen cimke név (kihagyva)"
::import::mc::Warning(InvalidCountryCode)		"Érvénytelen országkód"
::import::mc::Warning(InvalidRating)			"Érvénytelen értékszám"
::import::mc::Warning(InvalidNag)			"Érvénytelen NAG"
::import::mc::Warning(BraceSeenOutsideComment)		"\"\}\" seen outside a comment in game (ignored)"
::import::mc::Warning(MissingFen)			"No start position for this Shuffle/Chess-960 game; will be interpreted as standard chess" ;# NEW
::import::mc::Warning(UnknownEventType)			"Ismeretlen verseny típus"
::import::mc::Warning(UnknownTitle)			"Ismeretlen cím (kihagyva)"
::import::mc::Warning(UnknownPlayerType)		"Ismeretlen játkos típus (kihagyva)"
::import::mc::Warning(UnknownSex)			"Ismeretlen nem (kihagyva)"
::import::mc::Warning(UnknownTermination)		"Ismeretlen megszakítási ok"
::import::mc::Warning(UnknownMode)			"Ismeretlen mód"
::import::mc::Warning(RatingTooHigh)			"Túl magas érétkszám (kihagyva))"
::import::mc::Warning(EncodingFailed)			"Character decoding failed"
::import::mc::Warning(TooManyNags)			"Túl sok NAG (a későbbiek kihagyva)"
::import::mc::Warning(IllegalCastling)			"Szabálytalan sáncolás"
::import::mc::Warning(IllegalMove)			"Szabálytalan lépés"
::import::mc::Warning(CastlingCorrection)		"Castling correction" ;# NEW
::import::mc::Warning(ResultDidNotMatchHeaderResult)	"Az eredmény nem egyezik meg a fejlécben megadott eredménnyel"
::import::mc::Warning(ValueTooLong)			"A cimke értéke túl hosszú és 255 karakterre csonkolódik"
::import::mc::Warning(NotSuicideNotGiveaway)		"Due to the outcome of the game the variant isn't either Suicide or Giveaway." ;# NEW
::import::mc::Warning(VariantChangedToGiveaway)		"Due to the outcome of the game the variant has been changed to Giveaway" ;# NEW
::import::mc::Warning(VariantChangedToSuicide)		"Due to the outcome of the game the variant has been changed to Suicide" ;# NEW
::import::mc::Warning(ResultCorrection)			"Due to the final position of the game a correction of the result has been done" ;# NEW
::import::mc::Warning(MaximalErrorCountExceeded)	"A maximális hibaszám túllépve; több hiba (az előző hibatípusból) nem lesz közölve"
::import::mc::Warning(MaximalWarningCountExceeded)	"A maximális figyelmeztetés-szám túllépve; több figyelmeztetés (az előző figyelmeztetés-típusból) nem lesz közölve"

::import::mc::Error(InvalidToken)			"Érvénytelen token"
::import::mc::Error(InvalidMove)			"Érvénytelen lépés"
::import::mc::Error(UnexpectedSymbol)			"Váratlan szimbólum"
::import::mc::Error(UnexpectedEndOfInput)		"A bement váratlanul véget ért" ;# ? Unexpected end of input"
::import::mc::Error(UnexpectedResultToken)		"Váratlan eredmény token"
::import::mc::Error(UnexpectedTag)			"Váratlan cimke a játszmában"
::import::mc::Error(UnexpectedEndOfGame)		"A játszma váratlanul véget ért (hiényzó eredmény)"
::import::mc::Error(UnexpectedCastling)			"Unexpected castling (not allowed in this chess variant)" ;# NEW
::import::mc::Error(ContinuationsNotSupported)		"'Continuations' not supported" ;# NEW
::import::mc::Error(TagNameExpected)			"Szintaktikai hiba: meg kell adni a cimke nevét"
::import::mc::Error(TagValueExpected)			"Szintaktikai hiba: meg kell adni a cimke értékét"
::import::mc::Error(InvalidFen)				"Érvénytelen FEN"
::import::mc::Error(UnterminatedString)			"Befejezetlen string"
::import::mc::Error(UnterminatedVariation)		"Befejezetlen változat"
::import::mc::Error(SeemsNotToBePgnText)		"Nem tűnik PGN szövegnek"

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
::export::mc::ExportDatabaseVariant		"Export database - variant %s" ;# NEW
::export::mc::ExportDatabaseTitle		"'%s' adatbézis exportálása"
::export::mc::ExportCurrentGameTitle		"Export Current Game" ;# NEW
::export::mc::ExportingDatabase			"'%s' exportálása '%s'fájlba"
::export::mc::Export				"Exportálás"
::export::mc::NoGamesCopied			"No games exported." ;# NEW
::export::mc::ExportedGames			"%s játszmá(k) exportálva"
::export::mc::NoGamesForExport			"Nincs kiválasztva exportálható játszma."
::export::mc::ResetDefaults			"Alapbeállítások visszaállítása"
::export::mc::UnsupportedEncoding		"%s kódolás nem használható PDF documentumokhoz. Kérem válaszzon másik kódolást."
::export::mc::DatabaseIsOpen			"The destination database '%s' is open, this means that the destination database will be emptied before the export is starting. Export anyway?" ;# NEW
::export::mc::DatabaseIsOpenDetail		"If you want to append instead you should use a Drag&Drop operation inside the database switcher." ;# NEW
::export::mc::ExportGamesFromTo			"Export games from '%src' to '%dst'" ;# NEW
::export::mc::IllegalRejected			"%s game(s) rejected due to illegal moves" ;# NEW

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
::export::mc::Option(pgn,use_strict_pgn_standard	"Use PGN standard" ;# NEW
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
::export::mc::Option(pgn,write_any_rating_as_elo)	"Write any rating as ELO" ;# NEW
::export::mc::Option(pgn,append_mode_to_event_type)	"Add mode after event type"
::export::mc::Option(pgn,comment_to_html)		"Megjegyzés írása HTML stílusban"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Érvénytelen lépést tartalmazó játszmák elvetése"
::export::mc::Option(pgn,use_utf8_encoding)		"Use UTF-8 encoding" ;# NEW

### notation ###########################################################
::notation::mc::Notation	"Játszmajegyzés"

::notation::mc::MoveForm(alg)	"Algebria"
::notation::mc::MoveForm(san)	"Rövidített algebrai"
::notation::mc::MoveForm(lan)	"Teljes algebrai"
::notation::mc::MoveForm(eng)	"Angol"
::notation::mc::MoveForm(cor)	"Levelezési"
::notation::mc::MoveForm(tel)	"Távirati"

### figurine ###########################################################
::figurines::mc::Figurines	"Figurális"
::figurines::mc::Graphic	"Grafikus"
::figurines::mc::User		"User"  ;#NEW meaning is "user defined"

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
::dialog::save::mc::LeaveTrialModeHint		"You have to leave trial mode beforehand, use shortcut %s." ;# NEW
::dialog::save::mc::OpenPlayerDictionary	"Open Player Dictionary" ;# NEW

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
::game::mc::VariantHasChanged		"Game cannot be opened because the variant of the database has changed and is now different from the game variant." ;# NEW
::game::mc::RemoveGameFromHistory	"Remove game from history?" ;# NEW
::game::mc::GameNumberDoesNotExist	"Game %number does not exist in '%base'."
::game::mc::ReallyReplaceGame		"It seems that the actual game #%s in game editor is not the originally loaded game due to intermediate database changes, it is likely that you lose a different game. Really replace game data?" ;# NEW
::game::mc::ReallyReplaceGameDetail	"It is recommended to have a look on game #%s before doing this action." ;# NEW
::game::mc::ReopenLockedGames		"Re-open locked games from previous session?" ;# NEW
::game::mc::OpenAssociatedDatabases	"Open all associated databases?"

### languagebox ########################################################
::languagebox::mc::AllLanguages	"Összes nyelv"
::languagebox::mc::None				"Egyik sem"

### datebox ############################################################
::datebox::mc::Today		"Ma"
::datebox::mc::Calendar		"Naptár..."
::datebox::mc::Year		"Év"
::datebox::mc::Month		"Hónap"
::datebox::mc::Day		"Nap"

### genderbox ##########################################################
::genderbox::mc::Gender(m) "Férfi"
::genderbox::mc::Gender(f) "Nő"
::genderbox::mc::Gender(c) "Számítógép"

### terminationbox #####################################################
::terminationbox::mc::Normal				"Normál"
::terminationbox::mc::Unplayed				"Unplayed" ;# NEW
::terminationbox::mc::Abandoned				"Abandoned" ;# NEW
::terminationbox::mc::Adjudication			"Adjudication" ;# NEW
::terminationbox::mc::Disconnection			"Disconnection" ;# NEW
::terminationbox::mc::Emergency				"Emergency" ;# NEW
::terminationbox::mc::RulesInfraction			"Rules infraction" ;# NEW
::terminationbox::mc::TimeForfeit			"Leesett"
::terminationbox::mc::Unterminated			"Unterminated" ;# NEW

::terminationbox::mc::Result(1-0)			"Black resigned" ;# NEW
::terminationbox::mc::Result(0-1)			"White resigned" ;# NEW
::terminationbox::mc::Result(0-0)			"Declared lost for both players" ;# NEW
::terminationbox::mc::Result(1/2-1/2)			"Draw agreed" ;# NEW

::terminationbox::mc::Reason(Unplayed)			"Game is unplayed" ;# NEW
::terminationbox::mc::Reason(Abandoned)			"Game is abandoned" ;# NEW
::terminationbox::mc::Reason(Adjudication)		"Adjudication" ;# NEW
::terminationbox::mc::Reason(Disconnection)		"Disconnection" ;# NEW
::terminationbox::mc::Reason(Emergency)			"Abandoned due to an emergency" ;# NEW
::terminationbox::mc::Reason(RulesInfraction)		"Decided due to a rules infraction" ;# NEW
::terminationbox::mc::Reason(TimeForfeit)		"%s forfeits on time" ;# NEW
::terminationbox::mc::Reason(TimeForfeit,both)		"Both players forfeits on time" ;# NEW
::terminationbox::mc::Reason(TimeForfeit,remis)		"%causer ran out of time and %opponent cannot win" ;# NEW
::terminationbox::mc::Reason(Unterminated)		"Unterminated" ;# NEW

::terminationbox::mc::Termination(checkmate)		"%s is checkmate" ;# NEW
::terminationbox::mc::Termination(stalemate)		"%s is stalemate" ;# NEW
::terminationbox::mc::Termination(three-checks)		"%s got three checks" ;# NEW
::terminationbox::mc::Termination(material)		"%s wins by losing all material" ;# NEW
::terminationbox::mc::Termination(equal-material)	"Game drawn by stalemate (equal material)" ;# NEW
::terminationbox::mc::Termination(less-material)	"%s wins by having less material (stalemate)"
::terminationbox::mc::Termination(bishops)		"Game drawn by stalemate (opposite color bishops)" ;# NEW
::terminationbox::mc::Termination(fifty)		"Game drawn by the 50 move rule" ;# NEW
::terminationbox::mc::Termination(threefold)		"Game drawn by threefold repetition" ;# NEW
::terminationbox::mc::Termination(nomating)		"Neither player has mating material" ;# NEW
::terminationbox::mc::Termination(nocheck)		"Neither player can give check" ;# NEW

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
::help::mc::Contents			"&Tartalom"
::help::mc::Index			"&Tárgymutató"
::help::mc::CQL				"C&QL"
::help::mc::Search			"&Keresés"

::help::mc::Help			"Súgó"
::help::mc::MatchEntireWord		"Teljes szó keresése"
::help::mc::MatchCase			"Match case" ;# NEW
::help::mc::TitleOnly			"Keresés csak a címek között"
::help::mc::CurrentPageOnly		"Keresés csak a jelenlegi oldalon"
::help::mc::GoBack			"Egy oldallal vissza"
::help::mc::GoForward			"Egy oldallal előre"
::help::mc::GotoHome			"Go to top of page" ;# NEW
::help::mc::GotoEnd			"Go to end of page" ;# NEW
::help::mc::GotoPage			"Menj a '%s'-dik oldalra"
::help::mc::NextTopic			"Go to next topic" ;# NEW
::help::mc::PrevTopic			"Go to previous topic" ;# NEW
::help::mc::ExpandAllItems		"Kibontás"
::help::mc::CollapseAllItems		"Összecsukás"
::help::mc::SelectLanguage		"Nyelv választás"
::help::mc::NoHelpAvailable		"Nincs elérhető súgó fájl magyar nyelven.\nVálaszz másik nyelvet\na súgó számára."
::help::mc::NoHelpAvailableAtAll	"Ehhez a témához még nem létezik súgó fájl."
::help::mc::KeepLanguage		"Őrizzem meg a %s nyelvet a következő alkalmakra is?"
::help::mc::ParserError			"Error while parsing file %s." ;# NEW
::help::mc::NoMatch			"Nincs találat"
::help::mc::MaxmimumExceeded		"Túl sok találat néhány oldalon."
::help::mc::OnlyFirstMatches		"Csak az első %s találat jelenik meg."
::help::mc::HideIndex			"Tárgymutató elrejtése"
::help::mc::ShowIndex			"Tárgymutató mutatása"
::help::mc::All				"All" ;# NEW

::help::mc::FileNotFound		"Fájl nem található."
::help::mc::CantFindFile		"Fájl nem található %s könyvtárban."
::help::mc::IncompleteHelpFiles		"Úgy tűnik, hogy a súgó fájlok még nem véglegesek. Bocs!"
::help::mc::ProbablyTheHelp		"Valószínűleg egy más nylevű súgó segíthet"
::help::mc::PageNotAvailable		"Ez az oldal nem elérhető"

### crosstable #########################################################
::crosstable::mc::TournamentTable		"Verseny tabella"
::crosstable::mc::AverageRating			"Átlagos pontszám"
::crosstable::mc::Category			"Kategória"
::crosstable::mc::Games				"játszmák"
::crosstable::mc::Game				"játszma"
::crosstable::mc::ScoringSystem			"Pontozási rendszer"
::crosstable::mc::Tiebreak			"Rövidített játszma"
::crosstable::mc::Settings			"Beállítások"
::crosstable::mc::RevertToStart			"Kiinduló értékek visszaállítása"
::crosstable::mc::UpdateDisplay			"Képernyő frissítése"
::crosstable::mc::SaveAsHTML			"Mentés HTML fájlként"

::crosstable::mc::Traditional			"Hagyományos"
::crosstable::mc::Bilbao			"Bilbao" ;# NEW

::crosstable::mc::None				"nincs"
::crosstable::mc::Buchholz			"Buchholz"
::crosstable::mc::MedianBuchholz		"Median-Buchholz"
::crosstable::mc::ModifiedMedianBuchholz 	"Mod. Median-Buchholz"
::crosstable::mc::RefinedBuchholz		"Refined Buchholz"
::crosstable::mc::SonnebornBerger		"Sonneborn-Berger"
::crosstable::mc::Progressive			"Progresszív"
::crosstable::mc::KoyaSystem			"Koya rendszer"
::crosstable::mc::GamesWon			"Nyert játszmák"
::crosstable::mc::GamesWonWithBlack		"Sötéttel nyert játszmák"
::crosstable::mc::ParticularResult		"Particular Result" ;# NEW
::crosstable::mc::TraditionalScoring		"Hagyományos pontozás"

::crosstable::mc::Crosstable			"Kereszttábla"
::crosstable::mc::Scheveningen			"Scheveningeni"
::crosstable::mc::Swiss				"Svájci rendszer"
::crosstable::mc::Match				"Match"
::crosstable::mc::Knockout			"Kieséses"
::crosstable::mc::RankingList			"Rangsor"

::crosstable::mc::Order				"Sorrend"
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
::crosstable::mc::ShowWinDrawLoss		"Győzelem/Döntetlen/Vereség"
::crosstable::mc::ShowTiebreak			"Rövidített játszma"
::crosstable::mc::ShowOpponent			"Ellenfél (as Tooltip)"
::crosstable::mc::KnockoutStyle			"Kiütéses Táblázat Stílus" ;# ?
::crosstable::mc::Pyramid			"Piramis"
::crosstable::mc::Triangle			"Háromszög"

::crosstable::mc::CrosstableLimit		"Túl sok a játékos (>%d) a kereszttáblához."
::crosstable::mc::CrosstableLimitDetail		"'%s' is choosing another table mode."
::crosstable::mc::CannotOverwriteFile		"'%s' felülírása sikertelen: hozzáférés megtagadva."
::crosstable::mc::CannotCreateFile		"'%s' létrehozása sikertelen: hozzáférés megtagadva."

### info ###############################################################
::info::mc::InfoTitle		"Névjegy %s"
::info::mc::Info		"Info"
::info::mc::About		"Névjegy"
::info::mc::Contributions	"Készítők" ;#Contributions
::info::mc::License		"Liszenc"
::info::mc::Localization	"Regionális beállítások" ;#"Localization"
::info::mc::Testing		"Tesztelés"
::info::mc::References		"Referenciák"
::info::mc::System		"Rendszer"
::info::mc::FontDesign		"sakk betűtípus terv" ;#chess font design
::info::mc::ChessPieceDesign	"Figurakészlet terv" ;# "chess piece design"
::info::mc::BoardThemeDesign	"Tábla terv" ;#"Board theme design"
::info::mc::FlagsDesign		"Miniatűr zászló terv" ;#"Miniature flags design"
::info::mc::IconDesign		"Ikon terv"
::info::mc::Development		"Fejlesztés"
::info::mc::Programming		"Kódolás"
::info::mc::Head		"Head" ;# NEW

::info::mc::Version		"Verzió"
::info::mc::Distributed		"This program is distributed under the terms of the GNU General Public License."
::info::mc::Inspired		"Scidb is inspired by Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
::info::mc::SpecialThanks	"Special thanks to %s for his terrific work. His effort is the basis for this application."

### comment ############################################################
::comment::mc::CommentBeforeMove	"Megjegyzés lépés elé"
::comment::mc::CommentAfterMove		"Megjegyzés lépés utám"
::comment::mc::PrecedingComment		"Előző megjegyzés"
::comment::mc::TrailingComment		"Utolsó megjegyzés"
::comment::mc::Language			"Nyelv"
::comment::mc::AddLanguage		"Nyelv hozzáadása..."
::comment::mc::SwitchLanguage		"Nyelv váltása"
::comment::mc::FormatText		"Szöveg formázása"
::comment::mc::CopyText			"Szöveg másolása"
::comment::mc::OverwriteContent		"Felülírod a meglévő tartalmat?"
::comment::mc::AppendContent		"Ha \"nem\" , akkor a szöveg hozzáasódik."
# Note for translators: "Emoticons" can be simply translated to "Smiley"
::comment::mc::DisplayEmoticons		"Display Emoticons" ;# NEW

::comment::mc::LanguageSelection	"Nyelvválasztás"
::comment::mc::Formatting		"Formázás"

::comment::mc::Bold			"Félkövér"
::comment::mc::Italic			"Dőlt"
::comment::mc::Underline		"Aláhúzott"

::comment::mc::InsertSymbol		"Szimbólum be&illesztése..."
# Note for translators: "Emoticon" can be simply translated to "Smiley"
::comment::mc::InsertEmoticon		"Insert &Emoticon..." ;# NEW
::comment::mc::MiscellaneousSymbols	"Vegyes szimbólumok"
::comment::mc::Figurine			"Figurális"

### annotation #########################################################
::annotation::mc::AnnotationEditor		"Értékelő jelek"
::annotation::mc::TooManyNags			"Túl sok értékelő jel (az utolsó elvetve)."
::annotation::mc::TooManyNagsDetail		"Maximal %d annotations per ply allowed."

::annotation::mc::PrefixedCommentaries		"Lépés előtti szimbólumok"
::annotation::mc::MoveAssesments		"Lépés értékelések"
::annotation::mc::PositionalAssessments		"Állás értékelések"
::annotation::mc::TimePressureCommentaries	"Időzavar jelölések"
::annotation::mc::AdditionalCommentaries	"További megjegyzések"
::annotation::mc::ChessBaseCommentaries		"ChessBase megjegyzések"

### marks ##############################################################
::marks::mc::MarksPalette			"Marks - Palette"

### move ###############################################################
::move::mc::Action(replace)	"Lépés felülírása"
::move::mc::Action(variation)	"Új változat hozzáadása"
::move::mc::Action(mainline)	"Új főváltozat"
::move::mc::Action(trial)	"Változat kipróbálása"
::move::mc::Action(exchange)	"Lépés cseréje"
::move::mc::Action(append)	"Lépés hozzáadása"
::move::mc::Action(load)	"Első játszma betöltése ezzel a folytatással"

::move::mc::Accel(trial)	"T"
::move::mc::Accel(replace)	"R"
::move::mc::Accel(variation)	"V"
::move::mc::Accel(append)	"A"
::move::mc::Accel(load)		"L"

::move::mc::GameWillBeTruncated	"Játszma megcsonkításra kerül. Folytatod? '%s'"

### log ################################################################
::log::mc::LogTitle		"Eseménynapló"
::log::mc::Warning		"Figyelmeztetés"
::log::mc::Error		"Hiba"
::log::mc::Information		"Információ"

### titlebox ############################################################
::titlebox::mc::None		"No title" ;# NEW
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
::table::mc::ExpandColumn			"Oszlopszélesség növelése"
::table::mc::SqueezeColumns			"Oszlopszélesség csökkentése (Squeeze)"
::table::mc::AccelFitColumns			"Ctrl+,"
::table::mc::AccelOptimizeColumns		"Ctrl+."
::table::mc::AccelSqueezeColumns		"Ctrl+#"

### fileselectionbox ###################################################
::dialog::fsbox::mc::ScidbDatabase		"Scidb adatbázis"
::dialog::fsbox::mc::ScidDatabase		"Scid adatbázis"
::dialog::fsbox::mc::ChessBaseDatabase		"ChessBase adatbázis"
::dialog::fsbox::mc::PortableGameFile		"PGN fájl" ;# PGN sakkfeljegyzés
::dialog::fsbox::mc::PortableGameFileCompressed "PGN fájl (gzip-pel tömörítve)"
::dialog::fsbox::mc::BughousePortableGameFile "Bughouse PGN fájl"
::dialog::fsbox::mc::BughousePortableGameFileCompressed "Bughouse PGN fájl (gzip-pel tömörítve)"
::dialog::fsbox::mc::ZipArchive			"ZIP archívum"
::dialog::fsbox::mc::ScidbArchive		"Scidb archívum"
::dialog::fsbox::mc::PortableDocumentFile	"PDF" ;# NEW
::dialog::fsbox::mc::HypertextFile		"Hypertext File" ;# NEW
::dialog::fsbox::mc::TypesettingFile		"Typesetting File" ;# NEW
::dialog::fsbox::mc::ImageFile			"Képfájl"
::dialog::fsbox::mc::TextFile			"Szövegfájl"
::dialog::fsbox::mc::BinaryFile			"Bináris fájl"
::dialog::fsbox::mc::ShellScript		"Shell Script" ;# NEW
::dialog::fsbox::mc::Executable			"Executable" ;# NEW

::dialog::fsbox::mc::LinkTo			"Link to %s" ;# NEW
::dialog::fsbox::mc::LinkTarget			"Link target" ;# NEW
::dialog::fsbox::mc::Directory			"Directory" ;# NEW

::dialog::fsbox::mc::Title(open)		"Select File" ;# NEW
::dialog::fsbox::mc::Title(save)		"Save File" ;# NEW
::dialog::fsbox::mc::Title(dir)			"Choose Directory" ;# NEW

::dialog::fsbox::mc::Content			"Content" ;# NEW
::dialog::fsbox::mc::Open			"Open" ;# NEW
::dialog::fsbox::mc::OriginalPath		"Original Path" ;# NEW
::dialog::fsbox::mc::DateOfDeletion		"Date of Deletion" ;# NEW

::dialog::fsbox::mc::FileType(exe)		"Executables" ;# NEW
::dialog::fsbox::mc::FileType(txt)		"Text files" ;# NEW
::dialog::fsbox::mc::FileType(bin)		"Binary files" ;# NEW
::dialog::fsbox::mc::FileType(log)		"Log files" ;# NEW
::dialog::fsbox::mc::FileType(html)		"HTML files" ;# NEW

### choosecolor ########################################################
::dialog::choosecolor::mc::Ok			"&OK"
::dialog::choosecolor::mc::Cancel		"&Mégse"

::dialog::choosecolor::mc::BaseColors		"Alap színek"
::dialog::choosecolor::mc::UserColors		"Felhasználó színek"
::dialog::choosecolor::mc::RecentColors		"Legutóbbi színek"
::dialog::choosecolor::mc::Old			"Régi"
::dialog::choosecolor::mc::Current		"Aktuális"
::dialog::choosecolor::mc::HexCode		"Hex Code" ;# NEW
::dialog::choosecolor::mc::ColorSelection	"Színválasztás"
::dialog::choosecolor::mc::Red			"Vörös"
::dialog::choosecolor::mc::Green		"Zöld"
::dialog::choosecolor::mc::Blue			"Kék"
::dialog::choosecolor::mc::Hue			"Hue"
::dialog::choosecolor::mc::Saturation		"Saturation"
::dialog::choosecolor::mc::Value		"Érték"
::dialog::choosecolor::mc::Enter		"Bevitel"
::dialog::choosecolor::mc::AddColor		"A kiválasztott szín hozzáadaása a felhasználói színekhez"

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
::fsbox::mc::Name			"Név"
::fsbox::mc::Size			"Dátum"
::fsbox::mc::Modified			"Módosítva"

::fsbox::mc::Forward			"Forward to '%s'"
::fsbox::mc::Backward			"Backward to '%s'"
::fsbox::mc::Delete			"Töröl"
::fsbox::mc::MoveToTrash		"Kukába"
::fsbox::mc::Restore			"Visszaállítás"
::fsbox::mc::Duplicate			"Duplicate"
::fsbox::mc::CopyOf			"Copy of %s"
::fsbox::mc::NewFolder			"Új könyvtár"
::fsbox::mc::Layout			"Nézet"
::fsbox::mc::ListLayout			"Lista nézet"
::fsbox::mc::DetailedLayout		"Részletes nézet"
::fsbox::mc::ShowHiddenDirs		"Mutasd a &rejtett könyvtárakat"
::fsbox::mc::ShowHiddenFiles		"Mutasd a &rejtett fájlokat és könyvtárakat"
::fsbox::mc::AppendToExisitingFile	"Játszmák hozzá&adása egy létező fájlhoz"
::fsbox::mc::Cancel			"&Mégse"
::fsbox::mc::Save			"Menté&s"
::fsbox::mc::Open			"&Megynitás"
::fsbox::mc::Overwrite			"Felülírás"
::fsbox::mc::Rename			"&Átnevez"
::fsbox::mc::Move			"Áthelyezés"

::fsbox::mc::AddBookmark		"Könyvjelző hozzáadása '%s'"
::fsbox::mc::RemoveBookmark		"Könyvjelző eltávolítása '%s'"
::fsbox::mc::RenameBookmark		"Könyvjelző átnevezése"

::fsbox::mc::Filename			"Fájl &név:"
::fsbox::mc::Filenames			"Fájl &nevek:"
::fsbox::mc::Directory			"Kö&nyvtár:" ;# NEW
::fsbox::mc::FilesType			"Fájl &típusok:"
::fsbox::mc::FileEncoding		"Fájl &kódolás:"

::fsbox::mc::Favorites			"Kedvencek"
::fsbox::mc::LastVisited		"Utoljára használt"   ;#?
::fsbox::mc::FileSystem			"Fájlredszer"
::fsbox::mc::Desktop			"Asztal"
::fsbox::mc::Trash			"Kuka"
::fsbox::mc::Download			"Download" ;# NEW
::fsbox::mc::Home			"Home"  ;#NEW

::fsbox::mc::SelectEncoding		"Adatbázis kódolásának kiválasztása"
::fsbox::mc::SelectWhichType		"Megjelenítendő fájltípusok kiválasztása"
::fsbox::mc::TimeFormat			"%Y.%m.%d %H:%M"

::fsbox::mc::CannotChangeDir		"Cannot change to the directory \"%s\".\nHozzáférés megtagadva."
::fsbox::mc::DirectoryRemoved		"Cannot change to the directory \"%s\".\nKönyvtár nem létezik."
::fsbox::mc::DeleteFailed		"'%s' törlése meghiúsult."
::fsbox::mc::RestoreFailed		"'%s' visszaállítása meghiúsult."
::fsbox::mc::CopyFailed			"'%s' fájl másolása meghiúsult: hozzáférés megtagadva"
::fsbox::mc::CannotCopy			"'%s' már létezik. A másolás meghiúsult."
::fsbox::mc::CannotDuplicate		"Cannot duplicate file '%s' due to the lack of read permission." ;# NEW
::fsbox::mc::ReallyDuplicateFile	"Really duplicate this file?"
::fsbox::mc::ReallyDuplicateDetail	"This file has about %s. Duplicating this file may take some time."
::fsbox::mc::InvalidFileExt		"A művelet meghiúsult: '%s' kiterjesztése érvénytelen."
::fsbox::mc::CannotRename		"'%s' nem nevezhető át, mert a könyvtár/fájl már létezik."
::fsbox::mc::CannotCreate		"'%s' könyvtár nem hozható létre, mert a könyvtár/fájl már létezik."
::fsbox::mc::ErrorCreate		"Hiba a könyvtár létrehozás közben: hozzáférés megtagadva."
::fsbox::mc::FilenameNotAllowed		"'%s' fájlnév nem engedélyezett."
::fsbox::mc::ContainsTwoDots		"Két egymásutáni pontot tartalmaz."
::fsbox::mc::ContainsReservedChars	"Contains reserved characters: %s, or a control character (ASCII 0-31)." ;# NEW previously: "Fenntartott karaktereket tartalmaz: %s."
::fsbox::mc::InvalidFileName		"A filename cannot start with a hyphen, and cannot end with a space or a period." ;# NEW
::fsbox::mc::IsReservedName		"Ez egy fenntartott név néhány operációs rendszeren."
::fsbox::mc::FilenameTooLong		"A file name should have less than 256 characters." ;# NEW
::fsbox::mc::InvalidFileExtension	"'%s': érvénytelen kiterjesztés."
::fsbox::mc::MissingFileExtension	"'%s': hiányzó kiterjesztés."
::fsbox::mc::FileAlreadyExists		"\"%s\" fájl már létezik.\n\nFelül akarod írni?"
::fsbox::mc::CannotOverwriteDirectory	"'%s' könyvtár nem írható felül."
::fsbox::mc::FileDoesNotExist		"\"%s\" fájl nem létezik."
::fsbox::mc::DirectoryDoesNotExist	"\"%s\" könyvtár nem létezik."
::fsbox::mc::CannotOpenOrCreate		"Cannot open/create '%s'. Please choose a directory."
::fsbox::mc::WaitWhileDuplicating	"Please wait while duplicating file..."
::fsbox::mc::FileHasDisappeared		"File '%s' has disappeared." ;# NEW
::fsbox::mc::CurrentlyInUse		"This file is currently in use." ;# NEW
::fsbox::mc::PermissionDenied		"Permission denied for directory '%s'." ;# NEW
::fsbox::mc::CannotOpenUri		"Cannot open the following URI:" ;# NEW
::fsbox::mc::InvalidUri			"Drop content is not a valid URI list." ;# NEW
::fsbox::mc::UriRejected		"The following files are rejected:" ;# NEW
::fsbox::mc::UriRejectedDetail		"Only the listed file types can be handled." ;# NEW
::fsbox::mc::CannotOpenRemoteFiles	"Cannot open remote files:" ;# NEW (http://*)
::fsbox::mc::CannotCopyFolders		"Cannot copy folders, thus these folders will be rejected:" ;# NEW
::fsbox::mc::OperationAborted		"Operation aborted." ;# NEW
::fsbox::mc::ApplyOnDirectories		"Are you sure that you want to apply the selected operation on (the following) directories?" ;# NEW
::fsbox::mc::EntryAlreadyExists		"Entry already exists" ;# NEW
::fsbox::mc::AnEntryAlreadyExists	"An entry '%s' already exists." ;# NEW
::fsbox::mc::SourceDirectoryIs		"The source directories is '%s'." ;# NEW
::fsbox::mc::NewName			"Új név"
::fsbox::mc::BookmarkAlreadyExists	"A bookmark for this folder is already existing: '%s'." ;# NEW
::fsbox::mc::AddBookmarkAnyway		"Add bookmark anyway?" ;# NEW
::fsbox::mc::OriginalPathDoesNotExist	"The original directory '%s' of this item does not exist anymore. Create this directory and continue with operation?" ;# NEW
::fsbox::mc::DragItemAnywhere		"An alternative may be to drag the item anywhere else to restore it." ;# NEW

::fsbox::mc::ReallyMove(file,w)		"Biztos hogy a kukába dobod a(z) '%s' fájlt?"
::fsbox::mc::ReallyMove(file,r)		"Biztos hogy a kukába dobod a(z) '%s' írásvédett fájlt?"
::fsbox::mc::ReallyMove(folder,w)	"Biztos hogy a kukába dobod a(z) '%s' könyvtárat"
::fsbox::mc::ReallyMove(folder,r)	"Biztos hogy a kukába dobod a(z) '%s' írásvédett könyvtárat?"
::fsbox::mc::ReallyDelete(file,w)	"Biztos hogy törlöd a(z) '%s' fájlt? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(file,r)	"Biztos hogy törlöd a(z) '%s' írásvédett fájlt? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(link,w)	"Biztos hogy törlöd a(z) '%s' linket?"
::fsbox::mc::ReallyDelete(link,r)	"Biztos hogy törlöd a(z) '%s' linket?"
::fsbox::mc::ReallyDelete(folder,w)	"Biztos hogy törlöd a(z) '%s' könyvtárat? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(folder,r)	"Biztos hogy törlöd a(z) '%s' írásvédett könyvtárat? Ez a művelet később nem vonható vissza."
::fsbox::mc::ReallyDelete(empty,w)	"Really delete empty folder '%s'? You cannot undo this operation." ;# NEW
::fsbox::mc::ReallyDelete(empty,r)	"Really delete empty write-protected folder '%s'? You cannot undo this operation." ;# NEW

::fsbox::mc::ErrorRenaming(folder)	"Hiba '%old' könyvtár '%new'-ra történő átnevezése közben: Hozzáférés megtagadva."
::fsbox::mc::ErrorRenaming(file)	"Hiba '%old' fájl '%new'-ra történő átnevezése közben: Hozzáférés megtagadva."

::fsbox::mc::Cannot(delete)		"'%s' fájl nem törölhető"
::fsbox::mc::Cannot(rename)		"'%s' fájlt nem lehet átnevezni"
::fsbox::mc::Cannot(move)		"'%s' fájlt nem lehet áthelyezni"
::fsbox::mc::Cannot(overwrite)		"'%s' fájlt nem lehet felülírni"

::fsbox::mc::DropAction(move)		"Beillesztés ide"
::fsbox::mc::DropAction(copy)		"Másolás innen"
::fsbox::mc::DropAction(link)		"Link Here"  ;#NEW
::fsbox::mc::DropAction(restore)	"Restore Here" ;# NEW

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
::country::mc::US_Virgin_Islands									"US Virgin Szigetek"
::country::mc::Wallis_and_Futuna									"Wallis and Futuna"
::country::mc::Wales													"Wales"
::country::mc::Yemen													"Jemen"
::country::mc::Yugoslavia											"Jugoszlávia"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzibár"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Vegyes Csapat"

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
::country::mc::Stateless											"Hontalan"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"afrikai"
::encoding::mc::Lang(ar)	"arab"
::encoding::mc::Lang(ast)	"Leonese"
::encoding::mc::Lang(az)	"azerbajdzsáni"
::encoding::mc::Lang(bat)	"balti"
::encoding::mc::Lang(be)	"fehérorosz"
::encoding::mc::Lang(bg)	"bolgár"
::encoding::mc::Lang(br)	"breton"
::encoding::mc::Lang(bs)	"bosnyák"
::encoding::mc::Lang(ca)	"katalán"
::encoding::mc::Lang(cs)	"cseh"
::encoding::mc::Lang(cy)	"walesi"
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
::encoding::mc::Lang(fo)	"faroese"
::encoding::mc::Lang(fr)	"francia"
::encoding::mc::Lang(fy)	"Frisian" ;# NEW
::encoding::mc::Lang(ga)	"ír"
::encoding::mc::Lang(gd)	"skót"
::encoding::mc::Lang(gl)	"Galician" ;# NEW
::encoding::mc::Lang(he)	"héber"
::encoding::mc::Lang(hi)	"hindi"
::encoding::mc::Lang(hr)	"horvát"
::encoding::mc::Lang(hu)	"magyar"
::encoding::mc::Lang(hy)	"örmény"
::encoding::mc::Lang(ia)	"Interlingua" ;' NEW
::encoding::mc::Lang(id)	"Indonesian" ;# NEW
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
::encoding::mc::Lang(oc)	"Occitan" ;' NEW
::encoding::mc::Lang(pl)	"lengyel"
::encoding::mc::Lang(pt)	"portugál"
::encoding::mc::Lang(rm)	"Romansh"  ;' NEW
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
::encoding::mc::Lang(tl)	"Tagalog" ;' NEW
::encoding::mc::Lang(tr)	"török"
::encoding::mc::Lang(uk)	"ukrán"
::encoding::mc::Lang(uz)	"üzbég"
::encoding::mc::Lang(vi)	"vietnámi"
::encoding::mc::Lang(wa)	"Walloon" ;' NEW
::encoding::mc::Lang(wen)	"Sorbian" ;' NEW
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

### emoticons ##########################################################
::emoticons::mc::Tooltip(smile)		"Smiling (Smiley)" ;# NEW
::emoticons::mc::Tooltip(frown)		"Frown (Frowny)" ;# NEW
::emoticons::mc::Tooltip(saint)		"Saint" ;# NEW
::emoticons::mc::Tooltip(evil)		"Evil" ;# NEW
::emoticons::mc::Tooltip(gleeful)	"Gleeful" ;# NEW
::emoticons::mc::Tooltip(wink)		"Winking" ;# NEW
::emoticons::mc::Tooltip(cool)		"Cool" ;# NEW
::emoticons::mc::Tooltip(grin)		"Grinning" ;# NEW
::emoticons::mc::Tooltip(neutral)	"Neutral" ;# NEW
::emoticons::mc::Tooltip(sweat)		"Sweating" ;# NEW
::emoticons::mc::Tooltip(confuse)	"Confused" ;# NEW
::emoticons::mc::Tooltip(shock)		"Shocked" ;# NEW
::emoticons::mc::Tooltip(kiss)		"Kissing" ;# NEW
::emoticons::mc::Tooltip(razz)		"Razzing" ;# NEW
::emoticons::mc::Tooltip(grumpy)	"Disappointed / Grumpy" ;# NEW
::emoticons::mc::Tooltip(upset)		"Upset" ;# NEW
::emoticons::mc::Tooltip(cry)		"Crying" ;# NEW
::emoticons::mc::Tooltip(yell)		"Yelling" ;# NEW
::emoticons::mc::Tooltip(surprise)	"Surprised" ;# NEW
::emoticons::mc::Tooltip(red)		"Ashamed" ;# NEW
::emoticons::mc::Tooltip(sleep)		"Sleepy" ;# NEW
::emoticons::mc::Tooltip(eek)		"Scared" ;# NEW
::emoticons::mc::Tooltip(kitty)		"Kitty" ;# NEW
::emoticons::mc::Tooltip(roll)		"Eye-rolling" ;# NEW
::emoticons::mc::Tooltip(blink)		"Blinking" ;# NEW
::emoticons::mc::Tooltip(glasses)	"Intelligent" ;# NEW

### remote #############################################################
::remote::mc::PostponedMessage "\"%s\" adatbázis megnyitása elhalasztva, amíg az aktuális művelet be nem fejeződik."

# vi:set ts=8 sw=8:
