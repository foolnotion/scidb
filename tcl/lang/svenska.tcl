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
# Copyright: (C) 2012-2013 Gregor Cramer
# Copyright: (C) 2012 Lars Ekman
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
::mc::SortMapping		{ä ä à a á a å a æ ae ç c é e ë e í i ñ n ö o õ o ø oe ß ss ü u Ü U}
::mc::AsciiMapping	{ä a à a á a å a æ a é e ë e ç c í i ñ n ö o õ o ø o ü u ß ss Å A Ä A Ö O Ü U}
::mc::SortOrder		{A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Å Ä Ö a b c d e f g h i j k l m n o p q r s t u v w x y z å ä ö}

::mc::Key(Alt)				"Alt"
::mc::Key(BS)				"\u232b"
::mc::Key(Ctrl)			"Ctrl" ;# NEW
::mc::Key(Del)				"Del" ;# NEW
::mc::Key(Down)			"\u2193"
::mc::Key(End)				"End" ;# NEW
::mc::Key(Enter)			"Enter" ;# NEW
::mc::Key(Esc)				"Esc"
::mc::Key(Home)			"Home" ;# NEW
::mc::Key(Left)			"\u2190"	;# "Vänster"
::mc::Key(Next)			"Page\u2193"	;# Page Down NEW
::mc::Key(Prior)			"Page\u2191"	;# Page Up NEW
::mc::Key(Right)			"\u2192" ;# "Höger"
::mc::Key(Shift)			"Shift" ;# NEW
::mc::Key(Up)				"\u2191"

::mc::Alignment			"Justering"
::mc::Apply					"Verkställ"
::mc::Archive				"Arkiv"
::mc::Background			"Bakgrund"
::mc::Black					"Svart"
::mc::Bottom				"Underkant"
::mc::Cancel				"Avbryt"
::mc::Clear					"Töm"
::mc::Close					"Stäng"
::mc::Color					"Färg"
::mc::Colors				"Färger"
::mc::Configuration		"Konfiguration"
::mc::Copy					"Kopiera"
::mc::Cut					"Klipp ut"
::mc::Dark					"Mörk"
::mc::Database				"Databas"
::mc::Default				"Standard"
::mc::Delete				"Radera"
::mc::Edit					"Redigera"
::mc::File					"Arkiv"
::mc::Filter				"Filter" ;# NEW
::mc::From					"Från"
::mc::Game					"Parti"
::mc::Layout				"Layout"
::mc::Left					"Vänster"
::mc::Lite					"Ljus"
::mc::Low					"Låg"
::mc::Modify				"Ändra"
::mc::No						"nej"
::mc::Normal				"Normal" ;# NEW
::mc::Number				"Nummer"
::mc::OK						"OK"
::mc::Order					"Ordning"
::mc::Paste					"Klistra in"
::mc::PieceSet				"Pjäser"
::mc::Preview				"Förhandsgranska"
::mc::Redo					"Gör om"
::mc::Remove				"Ta bort"
::mc::Reset					"Återställ"
::mc::Right					"Höger"
::mc::SelectAll			"Markera allt"
::mc::Texture				"Texture"
::mc::Theme					"Tema"
::mc::To						"Till"
::mc::Top					"Överkant"
::mc::Undo					"Undo"
::mc::Variant				"Variant" ;# NEW different from "Variation"
::mc::Variation			"Variation"
::mc::White					"Vit"
::mc::Yes					"ja"

::mc::Piece(K)				"Kung"
::mc::Piece(Q)				"Dam"
::mc::Piece(R)				"Torn"
::mc::Piece(B)				"Löpare"
::mc::Piece(N)				"Springare"
::mc::Piece(P)				"Bonde"

::mc::Logical(reset)		"Återställ"
::mc::Logical(or)			"Eller"
::mc::Logical(and)		"Och"
::mc::Logical(null)		"None" ;# NEW
::mc::Logical(remove)	"Remove" ;# NEW
::mc::Logical(not)		"Icke"

::mc::LogicalDetail(reset)			"Clear filter / Reset display" ;# NEW
::mc::LogicalDetail(or)				"Remove from filter / Add to display" ;# NEW
::mc::LogicalDetail(and)			"Extend filter / Restrict display" ;# NEW
::mc::LogicalDetail(null)			"Fill filter / Clear display" ;# NEW
::mc::LogicalDetail(remove)		"Add to filter / Remove from display" ;# NEW
::mc::LogicalDetail(not)			"Restrict filter / Extent display" ;# NEW

::mc::VariantName(Undetermined)	"Undetermined" ;# NEW
::mc::VariantName(Normal)			"Normal Chess" ;# NEW
::mc::VariantName(Bughouse)		"Bughouse Chess" ;# NEW
::mc::VariantName(Crazyhouse)		"Crazyhouse Chess" ;# NEW
::mc::VariantName(ThreeCheck)		"Tre-schack"
::mc::VariantName(Antichess)		"Slagschack"
::mc::VariantName(Suicide)			"Suicide" ;# NEW
::mc::VariantName(Giveaway)		"Giveaway" ;# NEW
::mc::VariantName(Losers)			"Losers" ;# NEW
::mc::VariantName(Chess960)		"Chess 960"
::mc::VariantName(Symm960)			"Chess 960 (endast symmetriskt)"
::mc::VariantName(Shuffle)			"Shuffle Chess"

### themes #############################################################
::scidb::themes::mc::CannotOverwriteTheme	"Kan inte skriva över tema %s."

### locale #############################################################
::locale::Pattern(decimalPoint)	","
::locale::Pattern(thousandsSep)	" "
::locale::Pattern(dateY)			"Y"
::locale::Pattern(dateM)			"Y M"
::locale::Pattern(dateD)			"Y-M-D"
::locale::Pattern(time)				"den D M Y, h:m"
::locale::Pattern(normal:dateY)	"Y"
::locale::Pattern(normal:dateM)	"Y-M"
::locale::Pattern(normal:dateD)	"Y-M-D"

### widget #############################################################
::widget::mc::Apply		"&Verkställ"
::widget::mc::Cancel		"&Avbryt"
::widget::mc::Clear		"&Rensa"
::widget::mc::Close		"S&täng"
::widget::mc::Ok			"&OK"
::widget::mc::Reset		"Å&terställ"
::widget::mc::Update		"&Updatera"
::widget::mc::Import		"&Importera"
::widget::mc::Revert		"&Återgå"
::widget::mc::Previous	"&Föregående"
::widget::mc::Next		"&Nästa"
::widget::mc::First		"&Första"
::widget::mc::Last		"&Sista"
::widget::mc::Help		"&Hjälp"
::widget::mc::Start		"&Start" ;# NEW

::widget::mc::New			"&Ny"
::widget::mc::Save		"&Spara"
::widget::mc::Delete		"&Radera"

::widget::mc::Control(minimize)	"Minimera"
::widget::mc::Control(restore)	"Lämna helskärm"
::widget::mc::Control(close)		"Stäng"

### util ###############################################################

::util::mc::IOErrorOccurred					"I/O fel uppstod"

::util::mc::IOError(OpenFailed)				"öppningen misslyckades"
::util::mc::IOError(ReadOnly)					"databasen är skrivskyddad"
::util::mc::IOError(UnknownVersion)			"okänd filversion"
::util::mc::IOError(UnexpectedVersion)		"oväntad filversion"
::util::mc::IOError(Corrupted)				"skadad fil"
::util::mc::IOError(WriteFailed)				"skrivning misslyckades"
::util::mc::IOError(InvalidData)				"ogiltigt data (filen kan vara skadad)"
::util::mc::IOError(ReadError)				"läsfel"
::util::mc::IOError(EncodingFailed)			"kan inte skriva i namnbas fil"
::util::mc::IOError(MaxFileSizeExceeded)	"maximal filstorlek uppnådd"
::util::mc::IOError(LoadFailed)				"inläsningen misslyckades  (för många tävlingar)"

::util::mc::SelectionOwnerDidntRespond		"Timeout during drop action: selection owner didn't respond."

### progress ###########################################################
::progress::mc::Progress							"Förlopp"

::progress::mc::Message(preload-namebase)		"Förladdar namndatabas"
::progress::mc::Message(preload-tournament)	"Förladdar turneringsindex"
::progress::mc::Message(preload-player)		"Förladdar spelarindex"
::progress::mc::Message(preload-annotator)	"Förladdar kommentatorindex"

::progress::mc::Message(read-index)				"Laddar indexdata"
::progress::mc::Message(read-game)				"Laddar partidata"
::progress::mc::Message(read-namebase)			"Laddar namndatabas"
::progress::mc::Message(read-tournament)		"Laddar turneringsindex"
::progress::mc::Message(read-player)			"Laddar spelarindex"
::progress::mc::Message(read-annotator)		"Laddar kommentatorindex"
::progress::mc::Message(read-source)			"Laddar källindex"
::progress::mc::Message(read-team)				"Laddar lagindex"
::progress::mc::Message(read-init)				"Laddar initieringsdata"

::progress::mc::Message(write-index)			"Skriver indexdata"
::progress::mc::Message(write-game)				"Skriver partidata"
::progress::mc::Message(write-namebase)		"Skriver namndatabas"

::progress::mc::Message(print-game)				"Skriv %s parti(er)"
::progress::mc::Message(copy-game)				"Kopiera %s parti(er)"

### menu ###############################################################
::menu::mc::Theme							"Tema"

::menu::mc::AllScidbFiles				"Alla Scidb filer"
::menu::mc::AllScidbBases				"Alla Scidb databaser"
::menu::mc::ScidBases					"Scid databaser"
::menu::mc::ScidbBases					"Scidb databaser"
::menu::mc::ChessBaseBases				"ChessBase databaser"
::menu::mc::ScidbArchives				"Scidb arkiv"
::menu::mc::PGNFilesArchives			"PGN filer/arkiv"
::menu::mc::PGNFiles						"PGN filer"
::menu::mc::BPGNFilesArchives			"BPGN filer/arkiv"
::menu::mc::BPGNFiles					"BPGN filer"
::menu::mc::PGNArchives					"PGN arkiv"

::menu::mc::Language						"&Språk"
::menu::mc::Toolbars						"&Verktygsfält"
::menu::mc::ShowLog						"Visa &Log"
::menu::mc::AboutScidb					"&Om Scidb"
::menu::mc::Fullscreen					"&Helskärm"
::menu::mc::LeaveFullscreen			"Lämna &helskärm"
::menu::mc::Help							"&Hjälp"
::menu::mc::Contact						"&Kontakt (Webbläsare)"
::menu::mc::Quit							"&Avsluta"
::menu::mc::Tools							"&Tools" ;# NEW
::menu::mc::Extras						"&Tillägg"
::menu::mc::Setup							"&Inställningar"

# Contact
::menu::mc::ContactBugReport			"&Felrapport"
::menu::mc::ContactFeatureRequest	"Ö&nskemål"

# Extras
::menu::mc::InstallChessBaseFonts	"Installera ChessBase fonter"
::menu::mc::OpenEngineLog				"Öppna &motorkonsol"

# Tools
::menu::mc::OpenEngineDictionary		"Open Engine &Dictionary" ;# NEW
::menu::mc::OpenPlayerDictionary		"Open &Player Dictionary" ;# NEW

# Setup
::menu::mc::Engines						"&Motorer"
::menu::mc::PrivatePlayerCard			"&Private Player Card" ;# NEW

::menu::mc::OpenFile						"Öppna Scidb fil"
::menu::mc::NewFile						"Skapa Scidb fil"
::menu::mc::Archiving					"Arkiverar"
::menu::mc::CreateArchive				"Skapa arkiv"
::menu::mc::BuildArchive				"Skapa arkiver %s"
::menu::mc::Data							"%s data" ;# NEW

### load ###############################################################
::load::mc::SevereError				"Allvarlig fel vid laddning av ECO-fil"
::load::mc::FileIsCorrupt			"Filen %s är skadad:"
::load::mc::ProgramAborting		"Programmet avbryter."
::load::mc::EngineSetupFailed		"Misslyckades att ladda motorkonfiguration"

::load::mc::Loading					"Laddar %s"
::load::mc::StartupFinished		"Inläsning klar"
::load::mc::SystemEncoding			"Systemkodning är '%s'"

::load::mc::ReadingFile(options)	"Läser alternativ"
::load::mc::ReadingFile(engines)	"Läser schackmotor"

::load::mc::ECOFile					"ECO-fil"
::load::mc::EngineFile				"schackmotor"
::load::mc::SpellcheckFile			"spelarinformation"
::load::mc::LocalizationFile		"lokaliseringsfilen"
::load::mc::RatingList				"%s ratinglista"
::load::mc::WikipediaLinks			"Wikipedia länkar"
::load::mc::ChessgamesComLinks	"chessgames.com länkar"
::load::mc::Cities					"städer"
::load::mc::PieceSet					"pjäser"
::load::mc::Theme						"teman"
::load::mc::Icons						"ikoner"

### archive ############################################################
::archive::mc::CorruptedArchive			"Arkiv '%s' är skadad."
::archive::mc::NotAnArchive				"'%s' är inte ett arkiv."
::archive::mc::CorruptedHeader			"Arkivhuvud i '%s' är skadat."
::archive::mc::CannotCreateFile			"Misslyckades att skapa fil '%s'."
::archive::mc::FailedToExtractFile		"Misslyckades att extrahera fil '%s'."
::archive::mc::UnknownCompression		"Okänd kompression '%s'."
::archive::mc::ChecksumError				"Fel kontrollsumma vid extrahering av '%s'."
::archive::mc::ChecksumErrorDetail		"Extraherad fil '%s' kommer vara skadad."
::archive::mc::FileNotReadable			"Filen '%s' går inte att läsa."
::archive::mc::UsingRawInstead			"Använder kompression 'raw' istället."
::archive::mc::CannotOpenArchive			"Kan inte öppna arkiv '%s'."
::archive::mc::CouldNotCreateArchive	"Kan inte skapa arkiv '%s'."

::archive::mc::PackFile						"Packa %s"
::archive::mc::UnpackFile					"Packa upp %s"

### player photos ######################################################
::util::photos::mc::InstallPlayerPhotos		"Installera/Updatera spelarfoton"
::util::photos::mc::TimeOut						"Timeout inträffade."
::util::photos::mc::EnterPassword				"Personligt lösenord"
::util::photos::mc::Download						"Hämta"
::util::photos::mc::SharedInstallation			"Delad installation"
::util::photos::mc::LocalInstallation			"Lokal installation"
::util::photos::mc::RetryLater					"Vänligen försök senare."
::util::photos::mc::DownloadStillInProgress	"Nerladdning av fotofiler pågår fortfarande."
::util::photos::mc::PhotoFiles					"Spelarfoton"

::util::photos::mc::RequiresSuperuserRights	"Installationen/uppdateringen kräver super-user rättigheter.\n\nNotera att lösenordet inte kommer att accepteras om din användare inte är med i sudoers filen."
::util::photos::mc::RequiresInternetAccess	"Installationen/uppdateringen av spelarfoton kräver en internetförbindelse."
::util::photos::mc::AlternativelyDownload(0)	"Alternativt kan du ladda ner fotofilerna från %link%. Installera sedan filerna i foldern %local%."
::util::photos::mc::AlternativelyDownload(1)	"Alternativt kan du ladda ner fotofilerna från %link%. Installera sedan filerna i den delade foldern %shared%, eller i den lokala foldern %local%."

::util::photos::mc::Error(nohttp)				"Kan inte öppna internetförbindelsen för att paketet TclHttp inte är installerat."
::util::photos::mc::Error(busy)					"Installationen/uppdateringen körs redan."
::util::photos::mc::Error(failed)				"Oväntat fel: Anropet av sub-processen misslyckades."
::util::photos::mc::Error(passwd)				"Lösenordet är felaktigt."
::util::photos::mc::Error(nosudo)				"Kan inte anropa 'sudo' kommandot därför  att din användare inte finns i sudoers filen."
::util::photos::mc::Detail(nosudo)				"Som en väg runt problemet kan du göra en lokal installation, eller starta den här applikationen som en super-user."

::util::photos::mc::Message(uptodate)			"Fotofilerna är redan uppdaterade."
::util::photos::mc::Message(finished)			"Installationen/uppdateringen av fotofiler har avslutas."
::util::photos::mc::Message(broken)				"Trasig Tcl library version."
::util::photos::mc::Message(noperm)				"Du har inte skrivrättigheter i foldern '%s'."
::util::photos::mc::Message(missing)			"Kan inte hitta foldern '%s'."
::util::photos::mc::Message(httperr)			"HTTP fel: %s"
::util::photos::mc::Message(httpcode)			"Oväntad HTTP kod %s."
::util::photos::mc::Message(noconnect)			"HTTP connection failed."
::util::photos::mc::Message(timeout)			"HTTP timeout inträffade."
::util::photos::mc::Message(crcerror)			"Checksummefel inträffade. Troligt pågående underhåll av filservern."
::util::photos::mc::Message(maintenance)		"På servern med fotofiler pågår det underhåll för närvarande."
::util::photos::mc::Message(notfound)			"Nerladdningen avbruten pga pågående underhåll av servern med fotofiler."
::util::photos::mc::Message(aborted)			"Användaren har avbrutit nerladdningen."
::util::photos::mc::Message(killed)				"Nerladdningen oväntad avbruten. Sub-processen har dött."

::util::photos::mc::Detail(nohttp)				"Installera paketet TclHttp, till exempel %s."
::util::photos::mc::Detail(noconnect)			"Troligen har du inte en internetförbindelse."
::util::photos::mc::Detail(badhost)				"En annan möjlighet är en dålig 'host', eller en dålig 'port'."

::util::photos::mc::Log(started)					"Installationen/uppdateringen av fotofiler började %s."
::util::photos::mc::Log(finished)				"Installationen/uppdateringen av fotofiler avslutade  %s."
::util::photos::mc::Log(destination)			"Folder för nerladdade fotofiler är '%s'."
::util::photos::mc::Log(created:1)				"%s fil skapad."
::util::photos::mc::Log(created:N)				"%s fil(er) skapad."
::util::photos::mc::Log(deleted:1)				"%s fil raderad."
::util::photos::mc::Log(deleted:N)				"%s fil(er) raderad."
::util::photos::mc::Log(skipped:1)				"%s fil överhoppad."
::util::photos::mc::Log(skipped:N)				"%s fil(er) överhoppad."
::util::photos::mc::Log(updated:1)				"%s fil updaterad."
::util::photos::mc::Log(updated:N)				"%s fil(er) updaterad."

### application ########################################################
::application::mc::Database				"&Databas"
::application::mc::Board					"&Bräde"
::application::mc::MainMenu				"&Huvudmeny"

::application::mc::DockWindow				"Docka fönster"
::application::mc::UndockWindow			"Avdocka fönster"
::application::mc::ChessInfoDatabase	"Chess Information Data Base"
::application::mc::Shutdown				"Avstängning..."
::application::mc::QuitAnyway				"Vill du avsluta?"

::application::mc::UpdatesAvailable		"Uppdateringar tillgängliga"

### application::board #################################################
::application::board::mc::ShowCrosstable				"Visa turneringstabell för partiet"
::application::board::mc::StartEngine					"Starta analysmotor"
::application::board::mc::StopEngine					"Stoppa analysmotor"
::application::board::mc::InsertNullMove				"Insert null move" ;# NEW
::application::board::mc::SelectStartPosition		"Select Start Position" ;# NEW
::application::board::mc::LoadRandomGame				"Load random game" ;# NEW

::application::board::mc::Tools							"Verktyg"
::application::board::mc::Control						"Kontroll"
::application::board::mc::Game							"Parti"
::application::board::mc::GoIntoNextVar				"Gå in i nästa variant"
::application::board::mc::GoIntPrevVar					"Gå in i föregående variant"

::application::board::mc::LoadGame(next)				"Ladda nästa parti"
::application::board::mc::LoadGame(prev)				"Ladda föregående parti"
::application::board::mc::LoadGame(first)				"Ladda första parti"
::application::board::mc::LoadGame(last)				"Ladda sista parti"

::application::board::mc::SwitchView(base)			"Switch to database view" ;# NEW
::application::board::mc::SwitchView(list)			"Switch to game list view" ;# NEW

::application::board::mc::Accel(edit-annotation)	"A"
::application::board::mc::Accel(edit-comment)		"C"
::application::board::mc::Accel(edit-marks)			"M"
::application::board::mc::Accel(add-new-game)		"S" ;# NEW
::application::board::mc::Accel(replace-game)		"R" ;# NEW
::application::board::mc::Accel(replace-moves)		"V" ;# NEW
::application::board::mc::Accel(trial-mode)			"T" ;# NEW

### application::database ##############################################
::application::database::mc::FileOpen							"Öppna databas"
::application::database::mc::FileOpenRecent					"Öppna senaste"
::application::database::mc::FileNew							"Ny databas"
::application::database::mc::FileExport						"Exportera"
::application::database::mc::FileImport(pgn)					"Importera PGN fil"
::application::database::mc::FileImport(db)					"Importera databas"
::application::database::mc::FileCreate						"Skapa arkiv"
::application::database::mc::FileClose							"Stäng"
::application::database::mc::FileMaintenance					"Underhåll"
::application::database::mc::FileCompact						"Komprimera"
::application::database::mc::FileStripMoveInfo				"Avlägsna draginformation"
::application::database::mc::FileStripPGNTags				"Avlägsna PGN-taggar"
::application::database::mc::HelpSwitcher						"Hjälp om databasväljare"

::application::database::mc::Games								"&Partier"
::application::database::mc::Players							"&Spelare"
::application::database::mc::Events								"&Tävlingar"
::application::database::mc::Sites								"&Platser"
::application::database::mc::Annotators						"&Kommentatorer"

::application::database::mc::File								"Fil"
::application::database::mc::SymbolSize						"Symbol storlek"
::application::database::mc::Large								"Stor"
::application::database::mc::Medium								"Mellan"
::application::database::mc::Small								"Liten"
::application::database::mc::Tiny								"Mycket liten"
::application::database::mc::LoadMessage						"Öppnar databas '%s'"
::application::database::mc::UpgradeMessage					"Upgraderar databas '%s'"
::application::database::mc::CompactMessage					"Komprimerar databas '%s'"
::application::database::mc::CannotOpenFile					"Kan inte öppna fil '%s'."
::application::database::mc::EncodingFailed					"Kodning %s misslyckades."
::application::database::mc::DatabaseAlreadyOpen			"Databasen '%s' är redan öppen."
::application::database::mc::Properties						"Egenskaper"
::application::database::mc::Preload							"Förinläsning"
::application::database::mc::MissingEncoding					"Saknar kodning %s (använder %s istället)"
::application::database::mc::DescriptionTooLarge			"Beskrivningen är för stor."
::application::database::mc::DescrTooLargeDetail			"Posten innehåller %d tecken, men bara %d tecken är tillåtet."
::application::database::mc::ClipbaseDescription			"Temporär databas, lagras inte på disk."
::application::database::mc::HardLinkDetected				"Kan inte ladda filen '%file1' därför den redan är laddad som filen '%file2'. Det kan bara hända när hård länkar är involverade."
::application::database::mc::HardLinkDetectedDetail		"Om vi laddar den här databasen två gånger kan applikation krasha pga trådanvändandet."
::application::database::mc::OverwriteExistingFiles		"Skriver över existerande filer i folder '%s'?"
::application::database::mc::SelectDatabases					"Välj databaser som ska öppnas"
::application::database::mc::ExtractArchive					"Packa upp arkiv %s"
::application::database::mc::SelectVariant					"Select Variant" ;# NEW
::application::database::mc::Example							"Example" ;# NEW

::application::database::mc::RecodingDatabase				"Omkodar %base från %from till %to"
::application::database::mc::RecodedGames						"%s parti(er) omkodade"

::application::database::mc::ChangeIcon						"Byt ikon"
::application::database::mc::Recode								"Omkoda"
::application::database::mc::EditDescription					"Redigera beskrivning"
::application::database::mc::EmptyClipbase					"Töm Clipbase"

::application::database::mc::Maintenance						"Maintenance" ;# NEW
::application::database::mc::StripMoveInfo					"Strip move information from database '%s'" ;# NEW
::application::database::mc::StripPGNTags						"Strip PGN tags from database '%s'" ;# NEW
::application::database::mc::GamesStripped(0)				"No game stripped." ;# NEW
::application::database::mc::GamesStripped(1)				"One game stripped." ;# NEW
::application::database::mc::GamesStripped(N)				"%s games stripped." ;# NEW
::application::database::mc::GamesRemoved(0)					"No game removed." ;# NEW
::application::database::mc::GamesRemoved(1)					"One game removed." ;# NEW
::application::database::mc::GamesRemoved(N)					"%s games removed." ;# NEW
::application::database::mc::AllGamesMustBeClosed			"All games must been closed before this operation can be done." ;# NEW
::application::database::mc::ReallyCompact					"Är du säker att databasen '%s' ska komprimeras?"
::application::database::mc::ReallyCompactDetail(1)		"Endast ett parti kommer bli raderade."
::application::database::mc::ReallyCompactDetail(N)		"%s partier kommer bli raderade."
::application::database::mc::RemoveSpace						"Some empty spaces will be removed." ;# NEW
::application::database::mc::CompactionRecommended			"It is recommended to compact the database." ;# NEW
::application::database::mc::SearchPGNTags					"Searching for PGN tags" ;# NEW
::application::database::mc::SelectSuperfluousTags			"Select superfluous tags:" ;# NEW

::application::database::mc::T_Unspecific						"Ospecifik"
::application::database::mc::T_Temporary						"Temporär"
::application::database::mc::T_Work								"Arbete"
::application::database::mc::T_Clipbase						"Clipbase"
::application::database::mc::T_MyGames							"Mina partier"
::application::database::mc::T_Informant						"Informant"
::application::database::mc::T_LargeDatabase					"Stordatabas"
::application::database::mc::T_CorrespondenceChess			"Korrschack"  
::application::database::mc::T_EmailChess						"E-post schack"
::application::database::mc::T_InternetChess					"Internetschack"
::application::database::mc::T_ComputerChess					"Datorschack"
::application::database::mc::T_Chess960						"Schack960"
::application::database::mc::T_PlayerCollection				"Spelarsamling"
# Female version of "Player Collection"
# Be sure that the translation starts with same term as the translation above.
::application::database::mc::T_PlayerCollectionFemale		"Spelarsamling"
::application::database::mc::T_Tournament						"Turnering"
::application::database::mc::T_TournamentSwiss				"Schweizer-turnering"
::application::database::mc::T_GMGames							"GM partier"
::application::database::mc::T_IMGames							"IM partier"
::application::database::mc::T_BlitzGames						"Blixtpartier"
::application::database::mc::T_Tactics							"Taktik"
::application::database::mc::T_Endgames						"Slutspel"
::application::database::mc::T_Analysis						"Analyser"
::application::database::mc::T_Training						"Träning"
::application::database::mc::T_Match							"Matcher"
::application::database::mc::T_Studies							"Studier"
::application::database::mc::T_Jewels							"Juveler"
::application::database::mc::T_Problems						"Problem"
::application::database::mc::T_Patzer							"Träflyttning"
::application::database::mc::T_Gambit							"Gambit"
::application::database::mc::T_Important						"Viktigt"
::application::database::mc::T_Openings						"Öppningar"
::application::database::mc::T_OpeningsWhite					"Vita öppningar"
::application::database::mc::T_OpeningsBlack					"Svarta öppningar"
::application::database::mc::T_Bughouse						"Chock"
::application::database::mc::T_Antichess						"Slagschack"
::application::database::mc::T_PGNFile							"PGN fil"
::application::database::mc::T_ThreeCheck						"Tre-schack"
::application::database::mc::T_Crazyhouse						"Crazyhouse" ;# NEW

::application::database::mc::OpenDatabase						"Öppna databas"
::application::database::mc::NewDatabase						"Ny databas"
::application::database::mc::CloseDatabase					"Stäng databas '%s'"
::application::database::mc::SetReadonly						"Sätt databasen '%s' skrivskyddad"
::application::database::mc::SetWriteable						"Sätt databasen '%s' skrivbar"

::application::database::mc::OpenReadonly						"Öppna skrivskyddat"
::application::database::mc::OpenWriteable					"Öppna skrivbart"

::application::database::mc::UpgradeDatabase					"%s är ett gammalt databasformat som inte kan öppnas skrivbart.\n\nEn uppgradering kommer skapa en ny version av databasen och efter det radera orginalfilerna.\n\nDet här kan ta en tid, men behöver bara göras en gång.\n\nVill du uppgradera databasen nu?"
::application::database::mc::UpgradeDatabaseDetail			"\"Nej\" kommer öppna databasen skrivskyddat och kan inte göras skrivbar."

::application::database::mc::MoveInfo(evaluation)			"Evaluation" ;# NEW
::application::database::mc::MoveInfo(playersClock)		"Players Clock" ;# NEW
::application::database::mc::MoveInfo(elapsedGameTime)	"Elapsed Game Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMoveTime)	"Elapsed Move Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMilliSecs)	"Elapsed Milliseconds" ;# NEW
::application::database::mc::MoveInfo(clockTime)			"Clock Time" ;# NEW
::application::database::mc::MoveInfo(corrChessSent)		"Correspondence Chess Sent" ;# NEW
::application::database::mc::MoveInfo(videoTime)			"Video Time" ;# NEW

### application::database::games #######################################
::application::database::games::mc::Control						"Kontroll"
::application::database::games::mc::GameNumber					"Partinummer"

::application::database::games::mc::GotoFirstPage				"Gå till första sidan av partier"
::application::database::games::mc::GotoLastPage				"Gå till sista sidan av partier"
::application::database::games::mc::PreviousPage				"Föregående sida av partier"
::application::database::games::mc::NextPage						"Nästa sida av partier"
::application::database::games::mc::GotoCurrentSelection		"Gå till aktuell markering"
::application::database::games::mc::UseVerticalScrollbar		"Lodrät rullningslist"
::application::database::games::mc::UseHorizontalScrollbar	"Vågrät rullningslist"
::application::database::games::mc::GotoEnteredGameNumber	"Gå till angivit partinummer"

### application::database::players #####################################
::application::database::players::mc::EditPlayer				"Redigera spelare"
::application::database::players::mc::Score						"Poäng"
::application::database::players::mc::TooltipRating			"Rating: %s"

### application::database::annotators ##################################
::application::database::annotators::mc::F_Annotator		"Kommentator"
::application::database::annotators::mc::F_Frequency		"Frekvens"

::application::database::annotators::mc::Find				"Sök"
::application::database::annotators::mc::FindAnnotator	"Sök kommentator"
::application::database::annotators::mc::ClearEntries		"Rensa poster"

### application::pgn ###################################################
::application::pgn::mc::Command(move:comment)			"Sätt kommentar"
::application::pgn::mc::Command(move:marks)				"Sätt markering"
::application::pgn::mc::Command(move:annotation)		"Sätt schacktecken/kommentar/markering"
::application::pgn::mc::Command(move:append)				"Lägg till drag"
::application::pgn::mc::Command(move:nappend)			"Lägg till drag"
::application::pgn::mc::Command(move:exchange)			"Byt ut drag"
::application::pgn::mc::Command(variation:new)			"Lägg till variant"
::application::pgn::mc::Command(variation:replace)		"Ersätt drag"
::application::pgn::mc::Command(variation:truncate)	"Trunkera variant"
::application::pgn::mc::Command(variation:first)		"Ange som huvudvariant"
::application::pgn::mc::Command(variation:promote)		"Flytta upp variant till huvudlinje"
::application::pgn::mc::Command(variation:remove)		"Radera variant"
::application::pgn::mc::Command(variation:remove:n)	"Delete Variations" ;# NEW
::application::pgn::mc::Command(variation:mainline)	"Ny huvudlinje"
::application::pgn::mc::Command(variation:insert)		"Infoga drag"
::application::pgn::mc::Command(variation:exchange)	"Byt ut drag"
::application::pgn::mc::Command(strip:moves)				"Drag från början"
::application::pgn::mc::Command(strip:truncate)			"Drag till slutet"
::application::pgn::mc::Command(strip:annotations)		"Schacktecken"
::application::pgn::mc::Command(strip:info)				"Drag information"
::application::pgn::mc::Command(strip:marks)				"Markering"
::application::pgn::mc::Command(strip:comments)			"Kommentarer"
::application::pgn::mc::Command(strip:variations)		"Varianter"
::application::pgn::mc::Command(copy:comments)			"Kopiera kommentarer"
::application::pgn::mc::Command(move:comments)			"Flytta kommentarer"
::application::pgn::mc::Command(game:clear)				"Rensa parti"
::application::pgn::mc::Command(game:merge)				"Merge Game" ;# NEW
::application::pgn::mc::Command(game:transpose)			"Transponera parti"

::application::pgn::mc::StartTrialMode						"Starta testmode"
::application::pgn::mc::StopTrialMode						"Avsluta testmode"
::application::pgn::mc::Strip									"Rensa"
::application::pgn::mc::InsertDiagram						"Infoga diagram"
::application::pgn::mc::InsertDiagramFromBlack			"Infoga diagram från svarts sida"
::application::pgn::mc::SuffixCommentaries				"Suffixed Commentaries"
::application::pgn::mc::StripOriginalComments			"Rensa original kommentarer"

::application::pgn::mc::LanguageSelection					"Språkval" ;# NEW change to "Language Selection"
::application::pgn::mc::MoveInfoSelection					"Move Info Selection" ;# NEW
::application::pgn::mc::MoveNotation						"Notation"
::application::pgn::mc::CollapseVariations				"Dölj varianter"
::application::pgn::mc::ExpandVariations					"Visa varianter"
::application::pgn::mc::EmptyGame							"Töm parti"

::application::pgn::mc::NumberOfMoves						"Antal halvdrag (i huvudlinje):"
::application::pgn::mc::InvalidInput						"Ogiltigt inmatning '%d'."
::application::pgn::mc::MustBeEven							"Inmatning måste vara ett jämnt nummer."
::application::pgn::mc::MustBeOdd							"Inmatning måste vara ett ojämnt nummer."
::application::pgn::mc::CannotOpenCursorFiles			"Kan inte öppna markörfilen: %s"
::application::pgn::mc::ReallyReplaceMoves				"Är du säker att dragen ska ersättas i aktuellt parti?"
::application::pgn::mc::CurrentGameIsNotModified		"Aktuelt parti är inte ändrat."
::application::pgn::mc::ShufflePosition					"Shuffle position..." ;# NEW

::application::pgn::mc::EditAnnotation						"Redigera schacktecken"
::application::pgn::mc::EditMoveInformation				"Redigera draginformation"
::application::pgn::mc::EditCommentBefore					"Redigera kommentar före drag"
::application::pgn::mc::EditCommentAfter					"Redigera kommentar efter drag"
::application::pgn::mc::EditPrecedingComment				"Redigera föregående kommentar"
::application::pgn::mc::EditTrailingComment				"Redigera efterföljande kommentar"
::application::pgn::mc::EditMarks							"Redigera markeringar"
::application::pgn::mc::Display								"Display"
::application::pgn::mc::None									"ingen"

::application::pgn::mc::MoveInfo(eval)						"Evaluation" ;# NEW
::application::pgn::mc::MoveInfo(clk)						"Players Clock" ;# NEW
::application::pgn::mc::MoveInfo(emt)						"Elapsed Time" ;# NEW
::application::pgn::mc::MoveInfo(ccsnt)					"Correspondence Chess Sent" ;# NEW
::application::pgn::mc::MoveInfo(video)					"Video Time" ;# NEW

### application::tree ##################################################
::application::tree::mc::Total								"Total"
::application::tree::mc::Control								"Kontroll"
::application::tree::mc::ChooseReferenceBase				"Välj referensdatabas"
::application::tree::mc::ReferenceBaseSwitcher			"Referensdatabas växel"
::application::tree::mc::Numeric								"Numerisk"
::application::tree::mc::Bar									"Bar"
::application::tree::mc::StartSearch						"Börja sökning"
::application::tree::mc::StopSearch							"Sluta sökning"
::application::tree::mc::UseExactMode						"Använd positions sökning"
::application::tree::mc::UseFastMode						"Använd accelererad sökning"
::application::tree::mc::UseQuickMode						"Använd snabbsökning"
::application::tree::mc::AutomaticSearch					"Automatisk sökning"
::application::tree::mc::LockReferenceBase				"Lås referensdatabas"
::application::tree::mc::SwitchReferenceBase				"Växla referensdatabas"
::application::tree::mc::TransparentBar					"Transparent bar"
::application::tree::mc::NoGamesFound						"No games found" ;# NEW
::application::tree::mc::NoGamesAvailable					"No games available" ;# NEW
::application::tree::mc::Searching							"Searching" ;# NEW
::application::tree::mc::VariantsNotYetSupported		"Chess variants not yet supported." ;# NEW

::application::tree::mc::FromWhitesPerspective			"Från vits sida"
::application::tree::mc::FromBlacksPerspective			"Från svarts sida"
::application::tree::mc::FromSideToMovePerspective		"Från sidan som är vid draget"
::application::tree::mc::FromWhitesPerspectiveTip		"Poäng från vits sida"
::application::tree::mc::FromBlacksPerspectiveTip		"Poäng från svarts sida"

::application::tree::mc::TooltipAverageRating			"Medelrating (%s)"
::application::tree::mc::TooltipBestRating				"Max rating (%s)"

::application::tree::mc::F_Number							"#"
::application::tree::mc::F_Move								"Drag"
::application::tree::mc::F_Eco								"ECO"
::application::tree::mc::F_Frequency						"Frekvens"
::application::tree::mc::F_Ratio								"Kvot"
::application::tree::mc::F_Score								"Poäng"
::application::tree::mc::F_Draws								"Remier"
::application::tree::mc::F_Performance						"Prestation"
::application::tree::mc::F_AverageYear						"\u00f8 År"
::application::tree::mc::F_LastYear							"Senast spelad"
::application::tree::mc::F_BestPlayer						"Bästa spelare"
::application::tree::mc::F_FrequentPlayer					"Frekventa spelare"

::application::tree::mc::T_Number							"Numeration"
::application::tree::mc::T_AverageYear						"Medelår"
::application::tree::mc::T_FrequentPlayer					"Mest frekvent spelare"

### database::switcher #################################################
::database::switcher::mc::Empty								"tom"
::database::switcher::mc::None								"ingen"
::database::switcher::mc::Failed								"misslyckades"

::database::switcher::mc::UriRejectedDetail(open)		"Bara Scidb databaser kan öppnas:"
::database::switcher::mc::UriRejectedDetail(import)	"Bara Scidb databases kan importeras:"
::database::switcher::mc::EmptyUriList						"Innehåll som släpps är tomt."
::database::switcher::mc::CopyGames							"Kopiera partier"
::database::switcher::mc::CopyGamesFromTo					"Kopiera partier från '%src' till '%dst'"
::database::switcher::mc::CopiedGames						"%s parti(er) kopierade"
::database::switcher::mc::NoGamesCopied					"Inga partier kopierade"
::database::switcher::mc::CopyGamesFrom					"Copy games from '%s'" ;# NEW
::database::switcher::mc::ImportGames						"Importera partier"
::database::switcher::mc::ImportFiles						"Importer filer:"

::database::switcher::mc::ImportOneGameTo(0)				"Kopiera ett parti till '%dst'?"
::database::switcher::mc::ImportOneGameTo(1)				"Kopiera cirka ett parti till '%dst'?"
::database::switcher::mc::ImportGamesTo(0)				"Kopiera %num partier till '%dst'?"
::database::switcher::mc::ImportGamesTo(1)				"Kopiera cirka %num partier till '%dst'?"

::database::switcher::mc::NumGames(0)						"none" ;# NEW
::database::switcher::mc::NumGames(1)						"one game" ;# NEW
::database::switcher::mc::NumGames(N)						"%s games" ;# NEW

::database::switcher::mc::SelectGames(all)				"All games" ;# NEW
::database::switcher::mc::SelectGames(filter)			"Only filtered games" ;# NEW
::database::switcher::mc::SelectGames(all,variant)		"Only variant %s" ;# NEW
::database::switcher::mc::SelectGames(filter,variant)	"Only filtered games of variant %s" ;# NEW
::database::switcher::mc::SelectGames(complete)			"Complete database" ;# NEW

::database::switcher::mc::GameCount							"Partier"
::database::switcher::mc::DatabasePath						"Databaskatalog"
::database::switcher::mc::DeletedGames						"Raderade partier"
::database::switcher::mc::Description						"Beskrivning"
::database::switcher::mc::Created							"Skapad"
::database::switcher::mc::LastModified						"Senast ändrad"
::database::switcher::mc::Encoding							"Kodning"
::database::switcher::mc::YearRange							"Årtalsintervall"
::database::switcher::mc::RatingRange						"Ratingintervall"
::database::switcher::mc::Result								"Resultat"
::database::switcher::mc::Score								"Poäng"
::database::switcher::mc::Type								"Typ"
::database::switcher::mc::ReadOnly							"Skrivskydda"

### board ##############################################################
::board::mc::CannotReadFile			"Kan inte läsa filen '%s':"
::board::mc::CannotFindFile			"Kan inte hitta filen '%s'"
::board::mc::FileWillBeIgnored		"'%s' kommer ignoreras (dubbla ID)"
::board::mc::IsCorrupt					"'%s' är skadad (okänd %s stil '%s')"
::board::mc::SquareStyleIsUndefined	"Square style '%s' no longer exists" ;# NEW
::board::mc::PieceStyleIsUndefined	"Piece style '%s' no longer exists" ;# NEW
::board::mc::ThemeIsUndefined			"Board theme '%s' no longer exists" ;# NEW

::board::mc::ThemeManagement			"Temahantering"
::board::mc::Setup						"Inställningar"

::board::mc::WorkingSet					"Arbetsuppsättning"

### board::options #####################################################
::board::options::mc::Coordinates			"Kordinater"
::board::options::mc::SolidColor				"Enfärgad"
::board::options::mc::EditList				"Redigera lista"
::board::options::mc::Embossed				"Relief"
::board::options::mc::Highlighting			"Markerade"
::board::options::mc::Border					"Ram"
::board::options::mc::SaveWorkingSet		"Spara arbetsuppsättning"
::board::options::mc::SelectedSquare		"Markerad ruta"
::board::options::mc::ShowBorder				"Visa ram"
::board::options::mc::ShowCoordinates		"Visa kordinater"
::board::options::mc::ShowMaterialValues	"Visa materiella värde"
::board::options::mc::ShowMaterialBar		"Visa material stapel"
::board::options::mc::ShowSideToMove		"Visa sida vid draget"
::board::options::mc::ShowSuggestedMove	"Visa föreslagna drag"
::board::options::mc::SuggestedMove			"Föreslagna drag"
::board::options::mc::Basic					"Enkelt"
::board::options::mc::PieceStyle				"Pjäser"
::board::options::mc::SquareStyle			"Bräde"
::board::options::mc::Styles					"Stilar"
::board::options::mc::Show						"Förhandsgranska"
::board::options::mc::ChangeWorkingSet		"Redigera arbetsuppsättning"
::board::options::mc::CopyToWorkingSet		"Kopiera till arbetsuppsättning"
::board::options::mc::NameOfPieceStyle		"Ange namn för pjässtil"
::board::options::mc::NameOfSquareStyle	"Ange namn för brädstil"
::board::options::mc::NameOfThemeStyle		"Ange namn för tema"
::board::options::mc::PieceStyleSaved		"Pjässtil '%s' sparad som '%s'"
::board::options::mc::SquareStyleSaved		"Brädstil '%s' sparad som '%s'"
::board::options::mc::ChooseColors			"Välj färger"
::board::options::mc::SupersedeSuggestion	"Supersede/use suggested colors from square style"
::board::options::mc::CannotDelete			"Kan inte radera '%s'."
::board::options::mc::IsWriteProtected		"Fil '%s' är skrivskyddat."
::board::options::mc::ConfirmDelete			"Är du säker du vill radera '%s'?"
::board::options::mc::NoPermission			"Kan inte radera '%s'.\nÅtkomst nekad."
::board::options::mc::BoardSetup				"Brädesinställningar"
::board::options::mc::OpenTextureDialog	"Öppna texturdialog"

::board::options::mc::YouCannotReverse		"Du kan inte ta tillbaka den här handlingen. Filen '%s' kommer fysiskt raderas."

::board::options::mc::CannotUsePieceWorkingSet "Kan inte skapa nytt tema med %s markerad för pjässtil.\n Först måste du spara den nya pjässtilen, eller välja en annan pjässtil."

::board::options::mc::CannotUseSquareWorkingSet "Kan inte skapa nytt tema med %s markerad för brädstil.\n Först måste du spara den nya brädstilen, eller välja en annan brädstil."

### board::piece #######################################################
::board::piece::mc::Start						"Start"
::board::piece::mc::Stop						"Stopp"
::board::piece::mc::HorzOffset				"Vågrät förskjutning"
::board::piece::mc::VertOffset				"Lodrät förskjutning"
::board::piece::mc::Gradient					"Gradient"
::board::piece::mc::Fill						"Fyllning"
::board::piece::mc::Stroke						"Streck"
::board::piece::mc::Contour					"Kontur"
::board::piece::mc::WhiteShape				"Vit form"
::board::piece::mc::PieceSelection			"Pjäs markering"
::board::piece::mc::BackgroundSelection	"Bakgrund markering"
::board::piece::mc::Zoom						"Zoom"
::board::piece::mc::Shadow						"Skugga"
::board::piece::mc::Opacity					"Genomskinlighet"
::board::piece::mc::ShadowDiffusion			"Skuggspridning"
::board::piece::mc::PieceStyleConf			"Pjässtil konfiguration"
::board::piece::mc::Offset						"Offset"
::board::piece::mc::Rotate						"Rotera"
::board::piece::mc::CloseDialog				"Stäng dialog och kasta bort ändringar?"
::board::piece::mc::OpenTextureDialog		"Öppna texturdialog"

### board::square ######################################################
::board::square::mc::SolidColor			"Enfärgad"
::board::square::mc::CannotReadFile		"Kan inte läsa fil"
::board::square::mc::Zoom					"Zoom"
::board::square::mc::Offset				"Offset"
::board::square::mc::Rotate				"Rotera"
::board::square::mc::Borderline			"Kantlinje"
::board::square::mc::Width					"Bredd"
::board::square::mc::Opacity				"Genomskinlighet"
::board::square::mc::GapBetweenSquares	"Mellanrum mellan rutor"
::board::square::mc::Highlighting		"Upplyst"
::board::square::mc::Selected				"Markerad"
::board::square::mc::SuggestedMove		"Föreslagit drag"
::board::square::mc::Show					"Förhandsgranskning"
::board::square::mc::SquareStyleConf	"Rutformats konfiguration"
::board::square::mc::CloseDialog			"Stäng dialog och kasta bort ändringar?"

### board::texture #####################################################
::board::texture::mc::PreselectedOnly "Endast förvalda"

### pgn-setup ##########################################################
::pgn::setup::mc::Configure(editor)				"Anpassa"
::pgn::setup::mc::Configure(browser)			"Anpassa utdata"
::pgn::setup::mc::TakeOver(editor)				"Ta inställningar från partibrowser"
::pgn::setup::mc::TakeOver(browser)				"Ta inställningar från partieditor"
::pgn::setup::mc::Pixel								"pixlar"
::pgn::setup::mc::Spaces							"blanksteg"
::pgn::setup::mc::RevertSettings					"Återgå till starttillstånd"
::pgn::setup::mc::ResetSettings					"Återställ till fabriksinställningar"
::pgn::setup::mc::DiscardAllChanges				"Kasta bort alla ändringar?"
::pgn::setup::mc::ThreefoldRepetition			"Threefold repetition" ;# NEW
::pgn::setup::mc::FiftyMoveRule					"50 drags regelen"

::pgn::setup::mc::Setup(Appearance)				"Utseende"
::pgn::setup::mc::Setup(Layout)					"Layout"
::pgn::setup::mc::Setup(Diagrams)				"Diagram"
::pgn::setup::mc::Setup(MoveStyle)				"Dragformat"

::pgn::setup::mc::Setup(Fonts)					"Fonter"
::pgn::setup::mc::Setup(font-and-size)			"Textfonter och storlek"
::pgn::setup::mc::Setup(figurine-font)			"Figurer (normal)"
::pgn::setup::mc::Setup(figurine-bold)			"Figurer (fet)"
::pgn::setup::mc::Setup(symbol-font)			"Symboler"

::pgn::setup::mc::Setup(Colors)					"Färger"
::pgn::setup::mc::Setup(Highlighting)			"Markering"
::pgn::setup::mc::Setup(start-position)		"Startposition"
::pgn::setup::mc::Setup(variations)				"Varianter"
::pgn::setup::mc::Setup(numbering)				"Numrering"
::pgn::setup::mc::Setup(brackets)				"Parenteser"
::pgn::setup::mc::Setup(illegal-move)			"Ogiltigt drag"
::pgn::setup::mc::Setup(comments)				"Kommentarer"
::pgn::setup::mc::Setup(annotation)				"Schacktecken"
::pgn::setup::mc::Setup(nagtext)					"NAG-text"
::pgn::setup::mc::Setup(marks)					"Markering"
::pgn::setup::mc::Setup(move-info)				"Draginformation"
::pgn::setup::mc::Setup(result)					"Resultat"
::pgn::setup::mc::Setup(current-move)			"Aktuellt drag"
::pgn::setup::mc::Setup(next-moves)				"Nästa drag"
::pgn::setup::mc::Setup(empty-game)				"Tomt parti"

::pgn::setup::mc::Setup(Hovers)					"Hovra"
::pgn::setup::mc::Setup(hover-move)				"Drag"
::pgn::setup::mc::Setup(hover-comment)			"Kommentar"
::pgn::setup::mc::Setup(hover-move-info)		"Draginformation"

::pgn::setup::mc::Section(ParLayout)			"Styckeformat"
::pgn::setup::mc::ParLayout(use-spacing)		"Använd styckeavstånd"
::pgn::setup::mc::ParLayout(column-style)		"Kolumnformat"
::pgn::setup::mc::ParLayout(tabstop-1)			"Indrag för vitt drag"
::pgn::setup::mc::ParLayout(tabstop-2)			"Indrag för svart drag"
::pgn::setup::mc::ParLayout(mainline-bold)	"Fet text för huvudlinjens drag"

::pgn::setup::mc::Section(Variations)			"Variantformat"
::pgn::setup::mc::Variations(width)				"Indrag"
::pgn::setup::mc::Variations(level)				"Indragsnivå"

::pgn::setup::mc::Section(Display)				"Display"
::pgn::setup::mc::Display(numbering)			"Visa variantnumrering"
::pgn::setup::mc::Display(moveinfo)				"Visa draginformation"
::pgn::setup::mc::Display(nagtext)				"Visa text för ovanliga NAG kommentarer"

::pgn::setup::mc::Section(Diagrams)				"Diagram" ;# NEW
::pgn::setup::mc::Diagrams(show)					"Visa diagram"
::pgn::setup::mc::Diagrams(square-size)		"Rutstorlek"
::pgn::setup::mc::Diagrams(indentation)		"Indrag"

### engine #############################################################
::engine::mc::Information				"Information"
::engine::mc::Features					"Funktioner"
::engine::mc::Options					"Alternativ"

::engine::mc::Name						"Namn"
::engine::mc::Identifier				"Identifierare"
::engine::mc::Author						"Författare"
::engine::mc::Webpage					"Webbsida"
::engine::mc::Email						"Email"
::engine::mc::Country					"Land"
::engine::mc::Rating						"Rating"
::engine::mc::Logo						"Logo"
::engine::mc::Protocol					"Protokoll"
::engine::mc::Parameters				"Parametrar"
::engine::mc::Command					"Kommand"
::engine::mc::Directory					"Folder"
::engine::mc::Variants					"Varianter"
::engine::mc::LastUsed					"Senast använd"

::engine::mc::Variant(standard)		"Standard"
::engine::mc::Variant(chess960)		"Schack960"
::engine::mc::Variant(bughouse)		"Chock"
::engine::mc::Variant(crazyhouse)	"Crazyhouse"
# NOTE: Suicide is Antichess according to FICS rules
# NOTE: "Giveaway" is Antichess according to internatianal rules.
# NOTE: "Losers" is Antichess according to ICC rules
# NOTE: You may translate "Suicide", "Giveaway", anmd "Losers" with the same term.
::engine::mc::Variant(suicide)		"Slagschack"
::engine::mc::Variant(giveaway)		"Slagschack"
::engine::mc::Variant(losers)			"Slagschack"
::engine::mc::Variant(3check)			"Tre-schack"

::engine::mc::Edit						"Redigera"
::engine::mc::View						"Visa"
::engine::mc::New							"Ny"
::engine::mc::Rename						"Byt namn"
::engine::mc::Delete						"Radera"
::engine::mc::Select(engine)			"Välj motor"
::engine::mc::Select(profile)			"Välj profil"
::engine::mc::ProfileName				"Profilnamn"
::engine::mc::NewProfileName			"Nytt profilnamn"
::engine::mc::OldProfileName			"Gammalt profilnamn"
::engine::mc::CopyFrom					"Kopiera från"
::engine::mc::NewProfile				"Ny profil"
::engine::mc::RenameProfile			"Byt namn på profil"
::engine::mc::EditProfile				"Redigera profil '%s'"
::engine::mc::ProfileAlreadyExists	"En profil med namn '%s' finns redan."
::engine::mc::ChooseDifferentName	"Välj ett annat namn."
::engine::mc::ReservedName				"Namnet '%s' är reserverat och kan inte användas."
::engine::mc::ReallyDeleteProfile	"Ta bort profil '%s'?"
::engine::mc::SortName					"Sort by name" ;# NEW
::engine::mc::SortElo					"Sort by Elo rating" ;# NEW
::engine::mc::SortRating				"Sort by CCRL rating" ;# NEW
::engine::mc::OpenUrl					"Open URL (web browser)" ;# NEW

::engine::mc::AdminEngines				"Hantera motorer"
::engine::mc::SetupEngine				"Installera motor %s"
::engine::mc::ImageFiles				"Imagefiler"
::engine::mc::SelectEngine				"Välj motor"
::engine::mc::SelectEngineLogo		"Välj motor logo"
::engine::mc::EngineDictionary		"Engine Dictionary" ;# NEW
::engine::mc::EngineFilter				"Engine Filter" ;# NEW
::engine::mc::EngineLog					"Engine Console" ;# NEW
::engine::mc::Probing					"Probing" ;# NEW
::engine::mc::NeverUsed					"Aldrig använd"
::engine::mc::OpenFsbox					"Öppna filvalsdialog"
::engine::mc::ResetToDefault			"Återställ till standard"
::engine::mc::ShowInfo					"Visa \"Info\""
::engine::mc::TotalUsage				"%s gånger totalt"
::engine::mc::Memory						"Minne (MB)"
::engine::mc::CPUs						"CPUs" ;# NEW
::engine::mc::Priority					"CPU prioritet"
::engine::mc::ClearHash					"Rensa hashtabeller"

::engine::mc::ConfirmNewEngine		"Bekräfta ny motor"
::engine::mc::EngineAlreadyExists	"An entry with this engine already exists." ;# NEW
::engine::mc::CopyFromEngine			"Make a copy of entry" ;# NEW
::engine::mc::CannotOpenProcess		"Cannot start process." ;# NEW
::engine::mc::DoesNotRespond			"This engine does not respond either to UCI nor to XBoard/WinBoard protocol." ;# NEW
::engine::mc::DiscardChanges			"The current item has changed.\n\nReally discard changes?"
::engine::mc::ReallyDelete				"Really delete engine '%s'?" ;# NEW
::engine::mc::EntryAlreadyExists		"An entry with name '%s' already exists." ;# NEW
::engine::mc::NoFeaturesAvailable	"This engine does not provide any feature, not even an analyze mode is available. You cannot use this engine for the analysis of positions." ;# NEW
::engine::mc::NoStandardChess			"This engine does not support standard chess." ;# NEW
::engine::mc::NoEngineAvailable		"No engine available." ;# NEW
::engine::mc::FailedToCreateDir		"Failed to create directory '%s'." ;# NEW
::engine::mc::ScriptErrors				"Any errors while saving will be displayed here." ;# NEW
::engine::mc::CommandNotAllowed		"Usage of command '%s' is not allowed here." ;# NEW
::engine::mc::ThrowAwayChanges		"Throw away all changes?" ;# NEW
::engine::mc::ResetToDefaultContent	"Reset to default content" ;# NEW

::engine::mc::ProbeError(registration)			"This engine requires a registration." ;# NEW
::engine::mc::ProbeError(copyprotection)		"This engine is copy-protected." ;# NEW

::engine::mc::FeatureDetail(analyze)			"This engine provides an analyze mode." ;# NEW
::engine::mc::FeatureDetail(multiPV)			"Allows you to see the engine evaluations and principal variations (PVs) from the highest ranked candidate moves. This engines can show up to %s principal variations." ;# NEW
::engine::mc::FeatureDetail(pause)				"This provides a proper handling of pause/resume: the engine does not think, ponder, or otherwise consume significant CPU time. The current thinking or pondering (if any) is suspended and both player's clocks are stopped." ;# NEW
::engine::mc::FeatureDetail(playOther)			"The engine is capable to play your move. Your clock wiil run while the engine is thinking about your move." ;# NEW
::engine::mc::FeatureDetail(hashSize)			"This feature allows to inform the engine on how much memory it is allowed to use maximally for the hash tables. This engine allows a range between %min and %max MB." ;# NEW
::engine::mc::FeatureDetail(clearHash)			"The user may clear the hash tables whlle the engine is running." ;# NEW
::engine::mc::FeatureDetail(threads)			"It allows you to configure the number of threads the chess engine will use during its thinking. This engine is using between %min and %max threads." ;# NEW
::engine::mc::FeatureDetail(smp)					"More than one CPU (core) can be used by this engine." ;# NEW
::engine::mc::FeatureDetail(limitStrength)	"The engine is able to limit its strength to a specific Elo number between %min-%max." ;# NEW
::engine::mc::FeatureDetail(skillLevel)		"The engine provides the possibility to lower the skill down, where it can be beaten quite easier." ;# NEW
::engine::mc::FeatureDetail(ponder)				"Pondering is simply using the user's move time to consider likely user moves and thus gain a pre-processing advantage when it is our turn to move, also referred as Permanent brain." ;# NEW
::engine::mc::FeatureDetail(chess960)			"Chess960 (or Fischer Random Chess) is a variant of chess. The game employs the same board and pieces as standard chess, but the starting position of the pieces along the players' home ranks is randomized, with a few restrictions which preserves full castling options in all starting positions, resulting in 960 unique positions." ;# NEW
::engine::mc::FeatureDetail(bughouse)			"Bughouse chess (also called Exchange chess, Siamese chess, Tandem chess, Transfer chess, or Double Bughouse) is a chess variant played on two chessboards by four players in teams of two. Normal chess rules apply, except that captured pieces on one board are passed on to the players of the other board, who then have the option of putting these pieces on their board." ;# NEW
::engine::mc::FeatureDetail(crazyhouse)		"Crazyhouse (also known as Drop Chess) is a chess variant similar to bughouse chess, but with only two players. It effectively incorporates a rule in shogi (Japanese chess), in which a player can introduce a captured piece back to the board as his own." ;# NEW
::engine::mc::FeatureDetail(suicide)			"Suicide Chess (also called Antichess, Take Me Chess, Must Kill, Reverse Chess) has simple rules: capturing moves are mandatory and the object is to lose all pieces. There is no check, the king is captured like an ordinary piece. In case of stalemate the side with fewer pieces will win (according to FICS rules)." ;# NEW
::engine::mc::FeatureDetail(giveaway)			"Giveaway Chess (a variant of Antichess) is like Suicide Chess, but in case of stalemate the side which is stalemate wins (according to international rules)." ;# NEW
::engine::mc::FeatureDetail(losers)				"Losing Chess is a variant of Antichess, where the goal is to lose the chess game, but with several conditions attached to the rules. The goal is to lose all of your pieces (except the king), although in Losers Chess, you can also win by getting checkmated (according to ICC rules)." ;# NEW
::engine::mc::FeatureDetail(3check)				"The characteristic of this chess variant: a player wins if he checks his opponent three times." ;# NEW
::engine::mc::FeatureDetail(playingStyle)		"This engine provides different playing styles, namely %s. See the handbook of the engine for an explanation of the different styles." ;# NEW

### analysis ###########################################################
::application::analysis::mc::Control						"Kontroll"
::application::analysis::mc::Information					"Information" ;# NEW
::application::analysis::mc::Setup							"Setup" ;# NEW
::application::analysis::mc::Pause							"Pause" ;# NEW
::application::analysis::mc::Resume							"Återuppta"
::application::analysis::mc::LockEngine					"Lås motor på aktuell position"
::application::analysis::mc::MultipleVariations			"Flera varianter (multi-pv)"
::application::analysis::mc::HashFullness					"Hash djup"
::application::analysis::mc::Hash							"Hash:" ;# NEW
::application::analysis::mc::Lines							"Rader:"
::application::analysis::mc::MateIn							"%color matt i %n"
::application::analysis::mc::BestScore						"Bästa poäng (av aktuella linjer)"
::application::analysis::mc::CurrentMove					"Söker för närvarande draget"
::application::analysis::mc::TimeSearched					"Söktid"
::application::analysis::mc::SearchDepth					"Sökdjup i plys (Selektivt sökdjup)"
::application::analysis::mc::IllegalPosition				"Ogiltig ställning - Kan inte analysera"
::application::analysis::mc::IllegalMoves					"Illegal moves in game - Cannot analyze" ;# NEW
::application::analysis::mc::DidNotReceivePong			"Engine is not responding to \"ping\" command - Engine aborted" ;# NEW

::application::analysis::mc::LinesPerVariation			"Rader per variant"
::application::analysis::mc::BestFirstOrder				"Sortera på  värdering"
::application::analysis::mc::Engine							"Motor" ;# NEW

# Note for translators: don't use more than 4 characters
::application::analysis::mc::Ply								"ply" ;# NEW
::application::analysis::mc::Seconds						"sec" ;# NEW
::application::analysis::mc::Minutes						"min" ;# NEW

::application::analysis::mc::Status(checkmate)			"%s är matt"
::application::analysis::mc::Status(stalemate)			"%s är patt"
::application::analysis::mc::Status(threechecks)		"%s har 3 schackar"
::application::analysis::mc::Status(losing)				"%s lost all pieces" ;# NEW

::application::analysis::mc::NotSupported(standard)	"Den här motorn har inte stöd för vanligt schack."
::application::analysis::mc::NotSupported(chess960)	"Den här motorn har inte stöd för schack960."
::application::analysis::mc::NotSupported(variant)		"This engine does not support variant '%s'." ;# NEW
::application::analysis::mc::NotSupported(analyze)		"Den här motorn har inte ett analys läge."

::application::analysis::mc::Signal(stopped)				"Motorn stoppad av signal."
::application::analysis::mc::Signal(resumed)				"Motorn återupptagen av signal."
::application::analysis::mc::Signal(killed)				"Motorn dödad av signal." ;# NEW change to "Engine crashed or killed by signal."
::application::analysis::mc::Signal(crashed)				"Motorn kraschade."
::application::analysis::mc::Signal(closed)				"Motorn har stängt anslutningen."
::application::analysis::mc::Signal(terminated)			"Motorn avslutades med värde %s."

::application::analysis::mc::Add(move)						"Add move" ;# NEW
::application::analysis::mc::Add(var)						"Add move as new variation" ;# NEW
::application::analysis::mc::Add(line)						"Add variation" ;# NEW
::application::analysis::mc::Add(all)						"Add all variations" ;# NEW

### gametable ##########################################################
::gametable::mc::DeleteGame				"Markera parti som raderad"
::gametable::mc::UndeleteGame				"Ångra radering av partiet"
::gametable::mc::EditGameFlags			"Redigera partimarkeringar"
::gametable::mc::Custom						"Anpassat"

::gametable::mc::Monochrome				"Svartvit"
::gametable::mc::Transparent				"Genomskinlig"
::gametable::mc::Relief						"Relief"
::gametable::mc::ShowIdn					"Visa schack960 positionsnummer"
::gametable::mc::Icons						"Ikoner"
::gametable::mc::Abbreviations			"Förkortningar"

::gametable::mc::SortAscending			"Sortera (stigande)"
::gametable::mc::SortDescending			"Sortera (fallande)"
::gametable::mc::SortOnAverageElo		"Sortera på medel Elo (fallande)"
::gametable::mc::SortOnAverageRating	"Sortera på medel rating (fallande)"
::gametable::mc::SortOnDate				"Sortera på datum (fallande)"
::gametable::mc::SortOnNumber				"Sortera på partinummer (stigande)"
::gametable::mc::ReverseOrder				"Omvänd ordning"
::gametable::mc::CancelSort				"Cancel sort" ;# NEW
::gametable::mc::NoMoves					"Inga drag"
::gametable::mc::NoMoreMoves				"Inga mer drag"
::gametable::mc::WhiteRating				"Vit rating"
::gametable::mc::BlackRating				"Svart rating"

::gametable::mc::Flags						"Flaggor"
::gametable::mc::PGN_CountryCode			"PGN landskod"
::gametable::mc::ISO_CountryCode			"ISO landskod"
::gametable::mc::ExcludeElo				"Exkludera Elo"
::gametable::mc::IncludePlayerType		"Inkludera spelartyp"
::gametable::mc::ShowTournamentTable	"Turneringstabell"

::gametable::mc::Long						"Lång"
::gametable::mc::Short						"Kort"

::gametable::mc::AccelBrowse				"W"
::gametable::mc::AccelOverview			"O"
::gametable::mc::AccelTournTable			"T"
::gametable::mc::Space						"Space"

::gametable::mc::F_Number					"#"
::gametable::mc::F_White					"Vit"
::gametable::mc::F_Black					"Svart"
::gametable::mc::F_Event					"Tävling"
::gametable::mc::F_Site						"Plats"
::gametable::mc::F_Date						"Datum"
::gametable::mc::F_Result					"Resultat"
::gametable::mc::F_Round					"Rond"
::gametable::mc::F_Annotator				"Kommentator"
::gametable::mc::F_Length					"Längd"
::gametable::mc::F_Termination			"Avslutning"
::gametable::mc::F_EventMode				"Mode"
::gametable::mc::F_Eco						"ECO"
::gametable::mc::F_Flags					"Flaggor"
::gametable::mc::F_Material				"Material"
::gametable::mc::F_Acv						"SKV"
::gametable::mc::F_Idn						"960"
::gametable::mc::F_Position				"Position"
::gametable::mc::F_EventDate				"Tävlingsdatum"
::gametable::mc::F_EventType				"Täv.typ"
::gametable::mc::F_Changed					"Ändrad"
::gametable::mc::F_Promotion				"Promovering"
::gametable::mc::F_UnderPromo				"Underpromovering"
::gametable::mc::F_StandardPos			"Standardposition"
::gametable::mc::F_Chess960Pos			"9"
::gametable::mc::F_Opening					"Öppning"
::gametable::mc::F_Variation				"Variant"
::gametable::mc::F_Subvariation			"Undervariant"
::gametable::mc::F_Overview				"Översikt"
::gametable::mc::F_Key						"Intern ECO-kod"

::gametable::mc::T_Number					"Nummer"
::gametable::mc::T_Acv						"Schacktecken / Kommentarer / Varianter"
::gametable::mc::T_WhiteRatingType		"Vit ratingytyp"
::gametable::mc::T_BlackRatingType		"Svart ratingtyp"
::gametable::mc::T_WhiteCountry			"Vit förbund"
::gametable::mc::T_BlackCountry			"Svart förbund"
::gametable::mc::T_WhiteTitle				"Vit titel"
::gametable::mc::T_BlackTitle				"Svart titel"
::gametable::mc::T_WhiteType				"Vit typ"
::gametable::mc::T_BlackType				"Svart typ"
::gametable::mc::T_WhiteSex				"Vit kön"
::gametable::mc::T_BlackSex				"Svart kön"
::gametable::mc::T_EventCountry			"Tävlingsland"
::gametable::mc::T_EventType				"Tävlingstyp"
::gametable::mc::T_Chess960Pos			"Schack960 position"
::gametable::mc::T_Deleted					"Raderad"
::gametable::mc::T_EngFlag					"Engelsk språkflagga"
::gametable::mc::T_OthFlag					"Övrig språkflagga"
::gametable::mc::T_Idn						"Schack960 positionsnummer"
::gametable::mc::T_Annotations			"Schacktecken"
::gametable::mc::T_Comments				"Kommentarer"
::gametable::mc::T_Variations				"Varianter"
::gametable::mc::T_TimeMode				"Time Mode"

::gametable::mc::P_Rating					"Ratingpoäng"
::gametable::mc::P_RatingType				"Ratingtyp"
::gametable::mc::P_Country					"Land"
::gametable::mc::P_Title					"Titel"
::gametable::mc::P_Type						"Typ"
::gametable::mc::P_Date						"Datum"
::gametable::mc::P_Mode						"Mode"
::gametable::mc::P_Sex						"Kön"
::gametable::mc::P_Name						"Namn"

::gametable::mc::G_White					"Vit"
::gametable::mc::G_Black					"Svart"
::gametable::mc::G_Event					"Tävling"

::gametable::mc::EventType(game)			"Parti"
::gametable::mc::EventType(match)		"Match"
::gametable::mc::EventType(tourn)		"Turn."
::gametable::mc::EventType(swiss)		"Schw."
::gametable::mc::EventType(team)			"Lag"
::gametable::mc::EventType(k.o.)			"K.O."
::gametable::mc::EventType(simul)		"Simul"
::gametable::mc::EventType(schev)		"Schev"

::gametable::mc::PlayerType(human)		"Man/Kvinna"
::gametable::mc::PlayerType(program)	"Dator"

::gametable::mc::GameFlags(w)				"Vit öppning"
::gametable::mc::GameFlags(b)				"Svart öppning"
::gametable::mc::GameFlags(m)				"Mittspel"
::gametable::mc::GameFlags(e)				"Slutspel"
::gametable::mc::GameFlags(N)				"Nyhet"
::gametable::mc::GameFlags(p)				"Bondestruktur"
::gametable::mc::GameFlags(T)				"Taktik"
::gametable::mc::GameFlags(K)				"Kungsflygel"
::gametable::mc::GameFlags(Q)				"Damflygel"
::gametable::mc::GameFlags(!)				"Briljans"
::gametable::mc::GameFlags(?)				"Blunder"
::gametable::mc::GameFlags(U)				"Användare"
::gametable::mc::GameFlags(*)				"Best Game"
::gametable::mc::GameFlags(D)				"Decided Tournament"
::gametable::mc::GameFlags(G)				"Model Game"
::gametable::mc::GameFlags(S)				"Strategi"
::gametable::mc::GameFlags(^)				"Attack"
::gametable::mc::GameFlags(~)				"Offer"
::gametable::mc::GameFlags(=)				"Försvar"
::gametable::mc::GameFlags(M)				"Material"
::gametable::mc::GameFlags(P)				"Pjässpel"
::gametable::mc::GameFlags(t)				"Taktisk miss"
::gametable::mc::GameFlags(s)				"Strategisk miss"
::gametable::mc::GameFlags(C)				"Ogiltig rockad"
::gametable::mc::GameFlags(I)				"Ogiltigt drag"

### playertable ########################################################
::playertable::mc::F_LastName					"Efternamn"
::playertable::mc::F_FirstName				"Förnamn"
::playertable::mc::F_FideID					"Fide ID"
::playertable::mc::F_DSBID						"DSB ID" ;# NEW
::playertable::mc::F_ECFID						"ECF ID" ;# NEW
::playertable::mc::F_ICCFID					"ICCF ID" ;# NEW
::playertable::mc::F_Title						"Titel"
::playertable::mc::F_Frequency				"Frekvens"

::playertable::mc::T_Federation				"Nation"
::playertable::mc::T_NativeCountry			"Native Country" ;# NEW
::playertable::mc::T_RatingType				"Ratingtyp"
::playertable::mc::T_Type						"Typ"
::playertable::mc::T_Sex						"Kön"
::playertable::mc::T_PlayerInfo				"Info Flag"

::playertable::mc::Find							"Hitta"
::playertable::mc::StartSearch				"Starta sökning"
::playertable::mc::ClearEntries				"Rensa"
::playertable::mc::NotFound					"Saknas."

::playertable::mc::Name							"Namn"
::playertable::mc::HighestRating				"Högsta rating"
::playertable::mc::MostRecentRating			"Senaste rating"
::playertable::mc::DateOfBirth				"Födelsedatum"
::playertable::mc::DateOfDeath				"Dödsdatum"

::playertable::mc::ShowPlayerCard			"Visa spelarkort..."

### eventtable #########################################################
::eventtable::mc::Attendance	"Deltagande"

### player dictionary ##################################################
::playerdict::mc::PlayerDictionary	"Player Dictionary" ;# NEW
::playerdict::mc::PlayerFilter		"Player Filter" ;# NEW
::playerdict::mc::Count					"Count" ;# NEW
::playerdict::mc::Ignore				"Ignore" ;# NEW
::playerdict::mc::FederationID		"Federation ID" ;# NEW
::playerdict::mc::BirthYear			"Birth Year" ;# NEW
::playerdict::mc::DeathYear			"Death Year" ;# NEW
::playerdict::mc::Ratings				"Ratings" ;# NEW
::playerdict::mc::Titles				"Titles" ;# NEW
::playerdict::mc::None					"None" ;# NEW
::playerdict::mc::Operation			"Operation" ;# NEW

### player-card ########################################################
::playercard::mc::PlayerCard					"Spelarkort"
::playercard::mc::Latest						"Senast"
::playercard::mc::Highest						"Högsta"
::playercard::mc::Minimal						"Minimal"
::playercard::mc::Maximal						"Maximal"
::playercard::mc::Win							"Vinster"
::playercard::mc::Draw							"Remier"
::playercard::mc::Loss							"Förluster"
::playercard::mc::Total							"Totalt"
::playercard::mc::FirstGamePlayed			"Första parti spelat"
::playercard::mc::LastGamePlayed				"Senaste parti spelat"
::playercard::mc::WhiteMostPlayed			"Vanligaste öppning som vit"
::playercard::mc::BlackMostPlayed			"Vanligaste öppning som svart"

::playercard::mc::OpenInWebBrowser			"Öppna i webbrowser"
::playercard::mc::OpenPlayerCard				"Öppna %s spelarkort"
::playercard::mc::OpenFileCard				"Öppna %s filkort"
::playercard::mc::OpenFideRatingHistory	"Öppna Fide ratinghistorik"
::playercard::mc::OpenWikipedia				"Öppna Wikipedia biografi"
::playercard::mc::OpenViafCatalog			"Öppna VIAF katalog"
::playercard::mc::OpenPndCatalog				"Öppna katalog i Deutsche Nationalbibliothek"
::playercard::mc::OpenChessgames				"chessgames.com partisamling"
::playercard::mc::SeachIn365ChessCom		"Sök i 365Chess.com"

### twm - tiled window manager #########################################
::twm::mc::Undock					"Avdocka"
::twm::mc::Close					"Stäng"

### fonts ##############################################################
::font::mc::ChessBaseFontsInstalled				"ChessBasefonter har installerats."
::font::mc::ChessBaseFontsInstallationFailed	"Installationen av ChessBasefonter misslyckades."
::font::mc::NoChessBaseFontFound					"Inga ChessBasefonter hittades i folder '%s'."
::font::mc::ChessBaseFontsAlreadyInstalled	"ChessBasefonter redan installerade. Ska installationen fortsätta ändå?"
::font::mc::ChooseMountPoint						"Monteringspunkt för installationspartition av Windows"
::font::mc::CopyingChessBaseFonts				"Kopierar ChessBasefonter"
::font::mc::CopyFile									"Kopiera fil %s"
::font::mc::UpdateFontCache						"Updatera font cache"

::font::mc::ChooseFigurineFont					"Choose figurine font" ;# NEW
::font::mc::ChooseSymbolFont						"Choose symbol font" ;# NEW
::font::mc::IncreaseFontSize						"Öka fontstorlek"
::font::mc::DecreaseFontSize						"Minska fontstorlek"

### gamebar ############################################################
::gamebar::mc::StartPosition					"Startposition"
::gamebar::mc::Players							"Spelare"
::gamebar::mc::Event								"Tävling"
::gamebar::mc::Site								"Plats"
::gamebar::mc::SeparateHeader					"Separat rubrik"
::gamebar::mc::ShowActiveAtBottom			"Visa aktivt parti längst ned"
::gamebar::mc::ShowPlayersOnSeparateLines	"Visa spelare på skilda rader"
::gamebar::mc::DiscardChanges					"Partiet har ändrats.\n\nÄr du säker att ändringarna inte ska sparas?"
::gamebar::mc::DiscardNewGame					"Vill du verkligen kasta bort det här partiet?"
::gamebar::mc::NewGameFstPart					"Nytt"
::gamebar::mc::NewGameSndPart					"parti"
::gamebar::mc::EnterGameNumber				"Enter game number" ;# NEW

::gamebar::mc::CopyThisGameToClipbase		"Copy this game to Clipbase" ;# NEW
::gamebar::mc::PasteLastClipbaseGame		"Paste last Clipbase game" ;# NEW
::gamebar::mc::MergeLastClipbaseGame		"Merge last Clipbase game" ;# NEW
::gamebar::mc::PasteGameFrom					"Paste game" ;# NEW
::gamebar::mc::MergeGameFrom					"Merge game" ;# NEW
::gamebar::mc::LoadGameNumber					"Load game number" ;# NEW
::gamebar::mc::ReloadCurrentGame				"Re-load current game" ;# NEW
::gamebar::mc::MergeWithCurrentGame			"Merge with current game" ;# NEW
::gamebar::mc::CreateNewGame					"Create new game" ;# NEW
::gamebar::mc::StartFromCurrentPosition	"Start merge from current position" ;# NEW
::gamebar::mc::StartFromInitialPosition	"Start merge from initial position" ;# NEW
::gamebar::mc::NoTranspositions				"No transpositions" ;# NEW
::gamebar::mc::IncludeTranspositions		"Include transpositions" ;# NEW
::gamebar::mc::VariationDepth					"Variation depth" ;# NEW

::gamebar::mc::LockGame							"Lås partiet"
::gamebar::mc::UnlockGame						"Lås upp partiet"
::gamebar::mc::CloseGame						"Stäng partiet"

::gamebar::mc::GameNew							"Nytt parti"
::gamebar::mc::AddNewGame						"Spara: Lägg till nytt parti till %s..."
::gamebar::mc::ReplaceGame						"Spara: Ersätt parti i %s..."
::gamebar::mc::ReplaceMoves					"Spara: Ersätt bara dragen i partiet..."

::gamebar::mc::Tip(Antichess)					"Det finns ingen schack, ingen rockad, kungen\ntas som en vanlig pjäs." ;# NEW
::gamebar::mc::Tip(Suicide)					"Om patt kommer spelaren med färre\npjäser att vinna (enligt FICS regler)." ;# NEW
::gamebar::mc::Tip(Giveaway)					"Om patt kommer spelaren som är\npatt att vinna (enligt internationella regler)." ;# NEW
 ;# NEW
::gamebar::mc::Tip(Losers)						"The king is like in normal chess, and you can also\nwin by getting checkmated or stalemated." ;# NEW

### validate ###########################################################
::validate::mc::Unlimited	"unlimited" ;# NEW

### browser ############################################################
::browser::mc::BrowseGame			"Titta igenom partiet"
::browser::mc::StartAutoplay		"Starta Autoplay"
::browser::mc::StopAutoplay		"Stoppa Autoplay"
::browser::mc::GoForward			"Gå framåt ett drag"
::browser::mc::GoBackward			"Gå bakåt ett drag"
::browser::mc::GoForwardFast		"Gå framåt flera drag"
::browser::mc::GoBackFast			"Gå bakåt flera drag"
::browser::mc::GotoStartOfGame	"Gå till början av partiet"
::browser::mc::GotoEndOfGame		"Gå till slutet av partiet"
::browser::mc::IncreaseBoardSize	"Förstora brädet"
::browser::mc::DecreaseBoardSize	"Förminska brädet"
::browser::mc::MaximizeBoardSize	"Maximera brädet"
::browser::mc::MinimizeBoardSize	"Minimera brädet"
::browser::mc::LoadPrevGame		"Load previous game" ;# NEW
::browser::mc::LoadNextGame		"Load next game" ;# NEW

::browser::mc::GotoGame(first)	"Gå till första partiet"
::browser::mc::GotoGame(last)		"Gå till sista partiet"
::browser::mc::GotoGame(next)		"Gå till nästa parti"
::browser::mc::GotoGame(prev)		"Gå till föregående parti"

::browser::mc::LoadGame				"Ladda parti into editor" ;# NEW
::browser::mc::ReloadGame			"Reload game" ;# NEW
::browser::mc::MergeGame			"Sammanfoga parti"

::browser::mc::IllegalMove			"Ogiltigt drag"
::browser::mc::NoCastlingRights	"Rockad ej tillåten"

### overview ###########################################################
::overview::mc::Overview				"Översikt"
::overview::mc::RotateBoard			"Byt sida"
::overview::mc::AcceleratorRotate	"R"

### encoding ###########################################################
::encoding::mc::AutoDetect				"auto-detection"

::encoding::mc::Encoding				"Kodning"
::encoding::mc::Description			"Beskriving"
::encoding::mc::Languages				"Språk (fonter)"
::encoding::mc::UseAutoDetection		"Use Auto-Detection"

::encoding::mc::ChooseEncodingTitle	"Välj kodning"

::encoding::mc::CurrentEncoding		"Aktuell kodning:"
::encoding::mc::DefaultEncoding		"Standardkodning:"
::encoding::mc::SystemEncoding		"Systemkodning:"

### setup ##############################################################
::setup::mc::Chess960Position			"Schack960 position"
::setup::mc::SymmChess960Position	"Symmetrisk schack960 position"
::setup::mc::ShuffleChessPosition	"Shuffleschack position"

### setup board ########################################################
::setup::position::mc::SetStartPosition		"Sätt startposition"
::setup::position::mc::UsePreviousPosition	"Använd tidigare position"

::setup::board::mc::SetStartBoard				"Sätt startbord"
::setup::board::mc::SideToMove					"Vid draget"
::setup::board::mc::Castling						"Rockad"
::setup::board::mc::MoveNumber					"Dragnummer"
::setup::board::mc::EnPassantFile				"En passant"
::setup::board::mc::HalfMoves						"Half move clock" ;# NEW
::setup::board::mc::StartPosition				"Startposition"
::setup::board::mc::Fen								"FEN"
::setup::board::mc::Promoted						"Promoted" ;# NEW
::setup::board::mc::Holding						"Holding" ;# NEW
::setup::board::mc::ChecksGiven					"Checks Given" ;# NEW
::setup::board::mc::Clear							"Rensa"
::setup::board::mc::CopyFen						"Kopiera FEN till urklipp"
::setup::board::mc::Shuffle						"Shuffle..." ;# NEW
::setup::board::mc::FICSPosition					"FICS Start Position..." ;# NEW
::setup::board::mc::StandardPosition			"Standardposition" ;# NEW
::setup::board::mc::Chess960Castling			"Chess 960 rockad"
::setup::board::mc::InvalidFen					"Ogiltigt FEN"

::setup::board::mc::ChangeToFormat(xfen)				"Ändra till X-Fen format"
::setup::board::mc::ChangeToFormat(shredder)			"Ändra till Shredder format"

::setup::board::mc::Error(InvalidFen)					"FEN är ogiltigt."
::setup::board::mc::Error(EmptyBoard)					"Brädet är tomt."
::setup::board::mc::Error(NoWhiteKing)					"Vit kung saknas."
::setup::board::mc::Error(NoBlackKing)					"Svart kung saknas."
::setup::board::mc::Error(BothInCheck)					"Båda kungar står i schack."
::setup::board::mc::Error(OppositeCheck)				"Spelaren som inte är vid draget står i schack."
::setup::board::mc::Error(TooManyWhitePawns)			"För många vita bönder."
::setup::board::mc::Error(TooManyBlackPawns)			"För många svarta bönder."
::setup::board::mc::Error(TooManyWhitePieces)		"För många vita pjäser."
::setup::board::mc::Error(TooManyBlackPieces)		"För många svarta pjäser."
::setup::board::mc::Error(PawnsOn18)					"Bonde på rad 1 eller 8."
::setup::board::mc::Error(TooManyKings)				"Fler än två kungar."
::setup::board::mc::Error(TooManyWhite)				"För många vita pjäser."
::setup::board::mc::Error(TooManyBlack)				"För många svarta pjäser."
::setup::board::mc::Error(BadCastlingRights)			"Ogiltiga rockadrättigheter."
::setup::board::mc::Error(InvalidCastlingRights)	"Ogiltig tornlinje för rockad."
::setup::board::mc::Error(InvalidCastlingFile)		"Ogiltig rockadlinje."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"För rockad måste entydiga tornlinjer anges. (Möjligtvis är fel linjer angivna.)"
::setup::board::mc::Error(TooManyPiecesInHolding)	"Too many pieces in holding." ;# NEW
::setup::board::mc::Error(TooManyPromotedPieces)	"Too many pieces marked as promoted." ;# NEW
::setup::board::mc::Error(TooFewPromotedPieces)		"Too few pieces marked as promoted." ;# NEW
::setup::board::mc::Error(InvalidEnPassant)			"Ogiltig en passant-linje."
::setup::board::mc::Error(MultiPawnCheck)				"Två eller fler bönder ger schack."
::setup::board::mc::Error(TripleCheck)					"Tre eller fler pjäser ger schack."

::setup::board::mc::Warning(TooFewPiecesInHolding)	"Too few pieces marked as promoted. Are you sure that this is ok?" ;# NEW
::setup::board::mc::Warning(CastlingWithoutRook)	"Du har valt att rockad är tillåten men det saknas minst ett torn. Detta är bara möjligt i partier med handikapp. Är du säker att du valt rätt?"
::setup::board::mc::Warning(UnsupportedVariant)		"Positionen är en startposition men ingen Shuffle Chess position. Är du säker?"

### import #############################################################
::import::mc::ImportingPgnFile					"Importerar PGN-fil '%s'"
::import::mc::ImportingDatabase					"Importerar databas '%s'"
::import::mc::Line									"Rad"
::import::mc::Column									"Spalt"
::import::mc::GameNumber							"Parti"
::import::mc::ImportedGames						"%s partier importerade"
::import::mc::NoGamesImported						"Inga partier importerade"
::import::mc::FileIsEmpty							"Filen är kanske tom"
::import::mc::DatabaseImport						"Databas-import"
::import::mc::ImportPgnGame						"Importera PGN-parti"
::import::mc::ImportPgnVariation					"Importera PGN-variation"
::import::mc::ImportOK								"PGN-text importerad utan fel eller varningar."
::import::mc::ImportAborted						"Import avbruten."
::import::mc::TextIsEmpty							"PGN-text är tom."
::import::mc::AbortImport							"Avbryta PGN-import?"
::import::mc::UnsupportedVariant					"Varianten '%s' stöds inte, avvisades"
::import::mc::Accepted								"accepterat"
::import::mc::Rejected								"avvisat"

::import::mc::DifferentEncoding					"Den valda kodningen %src överensstämmer inte med filkodningen %dst."
::import::mc::DifferentEncodingDetails			"Databasen kan därefter inte omkoderas."
::import::mc::CannotDetectFigurineSet			"Kan inte hitta någon passande figuruppsättning."
::import::mc::TryAgainWithEnglishSet			"Try again with English figurines?" ;# NEW
::import::mc::TryAgainWithEnglishSetDetail	"It may be helpful to use English figurines, because this is standard in PGN." ;# NEW
::import::mc::CheckImportResult					"Kontrollera om den riktiga figuruppsättningen hittats: %s."
::import::mc::CheckImportResultDetail			"In seldom cases the auto-detection fails due to ambiguities."

::import::mc::UnsupportedVariant					"Unsuported variant rejected" ;# NEW
::import::mc::EnterOrPaste							"Ange eller klistra in ett %s i PGN-format i fönstret ovan.\nFel vid import av %s kommer att visas här."
::import::mc::EnterOrPaste-Game					"parti"
::import::mc::EnterOrPaste-Variation			"variation"

::import::mc::MissingWhitePlayerTag				"Vitspelare saknas"
::import::mc::MissingBlackPlayerTag				"Svartspelare saknas"
::import::mc::MissingPlayerTags					"Spelare saknas"
::import::mc::MissingResult						"Resultat saknas (i slutet av move section)"
::import::mc::MissingResultTag					"Resultat saknas (i tag section)"
::import::mc::InvalidRoundTag						"Ogiltig 'round tag'"
::import::mc::InvalidResultTag					"Ogiltig 'result tag'"
::import::mc::InvalidDateTag						"Ogiltig 'date tag'"
::import::mc::InvalidEventDateTag				"Ogiltig 'event date tag'"
::import::mc::InvalidTimeModeTag					"Ogiltig 'time mode tag'"
::import::mc::InvalidEcoTag						"Ogiltig 'ECO tag'"
::import::mc::InvalidTagName						"Ogiltig 'tag name' (ignored)"
::import::mc::InvalidCountryCode					"Ogiltig landskod"
::import::mc::InvalidRating						"Ogiltigt 'ratingtal'"
::import::mc::InvalidNag							"Ogiltig 'NAG'"
::import::mc::BraceSeenOutsideComment			"\"\}\" seen outisde a comment in game (ignored)"
::import::mc::MissingFen							"Ingen startposition funnen för det schack960 partiet; det är kommer behandlas som vanligt schack"
::import::mc::UnknownEventType					"Okänd tävlingstyp"
::import::mc::UnknownTitle							"Okänd titel(ignorerad)"
::import::mc::UnknownPlayerType					"Okänd spelartyp (ignorerad)"
::import::mc::UnknownSex							"Okänd kön (ignorerad)"
::import::mc::UnknownTermination					"Okänd avbrottsorsak"
::import::mc::UnknownMode							"Okänd modus"
::import::mc::RatingTooHigh						"Ratingtal för högt(ignorerad)"
::import::mc::EncodingFailed						"Encoding failed"
::import::mc::TooManyNags							"För många NAG's (latter ignored)"
::import::mc::IllegalCastling						"Otillåten rockad"
::import::mc::IllegalMove							"Ogiltigt drag"
::import::mc::CastlingCorrection					"Rockad korrigering"
::import::mc::DecodingFailed						"Partiet kunde inte avkodas"
::import::mc::ResultDidNotMatchHeaderResult	"Resultatet motsvarar inte resultatrubrik"
::import::mc::ValueTooLong							"Tagvärdet är för lång och kommer att avkortas till 255 tecken"
::import::mc::NotSuicideNotGiveaway				"Due to the outcome of the game the variant isn't either Suicide or Giveaway." ;# NEW
::import::mc::VariantChangedToGiveaway			"Due to the outcome of the game the variant has been changed to Giveaway" ;# NEW
::import::mc::VariantChangedToSuicide			"Due to the outcome of the game the variant has been changed to Suicide" ;# NEW
::import::mc::ResultCorrection					"Due to the final position of the game a correction of the result has been done" ;# NEW
::import::mc::MaximalErrorCountExceeded		"Fler än maximalt tillåtna fel. Inga fler fel (av tidigare typ) kommer att rapporteras"
::import::mc::MaximalWarningCountExceeded		"Fler än maximalt tillåtna varningar. Inga fler varningar (av tidigare typ) kommer att rapporteras"
::import::mc::InvalidToken							"Ogiltigt tecken"
::import::mc::InvalidMove							"Ogiltigt drag"
::import::mc::UnexpectedSymbol					"Oväntad symbol"
::import::mc::UnexpectedEndOfInput				"Oväntad end of input"
::import::mc::UnexpectedResultToken				"Oväntad resultattecken"
::import::mc::UnexpectedTag						"Oväntad tag inuti parti"
::import::mc::UnexpectedEndOfGame				"Oväntad slut av parti (saknar resultat)"
::import::mc::UnexpectedCastling					"Oväntad rockad (inte tillåten i den här schackvarianten)"
::import::mc::ContinuationsNotSupported		"'Continuations' not supported" ;# NEW
::import::mc::TagNameExpected						"Syntaxfel: Tag name expected"
::import::mc::TagValueExpected					"Syntaxfel: Tag value expected"
::import::mc::InvalidFen							"Ogiltig FEN"
::import::mc::UnterminatedString					"Obestämd sträng"
::import::mc::UnterminatedVariation				"Obestämd variation"
::import::mc::TooManyGames							"För många partier i databasen (avbrott)"
::import::mc::GameTooLong							"Partiet för långt (utelämnat)"
::import::mc::FileSizeExceeded					"Maximala filstorleken (2GB) kommer att överskridas (avbrott)"
::import::mc::TooManyPlayerNames					"För många spelarnamn i databasen (avbrott)"
::import::mc::TooManyEventNames					"För många tävlingsnamn i databasen (avbrott)"
::import::mc::TooManySiteNames					"För många platsnamn i databasen (avbrott)"
::import::mc::TooManyRoundNames					"För många rondnamn i databasen"
::import::mc::TooManyAnnotatorNames				"För många kommentatornamn i databasen (avbrott)"
::import::mc::TooManySourceNames					"För många källnamn i databasen (avbrott)"
::import::mc::SeemsNotToBePgnText				"Det här är ingen PGN-text."
::import::mc::AbortedDueToInternalError		"Avbrott på grund av internt fel."
::import::mc::AbortedDueToIoError				"Avbrott på grund av läs/skrivfel"
::import::mc::UserHasInterrupted					"Avbrutit av användare"

### export #############################################################
::export::mc::FileSelection				"&Filer"
::export::mc::OptionsSetup					"&Alternativ"
::export::mc::PageSetup						"&Utskriftsformat"
::export::mc::DiagramSetup					"&Diagramformat"
::export::mc::StyleSetup					"&Format"
::export::mc::EncodingSetup				"&Kodning"
::export::mc::TagsSetup						"&Taggar"
::export::mc::NotationSetup				"&Notation"
::export::mc::AnnotationSetup				"&Schacktecken"
::export::mc::CommentsSetup				"&Kommentarer"

::export::mc::Visibility					"Synlighet"
::export::mc::HideDiagrams					"Dölj diagram"
::export::mc::AllFromWhitePersp			"Allt från vits perspektiv"
::export::mc::AllFromBlackPersp			"Allt från svarts perspektiv"
::export::mc::ShowCoordinates				"Visa koordinater"
::export::mc::ShowSideToMove				"Visa vem som är vid draget"
::export::mc::ShowArrows					"Visa pilar"
::export::mc::ShowMarkers					"Visa markeringar"
::export::mc::Layout							"Layout"
::export::mc::PostscriptSpecials			"Postscript-specialiteter"
::export::mc::BoardSize						"Brädstorlek"

::export::mc::Short							"Kort"
::export::mc::Long							"Lång"
::export::mc::Algebraic						"Algebraisk"
::export::mc::Correspondence				"Korrespondens"
::export::mc::Telegraphic					"Telegrafisk"
::export::mc::FontHandling					"Fonthantering"
::export::mc::DiagramStyle					"Diagramstil"
::export::mc::UseImagesForDiagram		"Använd schabloner för diagramgenerering"
::export::mc::EmebedTruetypeFonts		"Bädda in TrueType-fonter"
::export::mc::UseBuiltinFonts				"Använd inbyggda fonter"
::export::mc::SelectExportedTags			"Val av exporterade taggar"
::export::mc::ExcludeAllTags				"Avmarkera allt"
::export::mc::IncludeAllTags				"Markera allt"
::export::mc::ExtraTags						"Alla andra extra taggar"
::export::mc::NoComments					"Ingen kommentar"
::export::mc::AllLanguages					"Alla språk"
::export::mc::Significant					"Signifikant"
::export::mc::LanguageSelection			"Val av språk"
::export::mc::MapTo							"Avbilda till"
::export::mc::MapNagsToComment			"Map annotations to comments"
::export::mc::UnusualAnnotation			"Unusual annotations"
::export::mc::AllAnnotation				"All annotations"
::export::mc::UseColumnStyle				"Use column style"
::export::mc::MainlineStyle				"Main Line Style"
::export::mc::HideVariations				"Dölj varianter"

::export::mc::PdfFiles						"PDF-filer"
::export::mc::HtmlFiles						"HTML-filer"
::export::mc::TeXFiles						"LaTeX-filer"

::export::mc::ExportDatabase				"Exportera databas"
::export::mc::ExportDatabaseVariant		"Export database - variant %s" ;# NEW
::export::mc::ExportDatabaseTitle		"Exportera databas '%s'"
::export::mc::ExportCurrentGameTitle	"Export Current Game" ;# NEW
::export::mc::ExportingDatabase			"Exporterar '%s' till filen '%s'"
::export::mc::Export							"Export"
::export::mc::NoGamesCopied				"Inga partier exporterade."
::export::mc::ExportedGames				"%s partier exporterade"
::export::mc::NoGamesForExport			"Inga partier att exportera."
::export::mc::ResetDefaults				"Återställ till standardvärden"
::export::mc::UnsupportedEncoding		"Kan inte använda kodning %s för PDF-dokument. Välj en alternativ kodning."
::export::mc::DatabaseIsOpen				"Destinations databasen '%s' är öppen, this means that the destination database will be emptied before the export is starting. Export anyway?" ;# NEW
::export::mc::DatabaseIsOpenDetail		"If you want to append instead you should use a Drag&Drop operation inside the database switcher." ;# NEW
::export::mc::ExportGamesFromTo			"Exporta partier från '%src' till '%dst'"
::export::mc::IllegalRejected				"%s game(s) rejected due to illegal moves" ;# NEW

::export::mc::BasicStyle					"Grundstil"
::export::mc::GameInfo						"Partiinfo"
::export::mc::GameText						"Partitext"
::export::mc::Moves							"Drag"
::export::mc::MainLine						"Huvudvariant"
::export::mc::Variation						"Variant"
::export::mc::Subvariation					"Sidovariant"
::export::mc::Figurines						"Figuruppsättning"
::export::mc::Hyphenation					"Avstavning"
::export::mc::None							"(ingen)"
::export::mc::Symbols						"Symboler"
::export::mc::Comments						"Kommentarer"
::export::mc::Result							"Resultat"
::export::mc::Diagram						"Diagram"
::export::mc::ColumnStyle					"Spaltformatering"

::export::mc::Paper							"Papper"
::export::mc::Orientation					"Orientering"
::export::mc::Margin							"Marginaler"
::export::mc::Format							"Format"
::export::mc::Size							"Storlek"
::export::mc::Custom							"Anpassad"
::export::mc::Potrait						"Stående"
::export::mc::Landscape						"Liggande"
::export::mc::Justification				"Justering"
::export::mc::Even							"Vänster och höger"
::export::mc::Columns						"Spalter"
::export::mc::One								"En"
::export::mc::Two								"Två"

::export::mc::DocumentStyle				"Dokumentstil"
::export::mc::Article						"Artikel"
::export::mc::Report							"Rapport"
::export::mc::Book							"Bok"

::export::mc::FormatName(scidb)			"Scidb"
::export::mc::FormatName(scid)			"Scid"
::export::mc::FormatName(pgn)				"PGN"
::export::mc::FormatName(pdf)				"PDF"
::export::mc::FormatName(html)			"HTML"
::export::mc::FormatName(tex)				"LaTeX"
::export::mc::FormatName(ps)				"Postscript"

::export::mc::Option(pgn,include_varations)						"Exportera varianter"
::export::mc::Option(pgn,include_comments)						"Exportera kommentarer"
::export::mc::Option(pgn,include_moveinfo)						"Exportera draginformationer (som kommentarer)"
::export::mc::Option(pgn,include_marks)							"Exportera markeringar (som kommentarer)"
::export::mc::Option(pgn,use_scidb_import_format)				"Använd Scidb-importformat"
::export::mc::Option(pgn,use_chessbase_format)					"Använd ChessBase-format"
::export::mc::Option(pgn,use_strict_pgn_standard				"Use PGN standard" ;# NEW
::export::mc::Option(pgn,include_ply_count_tag)					"Skriv tag 'PlyCount'"
::export::mc::Option(pgn,include_termination_tag)				"Skriv tag 'Termination'"
::export::mc::Option(pgn,include_mode_tag)						"Skriv tag 'Mode'"
::export::mc::Option(pgn,include_opening_tag)					"Skriv taggar 'Opening', 'Variation', 'Subvariation'"
::export::mc::Option(pgn,include_setup_tag)						"Skriv tag 'Setup' (om nödvändigt)"
::export::mc::Option(pgn,include_variant_tag)					"Skriv tag 'Variant' (om nödvändigt)"
::export::mc::Option(pgn,include_position_tag)					"Skriv tag 'Position' (om nödvändigt)"
::export::mc::Option(pgn,include_time_mode_tag)					"Skriv tag 'TimeMode' (om nödvändigt)"
::export::mc::Option(pgn,exclude_extra_tags)						"Uteslut extra taggar"
::export::mc::Option(pgn,indent_variations)						"Indrag för varianter"
::export::mc::Option(pgn,indent_comments)							"Indrag för kommentarer"
::export::mc::Option(pgn,column_style)								"Spaltformatering (ett drag per rad)"
::export::mc::Option(pgn,symbolic_annotation_style)			"Schacktecken(!, !?)"
::export::mc::Option(pgn,extended_symbolic_style)				"Utökade schacktecken(+=, +/-)"
::export::mc::Option(pgn,convert_null_moves)						"Skriv nolldrag som kommentarer"
::export::mc::Option(pgn,space_after_move_number)				"Infoga mellanslag efter dragnummer"
::export::mc::Option(pgn,shredder_fen)								"Använd Shredder-FEN (standard är X-FEN)"
::export::mc::Option(pgn,convert_lost_result_to_comment)		"Skriv kommentar för resultat '0-0'"
::export::mc::Option(pgn,write_any_rating_as_elo)				"Write any rating as ELO" ;# NEW
::export::mc::Option(pgn,append_mode_to_event_type)			"Lägg till modus efter tävlingstyp"
::export::mc::Option(pgn,comment_to_html)							"Skriv kommentar i HTML-format"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Uteslut partier med ogiltiga drag"
::export::mc::Option(pgn,use_utf8_encoding)						"Använd UTF-8 kodning"

### notation ###########################################################
::notation::mc::Notation		"Notation"

::notation::mc::MoveForm(alg)	"Algebraisk"
::notation::mc::MoveForm(san)	"Kort algebraisk"
::notation::mc::MoveForm(lan)	"Long algebraisk"
::notation::mc::MoveForm(eng)	"Engelskt"
::notation::mc::MoveForm(cor)	"Korrespondens"
::notation::mc::MoveForm(tel)	"Telegrafisk"

### figurine ###########################################################
::figurines::mc::Figurines	"Figuruppsättning"
::figurines::mc::Graphic	"Grafisk"
::figurines::mc::User		"Användardefinierad"

### save/replace #######################################################
::dialog::save::mc::SaveGame						"Spara partiet"
::dialog::save::mc::ReplaceGame					"Ersätt partiet"
::dialog::save::mc::EditCharacteristics		"Redigera egenskaper"
	
::dialog::save::mc::GameData						"Partidata"
::dialog::save::mc::Event							"Tävling"

::dialog::save::mc::MatchesExtraTags			"Matcher / Extra Taggar"
::dialog::save::mc::PressToSelect				"Tryck Ctrl+0 till Ctrl+9 (eller vänster musknapp) för att välja"
::dialog::save::mc::PressForWhole				"Tryck Alt-0 till Alt-9 (eller mellersta musknappen) för helt dataset"
::dialog::save::mc::EditTags						"Bearbeta taggar"
::dialog::save::mc::RemoveThisTag				"Radera tag '%s'?"
::dialog::save::mc::TagAlreadyExists			"Tagnamnet '%s' finns redan."
::dialog::save::mc::TagRemoved					"Extra tag '%s' (aktuellt värde: '%s') kommer att raderas."
::dialog::save::mc::TagNameIsReserved			"Tagnamnet '%s' är reserverat."
::dialog::save::mc::Locked							"Spärrad"
::dialog::save::mc::OtherTag						"Fler taggar"
::dialog::save::mc::NewTag							"Ny tag"
::dialog::save::mc::RemoveTag						"Radera tag"
::dialog::save::mc::SetToGameDate				"Ange partidatum"
::dialog::save::mc::SaveGameFailed				"Partiet kunde inte sparas."
::dialog::save::mc::SaveGameFailedDetail		"Se log för detaljer."
::dialog::save::mc::SavingGameLogInfo			"Sparar partiet (%vit - %svart, %tävling) i databasen '%base'"
::dialog::save::mc::CurrentBaseIsReadonly		"Aktuell databas '%s' är skrivskyddad."
::dialog::save::mc::CurrentGameHasTrialMode	"Aktuellt parti befinner sig i teststadiet och kan inte sparas."
::dialog::save::mc::OpenPlayerDictionary		"Open Player Dictionary" ;# NEW

::dialog::save::mc::LocalName						"&Lokalt namn"
::dialog::save::mc::EnglishName					"E&ngelskt namn"
::dialog::save::mc::ShowRatingType				"Visa &rating"
::dialog::save::mc::EcoCode						"&ECO-code"
::dialog::save::mc::Matches						"&Matcher"
::dialog::save::mc::Tags							"&Taggar"

::dialog::save::mc::Label(name)					"Namn"
::dialog::save::mc::Label(fideID)				"Fide-ID"
::dialog::save::mc::Label(value)					"Värde"
::dialog::save::mc::Label(title)					"Titel"
::dialog::save::mc::Label(rating)				"Rating"
::dialog::save::mc::Label(federation)			"Nation"
::dialog::save::mc::Label(country)				"Land"
::dialog::save::mc::Label(eventType)			"Typ"
::dialog::save::mc::Label(sex)					"Kön/Typ"
::dialog::save::mc::Label(date)					"Datum"
::dialog::save::mc::Label(eventDate)			"Tävlingsdatum"
::dialog::save::mc::Label(round)					"Rond"
::dialog::save::mc::Label(result)				"Resultat"
::dialog::save::mc::Label(termination)			"Avslutning"
::dialog::save::mc::Label(annotator)			"Kommentator"
::dialog::save::mc::Label(site)					"Plats"
::dialog::save::mc::Label(eventMode)			"Modus"
::dialog::save::mc::Label(timeMode)				"Tidsmodus"
::dialog::save::mc::Label(frequency)			"Frekvens"
::dialog::save::mc::Label(score)					"Second rating"

::dialog::save::mc::GameBase						"Partidatabas"
::dialog::save::mc::PlayerBase					"Spelardatabas"
::dialog::save::mc::EventBase						"Tävlingsdatabas"
::dialog::save::mc::SiteBase						"Platsdatabas"
::dialog::save::mc::AnnotatorBase				"Kommentatordatabas"
::dialog::save::mc::History						"Historik"

::dialog::save::mc::InvalidEntry					"'%s' är ingen giltig uppgift."
::dialog::save::mc::InvalidRoundEntry			"'%s' är ingen giltig ronduppgift."
::dialog::save::mc::InvalidRoundEntryDetail	"Giltiga ronduppgifter är '4' eller '6.1'. Noll som rondnummer är inte tillåten."
::dialog::save::mc::RoundIsTooHigh				"Rondnumret ska vara lägre än 256."
::dialog::save::mc::SubroundIsTooHigh			"Underrondnumret ska vara lägre än 256."
::dialog::save::mc::ImplausibleDate				"Datum för parti '%s' är tidigare än datum för tävling '%s'."
::dialog::save::mc::InvalidTagName				"Ogiltigt tagnamn '%s' (syntaxfel)."
::dialog::save::mc::Field							"Fält '%s': "
::dialog::save::mc::ExtraTag						"Extra tag '%s': "
::dialog::save::mc::InvalidNetworkAddress		"Ogiltig nätverksadress '%s'."
::dialog::save::mc::InvalidCountryCode			"Ogiltig landscode '%s'."
::dialog::save::mc::InvalidEventRounds			"Ogiltigt antal tävlingsronder '%s' (ska vara positivt heltal)."
::dialog::save::mc::InvalidPlyCount				"Ogiltigt antal drag '%s' (ska vara positivt heltal)."
::dialog::save::mc::IncorrectPlyCount			"Fel antal drag '%s' (rätt antal drag är %s)."
::dialog::save::mc::InvalidTimeControl			"Ogiltig tidskontrolluppgift i '%s'."
::dialog::save::mc::InvalidDate					"Ogiltigt datum '%s'."
::dialog::save::mc::InvalidYear					"Ogiltigt år '%s'."
::dialog::save::mc::InvalidMonth					"Ogiltig månad '%s'."
::dialog::save::mc::InvalidDay					"Ogiltig dag '%s'."
::dialog::save::mc::MissingYear					"Uppgift om år saknas."
::dialog::save::mc::MissingMonth					"Uppgift om månad saknas."
::dialog::save::mc::StringTooLong				"Tag %tag%: sträng '%value%' är för lång och kommer att förkortas till '%trunc%'."
::dialog::save::mc::InvalidEventDate			"Kan inte acceptera angivet tävlingsdatum: Skillnaden mellan året för partiet och året för tävlingen ska vara mindre än 4 (begränsning av Scid-databasformatet)."
::dialog::save::mc::TagIsEmpty					"Tag '%s' är tom (kommer att utsorteras)."

### gamehistory ########################################################
::game::history::mc::GameHistory		"Partihistoria"

### game ###############################################################
::game::mc::CloseDatabase					"Stäng databasen"
::game::mc::CloseAllGames					"Stäng alla öppna partier i databas '%s'?"
::game::mc::SomeGamesAreModified			"Några partier i databas '%s' har ändrats. Vill du stänga dem ändå?"
::game::mc::AllSlotsOccupied				"All game slots are occupied."
::game::mc::ReleaseOneGame					"Please release one of the games before loading a new one."
::game::mc::GameAlreadyOpen				"Partiet är redan öppnat men har ändrats. Discard modified version of this game?"
::game::mc::GameAlreadyOpenDetail		"'%s' kommer att öppna ett nytt parti."
::game::mc::GameHasChanged					"Parti %s har ändrats."
::game::mc::GameHasChangedDetail			"Probably this is not the expected game due to database changes."
::game::mc::CorruptedHeader				"Corrupted header in recovery file '%s'."
::game::mc::RenamedFile						"Filen har döpts om till '%s.bak'."
::game::mc::CannotOpen						"Kan inte öppna återställningfilen '%s'."
::game::mc::GameRestored					"Ett parti återställt från senaste session."
::game::mc::GamesRestored					"%s partier återställda från senaste session."
::game::mc::OldGameRestored				"Ett parti återställt."
::game::mc::OldGamesRestored				"%s partier återställda."
::game::mc::ErrorInRecoveryFile			"Fel i återställningsfilen '%s'"
::game::mc::Recovery							"Återställning"
::game::mc::UnsavedGames					"Det finns partiändringar som inte sparats."
::game::mc::DiscardChanges					"'%s' kommer att ta bort alla ändringar."
::game::mc::ShouldRestoreGame				"Ska detta parti återställas under nästa session?"
::game::mc::ShouldRestoreGames			"Ska dessa partier återställas under nästa session?"
::game::mc::NewGame							"Nytt parti"
::game::mc::NewGames							"Nya partier"
::game::mc::Created							"skapade"
::game::mc::ClearHistory					"Töm historik"
::game::mc::RemoveSelectedGame			"Ta bort valt parti från historien"
::game::mc::GameDataCorrupted				"Partidata är skadade."
::game::mc::GameDecodingFailed			"Partiet kunde inte avkodas."
::game::mc::GameDecodingChanged			"The database is opened with character set '%base%', but this game seems to be encoded with character set '%game%', therefore this game is loaded with the detected character set." ;# NEW
::game::mc::GameDecodingChangedDetail	"Probably you have opened the database with the wrong character set. Note that the automatic detection of the character set is limited." ;# NEW
::game::mc::VariantHasChanged				"Game cannot be opened because the variant of the database has changed and is now different from the game variant." ;# NEW
::game::mc::RemoveGameFromHistory		"Remove game from history?" ;# NEW
::game::mc::GameNumberDoesNotExist		"Game %number does not exist in '%base'."

### languagebox ########################################################
::languagebox::mc::AllLanguages	"Alla språk"
::languagebox::mc::None				"Inget"

### datebox ############################################################
::datebox::mc::Today		"Idag"
::datebox::mc::Calendar	"Kalender..."
::datebox::mc::Year		"År"
::datebox::mc::Month		"Månad"
::datebox::mc::Day		"Dag"

### genderbox ##########################################################
::genderbox::mc::Gender(m) "Man"
::genderbox::mc::Gender(f) "Kvinna"
::genderbox::mc::Gender(c) "Dator"

### terminationbox #####################################################
::terminationbox::mc::Normal								"Normalt"
::terminationbox::mc::Unplayed							"Inte spelat"
::terminationbox::mc::Abandoned							"Avbrutet"
::terminationbox::mc::Adjudication						"Avdömt"
::terminationbox::mc::Disconnection						"Disconnection" ;# NEW
::terminationbox::mc::Emergency							"Nödsituation"
::terminationbox::mc::RulesInfraction					"Regelbrott"
::terminationbox::mc::TimeForfeit						"Tidsöverskridning"
::terminationbox::mc::Unterminated						"Ej färdigspelat"

::terminationbox::mc::State(Checkmate)					"%s är matt"
::terminationbox::mc::State(Stalemate)					"%s är matt"
::terminationbox::mc::State(ThreeChecks)				"%s got three checks" ;# NEW
::terminationbox::mc::State(Losing)						"%s wins by losing all material" ;# NEW

::terminationbox::mc::Result(1-0)						"Svart gav upp"
::terminationbox::mc::Result(0-1)						"Vit gav upp"
::terminationbox::mc::Result(0-0)						"Förlust dömt för båda spelaren"
::terminationbox::mc::Result(1/2-1/2)					"Remi"

::terminationbox::mc::Reason(Unplayed)					"Parti är ospelat"
::terminationbox::mc::Reason(Abandoned)				"Parti är avbrutit"
::terminationbox::mc::Reason(Adjudication)			"Avdömt"
::terminationbox::mc::Reason(Disconnection)			"Disconnection" ;# NEW
::terminationbox::mc::Reason(Emergency)				"Avbrutit pga nödsituation"
::terminationbox::mc::Reason(RulesInfraction)		"Avdömt pga regelbrott"
::terminationbox::mc::Reason(TimeForfeit)				"%s tidsförlust"
::terminationbox::mc::Reason(TimeForfeit,both)		"Båda spelarna överskred tiden"
::terminationbox::mc::Reason(TimeForfeit,remis)		"%causer ran out of time and %opponent cannot win" ;# NEW
::terminationbox::mc::Reason(Unterminated)			"Ej färdigspelat"

::terminationbox::mc::Termination(equal-material)	"Game drawn by stalemate (equal material)" ;# NEW
::terminationbox::mc::Termination(less-material)	"%s wins by having less material (stalemate)"
::terminationbox::mc::Termination(bishops)			"Game drawn by stalemate (opposite color bishops)" ;# NEW
::terminationbox::mc::Termination(fifty)				"Game drawn by the 50 move rule" ;# NEW
::terminationbox::mc::Termination(threefold)			"Game drawn by threefold repetition" ;# NEW
::terminationbox::mc::Termination(nomating)			"Neither player has mating material" ;# NEW
::terminationbox::mc::Termination(nocheck)			"Neither player can give check" ;# NEW

### eventmodebox #######################################################
::eventmodebox::mc::OTB				"Vid bordet"
::eventmodebox::mc::PM				"Korrespondens"
::eventmodebox::mc::EM				"E-mail"
::eventmodebox::mc::ICS				"Internet Chess Server"
::eventmodebox::mc::TC				"Telekommunikation"
::eventmodebox::mc::Analysis		"Analys"
::eventmodebox::mc::Composition	"Komposition"

### eventtypebox #######################################################
::eventtypebox::mc::Type(game)	"Fristående parti"
::eventtypebox::mc::Type(match)	"Tävlingsparti"
::eventtypebox::mc::Type(tourn)	"Berger"
::eventtypebox::mc::Type(swiss)	"Schweizerturnering"
::eventtypebox::mc::Type(team)	"Lagtävling"
::eventtypebox::mc::Type(k.o.)	"Utslagstävling"
::eventtypebox::mc::Type(simul)	"Simultantävling"
::eventtypebox::mc::Type(schev)	"Scheveningen-System Tournament"  

### timemodebox ########################################################
::timemodebox::mc::Mode(normal)	"Normal"
::timemodebox::mc::Mode(rapid)	"Snabb"
::timemodebox::mc::Mode(blitz)	"Blixt"
::timemodebox::mc::Mode(bullet)	"Bullet"
::timemodebox::mc::Mode(corr)		"Korrespondens"

### help ###############################################################
::help::mc::Contents					"&Innehåll"
::help::mc::Index						"Inde&x"
::help::mc::CQL						"C&QL"
::help::mc::Search					"&Sök"

::help::mc::Help						"Hjälp"
::help::mc::MatchEntireWord		"Matcha hela ord"
::help::mc::MatchCase				"Matcha gemener/versaler"
::help::mc::TitleOnly				"Sök endast bland titlar"
::help::mc::CurrentPageOnly		"Sök endast på aktuell sida"
::help::mc::GoBack					"Gå bakåt en sida"
::help::mc::GoForward				"Gå framåt en sida"
::help::mc::GotoHome					"Go to top of page" ;# NEW
::help::mc::GotoEnd					"Go to end of page" ;# NEW
::help::mc::GotoPage					"Gå till sida '%s'"
::help::mc::ExpandAllItems			"Visa alla objekt"
::help::mc::CollapseAllItems		"Dölj alla objekt"
::help::mc::SelectLanguage			"Välj språk"
::help::mc::NoHelpAvailable		"Det finns inga hjälpfiler på engelska.\nVälj ett annat språk\nför hjälpdialogen."
::help::mc::NoHelpAvailableAtAll	"Inga hjälpfiler finns för detta ämne."
::help::mc::KeepLanguage			"Använd samma språk %s för kommande sessioner?"
::help::mc::ParserError				"Fel vid parsning av fil %s."
::help::mc::NoMatch					"Ingen träff"
::help::mc::MaxmimumExceeded		"För många träffar på somliga sidor."
::help::mc::OnlyFirstMatches		"Endast de första %s träffar per sida kommer att visas."
::help::mc::HideIndex				"Dölj index"
::help::mc::ShowIndex				"Visa index"

::help::mc::FileNotFound			"Hittar ej filen."
::help::mc::CantFindFile			"Kan inte hitta filen på %s."
::help::mc::IncompleteHelpFiles	"Det verkar som om hjälpfilerna är fortfarande ofullständiga. Vi beklagar."
::help::mc::ProbablyTheHelp		"Kanske kan hjälpsidan på ett annat språk vara ett alternativ för dig."
::help::mc::PageNotAvailable		"Denna sida är inte tillgänglig"

::help::mc::Overview					"Översikt"

### crosstable #########################################################
::crosstable::mc::TournamentTable			"Turneringstabell"
::crosstable::mc::AverageRating				"Genomsnittsranking"
::crosstable::mc::Category						"Kategori"
::crosstable::mc::Games							"Partier"
::crosstable::mc::Game							"Parti"

::crosstable::mc::ScoringSystem				"Poängsystem"
::crosstable::mc::Tiebreak						"Tie-Break"
::crosstable::mc::Settings						"Inställningar"
::crosstable::mc::RevertToStart				"Återgå till de ursprungliga värdena"
::crosstable::mc::UpdateDisplay				"Uppdatera displayen"
::crosstable::mc::SaveAsHTML					"Save as HTML file" ;# NEW

::crosstable::mc::Traditional					"Traditionellt"
::crosstable::mc::Bilbao						"Bilbao"

::crosstable::mc::None							"None"
::crosstable::mc::Buchholz						"Buchholz"
::crosstable::mc::MedianBuchholz				"Median-Buchholz"
::crosstable::mc::ModifiedMedianBuchholz	"Mod. Median-Buchholz"
::crosstable::mc::RefinedBuchholz			"Refined Buchholz"
::crosstable::mc::SonnebornBerger			"Sonneborn-Berger"
::crosstable::mc::Progressive					"Progressive Score"
::crosstable::mc::KoyaSystem					"Koya System"
::crosstable::mc::GamesWon						"Antal vinstpartier"
::crosstable::mc::GamesWonWithBlack			"Antal vinstpartier med svart"
::crosstable::mc::ParticularResult			"Particular Result"
::crosstable::mc::TraditionalScoring		"Traditional Scoring"

::crosstable::mc::Crosstable					"Korstabell"
::crosstable::mc::Scheveningen				"Scheveningen"
::crosstable::mc::Swiss							"Schweitzersystem"
::crosstable::mc::Match							"Match"
::crosstable::mc::Knockout						"Knockout"
::crosstable::mc::RankingList					"Rankinglista"

::crosstable::mc::Order						"Ordning"
::crosstable::mc::Type						"Tabelltyp"
::crosstable::mc::Score						"Poäng"
::crosstable::mc::Alphabetical			"Alfabetisk"
::crosstable::mc::Rating					"Rating"
::crosstable::mc::Federation				"Nation"

::crosstable::mc::Debugging					"Debugging"
::crosstable::mc::Display						"Display"
::crosstable::mc::Style							"Stil"
::crosstable::mc::Spacing						"Radavstånd"
::crosstable::mc::Padding						"Padding"
::crosstable::mc::ShowLog						"Visa log"
::crosstable::mc::ShowHtml						"Visa HTML"
::crosstable::mc::ShowRating					"Rating"
::crosstable::mc::ShowPerformance			"Prestation"
::crosstable::mc::ShowWinDrawLoss			"Vinst/Remi/Förlust"
::crosstable::mc::ShowTiebreak				"Tiebreak"
::crosstable::mc::ShowOpponent				"Motståndare (som Tooltip)"
::crosstable::mc::KnockoutStyle				"Knockout Table Style"
::crosstable::mc::Pyramid						"Pyramid"
::crosstable::mc::Triangle						"Trekant"

::crosstable::mc::CrosstableLimit			"Korstabellens maxantal av %d spelare kommer att överskridas."
::crosstable::mc::CrosstableLimitDetail	"'%s' väljer ett annat tabellformat."
::crosstable::mc::CannotOverwriteFile		"Cannot overwrite file '%s': permission denied." ;# NEW
::crosstable::mc::CannotCreateFile			"Cannot create file '%s': permission denied." ;# NEW

### info ###############################################################
::info::mc::InfoTitle			"Om %s"
::info::mc::Info					"Info"
::info::mc::About					"Om"
::info::mc::Contributions		"Bidrag"
::info::mc::License				"Licens"
::info::mc::Localization		"Localization"
::info::mc::Testing				"Testing"
::info::mc::References			"Referenser"
::info::mc::System				"System"
::info::mc::FontDesign			"Design av schackfonter"
::info::mc::ChessPieceDesign	"Design av schackpjäser"
::info::mc::BoardThemeDesign	"Design av schackbräden"
::info::mc::FlagsDesign			"Design av miniaturflaggor"
::info::mc::IconDesign			"Design av ikoner"
::info::mc::Development			"Utveckling"
::info::mc::Programming			"Programmering"
::info::mc::Head					"Head" ;# NEW

::info::mc::Version				"Version"
::info::mc::Distributed			"Det här programmet distribueras enligt bestämmelserna i GNU General Public License."
::info::mc::Inspired				"Scidb bygger på Scid 3.6.1, copyright \u00A9 1999-2003 by Shane Hudson."
::info::mc::SpecialThanks		"Särskilt tack till %s för ett fantastiska jobb. Hans insatser är grunden för detta program."

### comment ############################################################
::comment::mc::CommentBeforeMove		"Kommentar före draget"
::comment::mc::CommentAfterMove		"Kommentar efter draget"
::comment::mc::PrecedingComment		"Föregående kommentar"
::comment::mc::TrailingComment		"Efterföljande kommentar"
::comment::mc::Language					"Språk"
::comment::mc::AddLanguage				"Lägg till språk..."
::comment::mc::SwitchLanguage			"Byt språk"
::comment::mc::FormatText				"Formatera text"
::comment::mc::CopyText					"Kopiera text till"
::comment::mc::OverwriteContent		"Ersätta aktuellt innehåll?"
::comment::mc::AppendContent			"Ifall \"nej\" kommer texten att läggas till."

::comment::mc::LanguageSelection		"Val av språk"
::comment::mc::Formatting				"Formaterar"

::comment::mc::Bold						"Fet"
::comment::mc::Italic					"Kursivt"
::comment::mc::Underline				"Understruket"

::comment::mc::InsertSymbol			"&Infoga symbol..."
::comment::mc::MiscellaneousSymbols	"Diverse symboler"
::comment::mc::Figurine					"Figur"

### annotation #########################################################
::annotation::mc::AnnotationEditor					"Kommentarer"
::annotation::mc::TooManyNags							"För många kommentarer (den sista ignorerades)."
::annotation::mc::TooManyNagsDetail					"Maximalt %d kommentarer för varje halvdrag."

::annotation::mc::PrefixedCommentaries				"Kommentarer framför"
::annotation::mc::MoveAssesments						"Dragomdömen"
::annotation::mc::PositionalAssessments			"Positionella omdömen"
::annotation::mc::TimePressureCommentaries		"Tidsnödskommentarer"
::annotation::mc::AdditionalCommentaries			"Fler kommentarer"
::annotation::mc::ChessBaseCommentaries			"ChessBase-kommentarer"

### marks ##############################################################
::marks::mc::MarksPalette			"Markeringar - Palett"

### move ###############################################################
::move::mc::Action(replace)		"Ersätt drag"
::move::mc::Action(variation)		"Lägg till ny variant"
::move::mc::Action(mainline)		"Ny huvudvariant"
::move::mc::Action(trial)			"Försöksvariant"
::move::mc::Action(exchange)		"Byt drag"
::move::mc::Action(append)			"Lägg till drag"
::move::mc::Action(load)			"Ladda första parti med den här fortsättningen"

::move::mc::GameWillBeTruncated	"Partiet kommer att avkortas. Fortsätta med '%s'?"

### log ################################################################
::log::mc::LogTitle		"Log"
::log::mc::Warning		"Varning"
::log::mc::Error			"Fel"
::log::mc::Information	"Info"

### titlebox ############################################################
::titlebox::mc::None				"No title" ;# NEW
::titlebox::mc::Title(GM)		"Stormästare (FIDE)"
::titlebox::mc::Title(IM)		"Internationell mästare (FIDE)"
::titlebox::mc::Title(FM)		"Fide-mästare (FIDE)"
::titlebox::mc::Title(CM)		"Candidate Master (FIDE)"
::titlebox::mc::Title(WGM)		"Woman Grandmaster (FIDE)"
::titlebox::mc::Title(WIM)		"Woman International Master (FIDE)"
::titlebox::mc::Title(WFM)		"Woman Fide Master (FIDE)"
::titlebox::mc::Title(WCM)		"Woman Candidate Master (FIDE)"
::titlebox::mc::Title(HGM)		"Honorary Grandmaster (FIDE)"
::titlebox::mc::Title(NM)		"National Master (USCF)"
::titlebox::mc::Title(SM)		"Senior Master (USCF)"
::titlebox::mc::Title(LM)		"Life Master (USCF)"
::titlebox::mc::Title(CGM)		"Correspondence Grandmaster (ICCF)"
::titlebox::mc::Title(CIM)		"Correspondence International Master (ICCF)"
::titlebox::mc::Title(CLGM)	"Correspondence Lady Grandmaster (ICCF)"
::titlebox::mc::Title(CILM)	"Correspondence Lady International Master (ICCF)"
::titlebox::mc::Title(CSIM)	"Correspondence Senior International Master (ICCF)"

### messagebox #########################################################
::dialog::mc::Ok				"&OK"
::dialog::mc::Cancel			"&Avbryt"
::dialog::mc::Yes				"&Ja"
::dialog::mc::No				"&Nej"
::dialog::mc::Retry			"&Försök igen"
::dialog::mc::Abort			"&Avbryt"
::dialog::mc::Ignore			"&Ignorera"
::dialog::mc::Continue		"Forts&ätt"

::dialog::mc::Error			"Fel"
::dialog::mc::Warning		"Varning"
::dialog::mc::Information	"Information"
::dialog::mc::Question		"Bekräfta"

::dialog::mc::DontAskAgain	"Fråga inte fler gånger"

### web ################################################################
::web::mc::CannotFindBrowser			"Det gick inte att hitta en passande webbrowser."
::web::mc::CannotFindBrowserDetail	"Sätt omgivningsvariabeln BROWSER till den önskade browsern."

### colormenu ##########################################################
::colormenu::mc::BaseColor			"Grundfärg"
::colormenu::mc::UserColor			"Användarfärg"
::colormenu::mc::UsedColor			"Använd färg"
::colormenu::mc::RecentColor		"Senaste färg"
::colormenu::mc::Texture			"Texture"
::colormenu::mc::OpenColorDialog	"Öppna färgdialogen"
::colormenu::mc::EraseColor		"Ta bort färg"
::colormenu::mc::Close				"Stäng"

### table ##############################################################
::table::mc::Ok							"&Ok"
::table::mc::Cancel						"&Avbryt"
::table::mc::Column						"Spalt"
::table::mc::Table						"Tabell"
::table::mc::Configure					"Konfigurera"
::table::mc::Hide							"Dölj"
::table::mc::ShowColumn					"Visa spalt"
::table::mc::Foreground					"Förgrund"
::table::mc::Background					"Bakgrund"
::table::mc::DisabledForeground		"Borttagen förgrund"
::table::mc::SelectionForeground		"Val av förgrund"
::table::mc::SelectionBackground		"Val av bakgrund"
::table::mc::HighlightColor			"Markeringsfärg"
::table::mc::Stripes						"Streck"
::table::mc::MinWidth					"Minimal bredd"
::table::mc::MaxWidth					"Maximal bredd"
::table::mc::Separator					"Separator"
::table::mc::AutoStretchColumn		"Auto stretch column"
::table::mc::FillColumn					"- Fyllnadsspalt -"
::table::mc::Preview						"Förhandsgranskning"
::table::mc::OptimizeColumn			"Optimera spaltbredden"
::table::mc::OptimizeColumns			"Optimera alla spalter"
::table::mc::FitColumnWidth			"Anpassa spaltbredden"
::table::mc::FitColumns					"Anpassa alla spalter"
::table::mc::ExpandColumn				"Expandera kolumnbredd"
::table::mc::SqueezeColumns			"Tryck ihop alla spalter"
::table::mc::AccelFitColumns			"Ctrl+,"
::table::mc::AccelOptimizeColumns	"Ctrl+."
::table::mc::AccelSqueezeColumns		"Ctrl+#"

### fileselectionbox ###################################################
::dialog::fsbox::mc::ScidbDatabase			"Scidb databas"
::dialog::fsbox::mc::ScidDatabase			"Scid databas"
::dialog::fsbox::mc::ChessBaseDatabase		"ChessBase databas"
::dialog::fsbox::mc::PortableGameFile		"Flyttbar partifil"
::dialog::fsbox::mc::BughousePortableGameFile "Bughouse Portable Game File" ;# NEW
::dialog::fsbox::mc::ZipArchive				"ZIP arkiv"
::dialog::fsbox::mc::ScidbArchive			"Scidb arkiv"
::dialog::fsbox::mc::PortableDocumentFile	"Flyttbar dokumentfil"
::dialog::fsbox::mc::HypertextFile			"Hypertext fil"
::dialog::fsbox::mc::TypesettingFile		"Typesetting File"
::dialog::fsbox::mc::ImageFile				"Bildfil" ;# NEW
::dialog::fsbox::mc::TextFile					"Textfil"
::dialog::fsbox::mc::BinaryFile				"Binärfil"
::dialog::fsbox::mc::ShellScript				"Kommandoskript"
::dialog::fsbox::mc::Executable				"Körbar fil"

::dialog::fsbox::mc::LinkTo					"Länka till %s"
::dialog::fsbox::mc::LinkTarget				"Länkmål"
::dialog::fsbox::mc::Directory				"Folder"

::dialog::fsbox::mc::Title(open)				"Välj fil"
::dialog::fsbox::mc::Title(save)				"Spara fil"
::dialog::fsbox::mc::Title(dir)				"Välj folder"

::dialog::fsbox::mc::Content					"Innehåll"
::dialog::fsbox::mc::Open						"Öppna"

::dialog::fsbox::mc::FileType(exe)			"Körbara filer"
::dialog::fsbox::mc::FileType(txt)			"Textfiler"
::dialog::fsbox::mc::FileType(bin)			"Binärfiler"
::dialog::fsbox::mc::FileType(log)			"Logfiler"
::dialog::fsbox::mc::FileType(html)			"HTML files" ;# NEW

### choosecolor ########################################################
::dialog::choosecolor::mc::Ok					"&OK"
::dialog::choosecolor::mc::Cancel			"&Avbryt"

::dialog::choosecolor::mc::BaseColors		"Basfärger"
::dialog::choosecolor::mc::UserColors		"Använderpallett"
::dialog::choosecolor::mc::RecentColors	"Senaste färger"
::dialog::choosecolor::mc::Old				"Tidigare"
::dialog::choosecolor::mc::Current			"Aktuell"
::dialog::choosecolor::mc::HexCode			"Hexkod"
::dialog::choosecolor::mc::ColorSelection	"Färgval"
::dialog::choosecolor::mc::Red				"Rött"
::dialog::choosecolor::mc::Green				"Grönt"
::dialog::choosecolor::mc::Blue				"Blått"
::dialog::choosecolor::mc::Hue				"Färgton"
::dialog::choosecolor::mc::Saturation		"Färgmättnad"
::dialog::choosecolor::mc::Value				"Värde"
::dialog::choosecolor::mc::Enter				"Enter"
::dialog::choosecolor::mc::AddColor			"Lägg till aktuell färg till användarpallet"

### choosefont #########################################################
::dialog::choosefont::mc::Apply				"&Verkställ"
::dialog::choosefont::mc::Cancel				"&Avbryt"
::dialog::choosefont::mc::Continue			"Forts&ätt"
::dialog::choosefont::mc::FixedOnly			"&Enbart fonter med fast bredd"
::dialog::choosefont::mc::Family				"&Fonter"
::dialog::choosefont::mc::Font				"&Font"
::dialog::choosefont::mc::Ok					"&OK"
::dialog::choosefont::mc::Reset				"&Återställ"
::dialog::choosefont::mc::Size				"&Storlek"
::dialog::choosefont::mc::Strikeout			"Överstru&ket"
::dialog::choosefont::mc::Style				"S&til"
::dialog::choosefont::mc::Underline			"&Understryket"
::dialog::choosefont::mc::Color				"Fä&rg"

::dialog::choosefont::mc::Regular			"Normalt"
::dialog::choosefont::mc::Bold				"Fet"
::dialog::choosefont::mc::Italic				"Kursivt"
{::dialog::choosefont::mc::Bold Italic}	"Fet kursivt"

::dialog::choosefont::mc::Effects			"Effekter"
::dialog::choosefont::mc::Filter				"Filter"
::dialog::choosefont::mc::Sample				"Exempel"
::dialog::choosefont::mc::SearchTitle		"Söker efter fonter med fast bredd."
::dialog::choosefont::mc::SeveralMinutes	"Denna operation kan ta ungefär %d minuter."
::dialog::choosefont::mc::FontSelection	"Font Selection"
::dialog::choosefont::mc::Wait				"Vänta"

### choosedir ##########################################################
::choosedir::mc::ShowPredecessor	"Show Predecessor"
::choosedir::mc::ShowTail			"Show Tail"
::choosedir::mc::Folder				"Folder"

### fsbox ##############################################################
::fsbox::mc::Name								"Namn"
::fsbox::mc::Size								"Storlek"
::fsbox::mc::Modified						"Senast ändrad"

::fsbox::mc::Forward							"Framåt till '%s'"
::fsbox::mc::Backward						"Bakåt till '%s'"
::fsbox::mc::Delete							"Radera"
::fsbox::mc::MoveToTrash					"Flytta till papperskorgen"
::fsbox::mc::Restore							"Återställ"
::fsbox::mc::Duplicate						"Duplicera"
::fsbox::mc::CopyOf							"Kopia av %s"
::fsbox::mc::NewFolder						"Ny folder"
::fsbox::mc::Layout							"Layout"
::fsbox::mc::ListLayout						"Spaltlayout"
::fsbox::mc::DetailedLayout				"Detaljerad layout"
::fsbox::mc::ShowHiddenDirs				"Visa dolda foldrar"
::fsbox::mc::ShowHiddenFiles				"Visa dolda filer och foldrar"
::fsbox::mc::AppendToExisitingFile		"&Lägg till partier till en existerande fil"
::fsbox::mc::Cancel							"&Avbryt"
::fsbox::mc::Save								"&Spara"
::fsbox::mc::Open								"&Öppna"
::fsbox::mc::Overwrite						"&Skriv över"
::fsbox::mc::Rename							"&Byt namn"
::fsbox::mc::Move								"Flytta"

::fsbox::mc::AddBookmark					"Lägg till bokmärke '%s'"
::fsbox::mc::RemoveBookmark				"Ta bort bokmärke '%s'"
::fsbox::mc::RenameBookmark				"Byt namn på bokmärke '%s'"

::fsbox::mc::Filename						"Fil&namn:"
::fsbox::mc::Filenames						"Fil&namn:"
::fsbox::mc::Directory						"&Folder:" ;# NEW
::fsbox::mc::FilesType						"Filer av &typ:"
::fsbox::mc::FileEncoding					"Fil&kodning:"

::fsbox::mc::Favorites						"Favoriter"
::fsbox::mc::LastVisited					"Senast besökt"
::fsbox::mc::FileSystem						"Filsystem"
::fsbox::mc::Desktop							"Skrivbord"
::fsbox::mc::Trash							"Papperskorg"
::fsbox::mc::Home								"Hem"

::fsbox::mc::SelectEncoding				"Välj kodning av databas (öppnar en dialog)"
::fsbox::mc::SelectWhichType				"Välj vilken filtyp som ska visas"
::fsbox::mc::TimeFormat						"%Y-%m-%d %H:%M"

::fsbox::mc::CannotChangeDir				"Kan inte byta till foldern \"%s\".\nÅtkomst nekad."
::fsbox::mc::DirectoryRemoved				"Kan inte byta till foldern \"%s\".\nFoldern är borttagen."
::fsbox::mc::DeleteFailed					"Det gick inte att radera '%s'."
::fsbox::mc::RestoreFailed					"Det gick inte att återställa '%s'."
::fsbox::mc::CommandFailed					"Kommmandot '%s' misslyckades."
::fsbox::mc::CopyFailed						"Det gick inte att kopiera filen '%s': åtkomst nekad."
::fsbox::mc::CannotCopy						"Kan inte skapa en kopia, filen '%s' finns redan."
::fsbox::mc::CannotDuplicate				"Kan inte duplicera filen '%s'. Tillstånd att läsa saknas."
::fsbox::mc::ReallyDuplicateFile			"Är du säker att filen ska dupliceras?"
::fsbox::mc::ReallyDuplicateDetail		"Denna fil har omkring %s. Dupliceringen kan ta en stund."
::fsbox::mc::InvalidFileExt				"Operationen misslyckades: '%s' har ett ogiltigt filtilläggg."
::fsbox::mc::CannotRename					"Kan inte byta namn till '%s'. Det finns redan en folder/fil med det namnet."
::fsbox::mc::CannotCreate					"Kan inte skapa foldern '%s' Det finns redan en folder/fil med det namnet."
::fsbox::mc::ErrorCreate					"Fel vid skapande av folder: åtkomst nekad."
::fsbox::mc::FilenameNotAllowed			"Filnamnet '%s' är inte tillåtet."
::fsbox::mc::ContainsTwoDots				"Innehåller två punkter efter varandra."
::fsbox::mc::ContainsReservedChars		"Innehåller reserverade tecken: %s, eller ett kontrolltecken (ASCII 0-31)."
::fsbox::mc::InvalidFileName				"Ett filnamn kan inte börja med ett bindestreck och kan inte sluta med ett blanksteg eller en punkt."
::fsbox::mc::IsReservedName				"I somliga operativsystem är detta ett reserverad namn."
::fsbox::mc::FilenameTooLong				"Ett filnamn ska ha mindre än 256 tecken."
::fsbox::mc::InvalidFileExtension		"Ogiltigt filtillägg i '%s'."
::fsbox::mc::MissingFileExtension		"Inget filtillägg i '%s'."
::fsbox::mc::FileAlreadyExists			"Filen \"%s\" finns redan.\n\nVill du skriva över filen?"
::fsbox::mc::CannotOverwriteDirectory	"Kan inte skriva över folder '%s'."
::fsbox::mc::FileDoesNotExist				"Filen \"%s\" finns inte."
::fsbox::mc::DirectoryDoesNotExist		"Foldern \"%s\" finns inte."
::fsbox::mc::CannotOpenOrCreate			"Kan inte öppna/skapa '%s'. Var vänlig och välj en folder."
::fsbox::mc::WaitWhileDuplicating		"Var vänlig vänta, filen dupliceras..."
::fsbox::mc::FileHasDisappeared			"Filen '%s' är försvunnen."
::fsbox::mc::CurrentlyInUse				"Filen '%s' används."
::fsbox::mc::PermissionDenied				"Åtkomst nekad för foldern '%s'."
::fsbox::mc::CannotOpenUri					"Kan inte öppna följande  URI:"
::fsbox::mc::InvalidUri						"Innehåll som släpps är inte en giltig URI-lista."
::fsbox::mc::UriRejected					"Följande filer är förkastade:"
::fsbox::mc::UriRejectedDetail			"Bara listade filtyper kan behandlas."
::fsbox::mc::CannotOpenTrashFiles		"Kan inte öppna filer från papperskorgen:"
::fsbox::mc::CannotOpenRemoteFiles		"Kan inte öppna fjärrfiler:"
::fsbox::mc::OperationAborted				"Åtgärden avbröts."
::fsbox::mc::ApplyOnDirectories			"Är du säker på att du vill använda den valda åtgärden på (följande) folder?"
::fsbox::mc::EntryAlreadyExists			"Post finns redan"
::fsbox::mc::AnEntryAlreadyExists		"En post '%s' finns redan."
::fsbox::mc::SourceDirectoryIs			"Källfoldern är '%s'."
::fsbox::mc::NewName							"Nytt namn"

::fsbox::mc::ReallyMove(file,w)			"Är du säker att filen '%s' ska flyttas till papperskorgen?"
::fsbox::mc::ReallyMove(file,r)			"Är du säker att den skrivskyddade filen '%s' ska flyttas till papperskorgen?"
::fsbox::mc::ReallyMove(folder,w)		"Är du säker att foldern '%s' ska flyttas till papperskorgen?"
::fsbox::mc::ReallyMove(folder,r)		"Är du säker att den skrivskyddade foldern '%s' ska flyttas till papperskorgen?"
::fsbox::mc::ReallyDelete(file,w)		"Är du säker att filen '%s' ska raderas? Denna åtgärd kan inte ångras."
::fsbox::mc::ReallyDelete(file,r)		"Är du säker att den skrivskyddade filen '%s' ska raderas? Denna åtgärd kan inte ångras."
::fsbox::mc::ReallyDelete(link,w)		"Är du säker att länken till '%s' ska raderas?"
::fsbox::mc::ReallyDelete(link,r)		"Är du säker att länken till '%s' ska raderas?"
::fsbox::mc::ReallyDelete(folder,w)		"Är du säker att folder '%s'ska raderas? Denna åtgärd kan inte ångras."
::fsbox::mc::ReallyDelete(folder,r)		"Är du säker att den skrivskyddade foldern '%s' ska raderas? Denna åtgärd kan inte ångras."

::fsbox::mc::ErrorRenaming(folder)		"Fel vid namnbyte av foldern '%old' till '%new': åtkomst nekad."
::fsbox::mc::ErrorRenaming(file)			"Fel vid namnbyte av filen '%old' till '%new': åtkomst nekad."

::fsbox::mc::Cannot(delete)				"Kan inte radera filen '%s'."
::fsbox::mc::Cannot(rename)				"Kan inte byta namn på filen '%s'."
::fsbox::mc::Cannot(move)					"Kan inte flytta filen '%s'."
::fsbox::mc::Cannot(overwrite)			"Kan inte skriva över filen '%s'."

::fsbox::mc::DropAction(move)				"Flytta hit"
::fsbox::mc::DropAction(copy)				"Kopiera hit"
::fsbox::mc::DropAction(link)				"Länka hit"

### toolbar ############################################################
::toolbar::mc::Toolbar		"Verktygsfält"
::toolbar::mc::Orientation	"Orientering"
::toolbar::mc::Alignment	"Anpassning"
::toolbar::mc::IconSize		"Ikonstorlek"

::toolbar::mc::Default		"Standard"
::toolbar::mc::Small			"Liten"
::toolbar::mc::Medium		"Medium"
::toolbar::mc::Large			"Stor"

::toolbar::mc::Top			"Överst"
::toolbar::mc::Bottom		"Nederst"
::toolbar::mc::Left			"Vänster"
::toolbar::mc::Right			"Höger"
::toolbar::mc::Center		"Centrerad"

::toolbar::mc::Flat			"Flat"
::toolbar::mc::Floating		"Svävande"
::toolbar::mc::Hide			"Dold"

::toolbar::mc::Expand		"Expandera"

### Countries ##########################################################
::country::mc::Afghanistan											"Afghanistan"
::country::mc::Netherlands_Antilles								"Nederländska antillerna"
::country::mc::Anguilla												"Anguilla"
::country::mc::Aboard_Aircraft									"Ombord flygplan"
::country::mc::Aaland_Islands										"Åland"
::country::mc::Albania												"Albanien"
::country::mc::Algeria												"Algeriet"
::country::mc::Andorra												"Andorra"
::country::mc::Angola												"Angola"
::country::mc::Antigua												"Antigua och Barbuda"
::country::mc::Australasia											"Australasia"
::country::mc::Argentina											"Argentina"
::country::mc::Armenia												"Armenien"
::country::mc::Aruba													"Aruba"
::country::mc::American_Samoa										"Amerikanska Samoa"
::country::mc::Antarctica											"Antarktis"
::country::mc::French_Southern_Territories					"Franska sydterritorierna"
::country::mc::Australia											"Australien"
::country::mc::Austria												"Österrike"
::country::mc::Azerbaijan											"Azerbajdzjan"
::country::mc::Bahamas												"Bahamas"
::country::mc::Bangladesh											"Bangladesh"
::country::mc::Barbados												"Barbados"
::country::mc::Basque												"Baskien"
::country::mc::Burundi												"Burundi"
::country::mc::Belgium												"Belgien"
::country::mc::Benin													"Benin"
::country::mc::Bermuda												"Bermudas"
::country::mc::Bhutan												"Bhutan"
::country::mc::Bosnia_and_Herzegovina							"Bosnien och Herzegovina"
::country::mc::Belize												"Belize"
::country::mc::Belarus												"Vitryssland"
::country::mc::Bolivia												"Bolivia"
::country::mc::Brazil												"Brasilien"
::country::mc::Bahrain												"Bahrain"
::country::mc::Brunei												"Brunei"
::country::mc::Botswana												"Botswana"
::country::mc::Bulgaria												"Bulgarien"
::country::mc::Burkina_Faso										"Burkina Faso"
::country::mc::Bouvet_Islands										"Bouvetön"
::country::mc::Central_African_Republic						"Centralafrikanska republiken"
::country::mc::Cambodia												"Kambodja"
::country::mc::Canada												"Kanada"
::country::mc::Catalonia											"Katalonien"
::country::mc::Cayman_Islands										"Caymanöarna"
::country::mc::Cocos_Islands										"Cocosöarna"
::country::mc::Congo													"Kongo (Brazzaville)"
::country::mc::Chad													"Tchad"
::country::mc::Chile													"Chile"
::country::mc::China													"Kina"
::country::mc::Ivory_Coast											"Elfenbenskusten"
::country::mc::Cameroon												"Kamerun"
::country::mc::DR_Congo												"DR Kongo"
::country::mc::Cook_Islands										"Cooköarna"
::country::mc::Colombia												"Colombia"
::country::mc::Comoros												"Comoros"
::country::mc::Cape_Verde											"Cape Verde"
::country::mc::Costa_Rica											"Costa Rica"
::country::mc::Croatia												"Kroatien"
::country::mc::Cuba													"Kuba"
::country::mc::Christmas_Island									"Christmas Island"
::country::mc::Cyprus												"Cypern"
::country::mc::Czech_Republic										"Tjeckien"
::country::mc::Denmark												"Danmark"
::country::mc::Djibouti												"Djibouti"
::country::mc::Dominica												"Dominica"
::country::mc::Dominican_Republic								"Dominikanska republiken"
::country::mc::Ecuador												"Ecuador"
::country::mc::Egypt													"Egypten"
::country::mc::England												"England"
::country::mc::Eritrea												"Eritrea"
::country::mc::El_Salvador											"El Salvador"
::country::mc::Western_Sahara										"Västsahara"
::country::mc::Spain													"Spanien"
::country::mc::Estonia												"Estland"
::country::mc::Ethiopia												"Ethiopien"
::country::mc::Faroe_Islands										"Färöarna"
::country::mc::Fiji													"Fiji"
::country::mc::Finland												"Finland"
::country::mc::Falkland_Islands									"Falklandsöarna"
::country::mc::France												"Frankrike"
::country::mc::West_Germany										"Västtyskland"
::country::mc::Micronesia											"Micronesia"
::country::mc::Gabon													"Gabon"
::country::mc::Gambia												"Gambia"
::country::mc::Great_Britain										"Storbritannien"
::country::mc::Guinea_Bissau										"Guinea-Bissau"
::country::mc::Gibraltar											"Gibraltar"
::country::mc::Guernsey												"Guernsey"
::country::mc::East_Germany										"Östtyskland"
::country::mc::Georgia												"Georgia"
::country::mc::Equatorial_Guinea									"Equatorial Guinea"
::country::mc::Germany												"Tyskland"
::country::mc::Ghana													"Ghana"
::country::mc::Guadeloupe											"Guadeloupe"
::country::mc::Greece												"Grekland"
::country::mc::Grenada												"Grenada"
::country::mc::Greenland											"Grönland"
::country::mc::Guatemala											"Guatemala"
::country::mc::French_Guiana										"Franska Guyana"
::country::mc::Guinea												"Guinea"
::country::mc::Guam													"Guam"
::country::mc::Guyana												"Guyana"
::country::mc::Haiti													"Haiti"
::country::mc::Hong_Kong											"Hong Kong"
::country::mc::Heard_Island_and_McDonald_Islands			"Heard Island and McDonald Islands"
::country::mc::Honduras												"Honduras"
::country::mc::Hungary												"Ungern"
::country::mc::Isle_of_Man											"Isle of Man"
::country::mc::Indonesia											"Indonesien"
::country::mc::India													"Indien"
::country::mc::British_Indian_Ocean_Territory				"British Indian Ocean Territory"
::country::mc::Iran													"Iran"
::country::mc::Ireland												"Irland"
::country::mc::Iraq													"Irak"
::country::mc::Iceland												"Island"
::country::mc::Israel												"Israel"
::country::mc::Italy													"Italien"
::country::mc::British_Virgin_Islands							"British Virgin Islands"
::country::mc::Jamaica												"Jamaica"
::country::mc::Jersey												"Jersey"
::country::mc::Jordan												"Jordanien"
::country::mc::Japan													"Japan"
::country::mc::Kazakhstan											"Kazakhstan"
::country::mc::Kenya													"Kenya"
::country::mc::Kosovo												"Kosovo"
::country::mc::Kyrgyzstan											"Kirgistan"
::country::mc::Kiribati												"Kiribati"
::country::mc::South_Korea											"Sydkorea"
::country::mc::Saudi_Arabia										"Saudiarabien"
::country::mc::Kuwait												"Kuwait"
::country::mc::Laos													"Laos"
::country::mc::Latvia												"Lettland"
::country::mc::Libya													"Libyen"
::country::mc::Liberia												"Liberia"
::country::mc::Saint_Lucia											"Saint Lucia"
::country::mc::Lesotho												"Lesotho"
::country::mc::Lebanon												"Libanon"
::country::mc::Liechtenstein										"Liechtenstein"
::country::mc::Lithuania											"Litauen"
::country::mc::Luxembourg											"Luxemburg"
::country::mc::Macao													"Macao"
::country::mc::Madagascar											"Madagaskar"
::country::mc::Morocco												"Marokko"
::country::mc::Malaysia												"Malaysia"
::country::mc::Malawi												"Malawi"
::country::mc::Moldova												"Moldavien"
::country::mc::Maldives												"Maldiverna"
::country::mc::Mexico												"Mexiko"
::country::mc::Mongolia												"Mongoliet"
::country::mc::Marshall_Islands									"Marshall Islands"
::country::mc::Macedonia											"Makedonien"
::country::mc::Mali													"Mali"
::country::mc::Malta													"Malta"
::country::mc::Montenegro											"Montenegro"
::country::mc::Northern_Mariana_Islands						"Northern Mariana Islands"
::country::mc::Monaco												"Monaco"
::country::mc::Mozambique											"Mozambique"
::country::mc::Mauritius											"Mauritius"
::country::mc::Montserrat											"Montserrat"
::country::mc::Mauritania											"Mauritanien"
::country::mc::Martinique											"Martinique"
::country::mc::Myanmar												"Myanmar"
::country::mc::Mayotte												"Mayotte"
::country::mc::Namibia												"Namibia"
::country::mc::Nicaragua											"Nicaragua"
::country::mc::New_Caledonia										"New Caledonia"
::country::mc::Netherlands											"Nederländerna"
::country::mc::Nepal													"Nepal"
::country::mc::The_Internet										"The Internet"
::country::mc::Norfolk_Island										"Norfolk Island"
::country::mc::Nigeria												"Nigeria"
::country::mc::Niger													"Niger"
::country::mc::Northern_Ireland									"Nordirland"
::country::mc::Niue													"Niue"
::country::mc::Norway												"Norge"
::country::mc::Nauru													"Nauru"
::country::mc::New_Zealand											"Nya Zealand"
::country::mc::Oman													"Oman"
::country::mc::Pakistan												"Pakistan"
::country::mc::Panama												"Panama"
::country::mc::Paraguay												"Paraguay"
::country::mc::Pitcairn_Islands									"Pitcairn Islands"
::country::mc::Peru													"Peru"
::country::mc::Philippines											"Philippines"
::country::mc::Palestine											"Palestinien"
::country::mc::Palau													"Palau"
::country::mc::Papua_New_Guinea									"Papua Nya Guinea"
::country::mc::Poland												"Polen"
::country::mc::Portugal												"Portugal"
::country::mc::North_Korea											"Nordkorea"
::country::mc::Puerto_Rico											"Puerto Rico"
::country::mc::French_Polynesia									"Franska Polynesien"
::country::mc::Qatar													"Qatar"
::country::mc::Reunion												"Reunion"
::country::mc::Romania												"Rumänien"
::country::mc::South_Africa										"Sydafrika"
::country::mc::Russia												"Ryssland"
::country::mc::Rwanda												"Rwanda"
::country::mc::Samoa													"Samoa"
::country::mc::Serbia_and_Montenegro							"Serbien och Montenegro"
::country::mc::Scotland												"Skottland"
::country::mc::At_Sea												"Till sjöss"
::country::mc::Senegal												"Senegal"
::country::mc::Seychelles											"Seychellerna"
::country::mc::South_Georgia_and_South_Sandwich_Islands	"South Georgia and South Sandwich Islands"
::country::mc::Saint_Helena										"Saint Helena"
::country::mc::Singapore											"Singapore"
::country::mc::Jan_Mayen_and_Svalbard							"Svalbard och Jan Mayen"
::country::mc::Saint_Kitts_and_Nevis							"Saint Kitts and Nevis"
::country::mc::Sierra_Leone										"Sierra Leone"
::country::mc::Slovenia												"Slovenien"
::country::mc::San_Marino											"San Marino"
::country::mc::Solomon_Islands									"Solomon Islands"
::country::mc::Somalia												"Somalia"
::country::mc::Aboard_Spacecraft									"Ombord rymdskepp"
::country::mc::Saint_Pierre_and_Miquelon						"Saint Pierre and Miquelon"
::country::mc::Serbia												"Serbien"
::country::mc::Sri_Lanka											"Sri Lanka"
::country::mc::Sao_Tome_and_Principe							"Sao Tome and Principe"
::country::mc::Sudan													"Sudan"
::country::mc::Switzerland											"Schweiz"
::country::mc::Suriname												"Suriname"
::country::mc::Slovakia												"Slovakien"
::country::mc::Sweden												"Sverige"
::country::mc::Swaziland											"Swaziland"
::country::mc::Syria													"Syrien"
::country::mc::Tanzania												"Tanzania"
::country::mc::Turks_and_Caicos_Islands						"Turks and Caicos Islands"
::country::mc::Czechoslovakia										"Tjeckoslovakien"
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
::country::mc::Tunisia												"Tunisien"
::country::mc::Turkey												"Turkiet"
::country::mc::Tuvalu												"Tuvalu"
::country::mc::United_Arab_Emirates								"Förenade Arabaemiraten"
::country::mc::Uganda												"Uganda"
::country::mc::Ukraine												"Ukraina"
::country::mc::United_States_Minor_Outlying_Islands		"United States Minor Outlying Islands"
::country::mc::Unknown												"(Okänd)"
::country::mc::Soviet_Union										"Sovjetunionen"
::country::mc::Uruguay												"Uruguay"
::country::mc::United_States_of_America						"USA"
::country::mc::Uzbekistan											"Uzbekistan"
::country::mc::Vanuatu												"Vanuatu"
::country::mc::Vatican												"Vatikan"
::country::mc::Venezuela											"Venezuela"
::country::mc::Vietnam												"Vietnam"
::country::mc::Saint_Vincent_and_the_Grenadines				"Saint Vincent and the Grenadines"
::country::mc::US_Virgin_Islands									"US Virgin Islands"
::country::mc::Wallis_and_Futuna									"Wallis and Futuna"
::country::mc::Wales													"Wales"
::country::mc::Yemen													"Yemen"
::country::mc::Yugoslavia											"Jugoslavien"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzibar"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Mixed Team"

::country::mc::Africa_North										"Nordafrika"
::country::mc::Africa_Sub_Saharan								"Afrika, Sub-Sahara"
::country::mc::America_Caribbean									"Amerika, Caribbean"
::country::mc::America_Central									"Centralamerika"
::country::mc::America_North										"Nordamerika"
::country::mc::America_South										"Sydamerika"
::country::mc::Antarctic											"Antarktik"
::country::mc::Asia_East											"Östasien"
::country::mc::Asia_South_South_East							"Sydöstasien"
::country::mc::Asia_West_Central									"Väst-/Centralasien"
::country::mc::Europe												"Europa"
::country::mc::Europe_East											"Östeuropa"
::country::mc::Oceania												"Oceanien"
::country::mc::Stateless											"Statslös"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"Afrikaans"
::encoding::mc::Lang(ar)	"Arabiska"
::encoding::mc::Lang(ast)	"Leonesiska"
::encoding::mc::Lang(az)	"Azerbajdzjanska"
::encoding::mc::Lang(bat)	"Baltic"
::encoding::mc::Lang(be)	"Belarusian"
::encoding::mc::Lang(bg)	"Bulgarian"
::encoding::mc::Lang(br)	"Breton"
::encoding::mc::Lang(bs)	"Bosnian"
::encoding::mc::Lang(ca)	"Catalan"
::encoding::mc::Lang(cs)	"Tjeckiska"
::encoding::mc::Lang(cy)	"Welsh"
::encoding::mc::Lang(da)	"Danska"
::encoding::mc::Lang(de)	"Tyska"
::encoding::mc::Lang(de+)	"Deutsch (reformed)" ;# NEW
::encoding::mc::Lang(el)	"Grekiska"
::encoding::mc::Lang(en)	"Engelska"
::encoding::mc::Lang(eo)	"Esperanto"
::encoding::mc::Lang(es)	"Spanska"
::encoding::mc::Lang(et)	"Estniska"
::encoding::mc::Lang(eu)	"Basque"
::encoding::mc::Lang(fi)	"Finska"
::encoding::mc::Lang(fo)	"Faroese"
::encoding::mc::Lang(fr)	"Franska"
::encoding::mc::Lang(fy)	"Frisian"
::encoding::mc::Lang(ga)	"Irish"
::encoding::mc::Lang(gd)	"Scottish"
::encoding::mc::Lang(gl)	"Galician"
::encoding::mc::Lang(he)	"Hebrew"
::encoding::mc::Lang(hi)	"Hindi"
::encoding::mc::Lang(hr)	"Croatian"
::encoding::mc::Lang(hu)	"Ungerska"
::encoding::mc::Lang(hy)	"Armenian"
::encoding::mc::Lang(ia)	"Interlingua"
::encoding::mc::Lang(id)	"Indonesian" ;# NEW
::encoding::mc::Lang(is)	"Isländska"
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
::encoding::mc::Lang(no)	"Norska"
::encoding::mc::Lang(oc)	"Occitan"
::encoding::mc::Lang(pl)	"Polska"
::encoding::mc::Lang(pt)	"Portuguese"
::encoding::mc::Lang(rm)	"Romansh"
::encoding::mc::Lang(ro)	"Romanian"
::encoding::mc::Lang(ru)	"Ryska"
::encoding::mc::Lang(se)	"Sami"
::encoding::mc::Lang(sk)	"Slovak"
::encoding::mc::Lang(sl)	"Slovenian"
::encoding::mc::Lang(sq)	"Albanian"
::encoding::mc::Lang(sr)	"Serbiska"
::encoding::mc::Lang(sv)	"Svenska"
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
::encoding::mc::Lang(hsb)	"Upper Sorbian"
::encoding::mc::Lang(dsb)	"Lower Sorbian"
::encoding::mc::Lang(zh)	"Chinese"

::encoding::mc::Font(hi)	"Devanagari"

### Calendar ###########################################################
::calendar::mc::OneMonthForward	"En månad framåt(Shift \u2192)"
::calendar::mc::OneMonthBackward	"En månad bakåt(Shift \u2190)"
::calendar::mc::OneYearForward	"Ett år framåt (Ctrl \u2192)"
::calendar::mc::OneYearBackward	"Ett år bakåt(Ctrl \u2190)"

::calendar::mc::Su	"Sö"
::calendar::mc::Mo	"Må"
::calendar::mc::Tu	"Ti"
::calendar::mc::We	"On"
::calendar::mc::Th	"To"
::calendar::mc::Fr	"Fr"
::calendar::mc::Sa	"Lö"

::calendar::mc::Jan	"Jan"
::calendar::mc::Feb	"Feb"
::calendar::mc::Mar	"Mar"
::calendar::mc::Apr	"Apr"
::calendar::mc::May	"Maj"
::calendar::mc::Jun	"Jun"
::calendar::mc::Jul	"Jul"
::calendar::mc::Aug	"Aug"
::calendar::mc::Sep	"Sep"
::calendar::mc::Oct	"Okt"
::calendar::mc::Nov	"Nov"
::calendar::mc::Dec	"Dec"

::calendar::mc::MonthName(1)		"Januari"
::calendar::mc::MonthName(2)		"Februari"
::calendar::mc::MonthName(3)		"Mars"
::calendar::mc::MonthName(4)		"April"
::calendar::mc::MonthName(5)		"Maj"
::calendar::mc::MonthName(6)		"Juni"
::calendar::mc::MonthName(7)		"Juli"
::calendar::mc::MonthName(8)		"Augusti"
::calendar::mc::MonthName(9)		"September"
::calendar::mc::MonthName(10)		"Oktober"
::calendar::mc::MonthName(11)		"November"
::calendar::mc::MonthName(12)		"December"

::calendar::mc::WeekdayName(0)	"Söndag"
::calendar::mc::WeekdayName(1)	"Måndag"
::calendar::mc::WeekdayName(2)	"Tisdag"
::calendar::mc::WeekdayName(3)	"Onsdag"
::calendar::mc::WeekdayName(4)	"Torsdag"
::calendar::mc::WeekdayName(5)	"Fredag"
::calendar::mc::WeekdayName(6)	"Lördag"

### remote #############################################################
::remote::mc::PostponedMessage "Databasen \"%s\" kommer inte att öppnas förrän den pågående operationen är avslutad."

# vi:set ts=3 sw=3:
