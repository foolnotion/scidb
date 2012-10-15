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
# Copyright: (C) 2011-2012 Giovanni Ornaghi
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
::mc::SortMapping		{Å A å a à a À A è e È E é e É E ì i Ì i ò o Ò O ù u Ù U}
::mc::AsciiMapping	{Å A à a À A å a è e È E é e É E ì i Ì i  ò o Ò O ù u Ù U}
::mc::SortOrder		{A À Å B C D E È É F G H I Ì J K L M N O Ò P Q R S T U Ù V W X Y Z a à å b c d e è é f g h i ì j k l m n o ò p q r s t u ù v w x y z}

::mc::Key(Alt)			"Alt"
::mc::Key(Ctrl)		"Ctrl"
::mc::Key(Down)		"\u2193"
::mc::Key(End)			"Fine"
::mc::Key(Esc)			"Esci"
::mc::Key(Home)		"Home"
::mc::Key(Left)		"\u2190"
::mc::Key(Next)		"Page\u2193"
::mc::Key(Prior)		"Page\u2191"
::mc::Key(Right)		"\u2192"
::mc::Key(Shift)		"Shift"
::mc::Key(Up)			"\u2191"

::mc::Alignment		"Allineamento"
::mc::Apply				"Applica"
::mc::Archive			"Archivio"
::mc::Background		"Sfondo"
::mc::Black				"Nero"
::mc::Bottom			"Basso"
::mc::Cancel			"Annulla"
::mc::Clear				"Pulisci"
::mc::Close				"Chiudi"
::mc::Color				"Colore"
::mc::Colors			"Colori"
::mc::Configuration	"Configurazione"
::mc::Copy				"Copia"
::mc::Cut				"Taglia"
::mc::Dark				"Scura"
::mc::Database			"Database"
::mc::Default			"Default"
::mc::Delete			"Elimina"
::mc::Edit				"Modifica"
::mc::File				"File" ;# NEW
::mc::From				"Da"
::mc::Game				"Partita"
::mc::Layout			"Layout"
::mc::Left				"Sinistra"
::mc::Lite				"Chiara"
::mc::Low				"Low" ;# NEW
::mc::Modify			"Cambia"
::mc::No					"no"
::mc::Normal			"Normal" ;# NEW
::mc::NotAvailable	"n/a"
::mc::Number			"Numero"
::mc::OK					"OK"
::mc::Order				"Ordine"
::mc::Paste				"Incolla"
::mc::PieceSet			"Set di Pezzi"
::mc::Preview			"Anteprima"
::mc::Redo				"Rifai"
::mc::Remove			"Rimuovi"
::mc::Reset				"Reset"
::mc::Right				"Destra"
::mc::SelectAll		"Seleziona Tutto"
::mc::Texture			"Texture"
::mc::Theme				"Tema"
::mc::To					"A"
::mc::Top				"Alto"
::mc::Undo				"Indietro"
::mc::Variation		"Variante"
::mc::White				"Bianco"
::mc::Yes				"sì"

::mc::LogicalReset	"Reset"
::mc::LogicalAnd		"AND"
::mc::LogicalOr		"OR"
::mc::LogicalNot		"NOT"

::mc::King				"Re"
::mc::Queen				"Donna"
::mc::Rook				"Torre"
::mc::Bishop			"Alfiere"
::mc::Knight			"Cavallo"
::mc::Pawn				"Pedone"

### scidb ##############################################################
::scidb::mc::CannotOverwriteTheme	"Impossibile sovrascrivere il tema %s."

### locale #############################################################
::locale::Pattern(decimalPoint)	"."
::locale::Pattern(thousandsSep)	","
::locale::Pattern(dateY)			"Y"
::locale::Pattern(dateM)			"M Y"
::locale::Pattern(dateD)			"D M, Y"
::locale::Pattern(time)				"D M, Y, h:m"
::locale::Pattern(normal:dateY)	"Y"
::locale::Pattern(normal:dateM)	"M/Y"
::locale::Pattern(normal:dateD)	"D/M/Y"

### widget #############################################################
::widget::mc::Apply		"&Applica"
::widget::mc::Cancel		"&Cancella"
::widget::mc::Clear		"P&ulisci"
::widget::mc::Close		"C&hiudi"
::widget::mc::Ok			"&OK"
::widget::mc::Reset		"&Reset"
::widget::mc::Update		"A&ggiorna"
::widget::mc::Import		"&Importa"
::widget::mc::Revert		"In&verti"
::widget::mc::Previous	"Prece&dente"
::widget::mc::Next		"Pro&ssima"
::widget::mc::First		"Pri&ma"
::widget::mc::Last		"&Ultima"
::widget::mc::Help		"&Aiuto"
::widget::mc::Start		"&Start" ;# NEW

::widget::mc::New			"&New" ;# NEW
::widget::mc::Save		"&Salva"
::widget::mc::Delete		"&Elimina"

::widget::mc::Control(minimize)	"Minimizza"
::widget::mc::Control(restore)	"Esci da Schermo-Interno"
::widget::mc::Control(close)		"Chiudi"

### util ###############################################################

::util::mc::IOErrorOccurred					"Errore Input/Output"

::util::mc::IOError(OpenFailed)				"apertura fallita"
::util::mc::IOError(ReadOnly)					"il database è in sola-lettura"
::util::mc::IOError(UnknownVersion)			"versione del file sconosciuta"
::util::mc::IOError(UnexpectedVersion)		"versione del file inattesa"
::util::mc::IOError(Corrupted)				"file corrotto"
::util::mc::IOError(WriteFailed)				"operazione di scrittura fallita"
::util::mc::IOError(InvalidData)				"dato non valido (possibile corruzione file)"
::util::mc::IOError(ReadError)				"errore di lettura"
::util::mc::IOError(EncodingFailed)			"non posso scrivere il file di namebase" ;#namebase?
::util::mc::IOError(MaxFileSizeExceeded)	"grandezza di file massima raggiunta"
::util::mc::IOError(LoadFailed)				"apertura fallita (troppi eventi inseriti)"

::util::mc::SelectionOwnerDidntRespond		"Tempo scaduto durante operazione di trascinamento: intestatario selezione non ha risposto."

### progress ###########################################################
::progress::mc::Progress							"Progressi"

::progress::mc::Message(preload-namebase)		"Pre-caricando dati di namebase"
::progress::mc::Message(preload-tournament)	"Pre-caricando indice tornei"
::progress::mc::Message(preload-player)		"Pre-caricando indice giocatori"
::progress::mc::Message(preload-annotator)	"Pre-caricando indice commentatori"

::progress::mc::Message(read-index)				"Caricando indice dati"
::progress::mc::Message(read-game)				"Caricando dati partite"
::progress::mc::Message(read-namebase)			"Caricando dati namebase"
::progress::mc::Message(read-tournament)		"Caricando indice tornei"
::progress::mc::Message(read-player)			"Caricando indice giocatori"
::progress::mc::Message(read-annotator)		"Caricando indice commentatori"
::progress::mc::Message(read-source)			"Caricando indice fonti"
::progress::mc::Message(read-team)				"Caricando indice squadre"
::progress::mc::Message(read-init)				"Caricando dati di inizializzazione"

::progress::mc::Message(write-index)			"Scrivendo indice dati"
::progress::mc::Message(write-game)				"Scrivendo dati partite"
::progress::mc::Message(write-namebase)		"Scrivendo dati namebase"

::progress::mc::Message(print-game)				"Print %s game(s)" ;# NEW
::progress::mc::Message(copy-game)				"Copy %s game(s)" ;# NEW

### menu ###############################################################
::menu::mc::Theme							"Tema"

::menu::mc::AllScidbFiles				"Tutti i file Scidb"
::menu::mc::AllScidbBases				"Tutti i Database Scidb"
::menu::mc::ScidBases					"Database Scid"
::menu::mc::ScidbBases					"Database Scidb"
::menu::mc::ChessBaseBases				"Database ChessBase"
::menu::mc::ScidbArchives				"Archivi Scidb"
::menu::mc::PGNFilesArchives			"File/Archivi PGN"
::menu::mc::PGNFiles						"File PGN"
::menu::mc::PGNArchives					"Archivi PGN"

::menu::mc::Language						"&Lingua"
::menu::mc::Toolbars						"&Barre strumenti"
::menu::mc::ShowLog						"Mostra &Log"
::menu::mc::AboutScidb					"S&u Scidb"
::menu::mc::Fullscreen					"&Schermo intero"
::menu::mc::LeaveFullscreen			"Esci da &Schermo intero"
::menu::mc::Help							"&Aiuto"
::menu::mc::Contact						"&Contenuti (browser)"
::menu::mc::Quit							"&Esci"
::menu::mc::Extras						"E&xtras"
::menu::mc::Setup							"Setu&p" ;# NEW
::menu::mc::Engines						"&Engines" ;# NEW

::menu::mc::ContactBugReport			"&Segnala Bug"
::menu::mc::ContactFeatureRequest	"&Richiesta Funzione"
::menu::mc::InstallChessBaseFonts	"Installa Caratteri ChessBase"
::menu::mc::OpenEngineLog				"Open &Engine Console" ;# NEW

::menu::mc::OpenFile						"Apri un file Scidb"
::menu::mc::NewFile						"Crea un file Scidb"
::menu::mc::Archiving					"Archiviazione"
::menu::mc::CreateArchive				"Crea Archivio"
::menu::mc::BuildArchive				"Crea Archivio %s"
::menu::mc::Data							"%s dati"

### load ###############################################################
::load::mc::SevereError				"Grave errore durante caricamento file ECO"
::load::mc::FileIsCorrupt			"Il file %s è corrotto:"
::load::mc::ProgramAborting		"Il programma si sta chiudendo."

::load::mc::Loading					"Carico %s"
::load::mc::ReadingOptionsFile	"Permessi di lettura del file"
::load::mc::StartupFinished		"Startup completato"
::load::mc::SystemEncoding			"La codifica di sistema è '%s'"

::load::mc::ReadingFile(options)	"Permessi di lettura del file"
::load::mc::ReadingFile(engines)	"Reading engines file" ;# NEW

::load::mc::ECOFile					"File ECO"
::load::mc::EngineFile				"File motore"
::load::mc::SpellcheckFile			"File di informazioni sul giocatore"
::load::mc::LocalizationFile		"File localizzazione"
::load::mc::RatingList				"%s lista punteggio"
::load::mc::WikipediaLinks			"Link a Wikipedia"
::load::mc::ChessgamesComLinks	"Link a chessgames.com"
::load::mc::Cities					"città"
::load::mc::PieceSet					"set di pezzi"
::load::mc::Theme						"temi"
::load::mc::Icons						"icone"

### archive ############################################################
::archive::mc::CorruptedArchive			"L'archivio '%s' è corrotto."
::archive::mc::NotAnArchive				"'%s' non è un archivio."
::archive::mc::CorruptedHeader			"L'intestazione dell'archivio in '%s' è corrotta."
::archive::mc::CannotCreateFile			"Fallita creazione del file '%s'."
::archive::mc::FailedToExtractFile		"Fallita estrazione del file '%s'."
::archive::mc::UnknownCompression		"Metodo di compressione sconosciuto '%s'."
::archive::mc::ChecksumError				"Errore nel checksum durante l'estrazione '%s'."
::archive::mc::ChecksumErrorDetail		"Il file estratto '%s' sarà corrotto."
::archive::mc::FileNotReadable			"Il file '%s' non è leggibile."
::archive::mc::UsingRawInstead			"Utilizzo il metodo di compressione 'raw'."
::archive::mc::CannotOpenArchive			"Impossibile aprire l'archivio '%s'."
::archive::mc::CouldNotCreateArchive	"Impossibile creare l'archivio '%s'."

::archive::mc::PackFile						"Comprimi %s"
::archive::mc::UnpackFile					"Estrai %s"

### player photos ######################################################
::util::photos::mc::InstallPlayerPhotos		"Installa/Aggiorna le foto dei giocatori"
::util::photos::mc::TimeOut						"Tempo per la connessione scaduto."
::util::photos::mc::EnterPassword				"Password personale"
::util::photos::mc::Download						"Download"
::util::photos::mc::SharedInstallation			"Installazione condivisa"
::util::photos::mc::LocalInstallation			"Installazione privata"
::util::photos::mc::RetryLater					"Per favore riprova più tardi."
::util::photos::mc::DownloadStillInProgress	"Il download delle foto è ancora in corso."
::util::photos::mc::PhotoFiles					"File di foto"

::util::photos::mc::RequiresSuperuserRights	"L'installazione/aggiornamento richiede diritti di super-user.\n\nNota che l apassword non sarà accettata se il tuo utente non è nel gruppo wheel." ;# sudoers file?
::util::photos::mc::RequiresInternetAccess	"L'installazione/aggiornamento delle foto dei giocatori richiede una connessione internet."
::util::photos::mc::AlternativelyDownload(0)	"Alternativamente puoi scaricare le foto da %link%. Installa questi file nella directory %local%."
::util::photos::mc::AlternativelyDownload(1)	"Alternativamente puoi scaricare questi file da %link%. Installa questi file nella cartella condivisa %shared%, o nella cartella privata %local%."

::util::photos::mc::Error(nohttp)				"Non posso aprire una connessione internet perché il pacchetto TclHttp non è installato."
::util::photos::mc::Error(busy)					"L'installazione/aggiornamento è ancora in corso."
::util::photos::mc::Error(failed)				"Errore inaspettato: l'invocazione della sub-routine è fallita."
::util::photos::mc::Error(passwd)				"La password è sbagliata."
::util::photos::mc::Error(nosudo)				"Impossibile invocare il comando 'sudo' perché il tuo utente non è nel gruppo wheel."
::util::photos::mc::Detail(nosudo)				"Per aggirare il problema puoi fare un'installazione privata, o lanciare il programma come super-user."

::util::photos::mc::Message(uptodate)			"Le foto sono già aggiornate." ;# NEW changed from "The photo files are already up-to-date." to "The photo files are still up-to-date."
::util::photos::mc::Message(finished)			"L'installazione/aggiornamento delle foto è finito."
::util::photos::mc::Message(broken)				"La versione della libreria Tcl è corrotta."
::util::photos::mc::Message(noperm)				"Non hai diritti di scittura nella cartella '%s'."
::util::photos::mc::Message(missing)			"Impossibile trovare la cartella '%s'."
::util::photos::mc::Message(httperr)			"Errore HTTP: %s"
::util::photos::mc::Message(httpcode)			"Codice HTTP inaspettato %s."
::util::photos::mc::Message(noconnect)			"Connessione HTTP fallita."
::util::photos::mc::Message(timeout)			"Tempo di connessione HTTP scaduto."
::util::photos::mc::Message(crcerror)			"Errore nel Checksum. Probabilmente il server è al momento sottoposto a manutenzione."
::util::photos::mc::Message(maintenance)		"Il server che ospita le foto è al momento in manutenzione."
::util::photos::mc::Message(notfound)			"Download interrotto perché il server che ospita le foto è al momento in manutenzione."
::util::photos::mc::Message(aborted)			"L'utente ha interrotto il download."
::util::photos::mc::Message(killed)				"Interruzione inaspettata del download. La sub-routine è cessata." ;# has died?

::util::photos::mc::Detail(nohttp)				"Per favore installa il pacchetto TclHttp, per esemio %s."
::util::photos::mc::Detail(noconnect)			"Probabilmente non hai una connessione internet."
::util::photos::mc::Detail(badhost)				"Un'altra possibilità è un cattivo host, o una cattiva porta."

::util::photos::mc::Log(started)					"L'installazione/aggiornamento delle foto è cominciato a %s."
::util::photos::mc::Log(finished)				"L'installazione/aggiornamneto delle foto è finito a %s."
::util::photos::mc::Log(destination)			"La cartella di destinazione del download è '%s'."
::util::photos::mc::Log(created:1)				"%s file creati."
::util::photos::mc::Log(created:N)				"%s file(s) creati."
::util::photos::mc::Log(deleted:1)				"%s file eliminati."
::util::photos::mc::Log(deleted:N)				"%s file(s) eliminati."
::util::photos::mc::Log(skipped:1)				"%s file saltati."
::util::photos::mc::Log(skipped:N)				"%s file(s) saltati."
::util::photos::mc::Log(updated:1)				"%s file aggiornati."
::util::photos::mc::Log(updated:N)				"%s file(s) aggiornati."

### application ########################################################
::application::mc::Database				"&Database"
::application::mc::Board					"&Scacchiera"
::application::mc::MainMenu				"&Menù principale"

::application::mc::DockWindow				"Blocca Finestra"
::application::mc::UndockWindow			"Sblocca Finestra"
::application::mc::ChessInfoDatabase	"Chess Information Data Base"
::application::mc::Shutdown				"Spegni..."
::application::mc::QuitAnyway				"Uscire comunque?"

### application::board #################################################
::application::board::mc::ShowCrosstable	"Mostra tabella torneo per questa partita"
::application::board::mc::StartEngine		"Start chess analysis engine" ;# NEW
::application::board::mc::StopEngine		"Stop chess analysis engine" ;# NEW

::application::board::mc::Tools				"Strumenti"
::application::board::mc::Control			"Controllo"
::application::board::mc::Game				"Partita"
::application::board::mc::GoIntoNextVar	"Vai alla prossima variante"
::application::board::mc::GoIntPrevVar		"Vai alla precedente variante"
::application::board::mc::LoadGame(next)	"Load next game" ;# NEW
::application::board::mc::LoadGame(prev)	"Load previous game" ;# NEW
::application::board::mc::LoadGame(first)	"Load first game" ;# NEW
::application::board::mc::LoadGame(last)	"Load last game" ;# NEW

::application::board::mc::Accel(edit-annotation)	"A"
::application::board::mc::Accel(edit-comment)		"C"
::application::board::mc::Accel(edit-marks)			"M"
::application::board::mc::Accel(add-new-game)		"S"
::application::board::mc::Accel(replace-game)		"R"
::application::board::mc::Accel(replace-moves)		"V"
::application::board::mc::Accel(trial-mode)			"T"

### application::database ##############################################
::application::database::mc::FileOpen							"Apri Database..."
::application::database::mc::FileOpenRecent					"Apri Recente"
::application::database::mc::FileNew							"Nuovo Database..."
::application::database::mc::FileExport						"Esporta..."
::application::database::mc::FileImport(pgn)					"Importa file PGN..."
::application::database::mc::FileImport(db)					"Importa Database..." ;# NEW ok?
::application::database::mc::FileCreate						"Crea Archivio..."
::application::database::mc::FileClose							"Chiudi"
::application::database::mc::FileCompact						"Compresso"
::application::database::mc::HelpSwitcher						"Aiuto per il Selezionatore di Database"

::application::database::mc::Games								"&Partite"
::application::database::mc::Players							"&Giocatori"
::application::database::mc::Events								"&Eventi"
::application::database::mc::Sites								"&Luoghi"
::application::database::mc::Annotators						"&Commentatori"

::application::database::mc::File								"File"
::application::database::mc::SymbolSize						"Grandezza simbolo"
::application::database::mc::Large								"Grande"
::application::database::mc::Medium								"Medio"
::application::database::mc::Small								"Piccolo"
::application::database::mc::Tiny								"Minuscolo"
::application::database::mc::Empty								"vuoto"
::application::database::mc::None								"nessuno"
::application::database::mc::Failed								"fallito"
::application::database::mc::LoadMessage						"Sto aprendo il database %s"
::application::database::mc::UpgradeMessage					"Aggiornamento database %s"
::application::database::mc::CompactMessage					"Comprimendo il database %s"
::application::database::mc::CannotOpenFile					"Non è possibile aprire il file '%s'."
::application::database::mc::EncodingFailed					"Codifica di %s fallita."
::application::database::mc::DatabaseAlreadyOpen			"Il database '%s' è già aperto."
::application::database::mc::Properties						"Proprietà"
::application::database::mc::Preload							"Preload"
::application::database::mc::MissingEncoding					"Codifica %s mancante (uso %s)"
::application::database::mc::DescriptionTooLarge			"La descrizione è troppo lunga."
::application::database::mc::DescrTooLargeDetail			"Il campo contiene %d caratteri, ma solo %d sono permessi."
::application::database::mc::ClipbaseDescription			"Database temporaneo, non è salvato sul disco"
::application::database::mc::HardLinkDetected				"Impossibile caricare il file '%file1' perché è già caricato come file '%file2'. Questo può succedere solo se ci sono collegamenti tra i due." ;# hard links?
::application::database::mc::HardLinkDetectedDetail		"Se il database viene caricato due volte il programma potrebbe crashare per l'eccessivo utilizzo dei threads." ;# thread? lasciare così?
::application::database::mc::UriRejectedDetail(open)		"Solo database Scidb possono essere aperti:"
::application::database::mc::UriRejectedDetail(import)	"Only Scidb databases can be imported:" ;# NEW
::application::database::mc::EmptyUriList						"Gli archivi trascinati sono vuoti."
::application::database::mc::OverwriteExistingFiles		"Sovrascrivi i file esistenti nella cartella '%s'?"
::application::database::mc::SelectDatabases					"Selezione il database da aprire"
::application::database::mc::ExtractArchive					"Estrai l'archivio %s"
::application::database::mc::CompactDetail					"Tutte le partite devono essere chiuse per permettere la compressione."
::application::database::mc::ReallyCompact					"Vuoi davvero comprimere il database '%s'?"
::application::database::mc::ReallyCompactDetail(1)		"Solo una partita sarà eliminata."
::application::database::mc::ReallyCompactDetail(N)		"%s partite saranno eliminate."
::application::database::mc::CopyGames							"Copy games" ;# NEW
::application::database::mc::CopyGamesFromTo					"Copy games from '%src' to '%dst'" ;# NEW
::application::database::mc::CopiedGames						"%s game(s) copied"
::application::database::mc::NoGamesCopied					"No games copied"
::application::database::mc::CopyAllGames						"Copy all games (%num) from '%src'"
::application::database::mc::CopyFilteredGames				"Copy only filtered games (%num) from '%src'"
::application::database::mc::ImportGames						"Import games" ;# NEW
::application::database::mc::ImportOneGameTo(0)				"Copy one game to '%dst'?" ;# NEW
::application::database::mc::ImportOneGameTo(1)				"Copy about one game to '%dst'?" ;# NEW
::application::database::mc::ImportGamesTo(0)				"Copy %num games to '%dst'?" ;# NEW
::application::database::mc::ImportGamesTo(1)				"Copy about %num games to '%dst'?" ;# NEW
::application::database::mc::ImportFiles						"Import Files:" ;# NEW

::application::database::mc::RecodingDatabase				"Registro %base da %from a %to"
::application::database::mc::RecodedGames						"%s partite registrate"

::application::database::mc::GameCount							"Partite"
::application::database::mc::DatabasePath						"Indirizzo Database"
::application::database::mc::DeletedGames						"Partite Eliminate"
::application::database::mc::Description						"Descrizione"
::application::database::mc::Created							"Creata"
::application::database::mc::LastModified						"Ultima Modifica"
::application::database::mc::Encoding							"Codifica"
::application::database::mc::YearRange							"Range Anni"
::application::database::mc::RatingRange						"Range Punteggio"
::application::database::mc::Result								"Risultato"
::application::database::mc::Score								"Score"
::application::database::mc::Type								"Tipo"
::application::database::mc::ReadOnly							"Sola Lettura"

::application::database::mc::ChangeIcon						"Cambia Icona"
::application::database::mc::Recode								"Ricodifica"
::application::database::mc::EditDescription					"Modifica Descrizione"
::application::database::mc::EmptyClipbase					"Svuota Clipbase"

::application::database::mc::T_Unspecific						"Non specificato"
::application::database::mc::T_Temporary						"Temporaneo"
::application::database::mc::T_Work								"Lavoro"
::application::database::mc::T_Clipbase						"Clipbase"
::application::database::mc::T_MyGames							"Mie partite"
::application::database::mc::T_Informant						"Informatore"
::application::database::mc::T_LargeDatabase					"Grande Database"
::application::database::mc::T_CorrespondenceChess			"Scacchi per corrispondenza"  
::application::database::mc::T_EmailChess						"Scacchi per email"
::application::database::mc::T_InternetChess					"Scacchi su internet"
::application::database::mc::T_ComputerChess					"Partite tra computer"
::application::database::mc::T_Chess960						"Scacchi 960"
::application::database::mc::T_PlayerCollection				"Monografia per giocatore"
# Female version of "Player Collection"
# Be sure that the translation starts with same term as the translation above.
::application::database::mc::T_PlayerCollectionFemale		"Player Collection" ;# NEW
::application::database::mc::T_Tournament						"Torneo"
::application::database::mc::T_TournamentSwiss				"Torneo Svizzero"
::application::database::mc::T_GMGames							"Partite di GM"
::application::database::mc::T_IMGames							"Partite di IM"
::application::database::mc::T_BlitzGames						"Partite lampi"
::application::database::mc::T_Tactics							"Tattica"
::application::database::mc::T_Endgames						"Finali"
::application::database::mc::T_Analysis						"Analisi"
::application::database::mc::T_Training						"Allenamento"
::application::database::mc::T_Match							"Match"
::application::database::mc::T_Studies							"Studi"
::application::database::mc::T_Jewels							"Gemme"
::application::database::mc::T_Problems						"Problemi"
::application::database::mc::T_Patzer							"Brocchi"
::application::database::mc::T_Gambit							"Gambetti"
::application::database::mc::T_Important						"Importanti"
::application::database::mc::T_Openings						"Aperture"
::application::database::mc::T_OpeningsWhite					"Aperture bianco"
::application::database::mc::T_OpeningsBlack					"Aperture nero"
::application::database::mc::T_Bughouse						"Bughouse Chess" ;# NEW
::application::database::mc::T_Antichess						"Antichess" ;# NEW
::application::database::mc::T_PGNFile							"File PGN"

::application::database::mc::OpenDatabase						"Apri Database"
::application::database::mc::NewDatabase						"Nuovo Database"
::application::database::mc::CloseDatabase					"Chiudi Database '%s'"
::application::database::mc::SetReadonly						"Imposta Database '%s' in sola lettura"
::application::database::mc::SetWriteable						"Imposta Database '%s' in scrittura"

::application::database::mc::OpenReadonly						"Apri sola lettura"
::application::database::mc::OpenWriteable					"Apri in scrittura"

::application::database::mc::UpgradeDatabase					"%s è un database in un vecchio formato che non può essere aperto per la scrittura.\n\nL'aggiornamento creerà una nuova versione del database e rimuoverà i file originali.\n\nQuesta operazione può richiedere del tempo, ma è necessario eseguirla una volta sola.\n\nVuoi aggiornare il database ora?"
::application::database::mc::UpgradeDatabaseDetail			"\"No\" aprirà il database per la sola lettura, non puoi settarlo come scrivibile."

### application::database::games #######################################
::application::database::games::mc::Control						"Controllo"
::application::database::games::mc::GameNumber					"Numero partita"

::application::database::games::mc::GotoFirstPage				"Vai alla prima pagina di partite"
::application::database::games::mc::GotoLastPage				"Vai all'ultima pagina di partite"
::application::database::games::mc::PreviousPage				"Pagina di partite precedente"
::application::database::games::mc::NextPage						"Prossima pagina di partite"
::application::database::games::mc::GotoCurrentSelection		"Vai alla selezione attuale"
::application::database::games::mc::UseVerticalScrollbar		"Usa scrollbar verticale"
::application::database::games::mc::UseHorizontalScrollbar	"Usa scrollbar orizzontale"
::application::database::games::mc::GotoEnteredGameNumber	"Vai alla partita numero..."

### application::database::players #####################################
::application::database::players::mc::EditPlayer				"Modifica Giocatore"
::application::database::players::mc::Score						"Punteggio"
::application::database::players::mc::TooltipRating			"Elo: %s"

### application::database::annotators ##################################
::application::database::annotators::mc::F_Annotator		"Commentatore"
::application::database::annotators::mc::F_Frequency		"Frequenza"

::application::database::annotators::mc::Find				"Cerca"
::application::database::annotators::mc::FindAnnotator	"Cerca Commentatore"
::application::database::annotators::mc::ClearEntries		"Pulisci Form"
::application::database::annotators::mc::NotFound			"Nessun risultato."

### application::pgn ###################################################
::application::pgn::mc::Command(move:comment)			"Imposta commento"
::application::pgn::mc::Command(move:marks)				"Imposta codici"
::application::pgn::mc::Command(move:annotation)		"Imposta annotazioni/commenti/codici"
::application::pgn::mc::Command(move:append)				"Aggiungi mossa"
::application::pgn::mc::Command(move:nappend)			"Aggiungi Mosse"
::application::pgn::mc::Command(move:exchange)			"Cambia mossa"
::application::pgn::mc::Command(variation:new)			"Aggiungi variante"
::application::pgn::mc::Command(variation:replace)		"Sostituisci mosse"
::application::pgn::mc::Command(variation:truncate)	"Interrompi variante"
::application::pgn::mc::Command(variation:first)		"Rendi prima variante"
::application::pgn::mc::Command(variation:promote)		"Promuovi variante a linea principale"
::application::pgn::mc::Command(variation:remove)		"Elimina variante"
::application::pgn::mc::Command(variation:mainline)	"Nuova linea principale"
::application::pgn::mc::Command(variation:insert)		"Inserisci mosse"
::application::pgn::mc::Command(variation:exchange)	"Cambia mosse"
::application::pgn::mc::Command(strip:moves)				"Mosse dall'inizio"
::application::pgn::mc::Command(strip:truncate)			"Mosse alla fine"
::application::pgn::mc::Command(strip:annotations)		"Annotazioni"
::application::pgn::mc::Command(strip:info)				"Informazioni Mossa"
::application::pgn::mc::Command(strip:marks)				"Codici"
::application::pgn::mc::Command(strip:comments)			"Commenti"
::application::pgn::mc::Command(strip:variations)		"Varianti"
::application::pgn::mc::Command(copy:comments)			"Copia Commenti"
::application::pgn::mc::Command(move:comments)			"Muovi Commenti"
::application::pgn::mc::Command(game:clear)				"Pulisci partita"
::application::pgn::mc::Command(game:transpose)			"Trasponi Partita"

::application::pgn::mc::StartTrialMode						"Inizia modalità di prova"
::application::pgn::mc::StopTrialMode						"Interrompi modalità di prova"
::application::pgn::mc::Strip									"Togli"
::application::pgn::mc::InsertDiagram						"Inserisci diagramma"
::application::pgn::mc::InsertDiagramFromBlack			"Inserisci diagramma dalla prospettiva del nero"
::application::pgn::mc::SuffixCommentaries				"Commenti dopo mossa"
::application::pgn::mc::StripOriginalComments			"Rimuovi commenti originali"

::application::pgn::mc::LanguageSelection					"Selezione Lingue"
::application::pgn::mc::MoveNotation						"Muovi Notazione"
::application::pgn::mc::CollapseVariations				"Comprimi Varianti"
::application::pgn::mc::ExpandVariations					"Espandi Varianti"
::application::pgn::mc::EmptyGame							"Partita Vuota"

::application::pgn::mc::NumberOfMoves						"Numero di semimosse (nella linea principale):"
::application::pgn::mc::InvalidInput						"Input non valido '%d'."
::application::pgn::mc::MustBeEven							"Input deve essere un numero pari."
::application::pgn::mc::MustBeOdd							"Input deve essere un numero dispari."
::application::pgn::mc::CannotOpenCursorFiles			"Impossibile aprire il file del cursore: %s"
::application::pgn::mc::ReallyReplaceMoves				"Vuoi davvero sostituire le mosse della partita corrente?"
::application::pgn::mc::CurrentGameIsNotModified		"La partita corrente non è stata modificata."

::application::pgn::mc::EditAnnotation						"Modifica annotazioni"
::application::pgn::mc::EditMoveInformation				"Modifica informazioni mossa"
::application::pgn::mc::EditCommentBefore					"Modifica commento prima della mossa"
::application::pgn::mc::EditCommentAfter					"Modifica commento dopo la mossa"
::application::pgn::mc::EditPrecedingComment				"Modifica commento precedente"
::application::pgn::mc::EditTrailingComment				"Modifica commento successivo"
::application::pgn::mc::EditMarks							"Modifica codici"
::application::pgn::mc::Display								"Display"
::application::pgn::mc::None									"nessuno"

### application::tree ##################################################
::application::tree::mc::Total								"Totale"
::application::tree::mc::Control								"Controllo"
::application::tree::mc::ChooseReferenceBase				"Scegli database di riferimento"
::application::tree::mc::ReferenceBaseSwitcher			"Selezione database di riferimento"
::application::tree::mc::Numeric								"Numerico"
::application::tree::mc::Bar									"Barra"
::application::tree::mc::StartSearch						"Comincia ricerca"
::application::tree::mc::StopSearch							"Interrompi ricerca"
::application::tree::mc::UseExactMode						"Usa ricerca di posizione"
::application::tree::mc::UseFastMode						"Usa ricerca accelerata"
::application::tree::mc::UseQuickMode						"Usa ricerca rapida"
::application::tree::mc::AutomaticSearch					"Ricerca automatica"
::application::tree::mc::LockReferenceBase				"Blocca il database di riferimento"
::application::tree::mc::SwitchReferenceBase				"Cambia database di riferimento"
::application::tree::mc::TransparentBar					"Barra trasparente"

::application::tree::mc::FromWhitesPerspective			"Dalla prospettiva del bianco"
::application::tree::mc::FromBlacksPerspective			"Dalla prospettiva del nero"
::application::tree::mc::FromSideToMovePerspective		"Dalla prospettiva del lato col tratto"
::application::tree::mc::FromWhitesPerspectiveTip		"Punteggio dalla prospettiva del bianco"
::application::tree::mc::FromBlacksPerspectiveTip		"Punteggio dalla prospettiva del nero"

::application::tree::mc::TooltipAverageRating			"Media ELO (%s)"
::application::tree::mc::TooltipBestRating				"Miglior ELO (%s)"

::application::tree::mc::F_Number							"#"
::application::tree::mc::F_Move								"Mossa"
::application::tree::mc::F_Eco								"ECO"
::application::tree::mc::F_Frequency						"Frequenza"
::application::tree::mc::F_Ratio								"Percentuale"
::application::tree::mc::F_Score								"Risultato"
::application::tree::mc::F_Draws								"Patte"
::application::tree::mc::F_Performance						"Performance"
::application::tree::mc::F_AverageYear						"\u00f8 Anno"
::application::tree::mc::F_LastYear							"Giocata per ultimo"
::application::tree::mc::F_BestPlayer						"Miglior giocatore"
::application::tree::mc::F_FrequentPlayer					"Giocata frequentemente da"

::application::tree::mc::T_Number							"Numerazione"
::application::tree::mc::T_AverageYear						"Media anni"
::application::tree::mc::T_FrequentPlayer					"Giocata frequentemente da"

### board ##############################################################
::board::mc::CannotReadFile		"Impossibile leggere file '%s':"
::board::mc::CannotFindFile		"Impossibile trovare file '%s'"
::board::mc::FileWillBeIgnored	"'%s' sarà ignorato (ID doppio)"
::board::mc::IsCorrupt				"'%s' è corrotto (stile %s sconosciuto '%s')"

::board::mc::ThemeManagement		"Gestore Temi"
::board::mc::Setup					"Setup"

::board::mc::WorkingSet				"Selezione di lavoro"

### board::options #####################################################
::board::options::mc::Coordinates			"Coordinate"
::board::options::mc::SolidColor				"Tinta Unita"
::board::options::mc::EditList				"Modifica lista"
::board::options::mc::Embossed				"In Rilievo"
::board::options::mc::Highlighting			"Evidenzia"
::board::options::mc::Border					"Bordo"
::board::options::mc::SaveWorkingSet		"Salva set di lavoro"
::board::options::mc::SelectedSquare		"Seleziona casa"
::board::options::mc::ShowBorder				"Mostra bordo"
::board::options::mc::ShowCoordinates		"Mostra coordinate"
::board::options::mc::ShowMaterialValues	"Mostra valore dei pezzi"
::board::options::mc::ShowMaterialBar		"Mostra barra del materiale"
::board::options::mc::ShowSideToMove		"Mostra lato con il tratto"
::board::options::mc::ShowSuggestedMove	"Mostra mossa suggerita"
::board::options::mc::SuggestedMove			"Mossa suggerita"
::board::options::mc::Basic					"Basilare"
::board::options::mc::PieceStyle				"Stile dei pezzi"
::board::options::mc::SquareStyle			"Stile delle case"
::board::options::mc::Styles					"Stili"
::board::options::mc::Show						"Anteprima"
::board::options::mc::ChangeWorkingSet		"Modifica set di lavoro"
::board::options::mc::CopyToWorkingSet		"Copia su set di lavoro"
::board::options::mc::NameOfPieceStyle		"Inserisci nome dello stile pezzi"
::board::options::mc::NameOfSquareStyle	"Inserisci nome dello stile case"
::board::options::mc::NameOfThemeStyle		"Inserisci nome del tema"
::board::options::mc::PieceStyleSaved		"Stile pezzi '%s' salvano sotto '%s'"
::board::options::mc::SquareStyleSaved		"Stile case '%s' salvato sotto '%s'"
::board::options::mc::ChooseColors			"Scegli colori"
::board::options::mc::SupersedeSuggestion	"Sostituisci/usa colori suggeridi dallo stile della casa"
::board::options::mc::CannotDelete			"Non posso eliminare '%s'."
::board::options::mc::IsWriteProtected		"Il file '%s' è protetto per la scrittura"
::board::options::mc::ConfirmDelete			"Sei sicuro di voler eliminare '%s'?"
::board::options::mc::NoPermission			"Non posso eliminare '%s'.\nPermesso negato."
::board::options::mc::BoardSetup				"Configurazione scacchiera"
::board::options::mc::OpenTextureDialog	"Apri finestra Texture"

::board::options::mc::YouCannotReverse		"Non puoi ritornare su questa azione. Il file '%s' sarà rimosso fisicamente."

::board::options::mc::CannotUsePieceWorkingSet "Non posso creare un nuovo tema con %s selezionato per lo stile dei pezzi.\n Prima devi salvare il nuovo stile pezzi, o scegliere un altro stile pezzi."

::board::options::mc::CannotUseSquareWorkingSet "Non posso creare un nuovo tema con %s selezionato per lo stile delle case.\n Prima devi salvare il nuovo stile case, o scegliere un altro stile case."

### board::piece #######################################################
::board::piece::mc::Start						"Inizia"
::board::piece::mc::Stop						"Ferma"
::board::piece::mc::HorzOffset				"Offset Orizzontale"
::board::piece::mc::VertOffset				"Offset Verticale"
::board::piece::mc::Gradient					"Gradiente"
::board::piece::mc::Fill						"Riempimento"
::board::piece::mc::Stroke						"Tratto"
::board::piece::mc::Contour					"Contorno"
::board::piece::mc::WhiteShape				"Forma bianca"
::board::piece::mc::PieceSelection			"Selezione pezzi"
::board::piece::mc::BackgroundSelection	"Selezione sfondo"
::board::piece::mc::Zoom						"Zoom"
::board::piece::mc::Shadow						"Ombre"
::board::piece::mc::Opacity					"Opacità"
::board::piece::mc::ShadowDiffusion			"Diffusione Ombra"
::board::piece::mc::PieceStyleConf			"Configurazione stile pezzi"
::board::piece::mc::Offset						"Offset"
::board::piece::mc::Rotate						"Ruota"
::board::piece::mc::CloseDialog				"Chiudi finestra di dialogo e perdere le modifiche?"
::board::piece::mc::OpenTextureDialog		"Apri finestra Texture"

### board::square ######################################################
::board::square::mc::SolidColor			"Tinta unita"
::board::square::mc::CannotReadFile		"Impossibile leggere il file"
::board::square::mc::Zoom					"Zoom"
::board::square::mc::Offset				"Offset"
::board::square::mc::Rotate				"Ruota"
::board::square::mc::Borderline			"Bordo"
::board::square::mc::Width					"Larghezza"
::board::square::mc::Opacity				"Opacità"
::board::square::mc::GapBetweenSquares	"Spazio tra le case"
::board::square::mc::Highlighting		"Evidenzia"
::board::square::mc::Selected				"Selezionato"
::board::square::mc::SuggestedMove		"Mossa suggerita"
::board::square::mc::Show					"Anteprima"
::board::square::mc::SquareStyleConf	"Configurazione stile casa"
::board::square::mc::CloseDialog			"Chiudere la finestra e perdere i cambiamenti?"

### board::texture #####################################################
::board::texture::mc::PreselectedOnly "Solo preselezionato"

### pgn-setup ##########################################################
::pgn::setup::mc::Configure(editor)				"Personalizza l'editor"
::pgn::setup::mc::Configure(browser)			"Personalizza il testo in output"
::pgn::setup::mc::TakeOver(editor)				"Imposta configurazione dallo Sfoglia Partite"
::pgn::setup::mc::TakeOver(browser)				"Imposta configurazione dall'Editor Partite"
::pgn::setup::mc::Pixel								"pixel"
::pgn::setup::mc::Spaces							"spaces" ;# NEW
::pgn::setup::mc::RevertSettings					"Torna alla configurazione iniziale"
::pgn::setup::mc::ResetSettings					"Torna alla configurazione di produzione"
::pgn::setup::mc::DiscardAllChanges				"Annulla tutte le modifiche applicate?"

::pgn::setup::mc::Setup(Appearance)				"Aspetto"
::pgn::setup::mc::Setup(Layout)					"Layout"
::pgn::setup::mc::Setup(Diagrams)				"Diagrammi"
::pgn::setup::mc::Setup(MoveStyle)				"Stile Mossa"

::pgn::setup::mc::Setup(Fonts)					"Fonts"
::pgn::setup::mc::Setup(font-and-size)			"Font e dimensione testo"
::pgn::setup::mc::Setup(figurine-font)			"Figurine (normale)"
::pgn::setup::mc::Setup(figurine-bold)			"Figurine (grassetto)"
::pgn::setup::mc::Setup(symbol-font)			"Simboli"

::pgn::setup::mc::Setup(Colors)					"Colori"
::pgn::setup::mc::Setup(Highlighting)			"Evidenziazione"
::pgn::setup::mc::Setup(start-position)		"Posizione Iniziale"
::pgn::setup::mc::Setup(variations)				"Varianti"
::pgn::setup::mc::Setup(numbering)				"Numerazione"
::pgn::setup::mc::Setup(brackets)				"Parentesi"
::pgn::setup::mc::Setup(illegal-move)			"Mosse Illegali"
::pgn::setup::mc::Setup(comments)				"Commenti"
::pgn::setup::mc::Setup(annotation)				"Annotazioni"
::pgn::setup::mc::Setup(nagtext)					"NAG-Text" ;# NEW
::pgn::setup::mc::Setup(marks)					"Codici"
::pgn::setup::mc::Setup(move-info)				"Informazioni Mossa"
::pgn::setup::mc::Setup(result)					"Risultato"
::pgn::setup::mc::Setup(current-move)			"Mossa Corrente"
::pgn::setup::mc::Setup(next-moves)				"Prossima Mossa"
::pgn::setup::mc::Setup(empty-game)				"Partita Vuota"

::pgn::setup::mc::Setup(Hovers)					"Al passaggio del mouse"
::pgn::setup::mc::Setup(hover-move)				"Mossa"
::pgn::setup::mc::Setup(hover-comment)			"Commento"
::pgn::setup::mc::Setup(hover-move-info)		"Informazioni Mossa"

::pgn::setup::mc::Section(ParLayout)			"Layout Paragrafo"
::pgn::setup::mc::ParLayout(use-spacing)		"Usa spaziatura di paragrafo"
::pgn::setup::mc::ParLayout(column-style)		"Stile colonna"
::pgn::setup::mc::ParLayout(tabstop-1)			"Indentazione per Mossa Bianca"
::pgn::setup::mc::ParLayout(tabstop-2)			"Indentazione per Mossa Nera"
::pgn::setup::mc::ParLayout(mainline-bold)	"Grassetto per mosse nella linea principale"

::pgn::setup::mc::Section(Variations)			"Layout Varianti"
::pgn::setup::mc::Variations(width)				"Larghezza Indentazione"
::pgn::setup::mc::Variations(level)				"Livello Indentazione"

::pgn::setup::mc::Section(Display)				"Visualizzazione"
::pgn::setup::mc::Display(numbering)			"Mostra Numerazione Varianti"
::pgn::setup::mc::Display(moveinfo)				"Mostra Informazioni Mossa"
::pgn::setup::mc::Display(nagtext)				"Show text for unusual NAG comments" ;# NEW

::pgn::setup::mc::Section(Diagrams)				"Diagrammi"
::pgn::setup::mc::Diagrams(show)					"Mostra diagrammi"
::pgn::setup::mc::Diagrams(square-size)		"Grandezza Casa"
::pgn::setup::mc::Diagrams(indentation)		"Larghezza Indentazione"


### engine #############################################################
::engine::mc::Information				"Information" ;# NEW
::engine::mc::Features					"Features" ;# NEW
::engine::mc::Options					"Options" ;# NEW

::engine::mc::Name						"Name" ;# NEW
::engine::mc::Identifier				"Identifier" ;# NEW
::engine::mc::Author						"Author" ;# NEW
::engine::mc::Webpage					"Webpage" ;# NEW
::engine::mc::Email						"Email" ;# NEW
::engine::mc::Country					"Country" ;# NEW
::engine::mc::Rating						"Rating" ;# NEW
::engine::mc::Logo						"Logo" ;# NEW
::engine::mc::Protocol					"Protocol" ;# NEW
::engine::mc::Parameters				"Parameters" ;# NEW
::engine::mc::Command					"Command" ;# NEW
::engine::mc::Directory					"Directory" ;# NEW
::engine::mc::Variants					"Variants" ;# NEW
::engine::mc::LastUsed					"Last used" ;# NEW

::engine::mc::Variant(standard)		"Standard" ;# NEW
::engine::mc::Variant(chess960)		"Chess 960" ;# NEW
::engine::mc::Variant(bughouse)		"Bughouse" ;# NEW
::engine::mc::Variant(crazyhouse)	"Crazyhouse" ;# NEW
# NOTE: Suicide is Antichess according to FICS rules
# NOTE: "Giveaway" is Antichess according to internatianal rules.
# NOTE: "Losers" is Antichess according to ICC rules
# NOTE: You may tarnslate "Suicide", "Giveaway", anmd "Losers" with the same term.
::engine::mc::Variant(suicide)		"Antichess" ;# NEW
::engine::mc::Variant(giveaway)		"Antichess" ;# NEW
::engine::mc::Variant(losers)			"Antichess" ;# NEW
::engine::mc::Variant(3check)			"Three-check" ;# NEW

::engine::mc::Edit						"Edit" ;# NEW
::engine::mc::View						"View" ;# NEW
::engine::mc::New							"New" ;# NEW
::engine::mc::Rename						"Rename" ;# NEW
::engine::mc::Delete						"Delete" ;# NEW
::engine::mc::Select(engine)			"Select engine" ;# NEW
::engine::mc::Select(profile)			"Select profile" ;# NEW
::engine::mc::ProfileName				"Profile name" ;# NEW
::engine::mc::NewProfileName			"New profile name" ;# NEW
::engine::mc::OldProfileName			"Old profile name" ;# NEW
::engine::mc::CopyFrom					"Copy from" ;# NEW
::engine::mc::NewProfile				"New Profile" ;# NEW
::engine::mc::RenameProfile			"Rename Profile" ;# NEW
::engine::mc::EditProfile				"Edit Profile '%s'" ;# NEW
::engine::mc::ProfileAlreadyExists	"A profile with name '%s' already exists." ;# NEW
::engine::mc::ChooseDifferentName	"Please choose a different name." ;# NEW
::engine::mc::ReservedName				"Name '%s' is reserved and cannot be used." ;# NEW
::engine::mc::ReallyDeleteProfile	"Really delete profile '%s'?" ;# NEW

::engine::mc::AdminEngines				"Manage Engines" ;# NEW
::engine::mc::SetupEngine				"Setup engine %s" ;# NEW
::engine::mc::ImageFiles				"Image files" ;# NEW
::engine::mc::SelectEngine				"Select Engine" ;# NEW
::engine::mc::SelectEngineLogo		"Select Engine Logo" ;# NEW
::engine::mc::EngineLog					"Engine Console" ;# NEW
::engine::mc::Probing					"Probing" ;# NEW
::engine::mc::NeverUsed					"Never used" ;# NEW
::engine::mc::OpenFsbox					"Open File Selection Dialog" ;# NEW
::engine::mc::ResetToDefault			"Reset to default" ;# NEW
::engine::mc::ShowInfo					"Show \"Info\"" ;# NEW don't translate "Info"
::engine::mc::TotalUsage				"%s times in total" ;# NEW
::engine::mc::Memory						"Memory (MB)" ;# NEW
::engine::mc::CPUs						"CPUs" ;# NEW
::engine::mc::Priority					"CPU Priority" ;# NEW
::engine::mc::ClearHash					"Clear hash tables" ;# NEW

::engine::mc::ConfirmNewEngine		"Confirm new engine" ;# NEW
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
::application::analysis::mc::Control						"Control" ;# NEW
::application::analysis::mc::Information					"Information" ;# NEW
::application::analysis::mc::Setup							"Setup" ;# NEW
::application::analysis::mc::Pause							"Pause" ;# NEW
::application::analysis::mc::Resume							"Resume" ;# NEW
::application::analysis::mc::LockEngine					"Lock engine to current position" ;# NEW
::application::analysis::mc::MultipleVariations			"Multiple variations (multi-pv)" ;# NEW
::application::analysis::mc::HashFullness					"Hash fullness" ;# NEW
::application::analysis::mc::Hash							"Hash:" ;# NEW
::application::analysis::mc::Lines							"Lines:" ;# NEW
::application::analysis::mc::MateIn							"%color mate in %n" ;# NEW
::application::analysis::mc::BestScore						"Best score (of current lines)" ;# NEW
::application::analysis::mc::CurrentMove					"Currently searching this move" ;# NEW
::application::analysis::mc::TimeSearched					"Time searched" ;# NEW
::application::analysis::mc::SearchDepth					"Search depth in plies (Selective search depth)" ;# NEW

::application::analysis::mc::LinesPerVariation			"Lines per variation" ;# NEW
::application::analysis::mc::BestFirstOrder				"Sort by evaluation" ;# NEW
::application::analysis::mc::Engine							"Engine" ;# NEW

::application::analysis::mc::Seconds						"s" ;# NEW
::application::analysis::mc::Minutes						"m" ;# NEW

::application::analysis::mc::NotSupported(standard)	"This engine does not support standard chess." ;# NEW
::application::analysis::mc::NotSupported(chess960)	"This engine does not support chess 960." ;# NEW
::application::analysis::mc::NotSupported(analyze)		"This engine does not have an analysis mode." ;# NEW

::application::analysis::mc::Signal(stopped)				"Engine stopped by signal." ;# NEW
::application::analysis::mc::Signal(resumed)				"Engine resumed by signal." ;# NEW
::application::analysis::mc::Signal(killed)				"Engine killed by signal." ;# NEW
::application::analysis::mc::Signal(crashed)				"Engine crashed." ;# NEW
::application::analysis::mc::Signal(closed)				"Engine has closed connection." ;# NEW
::application::analysis::mc::Signal(terminated)			"Engine terminated with exit code %s." ;# NEW

### gametable ##########################################################
::gametable::mc::DeleteGame				"Segna partita come eliminata"
::gametable::mc::UndeleteGame				"Ripristina questa partita"
::gametable::mc::EditGameFlags			"Modifica identificatori partita"
::gametable::mc::Custom						"Personalizza"

::gametable::mc::Monochrome				"Monocroma"
::gametable::mc::Transparent				"Trasparente"
::gametable::mc::Relief						"Rilievo"
::gametable::mc::ShowIdn					"Mostra numero posizione di Scacchi 960"
::gametable::mc::Icons						"Icone"
::gametable::mc::Abbreviations			"Abbreviazioni"

::gametable::mc::SortAscending			"Ordina (ascendente)"
::gametable::mc::SortDescending			"Ordina (discendente)"
::gametable::mc::SortOnAverageElo		"Ordina su Elo medio (discendente)"
::gametable::mc::SortOnAverageRating	"Ordina su punteggio medio (discendente)"
::gametable::mc::SortOnDate				"Ordina su data (discendente)"
::gametable::mc::SortOnNumber				"Ordina su numero partita (ascendente)"
::gametable::mc::ReverseOrder				"Inverti ordine"
::gametable::mc::NoMoves					"Nessuna mossa"
::gametable::mc::NoMoreMoves				"Nessuna altra mossa"
::gametable::mc::WhiteRating				"Punteggio Bianco"
::gametable::mc::BlackRating				"Punteggio Nero"

::gametable::mc::Flags						"Identificatori"
::gametable::mc::PGN_CountryCode			"Codice paese PGN"
::gametable::mc::ISO_CountryCode			"Codice paese ISO"
::gametable::mc::ExcludeElo				"Escludi Elo"
::gametable::mc::IncludePlayerType		"Includi tipo giocatore"
::gametable::mc::ShowTournamentTable	"Tabella torneo"

::gametable::mc::Long						"Lungo"
::gametable::mc::Short						"Corto"

::gametable::mc::AccelBrowse				"W"
::gametable::mc::AccelOverview			"O"
::gametable::mc::AccelTournTable			"T"
::gametable::mc::Space						"Spazio"

::gametable::mc::F_Number					"#"
::gametable::mc::F_White					"Bianco"
::gametable::mc::F_Black					"Nero"
::gametable::mc::F_Event					"Evento"
::gametable::mc::F_Site						"Sito"
::gametable::mc::F_Date						"Data"
::gametable::mc::F_Result					"Risultato"
::gametable::mc::F_Round					"Turno"
::gametable::mc::F_Annotator				"Commentatore"
::gametable::mc::F_Length					"Lunghezza"
::gametable::mc::F_Termination			"Terminazione"
::gametable::mc::F_EventMode				"Modalità"
::gametable::mc::F_Eco						"ECO"
::gametable::mc::F_Flags					"Identificatori"
::gametable::mc::F_Material				"Materiale"
::gametable::mc::F_Acv						"ACV"
::gametable::mc::F_Idn						"960"
::gametable::mc::F_Position				"Posizione"
::gametable::mc::F_EventDate				"Data Evento"
::gametable::mc::F_EventType				"Tipo Ev."
::gametable::mc::F_Changed					"Modificato"
::gametable::mc::F_Promotion				"Promozione"
::gametable::mc::F_UnderPromo				"Sotto-Promozione"
::gametable::mc::F_StandardPos			"Posizione Standard"
::gametable::mc::F_Chess960Pos			"9"
::gametable::mc::F_Opening					"Apertura"
::gametable::mc::F_Variation				"Variante"
::gametable::mc::F_Subvariation			"Sottovariante"
::gametable::mc::F_Overview				"Panoramica"
::gametable::mc::F_Key						"Codice ECO interno"

::gametable::mc::T_Number					"Numero"
::gametable::mc::T_Acv						"Annotazioni / Commenti / Varianti"
::gametable::mc::T_WhiteRatingType		"Tipo punteggio Bianco"
::gametable::mc::T_BlackRatingType		"Tipo punteggio Nero"
::gametable::mc::T_WhiteCountry			"Federazione Bianco"
::gametable::mc::T_BlackCountry			"Federazione Nero"
::gametable::mc::T_WhiteTitle				"Titolo del bianco"
::gametable::mc::T_BlackTitle				"Titolo del nero"
::gametable::mc::T_WhiteType				"Tipo bianco"
::gametable::mc::T_BlackType				"Tipo nero"
::gametable::mc::T_WhiteSex				"Genere bianco"
::gametable::mc::T_BlackSex				"Genere nero"
::gametable::mc::T_EventCountry			"Nazione dell'evento"
::gametable::mc::T_EventType				"Tipo dell'evento"
::gametable::mc::T_Chess960Pos			"Posizione Scacchi 960"
::gametable::mc::T_Deleted					"Eliminate"
::gametable::mc::T_EngFlag					"Identificatore Lingua Inglese"
::gametable::mc::T_OthFlag					"Identificatori per Altre Lingue"
::gametable::mc::T_Idn						"Numero Posizione Scacchi 960"
::gametable::mc::T_Annotations			"Annotazioni"
::gametable::mc::T_Comments				"Commenti"
::gametable::mc::T_Variations				"Varianti"
::gametable::mc::T_TimeMode				"Cadenza"

::gametable::mc::P_Rating					"Punteggio"
::gametable::mc::P_RatingType				"Tipo Punteggio"
::gametable::mc::P_Country					"Nazione"
::gametable::mc::P_Title					"Titolo"
::gametable::mc::P_Type						"Tipo"
::gametable::mc::P_Date						"Data"
::gametable::mc::P_Mode						"Modalità"
::gametable::mc::P_Sex						"Genere"
::gametable::mc::P_Name						"Nome"

::gametable::mc::G_White					"Bianco"
::gametable::mc::G_Black					"Nero"
::gametable::mc::G_Event					"Evento"

::gametable::mc::EventType(game)			"Partita"
::gametable::mc::EventType(match)		"Match"
::gametable::mc::EventType(tourn)		"Torneo"
::gametable::mc::EventType(swiss)		"Svizzero"
::gametable::mc::EventType(team)			"Squadre"
::gametable::mc::EventType(k.o.)			"K.O."
::gametable::mc::EventType(simul)		"Simul"
::gametable::mc::EventType(schev)		"Schev"

::gametable::mc::PlayerType(human)		"Umano"
::gametable::mc::PlayerType(program)	"Computer"

::gametable::mc::GameFlags(w)				"Apertura Bianco"
::gametable::mc::GameFlags(b)				"Apertura Nero"
::gametable::mc::GameFlags(m)				"Mediogioco"
::gametable::mc::GameFlags(e)				"Finale"
::gametable::mc::GameFlags(N)				"Novità"
::gametable::mc::GameFlags(p)				"Struttura pedonale"
::gametable::mc::GameFlags(T)				"Tattica"
::gametable::mc::GameFlags(K)				"Lato di re"
::gametable::mc::GameFlags(Q)				"Lato di donna"
::gametable::mc::GameFlags(!)				"Brillante"
::gametable::mc::GameFlags(?)				"Svista"
::gametable::mc::GameFlags(U)				"Utente"
::gametable::mc::GameFlags(*)				"Miglior partita"
::gametable::mc::GameFlags(D)				"Partita decisiva"
::gametable::mc::GameFlags(G)				"Partita modello"
::gametable::mc::GameFlags(S)				"Strategia"
::gametable::mc::GameFlags(^)				"Attacco"
::gametable::mc::GameFlags(~)				"Sacrificio"
::gametable::mc::GameFlags(=)				"Difesa"
::gametable::mc::GameFlags(M)				"Materiale"
::gametable::mc::GameFlags(P)				"Gioco di pezzi"
::gametable::mc::GameFlags(t)				"Svista tattica"
::gametable::mc::GameFlags(s)				"Svista strategica"
::gametable::mc::GameFlags(C)				"Arrocco illegale"
::gametable::mc::GameFlags(I)				"Mossa illegale"

### playertable ########################################################
::playertable::mc::F_LastName					"Cognome"
::playertable::mc::F_FirstName				"Nome"
::playertable::mc::F_FideID					"ID Fide"
::playertable::mc::F_Title						"Titolo"
::playertable::mc::F_Frequency				"Frequenza"

::playertable::mc::T_Federation				"Federazione"
::playertable::mc::T_RatingType				"Tipo punteggio"
::playertable::mc::T_Type						"Tipo"
::playertable::mc::T_Sex						"Genere"
::playertable::mc::T_PlayerInfo				"Identificatore informazioni" ;# "Info Flag" Identificatore informazioni o informazioni sull'identificatore?

::playertable::mc::Find							"Cerca"
::playertable::mc::StartSearch				"Comincia ricerca"
::playertable::mc::ClearEntries				"Pulisci form"
::playertable::mc::NotFound					"Nessun risultato."

::playertable::mc::Name							"Nome"
::playertable::mc::HighestRating				"Punteggio più alto"
::playertable::mc::MostRecentRating			"Punteggio più recente"
::playertable::mc::DateOfBirth				"Data di nascita"
::playertable::mc::DateOfDeath				"Data di morte"
::playertable::mc::FideID						"ID Fide"

::playertable::mc::ShowPlayerCard			"Mostra Informazioni Giocatore..."

### eventtable #########################################################
::eventtable::mc::Attendance	"Frequenza di partecipazione"

### player-card ########################################################
::playercard::mc::PlayerCard					"Informazioni Giocatore"
::playercard::mc::Latest						"Ultimo"
::playercard::mc::Highest						"Più alto"
::playercard::mc::Minimal						"Minimo"
::playercard::mc::Maximal						"Massimo"
::playercard::mc::Win							"Vinte"
::playercard::mc::Draw							"Patte"
::playercard::mc::Loss							"Perse"
::playercard::mc::Total							"Totale"
::playercard::mc::FirstGamePlayed			"Prima partita giocata"
::playercard::mc::LastGamePlayed				"Ultima partita giocata"
::playercard::mc::WhiteMostPlayed			"Apertura più giocata da Bianco"
::playercard::mc::BlackMostPlayed			"Apertura più giocata da Nero"

::playercard::mc::OpenInWebBrowser			"Apri nel browser"
::playercard::mc::OpenPlayerCard				"Apri profilo utente %s"
::playercard::mc::OpenFileCard				"Apri profilo file %s"
::playercard::mc::OpenFideRatingHistory	"Apri storia punteggio FIDE"
::playercard::mc::OpenWikipedia				"Apri biografia Wikipedia"
::playercard::mc::OpenViafCatalog			"Apri catalogo VIAF"
::playercard::mc::OpenPndCatalog				"Apri catalogo della Deutsche Nationalbibliothek"
::playercard::mc::OpenChessgames				"Collezione partite chessgames.com"
::playercard::mc::SeachIn365ChessCom		"Cerca in 365Chess.com"

### twm - tiled window manager #########################################
::twm::mc::Undock	"Sblocca"
::twm::mc::Close	"Chiudi"

### fonts ##############################################################
::font::mc::ChessBaseFontsInstalled				"Caratteri di ChessBase installati con successo."
::font::mc::ChessBaseFontsInstallationFailed	"Installazione dei caratteri di ChessBase fallita."
::font::mc::NoChessBaseFontFound					"Nessun carattere di ChessBase trovato nella cartella '%s'."
::font::mc::ChessBaseFontsAlreadyInstalled	"Caratteri di ChessBase già installati. Installa comunque?"
::font::mc::ChooseMountPoint						"Punto di montaggio della partizione di installazione Windows"
::font::mc::CopyingChessBaseFonts				"Copiando i caratteri di ChessBase"
::font::mc::CopyFile									"Copiando i file %s"
::font::mc::UpdateFontCache						"Aggiornando cache caratteri"

::font::mc::ChooseFigurineFont					"Scegli un font figurine"
::font::mc::ChooseSymbolFont						"Scegli un font per i simboli"
::font::mc::IncreaseFontSize						"Aumenta Grandezza Font"
::font::mc::DecreaseFontSize						"Diminuisci Grandezza Font"

### gamebar ############################################################
::gamebar::mc::StartPosition			"Posizione di partenza"
::gamebar::mc::Players					"Giocatori"
::gamebar::mc::Event						"Eventi"
::gamebar::mc::Site						"Sito"
::gamebar::mc::SeparateHeader			"Separa intestazione"
::gamebar::mc::ShowActiveAtBottom	"Mostra partita attiva in basso"
::gamebar::mc::ShowPlayersOnSeparateLines	"Mostra giocatori su righe separate"
::gamebar::mc::DiscardChanges			"Questa partita è stata modificata.\n\nVuoi davvero annullare i cambiamenti fatti?"
::gamebar::mc::DiscardNewGame			"Vuoi davvero buttare via questa partita?"
::gamebar::mc::NewGameFstPart			"Nuovo"
::gamebar::mc::NewGameSndPart			"Partita"

::gamebar::mc::LockGame					"Blocca Partita"
::gamebar::mc::UnlockGame				"Sblocca Partita"
::gamebar::mc::CloseGame				"Chiudi Partita"

::gamebar::mc::GameNew					"Nuova Partita"
::gamebar::mc::GameNewChess960		"Nuova Partita: Scacchi 960"
::gamebar::mc::GameNewChess960Sym	"Nuova Partita: Scacchi 960 (solo simmetrica)"
::gamebar::mc::GameNewShuffle			"Nuova Partita: Scacchi Shuffle"

::gamebar::mc::AddNewGame				"Salva: Aggiunti nuova partita a %s..."
::gamebar::mc::ReplaceGame				"Salva: Rimpiazza partita in %s..."
::gamebar::mc::ReplaceMoves			"Salva: Sostituisci solo mosse nella partita..."

### browser ############################################################
::browser::mc::BrowseGame			"Sfoglia Partita"
::browser::mc::StartAutoplay		"Inizia Autoplay"
::browser::mc::StopAutoplay		"Ferma Autoplay"
::browser::mc::GoForward			"Vai alla prossima mossa"
::browser::mc::GoBackward			"Vai alla mossa precedente"
::browser::mc::GoForwardFast		"Vai avanti per alcune mosse"
::browser::mc::GoBackFast			"Vai indietro per alcune mosse"
::browser::mc::GotoStartOfGame	"Vai all'inizio della partita"
::browser::mc::GotoEndOfGame		"Vai alla fine della partita"
::browser::mc::IncreaseBoardSize	"Aumenta grandezza scacchiera"
::browser::mc::DecreaseBoardSize	"Diminuisci grandezza scacchiera"
::browser::mc::MaximizeBoardSize	"Ingrandisci dimensione scacchiera"
::browser::mc::MinimizeBoardSize	"Minimizza dimensione scacchiera"

::browser::mc::GotoGame(first)  	"Vai alla prima partita"
::browser::mc::GotoGame(last)   	"Vai all'ultima partita"
::browser::mc::GotoGame(next)		"Goto next game" ;# NEW
::browser::mc::GotoGame(prev)		"Goto previous game" ;# NEW

::browser::mc::LoadGame				"Carica partita"
::browser::mc::MergeGame			"Unisci partita"

::browser::mc::IllegalMove			"Mossa illegale"
::browser::mc::NoCastlingRights	"Impossibile arroccare"

### overview ###########################################################
::overview::mc::Overview				"Panoramica"
::overview::mc::RotateBoard			"Ruota scacchiera"
::overview::mc::AcceleratorRotate	"R"

### encoding ###########################################################
::encoding::mc::AutoDetect				"auto-rilevazione"

::encoding::mc::Encoding				"Codifica"
::encoding::mc::Description			"Descrizione"
::encoding::mc::Languages				"Lingue (Fonts)"
::encoding::mc::UseAutoDetection		"Usa rilevazione automatica"

::encoding::mc::ChooseEncodingTitle	"Scegli codifica"

::encoding::mc::CurrentEncoding		"Codifica attuale:"
::encoding::mc::DefaultEncoding		"Codifica di default:"
::encoding::mc::SystemEncoding		"Codifica di sistema:"

### setup ##############################################################
::setup::mc::Chess960Position			"Posizione Scacchi 960"
::setup::mc::SymmChess960Position	"Posizione Scacchi 960 Simmetrica"
::setup::mc::ShuffleChessPosition	"Posizione Scacchi Shuffle"

### setup board ########################################################
::setup::position::mc::SetStartPosition		"Imposta posizione iniziale"
::setup::position::mc::UsePreviousPosition	"Usa posizione precedente"

::setup::board::mc::SetStartBoard				"Imposta scacchiera iniziale"
::setup::board::mc::SideToMove					"Lato col tratto"
::setup::board::mc::Castling						"Arrocco"
::setup::board::mc::MoveNumber					"Numero mossa"
::setup::board::mc::EnPassantFile				"En passant"
::setup::board::mc::StartPosition				"Posizione iniziale"
::setup::board::mc::Fen								"FEN"
::setup::board::mc::Clear							"Pulisci"
::setup::board::mc::CopyFen						"Copia FEN a clipboard"
::setup::board::mc::Shuffle						"Mischia..."
::setup::board::mc::StandardPosition			"Posizione Standard"
::setup::board::mc::Chess960Castling			"Arrocco da Scacchi 960"

::setup::board::mc::InvalidFen					"FEN non valido"
::setup::board::mc::CastlingWithoutRook		"Hai segnato il diritto di arroccare, ma almeno una torre di arrocco manca. Questo può succedere solo in partite con handicap. Sei sicuro che ci sia la possibilità di arroccare?"
::setup::board::mc::UnsupportedVariant			"La posizione è una posizione iniziale ma non di Scacchi Mischiati - Shuffle Chess. Sei sicuro?"

::setup::board::mc::ChangeToFormat(xfen)				"Change to X-Fen format" ;# NEW
::setup::board::mc::ChangeToFormat(shredder)			"Change to Shredder format" ;# NEW

::setup::board::mc::Error(InvalidFen)					"FEN non valido."
::setup::board::mc::Error(NoWhiteKing)					"Manca il re bianco."
::setup::board::mc::Error(NoBlackKing)					"Manca il re nero."
::setup::board::mc::Error(DoubleCheck)					"Entrambi i re sono sotto scacco."
::setup::board::mc::Error(OppositeCheck)				"Il lato senza tratto è sotto scacco."
::setup::board::mc::Error(TooManyWhitePawns)			"Troppi pedoni bianchi."
::setup::board::mc::Error(TooManyBlackPawns)			"Troppi pedoni neri."
::setup::board::mc::Error(TooManyWhitePieces)		"Troppi pezzi bianchi."
::setup::board::mc::Error(TooManyBlackPieces)		"Troppi pezzi neri."
::setup::board::mc::Error(PawnsOn18)					"Pedone sulla prima o ottava traversa."
::setup::board::mc::Error(TooManyKings)				"Ci sono più di due re."
::setup::board::mc::Error(TooManyWhite)				"Troppi pezzi bianchi."
::setup::board::mc::Error(TooManyBlack)				"Troppi pezzi neri."
::setup::board::mc::Error(BadCastlingRights)			"Cattivi diritti di arrocco."
::setup::board::mc::Error(InvalidCastlingRights)	"Colonna della torre di arrocco non ragionevole."
::setup::board::mc::Error(InvalidCastlingFile)		"Colonna di arrocco non valida."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"Per arroccare bisogna disambiguare la colonna della torre (è possibile siano messe male)."
::setup::board::mc::Error(InvalidEnPassant)			"Colonna di en passant non ragionevole."
::setup::board::mc::Error(MultiPawnCheck)				"Due o più pedoni danno scacco."
::setup::board::mc::Error(TripleCheck)					"Tre o più pezzi danno scacco."

### import #############################################################
::import::mc::ImportingPgnFile					"Importando file PGN '%s'"
::import::mc::ImportingDatabase					"Importing database '%s'" ;# NEW
::import::mc::Line									"Linea"
::import::mc::Column									"Colonna"
::import::mc::GameNumber							"Partita"
::import::mc::ImportedGames						"%s partite importate"
::import::mc::NoGamesImported						"Nessuna partita importata"
::import::mc::FileIsEmpty							"Il file è probabilmente vuoto"
::import::mc::DatabaseImport						"Importa Database"
::import::mc::ImportPgnGame						"Importa partita in PGN"
::import::mc::ImportPgnVariation					"Importa variante in PGN"
::import::mc::ImportOK								"Testo PGN importato senza errori o avvertimenti."
::import::mc::ImportAborted						"Importazione interrotta."
::import::mc::TextIsEmpty							"Testo PGN vuoto."
::import::mc::AbortImport							"Annulla importazione PGN?"

::import::mc::DifferentEncoding					"La codifica selezionata %src non corrisponde alla codifica del file %dst."
::import::mc::DifferentEncodingDetails			"La ricodifica del database non avrà più successo dopo questa azione."
::import::mc::CannotDetectFigurineSet			"Impossibile auto-rilevare un set figurine adatto."
::import::mc::CheckImportResult					"Per favore controlla che un set figurine adatto sia stato rilevato."
::import::mc::CheckImportResultDetail			"In rari casi l'auto-rilevamento fallisce per ambiguità."

::import::mc::EnterOrPaste							"Inserisci o incolla un PGN %s nel campo in alto.\nErrori legati all'importazione di %s saranno mostrati qui."
::import::mc::EnterOrPaste-Game					"partita"
::import::mc::EnterOrPaste-Variation			"variante"

::import::mc::MissingWhitePlayerTag				"Manca giocatore bianco"
::import::mc::MissingBlackPlayerTag				"Manca giocatore nero"
::import::mc::MissingPlayerTags					"Mancano i giocatori"
::import::mc::MissingResult						"Manca risultato (alla fine della selezione mosse)"
::import::mc::MissingResultTag					"Manca risultato (nella sezione tag)"
::import::mc::InvalidRoundTag						"Tag turno non valida"
::import::mc::InvalidResultTag					"Tag risultato non valida"
::import::mc::InvalidDateTag						"Tag data non valida"
::import::mc::InvalidEventDateTag				"Tag data evento non valida"
::import::mc::InvalidTimeModeTag					"Tag cadenza non valida"
::import::mc::InvalidEcoTag						"Tag ECO non valida"
::import::mc::InvalidTagName						"Tag nome non valida (ignorata)"
::import::mc::InvalidCountryCode					"Codice paese non valido"
::import::mc::InvalidRating						"Valore punteggio non valido"
::import::mc::InvalidNag							"NAG non valido"
::import::mc::BraceSeenOutsideComment			"\"\}\" visto fuori da un commento nella partita (ignorato)"
::import::mc::MissingFen							"Manca FEN (tag variante sarà ignorata)"
::import::mc::UnknownEventType					"Tipo di evento sconosciuto"
::import::mc::UnknownTitle							"Titolo sconosciuto (ignorato)"
::import::mc::UnknownPlayerType					"Tipo di giocatore sconosciuto (ignorato)"
::import::mc::UnknownSex							"Genere sconosciuto (ignorato)"
::import::mc::UnknownTermination					"Ragione del termine sconosciuta"
::import::mc::UnknownMode							"Modalità sconosciuta"
::import::mc::RatingTooHigh						"Elo troppo alto (ignorato)"
::import::mc::TooManyNags							"Troppi NAG (ultimo ignorato)"
::import::mc::IllegalCastling						"Arrocco illegale"
::import::mc::IllegalMove							"Mossa illegale"
::import::mc::CastlingCorrection					"Correzione arrocco"
::import::mc::UnsupportedVariant					"Variante di scacchi non supportata"
::import::mc::UnsupportedCrazyhouseVariant	"Variant Crazyhouse is not yet supported (game skipped)" ;# NEW
::import::mc::DecodingFailed						"La decodifica di questa partita non è stata possibile"
::import::mc::ResultDidNotMatchHeaderResult	"Il risultato non corrisponde alle informazioni fornite"
::import::mc::ValueTooLong							"Il valore del tag è troppo lungo e sarà interrotto a 255 caratteri"
::import::mc::MaximalErrorCountExceeded		"Numero massimo di errori superato; non saranno riportati altri errori analoghi"
::import::mc::MaximalWarningCountExceeded	"Numero massimo di avvertimenti superato; non saranno riportati altri avvertimenti analoghi"
::import::mc::InvalidToken							"Token non valido"
::import::mc::InvalidMove							"Mossa non valida"
::import::mc::UnexpectedSymbol					"Simbolo inatteso"
::import::mc::UnexpectedEndOfInput				"Fine dell'inserimento inatteso"
::import::mc::UnexpectedResultToken				"Token del risultato inatteso"
::import::mc::UnexpectedTag						"Tag all'interno della partita inattesa"
::import::mc::UnexpectedEndOfGame				"Fine partita inattesa (manca il risultato)"
::import::mc::TagNameExpected						"Errore di sintassi: serve un nome per il Tag"
::import::mc::TagValueExpected					"Errore di sintassi: serve un valore per il Tag"
::import::mc::InvalidFen							"FEN non valido"
::import::mc::UnterminatedString					"Stringa indeterminata"
::import::mc::UnterminatedVariation				"Variante indeterminata"
::import::mc::TooManyGames							"Troppe partite nel database (interrotto)"
::import::mc::GameTooLong							"Partita troppo lunga (saltata)"
::import::mc::FileSizeExceeded					"La grandezza massima del file (2GB) sarà superata (interrotto)"
::import::mc::TooManyPlayerNames					"Troppi nomi di giocatori nel database (interrotto)"
::import::mc::TooManyEventNames					"Troppi nomi di eventi nel database (interrotto)"
::import::mc::TooManySiteNames					"Troppi nomi di siti nel database (interrotto)"
::import::mc::TooManyRoundNames					"Troppi turni nel database"
::import::mc::TooManyAnnotatorNames				"Troppi nomi di commentatori nel database (interrotto)"
::import::mc::TooManySourceNames					"Troppi nomi fonte nel database (interrotto)"
::import::mc::SeemsNotToBePgnText				"Potrebbe non essere un testo PGN"
::import::mc::AbortedDueToInternalError		"Annullato per errore interno"
::import::mc::AbortedDueToIoError				"Aborted due to an read/write error" ;# NEW
::import::mc::UserHasInterrupted					"User has interrupted" ;# NEW

### export #############################################################
::export::mc::FileSelection				"&Selezione File"
::export::mc::OptionsSetup					"&Opzioni"
::export::mc::PageSetup						"Set&up pagina"
::export::mc::DiagramSetup					"&Diagram Setup"
::export::mc::StyleSetup					"Sti&le"
::export::mc::EncodingSetup				"Codi&fica"
::export::mc::TagsSetup						"&Tags"
::export::mc::NotationSetup				"&Notazione"
::export::mc::AnnotationSetup				"&Annotazione"
::export::mc::CommentsSetup				"&Commenti"

::export::mc::Visibility					"Visibilità"
::export::mc::HideDiagrams					"Nascondi Diagrammi"
::export::mc::AllFromWhitePersp			"Tutto dalla prospettiva del Bianco"
::export::mc::AllFromBlackPersp			"Tutto dalla prospettiva del Nero"
::export::mc::ShowCoordinates				"Mostra coordinate"
::export::mc::ShowSideToMove				"Mostra lato con il tratto"
::export::mc::ShowArrows					"Mostra Frecce"
::export::mc::ShowMarkers					"Mostra Codici"
::export::mc::Layout							"Layout"
::export::mc::PostscriptSpecials			"Speciali Postscript"
::export::mc::BoardSize						"Grandezza Scacchiera"

::export::mc::Short							"Corto"
::export::mc::Long							"Lungo"
::export::mc::Algebraic						"Algebrico"
::export::mc::Correspondence				"Corrispondenza"
::export::mc::Telegraphic					"Telegrafico"
::export::mc::FontHandling					"Gestione caratteri"
::export::mc::DiagramStyle					"Stile Diagramma"
::export::mc::UseImagesForDiagram		"Usa immagini per la generazione dei diagrammi"
::export::mc::EmebedTruetypeFonts		"Inserisci fond TrueType"
::export::mc::UseBuiltinFonts				"Usa caratteri nativi"
::export::mc::SelectExportedTags			"Selezione dei tag per l'esportazione"
::export::mc::ExcludeAllTags				"Escludi tutti i tag"
::export::mc::IncludeAllTags				"Includi tutti i tag"
::export::mc::ExtraTags						"Tutti gli altri tag"
::export::mc::NoComments					"Nessun commento"
::export::mc::AllLanguages					"Tutte le lingue"
::export::mc::Significant					"Significativo"
::export::mc::LanguageSelection			"Selezione Lingua"
::export::mc::MapTo							"Mappa NAG a" ;# (map to)
::export::mc::MapNagsToComment			"Mappa annotazioni (NAG) a commenti" ;# (map annotations to comments)
::export::mc::UnusualAnnotation			"Annotazione Inusuali"
::export::mc::AllAnnotation				"Tutte le annotazioni"
::export::mc::UseColumnStyle				"Usa stile colonna"
::export::mc::MainlineStyle				"Stile Linea Principale"
::export::mc::HideVariations				"Nascondi Varianti"

::export::mc::PdfFiles						"File PDF"
::export::mc::HtmlFiles						"File HTML"
::export::mc::TeXFiles						"File LaTeX"

::export::mc::ExportDatabase				"Esporta Database"
::export::mc::ExportDatabaseTitle		"Esporta Database '%s'"
::export::mc::ExportingDatabase			"Sto esportando '%s' nel file '%s'"
::export::mc::Export							"Esporta"
::export::mc::NoGamesCopied				"No games exported." ;# NEW
::export::mc::ExportedGames				"%s partite esportate"
::export::mc::NoGamesForExport			"Nessuna partita da esportare."
::export::mc::ResetDefaults				"Torna a valori di default"
::export::mc::UnsupportedEncoding		"Impossibile usare codifica %s per documenti PDF. Devi usare una codifica alternativa."
::export::mc::DatabaseIsOpen				"The destination database '%s' is open, this means that the destination database will be emptied before the export is starting. Export anyway?" ;# NEW
::export::mc::DatabaseIsOpenDetail		"If you want to append instead you should use a Drag&Drop operation inside the database switcher." ;# NEW
::export::mc::ExportGamesFromTo			"Export games from '%src' to '%dst'" ;# NEW

::export::mc::BasicStyle					"Stile base"
::export::mc::GameInfo						"Informazioni della partita"
::export::mc::GameText						"Testo della partita"
::export::mc::Moves							"Mosse"
::export::mc::MainLine						"Linea principale"
::export::mc::Variation						"Variante"
::export::mc::Subvariation					"Sottovariante"
::export::mc::Figurines						"Figurines"
::export::mc::Hyphenation					"Sillabazione"
::export::mc::None							"(nessuno)"
::export::mc::Symbols						"Simboli"
::export::mc::Comments						"Commenti"
::export::mc::Result							"Risultato"
::export::mc::Diagram						"Diagramma"
::export::mc::ColumnStyle					"Stile Colonna"

::export::mc::Paper							"Pagine"
::export::mc::Orientation					"Orientamento"
::export::mc::Margin							"Margine"
::export::mc::Format							"Formato"
::export::mc::Size							"Grandezza"
::export::mc::Custom							"Personalizza"
::export::mc::Potrait						"Ritratto"
::export::mc::Landscape						"Panoramica"
::export::mc::Justification				"Giustificazione"
::export::mc::Even							"Pareggia"
::export::mc::Columns						"Colonne"
::export::mc::One								"Uno"
::export::mc::Two								"Due"

::export::mc::DocumentStyle				"Stile Documento"
::export::mc::Article						"Articolo"
::export::mc::Report							"Report"
::export::mc::Book							"Libro"

::export::mc::FormatName(scidb)			"Scidb"
::export::mc::FormatName(scid)			"Scid"
::export::mc::FormatName(pgn)				"PGN"
::export::mc::FormatName(pdf)				"PDF"
::export::mc::FormatName(html)			"HTML"
::export::mc::FormatName(tex)				"LaTeX"
::export::mc::FormatName(ps)				"Postscript"

::export::mc::Option(pgn,include_varations)						"Esporta variante"
::export::mc::Option(pgn,include_comments)						"Esporta commenti"
::export::mc::Option(pgn,include_moveinfo)						"Esporta informazioni mossa (come commenti)"
::export::mc::Option(pgn,include_marks)							"Esporta codici (come commenti)"
::export::mc::Option(pgn,use_scidb_import_format)				"Usa formato importazione Scidb" ;# [chessbase?]
::export::mc::Option(pgn,use_chessbase_format)					"Usa formato ChessBase"
::export::mc::Option(pgn,include_ply_count_tag)					"Scrivi tag 'PlyCount'"
::export::mc::Option(pgn,include_termination_tag)				"Scrivi tag 'Termination'"
::export::mc::Option(pgn,include_mode_tag)						"Scrivi tag 'Mode'"
::export::mc::Option(pgn,include_opening_tag)					"Scrivi tag 'Opening', 'Variation', 'Subvariation'"
::export::mc::Option(pgn,include_setup_tag)						"Scrivi tag 'Setup' (se necessario)"
::export::mc::Option(pgn,include_variant_tag)					"Scrivi tag 'Variant' (se necessario)"
::export::mc::Option(pgn,include_position_tag)					"Scrivi tag 'Position' (se necessario)"
::export::mc::Option(pgn,include_time_mode_tag)					"Scrivi tag 'TimeMode' (se necessario)"
::export::mc::Option(pgn,exclude_extra_tags)						"Escludi tag estranei"
::export::mc::Option(pgn,indent_variations)						"Indenta varianti"
::export::mc::Option(pgn,indent_comments)							"Indenta commenti"
::export::mc::Option(pgn,column_style)								"Stile Colonna (una mossa per riga)"
::export::mc::Option(pgn,symbolic_annotation_style)			"Annotazione simbolica (!, !?)"
::export::mc::Option(pgn,extended_symbolic_style)				"Espandi stile notazione simbolica (+=, +/-)"
::export::mc::Option(pgn,convert_null_moves)						"Trasforma mosse nulle a commento"
::export::mc::Option(pgn,space_after_move_number)				"Aggiungi spazio dopo numero mossa"
::export::mc::Option(pgn,shredder_fen)								"Scrivi in Shredder-FEN (default è X-FEN)"
::export::mc::Option(pgn,convert_lost_result_to_comment)		"Scrivi commento per risultato '0-0'"
::export::mc::Option(pgn,append_mode_to_event_type)			"Aggiungi modalità dopo il tipo dell'evento"
::export::mc::Option(pgn,comment_to_html)							"Scrivi commento in stile HTML"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Escludi partite con mosse illegali"
::export::mc::Option(pgn,use_utf8_encoding)						"Usa encoding UTF-8"

### notation ###########################################################
::notation::mc::Notation		"Notazione"

::notation::mc::MoveForm(alg)	"Algebrico"
::notation::mc::MoveForm(san)	"Algebrico Abbreviato"
::notation::mc::MoveForm(lan)	"Algebrico Completo"
::notation::mc::MoveForm(eng)	"Inglese"
::notation::mc::MoveForm(cor)	"Corrispondenza"
::notation::mc::MoveForm(tel)	"Telegrafico"

### figurine ###########################################################
::figurines::mc::Figurines	"Figurines"
::figurines::mc::Graphic	"Grafica"
::figurines::mc::User		"Utente" ;# "Definito dall'utente"

### save/replace #######################################################
::dialog::save::mc::SaveGame						"Salva Partita"
::dialog::save::mc::ReplaceGame					"Sostituisci Partita"
::dialog::save::mc::EditCharacteristics		"Modifica caratteristiche"
	
::dialog::save::mc::GameData						"Dati Partita"
::dialog::save::mc::Event							"Evento"

::dialog::save::mc::MatchesExtraTags			"Concordanze Tag / Estranee"
::dialog::save::mc::PressToSelect				"Premi da Ctrl+0 a Ctrl+9 (o tasto sinistro del mouse) per selezionare"
::dialog::save::mc::PressForWhole				"Premi da Alt-0 a Alt-9 (o tasto centrale del mouse) per l'intera selezione dati"
::dialog::save::mc::EditTags						"Modifica Tag"
::dialog::save::mc::RemoveThisTag				"Eliminare tag '%s'?"
::dialog::save::mc::TagAlreadyExists			"Il nome tag '%s' esiste già."
::dialog::save::mc::TagRemoved					"La tag '%s' (valore attuale: '%s') sarà eliminata."
::dialog::save::mc::TagNameIsReserved			"Nome tag '%s' è riservato."
::dialog::save::mc::Locked							"Chiuso"
::dialog::save::mc::OtherTag						"Altra tag"
::dialog::save::mc::NewTag							"Aggiungi tag"
::dialog::save::mc::RemoveTag						"Eliminare tag"
::dialog::save::mc::SetToGameDate				"Imposta a data partita"
::dialog::save::mc::SaveGameFailed				"Salvataggio partita fallito."
::dialog::save::mc::SaveGameFailedDetail		"Guarda il log per maggiori dettagli."
::dialog::save::mc::SavingGameLogInfo			"Salvataggio partita (%white - %black, %event) nel database '%base'"
::dialog::save::mc::CurrentBaseIsReadonly		"L'attuale database '%s' è per sola-lettura."
::dialog::save::mc::CurrentGameHasTrialMode	"L'attuale partita è in modalità di prova e non può essere salvata."

::dialog::save::mc::LocalName						"&Nome locale"
::dialog::save::mc::EnglishName					"Nome &Inglese"
::dialog::save::mc::ShowRatingType				"Mostra &punteggio"
::dialog::save::mc::EcoCode						"&Codice ECO"
::dialog::save::mc::Matches						"&Match"
::dialog::save::mc::Tags							"&Tags"

::dialog::save::mc::Label(name)					"Nome"
::dialog::save::mc::Label(fideID)				"Fide-ID"
::dialog::save::mc::Label(value)					"Valore"
::dialog::save::mc::Label(title)					"Titolo"
::dialog::save::mc::Label(rating)				"Elo"
::dialog::save::mc::Label(federation)			"Federazione"
::dialog::save::mc::Label(country)				"Nazione"
::dialog::save::mc::Label(eventType)			"Tipo"
::dialog::save::mc::Label(sex)					"Sesso/Tipe"
::dialog::save::mc::Label(date)					"Data"
::dialog::save::mc::Label(eventDate)			"Data Evento"
::dialog::save::mc::Label(round)					"Turno"
::dialog::save::mc::Label(result)				"Risultato"
::dialog::save::mc::Label(termination)			"Terminazione"
::dialog::save::mc::Label(annotator)			"Commentatore"
::dialog::save::mc::Label(site)					"Luogo"
::dialog::save::mc::Label(eventMode)			"Modalità"
::dialog::save::mc::Label(timeMode)				"Cadenza"
::dialog::save::mc::Label(frequency)			"Frequenza"
::dialog::save::mc::Label(score)					"Rating" ;#"Second rating"

::dialog::save::mc::GameBase						"Base Partite"
::dialog::save::mc::PlayerBase					"Base Giocatori"
::dialog::save::mc::EventBase						"Base Eventi"
::dialog::save::mc::SiteBase						"Base Siti"
::dialog::save::mc::AnnotatorBase				"Base Commentatori"
::dialog::save::mc::History						"Storia"

::dialog::save::mc::InvalidEntry					"'%s' non è un valore valido."
::dialog::save::mc::InvalidRoundEntry			"'%s' non è un valido valore di turno."
::dialog::save::mc::InvalidRoundEntryDetail	"Valori di turno validi sono '4' o '6.1'. Lo zero non è permesso."
::dialog::save::mc::RoundIsTooHigh				"I turni devono essere meno di 256."
::dialog::save::mc::SubroundIsTooHigh			"I sotto-turni devono essere meno di 256."
::dialog::save::mc::ImplausibleDate				"La data della partita '%s' è precedente a quella dell'evento '%s'."
::dialog::save::mc::InvalidTagName				"Nome tag non valido '%s' (errore di sintassi)."
::dialog::save::mc::Field							"Campo '%s': "
::dialog::save::mc::ExtraTag						"Tag Extra '%s': "
::dialog::save::mc::InvalidNetworkAddress		"Indirizzo network non valido '%s'."
::dialog::save::mc::InvalidCountryCode			"Codice nazione non valido '%s'."
::dialog::save::mc::InvalidEventRounds			"Numero di turni per l'evento non valido '%s' (serve un intero positivo)."
::dialog::save::mc::InvalidPlyCount				"Numero mosse non valido '%s' (serve un intero positivo)."
::dialog::save::mc::IncorrectPlyCount			"Numero mosse scorretto '%s' (il numero corretto è %s)."
::dialog::save::mc::InvalidTimeControl			"Cadenza inserita in '%s' non valida."
::dialog::save::mc::InvalidDate					"Data non valida '%s'."
::dialog::save::mc::InvalidYear					"Anno non valido '%s'."
::dialog::save::mc::InvalidMonth					"Mese non valido '%s'."
::dialog::save::mc::InvalidDay					"Giorno non valido '%s'."
::dialog::save::mc::MissingYear					"Manca l'anno."
::dialog::save::mc::MissingMonth					"Manca il mese."
::dialog::save::mc::StringTooLong				"Tag %tag%: la stringa '%value%' è troppo lunga e sarà troncata a '%trunc%'."
::dialog::save::mc::InvalidEventDate			"Non posso accettare la data inserita: La differenza tra l'anno della partita e l'anno dell'evento dovrebbe essere meno di 4 (restrizione del formato database di Scid)."
::dialog::save::mc::TagIsEmpty					"Tag '%s' is empty (will be discarded)."

### gamehistory ########################################################
::game::history::mc::GameHistory	"Storia della Partita"

### game ###############################################################
::game::mc::CloseDatabase					"Chiudi Database"
::game::mc::CloseAllGames					"Chiudere tutte le partite aperte del database '%s'?"
::game::mc::SomeGamesAreModified			"Alcune partite nel database '%s' sono state modificate. Chiudo comunque?"
::game::mc::AllSlotsOccupied				"Tutti i posti per le partite sono occupati."
::game::mc::ReleaseOneGame					"Per favore chiudi una partita prima di caricarne un'altra."
::game::mc::GameAlreadyOpen				"La partita è già aperta ma modificata. Annulla modifiche a questa partita?"
::game::mc::GameAlreadyOpenDetail		"'%s' aprirà una nuova partita."
::game::mc::GameHasChanged					"La partita %s è stata modificata."
::game::mc::GameHasChangedDetail			"Probabilmente questa non è la partita giusta in virtù di cambiamenti nel database"
::game::mc::CorruptedHeader				"Intestazione corrotta nel file di ripristino '%s'." ;#di ripristino? da ripristinare?
::game::mc::RenamedFile						"File rinominato in '%s.bak'."
::game::mc::CannotOpen						"Impossibile aprire file di ripristino '%s'."
::game::mc::GameRestored					"Una partita dall'ultima sessione ripristinata."
::game::mc::GamesRestored					"%s partite dall'ultima sessione ripristinate."
::game::mc::OldGameRestored				"Una partita ripristinata."
::game::mc::OldGamesRestored				"%s partite ripristinate."
::game::mc::ErrorInRecoveryFile			"Errore nel file di ripristino '%s'"
::game::mc::Recovery							"Ripristino"
::game::mc::UnsavedGames					"Ci sono modifiche non salvate."
::game::mc::DiscardChanges					"'%s' annullerà ogni modifica."
::game::mc::ShouldRestoreGame				"Vuoi ripristinare questa partita nella prossima sessione?"
::game::mc::ShouldRestoreGames			"Vuoi ripristinare queste partite nella prossima sessione?"
::game::mc::NewGame							"Nuova partita"
::game::mc::NewGames							"Nuove partite"
::game::mc::Created							"creata" ;#creato?
::game::mc::ClearHistory					"Pulisci Storia"
::game::mc::RemoveSelectedGame			"Rimuovi partita selezionata dalla storia"
::game::mc::GameDataCorrupted				"Dati partita corrotti."
::game::mc::GameDecodingFailed			"La decodifica di questa partita non è stata possibile."
::game::mc::GameDecodingChanged			"Il database è aperto con il set caratteri '%base%', ma questa partita sembra codificata con il set caratteri '%game%', quindi la partita è caricata con il set caratteri identificato."
::game::mc::GameDecodingChangedDetail	"Probabilmente hai aperto il database con il set caratteri sbagliato. Nota che l'identificazione automatica del set caratteri è limitata."

### languagebox ########################################################
::languagebox::mc::AllLanguages	"Tutte le lingue"
::languagebox::mc::None				"Nessuno"

### datebox ############################################################
::widget::datebox::mc::Today		"Oggi"
::widget::datebox::mc::Calendar	"Calendario..."
::widget::datebox::mc::Year		"Anno"
::widget::datebox::mc::Month		"Mese"
::widget::datebox::mc::Day			"Giorno"

### genderbox ##########################################################
::genderbox::mc::Gender(m) "Maschio"
::genderbox::mc::Gender(f) "Femmina"
::genderbox::mc::Gender(c) "Computer"

### terminationbox #####################################################
::terminationbox::mc::Normal				"Normale"
::terminationbox::mc::Unplayed			"Non Giocata"
::terminationbox::mc::Abandoned			"Abbandonata"
::terminationbox::mc::Adjudication		"Aggiudicata"
::terminationbox::mc::Death				"Morte"
::terminationbox::mc::Emergency			"Emergenza"
::terminationbox::mc::RulesInfraction	"Infrazione regole"
::terminationbox::mc::TimeForfeit		"Tempo scaduto"
::terminationbox::mc::Unterminated		"Indeterminato"

### eventmodebox #######################################################
::eventmodebox::mc::OTB				"A tavolino"
::eventmodebox::mc::PM				"Corrispondenza"
::eventmodebox::mc::EM				"E-mail"
::eventmodebox::mc::ICS				"Internet Chess Server"
::eventmodebox::mc::TC				"Telecomunicazione"
::eventmodebox::mc::Analysis		"Analisi"
::eventmodebox::mc::Composition	"Composizione"

### eventtypebox #######################################################
::eventtypebox::mc::Type(game)	"Partita singola"
::eventtypebox::mc::Type(match)	"Match"
::eventtypebox::mc::Type(tourn)	"Round Robin"
::eventtypebox::mc::Type(swiss)	"Torneo con Sistema Svizzero"
::eventtypebox::mc::Type(team)	"Torneo a squadre"
::eventtypebox::mc::Type(k.o.)	"Torneo Knockout"
::eventtypebox::mc::Type(simul)	"Torneo in simultanea"
::eventtypebox::mc::Type(schev)	"Torneo con Sistema Scheveningen"

### timemodebox ########################################################
::timemodebox::mc::Mode(normal)	"Normale"
::timemodebox::mc::Mode(rapid)	"Rapid"
::timemodebox::mc::Mode(blitz)	"Blitz"
::timemodebox::mc::Mode(bullet)	"Bullet"
::timemodebox::mc::Mode(corr)		"Corrispondenza"

### help ###############################################################
::help::mc::Contents					"&Contenuti"
::help::mc::Index						"&Indice"
::help::mc::Search					"&Cerca"

::help::mc::Help						"Aiuto"
::help::mc::MatchEntireWord		"Corrispondi intera parola"
::help::mc::MatchCase				"Corrispondi capitalizzazione"
::help::mc::TitleOnly				"Cerca solo nei titoli"
::help::mc::CurrentPageOnly		"Cerca solo nella pagina corrente"
::help::mc::GoBack					"Vai indietro una pagina"
::help::mc::GoForward				"Vai avanti una pagina"
::help::mc::GotoPage					"Vai alla pagina '%s'"
::help::mc::ExpandAllItems			"Espandi tutti gli oggetti"
::help::mc::CollapseAllItems		"Comprimi tutti gli oggetti"
::help::mc::SelectLanguage			"Selezione Lingua"
::help::mc::NoHelpAvailable		"Nessun file di aiuto disponibile per la lingua italiana.\nPer favore scelti una lingua alternativa\nper la finestra di aiuto."
::help::mc::NoHelpAvailableAtAll	"Nessun file di aiuto disponibile per questo argomento."
::help::mc::KeepLanguage			"Mantenere la lingua %s per le prossime sessioni?"
::help::mc::ParserError				"Errore nel parsing del file %s."
::help::mc::NoMatch					"Nessuna corrispondenza trovata"
::help::mc::MaxmimumExceeded		"Il numero massimo di corrispondenze è ecceduto in alcune pagine."
::help::mc::OnlyFirstMatches		"Solo le prime %s corrispondenze per pagina saranno mostrate."
::help::mc::HideIndex				"Nascondi Indice"
::help::mc::ShowIndex				"Mostra Indice"

::help::mc::FileNotFound			"File non trovato."
::help::mc::CantFindFile			"Impossibile trovare file a %s."
::help::mc::IncompleteHelpFiles	"I file di aiuto sono ancora incompleti. Ci scusiamo."
::help::mc::ProbablyTheHelp		"Probabilmente la pagina di aiuto in una lingua differente può essere una valida alternativa."
::help::mc::PageNotAvailable		"Questa pagina non è disponibile"

::help::mc::Overview					"Visione d'insieme"

### crosstable #########################################################
::crosstable::mc::TournamentTable		"Tabella Torneo"
::crosstable::mc::AverageRating			"Elo medio"
::crosstable::mc::Category					"Categoria"
::crosstable::mc::Games						"partite"
::crosstable::mc::Game						"partita"

::crosstable::mc::ScoringSystem			"Sistema di Punteggio"
::crosstable::mc::Tiebreak					"Tie-Break"
::crosstable::mc::Settings					"Opzioni"
::crosstable::mc::RevertToStart			"Torna ai valori iniziali"
::crosstable::mc::UpdateDisplay			"Aggiorna visualizzazione"

::crosstable::mc::Traditional				"Tradizionale"
::crosstable::mc::Bilbao					"Bilbao"

::crosstable::mc::None						"Nessuna"
::crosstable::mc::Buchholz					"Buchholz"
::crosstable::mc::MedianBuchholz			"Median-Buchholz"
::crosstable::mc::ModifiedMedianBuchholz "Mod. Median-Buchholz"
::crosstable::mc::RefinedBuchholz		"Buchholz Migliorato"
::crosstable::mc::SonnebornBerger		"Sonneborn-Berger"
::crosstable::mc::Progressive				"Punteggio progressivo"
::crosstable::mc::KoyaSystem				"Sistema Koya"
::crosstable::mc::GamesWon					"Numero di partite vinte"
::crosstable::mc::GamesWonWithBlack		"Partite vinte dal Nero"
::crosstable::mc::ParticularResult		"Risultato Particolare"
::crosstable::mc::TraditionalScoring	"Punteggio Tradizionale"

::crosstable::mc::Crosstable				"Tabellone"
::crosstable::mc::Scheveningen			"Scheveningen"
::crosstable::mc::Swiss						"Sistema svizzero"
::crosstable::mc::Match						"Match"
::crosstable::mc::Knockout					"Knockout"
::crosstable::mc::RankingList				"Lista ELO"

::crosstable::mc::Order						"Ordine"
::crosstable::mc::Type						"Tipo Tabella"
::crosstable::mc::Score						"Punteggio"
::crosstable::mc::Alphabetical			"Alfabetico"
::crosstable::mc::Rating					"Elo"
::crosstable::mc::Federation				"Federazione"

::crosstable::mc::Debugging				"Debugging"
::crosstable::mc::Display					"Display"
::crosstable::mc::Style						"Stile"
::crosstable::mc::Spacing					"Spaziatura"
::crosstable::mc::Padding					"Padding"
::crosstable::mc::ShowLog					"Mostra Log"
::crosstable::mc::ShowHtml					"Mostra HTML"
::crosstable::mc::ShowRating				"Elo"
::crosstable::mc::ShowPerformance		"Performance"
::crosstable::mc::ShowWinDrawLoss		"Vinte/Patte/Perse"
::crosstable::mc::ShowTiebreak			"Tiebreak"
::crosstable::mc::ShowOpponent			"Avversario (come Tooltip)" ;# ??
::crosstable::mc::KnockoutStyle			"Stile Tabella Knockout"
::crosstable::mc::Pyramid					"Piramide"
::crosstable::mc::Triangle					"Triangolo"

::crosstable::mc::CrosstableLimit		"Il limite del tabellone di %d giocatori sarà superato."
::crosstable::mc::CrosstableLimitDetail "'%s' sta scegliendo un altro stile tabella."

### info ###############################################################
::info::mc::InfoTitle			"About %s"
::info::mc::Info					"Info"
::info::mc::About					"About"
::info::mc::Contributions		"Contributi"
::info::mc::License				"Licenza"
::info::mc::Localization		"Localizzazione"
::info::mc::Testing				"Testing"
::info::mc::References			"Riferimenti"
::info::mc::System				"Sistema"
::info::mc::FontDesign			"Design del font di scacchi"
::info::mc::ChessPieceDesign	"Design dei pezzi"
::info::mc::BoardThemeDesign	"Design della scacchiera"
::info::mc::FlagsDesign			"Design identificatori miniaturizzati"
::info::mc::IconDesign			"Design icone"
::info::mc::Development			"Development" ;# NEW
::info::mc::Programming			"Programming" ;# NEW
::info::mc::Head					"Head" ;# NEW

::info::mc::Version				"Versione"
::info::mc::Distributed			"Questo programma è distribuito secondo i termini della GNU General Public License."
::info::mc::Inspired				"Scidb è ispirato a Scid 3.6.1, copyrighted \u00A9 1999-2003 by Shane Hudson."
::info::mc::SpecialThanks		"Ringraziamenti speciali a Shane Hudson per il suo incredibile lavoro. I suoi sforzi sono alla base di questa applicazione."

### comment ############################################################
::comment::mc::CommentBeforeMove		"Commento prima della mossa"
::comment::mc::CommentAfterMove		"Commento dopo mossa"
::comment::mc::PrecedingComment		"Commento precedente"
::comment::mc::TrailingComment		"Commento successivo"
::comment::mc::Language					"Lingua"
::comment::mc::AddLanguage				"Aggiungi lingua..."
::comment::mc::SwitchLanguage			"Cambia lingua"
::comment::mc::FormatText				"Formatta testo"
::comment::mc::CopyText					"Copia testo in" ;#Copy text to
::comment::mc::OverwriteContent		"Sovrascrivere contenuto esistente?"
::comment::mc::AppendContent			"Se \"no\" il testo sarà aggiunto."

::comment::mc::LanguageSelection		"Selezione lingua"
::comment::mc::Formatting				"Formattazione"

::comment::mc::Bold						"Grassetto"
::comment::mc::Italic					"Corsivo"
::comment::mc::Underline				"Sottolinea"

::comment::mc::InsertSymbol			"&Inserisci Simbolo..."
::comment::mc::MiscellaneousSymbols	"Simboli vari"
::comment::mc::Figurine					"Figurine"

### annotation #########################################################
::annotation::mc::AnnotationEditor					"Annotazione"
::annotation::mc::TooManyNags							"Troppe annotazioni (l'ultima è stato ignorato)."
::annotation::mc::TooManyNagsDetail					"Massimo %d annotazioni per semimossa permessi."

::annotation::mc::PrefixedCommentaries				"Commenti prima della mossa"
::annotation::mc::MoveAssesments						"Giudizio sulla mossa"
::annotation::mc::PositionalAssessments			"Giudizi posizionali"
::annotation::mc::TimePressureCommentaries		"Commenti Zeitnot"
::annotation::mc::AdditionalCommentaries			"Commenti aggiuntivi"
::annotation::mc::ChessBaseCommentaries			"Commenti ChessBase"

### marks ##############################################################
::marks::mc::MarksPalette			"Tavolozza Simboli"

### move ###############################################################
::move::mc::Action(replace)		"Sostituisci mossa"
::move::mc::Action(variation)		"Aggiungi nuova variante"
::move::mc::Action(mainline)		"Nuova linea principale"
::move::mc::Action(trial)			"Prova variante"
::move::mc::Action(exchange)		"Cambia mossa"
::move::mc::Action(append)			"Append move" ;# NEW
::move::mc::Action(load)			"Load first game with this continuation" ;# NEW

::move::mc::GameWillBeTruncated	"La partita sarà interrotta. Continuare con '%s'?"

### log ################################################################
::log::mc::LogTitle		"Log"
::log::mc::Warning		"Avvertenza"
::log::mc::Error			"Errore"
::log::mc::Information	"Info"

### titlebox ############################################################
::titlebox::mc::Title(GM)		"Grande Maestro (FIDE)"
::titlebox::mc::Title(IM)		"Maestro Internazionale (FIDE)"
::titlebox::mc::Title(FM)		"Maestro Fide (FIDE)"
::titlebox::mc::Title(CM)		"Candidato Maestro (FIDE)"
::titlebox::mc::Title(WGM)		"Grande Mestro Femminile (FIDE)"
::titlebox::mc::Title(WIM)		"Maestro Internazionale Femminile (FIDE)"
::titlebox::mc::Title(WFM)		"Maestro Fide Femminile (FIDE)"
::titlebox::mc::Title(WCM)		"Candidato Maestro Femminile (FIDE)"
::titlebox::mc::Title(HGM)		"Grande Maestro ad honorem (FIDE)"
::titlebox::mc::Title(NM)		"Maestro Nazionale (USCF)"
::titlebox::mc::Title(SM)		"Maestro Senior (USCF)"
::titlebox::mc::Title(LM)		"Maestro a vita (USCF)"
::titlebox::mc::Title(CGM)		"Grande Maestro per corrispondenza (ICCF)"
::titlebox::mc::Title(CIM)		"Maestro Internazionale per corrispondenza (ICCF)"
::titlebox::mc::Title(CLGM)	"Grande Maestro femminile per corrispondenza (ICCF)"
::titlebox::mc::Title(CILM)	"Maestro Internazionale femminile per corrispondenza (ICCF)"
::titlebox::mc::Title(CSIM)	"Maestro Internazionale Senior per corrispondenza (ICCF)"

### messagebox #########################################################
::dialog::mc::Ok				"&OK"
::dialog::mc::Cancel			"&Annulla"
::dialog::mc::Yes				"&Sì"
::dialog::mc::No				"&No"
::dialog::mc::Retry			"&Riprova"
::dialog::mc::Abort			"&Interrompi"
::dialog::mc::Ignore			"I&gnora"
::dialog::mc::Continue		"Con&tinua"

::dialog::mc::Error			"Errore"
::dialog::mc::Warning		"Avvertenza"
::dialog::mc::Information	"Informazioni"
::dialog::mc::Question		"Conferma"

::dialog::mc::DontAskAgain	"Non chiedere più"

### web ################################################################
::web::mc::CannotFindBrowser			"Non ho trovato un browser compatibile."
::web::mc::CannotFindBrowserDetail	"Imposta la variabile d'ambiente BROWSER al tuo browser desiderato."

### colormenu ##########################################################
::colormenu::mc::BaseColor			"Base Colori"
::colormenu::mc::UserColor			"Colori utente"
::colormenu::mc::UsedColor			"Colori usati"
::colormenu::mc::RecentColor		"Colori recenti"
::colormenu::mc::Texture			"Texture"
::colormenu::mc::OpenColorDialog	"Apri finestra colori"
::colormenu::mc::EraseColor		"Elimina colore"
::colormenu::mc::Close				"Chiudi"

### table ##############################################################
::table::mc::Ok							"&Ok"
::table::mc::Cancel						"&Annulla"
::table::mc::Column						"Colonna"
::table::mc::Table						"Tabella"
::table::mc::Configure					"Configura"
::table::mc::Hide							"Nascondi"
::table::mc::ShowColumn					"Mostra colonna"
::table::mc::Foreground					"Primo Piano"
::table::mc::Background					"Sfondo"
::table::mc::DisabledForeground		"Primo Piano eliminato"
::table::mc::SelectionForeground		"Seleziona Primo Piano"
::table::mc::SelectionBackground		"Selezione Sfondo"
::table::mc::HighlightColor			"Evidenzia Sfondo"
::table::mc::Stripes						"Strisce"
::table::mc::MinWidth					"Larghezza minima"
::table::mc::MaxWidth				   "Larghezza massima"
::table::mc::Separator					"Separatore"
::table::mc::AutoStretchColumn		"Espandi colonne automaticamente"
::table::mc::FillColumn					"- Riempi colonna -"
::table::mc::Preview						"Anteprima"
::table::mc::OptimizeColumn			"Ottimizza larghezza colonna"
::table::mc::OptimizeColumns			"Ottimizza tutte le colonne"
::table::mc::FitColumnWidth			"Regola larghezza colonna"
::table::mc::FitColumns					"Regola tutte le colonne"
::table::mc::ExpandColumn				"Expand column width" ;# NEW
::table::mc::SqueezeColumns			"Stringi tutte le colonne"
::table::mc::AccelFitColumns			"Ctrl+,"
::table::mc::AccelOptimizeColumns	"Ctrl+."
::table::mc::AccelSqueezeColumns		"Ctrl+#"

### fileselectionbox ###################################################
::dialog::fsbox::mc::ScidbDatabase			"Database Scidb"
::dialog::fsbox::mc::ScidDatabase			"Database Scidb"
::dialog::fsbox::mc::ChessBaseDatabase		"Database ChessBase"
::dialog::fsbox::mc::PortableGameFile		"File Portatile di partita" ;# Portable Game File?
::dialog::fsbox::mc::ZipArchive				"Archivio ZIP"
::dialog::fsbox::mc::ScidbArchive			"Arvchivio Scidb"
::dialog::fsbox::mc::PortableDocumentFile	"Documento Portatile"
::dialog::fsbox::mc::HypertextFile			"File Ipertestuale"
::dialog::fsbox::mc::TypesettingFile		"File di Typesetting"
::dialog::fsbox::mc::ImageFile				"Image File" ;# NEW
::dialog::fsbox::mc::TextFile					"Text File" ;# NEW
::dialog::fsbox::mc::BinaryFile				"Bin�ry File" ;# NEW
::dialog::fsbox::mc::ShellScript				"Shell Script" ;# NEW
::dialog::fsbox::mc::Executable				"Executable" ;# NEW

::dialog::fsbox::mc::LinkTo					"Collegamento a %s"
::dialog::fsbox::mc::LinkTarget				"Obiettivo collegamento"
::dialog::fsbox::mc::Directory				"Cartella"

::dialog::fsbox::mc::Title(open)				"Select File" ;# NEW
::dialog::fsbox::mc::Title(save)				"Save File" ;# NEW
::dialog::fsbox::mc::Title(dir)				"Choose Directory" ;# NEW

::dialog::fsbox::mc::Content					"Contenuto"
::dialog::fsbox::mc::Open						"Apri"

::dialog::fsbox::mc::FileType(exe)			"Executables" ;# NEW
::dialog::fsbox::mc::FileType(txt)			"Text files" ;# NEW
::dialog::fsbox::mc::FileType(log)			"Log files" ;# NEW
::dialog::fsbox::mc::FileType(bin)			"Binary files" ;# NEW

### choosecolor ########################################################
::dialog::choosecolor::mc::Ok					"&OK"
::dialog::choosecolor::mc::Cancel			"&Cancella"

::dialog::choosecolor::mc::BaseColors		"Base Colori"
::dialog::choosecolor::mc::UserColors		"Colori utente"
::dialog::choosecolor::mc::RecentColors	"Colori recenti"
::dialog::choosecolor::mc::Old				"Vecchio"
::dialog::choosecolor::mc::Current			"Attuale"
::dialog::choosecolor::mc::HexCode			"Codice Esadecimale"
::dialog::choosecolor::mc::ColorSelection	"Selezione Colore"
::dialog::choosecolor::mc::Red				"Rosso"
::dialog::choosecolor::mc::Green				"Verde"
::dialog::choosecolor::mc::Blue				"Blu"
::dialog::choosecolor::mc::Hue				"Tonalità"
::dialog::choosecolor::mc::Saturation		"Saturazione"
::dialog::choosecolor::mc::Value				"Valore"
::dialog::choosecolor::mc::Enter				"Inserisci"
::dialog::choosecolor::mc::AddColor			"Aggiunti colore attuali ai colori utente"

### choosefont #########################################################
::dialog::choosefont::mc::Apply				"&Applica"
::dialog::choosefont::mc::Cancel				"A&nnulla"
::dialog::choosefont::mc::Continue			"Con&tinua"
::dialog::choosefont::mc::FixedOnly			"Solo font &Monospaced"
::dialog::choosefont::mc::Family				"Fam&iglia"
::dialog::choosefont::mc::Font				"&Font"
::dialog::choosefont::mc::Ok					"&OK"
::dialog::choosefont::mc::Reset				"&Reset"
::dialog::choosefont::mc::Size				"&Grandezza"
::dialog::choosefont::mc::Strikeout			"Can&cellato"
::dialog::choosefont::mc::Style				"&Stile"
::dialog::choosefont::mc::Underline			"S&ottolinea"
::dialog::choosefont::mc::Color				"Co&lore"

::dialog::choosefont::mc::Regular			"Regolare"
::dialog::choosefont::mc::Bold				"Grassetto"
::dialog::choosefont::mc::Italic				"Corsivo"
{::dialog::choosefont::mc::Bold Italic}	"Grassetto Corsivo"

::dialog::choosefont::mc::Effects			"Effetti"
::dialog::choosefont::mc::Filter				"Filtro"
::dialog::choosefont::mc::Sample				"Campione"
::dialog::choosefont::mc::SearchTitle		"Ricerca per font monospaced"
::dialog::choosefont::mc::SeveralMinutes	"Questa operazione potrebbe richiedere %d minuti."
::dialog::choosefont::mc::FontSelection	"Seleziona Font"
::dialog::choosefont::mc::Wait				"Aspetta"

### choosedir ##########################################################
::choosedir::mc::ShowPredecessor	"Mostra Precedente"
::choosedir::mc::ShowTail			"Mostra Coda"
::choosedir::mc::Folder				"Cartella"

### fsbox ##############################################################
::fsbox::mc::Name								"Nome"
::fsbox::mc::Size								"Grandezza"
::fsbox::mc::Modified						"Modificato"

::fsbox::mc::Forward							"Avanti a '%s'"
::fsbox::mc::Backward						"Indietro a '%s'"
::fsbox::mc::Delete							"Elimina"
::fsbox::mc::MoveToTrash					"Sposta nel Cestino"
::fsbox::mc::Restore							"Ripristina"
::fsbox::mc::Duplicate						"Duplica"
::fsbox::mc::CopyOf							"Copia di %s"
::fsbox::mc::NewFolder						"Nuova Cartella"
::fsbox::mc::Layout							"Layout"
::fsbox::mc::ListLayout						"Layout della Lista"
::fsbox::mc::DetailedLayout				"Layout Dettagliato"
::fsbox::mc::ShowHiddenDirs				"Mostra carte&lle nascoste"
::fsbox::mc::ShowHiddenFiles				"Mostra &file e cartelle nascoste"
::fsbox::mc::AppendToExisitingFile		"&Aggiungi partite a un file esistente"
::fsbox::mc::Cancel							"&Cancella"
::fsbox::mc::Save								"&Salva"
::fsbox::mc::Open								"A&pri"
::fsbox::mc::Overwrite						"&Sovrascrivi"
::fsbox::mc::Rename							"&Rinomina"
::fsbox::mc::Move								"Muovi"

::fsbox::mc::AddBookmark					"Aggiungi Segnalibro '%s'"
::fsbox::mc::RemoveBookmark				"Rimuovi il segnalibro '%s'"
::fsbox::mc::RenameBookmark				"Rinomina Segnalibro '%s'"

::fsbox::mc::Filename						"Nom&e file:"
::fsbox::mc::Filenames						"Nom&i file:"
::fsbox::mc::Directory						"&Cartella:"
::fsbox::mc::FilesType						"File del &tipo:"
::fsbox::mc::FileEncoding					"&Codifica File:"

::fsbox::mc::Favorites						"Preferiti"
::fsbox::mc::LastVisited					"Ultime Visite"
::fsbox::mc::FileSystem						"File System"
::fsbox::mc::Desktop							"Desktop"
::fsbox::mc::Trash							"Cestino"
::fsbox::mc::Home								"Home"

::fsbox::mc::SelectEncoding				"Selezionare la codifica del database (apre un'interfaccia)"
::fsbox::mc::SelectWhichType				"Selezione che tipo di file visualizzare"
::fsbox::mc::TimeFormat						"%d/%m/%Y %H:%M"

::fsbox::mc::CannotChangeDir				"Non posso cambiare la cartella a '%s'.\nPermesso negato."
::fsbox::mc::DirectoryRemoved				"Non posso passare alla cartella '%s'.\nLa cartella è rimossa."
::fsbox::mc::DeleteFailed					"Rimozione di '%s' fallita."
::fsbox::mc::RestoreFailed					"Ripristino di '%s' fallito."
::fsbox::mc::CommandFailed					"Comando '%s' fallito." 
::fsbox::mc::CopyFailed						"Copia del file '%s' fallita: permesso negato."
::fsbox::mc::CannotCopy						"Non posso creare una copia perché il file '%s' esiste già."
::fsbox::mc::CannotDuplicate				"Impossibile duplicare il file '%s' per mancanza di permessi lettura."
::fsbox::mc::ReallyDuplicateFile			"Vuoi davvero duplicare questo file?"
::fsbox::mc::ReallyDuplicateDetail		"Questo file ha circa %s. Duplicarlo può richiedere del tempo."
::fsbox::mc::ErrorRenaming(folder)		"Errore nel rinominare la cartella '%old' a '%new': permesso negato."
::fsbox::mc::ErrorRenaming(file)			"Errore nel rinominare il file '%old' a '%new': permesso negato."
::fsbox::mc::InvalidFileExt				"Operazione fallita: '%s' ha un'estensione file non valida."
::fsbox::mc::CannotRename					"Impossibile rinominare in '%s' perché questa cartella\file esiste già."
::fsbox::mc::CannotCreate					"Non posso creare la cartella '%s' perché questa cartella\file esiste già."
::fsbox::mc::ErrorCreate					"Errore nel creare la cartella: permesso negato."
::fsbox::mc::FilenameNotAllowed			"Il nome del file '%s' non è permesso."
::fsbox::mc::ContainsTwoDots				"Contiene due punti consecutivi."
::fsbox::mc::ContainsReservedChars		"Contiene caratteri riservati: %s, o un carattere di controllo (ASCII 0-31)."
::fsbox::mc::InvalidFileName				"Il nome del file non può iniziare con un trattino (-) e non può finire con uno spazio o un punto."
::fsbox::mc::IsReservedName				"In alcuni sistemi operativi questo è un nome riservato."
::fsbox::mc::FilenameTooLong				"Il nome del file deve avere meno di 256 caratteri."
::fsbox::mc::InvalidFileExtension		"Estensione file '%s' non valida."
::fsbox::mc::MissingFileExtension		"Manca estensione del file in '%s'."
::fsbox::mc::FileAlreadyExists			"Il file '%s' esiste già.\n\nVuoi sovrascriverlo?"
::fsbox::mc::CannotOverwriteDirectory	"Impossibile rinominare la cartella '%s'."
::fsbox::mc::FileDoesNotExist				"Il file '%s' non esiste."
::fsbox::mc::DirectoryDoesNotExist		"La cartella '%s' non esiste."
::fsbox::mc::CannotOpenOrCreate			"Non posso aprire/creare '%s'. Per favore scegli una cartella."
::fsbox::mc::WaitWhileDuplicating		"Per favore attendere mentre avviene la duplicazione del file..."
::fsbox::mc::FileHasDisappeared			"Il file '%s' è scomparso."
::fsbox::mc::CurrentlyInUse				"Questo file è correntemente in uso."
::fsbox::mc::PermissionDenied				"Permessi negati per la cartella '%s'."
::fsbox::mc::CannotOpenUri					"Impossibile aprire il seguente URI:"
::fsbox::mc::InvalidUri						"Il contenuto trascinato non è una lista valida di URI."
::fsbox::mc::UriRejected					"I seguenti file sono rifiutati:"
::fsbox::mc::UriRejectedDetail			"Solo i seguenti tipi di file possono essere gestiti."
::fsbox::mc::CannotOpenTrashFiles		"Cannot open files from trash:" ;# NEW
::fsbox::mc::CannotOpenRemoteFiles		"Cannot open remote files:" ;# NEW (http://*)
::fsbox::mc::OperationAborted				"Operazione interrotta."
::fsbox::mc::ApplyOnDirectories			"Sei sicuro di voler appllicare l'operazione selezionata sulle (seguenti) cartelle?"
::fsbox::mc::EntryAlreadyExists			"Valore già esistente"
::fsbox::mc::AnEntryAlreadyExists		"Un valore '%s' è già presente."
::fsbox::mc::SourceDirectoryIs			"La cartella d'origine è '%s'."
::fsbox::mc::NewName							"Nuovo nome"

::fsbox::mc::ReallyMove(file,w)			"Vuoi davvero spostare il file '%s' nel cestino?"
::fsbox::mc::ReallyMove(file,r)			"Vuoi davvero spostare il file protetto in scrittura '%s' nel cestino?"
::fsbox::mc::ReallyMove(folder,w)		"Vuoi davvero spostare la cartella '%s' nel cestino?"
::fsbox::mc::ReallyMove(folder,r)		"Vuoi davvero spostare la cartella protetta in scrittura '%s' nel cestino?"
::fsbox::mc::ReallyDelete(file,w)		"Vuoi davvero eliminare il file '%s'? L'operazione è permanente."
::fsbox::mc::ReallyDelete(file,r)		"Vuoi davvero eliminare il file protetto in scrittura '%s'? L'operazione è permanente."
::fsbox::mc::ReallyDelete(link,w)		"Vuoi davvero eliminare il collegamento a '%s'?"
::fsbox::mc::ReallyDelete(link,r)		"Vuoi davvero eliminare il collegamento a '%s'?"
::fsbox::mc::ReallyDelete(folder,w)		"Vuoi davvero eliminare la cartella '%s'? L'operazione è permanente."
::fsbox::mc::ReallyDelete(folder,r)		"Vuoi davvero eliminare la cartella protetta in scrittura '%s'? L'operazione è permanente."

::fsbox::mc::ErrorRenaming(folder)		"Errore nel rinominare la cartella '%old' a '%new': permesso negato."
::fsbox::mc::ErrorRenaming(file)			"Errore nel rinominare il file '%old' a '%new': permesso negato."

::fsbox::mc::Cannot(delete)				"Impossibile eliminare il file '%s'."
::fsbox::mc::Cannot(rename)				"Impossibile rinominare il file '%s'."
::fsbox::mc::Cannot(move)					"Cannot move file '%s'." ;# NEW
::fsbox::mc::Cannot(overwrite)			"Impossibile sovrascrivere il file '%s'."

::fsbox::mc::DropAction(move)				"Sposta qui"
::fsbox::mc::DropAction(copy)				"Copia qui"
::fsbox::mc::DropAction(link)				"Collega qui"

### toolbar ############################################################
::toolbar::mc::Toolbar		"Barra strumenti"
::toolbar::mc::Orientation	"Orientamento"
::toolbar::mc::Alignment	"Allineamento"
::toolbar::mc::IconSize		"Grandezza icone"

::toolbar::mc::Default		"Default"
::toolbar::mc::Small			"Piccolo"
::toolbar::mc::Medium		"Medio"
::toolbar::mc::Large			"Grande"

::toolbar::mc::Top			"In alto"
::toolbar::mc::Bottom		"In basso"
::toolbar::mc::Left			"Sinistra"
::toolbar::mc::Right			"Destra"
::toolbar::mc::Center		"Centro"

::toolbar::mc::Flat			"Piatto"
::toolbar::mc::Floating		"Volante"
::toolbar::mc::Hide			"Nascondi"

::toolbar::mc::Expand		"Espandi"

### Countries ##########################################################
::country::mc::Afghanistan											"Afghanistan"
::country::mc::Netherlands_Antilles								"Antille Olandesi"
::country::mc::Anguilla												"Anguilla"
::country::mc::Aboard_Aircraft									"Velivolo Aereo"
::country::mc::Aaland_Islands										"Isole Åland"
::country::mc::Albania												"Albania"
::country::mc::Algeria												"Algeria"
::country::mc::Andorra												"Andorra"
::country::mc::Angola												"Angola"
::country::mc::Antigua												"Antigua e Barbuda"
::country::mc::Australasia											"Australasia"
::country::mc::Argentina											"Argentina"
::country::mc::Armenia												"Armenia"
::country::mc::Aruba													"Aruba"
::country::mc::American_Samoa										"Samoa Americane"
::country::mc::Antarctica											"Antartide"
::country::mc::French_Southern_Territories					"Territori Francesi Meridionali"
::country::mc::Australia											"Australia"
::country::mc::Austria												"Austria"
::country::mc::Azerbaijan											"Azerbaijan"
::country::mc::Bahamas												"Bahamas"
::country::mc::Bangladesh											"Bangladesh"
::country::mc::Barbados												"Barbados"
::country::mc::Basque												"Paesi Baschi"
::country::mc::Burundi												"Burundi"
::country::mc::Belgium												"Belgio"
::country::mc::Benin													"Benin"
::country::mc::Bermuda												"Bermuda"
::country::mc::Bhutan												"Bhutan"
::country::mc::Bosnia_and_Herzegovina							"Bosnia-Erzegovina"
::country::mc::Belize												"Belize"
::country::mc::Belarus												"Bielorussia"
::country::mc::Bolivia												"Bolivia"
::country::mc::Brazil												"Brazile"
::country::mc::Bahrain												"Bahrain"
::country::mc::Brunei												"Brunei"
::country::mc::Botswana												"Botswana"
::country::mc::Bulgaria												"Bulgaria"
::country::mc::Burkina_Faso										"Burkina Faso"
::country::mc::Bouvet_Islands										"Isola Bouvet"
::country::mc::Central_African_Republic						"Repubblica Centraficana"
::country::mc::Cambodia												"Cambogia"
::country::mc::Canada												"Canada"
::country::mc::Catalonia											"Catalonia"
::country::mc::Cayman_Islands										"Isola Cayman"
::country::mc::Cocos_Islands										"Isole Cocos"
::country::mc::Congo													"Congo-Brazzaville"
::country::mc::Chad													"Chad"
::country::mc::Chile													"Cile"
::country::mc::China													"Cina"
::country::mc::Ivory_Coast											"Costa d'Avorio"
::country::mc::Cameroon												"Cameroon"
::country::mc::DR_Congo												"Repubblica Democratica del Congo"
::country::mc::Cook_Islands										"Isole Cook"
::country::mc::Colombia												"Colombia"
::country::mc::Comoros												"Comore"
::country::mc::Cape_Verde											"Capo Verde"
::country::mc::Costa_Rica											"Costa Rica"
::country::mc::Croatia												"Croazia"
::country::mc::Cuba													"Cuba"
::country::mc::Christmas_Island									"Isola Christmas"
::country::mc::Cyprus												"Cipro"
::country::mc::Czech_Republic										"Repubblica Ceca"
::country::mc::Denmark												"Danimarca"
::country::mc::Djibouti												"Djibouti"
::country::mc::Dominica												"Dominica"
::country::mc::Dominican_Republic								"Repubblica Dominicana"
::country::mc::Ecuador												"Ecuador"
::country::mc::Egypt													"Egitto"
::country::mc::England												"Inghilterra"
::country::mc::Eritrea												"Eritrea"
::country::mc::El_Salvador											"El Salvador"
::country::mc::Western_Sahara										"Sahara Occidentale"
::country::mc::Spain													"Spagna"
::country::mc::Estonia												"Estonia"
::country::mc::Ethiopia												"Etiopia"
::country::mc::Faroe_Islands										"Isole Faroe"
::country::mc::Fiji													"Fiji"
::country::mc::Finland												"Finlandia"
::country::mc::Falkland_Islands									"Isole Falkland"
::country::mc::France												"Francia"
::country::mc::West_Germany										"Germania dell'Ovest"
::country::mc::Micronesia											"Micronesia"
::country::mc::Gabon													"Gabon"
::country::mc::Gambia												"Gambia"
::country::mc::Great_Britain										"Gran Bretagna"
::country::mc::Guinea_Bissau										"Guinea-Bissau"
::country::mc::Gibraltar											"Gibilterra"
::country::mc::Guernsey												"Guernsey"
::country::mc::East_Germany										"Germania dell'Est"
::country::mc::Georgia												"Georgia"
::country::mc::Equatorial_Guinea									"Guinea Equatoriale"
::country::mc::Germany												"Germania"
::country::mc::Ghana													"Ghana"
::country::mc::Guadeloupe											"Guadalupa"
::country::mc::Greece												"Grecia"
::country::mc::Grenada												"Granada"
::country::mc::Greenland											"Groenlandia"
::country::mc::Guatemala											"Guatemala"
::country::mc::French_Guiana										"Guyana Francese"
::country::mc::Guinea												"Guinea"
::country::mc::Guam													"Guam"
::country::mc::Guyana												"Guyana"
::country::mc::Haiti													"Haiti"
::country::mc::Hong_Kong											"Hong Kong"
::country::mc::Heard_Island_and_McDonald_Islands			"Isole Heard e McDonald"
::country::mc::Honduras												"Honduras"
::country::mc::Hungary												"Ungheria"
::country::mc::Isle_of_Man											"Isola di Man"
::country::mc::Indonesia											"Indonesia"
::country::mc::India													"India"
::country::mc::British_Indian_Ocean_Territory				"Territorio britannico dell'oceano Indiano"
::country::mc::Iran													"Iran"
::country::mc::Ireland												"Irlanda"
::country::mc::Iraq													"Iraq"
::country::mc::Iceland												"Islanda"
::country::mc::Israel												"Israele"
::country::mc::Italy													"Italia"
::country::mc::British_Virgin_Islands							"Isole Vergini Britanniche"
::country::mc::Jamaica												"Giamaica"
::country::mc::Jersey												"Jersey"
::country::mc::Jordan												"Giordania"
::country::mc::Japan													"Giappone"
::country::mc::Kazakhstan											"Kazakhstan"
::country::mc::Kenya													"Kenya"
::country::mc::Kosovo												"Kosovo"
::country::mc::Kyrgyzstan											"Kyrgyzstan"
::country::mc::Kiribati												"Kiribati"
::country::mc::South_Korea											"Corea del Sud"
::country::mc::Saudi_Arabia										"Arabia Saudita"
::country::mc::Kuwait												"Kuwait"
::country::mc::Laos													"Laos"
::country::mc::Latvia												"Lettonia"
::country::mc::Libya													"Libia"
::country::mc::Liberia												"Liberia"
::country::mc::Saint_Lucia											"Santa Lucia"
::country::mc::Lesotho												"Lesotho"
::country::mc::Lebanon												"Libano"
::country::mc::Liechtenstein										"Liechtenstein"
::country::mc::Lithuania											"Lituania"
::country::mc::Luxembourg											"Lussemburgo"
::country::mc::Macao													"Macao"
::country::mc::Madagascar											"Madagascar"
::country::mc::Morocco												"Marocco"
::country::mc::Malaysia												"Malesia"
::country::mc::Malawi												"Malawi"
::country::mc::Moldova												"Moldavia"
::country::mc::Maldives												"Maldive"
::country::mc::Mexico												"Messico"
::country::mc::Mongolia												"Mongolia"
::country::mc::Marshall_Islands									"Isole Marshall"
::country::mc::Macedonia											"Macedonia"
::country::mc::Mali													"Mali"
::country::mc::Malta													"Malta"
::country::mc::Montenegro											"Montenegro"
::country::mc::Northern_Mariana_Islands						"Isole Marianne Settentrionali"
::country::mc::Monaco												"Monaco"
::country::mc::Mozambique											"Mozambico"
::country::mc::Mauritius											"Mauritius"
::country::mc::Montserrat											"Montserrat"
::country::mc::Mauritania											"Mauritania"
::country::mc::Martinique											"Martinica"
::country::mc::Myanmar												"Myanmar"
::country::mc::Mayotte												"Mayotte"
::country::mc::Namibia												"Namibia"
::country::mc::Nicaragua											"Nicaragua"
::country::mc::New_Caledonia										"Nuova Caledonia"
::country::mc::Netherlands											"Olanda"
::country::mc::Nepal													"Nepal"
::country::mc::The_Internet										"Internet"
::country::mc::Norfolk_Island										"Isole Norfolk"
::country::mc::Nigeria												"Nigeria"
::country::mc::Niger													"Niger"
::country::mc::Northern_Ireland									"Irlanda del Nord"
::country::mc::Niue													"Niue"
::country::mc::Norway												"Norvegia"
::country::mc::Nauru													"Nauru"
::country::mc::New_Zealand											"Nuova Zelanda"
::country::mc::Oman													"Oman"
::country::mc::Pakistan												"Pakistan"
::country::mc::Panama												"Panama"
::country::mc::Paraguay												"Paraguay"
::country::mc::Pitcairn_Islands									"Isole Pitcairn"
::country::mc::Peru													"Perù"
::country::mc::Philippines											"Filippine"
::country::mc::Palestine											"Palestina"
::country::mc::Palau													"Palau"
::country::mc::Papua_New_Guinea									"Papua Nuova Guinea"
::country::mc::Poland												"Polonia"
::country::mc::Portugal												"Portogallo"
::country::mc::North_Korea											"Corea del Nord"
::country::mc::Puerto_Rico											"Porto Rico"
::country::mc::French_Polynesia									"Polinesia Francese"
::country::mc::Qatar													"Qatar"
::country::mc::Reunion												"Réunion"
::country::mc::Romania												"Romania"
::country::mc::South_Africa										"Sudafrica"
::country::mc::Russia												"Russia"
::country::mc::Rwanda												"Rwanda"
::country::mc::Samoa													"Samoa"
::country::mc::Serbia_and_Montenegro							"Serbia e Montenegro"
::country::mc::Scotland												"Scozia"
::country::mc::At_Sea												"In mare"
::country::mc::Senegal												"Senegal"
::country::mc::Seychelles											"Seychelles"
::country::mc::South_Georgia_and_South_Sandwich_Islands	"Georgia del Sud e isole Sandwich meridionali"
::country::mc::Saint_Helena										"Sant'Elena"
::country::mc::Singapore											"Singapore"
::country::mc::Jan_Mayen_and_Svalbard							"Svalbard e Jan Mayen"
::country::mc::Saint_Kitts_and_Nevis							"Saint Kitts e Nevis"
::country::mc::Sierra_Leone										"Sierra Leone"
::country::mc::Slovenia												"Slovenia"
::country::mc::San_Marino											"San Marino"
::country::mc::Solomon_Islands									"Isole Salomone"
::country::mc::Somalia												"Somalia"
::country::mc::Aboard_Spacecraft									"Stazione Spaziale Internazionale"
::country::mc::Saint_Pierre_and_Miquelon						"Saint-Pierre e Miquelon"
::country::mc::Serbia												"Serbia"
::country::mc::Sri_Lanka											"Sri Lanka"
::country::mc::Sao_Tome_and_Principe							"Sao Tome e Principe"
::country::mc::Sudan													"Sudan"
::country::mc::Switzerland											"Svizzera"
::country::mc::Suriname												"Suriname"
::country::mc::Slovakia												"Slovacchia"
::country::mc::Sweden												"Svezia"
::country::mc::Swaziland											"Swaziland"
::country::mc::Syria													"Siria"
::country::mc::Tanzania												"Tanzania"
::country::mc::Turks_and_Caicos_Islands						"Isole Turks e Caicos"
::country::mc::Czechoslovakia										"Cecoslovacchia"
::country::mc::Tonga													"Tonga"
::country::mc::Thailand												"Tailandia"
::country::mc::Tibet													"Tibet"
::country::mc::Tajikistan											"Tajikistan"
::country::mc::Tokelau												"Tokelau"
::country::mc::Turkmenistan										"Turkmenistan"
::country::mc::Timor_Leste											"Timor Est"
::country::mc::Togo													"Togo"
::country::mc::Chinese_Taipei										"Taiwan"
::country::mc::Trinidad_and_Tobago								"Trinidad e Tobago"
::country::mc::Tunisia												"Tunisia"
::country::mc::Turkey												"Turchia"
::country::mc::Tuvalu												"Tuvalu"
::country::mc::United_Arab_Emirates								"Emirati Arabi Uniti"
::country::mc::Uganda												"Uganda"
::country::mc::Ukraine												"Ucraina"
::country::mc::United_States_Minor_Outlying_Islands		"Isole minori esterne degli Stati Uniti d'America"
::country::mc::Unknown												"(Sconosciuta)"
::country::mc::Soviet_Union										"Unione Sovietica"
::country::mc::Uruguay												"Uruguay"
::country::mc::United_States_of_America						"Stati Uniti d'America"
::country::mc::Uzbekistan											"Uzbekistan"
::country::mc::Vanuatu												"Vanuatu"
::country::mc::Vatican												"Città del Vaticano"
::country::mc::Venezuela											"Venezuela"
::country::mc::Vietnam												"Vietnam"
::country::mc::Saint_Vincent_and_the_Grenadines				"Saint Vincent e Grenadines"
::country::mc::US_Virgin_Islands									"Isole Vergini Americane"
::country::mc::Wallis_and_Futuna									"Wallis e Futuna"
::country::mc::Wales													"Galles"
::country::mc::Yemen													"Yemen"
::country::mc::Yugoslavia											"Yugoslavia"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzibar"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Squadra mista"

::country::mc::Africa_North										"Africa, Nord"
::country::mc::Africa_Sub_Saharan								"Africa, Sub-Sahara"
::country::mc::America_Caribbean									"America, Caraibi"
::country::mc::America_Central									"America, Centrale"
::country::mc::America_North										"America, Nord"
::country::mc::America_South										"America, Sud"
::country::mc::Antarctic											"Antartide"
::country::mc::Asia_East											"Asia, Est"
::country::mc::Asia_South_South_East							"Asia, Sud-Est"
::country::mc::Asia_West_Central									"Asia, Ovest-Centale"
::country::mc::Europe												"Europa"
::country::mc::Europe_East											"Europa, Est"
::country::mc::Oceania												"Oceania"
::country::mc::Stateless											"Apolide"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"Afrikaans"
::encoding::mc::Lang(ar)	"Arabo"
::encoding::mc::Lang(ast)	"Leonese"
::encoding::mc::Lang(az)	"Azero"
::encoding::mc::Lang(bat)	"Baltico"
::encoding::mc::Lang(be)	"Bielorusso"
::encoding::mc::Lang(bg)	"Bulgaro"
::encoding::mc::Lang(br)	"Bretone"
::encoding::mc::Lang(bs)	"Bosniaco"
::encoding::mc::Lang(ca)	"Catalano"
::encoding::mc::Lang(cs)	"Ceco"
::encoding::mc::Lang(cy)	"Gallese"
::encoding::mc::Lang(da)	"Danese"
::encoding::mc::Lang(de)	"Tedesco"
::encoding::mc::Lang(de+)	"Tedesco (riformato)"
::encoding::mc::Lang(el)	"Greco"
::encoding::mc::Lang(en)	"Inglese"
::encoding::mc::Lang(eo)	"Esperanto"
::encoding::mc::Lang(es)	"Spagnolo"
::encoding::mc::Lang(et)	"Estone"
::encoding::mc::Lang(eu)	"Basco"
::encoding::mc::Lang(fi)	"Finlandese"
::encoding::mc::Lang(fo)	"Faroese"
::encoding::mc::Lang(fr)	"Francese"
::encoding::mc::Lang(fy)	"Frisico"
::encoding::mc::Lang(ga)	"Irlandese"
::encoding::mc::Lang(gd)	"Scozzese"
::encoding::mc::Lang(gl)	"Gaelico"
::encoding::mc::Lang(he)	"Ebreo"
::encoding::mc::Lang(hi)	"Hindi"
::encoding::mc::Lang(hr)	"Croato"
::encoding::mc::Lang(hu)	"Ungherese"
::encoding::mc::Lang(hy)	"Armeno"
::encoding::mc::Lang(ia)	"Interlingua"
::encoding::mc::Lang(is)	"Islandese"
::encoding::mc::Lang(it)	"Italiano"
::encoding::mc::Lang(iu)	"Inuktitut"
::encoding::mc::Lang(ja)	"Giapponese"
::encoding::mc::Lang(ka)	"Georgiano"
::encoding::mc::Lang(kk)	"Kazaka"
::encoding::mc::Lang(kl)	"Groenlandese"
::encoding::mc::Lang(ko)	"Coreano"
::encoding::mc::Lang(ku)	"Curdo"
::encoding::mc::Lang(ky)	"Kyrgyz"
::encoding::mc::Lang(la)	"Latino"
::encoding::mc::Lang(lb)	"Lussemburghese"
::encoding::mc::Lang(lt)	"Lituano"
::encoding::mc::Lang(lv)	"Lettone"
::encoding::mc::Lang(mk)	"Macedone"
::encoding::mc::Lang(mo)	"Moldavo"
::encoding::mc::Lang(ms)	"Malese"
::encoding::mc::Lang(mt)	"Maltese"
::encoding::mc::Lang(nl)	"Olandese"
::encoding::mc::Lang(no)	"Norvegese"
::encoding::mc::Lang(oc)	"Occitano"
::encoding::mc::Lang(pl)	"Polacco"
::encoding::mc::Lang(pt)	"Portoghese"
::encoding::mc::Lang(rm)	"Romancio"
::encoding::mc::Lang(ro)	"Rumeno"
::encoding::mc::Lang(ru)	"Russo"
::encoding::mc::Lang(se)	"Sami"
::encoding::mc::Lang(sk)	"Slovacco"
::encoding::mc::Lang(sl)	"Sloveno"
::encoding::mc::Lang(sq)	"Albanese"
::encoding::mc::Lang(sr)	"Serbo"
::encoding::mc::Lang(sv)	"Svedese"
::encoding::mc::Lang(sw)	"Swahili"
::encoding::mc::Lang(tg)	"Tagico"
::encoding::mc::Lang(th)	"Tailandese"
::encoding::mc::Lang(tk)	"Turkmena"
::encoding::mc::Lang(tl)	"Tagalog"
::encoding::mc::Lang(tr)	"Turco"
::encoding::mc::Lang(uk)	"Ucraino"
::encoding::mc::Lang(uz)	"Usbeco"
::encoding::mc::Lang(vi)	"Vietnamese"
::encoding::mc::Lang(wa)	"Vallone"
::encoding::mc::Lang(wen)	"Lusaziano"
::encoding::mc::Lang(hsb)	"Alto Sorbo" 
::encoding::mc::Lang(dsb)	"Basso Sorbo"
::encoding::mc::Lang(zh)	"Cinese"

::encoding::mc::Font(hi)	"Devanagari"

### Calendar ###########################################################
::calendar::mc::OneMonthForward	"Un mese avanti (Shift \u2192)"
::calendar::mc::OneMonthBackward	"Un mese indietro (Shift \u2190)"
::calendar::mc::OneYearForward	"Un anno avanti (Ctrl \u2192)"
::calendar::mc::OneYearBackward	"Un anno indietro (Ctrl \u2190)"

::calendar::mc::Su	"Do"
::calendar::mc::Mo	"Lu"
::calendar::mc::Tu	"Ma"
::calendar::mc::We	"Me"
::calendar::mc::Th	"Gi"
::calendar::mc::Fr	"Ve"
::calendar::mc::Sa	"Sa"

::calendar::mc::Jan	"Gen"
::calendar::mc::Feb	"Feb"
::calendar::mc::Mar	"Mar"
::calendar::mc::Apr	"Apr"
::calendar::mc::May	"Mag"
::calendar::mc::Jun	"Giu"
::calendar::mc::Jul	"Lug"
::calendar::mc::Aug	"Ago"
::calendar::mc::Sep	"Set"
::calendar::mc::Oct	"Ott"
::calendar::mc::Nov	"Nov"
::calendar::mc::Dec	"Dic"

::calendar::mc::MonthName(1)		"Gennaio"
::calendar::mc::MonthName(2)		"Febbraio"
::calendar::mc::MonthName(3)		"Marzo"
::calendar::mc::MonthName(4)		"Aprile"
::calendar::mc::MonthName(5)		"Maggio"
::calendar::mc::MonthName(6)		"Giugno"
::calendar::mc::MonthName(7)		"Luglio"
::calendar::mc::MonthName(8)		"Agosto"
::calendar::mc::MonthName(9)		"Settembre"
::calendar::mc::MonthName(10)		"Ottobre"
::calendar::mc::MonthName(11)		"Novembre"
::calendar::mc::MonthName(12)		"Dicembre"

::calendar::mc::WeekdayName(0)	"Domenica"
::calendar::mc::WeekdayName(1)	"Lunedì"
::calendar::mc::WeekdayName(2)	"Martedì"
::calendar::mc::WeekdayName(3)	"Mercoledì"
::calendar::mc::WeekdayName(4)	"Giovedì"
::calendar::mc::WeekdayName(5)	"Venerdì"
::calendar::mc::WeekdayName(6)	"Sabato"

### remote #############################################################
::remote::mc::PostponedMessage "Apertura database \"%s\" in pausa fino a che l'operazione attuale non è conclusa."

# vi:set ts=3 sw=3:
