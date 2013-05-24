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
# Copyright: (C) 2011-2013 Gregor Cramer
# Copyright: (C) 2011 Carlos Fernando Gonzalez
# Copyright: (C) 2012 Juan Carlos Vasquez R.
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
::mc::SortMapping		{á a Á A é e É E í i Í I ñ n Ñ N ó o Ó O ú u Ú U}
::mc::AsciiMapping	{á a Á A é e É E í i Í I ñ n Ñ N ó o Ó O ú u Ú U}
::mc::SortOrder		{A Á B C D E É F G H I Í J K L M N Ñ O Ó P Q R S T U Ú V W X Y Z a á b c d e é f g h i í j k l m n ñ o ó p q r s t u ú v w x y z}

::mc::Key(Alt)				"Alt" 
::mc::Key(BS)				"Retroceso"
::mc::Key(Ctrl)			"Ctrl" 
::mc::Key(Del)				"Supr"
::mc::Key(Down)			"\u2193"
::mc::Key(End)				"Fin"
::mc::Key(Enter)			"Intro"
::mc::Key(Esc)				"Esc"
::mc::Key(Home)			"Inicio"
::mc::Key(Ins)				"Ins" ;# NEW
::mc::Key(Left)			"\u2190"
::mc::Key(Next)			"Re Pag" ;# "Página\u2193"
::mc::Key(Prior)			"Av Pag" ;# "Página\u2191"
::mc::Key(Right)			"\u2192"
::mc::Key(Shift)			"Mayúsculas" 
::mc::Key(Space)			"\u2423"
::mc::Key(Up)				"\u2191"

::mc::Alignment			"Alineación"
::mc::Apply					"Aplicar"
::mc::Archive				"Archivo" 
::mc::Background			"Fondo"
::mc::Black					"Negras"
::mc::Bottom				"Inferior"
::mc::Cancel				"Cancelar"
::mc::Clear					"Vaciar"
::mc::Close					"Cerrar"
::mc::Color					"Color"
::mc::Colors				"Colores"
::mc::Configuration		"Configuración"
::mc::Copy					"Copiar"
::mc::Cut					"Cortar"
::mc::Dark					"Oscuras"
::mc::Database				"Base"
::mc::Default				"Estándar"
::mc::Delete				"Eliminar"
::mc::Edit					"Editar"
::mc::File					"Archivo"
::mc::Filter				"Filter" ;# NEW
::mc::From					"De"
::mc::Game					"Partida"
::mc::Layout				"Disposición"
::mc::Left					"Izquierda"
::mc::Lite					"Claras"
::mc::Low					"Bajo"
::mc::Modify				"Modificar"
::mc::No						"no"
::mc::Normal				"Normal"
::mc::Number				"Número"
::mc::OK						"Aceptar"
::mc::Order					"Orden"
::mc::Paste					"Pegar"
::mc::PieceSet				"Piezas"
::mc::Preview				"Vista previa"
::mc::Redo					"Deshacer"
::mc::Remove				"Quitar" 
::mc::Reset					"Restablecer"
::mc::Right					"Derecha"
::mc::SelectAll			"Seleccionar todo"
::mc::Texture				"Textura"
::mc::Theme					"Tema"
::mc::To						"A"
::mc::Top					"Superior"
::mc::Undo					"Deshacer"
::mc::Variant				"Variant" ;# NEW different from "Variation"
::mc::Variation			"Variante"
::mc::White					"Blancas"
::mc::Yes					"Sí"

::mc::Piece(K)				"Rey"
::mc::Piece(Q)				"Dama"
::mc::Piece(R)				"Torre"
::mc::Piece(B)				"Alfil"
::mc::Piece(N)				"Caballo"
::mc::Piece(P)				"Peón"

::mc::Logical(reset)		"Restablecer"
::mc::Logical(or)			"O"
::mc::Logical(and)		"Y"
::mc::Logical(null)		"None" ;# NEW
::mc::Logical(remove)	"Remove" ;# NEW
::mc::Logical(not)		"No"

::mc::LogicalDetail(reset)			"Clear filter / Reset display" ;# NEW
::mc::LogicalDetail(or)				"Remove from filter / Add to display" ;# NEW
::mc::LogicalDetail(and)			"Extend filter / Restrict display" ;# NEW
::mc::LogicalDetail(null)			"Fill filter / Clear display" ;# NEW
::mc::LogicalDetail(remove)		"Add to filter / Remove from display" ;# NEW
::mc::LogicalDetail(not)			"Restrict filter / Extent display" ;# NEW

::mc::VariantName(Undetermined)	"Indeterminado"
::mc::VariantName(Normal)			"Ajedrez Normal"
::mc::VariantName(Bughouse)		"Bughouse" ;# No spanish translation
::mc::VariantName(Crazyhouse)		"Crazyhouse"
::mc::VariantName(ThreeCheck)		"Three-check" ;# No spanish translation
::mc::VariantName(Antichess)		"Antichess" ;# No spanish translation
::mc::VariantName(Suicide)			"Suicidio"
::mc::VariantName(Giveaway)		"Giveaway" ;# No spanish translation
::mc::VariantName(Losers)			"Losers" ;# No spanish translation
::mc::VariantName(Chess960)		"Ajedrez 960"
::mc::VariantName(Symm960)			"Ajedrez 960 (sólo simétrico)"
::mc::VariantName(Shuffle)			"Ajedrez Shuffle"

### themes #############################################################
::scidb::themes::mc::CannotOverwriteTheme	"No se puede anular el tema %s."

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
::widget::mc::Apply		"&Aplicar"
::widget::mc::Cancel		"&Cancelar"
::widget::mc::Clear		"&Vaciar"
::widget::mc::Close		"C&errar"
::widget::mc::Ok			"Acep&tar"
::widget::mc::Reset		"&Restablecer"
::widget::mc::Update		"Ac&tualizar"
::widget::mc::Import		"&Importar"
::widget::mc::Revert		"Re&vertir"
::widget::mc::Previous	"&Previo"
::widget::mc::Next		"Pró&ximo"
::widget::mc::First		"Pr&imero" 
::widget::mc::Last		"Últi&mo" 
::widget::mc::Help		"Ayuda" 
::widget::mc::Start		"&Inicio"

::widget::mc::New			"&Nuevo"
::widget::mc::Save		"&Guardar"
::widget::mc::Delete		"&Eliminar"

::widget::mc::Control(minimize)	"Minimizar" 
::widget::mc::Control(restore)	"Salir de pantalla completa"
::widget::mc::Control(close)		"Cerrar"

### util ###############################################################

::util::mc::IOErrorOccurred					"Hubo un error de E/S"

::util::mc::IOError(OpenFailed)				"apertura fallida"
::util::mc::IOError(ReadOnly)					"la base es de sólo lectura"
::util::mc::IOError(UnknownVersion)			"versión desconocida del archivo"
::util::mc::IOError(UnexpectedVersion)		"versión no esperada del archivo"
::util::mc::IOError(Corrupted)				"archivo corrupto"
::util::mc::IOError(WriteFailed)				"operación de escritura fallida"
::util::mc::IOError(InvalidData)				"datos no válidos (archivo probablemente corrupto)" 
::util::mc::IOError(ReadError)				"error de lectura"
::util::mc::IOError(EncodingFailed)			"no se puede escribir el nombre"
::util::mc::IOError(MaxFileSizeExceeded)	"se alcanzó el tamaño máximo de archivo" 
::util::mc::IOError(LoadFailed)				"carga fallida (demasiadas entradas de evento)" 

::util::mc::SelectionOwnerDidntRespond		"Tiempo excedido durante la operación: el propietario de la selección no respondió."

### progress ###########################################################
::progress::mc::Progress							"Progreso"

::progress::mc::Message(preload-namebase)		"Pre-cargando datos de jugadores"
::progress::mc::Message(preload-tournament)	"Pre-cargando datos de torneos"
::progress::mc::Message(preload-player)		"Pre-cargando datos de jugadores"
::progress::mc::Message(preload-annotator)	"Pre-cargando datos de anotadores"

::progress::mc::Message(read-index)				"Cargando úndices"
::progress::mc::Message(read-game)				"Cargando datos de partida"
::progress::mc::Message(read-namebase)			"Cargando nombres"
::progress::mc::Message(read-tournament)		"Cargando datos de torneos"
::progress::mc::Message(read-player)			"Cargando datos de jugadores"
::progress::mc::Message(read-annotator)		"Cargando datos de anotadores"
::progress::mc::Message(read-source)			"Cargando datos de fuentes"
::progress::mc::Message(read-team)				"Cargando datos de equipos"
::progress::mc::Message(read-init)				"Cargando datos de incialización"

::progress::mc::Message(write-index)			"Escribiendo indices"
::progress::mc::Message(write-game)				"Escribiendo datos de la partida"
::progress::mc::Message(write-namebase)		"Escribiendo datos de nombres"

::progress::mc::Message(print-game)				"Imprimir %s partida(s)"
::progress::mc::Message(copy-game)				"Copiar %s partida(s)"

### menu ###############################################################
::menu::mc::Theme							"Tema"

::menu::mc::AllScidbFiles				"Todos los archivos Scidb"
::menu::mc::AllScidbBases				"Todas las bases Scidb"
::menu::mc::ScidBases					"Bases Scid"
::menu::mc::ScidbBases					"Bases Scidb"
::menu::mc::ChessBaseBases				"Bases ChessBase"
::menu::mc::ScidbArchives				"Archivos Scidb"
::menu::mc::PGNFilesArchives			"Archivos PGN"
::menu::mc::PGNFiles						"Archivos PGN"
::menu::mc::BPGNFilesArchives			"Archivos BPGN"
::menu::mc::BPGNFiles					"Archivos BPGN"
::menu::mc::PGNArchives					"Archivos PGN"

::menu::mc::Language						"&Idioma"
::menu::mc::Toolbars						"&Barras de herramientas"
::menu::mc::ShowLog						"Mostrar &bitácora"
::menu::mc::AboutScidb					"A&cerca de Scidb"
::menu::mc::Fullscreen					"&Pantalla completa"
::menu::mc::LeaveFullscreen			"Salir de &pantalla completa"
::menu::mc::Help							"&Ayuda"
::menu::mc::Contact						"&Contenidos (navegador web)"
::menu::mc::Quit							"&Salir"
::menu::mc::Tools							"&Tools" ;# NEW
::menu::mc::Extras						"E&xtras" 
::menu::mc::Setup							"Configu&rar"

# Contact
::menu::mc::ContactBugReport			"&Reporte de errores"
::menu::mc::ContactFeatureRequest	"&Solicitud de característica"

# Extras
::menu::mc::InstallChessBaseFonts	"Instalar Fuentes de ChessBase" 
::menu::mc::OpenEngineLog				"Abrir bitácora d&el Motor"

# Tools
::menu::mc::OpenEngineDictionary		"Open Engine &Dictionary" ;# NEW
::menu::mc::OpenPlayerDictionary		"Open &Player Dictionary" ;# NEW

# Setup
::menu::mc::Engines						"Motor&es"
::menu::mc::PrivatePlayerCard			"&Private Player Card" ;# NEW

::menu::mc::OpenFile						"Abrir un archivo Scidb"
::menu::mc::NewFile						"Crear un archivo Scidb"
::menu::mc::Archiving					"Archivando" 
::menu::mc::CreateArchive				"Crear Archivo" 
::menu::mc::BuildArchive				"Crear archivo %s" 
::menu::mc::Data							"%s datos" 

### load ###############################################################
::load::mc::SevereError				"Error severo al cargar archivo ECO" 
::load::mc::FileIsCorrupt			"El archivo %s está corrupto:"
::load::mc::ProgramAborting		"Abortando programa."
::load::mc::EngineSetupFailed		"Falló la carga del archivo de configuración del motor"

::load::mc::Loading					"Cargando %s"
::load::mc::StartupFinished		"Inicio del programa completado"
::load::mc::SystemEncoding			"La codificación del sistema es '%s'"

::load::mc::ReadingFile(options)	"Leer archivo de opciones"
::load::mc::ReadingFile(engines)	"Leer archivo de motores"

::load::mc::ECOFile					"archivo ECO"
::load::mc::EngineFile				"archivo de motor"
::load::mc::SpellcheckFile			"archivo de revisión"
::load::mc::LocalizationFile		"archivo de localización"
::load::mc::RatingList				"listado de rating %s"
::load::mc::WikipediaLinks			"enlace a Wikipedia"
::load::mc::ChessgamesComLinks	"enlace a chessgames.com"
::load::mc::Cities					"ciudades"
::load::mc::PieceSet					"piezas"
::load::mc::Theme						"tema"
::load::mc::Icons						"íconos"

### archive ############################################################
::archive::mc::CorruptedArchive			"Archivo '%s' está corrupto."
::archive::mc::NotAnArchive				"'%s' no es un archivo."
::archive::mc::CorruptedHeader			"El encabezado del archivo en '%s' está corrupto."
::archive::mc::CannotCreateFile			"No se pudo crear e archivo '%s'."
::archive::mc::FailedToExtractFile		"No se pudo extraer el archivo '%s'."
::archive::mc::UnknownCompression		"Método de compresión desconocido '%s'." 
::archive::mc::ChecksumError				"Error de checksum al extraer '%s'." 
::archive::mc::ChecksumErrorDetail		"El archivo extraúdo '%s' se corromperá." 
::archive::mc::FileNotReadable			"El archivo '%s' no puede leerse." ;
::archive::mc::UsingRawInstead			"Usando método 'raw' de compresión." 
::archive::mc::CannotOpenArchive			"No se puede abrir el archivo '%s'." 
::archive::mc::CouldNotCreateArchive	"No se puede crear el archivo '%s'." ;

::archive::mc::PackFile						"Comprimir %s" ;
::archive::mc::UnpackFile					"Descomprimir %s" ;

### player photos ######################################################
::util::photos::mc::InstallPlayerPhotos		"Instalar/Actualizar fotos de los jugadores"
::util::photos::mc::TimeOut						"Se acabó el tiempo de espera."
::util::photos::mc::EnterPassword				"Contraseña personal"
::util::photos::mc::Download						"Descarga"
::util::photos::mc::SharedInstallation			"Instalación compartida"
::util::photos::mc::LocalInstallation			"Instalación privada"
::util::photos::mc::RetryLater					"Por favor, inténtelo de nuevo más tarde."
::util::photos::mc::DownloadStillInProgress	"La descarga de los archivos de fotos aún está en curso."
::util::photos::mc::PhotoFiles					"Archivos de fotos de jugadores"

::util::photos::mc::RequiresSuperuserRights	"La instalación/actualización requiere derechos de superusuario.\n\nAdvierta que la contraseña no se aceptará si el usuario no figura en el archivo sudoers."
::util::photos::mc::RequiresInternetAccess	"La instalación/actualización de los archivos de fotos de los jugadores requiere una conexión a Internet."
::util::photos::mc::AlternativelyDownload(0)	"Como alternativa usted puede descargar los archivos de fotos desde %link%. Instale estos archivos en el directorio %local%."
::util::photos::mc::AlternativelyDownload(1)	"Como alternativa usted puede descargar los archivos de fotos desde %link%. Instale estos archivos en el directorio compartido %shared%, o en su directorio privado %local%."

::util::photos::mc::Error(nohttp)				"No se puede establecer una conexión a Internet debido a que no está instalado el paquete TclHttp."
::util::photos::mc::Error(busy)					"La instalación/actualización ya está en curso."
::util::photos::mc::Error(failed)				"Error inesperado: falló la llamada al sub-proceso."
::util::photos::mc::Error(passwd)				"La contraseña es incorrecta."
::util::photos::mc::Error(nosudo)				"No puede invocar el comando 'sudo' debido a que el usuario no figura en el archivo sudoers."
::util::photos::mc::Detail(nosudo)				"Usted puede realizar una instalación privada como solución alternativa, o iniciar esta aplicación como superusuario."

::util::photos::mc::Message(uptodate)			"Los archivos de fotos aún están actualizados."
::util::photos::mc::Message(finished)			"La instalación/actualización de los archivos de fotos ha finalizado."
::util::photos::mc::Message(broken)				"Versión corrupta de la biblioteca Tcl."
::util::photos::mc::Message(noperm)				"Usted no tiene permisos de escritura para el directorio '%s'."
::util::photos::mc::Message(missing)			"No se encuentra el directorio '%s'."
::util::photos::mc::Message(httperr)			"Error HTTP: %s"
::util::photos::mc::Message(httpcode)			"Código HTTP %s inesperado."
::util::photos::mc::Message(noconnect)			"Falló la conexión HTTP."
::util::photos::mc::Message(timeout)			"Se acabó el tiempo HTTP de espera."
::util::photos::mc::Message(crcerror)			"Error de suma de chequeo. Probablemente el servidor de archivos se encuentra actualmente en modo mantenimiento."
::util::photos::mc::Message(maintenance)		"Actualmente se encuentra en curso un mantenimiento del servidor de archivos de fotos."
::util::photos::mc::Message(notfound)			"Descarga abortada debido a que se encuentra en curso actualmente un mantenimiento del servidor de archivos de fotos."
::util::photos::mc::Message(aborted)			"El usuario abortó la descarga."
::util::photos::mc::Message(killed)				"Cese inesperado de la descarga. Terminó el sub-proceso."

::util::photos::mc::Detail(nohttp)				"Por favor, instale el paquete TclHttp, por ejemplo %s."
::util::photos::mc::Detail(noconnect)			"Probablemente usted no tiene  una conexión a Internet."
::util::photos::mc::Detail(badhost)				"Otra posibilidad es un servidor o un puerto anómalos."

::util::photos::mc::Log(started)					"Instalación/actualización de los archivos de fotos iniciada a las %s."
::util::photos::mc::Log(finished)				"Instalación/actualización de los archivos de fotos finalizada a las %s."
::util::photos::mc::Log(destination)			"El directorio de destino de los archivos de fotos descargados es '%s'."
::util::photos::mc::Log(created:1)				"%s archivo) creado."
::util::photos::mc::Log(created:N)				"%s archivos creados."
::util::photos::mc::Log(deleted:1)				"%s archivo eliminado."
::util::photos::mc::Log(deleted:N)				"%s archivos eliminados."
::util::photos::mc::Log(skipped:1)				"%s archivo mantenido."
::util::photos::mc::Log(skipped:N)				"%s archivos mantenidos."
::util::photos::mc::Log(updated:1)				"%s archivo actualizado."
::util::photos::mc::Log(updated:N)				"%s archivos actualizados."

### application ########################################################
::application::mc::Database				"&Base"
::application::mc::Board					"&Tablero"
::application::mc::MainMenu				"&Menu principal"

::application::mc::DockWindow				"Ventana acoplada"
::application::mc::UndockWindow			"Ventana desacoplada"
::application::mc::ChessInfoDatabase	"Base de Datos Ajedrecística"
::application::mc::Shutdown				"Cierre..."
::application::mc::QuitAnyway				"¿Desea cerrar de todos modos?"

::application::mc::UpdatesAvailable		"Actualizaciones disponibles"

### application::board #################################################
::application::board::mc::ShowCrosstable				"Mostrar tabla de torneo para esta partida"
::application::board::mc::StartEngine					"Iniciar motor de análisis"
::application::board::mc::StopEngine					"Detener motor de análisis"
::application::board::mc::InsertNullMove				"Insert null move" ;# NEW
::application::board::mc::SelectStartPosition		"Select Start Position" ;# NEW
::application::board::mc::LoadRandomGame				"Load random game" ;# NEW

::application::board::mc::Tools							"Herramientas"
::application::board::mc::Control						"Control"
::application::board::mc::Game							"Partida"
::application::board::mc::GoIntoNextVar				"Ir a la próxima variante"
::application::board::mc::GoIntPrevVar					"Ir a la variante previa"

::application::board::mc::LoadGame(next)				"Cargar siguiente partida"
::application::board::mc::LoadGame(prev)				"Cargar partida anterior"
::application::board::mc::LoadGame(first)				"Cargar primer partida"
::application::board::mc::LoadGame(last)				"Cargar última partida"

::application::board::mc::SwitchView(base)			"Switch to database view" ;# NEW
::application::board::mc::SwitchView(list)			"Switch to game list view" ;# NEW

::application::board::mc::Accel(edit-annotation)	"A"
::application::board::mc::Accel(edit-comment)		"C"
::application::board::mc::Accel(edit-marks)			"M"
::application::board::mc::Accel(add-new-game)		"S" 
::application::board::mc::Accel(replace-game)		"R" 
::application::board::mc::Accel(replace-moves)		"V" 
::application::board::mc::Accel(trial-mode)			"T" 

### application::database ##############################################
::application::database::mc::FileOpen							"Abrir Base"
::application::database::mc::FileOpenRecent					"Abrir Recientes"
::application::database::mc::FileNew							"Nueva Base"
::application::database::mc::FileExport						"Exportar"
::application::database::mc::FileImport(pgn)					"Importar archivos PGN"
::application::database::mc::FileImport(db)					"Importar Bases de Datos"
::application::database::mc::FileCreate						"Crear Archivo"
::application::database::mc::FileClose							"Cerrar"
::application::database::mc::FileMaintenance					"Maintenance" ;# NEW
::application::database::mc::FileCompact						"Compactar"
::application::database::mc::FileStripMoveInfo				"Strip Move Information" ;# NEW
::application::database::mc::FileStripPGNTags				"Strip PGN Tags" ;# NEW
::application::database::mc::HelpSwitcher						"Ayuda con el Cambiador de Bases de Datos"

::application::database::mc::Games								"&Partidas"
::application::database::mc::Players							"&Jugadores"
::application::database::mc::Events								"Even&tos"
::application::database::mc::Sites								"Lugare&s"
::application::database::mc::Annotators						"&Comentaristas"

::application::database::mc::File								"Archivo"
::application::database::mc::SymbolSize						"Tamaño del símbolo"
::application::database::mc::Large								"Grande"
::application::database::mc::Medium								"Mediano"
::application::database::mc::Small								"Pequeño"
::application::database::mc::Tiny								"Diminuto"
::application::database::mc::LoadMessage						"Abrir Base '%s'"
::application::database::mc::UpgradeMessage					"Actualizando Database '%s'"
::application::database::mc::CompactMessage					"Compactando base de datos '%s'" 
::application::database::mc::CannotOpenFile					"No se puede abrir el archivo '%s'."
::application::database::mc::EncodingFailed					"Fallo en la codificación de %s." ;# "Character decoding %s failed."
::application::database::mc::DatabaseAlreadyOpen			"La Base '%s' ya está abierta."
::application::database::mc::Properties						"Propiedades"
::application::database::mc::Preload							"Precarga"
::application::database::mc::MissingEncoding					"Codificación %s perdida (usar %s en su lugar)" ;# NEW "Missing character encoding %s (using %s instead)"
::application::database::mc::DescriptionTooLarge			"Descripción demasiado grande."
::application::database::mc::DescrTooLargeDetail			"La entrada contiene %d caracteres, pero sólo se permiten %d."
::application::database::mc::ClipbaseDescription			"Base temporal, no se guarda al disco."
::application::database::mc::HardLinkDetected				"No se puede cargar el archivo '%file1' porque ya está cargado como '%file2'. Esto sucede cuando se usan hard links."
::application::database::mc::HardLinkDetectedDetail		 "Si se carga la misma base de datos nuevamente, la aplicació puede terminar debido a los hilos usados."
::application::database::mc::OverwriteExistingFiles		"¿Sobrescribir archivos existentes en el directorio '%s'?"
::application::database::mc::SelectDatabases					"Seleccione las bases de datos que se abrirán"
::application::database::mc::ExtractArchive					"Extracer archivo %s"
::application::database::mc::SelectVariant					"Select Variant" ;# NEW
::application::database::mc::Example							"Example" ;# NEW

::application::database::mc::RecodingDatabase				"Recodificar %base de %from a %to"
::application::database::mc::RecodedGames						"%s partida(s) recodificadas"

::application::database::mc::ChangeIcon						"Cambiar ícono"
::application::database::mc::Recode								"Recodificar"
::application::database::mc::EditDescription					"Editar Descripción"
::application::database::mc::EmptyClipbase					"Vaciar Base temporal"

::application::database::mc::Maintenance						"Maintenance" ;# NEW
::application::database::mc::StripMoveInfo					"Strip move information from database '%s'" ;# NEW
::application::database::mc::StripPGNTags						"Strip PGN tags from database '%s'" ;# NEW
::application::database::mc::GamesStripped(0)				"No game stripped." ;# NEW
::application::database::mc::GamesStripped(1)				"One game stripped." ;# NEW
::application::database::mc::GamesStripped(N)				"%s games stripped." ;# NEW
::application::database::mc::GamesRemoved(0)					"No game removed." ;# NEW
::application::database::mc::GamesRemoved(1)					"One game removed." ;# NEW
::application::database::mc::GamesRemoved(N)					"%s games removed." ;# NEW
::application::database::mc::CompactDetail					"Todos los juegos deben cerrarse para poder compactar."
::application::database::mc::ReallyCompact					"¿Realmente desea compactar la base de datos '%s'?" 
::application::database::mc::ReallyCompactDetail(1)		"Solamente se borrará una partida."
::application::database::mc::ReallyCompactDetail(N)		"Se borrarán %s partidas."
::application::database::mc::RemoveSpace						"Some empty spaces will be removed." ;# NEW
::application::database::mc::CompactionRecommended			"It is recommended to compact the database."
::application::database::mc::SearchPGNTags					"Searching for PGN tags" ;# NEW
::application::database::mc::SelectSuperfluousTags			"Select superfluous tags:" ;# NEW
::application::database::mc::WillBePermanentlyDeleted		"Please note: This action will permanently delete the concerned information from database." ;# NEW

::application::database::mc::T_Unspecific						"Inespecífico"
::application::database::mc::T_Temporary						"Temporal"
::application::database::mc::T_Work								"Trabajo"
::application::database::mc::T_Clipbase						"Base temporal"
::application::database::mc::T_MyGames							"Mis partidas"
::application::database::mc::T_Informant						"Informador"
::application::database::mc::T_LargeDatabase					"Gran Base"
::application::database::mc::T_CorrespondenceChess			"Ajedrez por Correspondencia"  
::application::database::mc::T_EmailChess						"Ajedrez por email"
::application::database::mc::T_InternetChess					"Ajedrez por Internet"
::application::database::mc::T_ComputerChess					"Ajedrez por computadora"
::application::database::mc::T_Chess960						"Ajedrez 960"
::application::database::mc::T_PlayerCollection				"Colección de jugadores"
::application::database::mc::T_PlayerCollectionFemale		"Colección de jugadoras"
::application::database::mc::T_Tournament						"Torneo"
::application::database::mc::T_TournamentSwiss				"Torneo suizo"
::application::database::mc::T_GMGames							"Partidas de GM"
::application::database::mc::T_IMGames							"Partidas de MI"
::application::database::mc::T_BlitzGames						"Partidas rápidas"
::application::database::mc::T_Tactics							"Táctica"
::application::database::mc::T_Endgames						"Finales"
::application::database::mc::T_Analysis						"Análisis"
::application::database::mc::T_Training						"Entrenamiento"
::application::database::mc::T_Match							"Competencia"
::application::database::mc::T_Studies							"Estudios"
::application::database::mc::T_Jewels							"Joyas"
::application::database::mc::T_Problems						"Problemas"
::application::database::mc::T_Patzer							"Novato"
::application::database::mc::T_Gambit							"Gambito"
::application::database::mc::T_Important						"Importante"
::application::database::mc::T_Openings						"Aperturas"
::application::database::mc::T_OpeningsWhite					"Aperturas de las Blancas"
::application::database::mc::T_OpeningsBlack					"Aperturas de las Negras"
::application::database::mc::T_Bughouse						"Bughouse"
::application::database::mc::T_Antichess						"Antichess"
::application::database::mc::T_PGNFile							"Archivo PGN"
::application::database::mc::T_ThreeCheck						"Three-check"
::application::database::mc::T_Crazyhouse						"Crazyhouse"

::application::database::mc::OpenDatabase						"Abrir Base de Datos"
::application::database::mc::NewDatabase						"Nueva Base de Datos"
::application::database::mc::CloseDatabase					"Cerrar Base de Datos '%s'"
::application::database::mc::SetReadonly						"Marcar Base de Datos '%s' como solo lectura"
::application::database::mc::SetWriteable						"Marcar Base de Datos '%s' para escritura"

::application::database::mc::OpenReadonly						"Abrir como solo lectura"
::application::database::mc::OpenWriteable					"Abrir con permiso de escritura"

::application::database::mc::UpgradeDatabase					"%s es un formato antiguo de base de datos que solo puede abrirse como solo lectura.\n\nActualizarla creará una nueva versión de la base de datos y luego removerá los archivos originales.\n\nEsto puede demorar un poco pero solo debe hacerse una vez.\n\n¿Desea actualizar esta base de datos ahora?"
::application::database::mc::UpgradeDatabaseDetail			"\"No\" abrirá la base de datos como solo lectura y no puede marcarse para escritura."

::application::database::mc::MoveInfo(evaluation)			"Evaluation" ;# NEW
::application::database::mc::MoveInfo(playersClock)		"Players Clock" ;# NEW
::application::database::mc::MoveInfo(elapsedGameTime)	"Elapsed Game Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMoveTime)	"Elapsed Move Time" ;# NEW
::application::database::mc::MoveInfo(elapsedMilliSecs)	"Elapsed Milliseconds" ;# NEW
::application::database::mc::MoveInfo(clockTime)			"Clock Time" ;# NEW
::application::database::mc::MoveInfo(corrChessSent)		"Correspondence Chess Sent" ;# NEW
::application::database::mc::MoveInfo(videoTime)			"Video Time" ;# NEW

### application::database::games #######################################
::application::database::games::mc::Control						"Control"
::application::database::games::mc::GameNumber					"Número de partida"

::application::database::games::mc::GotoFirstPage				"Ir a la primera página de partidas"
::application::database::games::mc::GotoLastPage				"Ir a la última página de partidas"
::application::database::games::mc::PreviousPage				"Página de partidas previa"
::application::database::games::mc::NextPage						"Próxima página de partidas"
::application::database::games::mc::GotoCurrentSelection		"Ir a la selección actual"
::application::database::games::mc::UseVerticalScrollbar		"Usar barra de deslizamiento vertical"
::application::database::games::mc::UseHorizontalScrollbar	"Usar barra de deslizamiento horizontal"
::application::database::games::mc::GotoEnteredGameNumber	"Ir al número de partida ingresado"

### application::database::players #####################################
::application::database::players::mc::EditPlayer				"Editar Jugador"
::application::database::players::mc::Score						"Puntuación"
::application::database::players::mc::TooltipRating			"Rating: %s"

### application::database::annotators ##################################
::application::database::annotators::mc::F_Annotator		"Comentarista"
::application::database::annotators::mc::F_Frequency		"Frecuencia"

::application::database::annotators::mc::Find				"Buscar"
::application::database::annotators::mc::FindAnnotator	"Buscar comentarista"
::application::database::annotators::mc::ClearEntries		"Vaciar entradas"

### application::pgn ###################################################
::application::pgn::mc::Command(move:comment)			"Agregar comentario"
::application::pgn::mc::Command(move:marks)				"Agregar marcador"
::application::pgn::mc::Command(move:annotation)		"Agregar Nota/Comentario/Marcador"
::application::pgn::mc::Command(move:append)				"Agregar jugada"
::application::pgn::mc::Command(move:nappend)			"Agregar jugadas"
::application::pgn::mc::Command(move:exchange)			"Cambiar jugada"
::application::pgn::mc::Command(variation:new)			"Agregar variante"
::application::pgn::mc::Command(variation:replace)		"Reemplazar jugadas"
::application::pgn::mc::Command(variation:truncate)	"Truncar variante"
::application::pgn::mc::Command(variation:first)		"Convertir en primera variante"
::application::pgn::mc::Command(variation:promote)		"Transformar variante en Línea principal"
::application::pgn::mc::Command(variation:remove)		"Eliminar variante"
::application::pgn::mc::Command(variation:remove:n)	"Delete Variations" ;# NEW
::application::pgn::mc::Command(variation:mainline)	"Nueva Línea principal"
::application::pgn::mc::Command(variation:insert)		"Agregar jugadas"
::application::pgn::mc::Command(variation:exchange)	"Permutar jugadas"
::application::pgn::mc::Command(strip:moves)				"Jugadas desde el principio"
::application::pgn::mc::Command(strip:truncate)			"Jugadas hasta el final"
::application::pgn::mc::Command(strip:annotations)		"Notas"
::application::pgn::mc::Command(strip:info)				"Mover Información"
::application::pgn::mc::Command(strip:marks)				"Marcadores"
::application::pgn::mc::Command(strip:comments)			"Comentarios"
::application::pgn::mc::Command(strip:variations)		"Variantes"
::application::pgn::mc::Command(copy:comments)			"Copiar Comentarios"
::application::pgn::mc::Command(move:comments)			"Mover Comentarios"
::application::pgn::mc::Command(game:clear)				"Vaciar partida"
::application::pgn::mc::Command(game:merge)				"Merge Game" ;# NEW
::application::pgn::mc::Command(game:transpose)			"Partida transpuesta"

::application::pgn::mc::StartTrialMode						"Iniciar el modo de prueba"
::application::pgn::mc::StopTrialMode						"Terminar el modo de prueba"
::application::pgn::mc::Strip									"Limpiar"
::application::pgn::mc::InsertDiagram						"Insertar diagrama"
::application::pgn::mc::InsertDiagramFromBlack			"Insertar diagrama desde la perspectiva de las Negras"
::application::pgn::mc::SuffixCommentaries				"Comentarios en los sufijos"
::application::pgn::mc::StripOriginalComments			"Remover comentarios orginales"

::application::pgn::mc::LanguageSelection					"Selección de Idioma"
::application::pgn::mc::MoveInfoSelection					"Move Info Selection" ;# NEW
::application::pgn::mc::MoveNotation						"Anotación de Jugadas"
::application::pgn::mc::CollapseVariations				"Contraer variantes"
::application::pgn::mc::ExpandVariations					"Expandir variantes"
::application::pgn::mc::EmptyGame							"Vaciar partida"

::application::pgn::mc::NumberOfMoves						"Número de medias jugadas (en la línea principal):"
::application::pgn::mc::InvalidInput						"Entrada no válida '%d'."
::application::pgn::mc::MustBeEven							"La entrada debe ser par."
::application::pgn::mc::MustBeOdd							"La entrada debe ser impar."
::application::pgn::mc::CannotOpenCursorFiles			"No se puede abrir el archivo: %s"
::application::pgn::mc::ReallyReplaceMoves				"¿Realmente desea reemplazar los movimientos de la partida actual?"
::application::pgn::mc::CurrentGameIsNotModified		"La partida actual no fue modificada."
::application::pgn::mc::ShufflePosition					"Position aleatoria..."

::application::pgn::mc::EditAnnotation						"Editar nota"
::application::pgn::mc::EditMoveInformation				"Editar información de la jugada"
::application::pgn::mc::EditCommentBefore					"Editar comentario antes de la jugada"
::application::pgn::mc::EditCommentAfter					"Editar comentario tras la jugada"
::application::pgn::mc::EditPrecedingComment				"Editar el comentario precedente"
::application::pgn::mc::EditTrailingComment				"Editar último comentario" 
::application::pgn::mc::EditMarks							"Editar marcador"
::application::pgn::mc::Display								"Mostrar"
::application::pgn::mc::None									"ninguno"

::application::pgn::mc::MoveInfo(eval)						"Evaluation" ;# NEW
::application::pgn::mc::MoveInfo(clk)						"Players Clock" ;# NEW
::application::pgn::mc::MoveInfo(emt)						"Elapsed Time" ;# NEW
::application::pgn::mc::MoveInfo(ccsnt)					"Correspondence Chess Sent" ;# NEW
::application::pgn::mc::MoveInfo(video)					"Video Time" ;# NEW

### application::tree ##################################################

::application::tree::mc::Total								"Total"
::application::tree::mc::Control								"Control"
::application::tree::mc::ChooseReferenceBase				"Elegir base de referencia"
::application::tree::mc::ReferenceBaseSwitcher			"Selector de base de referencia"
::application::tree::mc::Numeric								"Numérico"
::application::tree::mc::Bar									"Barras"
::application::tree::mc::StartSearch						"Iniciar búsqueda"
::application::tree::mc::StopSearch							"Suspender búsqueda"
::application::tree::mc::UseExactMode						"Usar posición de búsqueda"
::application::tree::mc::UseFastMode						"Usar búsqueda acelerada"
::application::tree::mc::UseQuickMode						"Usar búsqueda rápida"
::application::tree::mc::AutomaticSearch					"Busqueda automática"
::application::tree::mc::LockReferenceBase				"Bloquear base de referencia"
::application::tree::mc::SwitchReferenceBase				"Cambiar base de datos de referencia"
::application::tree::mc::TransparentBar					"Barras transparentes"
::application::tree::mc::NoGamesFound						"No games found" ;# NEW
::application::tree::mc::NoGamesAvailable					"No games available" ;# NEW
::application::tree::mc::Searching							"Searching" ;# NEW
::application::tree::mc::VariantsNotYetSupported		"Chess variants not yet supported." ;# NEW

::application::tree::mc::FromWhitesPerspective			"Desde el lado de las Blancas"
::application::tree::mc::FromBlacksPerspective			"Desde el lado de las Negras"
::application::tree::mc::FromSideToMovePerspective		"Desde el lado que mueve"
::application::tree::mc::FromWhitesPerspectiveTip		"Evaluar desde la perspectiva de las blancas"
::application::tree::mc::FromBlacksPerspectiveTip		"Evaluar desde la perspectiva de las negras"
::application::tree::mc::EmphasizeMoveOfGame				"Emphasize move of game" ;# NEW

::application::tree::mc::TooltipAverageRating			"Rating promedio (%s)"
::application::tree::mc::TooltipBestRating				"Mejor rating (%s)"

::application::tree::mc::F_Number							"#"
::application::tree::mc::F_Move								"Jugada"
::application::tree::mc::F_Eco								"ECO"
::application::tree::mc::F_Frequency						"Frecuencia"
::application::tree::mc::F_Ratio								"Proporción"
::application::tree::mc::F_Score								"Resultado"
::application::tree::mc::F_Draws								"Tablas"
::application::tree::mc::F_Performance						"Desempeño"
::application::tree::mc::F_AverageYear						"\u00f8 Año"
::application::tree::mc::F_LastYear							"Última partida jugada"
::application::tree::mc::F_BestPlayer						"Mejor jugador"
::application::tree::mc::F_FrequentPlayer					"Jugador más frecuente"

::application::tree::mc::T_Number							"Numeración"
::application::tree::mc::T_AverageYear						"Año promedio"
::application::tree::mc::T_FrequentPlayer					"Jugador más frecuente"

### database::switcher #################################################
::database::switcher::mc::Empty								"vacío"
::database::switcher::mc::None								"ninguno"
::database::switcher::mc::Failed								"fallido"

::database::switcher::mc::UriRejectedDetail(open)		"Solamente pueden abrirse bases de datos Scidb:"
::database::switcher::mc::UriRejectedDetail(import)	"Solamente pueden importarse bases de datos de Scidb:"
::database::switcher::mc::EmptyUriList						"Descartar contenido está vacóo."
::database::switcher::mc::CopyGames							"Copiar partidas"
::database::switcher::mc::CopyGamesFromTo					"Copiar partidas de '%src' a '%dst'"
::database::switcher::mc::CopiedGames						"%s partida(s) copiada"
::database::switcher::mc::NoGamesCopied					"No se copiaron partidas"
::database::switcher::mc::CopyGamesFrom					"Copiar partidas de '%s'"
::database::switcher::mc::ImportGames						"Importar partidas"
::database::switcher::mc::ImportFiles						"Importar Archivos:"

::database::switcher::mc::ImportOneGameTo(0)				"¿Copiar una partida a '%dst'?"
::database::switcher::mc::ImportOneGameTo(1)				"¿Copiar aproximadamente una partida a '%dst'?"
::database::switcher::mc::ImportGamesTo(0)				"¿Copiar %num partidas a '%dst'?"
::database::switcher::mc::ImportGamesTo(1)				"¿Copiar aproximadamente %num partidas a '%dst'?"

::database::switcher::mc::NumGames(0)						"ninguno"
::database::switcher::mc::NumGames(1)						"una partida"
::database::switcher::mc::NumGames(N)						"%s partidas"

::database::switcher::mc::SelectGames(all)				"All games" ;# NEW
::database::switcher::mc::SelectGames(filter)			"Only filtered games" ;# NEW
::database::switcher::mc::SelectGames(all,variant)		"Only variant %s" ;# NEW
::database::switcher::mc::SelectGames(filter,variant)	"Only filtered games of variant %s" ;# NEW
::database::switcher::mc::SelectGames(complete)			"Complete database" ;# NEW

::database::switcher::mc::GameCount							"Partidas"
::database::switcher::mc::DatabasePath						"ruta a la Base"
::database::switcher::mc::DeletedGames						"Partidas eliminadas"
::database::switcher::mc::Description						"Descripción"
::database::switcher::mc::Created							"Creada"
::database::switcher::mc::LastModified						"Última modificación"
::database::switcher::mc::Encoding							"Codificar"
::database::switcher::mc::YearRange							"Rango de años"
::database::switcher::mc::RatingRange						"Rango de ratings"
::database::switcher::mc::Result								"Resultado"
::database::switcher::mc::Score								"puntuación"
::database::switcher::mc::Type								"Tipo"
::database::switcher::mc::ReadOnly							"Sólo lectura"

### board ##############################################################
::board::mc::CannotReadFile			"No se puede leer el archivo '%s':"
::board::mc::CannotFindFile			"No se encuentra el archivo '%s'"
::board::mc::FileWillBeIgnored		"Se ignorará '%s' (ID duplicado)"
::board::mc::IsCorrupt					"'%s' está dañado (estilo %s desconocido '%s')"
::board::mc::SquareStyleIsUndefined	"El estilo de tablero '%s' ya no existe"
::board::mc::PieceStyleIsUndefined	"El estilo de piezas '%s' ya no existe"
::board::mc::ThemeIsUndefined			"El tema de tablero '%s' ya no existe"

::board::mc::ThemeManagement			"Manejo de temas"
::board::mc::Setup						"Disposición"

::board::mc::WorkingSet					"Conjunto usado"

### board::options #####################################################
::board::options::mc::Coordinates			"Coordenadas"
::board::options::mc::SolidColor				"Color sólido"
::board::options::mc::EditList				"Editar lista"
::board::options::mc::Embossed				"repujado"
::board::options::mc::Highlighting			"Resaltar"
::board::options::mc::Border					"Borde"
::board::options::mc::SaveWorkingSet		"Guardar el conjunto usado"
::board::options::mc::SelectedSquare		"Casilla elegida"
::board::options::mc::ShowBorder				"Mostrar borde"
::board::options::mc::ShowCoordinates		"Mostrar coordenadas"
::board::options::mc::ShowMaterialValues	"Mostrar material"
::board::options::mc::ShowMaterialBar		"Mostrar Barra de Matrial" 
::board::options::mc::ShowSideToMove		"Mostrar el lado que mueve"
::board::options::mc::ShowSuggestedMove	"Mostar jugada sugerida"
::board::options::mc::SuggestedMove			"Jugada sugerida"
::board::options::mc::Basic					"Básico"
::board::options::mc::PieceStyle				"Estilo de pieza"
::board::options::mc::SquareStyle			"Estilo de casilla"
::board::options::mc::Styles					"Estilos"
::board::options::mc::Show						"Vista previa"
::board::options::mc::ChangeWorkingSet		"Editar conjunto usado"
::board::options::mc::CopyToWorkingSet		"Copiar al conjunto usado"
::board::options::mc::NameOfPieceStyle		"Ingresar nombre del estilo de piezas"
::board::options::mc::NameOfSquareStyle	"Ingresar nombre de estilo de casillas"
::board::options::mc::NameOfThemeStyle		"Ingresar nombre del tema"
::board::options::mc::PieceStyleSaved		"Estilo de pieza '%s' guardado como '%s'"
::board::options::mc::SquareStyleSaved		"Estilo de casillas '%s' guardado como '%s'"
::board::options::mc::ChooseColors			"Elija colores"
::board::options::mc::SupersedeSuggestion	"Cambiar/usar colores sugeridos en estilo de casillas"
::board::options::mc::CannotDelete			"No se puede eliminar '%s'."
::board::options::mc::IsWriteProtected		"El archivo '%s' está protegido contra escritura."
::board::options::mc::ConfirmDelete			"¿Está seguro que desea eliminar '%s'?"
::board::options::mc::NoPermission			"No se puede eliminar '%s'.\nPermiso denegado."
::board::options::mc::BoardSetup				"Disposición del tablero"
::board::options::mc::OpenTextureDialog	"Abrir diálogo de texturas"

::board::options::mc::YouCannotReverse		"No puede revertir esta acción. El archivo '%s' será removido físicamente."

::board::options::mc::CannotUsePieceWorkingSet "No se puede crear un nuevo tema con el estilo de piezas %s elegido.\n Primero debe guardar el nuevo estilo de pieza, o elegir otro."

::board::options::mc::CannotUseSquareWorkingSet "No se puede crear un nuevo tema con el estilo de casillas %s elegido.\n Primero debe guardar el nuevo estilo de casillas, o elegir otro."

### board::piece #######################################################
::board::piece::mc::Start						"Iniciar"
::board::piece::mc::Stop						"Parar"
::board::piece::mc::HorzOffset				"Impresión horizontal"
::board::piece::mc::VertOffset				"Impresión vertical"
::board::piece::mc::Gradient					"Gradiente"
::board::piece::mc::Fill						"Relleno"
::board::piece::mc::Stroke						"Trazo"
::board::piece::mc::Contour					"Contorno"
::board::piece::mc::WhiteShape				"Silueta blanca"
::board::piece::mc::PieceSelection			"Selección de piezas"
::board::piece::mc::BackgroundSelection	"Selección de fondo"
::board::piece::mc::Zoom						"Zoom"
::board::piece::mc::Shadow						"Sombra"
::board::piece::mc::Opacity					"Opacidad"
::board::piece::mc::ShadowDiffusion			"Difusión de la sombra"
::board::piece::mc::PieceStyleConf			"Configuración del estilo de pieza"
::board::piece::mc::Offset						"Impresión"
::board::piece::mc::Rotate						"Rotar"
::board::piece::mc::CloseDialog				"¿Cerrar el diálogo y descartar cambios?"
::board::piece::mc::OpenTextureDialog		"Abrir diálogo de textura"

### board::square ######################################################
::board::square::mc::SolidColor			"Color sólido"
::board::square::mc::CannotReadFile		"No se puede leer el archivo"
::board::square::mc::Zoom					"Zoom"
::board::square::mc::Offset				"Imprimir"
::board::square::mc::Rotate				"Rotar"
::board::square::mc::Borderline			"Borde"
::board::square::mc::Width					"Ancho"
::board::square::mc::Opacity				"Opacidad"
::board::square::mc::GapBetweenSquares	"Espacio entre casillas"
::board::square::mc::Highlighting		"Resaltar"
::board::square::mc::Selected				"Elegido"
::board::square::mc::SuggestedMove		"Jugada sugerida"
::board::square::mc::Show					"Vista previa"
::board::square::mc::SquareStyleConf	"Configuración del estilo de las casillas"
::board::square::mc::CloseDialog			"¿Cerrar el diálogo y descartar los cambios?"

### board::texture #####################################################
::board::texture::mc::PreselectedOnly "Sólo preseleccionados"

### pgn-setup ##########################################################
::pgn::setup::mc::Configure(editor)				"Personalizar Editor"
::pgn::setup::mc::Configure(browser)			"Personalizar Salida de texto"
::pgn::setup::mc::TakeOver(editor)				"Adoptar la configuración del Explorador de partidas"
::pgn::setup::mc::TakeOver(browser)				"Adoptar la configuración del Editor de partidas"
::pgn::setup::mc::Pixel								"Píxel"
::pgn::setup::mc::Spaces							"espacios"
::pgn::setup::mc::RevertSettings					"Volver a la configuración inicial"
::pgn::setup::mc::ResetSettings					"Volver a la configuración original"
::pgn::setup::mc::DiscardAllChanges				"¿Desea descartar todos los cambios realizados?"
::pgn::setup::mc::ThreefoldRepetition			"Threefold repetition" ;# NEW
::pgn::setup::mc::FiftyMoveRule					"50 move rule" ;# NEW

::pgn::setup::mc::Setup(Appearance)				"Apariencia"
::pgn::setup::mc::Setup(Layout)					"Disposición"
::pgn::setup::mc::Setup(Diagrams)				"Diagramas"
::pgn::setup::mc::Setup(MoveStyle)				"Estilo de las jugadas"

::pgn::setup::mc::Setup(Fonts)					"Fuentes"
::pgn::setup::mc::Setup(font-and-size)			"Fuente y tamaño del texto"
::pgn::setup::mc::Setup(figurine-font)			"Figurines (normal)"
::pgn::setup::mc::Setup(figurine-bold)			"Figurines (negritas)"
::pgn::setup::mc::Setup(symbol-font)			"Símbolos"

::pgn::setup::mc::Setup(Colors)					"Colores"
::pgn::setup::mc::Setup(Highlighting)			"Resaltado"
::pgn::setup::mc::Setup(start-position)		"Posición inicial"
::pgn::setup::mc::Setup(variations)				"Variantes"
::pgn::setup::mc::Setup(numbering)				"Numeración"
::pgn::setup::mc::Setup(brackets)				"Paréntesis"
::pgn::setup::mc::Setup(illegal-move)			"Jugada ilegal"
::pgn::setup::mc::Setup(comments)				"Comentarios"
::pgn::setup::mc::Setup(annotation)				"Anotación"
::pgn::setup::mc::Setup(nagtext)					"Texto NAG"
::pgn::setup::mc::Setup(marks)					"Marcadores"
::pgn::setup::mc::Setup(move-info)				"Información de la jugada"
::pgn::setup::mc::Setup(result)					"Resultado"
::pgn::setup::mc::Setup(current-move)			"Jugada actual"
::pgn::setup::mc::Setup(next-moves)				"Jugadas siguientes"
::pgn::setup::mc::Setup(empty-game)				"Partida vacía"

::pgn::setup::mc::Setup(Hovers)					"Flotantes"
::pgn::setup::mc::Setup(hover-move)				"Jugada"
::pgn::setup::mc::Setup(hover-comment)			"Comentario"
::pgn::setup::mc::Setup(hover-move-info)		"Información de la jugada"

::pgn::setup::mc::Section(ParLayout)			"Disposición de párrafo"
::pgn::setup::mc::ParLayout(use-spacing)		"Usar espaciado en los párrafos"
::pgn::setup::mc::ParLayout(column-style)		"Estilo columna"
::pgn::setup::mc::ParLayout(tabstop-1)			"Sangrar la jugada de las Blancas"
::pgn::setup::mc::ParLayout(tabstop-2)			"Sangrar la jugada de las Negras"
::pgn::setup::mc::ParLayout(mainline-bold)	"Negrita para las jugadas de la Línea principal"

::pgn::setup::mc::Section(Variations)			"Disposición de las Variantes"
::pgn::setup::mc::Variations(width)				"Sangrar el ancho"
::pgn::setup::mc::Variations(level)				"Sangrar nivel"

::pgn::setup::mc::Section(Display)				"Presentación"
::pgn::setup::mc::Display(numbering)			"Mostrar numeración en las Variantes"
::pgn::setup::mc::Display(moveinfo)				"Mostrar Información de la jugada"
::pgn::setup::mc::Display(nagtext)				"Mostrar texto para comentarios NAG inusuales"

::pgn::setup::mc::Section(Diagrams)				"Diagramas"
::pgn::setup::mc::Diagrams(show)					"Mostrar diagramas"
# Note for translators: "Emoticons" can be simply translated to "Smileys"
::pgn::setup::mc::Emoticons(show)				"Detect Emoticons" ;# NEW
::pgn::setup::mc::Diagrams(square-size)		"Tamaño de los escaques"
::pgn::setup::mc::Diagrams(indentation)		"Sangrar el ancho"

### engine #############################################################
::engine::mc::Information				"Información"
::engine::mc::Features					"Características"
::engine::mc::Options					"Opciones"

::engine::mc::Name						"Nombre"
::engine::mc::Identifier				"Identificador"
::engine::mc::Author						"Autor"
::engine::mc::Webpage					"Página web"
::engine::mc::Email						"Correo electrónico"
::engine::mc::Country					"País"
::engine::mc::Rating						"Rating"
::engine::mc::Logo						"Logotipo"
::engine::mc::Protocol					"Protocolo"
::engine::mc::Parameters				"Parámetros"
::engine::mc::Command					"Comandos"
::engine::mc::Directory					"Directorio"
::engine::mc::Variants					"Variantes"
::engine::mc::LastUsed					"Último uso"

::engine::mc::Variant(standard)		"Estándar"
::engine::mc::Variant(chess960)		"Ajedrez 960"
::engine::mc::Variant(bughouse)		"Bughouse"
::engine::mc::Variant(crazyhouse)	"Crazyhouse"
::engine::mc::Variant(suicide)		"Antichess"
::engine::mc::Variant(giveaway)		"Antichess"
::engine::mc::Variant(losers)			"Antichess"
::engine::mc::Variant(3check)			"Three-check"

::engine::mc::Edit						"Editar"
::engine::mc::View						"Ver"
::engine::mc::New							"Nuevo"
::engine::mc::Rename						"Renombrar"
::engine::mc::Delete						"Borrar"
::engine::mc::Select(engine)			"Seleccionar motor"
::engine::mc::Select(profile)			"Seleccionar perfil"
::engine::mc::ProfileName				"Nombre del perfil"
::engine::mc::NewProfileName			"Nuevo nombre de perfil"
::engine::mc::OldProfileName			"Nombre de perfil anterior"
::engine::mc::CopyFrom					"Copiar de"
::engine::mc::NewProfile				"Nuevo perfil"
::engine::mc::RenameProfile			"Renombrar perfil"
::engine::mc::EditProfile				"Editar Perfil '%s'"
::engine::mc::ProfileAlreadyExists	"Ya existe un perfil de nombre '%s'."
::engine::mc::ChooseDifferentName	"Por favor escoja un nombre diferente."
::engine::mc::ReservedName				"El nombre '%s' es reservado y no puede ser usado."
::engine::mc::ReallyDeleteProfile	"¿Realmente desea borrar el perfil '%s'?"
::engine::mc::SortName					"Sort by name" ;# NEW
::engine::mc::SortElo					"Sort by Elo rating" ;# NEW
::engine::mc::SortRating				"Sort by CCRL rating" ;# NEW
::engine::mc::OpenUrl					"Open URL (web browser)" ;# NEW

::engine::mc::AdminEngines				"Administrar Motores"
::engine::mc::SetupEngine				"Configurar motor %s"
::engine::mc::ImageFiles				"Archivos de Imagen"
::engine::mc::SelectEngine				"Seleccionar Motor"
::engine::mc::SelectEngineLogo		"Elegir un logotipo para el Motor"
::engine::mc::EngineDictionary		"Engine Dictionary" ;# NEW
::engine::mc::EngineFilter				"Engine Filter" ;# NEW
::engine::mc::EngineLog					"Bitácora del Motor"
::engine::mc::Probing					"Penetrante"
::engine::mc::NeverUsed					"Nunca utilizado"
::engine::mc::OpenFsbox					"Abrir el diálogo Seleccionar archivo"
::engine::mc::ResetToDefault			"Reset to default" ;# NEW
::engine::mc::ShowInfo					"Mostrar \"Info\""
::engine::mc::TotalUsage				"%s veces en total"
::engine::mc::Memory						"Memoria (MB)"
::engine::mc::CPUs						"Procesadores"
::engine::mc::Priority					"Prioridad del procesador"
::engine::mc::ClearHash					"Limpiar tablas hash"

::engine::mc::ConfirmNewEngine		"Confirmar el nuevo Motor"
::engine::mc::EngineAlreadyExists	"Ya existe una entrada con este Motor."
::engine::mc::CopyFromEngine			"Hacer una copia de la entrada"
::engine::mc::CannotOpenProcess		"No se puede iniciar el proceso."
::engine::mc::DoesNotRespond			"Este Motor no responde ni al protocolo UCI ni al protocolo XBoard/WinBoard."
::engine::mc::DiscardChanges			"El ítem actual ha cambiado.\n\n¿Realmente desea descartar los cambios?"
::engine::mc::ReallyDelete				"¿Realmente desea eliminar el Motor '%s'?"
::engine::mc::EntryAlreadyExists		"Ya existe una entrada con el nombre '%s'."
::engine::mc::NoFeaturesAvailable	"Este motor no provee ninguna característica, ni siquiera esta disponible un modo de análisis. Este motor no puede ser usado para el análisis de posiciones."
::engine::mc::NoStandardChess			"Este motor no tiene soporte para ajedrez estándard."
::engine::mc::NoEngineAvailable		"No hay motores disponibles."
::engine::mc::FailedToCreateDir		"No se pudo crear el directorio '%s'."
::engine::mc::ScriptErrors				"Si ocurren errores durante el guardado se reflejarán aqui."
::engine::mc::CommandNotAllowed		"El uso del comando '%s' no se permite aqui."
::engine::mc::ThrowAwayChanges		"¿Descartar todos los cambios?"
::engine::mc::ResetToDefaultContent	"Volver al contenido predeterminado"

::engine::mc::ProbeError(registration)			"Este motor requiere de registro."
::engine::mc::ProbeError(copyprotection)		"Este motor está protegido contra copias."

::engine::mc::FeatureDetail(analyze)			"Este motor provee un modo de análisis."
::engine::mc::FeatureDetail(multiPV)			"Le permite ver las evaluaciones generadas por el motor y las principales variantes (PV)) con los movimientos candidatos de mayor rango. Estos motores pueden mostrar hasta %s variantes principales."
::engine::mc::FeatureDetail(pause)				"Esto permite un mejor manejo de pausa/continuar: el motor no piensa, evalúa ni consume tiempo significativo del procesador. El análisis activo (si existiera) se suspende y los relojes de ambos jugadores se detienen."
::engine::mc::FeatureDetail(playOther)			"El motor de análisis puede ejecutar el movimiento que usted solicita. Su reloj continuará corriendo mientras el motor analiza el movimiento solicitado."
::engine::mc::FeatureDetail(hashSize)			"Esta característica permite informar al motor de análisis sobre cuánta memoria se le permite usar como máximo para las tablas hash. Este motor permite un rango entre %min y %max MB."
::engine::mc::FeatureDetail(clearHash)			"El usuario puede limpiar las tablas hash mientras el motor de análisis trabaja."
::engine::mc::FeatureDetail(threads)			"Le permite configurar el número de hilos que usará el motor de análisis durante su trabajo. Este motor utiliza entre %min y %max hilos."
::engine::mc::FeatureDetail(smp)					"Este motor de análisis puede utilizar más de un de procesador (núcleo)."
::engine::mc::FeatureDetail(limitStrength)	"El motor de análisis puede limitar su fuerza a un número Elo específico entre %min-%max."
::engine::mc::FeatureDetail(skillLevel)		"El motor de análisis brinda la posibilidad de rebajar su habilidad, donde puede ser derrotado más fácilmente."
::engine::mc::FeatureDetail(ponder)				"Evaluar es simplemente usar el tiempo del movimiento del usuario para considerar sus movimientos posibles y con ello ganar cierta ventaja de pre-procesamiento cuando es nuestro turno de jugar. También se le llama Cerebro Permanente."
::engine::mc::FeatureDetail(chess960)			"Chess960 (o Ajedrez Aleatorio de Fischer) es una variante de ajedrez. El juego utiliza el mismo tanlero y piezas que el ajedrez estándard, pero la posición inicial de las piezas en las dos primeras filas es aleatoria para ambos jugadores, con algunas restricciones para preservar la posibilidad de enrocar en todas las posiciones iniciales, resultando en 960 posiciones únicas."
::engine::mc::FeatureDetail(bughouse)			"Ajedrez Bughouse (también llamado ajedrez de Intercambio, ajedrez Siamés, ajedrez Tandem, ajedrez de Transferencia o Doble Bughouse) es una variante de ajedrez jugada en dos tableros por cuatro jugadores en equipos de dos. Se aplican las reglas normales del ajedrez, excepto que las piezas capturadas en un tablero son pasadas a los jugadores en el otro tablero, quienes tienen la opción de utilizarlas."
::engine::mc::FeatureDetail(crazyhouse)		"Crazyhouse (también conocido como Drop Chess) es una variante de ajedrez similar a Bughouse, pero con solamente dos jugadores. Incorpora una regla del shogi (ajedrez Japonés), según la cual un jugador introduce nuevamente en el tablero como propia una pieza capturada."
::engine::mc::FeatureDetail(suicide)			"Suicidio (también llamado Antichess, Take Me Chess, Must Kill, Reverse Chess) tiene reglas simples: es obligatorio capturar las piezas del contrario y el objetivo es perder todas las piezas propias. No existe el jaque, el Rey se captura como una pieza más. En caso de ahogado, el jugador con menos piezas en el tablero gana (según las reglas de FICS)."
::engine::mc::FeatureDetail(giveaway)			"Ajedrez Giveaway (una variante de Antichess) es como el Suicidio, pero en caso de ahogado el jugador que no puede mover gana (según las reglas internacionales)."
::engine::mc::FeatureDetail(losers)				"Losing Chess es una variante de Antichess, donde el objetivo es perder el juego, pero con varias condiciones adicionales a las reglas. El objetivo es perder todas las piezas (excepto el Rey), aunque enLosers Chess también puede ganarse cuando se recibe mate (según las reglas de ICC)."
::engine::mc::FeatureDetail(3check)				"La característica de esta variante del ajedrez: un jugador gana si da jaque a su oponente tres veces."
::engine::mc::FeatureDetail(playingStyle)		"El motor de análisis proporciona diferentes estilos de juego: %s. Vea el manual del motor de análisis para una explicación de los diferentes estilos."

### analysis ###########################################################
::application::analysis::mc::Control						"Control"
::application::analysis::mc::Information					"Información"
::application::analysis::mc::Setup							"Configuración"
::application::analysis::mc::Pause							"Pausa"
::application::analysis::mc::Resume							"Continuar"
::application::analysis::mc::LockEngine					"Fijar el motor de análisis a esta posición"
::application::analysis::mc::MultipleVariations			"Multiples variantes"
::application::analysis::mc::HashFullness					"Hash lleno"
::application::analysis::mc::Hash							"Hash:"
::application::analysis::mc::Lines							"Líneas:"
::application::analysis::mc::MateIn							"%color da mate en %n"
::application::analysis::mc::BestScore						"Mejor puntaje (de las líneas actuales)"
::application::analysis::mc::CurrentMove					"Actualmente buscando este movimiento"
::application::analysis::mc::TimeSearched					"Tiempo utilizado buscando"
::application::analysis::mc::SearchDepth					"Profundidad de búsqueda en medias-jugadas (Profundidad de búsqueda selectiva)"
::application::analysis::mc::IllegalPosition				"Posición ilegal - No puede analizarse"
::application::analysis::mc::IllegalMoves					"Illegal moves in game - Cannot analyze" ;# NEW
::application::analysis::mc::DidNotReceivePong			"Engine is not responding to \"ping\" command - Engine aborted" ;# NEW

::application::analysis::mc::LinesPerVariation			"Líneas por variación"
::application::analysis::mc::BestFirstOrder				"Ordenar por evaluación"
::application::analysis::mc::Engine							"Motor de Análisis"

# Note for translators: don't use more than 4 characters
::application::analysis::mc::Ply								"ply" ;# NEW
::application::analysis::mc::Seconds						"sec" ;# NEW
::application::analysis::mc::Minutes						"min" ;# NEW

::application::analysis::mc::Status(checkmate)			"%s es jaque mate"
::application::analysis::mc::Status(stalemate)			"%s es ahogado"
::application::analysis::mc::Status(threechecks)		"%s got three checks" ;# NEW
::application::analysis::mc::Status(losing)				"%s lost all pieces" ;# NEW

::application::analysis::mc::NotSupported(standard)	"Este motor de análisis no tiene soporte para ajedrez normal."
::application::analysis::mc::NotSupported(chess960)	"Este motor de análisis no tiene soporte para chess 960."
::application::analysis::mc::NotSupported(variant)		"This engine does not support variant '%s'." ;# NEW
::application::analysis::mc::NotSupported(analyze)		"Este motor no tiene un modo de análisis."

::application::analysis::mc::Signal(stopped)				"Motor de análisis detenido por señal."
::application::analysis::mc::Signal(resumed)				"Motor de análisis continúa por señal."
::application::analysis::mc::Signal(killed)				"Motor de análisis eliminado por señal." ;# NEW change to "Engine crashed or killed by signal."
::application::analysis::mc::Signal(crashed)				"El motor de análisis falló."
::application::analysis::mc::Signal(closed)				"El motor de análisis cerró la conexión."
::application::analysis::mc::Signal(terminated)			"El motor de análisis terminado con código %s."

::application::analysis::mc::Add(move)						"Add move" ;# NEW
::application::analysis::mc::Add(var)						"Add move as new variation" ;# NEW
::application::analysis::mc::Add(line)						"Add variation" ;# NEW
::application::analysis::mc::Add(all)						"Add all variations" ;# NEW

### gametable ##########################################################
::gametable::mc::DeleteGame				"Marcar partida como eliminada"
::gametable::mc::UndeleteGame				"Recuperar esta partida"
::gametable::mc::EditGameFlags			"Editar insignias de la partida"
::gametable::mc::Custom						"Habitual"

::gametable::mc::Monochrome				"Monocromo"
::gametable::mc::Transparent				"Transparente"
::gametable::mc::Relief						"Relieve"
::gametable::mc::ShowIdn					"Mostrar número de posición en Chess 960"
::gametable::mc::Icons						"Iconos"
::gametable::mc::Abbreviations			"Abreviaturas"

::gametable::mc::SortAscending			"Clasificar (ascendente)"
::gametable::mc::SortDescending			"Clasificar (descendente)"
::gametable::mc::SortOnAverageElo		"Clasificar por Elo promedio (descendente)"
::gametable::mc::SortOnAverageRating	"Clasificar por rating promedio (descendente)"
::gametable::mc::SortOnDate				"Clasificar por fecha (descendente)"
::gametable::mc::SortOnNumber				"Clasificar por número de partida (ascendente)"
::gametable::mc::ReverseOrder				"Invertir el orden"
::gametable::mc::CancelSort				"Cancel sort" ;# NEW
::gametable::mc::NoMoves					"Sin jugadas"
::gametable::mc::NoMoreMoves				"No hay mas jugadas"
::gametable::mc::WhiteRating				"Rating de las Blancas"
::gametable::mc::BlackRating				"Rating de las Negras"

::gametable::mc::Flags						"Insignias"
::gametable::mc::PGN_CountryCode			"Código PGN de país"
::gametable::mc::ISO_CountryCode			"Código ISO de país"
::gametable::mc::ExcludeElo				"Excluir Elo"
::gametable::mc::IncludePlayerType		"Incluir tipo de jugador"
::gametable::mc::ShowTournamentTable	"Tabla del torneo"

::gametable::mc::Long						"Largo"
::gametable::mc::Short						"Corto"

::gametable::mc::AccelBrowse				"W"
::gametable::mc::AccelOverview			"O"
::gametable::mc::AccelTournTable			"T"
::gametable::mc::Space						"Espacio"

::gametable::mc::F_Number					"#"
::gametable::mc::F_White					"Blancas"
::gametable::mc::F_Black					"Negras"
::gametable::mc::F_Event					"Evento"
::gametable::mc::F_Site						"Lugar"
::gametable::mc::F_Date						"Fecha"
::gametable::mc::F_Result					"Resultado"
::gametable::mc::F_Round					"Ronda"
::gametable::mc::F_Annotator				"Comentarista"
::gametable::mc::F_Length					"Longitud"
::gametable::mc::F_Termination			"Terminación"
::gametable::mc::F_EventMode				"Modo"
::gametable::mc::F_Eco						"ECO"
::gametable::mc::F_Flags					"Insignias"
::gametable::mc::F_Material				"Material"
::gametable::mc::F_Acv						"ACV"
::gametable::mc::F_Idn						"960"
::gametable::mc::F_Position				"Posición"
::gametable::mc::F_EventDate				"Fecha del Evento"
::gametable::mc::F_EventType				"Tipo de Ev."
::gametable::mc::F_Changed					"Modificado"
::gametable::mc::F_Promotion				"Promoción"
::gametable::mc::F_UnderPromo				"Sub-promoción"
::gametable::mc::F_StandardPos			"Posición estándar"
::gametable::mc::F_Chess960Pos			"9"
::gametable::mc::F_Opening					"Apertura"
::gametable::mc::F_Variation				"Variante"
::gametable::mc::F_Subvariation			"Subvariante"
::gametable::mc::F_Overview				"Visión general"
::gametable::mc::F_Key						"Código ECO interno"

::gametable::mc::T_Number					"Número"
::gametable::mc::T_Acv						"Notas / Comentarios / Variantes"
::gametable::mc::T_WhiteRatingType		"Tipo de valuación de las Blancas"
::gametable::mc::T_BlackRatingType		"Tipo de valuación de las Negras"
::gametable::mc::T_WhiteCountry			"Federación de las Blancas"
::gametable::mc::T_BlackCountry			"Federación de las Negras"
::gametable::mc::T_WhiteTitle				"Título de las Blancas"
::gametable::mc::T_BlackTitle				"Título de las Negras"
::gametable::mc::T_WhiteType				"Tipo de las Blancas"
::gametable::mc::T_BlackType				"Tipo de las Negras"
::gametable::mc::T_WhiteSex				"Sexo de las Blancas"
::gametable::mc::T_BlackSex				"Sexo de las Negras"
::gametable::mc::T_EventCountry			"País del Evento"
::gametable::mc::T_EventType				"Tipo de Evento"
::gametable::mc::T_Chess960Pos			"Posición en Chess 960"
::gametable::mc::T_Deleted					"Eliminado"
::gametable::mc::T_EngFlag					"Insignia de idioma inglés"
::gametable::mc::T_OthFlag					"Insignia de otro idioma"
::gametable::mc::T_Idn						"Número de posición en Chess 960"
::gametable::mc::T_Annotations			"Notas"
::gametable::mc::T_Comments				"Comentarios"
::gametable::mc::T_Variations				"Variantes"
::gametable::mc::T_TimeMode				"Control de tiempo"

::gametable::mc::P_Rating					"Puntaje de rating"
::gametable::mc::P_RatingType				"Tipo de rating"
::gametable::mc::P_Country					"País"
::gametable::mc::P_Title					"Título"
::gametable::mc::P_Type						"Tipo"
::gametable::mc::P_Date						"Fecha"
::gametable::mc::P_Mode						"Modo"
::gametable::mc::P_Sex						"Sexo"
::gametable::mc::P_Name						"Nombre"

::gametable::mc::G_White					"Blancas"
::gametable::mc::G_Black					"Negras"
::gametable::mc::G_Event					"Evento"

::gametable::mc::EventType(game)			"Partida"
::gametable::mc::EventType(match)		"Match"
::gametable::mc::EventType(tourn)		"Torneo"
::gametable::mc::EventType(swiss)		"Suizo"
::gametable::mc::EventType(team)			"Equipo"
::gametable::mc::EventType(k.o.)			"K.O."
::gametable::mc::EventType(simul)		"Simultáneas"
::gametable::mc::EventType(schev)		"Scheveningen"

::gametable::mc::PlayerType(human)		"Humano"
::gametable::mc::PlayerType(program)	"Computadora"

::gametable::mc::GameFlags(w)				"Apertura de las Blancas"
::gametable::mc::GameFlags(b)				"Apertura de las Negras"
::gametable::mc::GameFlags(m)				"Medio juego"
::gametable::mc::GameFlags(e)				"Final"
::gametable::mc::GameFlags(N)				"Novedad"
::gametable::mc::GameFlags(p)				"Estructura de peones"
::gametable::mc::GameFlags(T)				"Táctica"
::gametable::mc::GameFlags(K)				"Ala de rey"
::gametable::mc::GameFlags(Q)				"Ala de dama"
::gametable::mc::GameFlags(!)				"Genialidad"
::gametable::mc::GameFlags(?)				"Error Decisivo"
::gametable::mc::GameFlags(U)				"Usuario"
::gametable::mc::GameFlags(*)				"Mejor partida"
::gametable::mc::GameFlags(D)				"Torneo resuelto"
::gametable::mc::GameFlags(G)				"Partida modelo"
::gametable::mc::GameFlags(S)				"Estrategia"
::gametable::mc::GameFlags(^)				"Ataque"
::gametable::mc::GameFlags(~)				"Sacrificio"
::gametable::mc::GameFlags(=)				"Defensa"
::gametable::mc::GameFlags(M)				"Material"
::gametable::mc::GameFlags(P)				"Juego de piezas"
::gametable::mc::GameFlags(t)				"Error táctico"
::gametable::mc::GameFlags(s)				"Error estratégico"
::gametable::mc::GameFlags(C)				"Entoque Ilegal"
::gametable::mc::GameFlags(I)				"Jugada Ilegal"

### playertable ########################################################
::playertable::mc::F_LastName					"Apellido"
::playertable::mc::F_FirstName				"Nombre"
::playertable::mc::F_FideID					"Fide ID" ;# NEW
::playertable::mc::F_DSBID						"DSB ID" ;# NEW
::playertable::mc::F_ECFID						"ECF ID" ;# NEW
::playertable::mc::F_ICCFID					"ICCF ID" ;# NEW
::playertable::mc::F_Title						"Título"
::playertable::mc::F_Frequency				"Frecuencia"

::playertable::mc::T_Federation				"Federación"
::playertable::mc::T_NativeCountry			"Native Country" ;# NEW
::playertable::mc::T_RatingType				"Tipo de rating"
::playertable::mc::T_Type						"Tipo"
::playertable::mc::T_Sex						"Sexo"
::playertable::mc::T_PlayerInfo				"Bandera"

::playertable::mc::Find							"Búsqueda"
::playertable::mc::StartSearch				"Iniciar búsqueda"
::playertable::mc::ClearEntries				"Vaciar entradas"
::playertable::mc::NotFound					"No se encontró."

::playertable::mc::Name							"Nombre"
::playertable::mc::HighestRating				"Mayor rating"
::playertable::mc::MostRecentRating			"Rating más reciente"
::playertable::mc::DateOfBirth				"Fecha de nacimiento"
::playertable::mc::DateOfDeath				"Fecha de fallecimiento"

::playertable::mc::ShowPlayerCard			"Mostrar Tarjeta del Jugador..." 

### eventtable #########################################################
::eventtable::mc::Attendance	"Asistencia"

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
::playercard::mc::PlayerCard					"Tarjeta del Jugador"
::playercard::mc::Latest						"Máas reciente"
::playercard::mc::Highest						"Más alto"
::playercard::mc::Minimal						"Minimo"
::playercard::mc::Maximal						"Maximo" 
::playercard::mc::Win							"Ganadas" 
::playercard::mc::Draw							"Tablas" 
::playercard::mc::Loss							"Pérdidas" 
::playercard::mc::Total							"Total" 
::playercard::mc::FirstGamePlayed			"Primera partida jugada" 
::playercard::mc::LastGamePlayed				"Última partida jugada"
::playercard::mc::WhiteMostPlayed			"Aperturas más comunes con blancas"
::playercard::mc::BlackMostPlayed			"Aperturas más comunes con negras"

::playercard::mc::OpenInWebBrowser			"Abrir en un navegador"
::playercard::mc::OpenPlayerCard				"Abrir la tarjeta del jugador %s"
::playercard::mc::OpenFileCard				"Abrir la tarjeta del archivo %s"
::playercard::mc::OpenFideRatingHistory	"Abrir el historial de ratings de la Fide"
::playercard::mc::OpenWikipedia				"Abrir la biografía de Wikipedia"
::playercard::mc::OpenViafCatalog			"Abrir el catálogo VIAF"
::playercard::mc::OpenPndCatalog				"Abrir el catálogo de la Deutsche Nationalbibliothek"
::playercard::mc::OpenChessgames				"Colección de partidas de chessgames.com"
::playercard::mc::SeachIn365ChessCom		"Buscar en 365Chess.com"

### twm - tiled window manager #########################################
::twm::mc::Undock	"Desbloquear"
::twm::mc::Close	"Cerrar"

### fonts ##############################################################
::font::mc::ChessBaseFontsInstalled				"Las fuentes de ChessBase se instalaron correctamente."
::font::mc::ChessBaseFontsInstallationFailed	"Falló la instalación de las fuentes de ChessBase."
::font::mc::NoChessBaseFontFound					"No se encontraron las fuentes de ChessBase en la carpeta '%s'." 
::font::mc::ChessBaseFontsAlreadyInstalled	"Las fuentes de ChessBase ya se encuentran instaladas. ¿Instalar nuevamente?"
::font::mc::ChooseMountPoint						"Primero debe escoger el punto de montaje de la partición que contiene la instalació de Windows."
::font::mc::CopyingChessBaseFonts				"Copiando fuentes de ChessBase"
::font::mc::CopyFile									"Copiar archivo %s"
::font::mc::UpdateFontCache						"Actualizando caché de fuentes"

::font::mc::ChooseFigurineFont					"Seleccione la fuente de figurines"
::font::mc::ChooseSymbolFont						"Selecciones la fuente de símbolos"
::font::mc::IncreaseFontSize						"Aumentar el tamaño de la fuente"
::font::mc::DecreaseFontSize						"Disminuir el tamaño de la fuente"

### gamebar ############################################################
::gamebar::mc::StartPosition					"Iniciar posición"
::gamebar::mc::Players							"Jugadores"
::gamebar::mc::Event								"Evento"
::gamebar::mc::Site								"Lugar"
::gamebar::mc::SeparateHeader					"Encabezado separado"
::gamebar::mc::ShowActiveAtBottom			"Mostrar la partida activa al pie"
::gamebar::mc::ShowPlayersOnSeparateLines			"Mostrar los jugadores en líneas separadas"
::gamebar::mc::DiscardChanges					"Esta partida ha cambiado.\n\n¿Realmente desea descartar los cambios realizados?"
::gamebar::mc::DiscardNewGame					"¿Realmente desea descartar esta partida?"
::gamebar::mc::NewGameFstPart					"Nueva"
::gamebar::mc::NewGameSndPart					"Partida"
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

::gamebar::mc::LockGame							"Bloquear Juego"
::gamebar::mc::UnlockGame						"Desbloquear Juego"
::gamebar::mc::CloseGame						"Cerrar Juego"

::gamebar::mc::GameNew							"Nueva partida"

::gamebar::mc::AddNewGame						"Guardar: Agregar nueva partida a %s..."
::gamebar::mc::ReplaceGame						"Guardar: Reemplazar partida en %s..."
::gamebar::mc::ReplaceMoves					"Guardar: Reemplazar jugadas sólo en la partida"

::gamebar::mc::Tip(Antichess)					"There is no check, no castling, the king\nis captured like an ordinary piece." ;# NEW
::gamebar::mc::Tip(Suicide)					"In case of stalemate the side with fewer\npieces will win (according to FICS rules)." ;# NEW
::gamebar::mc::Tip(Giveaway)					"In case of stalemate the side which is\nstalemate wins (according to international rules)." ;# NEW
 ;# NEW
::gamebar::mc::Tip(Losers)						"The king is like in normal chess, and you can also\nwin by getting checkmated or stalemated." ;# NEW

### validate ###########################################################
::validate::mc::Unlimited	"unlimited" ;# NEW

### browser ############################################################
::browser::mc::BrowseGame			"Buscar partida"
::browser::mc::StartAutoplay		"Comenzar Autojuego"
::browser::mc::StopAutoplay		"Parar Autojuego"
::browser::mc::GoForward			"Avanzar una jugada"
::browser::mc::GoBackward			"Retroceder una jugada"
::browser::mc::GoForwardFast		"Avanzar algunas jugadas"
::browser::mc::GoBackFast			"Retroceder algunas jugadas"
::browser::mc::GotoStartOfGame	"Ir al inicio de la partida"
::browser::mc::GotoEndOfGame		"Ir al final de la partida"
::browser::mc::IncreaseBoardSize	"Agrandar el tablero"
::browser::mc::DecreaseBoardSize	"Achicar el tablero"
::browser::mc::MaximizeBoardSize	"Maximizar el tamaño del tablero"
::browser::mc::MinimizeBoardSize	"Minimizar el tamaño del tablero"
::browser::mc::LoadPrevGame		"Load previous game" ;# NEW
::browser::mc::LoadNextGame		"Load next game" ;# NEW

::browser::mc::GotoGame(first)	"Ir a la primera partida"
::browser::mc::GotoGame(last)		"Ir a la última partida"
::browser::mc::GotoGame(next)		"Ir a la siguiente partida"
::browser::mc::GotoGame(prev)		"Ir a la partida anterior"

::browser::mc::LoadGame				"Cargar partida into editor" ;# NEW
::browser::mc::ReloadGame			"Reload game" ;# NEW
::browser::mc::MergeGame			"Fusionar partida"

::browser::mc::IllegalMove			"Jugada ilegal"
::browser::mc::NoCastlingRights	"no puede enrocar"

### overview ###########################################################
::overview::mc::Overview				"Visión general"
::overview::mc::RotateBoard			"Girar el tablero"
::overview::mc::AcceleratorRotate	"R"

### encoding ###########################################################
::encoding::mc::AutoDetect				"auto-detección"

::encoding::mc::Encoding				"Codificar"
::encoding::mc::Description			"Descripción"
::encoding::mc::Languages				"Idiomas (Fuentes)"
::encoding::mc::UseAutoDetection		"Usar Auto-Detección"

::encoding::mc::ChooseEncodingTitle	"Elegir Código"

::encoding::mc::CurrentEncoding		"Codificación actual:"
::encoding::mc::DefaultEncoding		"Codificación predeterminada:"
::encoding::mc::SystemEncoding		"Codificación del sistema:"

### setup ##############################################################
::setup::mc::Position(Chess960)	"Posición de Chess 960"
::setup::mc::Position(Symm960)	"Posición simétrica de chess 960"
::setup::mc::Position(Shuffle)	"Posición de ajedrez Shuffle"

### setup board ########################################################
::setup::position::mc::SetStartPosition		"Configurar una posición inicial"
::setup::position::mc::UsePreviousPosition	"Usar una posición previa"

::setup::board::mc::SetStartBoard				"Configurar tablero de inicio"
::setup::board::mc::SideToMove					"Lado que mueve"
::setup::board::mc::Castling						"Enroque"
::setup::board::mc::MoveNumber					"Número de jugada"
::setup::board::mc::EnPassantFile				"Al paso"
::setup::board::mc::HalfMoves						"Half move clock" ;# NEW
::setup::board::mc::StartPosition				"Posición inicial"
::setup::board::mc::Fen								"FEN"
::setup::board::mc::Promoted						"Promoted" ;# NEW
::setup::board::mc::Holding						"Holding" ;# NEW
::setup::board::mc::ChecksGiven					"Checks Given" ;# NEW
::setup::board::mc::Clear							"Vaciar"
::setup::board::mc::CopyFen						"Copiar FEN al portapapeles"
::setup::board::mc::Shuffle						"Shuffle..." ;# NEW
::setup::board::mc::FICSPosition					"FICS Start Position..." ;# NEW
::setup::board::mc::StandardPosition			"Posición estándar"
::setup::board::mc::Chess960Castling			"Enroque en Chess 960"
::setup::board::mc::InvalidFen					"FEN no válido"

::setup::board::mc::ChangeToFormat(xfen)				"Cambiar a formato X-Fen"
::setup::board::mc::ChangeToFormat(shredder)			"Cambiar a formato Shredder"

::setup::board::mc::Error(InvalidFen)					"FEN no válido."
::setup::board::mc::Error(EmptyBoard)					"El tablero está vacío."
::setup::board::mc::Error(NoWhiteKing)					"Sin rey blanco."
::setup::board::mc::Error(NoBlackKing)					"Sin rey negro."
::setup::board::mc::Error(BothInCheck)					"Ambos reyes en jaque."
::setup::board::mc::Error(OppositeCheck)				"El lado que no mueve está en jaque."
::setup::board::mc::Error(TooManyWhitePawns)			"Demasiados peones blancos."
::setup::board::mc::Error(TooManyBlackPawns)			"Demasiados peones negros."
::setup::board::mc::Error(TooManyWhitePieces)		"Demasiadas piezas blancas."
::setup::board::mc::Error(TooManyBlackPieces)		"Demasiadas piezas negras."
::setup::board::mc::Error(PawnsOn18)					"Peón en la 1ra o en la 8va fila."
::setup::board::mc::Error(TooManyKings)				"Más de dos reyes."
::setup::board::mc::Error(TooManyWhite)				"Demasiadas piezas blancas."
::setup::board::mc::Error(TooManyBlack)				"Demasiadas piezas negras."
::setup::board::mc::Error(BadCastlingRights)			"Derechos de enroque equivocados."
::setup::board::mc::Error(InvalidCastlingRights)	"Fila(s) de la torre irrazonable para el enroque."
::setup::board::mc::Error(InvalidCastlingFile)		"Fila no válida para el enroque."
::setup::board::mc::Error(AmbiguousCastlingFyles)	"El enroque requiere filas con torre para no ser ambiguo (posiblemente estén mal configuradas)."
::setup::board::mc::Error(TooManyPiecesInHolding)	"Too many pieces in holding." ;# NEW
::setup::board::mc::Error(TooManyPromotedPieces)	"Too many pieces marked as promoted." ;# NEW
::setup::board::mc::Error(TooFewPromotedPieces)		"Too few pieces marked as promoted."
::setup::board::mc::Error(InvalidEnPassant)			"Fila al paso no razonable."
::setup::board::mc::Error(MultiPawnCheck)				"Dos o más peones dando jaque."
::setup::board::mc::Error(TripleCheck)					"Tres o más piezas dando jaque."

::setup::board::mc::Warning(TooFewPiecesInHolding)	"Too few pieces marked as promoted. Are you sure that this is ok?" ;# NEW
::setup::board::mc::Warning(CastlingWithoutRook)	"Existen derechos de enroque pero al menos una de las torres no está. Esto sólo sucede en partidas con ventaja. ¿Está seguro que los derechos de enroque son correctos?"
::setup::board::mc::Warning(UnsupportedVariant)		"La posición es una posición de inicio pero no corresponde a una posición de Shuffle Chess. ¿Está seguro?"

### import #############################################################
::import::mc::ImportingPgnFile					"Importar archivo PGN '%s'"
::import::mc::ImportingDatabase					"Importando base de datos '%s'"
::import::mc::Line									"Línea"
::import::mc::Column									"Columna"
::import::mc::GameNumber							"Partida"
::import::mc::ImportedGames						"%s partida(s) importada(s)"
::import::mc::NoGamesImported						"Ninguna partida importada"
::import::mc::FileIsEmpty							"el archivo probablemente está vacío"
::import::mc::DatabaseImport						"Importar base"
::import::mc::ImportPgnGame						"Importar partida PGN"
::import::mc::ImportPgnVariation					"Importar variante PGN"
::import::mc::ImportOK								"Texto PGN importado sin errores o advertencias."
::import::mc::ImportAborted						"Importación abortada."
::import::mc::TextIsEmpty							"El texto PGN está vacío."
::import::mc::AbortImport							"¿Abortar importación de PGN?"
::import::mc::UnsupportedVariantRejected		"Unsuported variant '%s' rejected" ;# NEW
::import::mc::Accepted								"accepted" ;# NEW
::import::mc::Rejected								"rejected" ;# NEW

::import::mc::DifferentEncoding					"La codificación seleccinada %src no coincide con la codificación del archivo %dst."
::import::mc::DifferentEncodingDetails			"Recodificar la base de datos no funcionará más despué de esta acción."
::import::mc::CannotDetectFigurineSet			"No puede auto-detectarse un juego de piezas adecuado."
::import::mc::TryAgainWithEnglishSet			"Try again with English figurines?" ;# NEW
::import::mc::TryAgainWithEnglishSetDetail	"It may be helpful to use English figurines, because this is standard in PGN format." ;# NEW
::import::mc::CheckImportResult					"Por favor revise si se ha detectado el juego de piezas correcto: %s."
::import::mc::CheckImportResultDetail			"En algunos casos la auto-detección falla debido a ambiguedades."

::import::mc::EnterOrPaste							"Ingrese o pegue en formato PGN %s en el cuadro de arriba.\nCualquier falla al importar el %s se mostrará aquí."
::import::mc::EnterOrPaste-Game					"partida"
::import::mc::EnterOrPaste-Variation			"variante"

::import::mc::UnsupportedVariant					"Unsuported variant rejected" ;# NEW
::import::mc::MissingWhitePlayerTag				"Jugador de las Blancas desconocido"
::import::mc::MissingBlackPlayerTag				"Jugador de las Negras desconocido"
::import::mc::MissingPlayerTags					"Jugadores desconocidos"
::import::mc::MissingResult						"Resultado desconocido (al final de la sección de jugadas)"
::import::mc::MissingResultTag					"Resultado desconocido (en la sección encabezado)"
::import::mc::InvalidRoundTag						"Ronda no válida en el encabezado"
::import::mc::InvalidResultTag					"Resultado no válido en el encabezado"
::import::mc::InvalidDateTag						"Fecha no válida en el encabezado"
::import::mc::InvalidEventDateTag				"Fecha del evento no válida en el encabezado"
::import::mc::InvalidTimeModeTag					"Parámetros de tiempo no válidos en el encabezado"
::import::mc::InvalidEcoTag						"ECO no válido en el encabezado"
::import::mc::InvalidTagName						"Nombre no válido en el encabezado (ignorado)"
::import::mc::InvalidCountryCode					"Código de país no válido"
::import::mc::InvalidRating						"Número de rating no válido"
::import::mc::InvalidNag							"NAG no válido"
::import::mc::BraceSeenOutsideComment			"\"\}\" fuera de un comentario en la partida (se ignorarán)" 
::import::mc::MissingFen							"Partida de Ajedrez Shuffle/960 sin posición de inicio especificada; se interpretará como Ajedrez estándar"
::import::mc::UnknownEventType					"Tipo de evento desconocido"
::import::mc::UnknownTitle							"Título desconocido (ignored)"
::import::mc::UnknownPlayerType					"Tipo de jugador desconocido (ignorado)"
::import::mc::UnknownSex							"Sexo desconocido (ignorado)"
::import::mc::UnknownTermination					"Motivo de la terminación desconocido"
::import::mc::UnknownMode							"Modo desconocido"
::import::mc::RatingTooHigh						"Número de valuación demasiado alto (ignorado)"
::import::mc::EncodingFailed						"Encoding failed" ;# NEW "Character decoding failed"
::import::mc::TooManyNags							"Demasiados NAG's (se ignorará el último)"
::import::mc::IllegalCastling						"Enroque ilegal"
::import::mc::IllegalMove							"Jugada ilegal"
::import::mc::CastlingCorrection					"Corrección del enroque"
::import::mc::DecodingFailed						"No se pudo decodificar esta partida"
::import::mc::ResultDidNotMatchHeaderResult	"El resultado no es igual al resultado del encabezado"
::import::mc::ValueTooLong							"El encabezado es demasiado largo y se cortará a los 255 caracteres"
::import::mc::NotSuicideNotGiveaway				"Due to the outcome of the game the variant isn't either Suicide or Giveaway." ;# NEW
::import::mc::VariantChangedToGiveaway			"Due to the outcome of the game the variant has been changed to Giveaway" ;# NEW
::import::mc::VariantChangedToSuicide			"Due to the outcome of the game the variant has been changed to Suicide" ;# NEW
::import::mc::ResultCorrection					"Due to the final position of the game a correction of the result has been done" ;# NEW
::import::mc::MaximalErrorCountExceeded		"Máximo de errores excedido; no se informarán más errores (del tipo de error previo)"
::import::mc::MaximalWarningCountExceeded		"Máximo de advertencias excedido; no se informarán más advertencias (del tipo previo de advertencias)"
::import::mc::InvalidToken							"Símbolo no válido"
::import::mc::InvalidMove							"Jugada no válida"
::import::mc::UnexpectedSymbol					"Símbolo inesperado"
::import::mc::UnexpectedEndOfInput				"Inesperado final de la entrada de datos"
::import::mc::UnexpectedResultToken				"Símbolo de resultado inesperado"
::import::mc::UnexpectedTag						"Etiqueta inesperada dentro de la partida"
::import::mc::UnexpectedEndOfGame				"Final de la partida inesperado (resultado desconocido)"
::import::mc::UnexpectedCastling					"Unexpected castling (not allowed in this chess variant)" ;# NEW
::import::mc::ContinuationsNotSupported		"'Continuations' not supported" ;# NEW
::import::mc::TagNameExpected						"Error de sintaxis: se esperaba un nombre en el encabezado"
::import::mc::TagValueExpected					"Error de sintaxis: Se esperaba un valor en el encabezado"
::import::mc::InvalidFen							"FEN no válido"
::import::mc::UnterminatedString					"Flujo no determinado"
::import::mc::UnterminatedVariation				"Variante no determinada"
::import::mc::TooManyGames							"Demasiadas partidas en la base (abortado)"
::import::mc::GameTooLong							"Partida demasiado larga (omitida)"
::import::mc::FileSizeExceeded					"Se excede el tamaño máximo de archivo (2GB) (abortado)"
::import::mc::TooManyPlayerNames					"Demasiados nombres de jugadores en la base (abortado)"
::import::mc::TooManyEventNames					"Demasiados nombres de evento en la base (abortado)"
::import::mc::TooManySiteNames					"Demasiados nombres de lugares en la base (abortado)"
::import::mc::TooManyRoundNames					"Demasiados nombres de ronda en la base"
::import::mc::TooManyAnnotatorNames				"Demasiados nombres de comentaristas en la base (abortado)"
::import::mc::TooManySourceNames					"Demasiados nombres de orígenes en la base (abortado)"
::import::mc::SeemsNotToBePgnText				"No parece ser un texto PGN"
::import::mc::AbortedDueToInternalError		"Abortado debido a un error interno"
::import::mc::AbortedDueToIoError				"Abortado debido a un error de lectura/escritura"
::import::mc::UserHasInterrupted					"Interrumpido por el usuario"

### export #############################################################
::export::mc::FileSelection				"&Selección de archivo"
::export::mc::OptionsSetup					"&Opciones"
::export::mc::PageSetup						"&Configuración de página"
::export::mc::DiagramSetup					"Configuración de &Diagrama"
::export::mc::StyleSetup					"&Estilo"
::export::mc::EncodingSetup				"Cod&ificación"
::export::mc::TagsSetup						"E&tiquetas"
::export::mc::NotationSetup				"&Notación"
::export::mc::AnnotationSetup				"Not&as"
::export::mc::CommentsSetup				"Co&mentarios"

::export::mc::Visibility					"Visibilidad"
::export::mc::HideDiagrams					"Ocultar Diagramas"
::export::mc::AllFromWhitePersp			"Desde la perspectiva de las Blancas"
::export::mc::AllFromBlackPersp			"Desde la perspectiva de las Negras"
::export::mc::ShowCoordinates				"Mostrar coordenadas"
::export::mc::ShowSideToMove				"Mostrar el lado que mueve"
::export::mc::ShowArrows					"Mostrar Flechas"
::export::mc::ShowMarkers					"Mostrar Marcedores"
::export::mc::Layout							"Disposición"
::export::mc::PostscriptSpecials			"Especialidades Postscript"
::export::mc::BoardSize						"Tamaño del tablero"

::export::mc::Short							"Corto"
::export::mc::Long							"Largo"
::export::mc::Algebraic						"Algebraico"
::export::mc::Correspondence				"Correspondencia"
::export::mc::Telegraphic					"Telegráfico"
::export::mc::FontHandling					"Manejo de fuentes"
::export::mc::DiagramStyle					"Estilo del Diagrama"
::export::mc::UseImagesForDiagram		"Usar imágenes para generar el diagrama"
::export::mc::EmebedTruetypeFonts		"Empotrar fuentes TrueType"
::export::mc::UseBuiltinFonts				"Usar fuentes incluidas"
::export::mc::SelectExportedTags			"Selección de etiquetas exportadas"
::export::mc::ExcludeAllTags				"Excluir todas las etiquetas"
::export::mc::IncludeAllTags				"Incluir todas las etiquetas"
::export::mc::ExtraTags						"Todas las etiquetas extra"
::export::mc::NoComments					"Sin comentarios"
::export::mc::AllLanguages					"Todos los idiomas"
::export::mc::Significant					"Significante"
::export::mc::LanguageSelection			"Selección de idioma"
::export::mc::MapTo							"Mapear a"
::export::mc::MapNagsToComment			"Mapear anotaciones a los comentarios"
::export::mc::UnusualAnnotation			"Anotaciones Inusuales"
::export::mc::AllAnnotation				"Todas las  anotaciones"
::export::mc::UseColumnStyle				"Usar estilo de columas"
::export::mc::MainlineStyle				"Estilo de Lúnea principal"
::export::mc::HideVariations				"Ocultar variaciones"

::export::mc::PdfFiles						"Archivos PDF"
::export::mc::HtmlFiles						"Archivos HTML"
::export::mc::TeXFiles						"Archivos LaTeX"

::export::mc::ExportDatabase				"Exportar base"
::export::mc::ExportDatabaseVariant		"Export database - variant %s" ;# NEW
::export::mc::ExportDatabaseTitle		"Exportar base '%s'"
::export::mc::ExportCurrentGameTitle	"Export Current Game" ;# NEW
::export::mc::ExportingDatabase			"Exportando '%s' al archivo '%s'"
::export::mc::Export							"Exportar"
::export::mc::NoGamesCopied				"No se exportaron partidas."
::export::mc::ExportedGames				"%s partida(s) exportada(s)"
::export::mc::NoGamesForExport			"No hay partidas para exportar."
::export::mc::ResetDefaults				"Volver a los parámetros predeterminados"
::export::mc::UnsupportedEncoding		"No use la codificación %s para documentos PDF. Debe elegir una codificación alternativa."
::export::mc::DatabaseIsOpen				"La base de datos de destino '%s' se encuentra abierta, esto significa que será vaciada antes de iniciar la exportación. ¿Continuar?"
::export::mc::DatabaseIsOpenDetail		"Si lo que desea es agregar debe arrastrar y soltar en el cambiador de bases de datos."
::export::mc::ExportGamesFromTo			"Exportar partidas de '%src' a '%dst'"
::export::mc::IllegalRejected				"%s game(s) rejected due to illegal moves" ;# NEW

::export::mc::BasicStyle					"Estilo básico"
::export::mc::GameInfo						"Información de la partida"
::export::mc::GameText						"Texto de la partida"
::export::mc::Moves							"Jugadas"
::export::mc::MainLine						"Línea principal"
::export::mc::Variation						"Variante"
::export::mc::Subvariation					"Subvariante"
::export::mc::Figurines						"Piezas"
::export::mc::Hyphenation					"Uso de guiones"
::export::mc::None							"(ninguno)"
::export::mc::Symbols						"Simbolos"
::export::mc::Comments						"Comentarios"
::export::mc::Result							"Resultado"
::export::mc::Diagram						"Diagrama"
::export::mc::ColumnStyle					"Estilo de Columnas"

::export::mc::Paper							"Papel"
::export::mc::Orientation					"Orientación"
::export::mc::Margin							"Márgenes"
::export::mc::Format							"Formato"
::export::mc::Size							"Tamaño"
::export::mc::Custom							"Habitual"
::export::mc::Potrait						"Retrato"
::export::mc::Landscape						"Apaisado"
::export::mc::Justification				"Justificado"
::export::mc::Even							"Ajustado"
::export::mc::Columns						"Columnas"
::export::mc::One								"Una"
::export::mc::Two								"Dos"

::export::mc::DocumentStyle				"Estilo del Documento"
::export::mc::Article						"Articulo"
::export::mc::Report							"Reporte"
::export::mc::Book							"Libro"

::export::mc::FormatName(scidb)			"Scidb"
::export::mc::FormatName(scid)			"Scid"
::export::mc::FormatName(pgn)				"PGN"
::export::mc::FormatName(pdf)				"PDF"
::export::mc::FormatName(html)			"HTML"
::export::mc::FormatName(tex)				"LaTeX"
::export::mc::FormatName(ps)				"Postscript"

::export::mc::Option(pgn,include_varations)						"Exportar variantes"
::export::mc::Option(pgn,include_comments)						"Exportar comentarios"
::export::mc::Option(pgn,include_moveinfo)						"Exportar información de las jugadas (como comentarios)"
::export::mc::Option(pgn,include_marks)							"Exportar marcadores (como comentarios)"
::export::mc::Option(pgn,use_scidb_import_format)				"Usar el formato de importación de Scidb"
::export::mc::Option(pgn,use_chessbase_format)					"Usar formato ChessBase"
::export::mc::Option(pgn,use_strict_pgn_standard				"Use PGN standard" ;# NEW
::export::mc::Option(pgn,include_ply_count_tag)					"Escribir la etiqueta 'PlyCount'"
::export::mc::Option(pgn,include_termination_tag)				"Escribir etiqueta 'Termination'"
::export::mc::Option(pgn,include_mode_tag)						"Escribir etiqueta 'Mode'"
::export::mc::Option(pgn,include_opening_tag)					"Escribir etiquetas 'Opening', 'Variation', 'Subvariation'"
::export::mc::Option(pgn,include_setup_tag)						"Escribir etiqueta 'Setup' (si es necesario)"
::export::mc::Option(pgn,include_variant_tag)					"Escribir etiqueta 'Variant' (si es necesario)"
::export::mc::Option(pgn,include_position_tag)					"Escribir etiqueta 'Position' (si es necesario)"
::export::mc::Option(pgn,include_time_mode_tag)					"Escribir etiqueta 'TimeMode' (si es necesario)"
::export::mc::Option(pgn,exclude_extra_tags)						"Excluir etiquetas superfluas"
::export::mc::Option(pgn,indent_variations)						"Sangrar variantes"
::export::mc::Option(pgn,indent_comments)							"Sangrar comentarios"
::export::mc::Option(pgn,column_style)								"Estilo columna (una jugada por línea)"
::export::mc::Option(pgn,symbolic_annotation_style)			"Estilo simbólico de comentarios (!, !?)"
::export::mc::Option(pgn,extended_symbolic_style)				"Estilo simbólico extendido de comentarios (+=, +/-)"
::export::mc::Option(pgn,convert_null_moves)						"Convertir las jugadas nulas en comentarios"
::export::mc::Option(pgn,space_after_move_number)				"Agregar espacio tras los números de jugada"
::export::mc::Option(pgn,shredder_fen)								"Escribir Shredder-FEN (X-FEN es lo predeterminado)"
::export::mc::Option(pgn,convert_lost_result_to_comment)		"Escribir comentario para el resultado '0-0'"
::export::mc::Option(pgn,write_any_rating_as_elo)				"Write any rating as ELO" ;# NEW
::export::mc::Option(pgn,append_mode_to_event_type)			"Agregar modo tras el tipo de evento"
::export::mc::Option(pgn,comment_to_html)							"Escribir comentario en estilo HTML"
::export::mc::Option(pgn,exclude_games_with_illegal_moves)	"Excluir partidas con jugadas ilegales"
::export::mc::Option(pgn,use_utf8_encoding)						"Utilizar codificación UTF-8"

### notation ###########################################################
::notation::mc::Notation		"Notación"

::notation::mc::MoveForm(alg)	"Algebraica" 
::notation::mc::MoveForm(san)	"Algebraica Corta" 
::notation::mc::MoveForm(lan)	"Algebraica Larga" 
::notation::mc::MoveForm(eng)	"Inglés" 
::notation::mc::MoveForm(cor)	"Correspondencia" 
::notation::mc::MoveForm(tel)	"Telegrafico" 

### figurine ###########################################################
::figurines::mc::Figurines	"Piezas"
::figurines::mc::Graphic	"Gráficos"
::figurines::mc::User		"Personalizado"

### save/replace #######################################################
::dialog::save::mc::SaveGame						"Guardar partida"
::dialog::save::mc::ReplaceGame					"Reemplazar partida"
::dialog::save::mc::EditCharacteristics		"Editar características"
	
::dialog::save::mc::GameData						"Datos de la partida"
::dialog::save::mc::Event							"Evento"

::dialog::save::mc::MatchesExtraTags			"Etiquetas iguales / Extra Etiquetas"
::dialog::save::mc::PressToSelect				"Presione Ctrl+0 a Ctrl+9 (o el botón izquierdo del ratón) para seleccionar"
::dialog::save::mc::PressForWhole				"Presione Alt-0 a Alt-9 (o el botón medio del ratón) para grupo de datos completo"
::dialog::save::mc::EditTags						"Editar etiquetas"
::dialog::save::mc::RemoveThisTag				"Eliminar etiqueta '%s'?"
::dialog::save::mc::TagAlreadyExists			"El nombre de etiqueta '%s' ya existe."
::dialog::save::mc::TagRemoved					"La etiqueta sobrante '%s' (valor actual: '%s') será eliminada."
::dialog::save::mc::TagNameIsReserved			"El nombre de etiqueta '%s' está reservado."
::dialog::save::mc::Locked							"Bloqueado"
::dialog::save::mc::OtherTag						"Otra etiqueta"
::dialog::save::mc::NewTag							"Agregar nueva etiqueta"
::dialog::save::mc::RemoveTag						"Etiqueta eliminada"
::dialog::save::mc::SetToGameDate				"Establecer fecha de la partida"
::dialog::save::mc::SaveGameFailed				"Guardado de la partida fallido."
::dialog::save::mc::SaveGameFailedDetail		"Ver bitácora para los detalles."
::dialog::save::mc::SavingGameLogInfo			"Guardar partida (%white - %black, %event) en base '%base'"
::dialog::save::mc::CurrentBaseIsReadonly		"La base actual '%s' es de sólo lectura."
::dialog::save::mc::CurrentGameHasTrialMode	"El juego actual está en modo de prueba y no puede ser guardado."
::dialog::save::mc::OpenPlayerDictionary		"Open Player Dictionary" ;# NEW

::dialog::save::mc::LocalName						"&Nombre local"
::dialog::save::mc::EnglishName					"Nombre I&nglés"
::dialog::save::mc::ShowRatingType				"Mostrar &rating"
::dialog::save::mc::EcoCode						"Código &ECO"
::dialog::save::mc::Matches						"&Matches"
::dialog::save::mc::Tags							"E&tiquetas"

::dialog::save::mc::Label(name)					"Nombre"
::dialog::save::mc::Label(fideID)				"Fide-ID"
::dialog::save::mc::Label(value)					"Valor"
::dialog::save::mc::Label(title)					"Título"
::dialog::save::mc::Label(rating)				"Rating"
::dialog::save::mc::Label(federation)			"Federación"
::dialog::save::mc::Label(country)				"País"
::dialog::save::mc::Label(eventType)			"Tipo"
::dialog::save::mc::Label(sex)					"Sexo/Tipo"
::dialog::save::mc::Label(date)					"Fecha"
::dialog::save::mc::Label(eventDate)			"Fecha del evento"
::dialog::save::mc::Label(round)					"Ronda"
::dialog::save::mc::Label(result)				"Resultado"
::dialog::save::mc::Label(termination)			"Terminación"
::dialog::save::mc::Label(annotator)			"Comentarista"
::dialog::save::mc::Label(site)					"Lugar"
::dialog::save::mc::Label(eventMode)			"Modo"
::dialog::save::mc::Label(timeMode)				"Tiempo"
::dialog::save::mc::Label(frequency)			"Frecuencia"
::dialog::save::mc::Label(score)					"Rating secundario"

::dialog::save::mc::GameBase						"Base de partidas"
::dialog::save::mc::PlayerBase					"Base de jugadores"
::dialog::save::mc::EventBase						"Base de eventos"
::dialog::save::mc::SiteBase						"Base de lugares"
::dialog::save::mc::AnnotatorBase				"Base de comentaristas"
::dialog::save::mc::History						"Historial"

::dialog::save::mc::InvalidEntry					"'%s' no es una entrada válida."
::dialog::save::mc::InvalidRoundEntry			"'%s' no es una entrada de ronda válida."
::dialog::save::mc::InvalidRoundEntryDetail	"Entradas de ronda válidas son '4' ó '6.1'. No se permiten ceros."
::dialog::save::mc::RoundIsTooHigh				"La ronda debería ser menor a 256."
::dialog::save::mc::SubroundIsTooHigh			"La sub-ronda debería ser menor a 256."
::dialog::save::mc::ImplausibleDate				"La fecha de la partida '%s' es anterior a la fecha del evento '%s'."
::dialog::save::mc::InvalidTagName				"Nombre de etiqueta no válido '%s' (error de sintaxis)."
::dialog::save::mc::Field							"Campo '%s': "
::dialog::save::mc::ExtraTag						"Etiqueta extra '%s': "
::dialog::save::mc::InvalidNetworkAddress		"Dirección de red '%s' no válida."
::dialog::save::mc::InvalidCountryCode			"Código de país '%s' no válido."
::dialog::save::mc::InvalidEventRounds			"Número de rondas del evento '%s' no válido (se espera un número entero positivo)."
::dialog::save::mc::InvalidPlyCount				"Recuento de jugadas '%s' no válido (se espera un número entero positivo)."
::dialog::save::mc::IncorrectPlyCount			"Recuento de jugadas '%s' incorrecto (el recuento de jugadas real es %s)."
::dialog::save::mc::InvalidTimeControl			"Entrada del campo de control de tiempo en '%s' no válida."
::dialog::save::mc::InvalidDate					"Fecha '%s' no válida."
::dialog::save::mc::InvalidYear					"Año '%s' no válido."
::dialog::save::mc::InvalidMonth					"Mes '%s' no válido."
::dialog::save::mc::InvalidDay					"Día '%s' no válido."
::dialog::save::mc::MissingYear					"Se desconoce el año."
::dialog::save::mc::MissingMonth					"Se desconoce el mes."
::dialog::save::mc::StringTooLong				"Etiqueta %tag%: la cadena '%value%' es demasiado larga y se cortará a '%trunc%'."
::dialog::save::mc::InvalidEventDate			"No se puede aceptar la fecha de evento suministrada: La diferencia entre el año de la partida y el año del evento debería ser menor a 4 (restricción del formato de base de datos de Scid)."
::dialog::save::mc::TagIsEmpty					"La etiqueta '%s' está vacía (se descartará)."

### gamehistory ########################################################
::game::history::mc::GameHistory	"Historial de Juegos"

### game ###############################################################
::game::mc::CloseDatabase					"Cerrar base de datos"
::game::mc::CloseAllGames					"¿Cerrar todas las partidas abiertas de la base de datos '%s'?"
::game::mc::SomeGamesAreModified			"Se modificaron algunas partidas de la base de datos '%s'. ¿Cerrar de todos modos?" 
::game::mc::AllSlotsOccupied				"Todos los espacios para partidas están ocupados."
::game::mc::ReleaseOneGame					"Por favor, saque una de las partidas antes de cargar otra."
::game::mc::GameAlreadyOpen				"La partida ya está abierta pero fue modificada. ¿Descartar la versión modificada de esta partida?"
::game::mc::GameAlreadyOpenDetail		"'%s' abrirá una nueva partida."
::game::mc::GameHasChanged					"La partida %s se ha modificado."
::game::mc::GameHasChangedDetail			"Probablemente este no es el juego esperado debido al cambio de bases de datos."
::game::mc::CorruptedHeader				"Encabezado corrupto en el archivo de recuperación '%s'."
::game::mc::RenamedFile						"Renombrar este archivo como '%s.bak'."
::game::mc::CannotOpen						"No se puede abrir el archivo de recuperación '%s'."
::game::mc::GameRestored					"Una partida restablecida de la última sesión."
::game::mc::GamesRestored					"%s partidas restablecidas de la última sesión."
::game::mc::OldGameRestored				"Una partida restablecida."
::game::mc::OldGamesRestored				"%s partidas restablecidas."
::game::mc::ErrorInRecoveryFile			"Error en el archivo de recuperación '%s'"
::game::mc::Recovery							"Recuperación"
::game::mc::UnsavedGames					"Usted tiene cambios en la partida que no se han guardado."
::game::mc::DiscardChanges					"'%s' descartará todos los cambios."
::game::mc::ShouldRestoreGame				"¿Desea restablecer esta partida en la próxima sesión?"
::game::mc::ShouldRestoreGames			"¿Desea restablecer estas partidas en la sesión siguiente?"
::game::mc::NewGame							"Nueva partida"
::game::mc::NewGames							"Nuevas partidas"
::game::mc::Created							"creado"
::game::mc::ClearHistory					"Limpiar Historial"
::game::mc::RemoveSelectedGame			"Remover el juego seleccionado del historial"
::game::mc::GameDataCorrupted				"Los datos de la partida son erróneos."
::game::mc::GameDecodingFailed			"No se pudo decodificar esta partida."
::game::mc::GameDecodingChanged			"La base de datos fue abierta usando el juego de caracteres '%base%', pero esta partida parece estar codificada usando '%game%', por ello, esta partida se cargará usando el juego de caracteres detectado."
::game::mc::GameDecodingChangedDetail	"Probablemente se abriá la base de datos con el juego de caracteres equivocado. Note que la detección automática del juego de caracteres es limitada."
::game::mc::VariantHasChanged				"Game cannot be opened because the variant of the database has changed and is now different from the game variant." ;# NEW
::game::mc::RemoveGameFromHistory		"Remove game from history?" ;# NEW
::game::mc::GameNumberDoesNotExist		"Game %number does not exist in '%base'."
::game::mc::ReallyReplaceGame				"It seems that the actual game #%s is not the originally loaded game due to intermediate database changes, it is likely that you lose a different game. Really replace game data?" ;# NEW
::game::mc::ReallyReplaceGameDetail		"It is recommended to have a look on game #%s before doing this action." ;# NEW

### languagebox ########################################################
::languagebox::mc::AllLanguages	"Todos los idiomas"
::languagebox::mc::None				"Ninguno"

### datebox ############################################################
::datebox::mc::Today		"Hoy"
::datebox::mc::Calendar	"Calendario..."
::datebox::mc::Year		"Año"
::datebox::mc::Month		"Mes"
::datebox::mc::Day		"Día"

### genderbox ##########################################################
::genderbox::mc::Gender(m) "Masculino"
::genderbox::mc::Gender(f) "Femenino"
::genderbox::mc::Gender(c) "Computadora"

### terminationbox #####################################################
::terminationbox::mc::Normal								"Normal"
::terminationbox::mc::Unplayed							"No jugado"
::terminationbox::mc::Abandoned							"Abandona"
::terminationbox::mc::Adjudication						"Adjudicación"
::terminationbox::mc::Disconnection						"Desconección"
::terminationbox::mc::Emergency							"Emergencia"
::terminationbox::mc::RulesInfraction					"Infracción a las reglas"
::terminationbox::mc::TimeForfeit						"Pierde por tiempo"
::terminationbox::mc::Unterminated						"No terminada"

::terminationbox::mc::State(Checkmate)					"%s es jaque mate"
::terminationbox::mc::State(Stalemate)					"%s es ahogado"
::terminationbox::mc::State(ThreeChecks)				"%s got three checks" ;# NEW
::terminationbox::mc::State(Losing)						"%s wins by losing all material" ;# NEW

::terminationbox::mc::Result(1-0)						"Las negras se rinden"
::terminationbox::mc::Result(0-1)						"Las blancas se rinden"
::terminationbox::mc::Result(0-0)						"Se declara perdida para ambos jugadores"
::terminationbox::mc::Result(1/2-1/2)					"Se acordó tablas"

::terminationbox::mc::Reason(Unplayed)					"La partida no se jugó"
::terminationbox::mc::Reason(Abandoned)				"Se abandonó la partida"
::terminationbox::mc::Reason(Adjudication)			"Adjudicado"
::terminationbox::mc::Reason(Disconnection)			"Disconnection" ;# NEW
::terminationbox::mc::Reason(Emergency)				"Abandonado por una emergencia"
::terminationbox::mc::Reason(RulesInfraction)		"Decidido debido a infracción de las reglas"
::terminationbox::mc::Reason(TimeForfeit)				"%s pierde por tiempo"
::terminationbox::mc::Reason(TimeForfeit,both)		"Ambos jugadores pierden por tiempo"
::terminationbox::mc::Reason(TimeForfeit,remis)		"%causer ran out of time and %opponent cannot win" ;# NEW
::terminationbox::mc::Reason(Unterminated)			"No finalizado"

::terminationbox::mc::Termination(equal-material)	"Game drawn by stalemate (equal material)" ;# NEW
::terminationbox::mc::Termination(less-material)	"%s wins by having less material (stalemate)"
::terminationbox::mc::Termination(bishops)			"Game drawn by stalemate (opposite color bishops)" ;# NEW
::terminationbox::mc::Termination(fifty)				"Game drawn by the 50 move rule" ;# NEW
::terminationbox::mc::Termination(threefold)			"Game drawn by threefold repetition" ;# NEW
::terminationbox::mc::Termination(nomating)			"Neither player has mating material" ;# NEW
::terminationbox::mc::Termination(nocheck)			"Neither player can give check" ;# NEW

### eventmodebox #######################################################
::eventmodebox::mc::OTB				"En tablero"
::eventmodebox::mc::PM				"Correspondencia"
::eventmodebox::mc::EM				"E-mail"
::eventmodebox::mc::ICS				"Internet Chess Server"
::eventmodebox::mc::TC				"Telecomunicación"
::eventmodebox::mc::Analysis		"Análisis"
::eventmodebox::mc::Composition	"Composición"

### eventtypebox #######################################################
::eventtypebox::mc::Type(game)	"Partida individual"
::eventtypebox::mc::Type(match)	"Match"
::eventtypebox::mc::Type(tourn)	"Round Robin"
::eventtypebox::mc::Type(swiss)	"Torneo por sistema suizo"
::eventtypebox::mc::Type(team)	"Torneo por equipos"
::eventtypebox::mc::Type(k.o.)	"Torneo por Knockout"
::eventtypebox::mc::Type(simul)	"Torneo de simultáneas"
::eventtypebox::mc::Type(schev)	"Torneo por sistema Scheveningen"  

### timemodebox ########################################################
::timemodebox::mc::Mode(normal)	"Normal"
::timemodebox::mc::Mode(rapid)	"Rápidas"
::timemodebox::mc::Mode(blitz)	"Blitz"
::timemodebox::mc::Mode(bullet)	"Bullet"
::timemodebox::mc::Mode(corr)		"Correspondencia"

### help ###############################################################
::help::mc::Contents					"&Contenido"
::help::mc::Index						"&Indice"
::help::mc::CQL						"C&QL"
::help::mc::Search					"Bu&scar"

::help::mc::Help						"Ayuda"
::help::mc::MatchEntireWord		"Coincidir palabra completa"
::help::mc::MatchCase				"Coincidir capitalización"
::help::mc::TitleOnly				"Buscar solamente en tútulos"
::help::mc::CurrentPageOnly		"Buscar solamente en la página actual"
::help::mc::GoBack					"Retroceder una página"
::help::mc::GoForward				"Avanzar una página"
::help::mc::GotoHome					"Go to top of page" ;# NEW
::help::mc::GotoEnd					"Go to end of page" ;# NEW
::help::mc::GotoPage					"Ir a la página '%s'"
::help::mc::ExpandAllItems			"Expandir todo"
::help::mc::CollapseAllItems		"Colapsar todo"
::help::mc::SelectLanguage			"Seleccionar idioma"
::help::mc::NoHelpAvailable		"No hay archivos de ayuda en Español.\nPor favor seleccione un lenguaje alternativo\npara el diálogo de ayuda."
::help::mc::NoHelpAvailableAtAll	"No help files available for this topic."
::help::mc::KeepLanguage			"¿Mantener el idioma  %s para sesiones futuras?"
::help::mc::ParserError				"Error al analizar archivo %s."
::help::mc::NoMatch					"No se encontró una coincidencia"
::help::mc::MaxmimumExceeded		"Se excedió el número máximo de coincidencias en algunas páginas."
::help::mc::OnlyFirstMatches		"Solo se mostrarán las primeras %s coincidencias por página."
::help::mc::HideIndex				"Ocultar el úndice"
::help::mc::ShowIndex				"Mostrar el úndice"
::help::mc::All						"All" ;# NEW

::help::mc::FileNotFound			"No se encontró el archivo."
::help::mc::CantFindFile			"No se encuentrá el archivo en %s."
::help::mc::IncompleteHelpFiles	"Lo sentimos pero parece que los archivos de ayuda aún estan incompletos."
::help::mc::ProbablyTheHelp		"Probablemente la página de ayuda en un lenguaje diferente puede ser una alternativa para usted"
::help::mc::PageNotAvailable		"Esta página no se encuentra disponible"

### crosstable #########################################################
::crosstable::mc::TournamentTable			"Tabla del torneo"
::crosstable::mc::AverageRating				"Rating promedio"
::crosstable::mc::Category						"Categoría"
::crosstable::mc::Games							"partidas"
::crosstable::mc::Game							"partida"

::crosstable::mc::ScoringSystem				"Sistema de Punteo"
::crosstable::mc::Tiebreak						"Desempate"
::crosstable::mc::Settings						"Configuraciones"
::crosstable::mc::RevertToStart				"Volver a los valores iniciales"
::crosstable::mc::UpdateDisplay				"Actualizar el visor"
::crosstable::mc::SaveAsHTML					"Save as HTML file" ;# NEW

::crosstable::mc::Traditional					"Tradicional"
::crosstable::mc::Bilbao						"Bilbao"

::crosstable::mc::None							"Ninguno"
::crosstable::mc::Buchholz						"Buchholz"
::crosstable::mc::MedianBuchholz				"Buchholz-Mediano"
::crosstable::mc::ModifiedMedianBuchholz	"Buchholz-Mediano Mod."
::crosstable::mc::RefinedBuchholz			"Buchholz perfeccionado"
::crosstable::mc::SonnebornBerger			"Sonneborn-Berger"
::crosstable::mc::Progressive					"Puntajes progresivos"
::crosstable::mc::KoyaSystem					"Sistema Koya"
::crosstable::mc::GamesWon						"Número de partidas ganadas"
::crosstable::mc::GamesWonWithBlack			"Partidas Ganadas con Negras"
::crosstable::mc::ParticularResult			"Resultado Particular"
::crosstable::mc::TraditionalScoring		"Punteo Tradicional"

::crosstable::mc::Crosstable					"Cuadro cruzado"
::crosstable::mc::Scheveningen				"Scheveningen"
::crosstable::mc::Swiss							"Sistema suizo"
::crosstable::mc::Match							"Match"
::crosstable::mc::Knockout						"Knockout"
::crosstable::mc::RankingList					"Lista de Ranking"

::crosstable::mc::Order							"Orden"
::crosstable::mc::Type							"Tipo tabla"
::crosstable::mc::Score							"Puntuación"
::crosstable::mc::Alphabetical				"Alfabético"
::crosstable::mc::Rating						"Rating"
::crosstable::mc::Federation					"Federación"

::crosstable::mc::Debugging					"Depuración"
::crosstable::mc::Display						"Visor"
::crosstable::mc::Style							"Estilo"
::crosstable::mc::Spacing						"Espaciado"
::crosstable::mc::Padding						"Relleno"
::crosstable::mc::ShowLog						"Mostrar bitácora"
::crosstable::mc::ShowHtml						"Mostrar HTML"
::crosstable::mc::ShowRating					"Rating"
::crosstable::mc::ShowPerformance			"Desempeño"
::crosstable::mc::ShowWinDrawLoss			"Ganadas/Tablas/Perdidas"
::crosstable::mc::ShowTiebreak				"Desempate"
::crosstable::mc::ShowOpponent				"Oponente (como Tooltip)"
::crosstable::mc::KnockoutStyle				"Estilo tabla de Knockout"
::crosstable::mc::Pyramid						"Pirámide"
::crosstable::mc::Triangle						"Triángulo"

::crosstable::mc::CrosstableLimit			"Se excederá el límite del cuadro cruzado de %d jugadores."
::crosstable::mc::CrosstableLimitDetail	"'%s' está seleccionando otro modo de tabla."
::crosstable::mc::CannotOverwriteFile		"Cannot overwrite file '%s': permission denied." ;# NEW
::crosstable::mc::CannotCreateFile			"Cannot create file '%s': permission denied." ;# NEW

### info ###############################################################
::info::mc::InfoTitle			"Acerca de %s"
::info::mc::Info					"Información"
::info::mc::About					"Acerca de"
::info::mc::Contributions		"Contribuciones"
::info::mc::License				"Licencia"
::info::mc::Localization		"Localización"
::info::mc::Testing				"Pruebas"
::info::mc::References			"Referencias"
::info::mc::System				"Sistema"
::info::mc::FontDesign			"Diseño de fuentes"
::info::mc::ChessPieceDesign	"Diseño de las piezas"
::info::mc::BoardThemeDesign	"Diseño de tema de tablero"
::info::mc::FlagsDesign			"Diseño de las banderas en miniatura"
::info::mc::IconDesign			"Diseño de iconos"
::info::mc::Development			"Desarrollo"
::info::mc::Programming			"Programación"
::info::mc::Head					"Líder"

::info::mc::Version				"Versión"
::info::mc::Distributed			"Este programa se distribuye bajo los términos de la Licencia Pública General GNU."
::info::mc::Inspired				"Scidb está inspirado en Scid 3.6.1, registrado en \u00A9 1999-2003 por Shane Hudson."
::info::mc::SpecialThanks		"Un especial agradecimiento a %s por su estupendo trabajo. Su empeño constituye la base de esta aplicación."

### comment ############################################################
::comment::mc::CommentBeforeMove		"Comentario antes de la jugada"
::comment::mc::CommentAfterMove		"Comentario tras la jugada"
::comment::mc::PrecedingComment		"Comentario precedente"
::comment::mc::TrailingComment		"Último comentario"
::comment::mc::Language					"Idioma"
::comment::mc::AddLanguage				"Agregar idioma..."
::comment::mc::SwitchLanguage			"Cambiar idioma"
::comment::mc::FormatText				"Dar formato al texto"
::comment::mc::CopyText					"Copiar texto a"
::comment::mc::OverwriteContent		"¿Sobrescribir contenido existente?"
::comment::mc::AppendContent			"Si \"no\" el texto se agregará al final."
# Note for translators: "Emoticons" can be simply translated to "Smiley
::comment::mc::DisplayEmoticons		"Display Emoticons" ;# NEW

::comment::mc::LanguageSelection		"Selección de idioma"
::comment::mc::Formatting				"Formateando"

::comment::mc::Bold						"Negrita"
::comment::mc::Italic					"Itálica"
::comment::mc::Underline				"Subrayado"

::comment::mc::InsertSymbol			"&Insertar símbolo..."
# Note for translators: "Emoticon" can be simply translated to "Smiley"
::comment::mc::InsertEmoticon			"Insert &Emoticon..." ;# NEW
::comment::mc::MiscellaneousSymbols	"Simbolos misceláneos"
::comment::mc::Figurine					"Piezas"

### annotation #########################################################
::annotation::mc::AnnotationEditor					"Notas"
::annotation::mc::TooManyNags							"Demasiados comentarios (el último será ignorado)."
::annotation::mc::TooManyNagsDetail					"Se permite un máximo de %d comentarios por jugada individual."

::annotation::mc::PrefixedCommentaries				"Comentarios prefijados"
::annotation::mc::MoveAssesments						"Evaluaciones de jugadas"
::annotation::mc::PositionalAssessments			"Evaluaciones posicionales"
::annotation::mc::TimePressureCommentaries		"Comentarios sobre apuros de tiempo"
::annotation::mc::AdditionalCommentaries			"Comentarios adicionales"
::annotation::mc::ChessBaseCommentaries			"Comentarios de ChessBase"

### marks ##############################################################
::marks::mc::MarksPalette			"Paleta de marcadores"

### move ###############################################################
::move::mc::Action(replace)		"Reemplazar jugada"
::move::mc::Action(variation)		"Agregar nueva variante"
::move::mc::Action(mainline)		"Nueva línea principal"
::move::mc::Action(trial)			"Probar variante"
::move::mc::Action(exchange)		"Cambiar jugada"
::move::mc::Action(append)			"Añadir movimiento"
::move::mc::Action(load)			"Cargar el primer juego con este movimiento"

::move::mc::GameWillBeTruncated	"Se truncará la partida. ¿Continuar con '%s'?"

### log ################################################################
::log::mc::LogTitle		"Bitácora"
::log::mc::Warning		"Advertencia"
::log::mc::Error			"Error"
::log::mc::Information	"Información"

### titlebox ############################################################
::titlebox::mc::None				"No title" ;# NEW
::titlebox::mc::Title(GM)		"Gran Maestro (FIDE)"
::titlebox::mc::Title(IM)		"Maestro Internacional (FIDE)"
::titlebox::mc::Title(FM)		"Maestro Fide (FIDE)"
::titlebox::mc::Title(CM)		"Candidato a Maestro (FIDE)"
::titlebox::mc::Title(WGM)		"Gran Maestro Femenino (FIDE)"
::titlebox::mc::Title(WIM)		"Maestro Internacional Femenino (FIDE)"
::titlebox::mc::Title(WFM)		"Maestro Fide Femenino (FIDE)"
::titlebox::mc::Title(WCM)		"Candidato a Maestro Femenino (FIDE)"
::titlebox::mc::Title(HGM)		"Gran Maestro Honorario (FIDE)"
::titlebox::mc::Title(NM)		"Maestro Nacional (USCF)"
::titlebox::mc::Title(SM)		"Maestro Senior (USCF)"
::titlebox::mc::Title(LM)		"Maestro de por Vida (USCF)"
::titlebox::mc::Title(CGM)		"Gran Maestro por Correspondencia (ICCF)"
::titlebox::mc::Title(CIM)		"Maestro Internacional por Correspondencia (ICCF)"
::titlebox::mc::Title(CLGM)	"Gran Maestro Femenino por Correspondencia (ICCF)"
::titlebox::mc::Title(CILM)	"Maestro Internacional Femenino por Correspondencia (ICCF)"
::titlebox::mc::Title(CSIM)	"Maestro Internacional Senior por Correspondencia (ICCF)"

### messagebox #########################################################
::dialog::mc::Ok				"&Aceptar"
::dialog::mc::Cancel			"&Cancelar"
::dialog::mc::Yes				"&Sí"
::dialog::mc::No				"&No"
::dialog::mc::Retry			"&Reintentar"
::dialog::mc::Abort			"A&bortar"
::dialog::mc::Ignore			"&Ignorar"
::dialog::mc::Continue		"Con&tinuar"

::dialog::mc::Error			"Error"
::dialog::mc::Warning		"Advertencia"
::dialog::mc::Information	"Información"
::dialog::mc::Question		"Confirmar"

::dialog::mc::DontAskAgain	"No pregunte nuevamente"

### web ################################################################
::web::mc::CannotFindBrowser			"No se pudo encontrar un navegador."
::web::mc::CannotFindBrowserDetail	"Configure la variable de entorno BROWSER a su navegador deseado."

### colormenu ##########################################################
::colormenu::mc::BaseColor			"Color base"
::colormenu::mc::UserColor			"Color del usuario"
::colormenu::mc::UsedColor			"Color utilizado"
::colormenu::mc::RecentColor		"Color reciente"
::colormenu::mc::Texture			"Textura"
::colormenu::mc::OpenColorDialog	"Abrir el diálogo de colores"
::colormenu::mc::EraseColor		"Borrar color"
::colormenu::mc::Close				"Cerrar"

### table ##############################################################
::table::mc::Ok							"&Aceptar"
::table::mc::Cancel						"&Cancelar"
::table::mc::Column						"Columna"
::table::mc::Table						"Tabla"
::table::mc::Configure					"Configurar"
::table::mc::Hide							"Ocultar"
::table::mc::ShowColumn					"Mostrar columna"
::table::mc::Foreground					"Primer plano"
::table::mc::Background					"Segundo plano"
::table::mc::DisabledForeground		"Eliminar primer plano"
::table::mc::SelectionForeground		"Elegir primer plano"
::table::mc::SelectionBackground		"Elegir segundo plano"
::table::mc::HighlightColor			"Resaltar segundo plano"
::table::mc::Stripes						"Listas"
::table::mc::MinWidth					"Ancho mínimo"
::table::mc::MaxWidth					"Ancho máximo"
::table::mc::Separator					"Separador"
::table::mc::AutoStretchColumn		"Auto estirar columna"
::table::mc::FillColumn					"- Llenar columna -"
::table::mc::Preview						"Vista previa"
::table::mc::OptimizeColumn			"Optimizar el ancho de la columna"
::table::mc::OptimizeColumns			"Optimizar todas las columnas"
::table::mc::FitColumnWidth			"Ajustar el ancho de columna"
::table::mc::FitColumns					"Ajustar todas las columnas"
::table::mc::ExpandColumn				"Expandir el ancho de columna"
::table::mc::SqueezeColumns			"Comprimir todas las columnas"
::table::mc::AccelFitColumns			"Ctrl+,"
::table::mc::AccelOptimizeColumns	"Ctrl+."
::table::mc::AccelSqueezeColumns		"Ctrl+#"

### fileselectionbox ###################################################
::dialog::fsbox::mc::ScidbDatabase			"Base de datos Scidb"
::dialog::fsbox::mc::ScidDatabase			"Base de datos Scid"
::dialog::fsbox::mc::ChessBaseDatabase		"Base de datos ChessBase" 
::dialog::fsbox::mc::PortableGameFile		"Archivo PGN"
::dialog::fsbox::mc::BughousePortableGameFile "Archivo BPGN"
::dialog::fsbox::mc::ZipArchive				"Archivo ZIP" 
::dialog::fsbox::mc::ScidbArchive			"Archivo Scidb" 
::dialog::fsbox::mc::PortableDocumentFile	"Archivo PDF" 
::dialog::fsbox::mc::HypertextFile			"Archivo HTML"
::dialog::fsbox::mc::TypesettingFile		"Archivo LATEX"
::dialog::fsbox::mc::ImageFile				"Archivo de Imagen"
::dialog::fsbox::mc::TextFile					"Archivo de Texto"
::dialog::fsbox::mc::BinaryFile				"Archivo Binario"
::dialog::fsbox::mc::ShellScript				"Script"
::dialog::fsbox::mc::Executable				"Ejecutable"

::dialog::fsbox::mc::LinkTo					"Vúnculo a %s" 
::dialog::fsbox::mc::LinkTarget				"Destino del vúnculo" 
::dialog::fsbox::mc::Directory				"Directorio" 

::dialog::fsbox::mc::Title(open)				"Select File"
::dialog::fsbox::mc::Title(save)				"Save File"
::dialog::fsbox::mc::Title(dir)				"Choose Directory"

::dialog::fsbox::mc::Content					"Contenido" 
::dialog::fsbox::mc::Open						"Abrir" 

::dialog::fsbox::mc::FileType(exe)			"Ejecutables"
::dialog::fsbox::mc::FileType(txt)			"Archivos de Texto"
::dialog::fsbox::mc::FileType(bin)			"Archivos Binarios"
::dialog::fsbox::mc::FileType(log)			"Archivos de Registro"
::dialog::fsbox::mc::FileType(html)			"HTML files" ;# NEW

### choosecolor ########################################################
::dialog::choosecolor::mc::Ok					"&Aceptar"
::dialog::choosecolor::mc::Cancel			"&Cancelar"

::dialog::choosecolor::mc::BaseColors		"Colores base"
::dialog::choosecolor::mc::UserColors		"Colores del usuario"
::dialog::choosecolor::mc::RecentColors	"Colores recientes"
::dialog::choosecolor::mc::Old				"Antiguo"
::dialog::choosecolor::mc::Current			"Actual"
::dialog::choosecolor::mc::HexCode			"Hexadecimal"
::dialog::choosecolor::mc::ColorSelection	"Elección del color"
::dialog::choosecolor::mc::Red				"Rojo"
::dialog::choosecolor::mc::Green				"Verde"
::dialog::choosecolor::mc::Blue				"Azul"
::dialog::choosecolor::mc::Hue				"Tono"
::dialog::choosecolor::mc::Saturation		"Saturación"
::dialog::choosecolor::mc::Value				"Valor"
::dialog::choosecolor::mc::Enter				"Ingresar"
::dialog::choosecolor::mc::AddColor			"Agregar el color actual a los colores de usuario"

### choosefont #########################################################
::dialog::choosefont::mc::Apply				"&Aplicar"
::dialog::choosefont::mc::Cancel				"&Cancelar"
::dialog::choosefont::mc::Continue			"Con&tinuar"
::dialog::choosefont::mc::FixedOnly			"Sólo fuentes m&onoespaciadas/fijas"
::dialog::choosefont::mc::Family				"Fam&ilia"
::dialog::choosefont::mc::Font				"&Fuente"
::dialog::choosefont::mc::Ok					"Ac&eptar"
::dialog::choosefont::mc::Reset				"&Reajustar"
::dialog::choosefont::mc::Size				"&Tamaño"
::dialog::choosefont::mc::Strikeout			"Tach&ado"
::dialog::choosefont::mc::Style				"Es&tilo"
::dialog::choosefont::mc::Underline			"S&ubrayado"
::dialog::choosefont::mc::Color				"Color"

::dialog::choosefont::mc::Regular			"Regular" 
::dialog::choosefont::mc::Bold				"Negrita" 
::dialog::choosefont::mc::Italic				"Italica" 
{::dialog::choosefont::mc::Bold Italic}	"Negrita Italica" 

::dialog::choosefont::mc::Effects			"Efectos"
::dialog::choosefont::mc::Filter				"Filtro"
::dialog::choosefont::mc::Sample				"Muestra"
::dialog::choosefont::mc::SearchTitle		"Buscando fuentes monoespaciadas/fijas"
::dialog::choosefont::mc::SeveralMinutes	"Esta operación puede tomar cerca de %d minuto(s)."
::dialog::choosefont::mc::FontSelection	"Selección de fuente"
::dialog::choosefont::mc::Wait				"Espere"

### choosedir ##########################################################
::choosedir::mc::ShowPredecessor	"Mostrar Predecesor"
::choosedir::mc::ShowTail			"Mostrar Atrasados"
::choosedir::mc::Folder				"Carpeta"

### fsbox ##############################################################
::fsbox::mc::Name								"Nombre"
::fsbox::mc::Size								"Tamaño"
::fsbox::mc::Modified						"Modificado"

::fsbox::mc::Forward							"Continuar a '%s'"
::fsbox::mc::Backward						"Retroceder a '%s'"
::fsbox::mc::Delete							"Eliminar"
::fsbox::mc::MoveToTrash					"Mover a la Papelera"
::fsbox::mc::Restore							"Restaurar"
::fsbox::mc::Duplicate						"Duplicar"
::fsbox::mc::CopyOf							"Copia de %s"
::fsbox::mc::NewFolder						"Nueva Carpeta"
::fsbox::mc::Layout							"Disposición"
::fsbox::mc::ListLayout						"Formato de Lista"
::fsbox::mc::DetailedLayout				"Formato Detallado"
::fsbox::mc::ShowHiddenDirs				"&Mostrar directorios ocultos"
::fsbox::mc::ShowHiddenFiles				"&Mostrar archivos y directorios ocultos"
::fsbox::mc::AppendToExisitingFile		"&Agregar partidas a un archivo existente"
::fsbox::mc::Cancel							"&Cancelar"
::fsbox::mc::Save								"&Guardar"
::fsbox::mc::Open								"&Abrir"
::fsbox::mc::Overwrite						"S&obreescribir"
::fsbox::mc::Rename							"&Renombrar"
::fsbox::mc::Move								"Mover"

::fsbox::mc::AddBookmark					"Agregar Marcador '%s'"
::fsbox::mc::RemoveBookmark				"Quitar Marcador '%s'"
::fsbox::mc::RenameBookmark				"Renombrar Marcador '%s'"

::fsbox::mc::Filename						"&Nombre del archivo:"
::fsbox::mc::Filenames						"&Nombres del archivo:"
::fsbox::mc::Directory						"&Directorio:"
::fsbox::mc::FilesType						"&Tipo de archivos:"
::fsbox::mc::FileEncoding					"Codificación de archivo:"

::fsbox::mc::Favorites						"Favoritoes"
::fsbox::mc::LastVisited					"Visitado por última vez"
::fsbox::mc::FileSystem						"Sistema de archivos"
::fsbox::mc::Desktop							"Escritorio"
::fsbox::mc::Trash							"Papelera"
::fsbox::mc::Home								"Inicio"

::fsbox::mc::SelectEncoding				"Seleccionar la codificación de la base de datos (abre un cuadro de dialogo)"
::fsbox::mc::SelectWhichType				"Elegir qué tipo de archivo mostrar"
::fsbox::mc::TimeFormat						"%d/%m/%y %I:%M %p"

::fsbox::mc::CannotChangeDir				"No se puede cambiar al directorio '%s'.\nPermiso denegado."
::fsbox::mc::DirectoryRemoved				"No se puede cambiar al directorio '%s'.\nEl directorio fue eliminado."
::fsbox::mc::DeleteFailed					"No se pudo borrar '%s'."
::fsbox::mc::RestoreFailed					"No se pudo restaurar '%s'."
::fsbox::mc::CommandFailed					"Falló el comando '%s'."
::fsbox::mc::CopyFailed						"No se pudo copiar el archivo '%s': permiso denegado."
::fsbox::mc::CannotCopy						"No se puede crear una copia porque el archivo '%s' ya existe."
::fsbox::mc::CannotDuplicate				"No se puede duplicar el archivo '%s': no se tiene permisos de lectura."
::fsbox::mc::ReallyDuplicateFile			"¿Realmente desea duplicar este archivo?"
::fsbox::mc::ReallyDuplicateDetail		"Este archivo tiene aproximadamente %s. Duplicarlo puede tardar algún tiempo."
::fsbox::mc::InvalidFileExt				"Operación falló: '%s' tiene una extensión inválida."
::fsbox::mc::CannotRename					"No se puede cambiar el nombre a '%s' porque la carpeta/archivo ya existe."
::fsbox::mc::CannotCreate					"No se puede crear la carpeta '%s' porque ya existe."
::fsbox::mc::ErrorCreate					"Error creando la carpeta: permiso denegado."
::fsbox::mc::FilenameNotAllowed			"El nombre de archivo '%s' no se permite."
::fsbox::mc::ContainsTwoDots				"Contiene dos puntos consecutivos."
::fsbox::mc::ContainsReservedChars		"Contiene caracteres reservados: %s, o un caracter de control (ASCII 0-31)."
::fsbox::mc::InvalidFileName				"El nombre de archivo no puede comenzar con un guión, y no puede terminar con un espacio o punto."
::fsbox::mc::IsReservedName				"En algunos sistemas operativos este es un nombre reservado."
::fsbox::mc::FilenameTooLong				"Un nombre de archivo debe tener menos de 256 caracteres."
::fsbox::mc::InvalidFileExtension		"Extensión de archivo inválida en '%s'."
::fsbox::mc::MissingFileExtension		"El archivo '%s' no tiene extensión."
::fsbox::mc::FileAlreadyExists			"El archivo '%s' ya existe.\n\n¿Quiere sobreescribirlo?"
::fsbox::mc::CannotOverwriteDirectory	"No se puede sobrescribir el directorio '%s'."
::fsbox::mc::FileDoesNotExist				"El archivo '%s' no existe."
::fsbox::mc::DirectoryDoesNotExist		"El directorio '%s' no existe."
::fsbox::mc::CannotOpenOrCreate			"No se puede abrir/crear '%s'. Por favor escoja un directorio."
::fsbox::mc::WaitWhileDuplicating		"Por favor espere mientras se duplica el archivo..."
::fsbox::mc::FileHasDisappeared			"El archivo '%s' ha desaparecido."
::fsbox::mc::CurrentlyInUse				"El archivo se encuentra en uso."
::fsbox::mc::PermissionDenied				"Permiso denegado para el directorio '%s'."
::fsbox::mc::CannotOpenUri					"No se puede abrir la siguiente URI:"
::fsbox::mc::InvalidUri						"Descartar contenido no es una lista URI válida."
::fsbox::mc::UriRejected					"Los siguientes archivos fueron rechazados:"
::fsbox::mc::UriRejectedDetail			"Sólo pueden manejarse los tipos de archivo listados."
::fsbox::mc::CannotOpenTrashFiles		"No pueden abrirse archivos de la papelera:"
::fsbox::mc::CannotOpenRemoteFiles		"No pueden abrirse archivos remotos:"
::fsbox::mc::OperationAborted				"Operación abortada."
::fsbox::mc::ApplyOnDirectories			"¿Está seguro que desea aplicar la operación seleccionada sobre los (siguientes) directorios?"
::fsbox::mc::EntryAlreadyExists			"La entrada ya existe"
::fsbox::mc::AnEntryAlreadyExists		"Una entrada '%s' ya existe."
::fsbox::mc::SourceDirectoryIs			"El directorio raíz es '%s'."
::fsbox::mc::NewName							"Nuevo nombre"

::fsbox::mc::ReallyMove(file,w)			"¿Realmente desea mover el archivo '%s' a la papelera?"
::fsbox::mc::ReallyMove(file,r)			"¿Realmente desea mover el archivo de solo lectura '%s' a la papelera?"
::fsbox::mc::ReallyMove(folder,w)		"¿Realmente desea mover la carpeta '%s' a la papelera?"
::fsbox::mc::ReallyMove(folder,r)		"¿Realmente desea mover la carpeta de solo lectura '%s' a la papelera?"
::fsbox::mc::ReallyDelete(file,w)		"¿Realmente desea borrar el archivo '%s'? Esta operación no puede revertirse."
::fsbox::mc::ReallyDelete(file,r)		"¿Realmente desea borrar el archivo de solo lectura '%s'? Esta operación no puede revertirse."
::fsbox::mc::ReallyDelete(link,w)		"¿Realmente desea borrar el vúnculo a '%s'?"
::fsbox::mc::ReallyDelete(link,r)		"¿Realmente desea borrar el vúnculo a '%s'?"
::fsbox::mc::ReallyDelete(folder,w)		"¿Realmente desea borrar la carpeta '%s'? Esta operación no puede revertirse."
::fsbox::mc::ReallyDelete(folder,r)		"¿Realmente desea borrar la carpeta de solo lectura '%s'? Esta operación no puede revertirse."

::fsbox::mc::ErrorRenaming(folder)		"No se puede cambiar el nombre de la carpeta '%old' a '%new': permiso denegado."
::fsbox::mc::ErrorRenaming(file)			"Error cambiando de nombre el archivo '%old' a '%new': permiso denegado."

::fsbox::mc::Cannot(delete)				"No se puede borrar el archivo '%s'."
::fsbox::mc::Cannot(rename)				"No se puede renombrar el archivo '%s'."
::fsbox::mc::Cannot(move)					"No se puede mover el archivo '%s'."
::fsbox::mc::Cannot(overwrite)			"No se puede sobrescribir el archivo '%s'." 

::fsbox::mc::DropAction(move)				"Mover aquí"
::fsbox::mc::DropAction(copy)				"Copiar aquí"
::fsbox::mc::DropAction(link)				"Enlazar aquí"

### toolbar ############################################################
::toolbar::mc::Toolbar		"Barra de herramientas"
::toolbar::mc::Orientation	"Orientación"
::toolbar::mc::Alignment	"Alineación"
::toolbar::mc::IconSize		"Tamaño de íconos"

::toolbar::mc::Default		"Predeterminado"
::toolbar::mc::Small			"Pequeño"
::toolbar::mc::Medium		"Medio"
::toolbar::mc::Large			"Grande"

::toolbar::mc::Top			"Arriba"
::toolbar::mc::Bottom		"Abajo"
::toolbar::mc::Left			"Izquierda"
::toolbar::mc::Right			"Derecha"
::toolbar::mc::Center		"Centro"

::toolbar::mc::Flat			"Plano"
::toolbar::mc::Floating		"Flotante"
::toolbar::mc::Hide			"Oculto"

::toolbar::mc::Expand		"Expandir"

### Countries ##########################################################
::country::mc::Afghanistan											"Afganistán"
::country::mc::Netherlands_Antilles								"Antillas Holandesas"
::country::mc::Anguilla												"Anguila"
::country::mc::Aboard_Aircraft									"A bordo de un avión"
::country::mc::Aaland_Islands										"Islas Aaland"
::country::mc::Albania												"Albania"
::country::mc::Algeria												"Argelia"
::country::mc::Andorra												"Andorra"
::country::mc::Angola												"Angola"
::country::mc::Antigua												"Antigua y Barbuda"
::country::mc::Australasia											"Australasia"
::country::mc::Argentina											"Argentina"
::country::mc::Armenia												"Armenia"
::country::mc::Aruba													"Aruba"
::country::mc::American_Samoa										"Samoa americana"
::country::mc::Antarctica											"Antártida"
::country::mc::French_Southern_Territories					"Territorios franceses del sur"
::country::mc::Australia											"Australia"
::country::mc::Austria												"Austria"
::country::mc::Azerbaijan											"Azerbaijan"
::country::mc::Bahamas												"Bahamas"
::country::mc::Bangladesh											"Bangladesh"
::country::mc::Barbados												"Barbados"
::country::mc::Basque												"Vascongada"
::country::mc::Burundi												"Burundi"
::country::mc::Belgium												"Bélgica"
::country::mc::Benin													"Benin"
::country::mc::Bermuda												"Bermuda"
::country::mc::Bhutan												"Bhutan"
::country::mc::Bosnia_and_Herzegovina							"Bosnia y Herzegovina"
::country::mc::Belize												"Belice"
::country::mc::Belarus												"Bielorrusia"
::country::mc::Bolivia												"Bolivia"
::country::mc::Brazil												"Brasil"
::country::mc::Bahrain												"Bahrein"
::country::mc::Brunei												"Brunei"
::country::mc::Botswana												"Botswana"
::country::mc::Bulgaria												"Bulgaria"
::country::mc::Burkina_Faso										"Burkina Faso"
::country::mc::Bouvet_Islands										"Islas Bouvet"
::country::mc::Central_African_Republic						"República Centroafricana"
::country::mc::Cambodia												"Camboya"
::country::mc::Canada												"Canadá"
::country::mc::Catalonia											"Cataluña"
::country::mc::Cayman_Islands										"Islas Caimán"
::country::mc::Cocos_Islands										"Islas Cocos"
::country::mc::Congo													"Congo (Brazzaville)"
::country::mc::Chad													"Chad"
::country::mc::Chile													"Chile"
::country::mc::China													"China"
::country::mc::Ivory_Coast											"Costa de Marfil"
::country::mc::Cameroon												"Camerún"
::country::mc::DR_Congo												"RD del Congo"
::country::mc::Cook_Islands										"Islas Cook"
::country::mc::Colombia												"Colombia"
::country::mc::Comoros												"Comoras"
::country::mc::Cape_Verde											"Cabo Verde"
::country::mc::Costa_Rica											"Costa Rica"
::country::mc::Croatia												"Croacia"
::country::mc::Cuba													"Cuba"
::country::mc::Christmas_Island									"Islas Christmas"
::country::mc::Cyprus												"Chipre"
::country::mc::Czech_Republic										"República Checa"
::country::mc::Denmark												"Dinamarca"
::country::mc::Djibouti												"Djibouti"
::country::mc::Dominica												"Dominica"
::country::mc::Dominican_Republic								"República Dominicana"
::country::mc::Ecuador												"Ecuador"
::country::mc::Egypt													"Egipto"
::country::mc::England												"Inglaterra"
::country::mc::Eritrea												"Etiopía"
::country::mc::El_Salvador											"El Salvador"
::country::mc::Western_Sahara										"Sahara Occidental"
::country::mc::Spain													"España"
::country::mc::Estonia												"Estonia"
::country::mc::Ethiopia												"Etiopía"
::country::mc::Faroe_Islands										"Islas Faroe"
::country::mc::Fiji													"Fidji"
::country::mc::Finland												"Finlandia"
::country::mc::Falkland_Islands									"Islas Malvinas"
::country::mc::France												"Francia"
::country::mc::West_Germany										"Alemania Occidental"
::country::mc::Micronesia											"Micronesia"
::country::mc::Gabon													"Gabón"
::country::mc::Gambia												"Gambia"
::country::mc::Great_Britain										"Gran Bretaña"
::country::mc::Guinea_Bissau										"Guinea-Bissau"
::country::mc::Gibraltar											"Gibraltar"
::country::mc::Guernsey												"Guernsey"
::country::mc::East_Germany										"Alemania Oriental"
::country::mc::Georgia												"Georgia"
::country::mc::Equatorial_Guinea									"Guinea Ecuatorial"
::country::mc::Germany												"Alemania"
::country::mc::Ghana													"Ghana"
::country::mc::Guadeloupe											"Guadalupe"
::country::mc::Greece												"Grecia"
::country::mc::Grenada												"Grenada"
::country::mc::Greenland											"Groenlandia"
::country::mc::Guatemala											"Guatemala"
::country::mc::French_Guiana										"Guayana Francesa"
::country::mc::Guinea												"Guinea"
::country::mc::Guam													"Guam"
::country::mc::Guyana												"Guyana"
::country::mc::Haiti													"Haití"
::country::mc::Hong_Kong											"Hong Kong"
::country::mc::Heard_Island_and_McDonald_Islands			"Isla Heard e Islas McDonald"
::country::mc::Honduras												"Honduras"
::country::mc::Hungary												"Hungría"
::country::mc::Isle_of_Man											"Isla de Man"
::country::mc::Indonesia											"Indonesia"
::country::mc::India													"India"
::country::mc::British_Indian_Ocean_Territory				"Territorio Británico del Océano Índico"
::country::mc::Iran													"Irán"
::country::mc::Ireland												"Irlanda"
::country::mc::Iraq													"Irak"
::country::mc::Iceland												"Islandia"
::country::mc::Israel												"Israel"
::country::mc::Italy													"Italia"
::country::mc::British_Virgin_Islands							"Islas Vírgenes Británicas"
::country::mc::Jamaica												"Jamaica"
::country::mc::Jersey												"Jersey"
::country::mc::Jordan												"Jordania"
::country::mc::Japan													"Japón"
::country::mc::Kazakhstan											"Kazajstán"
::country::mc::Kenya													"Kenia"
::country::mc::Kosovo												"Kosovo"
::country::mc::Kyrgyzstan											"Kirguizistán"
::country::mc::Kiribati												"Kiribati"
::country::mc::South_Korea											"Corea del Sur"
::country::mc::Saudi_Arabia										"Arabia Saudita"
::country::mc::Kuwait												"Kuwait"
::country::mc::Laos													"Laos"
::country::mc::Latvia												"Letonia"
::country::mc::Libya													"Libia"
::country::mc::Liberia												"Liberia"
::country::mc::Saint_Lucia											"Santa Lucía"
::country::mc::Lesotho												"Lesotho"
::country::mc::Lebanon												"Líbano"
::country::mc::Liechtenstein										"Liechtenstein"
::country::mc::Lithuania											"Lituania"
::country::mc::Luxembourg											"Luxemburgo"
::country::mc::Macao													"Macao"
::country::mc::Madagascar											"Madagascar"
::country::mc::Morocco												"Marruecos"
::country::mc::Malaysia												"Malasia"
::country::mc::Malawi												"Malawi"
::country::mc::Moldova												"Moldova"
::country::mc::Maldives												"Maldivas"
::country::mc::Mexico												"Mexico"
::country::mc::Mongolia												"Mongolia"
::country::mc::Marshall_Islands									"Islas Marshall"
::country::mc::Macedonia											"Macedonia"
::country::mc::Mali													"Mali"
::country::mc::Malta													"Malta"
::country::mc::Montenegro											"Montenegro"
::country::mc::Northern_Mariana_Islands						"Islas Marianas Septentrionales"
::country::mc::Monaco												"Monaco"
::country::mc::Mozambique											"Mozambique"
::country::mc::Mauritius											"Mauricio"
::country::mc::Montserrat											"Montserrat"
::country::mc::Mauritania											"Mauritania"
::country::mc::Martinique											"Martinica"
::country::mc::Myanmar												"Myanmar"
::country::mc::Mayotte												"Mayotte"
::country::mc::Namibia												"Namibia"
::country::mc::Nicaragua											"Nicaragua"
::country::mc::New_Caledonia										"Nueva Caledonia"
::country::mc::Netherlands											"Países Bajos"
::country::mc::Nepal													"Nepal"
::country::mc::The_Internet										"Internet"
::country::mc::Norfolk_Island										"Isla Norfolk"
::country::mc::Nigeria												"Nigeria"
::country::mc::Niger													"Níger"
::country::mc::Northern_Ireland									"Irlanda del Norte"
::country::mc::Niue													"Niue"
::country::mc::Norway												"Noruega"
::country::mc::Nauru													"Nauru"
::country::mc::New_Zealand											"Nueva Zelanda"
::country::mc::Oman													"Omán"
::country::mc::Pakistan												"Pakistán"
::country::mc::Panama												"Panamá"
::country::mc::Paraguay												"Paraguay"
::country::mc::Pitcairn_Islands									"Islas Pitcairn"
::country::mc::Peru													"Perú"
::country::mc::Philippines											"Filipinas"
::country::mc::Palestine											"Palestina"
::country::mc::Palau													"Palau"
::country::mc::Papua_New_Guinea									"Papua Nueva Guinea"
::country::mc::Poland												"Polonia"
::country::mc::Portugal												"Portugal"
::country::mc::North_Korea											"Corea del Norte"
::country::mc::Puerto_Rico											"Puerto Rico"
::country::mc::French_Polynesia									"Polinesia Francesa"
::country::mc::Qatar													"Qatar"
::country::mc::Reunion												"Reunión"
::country::mc::Romania												"Rumania"
::country::mc::South_Africa										"Sudáfrica"
::country::mc::Russia												"Rusia"
::country::mc::Rwanda												"Rwanda"
::country::mc::Samoa													"Samoa"
::country::mc::Serbia_and_Montenegro							"Serbia y Montenegro"
::country::mc::Scotland												"Escocia"
::country::mc::At_Sea												"En el mar"
::country::mc::Senegal												"Senegal"
::country::mc::Seychelles											"Seychelles"
::country::mc::South_Georgia_and_South_Sandwich_Islands	"Isla Georgia y Sandwich del Sur"
::country::mc::Saint_Helena										"Santa Helena"
::country::mc::Singapore											"Singapur"
::country::mc::Jan_Mayen_and_Svalbard							"Svalbard y Jan Mayen"
::country::mc::Saint_Kitts_and_Nevis							"Saint Kitts y Nevis"
::country::mc::Sierra_Leone										"Sierra Leona"
::country::mc::Slovenia												"Eslovenia"
::country::mc::San_Marino											"San Marino"
::country::mc::Solomon_Islands									"Islas Solomon"
::country::mc::Somalia												"Somalía"
::country::mc::Aboard_Spacecraft									"A bordo del transbordador espacial"
::country::mc::Saint_Pierre_and_Miquelon						"Saint Pierre y Miquelon"
::country::mc::Serbia												"Serbia"
::country::mc::Sri_Lanka											"Sri Lanka"
::country::mc::Sao_Tome_and_Principe							"Sao Tome y Príncipe"
::country::mc::Sudan													"Sudán"
::country::mc::Switzerland											"Suiza"
::country::mc::Suriname												"Surinam"
::country::mc::Slovakia												"Eslovaquia"
::country::mc::Sweden												"Suecia"
::country::mc::Swaziland											"Swazilandia"
::country::mc::Syria													"Siria"
::country::mc::Tanzania												"Tanzania"
::country::mc::Turks_and_Caicos_Islands						"Islas Turks y Caicos"
::country::mc::Czechoslovakia										"Checoslovaquia"
::country::mc::Tonga													"Tonga"
::country::mc::Thailand												"Tailandia"
::country::mc::Tibet													"Tíbet"
::country::mc::Tajikistan											"Tajikistán"
::country::mc::Tokelau												"Tokelau"
::country::mc::Turkmenistan										"Turkmenistán"
::country::mc::Timor_Leste											"Timor Leste"
::country::mc::Togo													"Togo"
::country::mc::Chinese_Taipei										"Taiwán"
::country::mc::Trinidad_and_Tobago								"Trinidad y Tobago"
::country::mc::Tunisia												"Túnez"
::country::mc::Turkey												"Turquía"
::country::mc::Tuvalu												"Tuvalu"
::country::mc::United_Arab_Emirates								"Emiratos Árabes Unidos"
::country::mc::Uganda												"Uganda"
::country::mc::Ukraine												"Ucrania"
::country::mc::United_States_Minor_Outlying_Islands		"Islas Remotas Menores de los Estados Unidos"
::country::mc::Unknown												"(Desconocido)"
::country::mc::Soviet_Union										"Unión Soviética"
::country::mc::Uruguay												"Uruguay"
::country::mc::United_States_of_America						"Estados Unidos de América"
::country::mc::Uzbekistan											"Uzbekistán"
::country::mc::Vanuatu												"Vanuatu"
::country::mc::Vatican												"Vaticano"
::country::mc::Venezuela											"Venezuela"
::country::mc::Vietnam												"Vietnam"
::country::mc::Saint_Vincent_and_the_Grenadines				"Saint Vincent y las Granadinas"
::country::mc::US_Virgin_Islands									"Islas Vírgenes Norteamericanas"
::country::mc::Wallis_and_Futuna									"Wallis y Futuna"
::country::mc::Wales													"Gales"
::country::mc::Yemen													"Yemen"
::country::mc::Yugoslavia											"Yugoslavia"
::country::mc::Zambia												"Zambia"
::country::mc::Zanzibar												"Zanzíbar"
::country::mc::Zimbabwe												"Zimbabwe"
::country::mc::Mixed_Team											"Equipo mixto"

::country::mc::Africa_North										"Africa, Norte"
::country::mc::Africa_Sub_Saharan								"Africa, Sub-Sahariana"
::country::mc::America_Caribbean									"América, Caribe"
::country::mc::America_Central									"América Central"
::country::mc::America_North										"América, Norte"
::country::mc::America_South										"América, Sur"
::country::mc::Antarctic											"Antártida"
::country::mc::Asia_East											"Asia, Este"
::country::mc::Asia_South_South_East							"Asia, Sud-Sudeste"
::country::mc::Asia_West_Central									"Asia, Oeste-Central"
::country::mc::Europe												"Europa"
::country::mc::Europe_East											"Europa, Este"
::country::mc::Oceania												"Oceanía"
::country::mc::Stateless											"Sin estado"

### Languages ##########################################################
::encoding::mc::Lang(FI)	"Fide"
::encoding::mc::Lang(af)	"Afrikaans"
::encoding::mc::Lang(ar)	"Árabe"
::encoding::mc::Lang(ast)	"Leonese"
::encoding::mc::Lang(az)	"Azerbaijani"
::encoding::mc::Lang(bat)	"Báltico"
::encoding::mc::Lang(be)	"Bielorruso"
::encoding::mc::Lang(bg)	"Búlgaro"
::encoding::mc::Lang(br)	"Bretón"
::encoding::mc::Lang(bs)	"Bosnio"
::encoding::mc::Lang(ca)	"Catalán"
::encoding::mc::Lang(cs)	"Checo"
::encoding::mc::Lang(cy)	"Galés"
::encoding::mc::Lang(da)	"Danés"
::encoding::mc::Lang(de)	"Alemán"
::encoding::mc::Lang(de+)	"Alemán (reformado)"
::encoding::mc::Lang(el)	"Griego"
::encoding::mc::Lang(en)	"Inglés"
::encoding::mc::Lang(eo)	"Esperanto"
::encoding::mc::Lang(es)	"Español"
::encoding::mc::Lang(et)	"Estonio"
::encoding::mc::Lang(eu)	"Vasco"
::encoding::mc::Lang(fi)	"Finés"
::encoding::mc::Lang(fo)	"Faroés"
::encoding::mc::Lang(fr)	"Francés"
::encoding::mc::Lang(fy)	"Frisón"
::encoding::mc::Lang(ga)	"Irlandés"
::encoding::mc::Lang(gd)	"Escocés"
::encoding::mc::Lang(gl)	"Gallego"
::encoding::mc::Lang(he)	"Hebreo"
::encoding::mc::Lang(hi)	"Hindi"
::encoding::mc::Lang(hr)	"Croata"
::encoding::mc::Lang(hu)	"Húngaro"
::encoding::mc::Lang(hy)	"Armenio"
::encoding::mc::Lang(ia)	"Interlingua"
::encoding::mc::Lang(id)	"Indonesian" ;# NEW
::encoding::mc::Lang(is)	"Islandés"
::encoding::mc::Lang(it)	"Italiano"
::encoding::mc::Lang(iu)	"Inuktitut"
::encoding::mc::Lang(ja)	"Japonés"
::encoding::mc::Lang(ka)	"Georgiano"
::encoding::mc::Lang(kk)	"Kazakho"
::encoding::mc::Lang(kl)	"Groenlandés"
::encoding::mc::Lang(ko)	"Coreano"
::encoding::mc::Lang(ku)	"Kurdo"
::encoding::mc::Lang(ky)	"Kirghiz"
::encoding::mc::Lang(la)	"Latin"
::encoding::mc::Lang(lb)	"Luxemburgués"
::encoding::mc::Lang(lt)	"Lituano"
::encoding::mc::Lang(lv)	"Letón"
::encoding::mc::Lang(mk)	"Macedonio"
::encoding::mc::Lang(mo)	"Moldavo"
::encoding::mc::Lang(ms)	"Malayo"
::encoding::mc::Lang(mt)	"Maltés"
::encoding::mc::Lang(nl)	"Holandés"
::encoding::mc::Lang(no)	"Noruego"
::encoding::mc::Lang(oc)	"Occitano"
::encoding::mc::Lang(pl)	"Polaco"
::encoding::mc::Lang(pt)	"Portugués"
::encoding::mc::Lang(rm)	"Romaní"
::encoding::mc::Lang(ro)	"Rumano"
::encoding::mc::Lang(ru)	"Ruso"
::encoding::mc::Lang(se)	"Sami"
::encoding::mc::Lang(sk)	"Eslocavo"
::encoding::mc::Lang(sl)	"Esloveno"
::encoding::mc::Lang(sq)	"Albanés"
::encoding::mc::Lang(sr)	"Serbio"
::encoding::mc::Lang(sv)	"Sueco"
::encoding::mc::Lang(sw)	"Swahili"
::encoding::mc::Lang(tg)	"Tajik"
::encoding::mc::Lang(th)	"Thai"
::encoding::mc::Lang(tk)	"Turkmeno"
::encoding::mc::Lang(tl)	"Tagalog"
::encoding::mc::Lang(tr)	"Turco"
::encoding::mc::Lang(uk)	"Ucraniano"
::encoding::mc::Lang(uz)	"Uzbeko"
::encoding::mc::Lang(vi)	"Vietnamita"
::encoding::mc::Lang(wa)	"Walloon"
::encoding::mc::Lang(wen)	"Sorbio"
::encoding::mc::Lang(hsb)	"Alto Sorbio"
::encoding::mc::Lang(dsb)	"Bajo Sorbio"
::encoding::mc::Lang(zh)	"Chino"

::encoding::mc::Font(hi)	"Devanagari"

### Calendar ###########################################################
::calendar::mc::OneMonthForward	"Avanzar un mes (Shift \u2192)"
::calendar::mc::OneMonthBackward	"Retroceder un mes (Shift \u2190)"
::calendar::mc::OneYearForward	"Avanzar un año (Ctrl \u2192)"
::calendar::mc::OneYearBackward	"Retroceder un año (Ctrl \u2190)"

::calendar::mc::Su	"Do"
::calendar::mc::Mo	"Lu"
::calendar::mc::Tu	"Ma"
::calendar::mc::We	"Mi"
::calendar::mc::Th	"Ju"
::calendar::mc::Fr	"Vi"
::calendar::mc::Sa	"Sa"

::calendar::mc::Jan	"Ene"
::calendar::mc::Feb	"Feb"
::calendar::mc::Mar	"Mar"
::calendar::mc::Apr	"Abr"
::calendar::mc::May	"May"
::calendar::mc::Jun	"Jun"
::calendar::mc::Jul	"Jul"
::calendar::mc::Aug	"Ago"
::calendar::mc::Sep	"Sep"
::calendar::mc::Oct	"Oct"
::calendar::mc::Nov	"Nov"
::calendar::mc::Dec	"Dic"

::calendar::mc::MonthName(1)		"Enero"
::calendar::mc::MonthName(2)		"Febrero"
::calendar::mc::MonthName(3)		"Marzo"
::calendar::mc::MonthName(4)		"Abril"
::calendar::mc::MonthName(5)		"Mayo"
::calendar::mc::MonthName(6)		"Junio"
::calendar::mc::MonthName(7)		"Julio"
::calendar::mc::MonthName(8)		"Agosto"
::calendar::mc::MonthName(9)		"Septiembre"
::calendar::mc::MonthName(10)		"Octubre"
::calendar::mc::MonthName(11)		"Noviembre"
::calendar::mc::MonthName(12)		"Diciembre"

::calendar::mc::WeekdayName(0)	"Domingo"
::calendar::mc::WeekdayName(1)	"Lunes"
::calendar::mc::WeekdayName(2)	"Martes"
::calendar::mc::WeekdayName(3)	"Miércoles"
::calendar::mc::WeekdayName(4)	"Jueves"
::calendar::mc::WeekdayName(5)	"Viernes"
::calendar::mc::WeekdayName(6)	"Sábado"

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
::emoticons::mc::Tooltip(grumpy)		"Disappointed / Grumpy" ;# NEW
::emoticons::mc::Tooltip(upset)		"Upset" ;# NEW
::emoticons::mc::Tooltip(cry)			"Crying" ;# NEW
::emoticons::mc::Tooltip(yell)		"Yelling" ;# NEW
::emoticons::mc::Tooltip(surprise)	"Surprised" ;# NEW
::emoticons::mc::Tooltip(red)			"Ashamed" ;# NEW
::emoticons::mc::Tooltip(sleep)		"Sleepy" ;# NEW
::emoticons::mc::Tooltip(eek)			"Scared" ;# NEW
::emoticons::mc::Tooltip(kitty)		"Kitty" ;# NEW
::emoticons::mc::Tooltip(roll)		"Eye-rolling" ;# NEW
::emoticons::mc::Tooltip(blink)		"Blinking" ;# NEW
::emoticons::mc::Tooltip(glasses)	"Intelligent" ;# NEW

### remote #############################################################
::remote::mc::PostponedMessage "La apertura de la base \"%s\" se pospondrá hasta que concluya la operación en curso."

# vi:set ts=3 sw=3:
