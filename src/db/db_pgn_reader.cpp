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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_pgn_reader.h"
#include "db_consumer.h"
#include "db_player.h"
#include "db_site.h"
#include "db_mark_set.h"
#include "db_tag_set.h"
#include "db_date.h"
#include "db_comment.h"
#include "db_eco.h"

#include "u_progress.h"

#include "m_algorithm.h"
#include "m_istream.h"
#include "m_stdio.h"

#include "sys_utf8_codec.h"

#include <ctype.h>
#include <stdlib.h>
#include <math.h>

using namespace db;
using namespace db::tag;
using namespace util;

enum { None, Piece, Fyle, Rank, Capture };


#define _ None
#define P Piece
#define F Fyle
#define R Rank
#define C Capture
static char const CharToType[256] =
{
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
//     !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
	 _, _, _, _, _, _, _, _, _, _, _, _, _, C, _, _,
//  0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?
	 _, R, R, R, R, R, R, R, R, _, C, _, _, _, _, _,
//  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O
	 _, _, P, _, _, _, _, _, _, _, _, P, _, _, P, _,
//  P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  -
	 P, P, P, _, _, _, _, _, _, _, _, _, _, _, _, _,
//  '  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o
	 _, F, F, F, F, F, F, F, F, _, _, _, _, _, _, _,
//  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~ DEL
	 _, _, _, _, _, _, _, _, C, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	 _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
};
#undef _
#undef F
#undef P
#undef R
#undef C

static unsigned const MaxWarnings	= 40;
static unsigned const MaxErrors		= 40;


// IMPORTANT NOTE: keep the entries normalized!
static char const* Phrases200[] =
{
	/* 200 */ 0,
	/* 201 */ "<xml><:de>Eine Ungenauigkeit.</:de><:en>An inaccuracy.</:en><:es>Una inexactitud.</:es><:fr>Une imprecision.</:fr><:it>Poco precisa.</:it><:ru>Неточность.</:ru></xml>",
	/* 202 */ "<xml><:de>Ein Fehler.</:de><:en>An error.</:en>Error.<:es>Une erreur.</:es><:fr></:fr><:it>Un errore.</:it><:ru>Ошибка.</:ru></xml>",
	/* 203 */ "<xml><:de>Ein Patzer.</:de><:en>A blunder.</:en><:es>Grave error</:es><:fr>Une gaffe.</:fr><:it>Una svista.</:it><:ru>Грубая ошибка.</:ru></xml>",
	/* 204 */ "<xml><:de>Der zweite Fehler in Folge.</:de><:en>The second error in a row.</:en><:es>Segundo error consecutivo.</:es><:fr>Une 2eme erreur d'affile.</:fr><:it>Il secondo errore di fila.</:it><:ru>Вторая ошибка подряд.</:ru></xml>",
	/* 205 */ "<xml><:de>Nicht die beste Fortsetzung.</:de><:en>Not the best continuation.</:en><:es>No es la mejor jugada.</:es><:fr>Ce n'est pas la meilleure suite.</:fr><:it>Non è la continuazione migliore.</:it><:ru>Не лучшее продолжение.</:ru></xml>",
	/* 206 */ "<xml><:de>Weiß kann den gegnerischen Fehler nicht zu seinem Vorteil nutzen.</:de><:en>White fails to take advantage of the opponent's error.</:en>Las blancas no aprovecharon el error del rival.<:es>Las negras no aprovecharon el error del rival.</:es><:fr>Les blancs ratent l'occasion de tirer avantage de l'erreur adverse. Plus fort est.</:fr><:it>Il Bianco manca di sfruttare l'errore dell'avversario.</:it><:ru>Белые не воспользовались ошибкой соперника.</:ru></xml>",
	/* 207 */ "<xml><:de>Schwarz kann den gegnerischen Fehler nicht zu seinem Vorteil nutzen.</:de><:en>Black fails to take advantage of the opponent's error.</:en><:es>Las negras no aprovecharon el error del rival.</:es><:fr>Les noirs ratent l'occasion de tirer avantage de l'erreur adverse. Plus fort est.</:fr><:it>Il Nero manca di sfruttare l'errore dell'avversario.</:it><:ru>Черные не воспользовались ошибкой соперника.</:ru></xml>",
	/* 208 */ 0,
	/* 209 */ 0,
	/* 210 */ 0,
	/* 211 */ "<xml><:de>Stärker ist</:de><:en>Stronger is</:en><:es>Mas fuerte es</:es><:fr>Plus fort est</:fr><:it>Più forte è</:it><:ru>Сильнее было</:ru></xml>",
	/* 212 */ "<xml><:de>Vielversprechender ist</:de><:en>More promising is</:en><:es>Mas prometedor es</:es><:fr>Plus prometteur est</:fr><:it>Più promettente è</:it><:ru>Перспективнее</:ru></xml>",
	/* 213 */ "<xml><:de>Vorzuziehen ist</:de><:en>Preferable is</:en><:es>Preferible era</:es><:fr>Preferable est</:fr><:it>È preferibile</:it><:ru>Предпочтительнее было</:ru></xml>",
	/* 214 */ "<xml><:de>Beachtung verdient</:de><:en>Worth attention is</:en><:es>Interesante era</:es><:fr>Merite attention</:fr><:it>Merita attenzione</:it><:ru>Заслуживало внимания</:ru></xml>",
	/* 215 */ "<xml><:de>Eine interessante Alternative ist</:de><:en>An interesting alternative is</:en><:es>La alternativa interesante era</:es><:fr>Une alternative interessante est</:fr><:it>Un'alternativa interessante è</:it><:ru>Интересной альтернативой было</:ru></xml>",
	/* 216 */ "<xml><:de>Besser ist</:de><:en>Better is</:en><:es>Mejor era</:es><:fr>Meilleur est</:fr><:it>Migliore</:it><:ru>Лучше</:ru></xml>",
	/* 217 */ "<xml><:de>Noch eigensinniger ist</:de><:en>More stubborn is</:en><:es>Mas resistente era</:es><:fr>Plus subtil est</:fr><:it>Più coriacea è</:it><:ru>Упорнее было</:ru></xml>",
	/* 218 */ 0,
	/* 219 */ 0,
	/* 220 */ 0,
	/* 221 */ "<xml><:de>bewahrt eine Vorteil.</:de><:en>retains an advantage.</:en><:es>Mantenia ventaja.</:es><:fr>conserve l'avantage.</:fr><:it>mantiene il vantaggio.</:it><:ru>сохраняло перевес.</:ru></xml>",
	/* 222 */ "<xml><:de>bewahrt eine ungefähre Ausgeglichenheit.</:de><:en>retains an approximate equality.</:en><:es>Mantenia aproximado equilibrio.</:es><:fr>conduit a une egalite approximative.</:fr><:it>mantiene una sostanziale parità.</:it><:ru>сохраняло примерное равновесие.</:ru></xml>",
	/* 223 */ "<xml><:de>gibt eine Möglichkeit um die Partie zu retten.</:de><:en>gives a chance to save the game.</:en><:es>dà la possibilità di salvare il gioco.</:es><:fr>donne une chance de sauver le jeu.</:fr><:it>da speranze per salvare la partita.</:it><:ru>оставляло шансы на спасение.</:ru></xml>",
	/* 224 */ 0,
	/* 225 */ 0,
	/* 226 */ 0,
	/* 227 */ 0,
	/* 228 */ 0,
	/* 229 */ 0,
	/* 230 */ 0,
	/* 231 */ "<xml><:de>Weiß steht etwas besser.</:de><:en>White stands slightly better.</:en><:es>Las blancas estan mejor.</:es><:fr>Les blancs sont legerement mieux (petit avantage).</:fr><:it>Il Bianco sta leggermente meglio.</:it><:ru>У белых немного лучше.</:ru></xml>",
	/* 232 */ "<xml><:de>Schwarz steht etwas besser.</:de><:en>Black stands slightly better.</:en><:es>Las negras estan mejor.</:es><:fr>Les noirs sont legerement mieux (petit avantage).</:fr><:it>Il Nero sta leggermente meglio.</:it><:ru>У черных немного лучше.</:ru></xml>",
	/* 233 */ "<xml><:de>Die weißen Chancen sind etwas besser.</:de><:en>White's chances are slightly better.</:en><:es>Chances de las blancas son un poco mejores.</:es><:fr>Les chances des blancs sont legerement superieures.</:fr><:it>Le possibilità del Bianco sono leggermente migliori.</:it><:ru>Шансы белых немного выше.</:ru></xml>",
	/* 234 */ "<xml><:de>Die schwarzen Chancen sind etwas besser.</:de><:en>Black's chances are slightly better.</:en><:es>Chances de las negras son un poco mejores.</:es><:fr>Les chances des noirs sont legerement superieures.</:fr><:it>Le possibilità del Nero sono leggermente migliori.</:it><:ru>Шансы черных немного выше.</:ru></xml>",
	/* 235 */ "<xml><:de>Die weiße Position ist etwas vielversprechender.</:de><:en>White's position is slightly more promising.</:en><:es>La posicion de las blancas es un poco mas interesante.</:es><:fr>La position blanche est plus prometteuse.</:fr><:it>La posizione del Bianco è un po' più promettente.</:it><:ru>Позиция белых неcколько перспективнее.</:ru></xml>",
	/* 236 */ "<xml><:de>Die schwarze Position ist etwas vielversprechender.</:de><:en>Black's position is slightly more promising.</:en><:es>La posicion de las negras es un poco mas interesante.</:es><:fr>La position noire est plus prometteuse.</:fr><:it>La posizione del Nero è un po' più promettente.</:it><:ru>Позиция черных неcколько перспективнее.</:ru></xml>",
	/* 237 */ "<xml><:de>Die Chancen sind gleich.</:de><:en>Chances are equal.</:en><:es>Los chances son igualados.</:es><:fr>Les chances sont egales.</:fr><:it>Uguali possibilità.</:it><:ru>Шансы сторон равны </:ru></xml>",
	/* 238 */ "<xml><:de>Die Position ist ungefähr ausgeglichen.</:de><:en>The position is approximately equal.</:en><:es>La posicion es equilibrada.</:es><:fr>La position est approximativement egale.</:fr><:it>La posizione è sostanzialmente pari.</:it><:ru>Позиция примерно равна.</:ru></xml>",
	/* 239 */ "<xml><:de>Die Chancen sind verteilt.</:de><:en>Chances are mutual.</:en><:es>Ambos tienen chances.</:es><:fr>Avec des chances des deux cotes.</:fr><:it>Con possibilità da entrambi i lati.</:it><:ru>Шансы сторон взаимны.</:ru></xml>",
	/* 240 */ "<xml><:de>Zweischneidiges Spiel.</:de><:en>Double-edged play.</:en><:es>Juego complejo.</:es><:fr>Jeu a double tranchant.</:fr><:it>Con gioco a doppio taglio.</:it><:ru>Обоюдоострая игра.</:ru></xml>",
	/* 241 */ "<xml><:de>Weiß ist am gewinnen.</:de><:en>White is winning.</:en><:es>Las blancas estan ganando.</:es><:fr>Les blancs gagnent.</:fr><:it>Il Bianco sta vincendo.</:it><:ru>У белых выиграно.</:ru></xml>",
	/* 242 */ "<xml><:de>Schwarz ist am gewinnen.</:de><:en>Black is winning.</:en><:es>Las negras estan ganando.</:es><:fr>Les noirs gagnent.</:fr><:it>Il Nero sta vincendo.</:it><:ru>У черных выиграно.</:ru></xml>",
	/* 243 */ "<xml><:de>Weiß hat einen entscheidenden Vorteil.</:de><:en>White has a decisive advantage.</:en><:es>Las blancas tienen ventaja decisiva.</:es><:fr>Les blancs ont un avantage decisif.</:fr><:it>Il Bianco è in netto vantaggio.</:it><:ru>У белых решающий перевес.</:ru></xml>",
	/* 244 */ "<xml><:de>Schwarz hat einen entscheidenden Vorteil.</:de><:en>Black has a decisive advantage.</:en><:es>Las negras tienen ventaja decisiva.</:es><:fr>Les noirs ont un avantage decisif.</:fr><:it>Il Nero è in netto vantaggio.</:it><:ru>У черных решающий перевес.</:ru></xml>",
	/* 245 */ "<xml><:de>Weiß hat einige Initiative.</:de><:en>White has an initiative.</:en><:es>Las blancas tienen iniciativa.</:es><:fr>Les blancs ont l'initiative.</:fr><:it>Il Bianco ha l'iniziativa.</:it><:ru>У белых инициатива.</:ru></xml>",
	/* 246 */ "<xml><:de>Schwarz hat einige Initiative.</:de><:en>Black has an initiative.</:en><:es>Las negras tienen iniciativa.</:es><:fr>Les noirs ont l'initiative.</:fr><:it>Il Nero ha l'iniziativa.</:it><:ru>У черных инициатива.</:ru></xml>",
	/* 247 */ "<xml><:de>Der weiße König ist in Gefahr.</:de><:en>White's king is in danger.</:en><:es>El rey blanco esta en peligro.</:es><:fr>Le roi blanc est en danger.</:fr><:it>Il re Bianco è in pericolo.</:it><:ru>Белый король в опасности.</:ru></xml>",
	/* 248 */ "<xml><:de>Der schwarze König ist in Gefahr.</:de><:en>Black's king is in danger.</:en><:es>El rey negro esta en peligro.</:es><:fr>Le roi noir est en danger.</:fr><:it>Il re Nero è in pericolo.</:it><:ru>Черный король в опасности.</:ru></xml>",
	/* 249 */ "<xml><:de>Weiß entwickelt einen gefährlichen Angriff.</:de><:en>White develops a dangerous attack.</:en><:es>Las blancas desarollan un ataque peligroso.</:es><:fr>Les blancs developpent une attaque dangereuse.</:fr><:it>Il Bianco sviluppa un attacco pericoloso.</:it><:ru>Белые развивают опасную атаку.</:ru></xml>",
	/* 250 */ "<xml><:de>Schwarz entwickelt einen gefährlichen Angriff.</:de><:en>Black develops a dangerous attack.</:en><:es>Las negras desarollan un ataque peligroso.</:es><:fr>Les noirs developpent une attaque dangereuse.</:fr><:it>Il Nero sviluppa un attacco pericoloso.</:it><:ru>Черные развивают опасную атаку.</:ru></xml>",
	/* 251 */ "<xml><:de>Weiß hat das Läuferpaar.</:de><:en>White has a pair of bishops.</:en><:es>Las blancas tienen ventaja de pareja de alfiles.</:es><:fr>Les blancs ont la paire de fous.</:fr><:it>Il Bianco ha la coppia degli alfieri.</:it><:ru>У белых преимущество 2-х слонов.</:ru></xml>",
	/* 252 */ "<xml><:de>Schwarz hat das Läuferpaar.</:de><:en>Black has a pair of bishops.</:en><:es>Las negras tienen ventaja de pareja de alfiles.</:es><:fr>Les noirs ont la paire de fous.</:fr><:it>Il Nero ha la coppia degli alfieri.</:it><:ru>У черных преимущество 2-х слонов.</:ru></xml>",
	/* 253 */ "<xml><:de>Es ist eine ruhige Position entstanden mit einem kleinen weißen Vorteil.</:de><:en><xml><:en>There arises a quiet position with a slight white advantage</:en><:es>Tenemos la posicion tranquila con ligera ventaja de las blancas.</:es><:fr>Une position tranquille survient avec un leger avantage blanc.</:fr><:it>Si e creata una posizione tranquilla con un piccolo vantaggio per il Bianco.</:it><:ru>Возникла спокойная позиция с небольшим перевесом белых.</:ru></xml>",
	/* 254 */ "<xml><:de>Es ist eine ruhige Position entstanden mit einem kleinen schwarzen Vorteil.</:de><:en><xml><:en>There arises a quiet position with a slight black advantage</:en><:es>Tenemos la posicion tranquila con ligera ventaja de las negras.</:es><:fr>Une position tranquille survient avec un leger avantage noir.</:fr><:it>Si e creata una posizione tranquilla con un piccolo vantaggio per il Nero.</:it><:ru>Возникла спокойная позиция с небольшим перевесом черных.</:ru></xml>",
	/* 255 */ "<xml><:de>Der weiße König ist der Rochade beraubt.</:de><:en>White king is deprived of castling.</:en><:es>El rey blanco ha perdido el enroque.</:es><:fr>Le roi blanc est prive du roque.</:fr><:it>Il Bianco perde il diritto di arroccare.</:it><:ru>Белый король лишился рокировки.</:ru></xml>",
	/* 256 */ "<xml><:de>Der schwarze König ist der Rochade beraubt.</:de><:en>Black king is deprived of castling.</:en><:es>El rey negro ha perdido el enroque.</:es><:fr>Le roi noir est prive du roque.</:fr><:it>Il Nero perde il diritto di arroccare.</:it><:ru>Черный король лишился рокировки.</:ru></xml>",
	/* 257 */ "<xml><:de>Im bevorstehenden Endspiel sind die weißen Chancen etwas besser.</:de><:en>In the ensuing endgame white's chances are slightly better.</:en><:es>En el final chances de las blancas son un poco superiores.</:es><:fr>Dans la finale qui s'en suit, les chances des blancs sont legerement superieures.</:fr><:it>Nel finale a seguire il Bianco ha maggiori possibilità.</:it><:ru>В возникшем эндшпиле шансы белых несколько выше.</:ru></xml>",
	/* 258 */ "<xml><:de>Im bevorstehenden Endspiel sind die schwarzen Chancen etwas besser.</:de><:en>In the ensuing endgame black's chances are slightly better.</:en><:es>En el final chances de las negras son un poco superiores.</:es><:fr>Dans la finale qui s'en suit, les chances des noirs sont legerement superieures.</:fr><:it>Nel finale a seguire il Nero ha maggiori possibilità.</:it><:ru>В возникшем эндшпиле шансы черных несколько выше.</:ru></xml>",
	/* 259 */ "<xml><:de>Der Freibauer sichert Weiß einen Vorteil.</:de><:en>A passed pawn secures an advantage for White.</:en><:es>El peon pasado garantiza la ventaja a las blancas.</:es><:fr>Le pion passe donne un avantage aux blancs.</:fr><:it>Un pedone passato assicura il vantaggio Bianco.</:it><:ru>Проходная пешка обеспечивает перевес белым.</:ru></xml>",
	/* 260 */ "<xml><:de>Der Freibauer sichert Schwarz einen Vorteil.</:de><:en>A passed pawn secures an advantage for Black.</:en><:es>El peon pasado garantiza la ventaja a las negras.</:es><:fr>Le pion passe donne un avantage aux noirs.</:fr><:it>Un pedone passato assicura il vantaggio Nero.</:it><:ru>Проходная пешка обеспечивает перевес черным.</:ru></xml>",
	/* 261 */ "<xml><:de>Beiderseitiger Schlagabtausch.</:de><:en>Both sides exchange blows.</:en><:es>Los oponentes estan intercambiando golpes.</:es><:fr>Les deux camps font des echanges.</:fr><:it>Scambio di colpi da entrambi i lati.</:it><:ru>Стороны обмениваются ударами.</:ru></xml>",
	/* 262 */ 0,
	/* 263 */ "<xml><:de>Eine unangenehme Fesselung, die Weiß einen Vorteil garantiert.</:de><:en>An unpleasant pin granting a slight advantage to White.</:en><:es>Clavada fastidiosa que da cierta ventaja a las blancas.</:es><:fr>Un clouage deplaisant donnant un leger avantage aux blancs.</:fr><:it>Un'inchiodatura fastidiosa garantisce un leggero vantaggio al Bianco.</:it><:ru>Неприятная связка, дающая небольшой перевес белым.</:ru></xml>",
	/* 264 */ "<xml><:de>Eine unangenehme Fesselung, die Schwarz einen Vorteil garantiert.</:de><:en>An unpleasant pin granting a slight advantage to Black.</:en><:es>Clavada fastidiosa que da cierta ventaja a las negras.</:es><:fr>Un clouage deplaisant donnant un leger avantage aux noirs.</:fr><:it>Un'inchiodatura fastidiosa garantisce un leggero vantaggio al Nero.</:it><:ru>Неприятная связка, дающая небольшой перевес черным.</:ru></xml>",
	/* 265 */ "<xml><:de>Weiß hat eine gute Kompensation für das geopferte Material.</:de><:en>White has good compensation for sacrificed material.</:en><:es>Las blancas tienen buena compensacion por el material.</:es><:fr>Les blancs ont de bonnes compensations pour l'avantage materiel.</:fr><:it>Il Bianco ha buon compenso per il materiale sacrificato.</:it><:ru>У белых хорошая компенсация за материальный перевес.</:ru></xml>",
	/* 266 */ "<xml><:de>Schwarz hat eine gute Kompensation für das geopferte Material.</:de><:en>Black has good compensation for sacrificed material.</:en><:es>Las negras tienen buena compensacion por el material.</:es><:fr>Les noirs ont de bonnes compensations pour l'avantage materiel.</:fr><:it>Il Nero ha buon compenso per il materiale sacrificato.</:it><:ru>У черных хорошая компенсация за материальный перевес.</:ru></xml>",
	/* 267 */ "<xml><:de>Weiß hat keine Kompensation für das Materialdefizit.</:de><:en>White has no compensation for lacking material.</:en><:es>Las blancas no tienen compensacion por el material.</:es><:fr>Les blancs n'ont pas de compensation a leur perte de materiel.</:fr><:it>Il Bianco non ha alcun compenso per il materiale in meno.</:it><:ru>У белых нет компенсации за отсутствующий материал.</:ru></xml>",
	/* 268 */ "<xml><:de>Schwarz hat keine Kompensation für das Materialdefizit.</:de><:en>Black has no compensation for lacking material.</:en><:es>Las negras no tienen compensacion por el material.</:es><:fr>Les noirs n'ont pas de compensation a leur perte de materiel.</:fr><:it>Il Nero non ha alcun compenso per il materiale in meno.</:it><:ru>У черных нет компенсации за отсутствующий материал.</:ru></xml>",
	/* 269 */ "<xml><:de>Weiß hat einen Materialvorteil.</:de><:en>White has a material advantage.</:en><:es>Las blancas tienen ventaja material.</:es><:fr>Les blancs ont l'avantage materiel.</:fr><:it>Il Bianco ha vantaggio materiale.</:it><:ru>У белых материальный перевес</:ru></xml>",
	/* 270 */ "<xml><:de>Schwarz hat einen Materialvorteil.</:de><:en>Black has a material advantage.</:en><:es>Las negras tienen ventaja material.</:es><:fr>Les noirs ont l'avantage materiel.</:fr><:it>Il Nero ha vantaggio materiale.</:it><:ru>У черных материальный перевес.</:ru></xml>",
	/* 271 */ "<xml><:de>Das Schliessen der Position favorisiert Weiß.</:de><:en>The ensuing closed position is favorable for White.</:en><:es>La posicion cerrada que tenemos es ventajosa para las blancas.</:es><:fr>La position fermee qui survient est favorable aux blancs.</:fr><:it>La posizione chiusa a seguire favorisce il Bianco.</:it><:ru>Возникшая закрытая позиция в пользу белых.</:ru></xml>",
	/* 272 */ "<xml><:de>Das Schliessen der Position favorisiert Schwarz.</:de><:en>The ensuing closed position is favorable for Black.</:en><:es>La posicion cerrada que tenemos es ventajosa para las negras.</:es><:fr>La position fermee qui survient est favorable aux noirs.</:fr><:it>La posizione chiusa a seguire favorisce il Nero.</:it><:ru>Возникшая закрытая позиция в пользу черных.</:ru></xml>",
	/* 273 */ 0,
	/* 274 */ 0,
	/* 275 */ 0,
	/* 276 */ 0,
	/* 277 */ 0,
	/* 278 */ 0,
	/* 279 */ 0,
	/* 280 */ 0,
	/* 281 */ 0,
	/* 282 */ 0,
	/* 283 */ 0,
	/* 284 */ 0,
	/* 285 */ 0,
	/* 286 */ 0,
	/* 287 */ 0,
	/* 288 */ 0,
	/* 289 */ 0,
	/* 290 */ 0,
	/* 291 */ "<xml><:de>Mit der Drohung</:de><:en>With a threat of</:en><:es>Сon amenaza</:es><:fr>Avec la menace</:fr><:it>Minacciando</:it><:ru>C угрозой</:ru></xml>",
	/* 292 */ "<xml><:de>Mit der Idee</:de><:en>With the idea of</:en><:es>Сon idea</:es><:fr>Avec l'idee</:fr><:it>Con l'idea</:it><:ru>C идеей</:ru></xml>",
};


// IMPORTANT NOTE: keep the entries normalized!
static char const* Phrases500[] =
{
	/* 500 */ 0,
	/* 501 */ "<xml><:de>Ein seltener Zug.</:de><:en>A rare move.</:en><:es>Una jugada rara.</:es><:fr>Un coup rare.</:fr><:it>Una mossa rara.</:it><:ru>Редкий ход.</:ru></xml>",
	/* 502 */ "<xml><:de>Die Hauptfortsetzung ist</:de><:en>The main continuation is</:en><:es>La continuacion principal es</:es><:fr>La suite principale est</:fr><:it>La continuazione principale è</:it><:ru>Основное продолжение</:ru></xml>",
	/* 503 */ "<xml><:de>Neuerung!</:de><:en>Novelty!</:en><:es>¡Novedad!</:es><:fr>Nouveaute!</:fr><:it>Novità!</:it><:ru>Новинка!</:ru></xml>",
	/* 504 */ "<xml><:de>Bisher wurde gespielt:</:de><:en>Previously occured</:en><:es>Se encontraba antes:</:es><:fr>Deja vu</:fr><:it>Avvenuto in precedenza.</:it><:ru>Ранее встречалось</:ru></xml>",
	/* 505 */ "<xml><:de>Ein veralteter Zug.</:de><:en>An old move.</:en><:es>Jugada vieja.</:es><:fr>Un coup ancien.</:fr><:it>Una vecchia mossa.</:it><:ru>Старый ход.</:ru></xml>",
	/* 506 */ "<xml><:de>Neuerdings ist folgende Fortsetzung populärer:</:de><:en>Recently more popular is the continuation:</:en><:es>Ultimamente la continuacion mas popular es:</:es><:fr>Recemment plus populaire est la suite:</:fr><:it>Recentemente è più popolare la continuazione:</:it><:ru>В последнее время популярнее продолжение:</:ru></xml>",
	/* 507 */ "<xml><:de>Dieser Zug wurde bisher nicht auf hohem Niveau angewandt.</:de><:en>This move has not occurred at the high level before.</:en><:es>Esta jugada nunca ha utilizada en los juegos de un alto nivel.</:es><:fr>A ce jour, ce coup n’est jamais apparu au top niveau.</:fr><:it>Questa mossa non si è ancora vista a livello magistrale.</:it><:ru>Ход, не применявшийся на высоком уровне.</:ru></xml>",
	/* 508 */ "<xml><:de>Führende Schachspieler bevorzugen</:de><:en>Leading chessplayers prefer</:en><:es>Los jugadores dirigentes prefieren</:es><:fr>Les joueurs de haut niveau preferent</:fr><:it>I più forti giocatori preferiscono</:it><:ru>Ведущие шахматисты предпочитали</:ru></xml>",
	/* 509 */ "<xml><:de>Die solidere Alternative ist</:de><:en>The more reliable continuation is</:en><:es>La continuacion mas segura</:es><:fr>Est une suite plus efficace</:fr><:it>Una solida alternativa è</:it><:ru>Более надежное продолжение</:ru></xml>",
	/* 510 */ "<xml><:de>Beachtung verdient</:de><:en>Worth attention is</:en><:es>Merece la atencion</:es><:fr>Merite attention</:fr><:it>Merita attenzione</:it><:ru>Заслуживает внимания</:ru></xml>",
	/* 511 */ "<xml><:de>Dieser Zug wird immer populärer.</:de><:en>This move becomes more and more unpopular.</:en><:es>Esta jugada se pone a estar mas y mas popular.</:es><:fr>Ce coup est de moins en moins apprecie.</:fr><:it>Questa mossa sta diventando sempre piu impopolare.</:it><:ru>Ход становится непопулярным.</:ru></xml>",
};


static
bool
parseChessOkComment(mstl::string& s)
{
	switch (*s.c_str())
	{
		case '<':
			// convert comments like {<font color=red>-12.13|d11</font>}
			if (::strncmp(s, "<font color=", 11) == 0 && ::strncmp(s.end() - 7, "</font>", 7) == 0)
			{
				mstl::string::size_type n = s.find('>');

				if (n != mstl::string::npos)
				{
					s.replace(0, n + 1, "<xml><b>", 8);
					s.replace(s.size() - 7, 7, "</b></xml>", 10);
					return true;
				}
			}
			break;

		case '&':
			// convert comments like {&lt;font color=red&gt;-12.13|d11&lt;/font&gt;}
			if (	::strncmp(s, "&lt;font color=", 15) == 0
				&& ::strncmp(s.end() - 13, "&lt;/font&gt;", 13) == 0)
			{
				mstl::string::size_type n = s.find("&gt;");

				if (n != mstl::string::npos && n < s.size() - 4)
				{
					s.replace(0, n + 4, "<xml><b>", 8);
					s.replace(s.size() - 13, 13, "</b></xml>", 10);
					return true;
				}
			}
			break;

		case 'R':
			// strip comments like {Rybka Aquarium (0:00:08)}
			if (::strncmp(s, "Rybka Aquarium (", 16) == 0)
			{
				char const* p = s.c_str() + 16;

				while (*p == ':' || ::isdigit(*p))
					++p;

				if (*p == ')')
				{
					s.erase(s.begin(), p + 1);
					s.ltrim();
				}
			}
			break;
	}

	return false;
}


static
void
join(Comment* first, Comment* last)
{
	for (Comment* next = first + 1; next < last; ++next)
		first->append(*next, ' ');
}


inline static
country::Code
checkCountry(mstl::string const& site, country::Code original, country::Code possible)
{
	db::Site const* p = db::Site::searchSite(site);

	if (p && p->containsCountry(possible) && !p->containsCountry(original))
		return possible;

	return original;
}


static mstl::string
quote(mstl::string const& s)
{
	mstl::string t;

	for (mstl::string::const_iterator i = s.begin(); i != s.end(); ++i)
	{
		if (*i == '"')
			t += '\\';
		t += *i;
	}

	return t;
}


static bool
isdelim(char c)
{
	return c == '\0' || ispunct(c) || isspace(c);
}


static char const*
skipMoveToken(char const* s)
{
	while (CharToType[int(*s)] != None)
		++s;

	return s;
}


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;
	return s;
}


static mstl::string
trim(mstl::string const& s)
{
	mstl::string t(s);
	t.trim();
	return t;
}


static void
addSpace(mstl::string& s)
{
	if (!s.empty() && !::isspace(s.back()))
		s += ' ';
}


static bool
checkScore(mstl::string const& s)
{
	if (s.find_first_not_of('?') == mstl::string::npos)
		return true;

	for (unsigned i = 0; i < s.size(); ++i)
	{
		if (!::isdigit(s[i]))
			return false;
	}

	return true;
}


static bool
isElo(char const* s, char const* e)
{
	unsigned size = e - s;

	if (size == 3)
		return '7' <= s[0] && s[0] <= '9' && isdigit(s[1]) && isdigit(s[2]);

	if (size != 4)
		return false;

	if (s[0] == '0')
		return '7' <= s[1] && s[1] <= '9' && isdigit(s[2]) && isdigit(s[3]);

	return isdigit(s[0]) && isdigit(s[1]) && isdigit(s[2]);
}


static bool
isCountry(char const* s, char const* e)
{
	return e - s == 3 && country::fromString(s) != country::Unknown;
}


static bool
isTitle(char const* s, char const* e)
{
	return (e - s == 2 || (e - s == 3 && ::isupper(s[2]))) && title::fromString(s) != title::None;
}


static bool
isHuman(char const* s, char const* e)
{
	switch (::tolower(*s))
	{
		case 'h': return strncasecmp(s, "human", 5) == 0;
		case 'm': return strncasecmp(s, "man", 3) == 0;
	}

	return false;
}


static bool
isSex(char const* s, char const* e)
{
	switch (*s)
	{
		case 'f': return e - s == 1;

		case 'm':
			return	e - s == 1
					|| (e - s == 3 && strncmp(s, "man", 3) == 0);

		case 'w':
			return e - s == 5 && strncmp(s, "woman", 5) == 0;
	}

	return false;
}


static bool
isProgram(char const* s, char const* e)
{
	switch (::tolower(*s))
	{
		case 'c': return strncasecmp(s, "comp", 4) == 0;
		case 'e': return strncasecmp(s, "engine", 6) == 0;
		case 'p': return strncasecmp(s, "program", 7) == 0;
	}

	return false;
}


static void
removeValue(mstl::string& str, char* p, char delim)
{
	while (*p != delim)
		--p;
	while (p > str.c_str() && ::isspace(p[-1]))
		--p;

	*p = '\0';
	str.set_size(p - str.begin());
}


static bool
matchSuffix(mstl::string const& str, mstl::string const& suffix)
{
	if (str.size() < suffix.size())
		return false;

	return strcasecmp(str.c_str() + suffix.size() - str.size(), suffix) == 0;
}


static mstl::string
itos(unsigned n)
{
	char buf[32];
	snprintf(buf, sizeof(buf), "%u", n);
	return buf;
}


static bool
isEmpty(char const* s)
{
	while (::isspace(*s))
		++s;

	return *s == '\0';
}


static void
appendSpace(mstl::string& str)
{
	if (!str.empty() && !isspace(str.back()))
		str += ' ';
}


PgnReader::Interruption::Interruption(Error code, mstl::string const& msg) :error(code), message(msg) {}
PgnReader::Pos::Pos() : line(0), column(0) {}


PgnReader::PgnReader(mstl::istream& stream,
							sys::utf8::Codec& codec,
							int firstGameNumber,
							Modification modification,
							ResultMode resultMode)
	:Reader(format::Pgn)
	,m_stream(stream)
	,m_putback(0)
	,m_linePos(0)
	,m_lineEnd(0)
	,m_gameCount(0)
	,m_firstGameNumber(firstGameNumber)
	,m_resultMode(resultMode)
	,m_prefixAnnotation(nag::Null)
	,m_ignoreNags(false)
	,m_noResult(false)
	,m_result(result::Unknown)
	,m_timeMode(time::Unknown)
	,m_modification(modification)
	,m_parsingFirstHdr(true)
	,m_parsingTags(false)
	,m_failed(false)
	,m_eof(false)
	,m_hasNote(false)
	,m_atStart(true)
	,m_parsingComment(false)
	,m_sourceIsPossiblyChessBase(false)
	,m_sourceIsChessOK(false)
	,m_postIndex(0)
	,m_variant(variant::Unknown)
	,m_codec(codec)
{
	M_REQUIRE(codec.hasEncoding());

	::memset(m_countWarnings, 0, sizeof(m_countWarnings));
	::memset(m_countErrors, 0, sizeof(m_countErrors));
}


PgnReader::~PgnReader() throw()
{
	// no action
}


bool
PgnReader::encodingFailed() const
{
	return m_failed;
}


mstl::string const&
PgnReader::encoding() const
{
	return m_codec.encoding();
}


inline
void
PgnReader::putback(int c)
{
	M_ASSERT(m_putback < sizeof(m_putbackBuf));
	M_ASSERT(c);

	if (c != '\n')
	{
		--m_currPos.column;
		m_putbackBuf[m_putback++] = c;
	}
}


mstl::string
PgnReader::inverseFigurineMapping(mstl::string const& str)
{
	mstl::string result(str);
	if (!m_figurine.empty())
		replaceFigurineSet(m_figurine, "KQRBNP", result);
	return result;
}


void
PgnReader::fatalError(Error code, Pos const& pos, mstl::string const& item)
{
	if (m_parsingFirstHdr)
	{
		error(SeemsNotToBePgnText,
				pos.line, 0, -1,
				mstl::string::empty_string,
				mstl::string::empty_string,
				mstl::string::empty_string);
	}
	else
	{
		error(code,
				pos.line, 0, -1,
				mstl::string::empty_string,
				mstl::string::empty_string,
				item);
	}

	throw Termination();
}


void
PgnReader::error(Error code, Pos pos, mstl::string const& item)
{
	if (m_firstGameNumber < 0 && code == UnexpectedEndOfInput)
	{
		putMove(true);
		throw Termination();
	}

	if (m_parsingFirstHdr)
	{
		error(SeemsNotToBePgnText,
				pos.line, 0, -1,
				mstl::string::empty_string,
				mstl::string::empty_string,
				mstl::string::empty_string);
		throw Termination();
	}

	unsigned gameCount = m_gameCount + m_firstGameNumber + 1;

	mstl::string myItem = ::quote(item);
	mstl::string msg;

	// TODO i18n
	switch (unsigned(code))
	{
		case InvalidToken:				msg += "Error parsing PGN file: invalid token " + myItem; break;
		case UnexpectedSymbol:			msg += "Error parsing PGN file: unexpected symbol " + myItem; break;
		case UnexpectedEndOfInput:		msg += "Error parsing PGN file: unexpected end of input"; break;
		case UnexpectedTag:				msg += "Error parsing PGN file: unexpected tag inside game";break;
		case UnexpectedEndOfGame:		msg += "Error parsing PGN file: unexpected end of game"; break;
		case UnterminatedVariation:	msg += "Error parsing PGN file: unterminated variation"; break;
		case InvalidMove:					msg += "Error parsing PGN file: illegal move " + myItem; break;
		case InvalidFen:					gameCount = pos.column = 0; break;
		default:								pos.column = 0; break;
	}

	// do line pos correction
	switch (unsigned(code))
	{
		case InvalidToken:
		case UnexpectedSymbol:
		case InvalidMove:
		case UnexpectedTag:
			if (m_linePos > m_line.begin() && ::strncmp(item, m_linePos, item.size()) != 0)
			{
				advanceLinePos(-1);
				if (m_linePos > m_line.begin() && ::strncmp(item, m_linePos, item.size()) != 0)
					advanceLinePos(-1);
			}
	}

	if (m_countErrors[code] < MaxErrors)
	{
		mstl::string info;

		if (m_tags.contains(White) && m_tags.contains(Black))
			info = m_tags.value(White) + " - " + m_tags.value(Black);

		error(code, pos.line, pos.column, gameCount, msg, info, myItem);

		if (++m_countErrors[code] == MaxErrors)
		{
			warning(	MaximalErrorCountExceeded,
						pos.line, 0, 0,
						mstl::string::empty_string,
						mstl::string::empty_string);
		}
	}

	if (code == InvalidMove || !m_move.isLegal())
		m_move.clear();

	throw Interruption(code, msg);
}


void
PgnReader::warning(Warning code, Pos pos, mstl::string const& item)
{
	if (m_countWarnings[code] == MaxWarnings)
		return;

	switch (unsigned(code))
	{
		case InvalidNag:
		case TooManyNags:
		case ResultDidNotMatchHeaderResult:
		case IllegalCastling:
			break;

		default:
			pos.column = 0;
			break;
	}

	mstl::string info = ::quote(item);

	if (m_tags.contains(White) && m_tags.contains(Black))
	{
		warning(	code, pos.line, pos.column,
					m_gameCount + m_firstGameNumber + 1,
					m_tags.value(White) + " - " + m_tags.value(Black),
					info);
	}
	else
	{
		warning(	code, pos.line, pos.column,
					m_gameCount + m_firstGameNumber + 1,
					mstl::string::empty_string,
					info);
	}

	if (++m_countWarnings[code] == MaxWarnings)
	{
		warning(	MaximalWarningCountExceeded,
					pos.line, 0, 0,
					mstl::string::empty_string,
					mstl::string::empty_string);
	}
}


void PgnReader::fatalError(Error code, mstl::string const& item)	{ fatalError(code, m_currPos, item); }
void PgnReader::error(Error code, mstl::string const& item)			{ error(code, m_currPos, item); }
void PgnReader::warning(Warning code, mstl::string const& item)	{ warning(code, m_currPos, item); }


unsigned
PgnReader::process(Progress& progress)
{
	M_REQUIRE(hasConsumer());

	try
	{
		Token		token				= m_firstGameNumber < 0 ? kTag : searchTag();
		unsigned	numGames			= mstl::max(1u, unsigned(::ceil(m_stream.size()/696.0)));// an estimation
		unsigned	frequency		= progress.frequency(numGames, 1000);
		unsigned	reportAfter		= frequency;
		unsigned	count				= 0;

		ProgressWatcher watcher(progress, numGames);

		while (token == kTag)
		{
			if (reportAfter == count++)
			{
				progress.update(count);

				if (progress.interrupted())
					return m_gameCount;

				reportAfter += frequency;
			}

			try
			{
				m_noResult = false;
				m_parsingFirstHdr = false;
				m_comments.clear();
				m_marks.clear();
				m_site.clear();
				m_annotation.clear();
				m_timeMode = time::Unknown;
				m_parsingComment = false;
				m_variant = variant::Unknown;
				m_ignoreNags = false;
				m_hasNote = false;
				m_atStart = true;
				m_significance[color::White] = 1;
				m_significance[color::Black] = 1;
				m_sourceIsChessOK = false;
				m_postIndex = 0;

				if (m_firstGameNumber >= 0)
				{
					m_parsingTags = true;
					readTags();
					m_parsingTags = false;
					m_sourceIsPossiblyChessBase =		m_modification == Raw
															&& m_tags.contains(PlyCount)
															&& m_tags.contains(EventCountry);
				}

				if (!consumer().startGame(m_tags))
					error(UnsupportedVariant, m_currPos);

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
								error(UnexpectedSymbol, m_prevPos, ")");

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

				putMove(true);

				if (!m_comments.empty())
				{
					// We have a comment after the last variation has finished,
					// but no more moves. As a workaround we add a variation.
					consumer().startVariation();
					m_move = Move::null();
					if (consumer().board().blackToMove())
						m_move.setColor(color::Black);
					m_postIndex = m_comments.size();
					putMove();
					consumer().finishVariation();
					warning(CommentAtEndOfGame);
				}

				if (token == kError)
					unexpectedSymbol(kError, get());

				if (consumer().variationLevel() > 0)
					error(UnterminatedVariation);

				if (token == kEoi)
				{
					if (m_firstGameNumber < 0)
						return 0;

					error(UnexpectedEndOfInput);
				}
				else if (token == kTag)
				{
					if (m_firstGameNumber < 0)
						error(UnexpectedTag, m_currPos);

					if (m_currPos.column == 1)
					{
						putback('[');
						error(UnexpectedEndOfGame, m_currPos);
					}

					m_prevPos = m_currPos;
					error(UnexpectedTag, m_prevPos);
				}
				else
				{
					M_ASSERT(token == kResult);

					if (m_noResult || m_resultMode == InMoveSection)
					{
						m_tags.set(Result, m_result);
					}
					else
					{
						result::ID r = result::fromString(m_tags.value(Result));

						if (m_result != r)
						{
							warning(ResultDidNotMatchHeaderResult, m_prevPos, result::toString(m_result));
							m_result = r;
						}
					}
				}

				finishGame();
			}
			catch (Interruption const& exc)
			{
				if (!m_parsingTags)
					handleError(exc.error, exc.message);

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

	return m_gameCount;
}


void
PgnReader::handleError(Error code, mstl::string const& message)
{
	mstl::string msg(message);

	if (code != UnexpectedEndOfGame)
	{
		mstl::string rest;

		findNextEmptyLine(rest);
		rest.trim();

		if (!::isEmpty(rest))
		{
			msg += "\nRest of game: \"";
			msg += rest;
			msg += '"';
		}
	}

	if (!msg.empty())
	{
		Comment comment(msg, false, false);

		if (m_comments.empty())
		{
			if (!m_move)
				m_postIndex = 1;
			m_comments.push_back(comment);
		}
		else
		{
			m_comments.back().append(comment, '\n');
		}

		if (!m_move)
			m_move = Move::null();

		m_hasNote = true;
		putMove();

		while (consumer().variationLevel() > 0)
			consumer().finishVariation();

		finishGame();
	}

	if (code == UnexpectedTag)
	{
		skipLine();
		searchTag();
	}
}


void
PgnReader::checkSite()
{
	mstl::string const& site = m_tags.value(tag::Site);

	if (m_eventCountry == country::Unknown)
	{
//		db::Site const* s = db::Site::searchSite(site);
//
//		if (s && s->countCountries() == 1)
//			m_eventCountry = s->country(0);
	}
	else
	{
		// sometimes wrong country codes will be used; we'll try to fix this:

		switch (int(m_eventCountry))
		{
			case country::Cambodia:		// CAM: sometimes confused with Cameroon (CMR)
				m_eventCountry = ::checkCountry(site, country::Cambodia, country::Cameroon);
				break;

			case country::Antigua:		// ANT: often confused with Netherlands_Antilles (AHO)
				m_eventCountry = ::checkCountry(site, country::Antigua, country::Netherlands_Antilles);
				break;

			case country::England:		// ENG: sometimes Gibraltar will be confused with England
				m_eventCountry = ::checkCountry(site, country::England, country::Gibraltar);
				break;

			case country::France:		// FRA: sometimes Monaco will be confused with France
				m_eventCountry = ::checkCountry(site, country::France, country::Monaco);
				break;

			case country::Ireland:		// IRL: probably it belongs to Northern_Ireland (NIR)
				m_eventCountry = ::checkCountry(site, country::Ireland, country::Northern_Ireland);
				break;

			case country::Kiribati:		// KIR: often confused with Kyrgyzstan (KGZ)
				m_eventCountry = ::checkCountry(site, country::Kiribati, country::Kyrgyzstan);
				break;

			case country::Lebanon:		// LIB: often confused with Libya (LBA)
				m_eventCountry = ::checkCountry(site, country::Lebanon, country::Libya);
				break;

			case country::Monaco:		// MON: sometimes confused with Mongolia (MGL)
				m_eventCountry = ::checkCountry(site, country::Monaco, country::Mongolia);
				break;

			case country::Niger:			// NIG: often confused with Nigeria (NGR)
				m_eventCountry = ::checkCountry(site, country::Niger, country::Nigeria);
				break;

			case country::Swaziland:	// SWZ: often confused with Switzerland (SUI)
				m_eventCountry = ::checkCountry(site, country::Swaziland, country::Switzerland);
				break;

			case country::The_Internet:	// NET: sometimes confused with Netherlands (NED)
				m_eventCountry = ::checkCountry(site, country::The_Internet, country::Netherlands);
				break;

			case country::Serbia_and_Montenegro:	// SCG: Scid is confusing this with Yugoslavia (YUG)
				m_eventCountry = ::checkCountry(	site,
															country::Serbia_and_Montenegro,
															country::Bosnia_and_Herzegovina);
				break;

			case country::United_Arab_Emirates:	// UAE: sometimes Bahrain will be confused with UAE
				m_eventCountry = ::checkCountry(site, country::United_Arab_Emirates, country::Bahrain);
				break;
		}

		if (m_sourceIsPossiblyChessBase)
		{
			// ChessBases ignores the PGN standard in case of the country codes.
			// We try to fix wrong country code mappings (should only happen if
			// the PGN source is ChessBase).
			//
			// We will verify the corrections. We cannot be sure that the source
			// of the data is ChessBase.

			switch (int(m_eventCountry))
			{
#if 0	// already handled
				case country::Cambodia:			// CAM
					m_eventCountry = ::checkCountry(site, country::Cambodia, country::Cameroon);
					break;
#endif

				case country::Palestine:		// PLE
					m_eventCountry = ::checkCountry(site, country::Palestine, country::Palau);
					break;

				case country::El_Salvador:		// SAL
					m_eventCountry = ::checkCountry(site, country::El_Salvador, country::Solomon_Islands);
					break;

				case country::Switzerland:		// SUI
					m_eventCountry = ::checkCountry(	site,
																country::Switzerland,
																country::Saint_Vincent_and_the_Grenadines);
					break;

				case country::Slovenia:			// SVN
					m_eventCountry = ::checkCountry(site, country::Slovenia, country::Jan_Mayen_and_Svalbard);
					break;

				case country::Czech_Republic:	// CZE
					m_eventCountry = ::checkCountry(site, country::Czech_Republic, country::Czechoslovakia);
					break;

				case country::West_Germany:	// FRG
					m_eventCountry = ::checkCountry(site, country::Germany, country::French_Guiana);
					break;

				case country::The_Internet:	// NET
					m_eventCountry = ::checkCountry(site, country::The_Internet, country::American_Samoa);
					break;

				case country::DR_Congo:			// ZAR
					m_eventCountry = ::checkCountry(site, country::DR_Congo, country::Russia);
					break;
			}

			// Possibly the mapping of the country code is still incorrect.
			// Complain this to ChessBase!
		}

		m_tags.add(EventCountry, country::toString(m_eventCountry));
	}

// NOTE:
// The tags "WhiteCountry", "BlackCountry" do not exist if source is "ChessBase".
//
//	if (m_tags.contains(Source))
//	{
//		if (::strcasecmp(m_tags.value(Source), "chessbase") == 0 || !m_eventCountry.empty())
//		{
//			if (m_tags.contains(WhiteCountry))
//			{
//				m_tags.set(	WhiteCountry,
//								country::toString(
//									country::remapToChessbaseCoding(
//										country::fromString(m_tags.value(WhiteCountry)))));
//			}
//
//			if (m_tags.contains(BlackCountry))
//			{
//				m_tags.set(	BlackCountry,
//								country::toString(
//									country::remapToChessbaseCoding(
//										country::fromString(m_tags.value(BlackCountry)))));
//			}
//		}
//	}
}


void
PgnReader::checkMode()
{
	event::Mode mode = event::Undetermined;

	if (m_tags.contains(Mode))
	{
		mode = event::modeFromString(m_tags.value(Mode));
	}
	else
	{
		mode = getEventMode(m_tags.value(Event), m_tags.value(tag::Site));

		if (mode != event::Undetermined)
			m_tags.add(Mode, event::toString(mode));
	}

	if (!m_tags.contains(TimeMode))
	{
		if (m_timeMode == time::Unknown)
		{
			switch (int(mode))
			{
				case event::PaperMail:
				case event::Email:
					m_timeMode = time::Corr;
					break;
			}
		}

		if (m_timeMode != time::Unknown)
			m_tags.add(TimeMode, time::toString(m_timeMode));
	}
}


void
PgnReader::finishGame()
{
	consumer().finishMoveSection(m_result);

	if (m_modification == Normalize)
	{
		checkSite();
		checkMode();
	}

	switch (consumer().finishGame(m_tags))
	{
		case save::Ok:								break;
		case save::UnsupportedVariant:		return; // already handled
		case save::DecodingFailed:				return; // cannot happen
		case save::TooManyGames:				fatalError(TooManyGames);
		case save::FileSizeExeeded:			fatalError(FileSizeExeeded);
		case save::TooManyPlayerNames:		fatalError(TooManyPlayerNames);
		case save::TooManyEventNames:			fatalError(TooManyEventNames);
		case save::TooManySiteNames:			fatalError(TooManySiteNames);
		case save::TooManyRoundNames:			fatalError(TooManyRoundNames);
		case save::TooManyAnnotatorNames:	fatalError(TooManyAnnotatorNames);

		case save::GameTooLong:
			error(GameTooLong,
					m_currPos.line,
					m_currPos.column,
					m_gameCount + m_firstGameNumber,
					mstl::string::empty_string,
					mstl::string::empty_string,
					mstl::string::empty_string);
			break;
	}

	++m_gameCount;
}


void
PgnReader::convertToUtf(mstl::string& s)
{
	m_codec.toUtf8(s);

	if (__builtin_expect(m_codec.failed(), 0))
	{
		warning(EncodingFailed, m_prevPos, s);
		m_codec.reset();
		m_failed = true;
	}
}


void
PgnReader::putMove(bool lastMove)
{
	if (__builtin_expect(m_move, 1))
	{
		M_ASSERT(m_hasNote == (!m_comments.empty() || !m_marks.isEmpty() || !m_annotation.isEmpty()));

		if (m_hasNote)
		{
			if (m_atStart)
			{
				if (m_comments.empty() || m_postIndex <= 1)
				{
					if (!m_annotation.isEmpty() || !m_marks.isEmpty())
						consumer().putComment(Comment(), m_annotation, m_marks);
				}
				else
				{
					consumer().putComment(m_comments[0], m_annotation, m_marks);
					m_comments.erase(m_comments.begin());

					if (m_postIndex > 0)
						--m_postIndex;
				}
				m_marks.clear();
				m_annotation.remove(nag::Diagram);
				m_annotation.remove(nag::DiagramFromBlack);
			}

			if (m_postIndex > 0)
			{
				M_ASSERT(m_postIndex <= m_comments.size());

				::join(m_comments.begin(), m_comments.begin() + m_postIndex);

				if (m_postIndex == m_comments.size())
				{
					consumer().putMove(m_move, m_annotation, m_comments[0], Comment(), m_marks);
					m_comments.clear();
				}
				else if (lastMove)
				{
					::join(m_comments.begin() + m_postIndex, m_comments.end());
					consumer().putMove(m_move, m_annotation, m_comments[0], m_comments[m_postIndex], m_marks);
					m_comments.clear();
				}
				else
				{
					consumer().putMove(m_move, m_annotation, m_comments[0], m_comments[m_postIndex], m_marks);
					m_comments.erase(m_comments.begin(), m_comments.begin() + m_postIndex + 1);
				}
			}
			else if (lastMove)
			{
				::join(m_comments.begin(), m_comments.end());
				if (m_comments.empty())
					m_comments.push_back();
				consumer().putMove(m_move, m_annotation, Comment(), m_comments[0], m_marks);
				m_comments.clear();
			}
			else
			{
				if (m_comments.empty())
					m_comments.push_back();
				consumer().putMove(m_move, m_annotation, Comment(), m_comments[0], m_marks);
				m_comments.erase(m_comments.begin());
			}

			m_marks.clear();
			m_annotation.set(m_prefixAnnotation);
			m_prefixAnnotation = nag::Null;
			m_postIndex = m_comments.size();
			m_hasNote = !m_comments.empty();
		}
		else
		{
			consumer().putMove(m_move);
		}

		m_move.clear();
		m_atStart = false;
	}
	else
	{
		m_postIndex = m_comments.size();
	}
}


void
PgnReader::setFigurine(mstl::string const& figurine)
{
	M_REQUIRE(figurine.size() == 6);
	M_REQUIRE(	::isalpha(figurine[0]) && ::isupper(figurine[0])
				&& ::isalpha(figurine[1]) && ::isupper(figurine[1])
				&& ::isalpha(figurine[2]) && ::isupper(figurine[2])
				&& ::isalpha(figurine[3]) && ::isupper(figurine[3])
				&& ::isalpha(figurine[4]) && ::isupper(figurine[4])
				&& ::isalpha(figurine[5]) && ::isupper(figurine[5]));

	if (figurine == "KQRBNP")
		m_figurine.clear();
	else
		m_figurine = figurine;
}


void
PgnReader::advanceLinePos(int n)
{
	M_ASSERT(m_linePos + n <= m_lineEnd);
	M_ASSERT(0 <= n || -n <= int(m_currPos.column));

	m_linePos += n;
	m_currPos.column += n;
}


void
PgnReader::setLinePos(char* pos)
{
	M_ASSERT(pos >= m_linePos || m_linePos - pos <= int(m_currPos.column));

	m_currPos.column += pos - m_linePos;
	m_linePos = pos;
}


int
PgnReader::get(bool allowEndOfInput)
{
	if (m_putback)
	{
		++m_currPos.column;
		return m_putbackBuf[--m_putback];
	}

	if (m_lineEnd <= m_linePos)
	{
		if (m_stream.getline(m_line))
		{
			m_linePos = m_line.begin();
			m_lineEnd = m_line.end();

			if (m_lineEnd > m_linePos && m_lineEnd[-1] == '\r')
			{
				M_ASSERT(m_line.readonly());
				m_line.hook(m_line.data(), m_line.size() - 1);
				m_lineEnd = m_line.end();
			}

			if (!m_figurine.empty() && (!m_parsingTags || *m_line.begin() != '['))
				replaceFigurineSet("KQRBNP", m_figurine, m_line);

			m_currPos.column = 0;
			++m_currPos.line;
		}
		else if (m_eof)
		{
			if (!allowEndOfInput)
				error(UnexpectedEndOfInput);

			return '\0';
		}
		else
		{
			m_eof = true;
		}

		return '\n';
	}
	else
	{
		++m_currPos.column;
	}

	return *m_linePos++;
}


void
PgnReader::skipLine()
{
	m_linePos = m_lineEnd;
}


void
PgnReader::findNextEmptyLine(mstl::string& str)
{
	while (true)
	{
		int c = get(true);

		if (c == '\n')
		{
			int d = get(true);

			if (d == '\n')
				return;

			::addSpace(str);
		}
		else
		{
			str += c;
		}

		if (m_stream.eof())
			return;
	}
}


PgnReader::Token
PgnReader::searchTag()
{
	while (true)
	{
		int c = get(true);

		while (::isspace(c))
			c = get(true);

		if (c == '\0')
			return kEoi;

		if (c == '[')
			return kTag;

		skipLine();
	}

	return kEoi;	// satisfies the compiler
}


void
PgnReader::checkTags()
{
	M_ASSERT(m_modification == Normalize);

	if (m_tags.contains(Fen))
	{
		Board board;
		mstl::string const& fen = m_tags.value(Fen);

		if (!board.setup(fen) || board.validate(m_variant) != Board::Valid)
			error(InvalidFen, m_fenPos, fen);

		if (board.isStandardPosition())
		{
			m_tags.remove(Fen);
			m_tags.remove(SetUp);
		}
		else
		{
			if (board.isChess960Position())
				m_tags.set(Variant, chess960::identifier());
			else if (board.isShuffleChessPosition())
				m_tags.set(Variant, shuffle::identifier());
			else if (!board.notDerivableFromChess960())
				m_tags.set(Variant, shuffle::identifier());
			else if (!board.notDerivableFromStandardChess())
				m_tags.set(Variant, chess960::identifier());
			else if (m_variant == variant::Shuffle)
				m_tags.set(Variant, shuffle::identifier());
			else if (m_variant == variant::Chess960)
				m_tags.set(Variant, chess960::identifier());

			m_tags.set(SetUp, "1");
			m_tags.remove(tag::Eco);
		}
	}
	else if (m_variant == variant::Shuffle || m_variant == variant::Chess960)
	{
		warning(MissingFen, m_variantPos, m_tags.value(Variant));
	}

	if (!m_tags.contains(White))
	{
		if (!m_tags.contains(Black))
		{
			m_tags.set(Black, "?");
			warning(MissingPlayerTags, m_prevPos);
		}

		m_tags.set(White, "?");
	}
	else if (!m_tags.contains(Black))
	{
		if (!m_tags.contains(White))
		{
			m_tags.set(White, "?");
			warning(MissingPlayerTags, m_prevPos);
		}

		m_tags.set(Black, "?");
	}

	if (!m_tags.contains(Result))
	{
		warning(MissingResultTag, m_prevPos);
		m_tags.set(Result, "*");
		m_noResult = true;
	}
}


bool
PgnReader::checkTag(ID tag, mstl::string& value)
{
	if (m_modification == Raw)
		return true;

	switch (tag)
	{
		case White:
		case Black:
			if (value.empty())
				return true;

			Player::standardizeNames(value);

			// remove trailing chars
			while (::strchr(" .,", value.back()))
			{
				value.resize(value.size() - 1);

				if (value.empty())
					return true;
			}

			// extract player data
			{
				mstl::string v;

				while (Tag t = extractPlayerData(value, v))
				{
					switch (t)
					{
						case Elo:
							m_tags.add(tag == White ? WhiteElo : BlackElo, mstl::string(v, v.size()));
							break;

						case Country:
							m_tags.add(tag == White ? WhiteCountry : BlackCountry, mstl::string(v, v.size()));
							break;

						case Title:
							m_tags.add(tag == White ? WhiteTitle : BlackTitle, mstl::string(v, v.size()));
							break;

						case Sex:
							m_tags.add(tag == White ? WhiteSex : BlackSex, mstl::string(v, v.size()));
							break;

						case Human:
							m_tags.add(	tag == White ? WhiteType : BlackType,
											species::toString(species::Human));
							break;

						case Program:
							m_tags.add(	tag == White ? WhiteType : BlackType,
											species::toString(species::Program));
							break;

						case None:
							break;
					}

					// remove trailing chars
					while (!value.empty() && ::strchr(" .,", value.back()))
					{
						value.resize(value.size() - 1);

						if (value.empty())
							return true;
					}
				}
			}

			// standardize player names
			{
				mstl::string::size_type k = value.find_first_of(',');

				if (k != mstl::string::npos)
				{
					if (::isupper(value[k + 1]))
					{
						value.insert(k + 1, ' ');
					}
					else if (value[k + 1] == ' ' && value[k + 2] == ' ')
					{
						while (value[k + 2] == ' ')
							value.erase(k + 2, 1);
					}

					if (k > 1 && value[k - 1] == ' ' && value[k - 2] != ' ')
						value.erase(k - 1, 1);
				}

				while (value.size() > 1 && value.back() == '.')
					value.resize(value.size() - 1);
			}

			convertToUtf(value);
			break;

		case tag::Site:
			m_site = value;
			m_eventCountry = extractCountryFromSite(value);
			convertToUtf(value);
			break;

		case Round:
			{
				unsigned round;
				unsigned subround;

				if (!parseRound(value, round, subround))
				{
					warning(InvalidRoundTag, m_prevPos, value);
				}
				else
				{
					value.clear();

					if (subround)
						value.format("%u.%u", round, subround);
					else if (round)
						value.format("%u", round);
					else
						value = '?';
				}
			}
			break;

		case WhiteCountry:
		case BlackCountry:
			{
				country::Code code = country::fromString(value);

				if (code == country::Unknown)
				{
					warning(InvalidCountryCode, m_prevPos, value);
					return false;
				}

				value = country::toString(code);
			}
			break;

		case EventCountry:
			{
				country::Code code = country::fromString(value);

				if (code == country::Unknown)
				{
					warning(InvalidCountryCode, m_prevPos, value);
					return false;
				}

				convertToUtf(m_site);
				m_tags.set(tag::Site, m_site);
				m_eventCountry = code;
			}
			break;

		case EventType:
			if (!value.empty())
			{
				if (value.back() == ')')
				{
					char* s = const_cast<char*>(::strchr(value.c_str(), '('));

					if (!s)
						return false;

					mstl::string v;
					*(value.end() - 1) = '\0';
					v.hook(s + 1, (value.end() - 1) - (s + 1));

					switch (time::Mode mode = time::fromString(v))
					{
						case time::Unknown:
							warning(UnknownMode, m_prevPos, v);
							break;

						case time::Corr:
							m_tags.set(Mode, event::PaperMail);
							// fallthru

						default:
							m_tags.set(TimeMode, time::toString(mode));
							break;
					}

					while (s > value.c_str() && ::isspace(s[-1]))
						--s;

					if (s == value.c_str())
						return false;

					value.erase(s, value.end());
				}

				// strip values like "team-" or "team-tourn", but take into account that
				// an entry like "tourn-blitz" contains the time mode.
				mstl::string::size_type n = value.find_first_of('-');

				if (n != mstl::string::npos)
				{
					mstl::string v;
					v.hook(value.data() + n + 1, value.size() - n - 1);

					switch (time::Mode mode = time::fromString(v))
					{
						case time::Unknown:
							break;

						case time::Corr:
							m_tags.set(Mode, event::PaperMail);
							// fallthru

						default:
							m_tags.set(TimeMode, time::toString(mode));
							break;
					}

					value.erase(n, mstl::string::npos);
				}

				event::Type type = event::typeFromString(value);

				if (type == event::Unknown)
				{
					// It is not an event type. Then it should be a time mode entry.
					// (Bug or feature in ChessBase?)

					if (value != "?" && value != "-")
					{
						time::Mode mode = time::fromString(value);

						if (mode == time::Unknown)
						{
							warning(UnknownEventType, m_prevPos, value);
							m_tags.setExtra(tag::toName(tag), value);
							return false;
						}

						m_tags.set(TimeMode, time::toString(mode));
					}
				}

				value = event::toString(type);
			}
			break;

		case WhiteTitle:
		case BlackTitle:
			{
				title::ID title = title::fromString(value);

				if (title == title::None)
				{
					warning(UnknownTitle, m_prevPos, value);
					return false;
				}

				value = title::toString(title);
				m_tags.add(tag == WhiteTitle ? WhiteType : BlackType, "human");
			}
			break;

		case WhiteSex:
		case BlackSex:
			{
				sex::ID sex = sex::fromChar(value.c_str()[0]);	// safe access

				if (sex == sex::Unspecified)
				{
					switch (value.c_str()[0])
					{
						case 'c':
						case 'p':
							m_tags.add(tag == WhiteSex ? WhiteType : BlackType, "program");
							break;

						default:
							warning(UnknownSex, m_prevPos, value);
							return false;
					}
				}

				M_ASSERT(value == sex::toString(sex));
			}
			break;

		case SetUp:
			// what should we do? even value "0" doesn't make sense,
			// this stupid "SetUp" tag is superfluous and confusing.
			// we will set this flag later by our own.
			return false;

		case Fen:
			// make corrections in first part of FEN:
			// - replace punctuation with '/'
			// - remove zeroes
			for (mstl::string::iterator i = value.begin(); *i && !::isspace(*i); ++i)
			{
				if (::ispunct(*i))
					*i = '/';
				else if (*i == '0')
					i = value.erase(i, 1);
			}
			m_fenPos = m_prevPos;
			break;

		case tag::Date:
			{
				if (value.find_first_not_of("?.") != mstl::string::npos)
				{
					Date date;

					if (!date.parseFromString(value))
						warning(InvalidDateTag, m_prevPos, value);

					if (!date)
						return false;

					value = date.asString();
				}
				else
				{
					value.assign("????.??.??", 10);
				}
			}
			break;

		case EventDate:
			{
				if (value.find_first_not_of("?.") != mstl::string::npos)
				{
					Date date;

					if (!date.parseFromString(value))
						warning(InvalidEventDateTag, m_prevPos, value);

					if (!date)
						return false;

					value = date.asString();
				}
				else
				{
					value.assign("????.??.??", 10);
				}
			}
			break;

		case TimeControl:
			m_timeMode = getTimeModeFromTimeControl(value);
			break;

		case TimeMode:
			if (value.size() > 1)
			{
				time::Mode timeMode = time::fromString(value);

				if (timeMode == time::Unknown)
				{
					warning(InvalidTimeModeTag, m_prevPos, value);
					m_tags.setExtra(tag::toName(tag), value);
					return false;
				}
			}
			break;

		case tag::Eco:
			{
				Eco eco(value);

				if (!eco)
				{
					warning(InvalidEcoTag, m_prevPos, value);
					return false;
				}
			}
			break;

		case Result:
			{
				result::ID res = result::fromString(value);

				if (res == result::Unknown && (value.size() != 1 || value[0] != '*'))
				{
					m_tags.set(Result, "*");
					warning(InvalidResultTag, m_prevPos, value);
					m_noResult = true;
					return false;
				}

				value = result::toString(res);
			}
			break;

		case Variant:
			switch (value.size())
			{
				case 3:	if (::strcasecmp(value, "FRC") == 0)
								m_variant = variant::Chess960;
							break;
				case 4:	if (::strcasecmp(value, "SFRC") == 0); // Symmetrical Fischerandom
								m_variant = variant::Chess960;
							break;
				case 7:	if (::strcasecmp(value, "Shuffle") == 0)
								m_variant = variant::Shuffle;
							break;
				case 8:	if (::strcasecmp(value, "Chess960") == 0)
								m_variant = variant::Chess960;
							break;
				case 9:	if (	::strcasecmp(value, "Chess 960") == 0
								|| ::strcasecmp(value, "Chess-960") == 0)
							{
								m_variant = variant::Chess960;
							}
							break;
				case 12:	if (::strcasecmp(value, "Fischerandom") == 0)
								m_variant = variant::Chess960;
							else if (::strcasecmp(value, "ShuffleChess") == 0)
								m_variant = variant::Shuffle;
							break;
				case 13:	if (::strcasecmp(value, "Fischerrandom") == 0)
								m_variant = variant::Chess960;
							else if (::strcasecmp(value, "Shuffle Chess") == 0)
								m_variant = variant::Shuffle;
							else if (::strcasecmp(value, "Shuffle-Chess") == 0)
								m_variant = variant::Shuffle;
							break;
			}

			if (m_variant != variant::Chess960 && m_variant != variant::Shuffle)
				error(UnsupportedVariant, m_prevPos, value);	// TODO: warning is probably sufficient?

			m_variantPos = m_prevPos;
			return false;	// we will set this tag later by our own

		case tag::Termination:
			{
				termination::Reason reason = termination::fromString(value);

				if (reason == termination::Unknown)
				{
					static mstl::string const Resigned("resigned");
					static mstl::string const WonByResignation("won by resignation");

					if (::matchSuffix(value, Resigned) || ::matchSuffix(value, WonByResignation))
					{
						value = "normal";
					}
					else if (::strcasecmp(value, "unknown") == 0)
					{
						return false;
					}
					else if (value != "?" && value != "-")
					{
						value.strip();
						value.strip('-');

						reason = termination::fromString(value);

						if (reason == termination::Unknown)
						{
							warning(UnknownTermination, m_prevPos, value);
							m_tags.setExtra(tag::toName(tag), value);
							return false;
						}
					}
				}
			}
			break;

		case Mode:
			{
				event::Mode mode = event::modeFromString(value);

				if (mode == event::Undetermined && value != "?" && value != "-")
				{
					if (::strcasecmp(value, "unknown") != 0)
					{
						warning(UnknownMode, m_prevPos, value);
						m_tags.setExtra(tag::toName(tag), value);
					}

					return false;
				}
			}
			break;

		case WhiteDWZ:
		case BlackDWZ:
		case WhiteECF:
		case BlackECF:
		case WhiteElo:
		case BlackElo:
		case WhiteICCF:
		case BlackICCF:
		case WhiteIPS:
		case BlackIPS:
		case WhiteRapid:
		case BlackRapid:
		case WhiteRating:
		case BlackRating:
		case WhiteUSCF:
		case BlackUSCF:
			if (!value.empty())
			{
				if (::isElo(value.begin(), value.end()))
				{
					if (value[0] == '0')
						value.erase(size_t(0), size_t(1));

					int rat = ::strtoul(value, 0, 10);

					if (rat == 0)
					{
						m_tags.remove(tag);
					}
					else if (rat > rating::Max_Value)
					{
						m_tags.remove(tag);
						warning(RatingTooHigh, m_prevPos, value);
					}
				}
				else if (!::checkScore(value))
				{
					warning(InvalidRating, m_prevPos, value);
					return false;
				}
			}
			break;

		case Event:
		case Opening:
		case Variation:
		case SubVariation:
		case Annotator:
		case ExtraTag:
			convertToUtf(value);
			break;

#if 0
		case WhiteFideId:
		case BlackFideId:
			// TODO: name correction?!
			break;
#endif

		default:
			break;
	}

	return true;
}


void
PgnReader::addTag(tag::ID tag, mstl::string const& value)
{
	m_tags.set(tag, value);

	if (tag::isRatingTag(tag))
	{
		color::ID color = tag::isWhiteRatingTag(tag) ? color::White : color::Black;

		m_tags.setSignificance(tag, m_significance[color]);

		if (m_significance[color] > 0 && ++m_significance[color] > 2)
			m_significance[color] = 0;
	}
}


void
PgnReader::readTags()
{
	mstl::string name;
	mstl::string value;

	m_tags.clear();
	m_eventCountry = country::Unknown;

	while (true)
	{
		if (readTagName(name))
		{
			M_ASSERT(!name.empty());

			m_prevPos = m_currPos;
			readTagValue(value);
			value.trim();

			if (value.size() > 255)
			{
				warning(ValueTooLong, m_prevPos, value);
				value.set_size(255);
			}

			int c = get();

			while (::isspace(c))
				c = get();

			if (__builtin_expect(c != ']', 0))
				error(UnexpectedSymbol);

			tag::ID tag = fromName(name);

			if (m_modification == Raw)
			{
				if (tag == ExtraTag)
					m_tags.setExtra(name, value);
				else
					addTag(tag, value);
			}
			else if (checkTag(tag, value))
			{
				if (isMandatory(tag))
				{
					if (value.empty())
					{
						switch (tag)
						{
							case tag::Date:	value = "????.??.??"; break;
							case Result:		value = "*"; break;
							default:				value = "?"; break;
						}
					}
					m_tags.set(tag, value);
				}
				else if (value.size() > 1 || (value[0] != '?' && value[0] != '-'))
				{
					switch (tag)
					{
						case ExtraTag:
							// we will silently ignore all tags not starting
							// with an upper case character
							if (m_modification == Raw || ::isupper(name[0]))
							{
								bool ignore = false;

								if (m_modification == Normalize)
								{
									// ignore special tags from chessOK.com
									switch (name[0])
									{
										case 'G': ignore = (name == "GameID"); break;
										case 'I': ignore = (name == "Input"); break;
										case 'O': ignore = (name == "Owner"); break;
										case 'S': ignore = (name == "Stamp"); break;
										case 'U': ignore = (name == "UniqID"); break;

										case 'L':
											ignore = (name == "LastMoves");
											m_sourceIsChessOK = true;
											break;
									}
								}

								if (!ignore)
									m_tags.setExtra(name, value);
							}
							break;

						case WhiteType:
						case BlackType:
							if (m_modification == Normalize)
							{
								if (::isHuman(value.begin(), value.end()))
									m_tags.set(tag, species::toString(species::Human));
								else if (::isProgram(value.begin(), value.end()))
									m_tags.set(tag, species::toString(species::Program));
								else
									warning(UnknownPlayerType, m_prevPos, value);
							}
							break;

						default:
							addTag(tag, value);
							break;
					}
				}
			}
		}
		else
		{
			warning(InvalidTagName, m_prevPos, name);
		}

		skipLine();

		int c;

		do
			c = get();
		while (c == '\n');

		if (c != '[')
		{
			putback(c);

			if (m_modification == Normalize)
				checkTags();

			return;
		}

		name.clear();
		value.clear();
	}
}


bool
PgnReader::validateTagName(char* tag, unsigned len)
{
	while (len--)
	{
		char c = *tag;

		if (c == '\0')
			return true;

		// NOTE: Character '-' is not allowed due to the PGN specification, but
		// is used in some PGN games (e.g. PGN files from www.remoteschach.de).
		// We replace this character silently to be PGN conform.

		if (c == '-')
			*tag = '_';
		else if (!::isalnum(c))
			return false;
	}

	return true;
}


bool
PgnReader::readTagName(mstl::string& s)
{
	m_prevPos = m_currPos;

	int c = get();

	while (c == ' ' || c == '[')
		c = get(true);

	while (!::isspace(c) && c != ']' && c != '"')
	{
		s += char(c);
		c = get(true);
	}

	if (c == ']' || c == '"')
		putback(c);

	if (s.empty())
	{
		do
			skipLine();
		while ((c = get(true)) == '[');

		putback(c);
		error(TagNameExpected, m_prevPos);
	}

	return validateTagName(s.data(), s.size());
}


void
PgnReader::readTagValue(mstl::string& s)
{
	int c = get();

	while (::isspace(c))
		c = get();

	m_prevPos = m_currPos;

	if (c != '"')
		error(TagValueExpected);

	while (true)
	{
		c = get();

		switch (c)
		{
			case '\n':
				error(UnterminatedString, m_prevPos);
				// not reached

			case '"':
				putback(c = get());
				if (c == ']')
					return;
				c = '"';
				break;

			case '\\':
				{
					if ((c = get()) == '\n')
						error(UnterminatedString, m_prevPos);

					int c2 = get();
					putback(c2);

					if (c2 == ']')
						return;
				}
				break;
		}

		s += char(c);
	}
}


time::Mode
PgnReader::getTimeModeFromTimeControl(mstl::string const& value)
{
	mstl::string::size_type field = 0;

	unsigned seconds	= 0;
	unsigned moves		= 0;

	do
	{
		if (field >= value.size() || (value[field] != '*' && !::isdigit(value[++field])))
			return time::Unknown;

		unsigned nextDelim = value.find_first_of(':', field);
		unsigned n;

		if ((n = value.find_first_of('/', field)) < nextDelim)
		{
			moves += ::strtoul(value.c_str() + field, 0, 10);
			seconds += ::strtoul(value.c_str() + n + 1, 0, 10);
		}
		else
		{
			if (value[field] == '*')
				++field;

			seconds += ::strtoul(value.c_str() + field, 0, 10);

			if ((n = value.find_first_of('+', field)) < nextDelim)
			{
				unsigned increment = ::strtoul(value.c_str() + n + 1, 0, 10);
				seconds += mstl::max(0, 60 - int(moves))*increment;
			}
		}

		field = nextDelim;
	}
	while (field++ != mstl::string::npos);

	if (seconds == 0)
		return time::Unknown;

	// Bullet: 1 or 2 minutes per side.
	if (seconds <= 120)
		return time::Bullet;

	// Blitz:  All the moves must be made in a fixed time of less
	//         than 15 minutes for each player; or the allotted time
	//         + 60 times any increment is less than 15 minutes.
	if (seconds < 900)
		return time::Blitz;

	// Rapid:  15 to less than 60 minutes per player, or the
	//         allotted time + 60 times any increment is at least
	//         15 minutes, but less than 60 minutes for each player.
	if (seconds < 3600)
		return time::Rapid;

	return time::Normal;
}


void
PgnReader::setNullMove()
{
	putMove();
	m_move = Move::null();
}


void
PgnReader::putNag(nag::ID nag)
{
	M_ASSERT(nag < nag::Scidb_Last);

	if (!m_ignoreNags && !m_annotation.contains(nag) && !m_annotation.add(nag))
	{
		m_ignoreNags = true;
		warning(TooManyNags, m_prevPos);
	}

	m_hasNote = true;
}


void
PgnReader::putNag(nag::ID whiteNag, nag::ID blackNag)
{
	putNag(whiteToMove() ? blackNag : whiteNag);
}


PgnReader::Token
PgnReader::resultToken(result::ID result)
{
	if (m_firstGameNumber < 0)
		error(UnexpectedResultToken, m_prevPos);

	m_result = result;
	return kResult;
}


void
PgnReader::stripDiagram(mstl::string& comment)
{
	if (comment.empty())
		return;

	char const* s = comment.c_str();

	if (s[0] == '#' && (comment.size() == 1 || ::isspace(s[1])))
	{
		comment.erase(comment.begin(), ::skipSpaces(s + 1));
		m_annotation.add(nag::Diagram);
		m_hasNote = true;
	}
	else if (m_sourceIsPossiblyChessBase)
	{
		// ChessBase does not have any convention for diagram notation. Therefore we look for
		// any sequence "<word> {#}".
		while (::isalpha(*s))
			++s;
		while (*s == ' ' || *s == '\t')
			++s;

		if (::strncmp(s, "{#}", 3) != 0)
			return;

		comment.erase(comment.begin(), ::skipSpaces(s + 3));
		m_annotation.add(nag::Diagram);
		m_hasNote = true;
	}
}


PgnReader::Token
PgnReader::endOfInput(Token, int)
{
	return kEoi;
}


bool
PgnReader::doCastling(char const* castle)
{
	putMove();
	board().parseMove(castle, m_move, move::DontAllowIllegalMove);

	if (__builtin_expect(!m_move, 0))
	{
		// The most common type of "illegal" move in standard
		// chess is castling when the king or rook have already
		// moved. So if a castling move failed, turn off
		// strict checking of castling rights and try again,
		// but still print a warning if that succeeded.

		Board			board		= this->board();
		color::ID	side		= board.sideToMove();

		board.tryCastleShort(side);
		board.tryCastleLong(side);

		board.parseMove(castle, m_move, move::AllowIllegalMove);

		if (!m_move)
			return false;

		m_move.setIllegalMove();
		warning(IllegalCastling, m_prevPos, castle);
	}
	else if (!m_move.isLegal())
	{
		warning(IllegalMove, m_prevPos, castle);
	}

	return true;
}


PgnReader::Token
PgnReader::parseComment(Token prevToken, int c)
{
	// Comment: '{' ... '}'

	mstl::string content;

	m_prevPos = m_currPos;

	if (c == '{')
	{
		// parse comment until first '}'
		do
			c = get();
		while (::isspace(c));

		while (c != '}')
		{
			if (c == '\n' || c == '\r')
			{
				::appendSpace(content);

				do
					c = get();
				while (::isspace(c));
			}
			else
			{
				content += c;
				c = get();
			}
		}
	}
	else
	{
		// parse comment until end of line
		do
			c = get();
		while (::isspace(c) && c != '\n' && c != '\r');

		while (c && c != '\n' && c != '\r')
		{
			content += c;
			c = get();
		}

		while (c == '\r')
			c = get();

		if (c != '\n')
			putback(c);
	}

	if (m_marks.extractFromComment(content))
		m_hasNote = true;

	if (m_modification == Normalize)
	{
		content.trim();
		stripDiagram(content);

		switch (content.size())
		{
			case 0:
				return kComment;

			case 1:
				switch (content[0])
				{
					case 'N':
						if (prevToken & PartOfMove)
						{
							putNag(nag::Novelty);
							return kNag;
						}
						break;

					case 'D':
						if (!m_annotation.contains(nag::Diagram))
						{
							putNag(nag::Diagram);
							return kNag;
						}
						break;
				}
				break;

			case 2:
				switch (content[0])
				{
					case 'D':
						if (content[1] == '\'')
						{
							putNag(nag::DiagramFromBlack);
							return kNag;
						}
						break;

					case 'R':
						if (content[1] == 'R')
						{
							putNag(nag::EditorsRemark);
							return kNag;
						}
						break;
				}
				break;
		}

		if (content.empty())
			return kComment;

		if (m_sourceIsChessOK)
		{
			if (::parseChessOkComment(content))
			{
				Comment comment(content, false, false);
				m_hasNote = true;
				m_comments.push_back();
				m_comments.back().swap(comment);
				return kComment;
			}

			if (content.empty())
				return kComment;

			char const* s = content;

			while (::isdigit(*s))
				++s;
			while (*s == '.')
				++s;

			char const* p = s + 1;

			switch (*s)
			{
				case 'K': case 'Q': case 'R': case 'B': case 'N': case 'P':
					if (!('a' <= *p && *p <= 'h'))
						break;
					++p;
					// fallthru

				case 'a' ... 'h':
					if ('1' <= *p && *p <= '8' && p[1] == '\0')
					{
						mstl::string buf;

						buf.append("<xml><:>", 8);
						buf.append(content.begin(), s);
						buf.append("<sym>", 5);
						buf.append(*s);
						buf.append("</sym>", 6);
						buf.append(s + 1, content.end());
						buf.append('.');
						buf.append("</:></xml>", 10);

						Comment comment(buf, false, false);

						if (!m_comments.empty() && m_postIndex < m_comments.size())
						{
							m_comments.back().append(comment, ' ');
						}
						else
						{
							m_comments.push_back();
							m_comments.back().swap(comment);
							m_hasNote = true;
						}

						return kComment;
					}
					break;
			}
		}

		// Why the hell does Rybka Aquarium use comments for his annotation?
		// Obviously this company is not interested in the PGN standard.
		if (content[0] == '$')
		{
			char const* s = content.c_str() + 1;

			while (::isdigit(*s))
				++s;

			if (*s == '\0')
			{
				unsigned nag = ::strtoul(content.c_str() + 1, 0, 10);

				if (nag < nag::Pgn_Last)
				{
					putNag(nag::ID(nag));
					return kNag;
				}

				char const* phrase = 0;

				// Rybka Aquarium is using enumerated phrases.
				if (500 < nag && nag < 500 + U_NUMBER_OF(::Phrases500))
					phrase = ::Phrases500[nag - 500];
				else if (200 < nag && nag < 200 + U_NUMBER_OF(::Phrases200))
					phrase = ::Phrases200[nag - 200];

				if (phrase)
				{
					Comment comment(phrase, true, true);
					m_comments.push_back();
					m_comments.back().swap(comment);
					m_hasNote = true;
					return kComment;
				}
			}
		}
		else if (!::isalpha(content[0]) && content.size() <= 5)
		{
			nag::ID nag = nag::fromSymbol(content);

			if (nag != nag::Null)
			{
				if (::strlen(nag::toSymbol(nag)) == content.size())
				{
					putNag(nag::ID(nag));
					return kNag;
				}
			}
		}

		if (content.empty())
			return kComment;
	}

	Comment comment;

	if (m_modification != Raw || !comment.fromHtml(content))
	{
		convertToUtf(content);
		Comment::convertCommentToXml(
			content, comment, m_codec.isUtf8() ? encoding::Utf8 : encoding::Latin1);
		comment.normalize();
	}

	m_hasNote = true;
	m_comments.push_back();
	m_comments.back().swap(comment);

	return kComment;
}


PgnReader::Token
PgnReader::parseAsterisk(Token prevToken, int)
{
	// Null move: "*"	(after '(')
	// Result: "*"		(otherwise)

	m_prevPos = m_currPos;

	if (prevToken == kStartVariation)
	{
		// '*' is interpreted as null move (used in PalView)
		setNullMove();
		return kSan;
	}

	return resultToken(result::Unknown);
}


PgnReader::Token
PgnReader::parseApostrophe(Token prevToken, int c)
{
	// Move suffix: "'"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "'");

	putNag(nag::Without);
	return kNag;
}


PgnReader::Token
PgnReader::parseAtSign(Token prevToken, int)
{
	// Move suffix: "@"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "@");

	putNag(nag::WhiteHasAModerateTimeAdvantage, nag::BlackHasAModerateTimeAdvantage);
	return kNag;
}


PgnReader::Token
PgnReader::parseBackslash(Token prevToken, int c)
{
	// Move suffix: "\/"

	m_prevPos = m_currPos;

	if (!(prevToken & PartOfMove) || get() != '/')
		error(UnexpectedSymbol, m_prevPos, "\\");

	putNag(nag::AimedAgainst);
	return kNag;
}


PgnReader::Token
PgnReader::parseCaret(Token prevToken, int c)
{
	// Move suffix: "^^", "^_", "^=", "^"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "^");

	m_prevPos = m_currPos;

	switch (c = get())
	{
		case '^':
			putNag(nag::WhiteHasAPairOfBishops, nag::BlackHasAPairOfBishops);
			break;

		case '_':
			putNag(nag::BishopsOfOppositeColor);
			break;

		case '=':
			putNag(nag::BishopsOfSameColor);
			break;

		default:
			putback(c);
			putNag(nag::WhiteHasTheInitiative, nag::BlackHasTheInitiative);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseCastling(Token prevToken, int c)
{
	// Castling: [0O][-]?[0O]([-]?[0O])?
	// Move suffix: "O"

	m_prevPos = m_currPos;

	char* e = m_linePos;
	char const* castle = 0;

	if (*e == '-')
		e++;

	if (*e == '0' || *e == 'O')
	{
		e++;

		switch (*e++)
		{
			case '0':
			case 'O':
				castle = "O-O-O";
				break;

			case '-':
				switch (*e++)
				{
					case '0':
					case 'O':
						castle = "O-O-O";
						break;

					default:
						castle = "O-O";
						e -= 2;
						break;
				}
				break;

			default:
				castle = "O-O";
				e--;
				break;
		}
	}

	if (__builtin_expect(castle == 0, 0))
	{
		if ((prevToken & PartOfMove) && c == 'O')
		{
			putNag(nag::WhiteHasAModerateSpaceAdvantage, nag::BlackHasAModerateSpaceAdvantage);
			return kNag;
		}

		error(InvalidToken, m_prevPos, mstl::string(m_linePos - 1, e));
	}

	if (!doCastling(castle))
		error(InvalidMove, m_prevPos, mstl::string(m_linePos - 1, e));

	setLinePos(e);
	return kSan;
}


PgnReader::Token
PgnReader::parseCloseParen(Token, int)
{
	// End of variation; ")"

	m_prevPos = m_currPos;
	return kEndVariation;
}


PgnReader::Token
PgnReader::parseEqualsSign(Token prevToken, int)
{
	// Move prefix: "="
	// Move suffix: "=", "==", "=~", "=&", "=+", "=/+", "=/&", "=/~", "=/&", "=>", "=>/<="

	if (!(prevToken & PartOfMove))
	{
		m_prefixAnnotation = nag::EquivalentMove;
		return kMovePrefix;
	}

	char c = get();
	char d;

	switch (c)
	{
		case '=':
			putNag(nag::EqualChancesQuietPosition);
			break;

		case '~':
		case '&':
			putNag(nag::EqualChancesActivePosition);
			break;

		case '+':
			putNag(nag::BlackHasASlightAdvantage);
			break;

		case '/':
			switch (d = get())
			{
				case '&':
				case '~':
					putNag(	nag::WhiteHasSufficientCompensationForMaterialDeficit,
								nag::BlackHasSufficientCompensationForMaterialDeficit);
					break;

				case '+':
					putNag(nag::BlackHasASlightAdvantage);
					break;

				default:
					putback(d);
					putback(c);
					putNag(nag::DrawishPosition);
					break;
			}
			break;

		case '>':
			d = get();
			if (d == '/')
			{
				char e = get();
				if (e == '<')
				{
					char f = get();
					if (f == '=')
					{
						putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
						return kNag;
					}
					putback(f);
				}
				putback(e);
			}
			putback(d);
			putNag(nag::WhiteHasTheAttack, nag::BlackHasTheAttack);
			break;

		default:
			putback(c);
			putNag(nag::DrawishPosition);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseExclamationMark(Token prevToken, int)
{
	// Move suffix: "!", "!?", "!!"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "!");

	char c = get();

	switch (c)
	{
		case '!': putNag(nag::VeryGoodMove); break;
		case '?': putNag(nag::SpeculativeMove); break;

		default:
			putNag(nag::GoodMove);
			putback(c);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseGraveAccent(Token prevToken, int c)
{
	// Move suffix: "`"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "`");

	putNag(nag::Without);
	return kNag;
}


PgnReader::Token
PgnReader::parseGreaterThanSign(Token prevToken, int)
{
	// Move prefix: ">"
	// Move suffix: ">=", ">>", "><"

	if (prevToken & PartOfMove)
	{
		int c = get();

		switch (c)
		{
			case '=':
				m_prefixAnnotation = nag::BetterMove;
				return kNag;

			case '>':
				putNag(	nag::WhiteHasAModerateKingsideControlAdvantage,
							nag::BlackHasAModerateKingsideControlAdvantage);
				return kNag;

			case '<':
				putNag(nag::WeakPoint);
				return kNag;
		}

		putback(c);
	}

	m_prefixAnnotation = nag::BetterMove;
	return kMovePrefix;
}


PgnReader::Token
PgnReader::parseLessThanSign(Token prevToken, int)
{
	// Null move: "<>"
	// Move prefix: "<=", "<<"
	// Move suffix: "<=>", "<->", "<=/=>"
	// Skip: '<' ... '>' (but do not skip newlines)

	char c = get();
	char d;

	switch (c)
	{
		case '>':
			// "<>" is interpreted as null move (used in PalView)
			setNullMove();
			return kSan;

		case '=':
			d = get();
			switch (d)
			{
				case '>':
					putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
					return kNag;

				case '/':
					char e = get();
					if (e == '<')
					{
						char f = get();
						if (f == '=')
						{
							putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
							return kNag;
						}
						putback(f);
					}
					putback(e);
			}
			if ((d = get()) == '>')
			{
			}
			putback(d);
			m_prefixAnnotation = nag::WorseMove;
			return kMovePrefix;

		case '<':
			// NOTE: possibly we should use nag::Queenside
			putNag(	nag::WhiteHasAModerateQueensideControlAdvantage,
						nag::BlackHasAModerateQueensideControlAdvantage);
			return kNag;

		case '-':
			if ((d = get()) == '>')
			{
				putNag(nag::Line);
				return kNag;
			}
			putback(d);
			break;
	}

	// The PGN standard says that '<' is a token, although
	// it's reserved for future use.
	// We will skip until first '>', but only in current line.
	m_prevPos = m_currPos;

	do
	{
		if ((c = get()) == '\n')
			error(UnexpectedSymbol, m_prevPos, "<");
	}
	while (c != '>');

	return prevToken;
}


PgnReader::Token
PgnReader::parseLowercaseE(Token prevToken, int c)
{
	// Skip en passant: "ep", "e.p."

	if (prevToken & PartOfMove)
	{
		switch (m_linePos[0])
		{
			case 'p':
				if (!::isalnum(m_linePos[1]))
				{
					advanceLinePos(1);
					return prevToken;
				}
				break;

			case '.':
				if (m_linePos[1] == 'p' && m_linePos[2] == '.')
				{
					advanceLinePos(3);
					return prevToken;
				}
				break;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseLowercaseN(Token, int)
{
	// Null move: "null"

	m_prevPos = m_currPos;

	if (get() != 'u' && get() != 'l' && get() != 'l')
		error(UnexpectedSymbol, m_prevPos, "n");

	setNullMove();
	return kSan;
}


PgnReader::Token
PgnReader::parseLowercaseO(Token, int)
{
	// Move suffix: "o^", "oo", "o/o", "o.o", "o..o", "or"

	m_prevPos = m_currPos;

	switch (get())
	{
		case '^':
			putNag(nag::PassedPawn);
			break;

		case 'o':
			putNag(nag::DoublePawns);
			break;

		case 'r':
			putNag(nag::BetterMove);
			break;

		case '/':
			if (get() != 'o')
				error(UnexpectedSymbol, m_prevPos, "o/");
			putNag(nag::SeparatedPawns);
			break;

		case '.':
			switch (get())
			{
				case 'o':
					putNag(nag::UnitedPawns);
					break;

				case '.':
					if (get() != 'o')
						error(UnexpectedSymbol, m_prevPos, "o..");
					putNag(nag::UnitedPawns);
					break;

				default:
					error(UnexpectedSymbol, m_prevPos, "o.");
			}
			break;

		default:
			error(UnexpectedSymbol, m_prevPos, "o");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseLowercaseZ(Token prevToken, int)
{
	// kNag: "zz"

	m_prevPos = m_currPos;

	if (get() != 'z')
		error(UnexpectedSymbol, m_prevPos, "z");

	putNag(nag::WhiteIsInZugzwang, nag::BlackIsInZugzwang);
	return kNag;
}


PgnReader::Token
PgnReader::parseMinusSign(Token prevToken, int)
{
	// Move suffix: "-+", "--+", "--++" "-/+", "->", "->/<-"
	// Null move: "--" (used in ChessBase)

	m_prevPos = m_currPos;

	char c = get();
	char d;

	switch (c)
	{
		case '-':
			if (prevToken & PartOfMove)
			{
				if ((d = get()) == '+')
				{
					if ((d = get()) == '+')
					{
						putNag(nag::BlackHasACrushingAdvantage);
						return kNag;
					}
					putback(d);
					putNag(nag::BlackHasADecisiveAdvantage);
					return kNag;
				}
				putback(d);
			}
			setNullMove();
			return kSan;

		case '+':
			if (!(prevToken & PartOfMove))
				error(UnexpectedSymbol, m_prevPos, "-");
			putNag(nag::BlackHasADecisiveAdvantage);
			return kNag;

		case '/':
			if (!(prevToken & PartOfMove))
				error(UnexpectedSymbol, m_prevPos, "/");
			m_prevPos = m_currPos;
			if ((c = get()) != '+')
				error(InvalidToken, m_prevPos, ::trim(mstl::string("-") + '/' + char(c)));
			putNag(nag::BlackHasAModerateAdvantage);
			return kNag;

		case '>':
			if (!(prevToken & PartOfMove))
				error(UnexpectedSymbol, m_prevPos, ">");
			if ((d = get()) == '/')
			{
				char e = get();
				if (e == '<')
				{
					char f = get();
					if (f == '-')
					{
						putNag(nag::WhiteHasModerateCounterplay, nag::BlackHasModerateCounterplay);
						return kNag;
					}
					putback(f);
				}
				putback(e);
			}
			putback(d);
			putNag(nag::WhiteHasTheAttack, nag::BlackHasTheAttack);
			return kNag;
	}

	error(UnexpectedSymbol, m_prevPos, mstl::string(1, c));
	return prevToken;	// satisfies the compiler
}


PgnReader::Token
PgnReader::parseMove(Token prevToken, int c)
{
	m_prevPos = m_currPos;
	putMove();

	char const* e = board().parseMove(m_linePos - 1, m_move, move::AllowIllegalMove);

	if (__builtin_expect(e == 0, 0))
	{
		error(InvalidToken,
				m_prevPos,
				inverseFigurineMapping(mstl::string(m_linePos - 1, ::skipMoveToken(m_linePos))));
	}

	if (__builtin_expect(!m_move, 0))
	{
		error(InvalidMove,
				m_prevPos,
				inverseFigurineMapping(mstl::string(m_linePos - 1, e)));
	}

	if (__builtin_expect(!m_move.isLegal(), 0))
	{
		warning(	IllegalMove,
					m_prevPos,
					inverseFigurineMapping(mstl::string(m_linePos - 1, e)));
	}

	setLinePos(const_cast<char*>(e));
	return kSan;
}


PgnReader::Token
PgnReader::parseMoveNumber(Token prevToken, int)
{
	// Move number: [0-9]+[.]*

	char c;

	do
		c = get();
	while (::isdigit(c));

	while (c == '.')
		c = get();

	putback(c);
	return prevToken;
}


PgnReader::Token
PgnReader::parseNag(Token prevToken, int)
{
	// Nag value: [$][0-9]+

	if (__builtin_expect(!(prevToken & PartOfMove), 0))
		error(UnexpectedSymbol, "$");

	unsigned	nag = 0;
	char		c;

	m_prevPos = m_currPos;

	if (__builtin_expect(!::isdigit(c = get()), 0))
		error(InvalidToken, m_prevPos, ::trim(mstl::string("$") + char(c)));

	do
		nag = nag*10 + c - '0';
	while (::isdigit(c = get()));

	nag::ID myNag;

	if (	(myNag = nag::fromScid3(nag::ID(nag))) == nag::Null
		|| (myNag = nag::fromChessPad(nag::ID(nag))) == nag::Null)
	{
		warning(InvalidNag, m_prevPos, mstl::string("$") + ::itos(nag));
	}

	putNag(myNag);
	putback(c);
	return kNag;
}


PgnReader::Token
PgnReader::parseNumberZero(Token prevToken, int c)
{
	// Castling: [0O][-]?[0O]([-]?[0O])?
	//	Result: "0-1", "0:1", "0-0", "0:0"

	m_prevPos = m_currPos;
	char* s = m_linePos;

	switch (c = get())
	{
		case '-':
			switch (c = get())
			{
				case '1':
					return resultToken(result::Black);

				case '0':
					{
						switch (c = get(true))
						{
							case '\0':
								return resultToken(result::Lost);

							case '-':
								advanceLinePos(-2);
								return parseCastling(prevToken, '0');
						}

						if (m_tags.value(Result) == "0-0")
							return resultToken(result::Lost);

						if (doCastling("O-O"))
							return kSan;

						advanceLinePos(-2);
						error(InvalidMove, m_prevPos, "O-O");
					}
					break;

				case 'O':
					setLinePos(s);
					return parseCastling(prevToken, '0');
			}

			error(InvalidToken, m_prevPos, mstl::string(s, m_linePos));
			// not reached

		case ':':
			switch ((c = get()))
			{
				case '0':
					return resultToken(result::Lost);

				case '1':
					return resultToken(result::Black);
			}
			error(InvalidToken, m_prevPos, ::trim(mstl::string("0:") + char(c)));
			// not reached

		case 'O':
		case '0':
			putback(c);
			return parseCastling(prevToken, '0');
	}

	putback(c);
	return parseMoveNumber(prevToken, '0');
}


PgnReader::Token
PgnReader::parseNumberOne(Token prevToken, int c)
{
	// Result: "1-0", "1:0", "1/2-1/2", "1/2:1/2", "1/2"
	// Move number: [1][0-9]*[.]*

	char d;

	m_prevPos = m_currPos;

	switch (c = get())
	{
		case '-':
		case ':':
			if ((d = get()) == '0')
				return resultToken(result::White);
			error(InvalidToken, m_prevPos, ::trim(mstl::string("1") + char(c) + char(d)));
			// not reached

		case '/':
			if (((c = get()) != '2'))
				error(InvalidToken, m_prevPos, ::trim(mstl::string("1/") + char(c)));

			if ((c = get()) == '-' || c == ':')
			{
				d = get();

				if (d != '1' || get() != '/' || get() != '2')
					error(InvalidToken, m_prevPos, ::trim(mstl::string("1/2") + char(c) + d));
			}
			else
			{
				putback(c);
			}

			return resultToken(result::Draw);
	}

	putback(c);
	return parseMoveNumber(prevToken, '1');
}


PgnReader::Token
PgnReader::parsePlusSign(Token prevToken, int c)
{
	// (Double) check sign: "+", "++" (double check will be ignored)
	// Move suffix: "+-", "+--", "++--", "+/-", "+=", "+/="

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "+");

	m_prevPos = m_currPos;

	switch (c = get())
	{
		case '-':
			if ((c = get()) != '-')
				putback(c);
			putNag(nag::WhiteHasADecisiveAdvantage);
			prevToken = kNag;
			break;

		case '=':
			putNag(nag::WhiteHasASlightAdvantage);
			prevToken = kNag;
			break;

		case '/':
			switch (c = get())
			{
				case '-':	putNag(nag::WhiteHasAModerateAdvantage); break;
				case '=':	putNag(nag::WhiteHasASlightAdvantage); break;
				default:		error(InvalidToken, m_prevPos, ::trim(mstl::string("+") + '/' + char(c)));
			}

			prevToken = kNag;
			break;

		case '+':
			if ((c = get()) == '-')
			{
				if ((c = get()) != '-')
					error(InvalidToken, m_prevPos, "++-");

				putNag(nag::WhiteHasACrushingAdvantage);
				prevToken = kNag;
			}
			putback(c);
			// skip double check
			break;

		default:
			putback(c);
			break;
	}

	return prevToken;
}


PgnReader::Token
PgnReader::parseQuestionMark(Token prevToken, int c)
{
	// Move suffix: "?", "??", "?!"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "?");

	switch (c = get())
	{
		case '!': putNag(nag::QuestionableMove); break;
		case '?': putNag(nag::VeryPoorMove); break;

		default:
			putNag(nag::PoorMove);
			putback(c);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseOpenParen(Token prevToken, int)
{
	// Move suffix: "(.)", "(+)", "(?)", "()"
	// Start of variation

	if (prevToken & PartOfMove)
	{
		int c = get();

		if (c == ')')
		{
			putNag(nag::WhiteHasAModerateSpaceAdvantage, nag::BlackHasAModerateSpaceAdvantage);
			return kNag;
		}

		if (::strchr(".+-", c))
		{
			int d = get();

			if (d == ')')
			{
				switch (c)
				{
					case '.':
						putNag(nag::WhiteIsInZugzwang, nag::BlackIsInZugzwang);
						break;

					case '+':
						putNag(	nag::WhiteHasModerateTimeControlPressure,
									nag::BlackHasModerateTimeControlPressure);
						break;

					case '?':
						putNag(nag::QuestionableMove);
						break;
				}

				return kNag;
			}

			putback(d);
		}

		putback(c);
	}
	else if (!(prevToken & (kStartVariation | kEndVariation)))
	{
		error(UnexpectedSymbol, "(");
	}

	return kStartVariation;
}


PgnReader::Token
PgnReader::parseSlash(Token prevToken, int)
{
	// Move suffix: "/\", "/^", "//"

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, "/");

	m_prevPos = m_currPos;

	switch (get())
	{
		case '\\':	putNag(nag::WithTheIdea); break;
		case '^':	// fallthru
		case '/':	putNag(nag::Diagonal); break;
		default:		error(UnexpectedSymbol, m_prevPos, "/");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseTag(Token prevToken, int)
{
	// Move suffix: "[]", "[+]"
	// Start of Tag

	if (prevToken & PartOfMove)
	{
		int c = get();

		if (c == ']')
		{
			putNag(nag::SingularMove);
			return kNag;
		}
		else if (c == '+')
		{
			int d = get();

			if (d == ']')
			{
				// NOTE: possibly we should use nag::Center
				putNag(	nag::WhiteHasAModerateCenterControlAdvantage,
							nag::BlackHasAModerateCenterControlAdvantage);
				return kNag;
			}

			putback(d);
		}

		putback(c);
	}

	return kTag;
}


PgnReader::Token
PgnReader::parseTilde(Token prevToken, int c)
{
	// Move suffix: "~", "~~", "~&", "~/=" "&", "&&", "&~", "&/="

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, mstl::string(1, c));

	switch (char d = get())
	{
		case '/':
			{
				d = get();

				if (d == '=')
				{
					putNag(	nag::WhiteHasSufficientCompensationForMaterialDeficit,
								nag::BlackHasSufficientCompensationForMaterialDeficit);
				}
				else
				{
					putback(d);
				}
			}
			break;

		case '~':
			putNag(c == '~' ? nag::UnclearPosition : nag::EqualChancesActivePosition);
			break;

		case '&':
			putNag(c == '&' ? nag::UnclearPosition : nag::EqualChancesActivePosition);
			break;

		default:
			putback(d);
			putNag(nag::UnclearPosition);
			break;
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUnderscore(Token prevToken, int c)
{
	// Move suffix: "_|_", "_|"

	m_prevPos = m_currPos;

	if (!(prevToken & PartOfMove) || (get() != '|' && get() != '_'))
		error(UnexpectedSymbol, m_prevPos, "_");

	if ((c = get()) == '_')
	{
		putNag(nag::Endgame);
	}
	else
	{
		putback(c);
		putNag(nag::Without);
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUppercaseB(Token prevToken, int c)
{
	// Move prefix: "BB", "Bb"

	if (prevToken & PartOfMove)
	{
		switch (m_linePos[0])
		{
			case 'B':
				if (!::isalnum(m_linePos[1]))
				{
					putNag(nag::BishopsOfSameColor);
					advanceLinePos(1);
					return kNag;
				}
				break;

			case 'b':
				if (!::isalnum(m_linePos[1]))
				{
					putNag(nag::BishopsOfOppositeColor);
					advanceLinePos(1);
					return kNag;
				}
				break;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseD(Token, int)
{
	// Diagram symbol "D", "D'"

	char c = get();

	if (c == '\'')
	{
		putNag(nag::DiagramFromBlack);
	}
	else
	{
		putNag(nag::Diagram);
		putback(c);
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseUppercaseN(Token prevToken, int c)
{
	// Move prefix: "N"

	if (prevToken & PartOfMove)
	{
		if (!::isalnum(m_linePos[0]))
		{
			putNag(nag::Novelty);
			return kNag;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseR(Token prevToken, int c)
{
	// Move prefix: "RR"

	if (prevToken & PartOfMove)
	{
		if (m_linePos[0] == 'R')
		{
			m_prefixAnnotation = nag::EditorsRemark;
			advanceLinePos(1);
			return kMovePrefix;
		}
	}

	return parseMove(prevToken, c);
}


PgnReader::Token
PgnReader::parseUppercaseZ(Token prevToken, int c)
{
	// Null move: "Z0" (used in Chess Assistant)

	if (m_linePos[0] != '0')
		return unexpectedSymbol(prevToken, c);

	advanceLinePos(1);
	setNullMove();
	return kSan;
}


PgnReader::Token
PgnReader::parseVerticalBar(Token prevToken, int)
{
	// Move suffix: "|^", "||", "|_"

	m_prevPos = m_currPos;

	if (!(prevToken & PartOfMove))
		error(UnexpectedSymbol, m_prevPos, "|");

	switch (get())
	{
		case '^':
			putNag(nag::WhiteHasTheInitiative, nag::BlackHasTheInitiative);
			break;

		case '/':
			putNag(nag::File);
			break;

		case '_':
			putNag(nag::With);
			break;

		default:
			error(UnexpectedSymbol, m_prevPos, "|");
	}

	return kNag;
}


PgnReader::Token
PgnReader::parseWeakPoint(Token, int)
{
	putNag(nag::WeakPoint);
	return kNag;
}


PgnReader::Token
PgnReader::skipDot(Token prevToken, int)
{
	// ignore '.'
	return prevToken;
}


PgnReader::Token
PgnReader::skipComment(Token prevToken, int c)
{
	// ignore comment until end of line

	do
		c = get();
	while (c && c != '\n');

	return prevToken;
}


PgnReader::Token
PgnReader::skipMateSymbol(Token prevToken, int)
{
	if (!(prevToken & kSan))
		error(UnexpectedSymbol, "#");

	return prevToken;
}


PgnReader::Token
PgnReader::skipWhiteSpace(Token prevToken, int)
{
	return prevToken;
}


PgnReader::Token
PgnReader::unexpectedSymbol(Token prevToken, int c)
{
	if (!(prevToken & kSan))
		error(UnexpectedSymbol, m_currPos, mstl::string(::isprint(c) ? 1 : 0, c));

	putback(c);
	return kError;
}


PgnReader::Token
PgnReader::nextToken(Token prevToken)
{
	typedef Token (PgnReader::*Meth)(Token, int);

	static Meth const Trampolin[128] =
	{
		/*   0    */ &PgnReader::endOfInput,
		/*   1    */ &PgnReader::unexpectedSymbol,
		/*   2    */ &PgnReader::unexpectedSymbol,
		/*   3    */ &PgnReader::unexpectedSymbol,
		/*   4    */ &PgnReader::unexpectedSymbol,
		/*   5    */ &PgnReader::unexpectedSymbol,
		/*   6    */ &PgnReader::unexpectedSymbol,
		/*   7 \a */ &PgnReader::unexpectedSymbol,
		/*   8 \b */ &PgnReader::unexpectedSymbol,
		/*   9 \t */ &PgnReader::skipWhiteSpace,
		/*  10 \n */ &PgnReader::skipWhiteSpace,
		/*  11 \v */ &PgnReader::skipWhiteSpace,
		/*  12 \f */ &PgnReader::skipWhiteSpace,
		/*  13 \r */ &PgnReader::skipWhiteSpace,
		/*  14    */ &PgnReader::unexpectedSymbol,
		/*  15    */ &PgnReader::unexpectedSymbol,
		/*  16    */ &PgnReader::unexpectedSymbol,
		/*  17    */ &PgnReader::unexpectedSymbol,
		/*  18    */ &PgnReader::unexpectedSymbol,
		/*  19    */ &PgnReader::unexpectedSymbol,
		/*  20    */ &PgnReader::unexpectedSymbol,
		/*  21    */ &PgnReader::unexpectedSymbol,
		/*  22    */ &PgnReader::unexpectedSymbol,
		/*  23    */ &PgnReader::unexpectedSymbol,
		/*  24    */ &PgnReader::unexpectedSymbol,
		/*  25    */ &PgnReader::unexpectedSymbol,
		/*  26    */ &PgnReader::unexpectedSymbol,
		/*  27    */ &PgnReader::unexpectedSymbol,
		/*  28    */ &PgnReader::unexpectedSymbol,
		/*  29    */ &PgnReader::unexpectedSymbol,
		/*  30    */ &PgnReader::unexpectedSymbol,
		/*  31    */ &PgnReader::unexpectedSymbol,
		/*  32 SP */ &PgnReader::skipWhiteSpace,
		/*  33 !  */ &PgnReader::parseExclamationMark,
		/*  34 "  */ &PgnReader::unexpectedSymbol,
		/*  35 #  */ &PgnReader::skipMateSymbol,
		/*  36 $  */ &PgnReader::parseNag,
		/*  37 %  */ &PgnReader::skipComment,
		/*  38 &  */ &PgnReader::parseTilde,
		/*  39 '  */ &PgnReader::parseApostrophe,
		/*  40 (  */ &PgnReader::parseOpenParen,
		/*  41 )  */ &PgnReader::parseCloseParen,
		/*  42 *  */ &PgnReader::parseAsterisk,
		/*  43 +  */ &PgnReader::parsePlusSign,
		/*  44 ,  */ &PgnReader::unexpectedSymbol,
		/*  45 -  */ &PgnReader::parseMinusSign,
		/*  46 .  */ &PgnReader::skipDot,
		/*  47 /  */ &PgnReader::parseSlash,
		/*  48 0  */ &PgnReader::parseNumberZero,
		/*  49 1  */ &PgnReader::parseNumberOne,
		/*  50 2  */ &PgnReader::parseMoveNumber,
		/*  51 3  */ &PgnReader::parseMoveNumber,
		/*  52 4  */ &PgnReader::parseMoveNumber,
		/*  53 5  */ &PgnReader::parseMoveNumber,
		/*  54 6  */ &PgnReader::parseMoveNumber,
		/*  55 7  */ &PgnReader::parseMoveNumber,
		/*  56 8  */ &PgnReader::parseMoveNumber,
		/*  57 9  */ &PgnReader::parseMoveNumber,
		/*  58 :  */ &PgnReader::unexpectedSymbol,
		/*  59 ;  */ &PgnReader::parseComment,
		/*  60 <  */ &PgnReader::parseLessThanSign,
		/*  61 =  */ &PgnReader::parseEqualsSign,
		/*  62 >  */ &PgnReader::parseGreaterThanSign,
		/*  63 ?  */ &PgnReader::parseQuestionMark,
		/*  64 @  */ &PgnReader::parseAtSign,
		/*  65 A  */ &PgnReader::unexpectedSymbol,
		/*  66 B  */ &PgnReader::parseUppercaseB,
		/*  67 C  */ &PgnReader::unexpectedSymbol,
		/*  68 D  */ &PgnReader::parseUppercaseD,
		/*  69 E  */ &PgnReader::unexpectedSymbol,
		/*  70 F  */ &PgnReader::unexpectedSymbol,
		/*  71 G  */ &PgnReader::unexpectedSymbol,
		/*  72 H  */ &PgnReader::unexpectedSymbol,
		/*  73 I  */ &PgnReader::unexpectedSymbol,
		/*  74 J  */ &PgnReader::unexpectedSymbol,
		/*  75 K  */ &PgnReader::parseMove,
		/*  76 L  */ &PgnReader::unexpectedSymbol,
		/*  77 M  */ &PgnReader::unexpectedSymbol,
		/*  78 N  */ &PgnReader::parseUppercaseN,
		/*  79 O  */ &PgnReader::parseCastling,
		/*  80 P  */ &PgnReader::parseMove,
		/*  81 Q  */ &PgnReader::parseMove,
		/*  82 R  */ &PgnReader::parseUppercaseR,
		/*  83 S  */ &PgnReader::unexpectedSymbol,
		/*  84 T  */ &PgnReader::unexpectedSymbol,
		/*  85 U  */ &PgnReader::unexpectedSymbol,
		/*  86 V  */ &PgnReader::unexpectedSymbol,
		/*  87 W  */ &PgnReader::unexpectedSymbol,
		/*  88 X  */ &PgnReader::parseWeakPoint,
		/*  89 Y  */ &PgnReader::unexpectedSymbol,
		/*  90 Z  */ &PgnReader::parseUppercaseZ,
		/*  91 [  */ &PgnReader::parseTag,
		/*  92 \  */ &PgnReader::parseBackslash,
		/*  93 ]  */ &PgnReader::unexpectedSymbol,
		/*  94 ^  */ &PgnReader::parseCaret,
		/*  95 _  */ &PgnReader::parseUnderscore,
		/*  96 `  */ &PgnReader::parseGraveAccent,
		/*  97 a  */ &PgnReader::parseMove,
		/*  98 b  */ &PgnReader::parseMove,
		/*  99 c  */ &PgnReader::parseMove,
		/* 100 d  */ &PgnReader::parseMove,
		/* 101 e  */ &PgnReader::parseLowercaseE,
		/* 102 f  */ &PgnReader::parseMove,
		/* 103 g  */ &PgnReader::parseMove,
		/* 104 h  */ &PgnReader::parseMove,
		/* 105 i  */ &PgnReader::unexpectedSymbol,
		/* 106 j  */ &PgnReader::unexpectedSymbol,
		/* 107 k  */ &PgnReader::unexpectedSymbol,
		/* 108 l  */ &PgnReader::unexpectedSymbol,
		/* 109 m  */ &PgnReader::unexpectedSymbol,
		/* 110 n  */ &PgnReader::parseLowercaseN,
		/* 111 o  */ &PgnReader::parseLowercaseO,
		/* 112 p  */ &PgnReader::unexpectedSymbol,
		/* 113 q  */ &PgnReader::unexpectedSymbol,
		/* 114 r  */ &PgnReader::unexpectedSymbol,
		/* 115 s  */ &PgnReader::unexpectedSymbol,
		/* 116 t  */ &PgnReader::unexpectedSymbol,
		/* 117 u  */ &PgnReader::unexpectedSymbol,
		/* 118 v  */ &PgnReader::unexpectedSymbol,
		/* 119 w  */ &PgnReader::unexpectedSymbol,
		/* 120 x  */ &PgnReader::parseWeakPoint,
		/* 121 y  */ &PgnReader::unexpectedSymbol,
		/* 122 z  */ &PgnReader::parseLowercaseZ,
		/* 123 {  */ &PgnReader::parseComment,
		/* 124 |  */ &PgnReader::parseVerticalBar,
		/* 125 }  */ &PgnReader::unexpectedSymbol,
		/* 126 ~  */ &PgnReader::parseTilde,
		/* 127    */ &PgnReader::unexpectedSymbol,
	};

	prevToken |= kOutDated;

	while (true)
	{
		unsigned char c = get();

		if (__builtin_expect(c & 0x80, 0))
			unexpectedSymbol(prevToken, c);

		if ((prevToken = (this->*Trampolin[c])(prevToken, c)) <= kError)
			return prevToken;
	}

	return kEoi;	// satisfies the compiler
}


bool
PgnReader::parseRound(mstl::string const& data, unsigned& round, unsigned& subround)
{
	char* s = const_cast<char*>(data.c_str());

	if (*s == '?' || *s == '-')
	{
		round = subround = 0;
	}
	else
	{
		if (*s == '(')
			++s;
		while (*s == '0')
			++s;

		if (::isdigit(*s))
		{
			round = ::strtoul(s, &s, 10);

			if (round > 255)
			{
				round = subround = 0;
				return false;
			}
		}
		else if (s == data.c_str() || s[-1] != '0')
		{
			round = subround = 0;
			return false;
		}
		else
		{
			round = subround = 0;
			return true;
		}

		if (*s == '.')
		{
			subround = ::strtoul(s + 1, &s, 10);

			if (subround > 255)
			{
				subround = 0;
				return false;
			}

			if (*s == '.')
			{
				round = subround;
				subround = ::strtoul(s + 1, &s, 10);

				if (subround > 255)
				{
					round = subround = 0;
					return false;
				}
			}

			if (*s == ')' && data[0] == '(')
				++s;

			if (*s)
			{
				round = subround = 0;
				return false;
			}
		}
		else
		{
			subround = 0;
		}
	}

	return true;
}


country::Code
PgnReader::extractCountryFromSite(mstl::string& data)
{
	if (data.size() < 3)
		return country::Unknown;

	country::Code country;

	if (data[0] == 'I')
	{
		switch (data[1])
		{
			case 'n':
				if (::strncmp(data, "Internet", 8) == 0 && ::isdelim(data[8]))
					return country::The_Internet;
				break;

			case 'N':
				if (data[2] == 'T' && ::isdelim(data[3]))
					return country::The_Internet;
				break;
		}
	}

	char* e = data.end() - 1;
	char* s;

	if (*e == ')')
	{
		s = e - 3;

		if (s < data.begin())
			return country::Unknown;

		if (*s == '(')
		{
			if ((country = country::fromString(s + 1)) == country::Unknown)
				return country::Unknown;
		}
		else if (s[1] == '(' || s[2] == '(')
		{
			return country::Unknown;
		}
		else
		{
			while (*s != '(')
			{
				if (s == data.begin())
					return country::Unknown;

				--s;
			}

			mstl::string str;
			str.hook(s + 1, e - s - 1);
			*e = '\0';
			country = Site::findCountryCode(str);
			*e = ')';

			if (country == country::Unknown)
				return country::Unknown;
		}
	}
	else
	{
		s = e - 2;

		if (s < data.begin())
			return country::Unknown;

		if (s == data.begin())
			return country::fromString(s);

		if (::isspace(s[-1]))
		{
			if ((country = country::fromString(s)) == country::Unknown)
				return country::Unknown;
		}
		else
		{
			while (*s != ',')
			{
				if (s == data.begin() || *s == '/')
					return country::Unknown;

				--s;
			}

			++s;
			while (::isspace(*s))
				++s;

			mstl::string str;
			str.hook(s, e - s + 1);

			if ((country = Site::findCountryCode(str)) == country::Unknown)
				return country::Unknown;
		}
	}

	if (s > data.begin())
	{
		--s;

		while (s > data.begin() && ::isspace(*s))
			--s;

		if (*s == '/')
			return country::Unknown;

		if (*s == ',')
		{
			--s;

			while (s > data.begin() && ::isspace(*s))
				--s;
		}

		data.set_size(s - data.begin() + 1);
	}

	return country;
}


PgnReader::Tag
PgnReader::extractPlayerData(mstl::string& data, mstl::string& value)
{
	if (data.size() <= 5)
		return None;

	if (data.back() == ')')
	{
		mstl::string::size_type k = data.find_last_of('(');

		if (k != mstl::string::npos)
		{
			char* s = data.begin() + k + 1;
			char* e = data.end() - 1;

			while (::isspace(*e))
				--e;
			while (::isspace(*s))
				++s;

			if (s < e)
			{
				if (::isElo(s, e) && strtoul(s, 0, 10) <= rating::Max_Value)
				{
					if (*s == '0')
						value.hook(s + 1, e - (s + 1));
					else
						value.hook(s, e - s);
					::removeValue(data, s, '(');
					return Elo;
				}

				if (::isCountry(s, e))
				{
					value.hook(s, e - s);
					::removeValue(data, s, '(');
					return Country;
				}

				if (::isTitle(s, e))
				{
					value.hook(s, e - s);
					::removeValue(data, s, '(');
					return Title;
				}

				if (::isHuman(s, e))
				{
					::removeValue(data, s, '(');
					return Human;
				}

				if (::isSex(s, e))
				{
					::removeValue(data, s, '(');
					return Sex;
				}

				if (::isProgram(s, e))
				{
					::removeValue(data, s, '(');
					return Program;
				}
			}
		}
	}
	else if (::isupper(data.back()))
	{
		char* s = data.end() - 3;
		char* e = data.end();

		if (::isspace(s[-1]))
		{
			if (::isCountry(s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
				return Country;
			}

			if (::isTitle(s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
				return Title;
			}
		}

		if (::isspace(s[0]))
		{
			if (::isTitle(++s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
				return Title;
			}
		}
	}

	return None;
}


event::Mode
PgnReader::getEventMode(char const* event, char const* site)
{
	event::Mode mode = event::Undetermined;

	switch (event[0])
	{
		case 'F':
			if (::strncmp(event, "FICGS_", 6) == 0)
				mode = event::PaperMail;
			break;

		case 'w':
			if (::strncmp(event, "www.", 4) == 0)
				mode = event::Internet;
			break;

		case 'e':
			if (::strncmp(event, "email", 5) == 0 && ::isdelim(event[5]))
				mode = event::Email;
			break;
	}

	if (mode == event::Undetermined)
	{
		switch (site[0])
		{
			case 'A':
				if (::strncmp(site, "AJEC", 4) == 0 && ::isdelim(site[4]))
					mode = event::PaperMail;
				break;

			case 'B':
				if ((site[1] == 'd' || site[1] == 'D') && site[2] == 'F' && ::isdelim(event[3]))
					mode = event::PaperMail;
				break;

			case 'C':
				switch (site[1])
				{
					case 'C':
						if (::strncmp(site, "CCLA", 4) == 0 && ::isdelim(site[4]))
					mode = event::PaperMail;
						break;

					case 'o':
						if (site[2] == 'r' && site[3] == 'r')
						{
							if (::isdelim(site[4]) || ::strncmp(site + 4, "espondence", 10) == 0)
								mode = event::PaperMail;
						}
						break;
				}
				break;

			case 'D':
				switch (site[1])
				{
					case 'E':
						if (::strncmp(site, "DESC", 4) == 0 && ::isdelim(site[4]))
							mode = event::Email;
						break;

					case 'I':
						if (::strncmp(site, "DICS", 4) == 0 && ::isdelim(site[4]))
							mode = event::Email;
						break;
				}
				break;

			case 'F':
				if (::strncmp(site, "FICGS", 5) == 0 && ::isdelim(site[5]))
					mode = event::PaperMail;
				break;

			case 'I':
				switch (site[1])
				{
					case 'C':
						if (::strncmp(site, "ICCF", 4) == 0 && ::isdelim(site[4]))
							mode = event::PaperMail;
					break;

					case 'E':
						if (	(::strncmp(site, "IECC", 4) == 0 || ::strncmp(site, "IECG", 4) == 0)
							&& ::isdelim(site[4]))
						{
							mode = event::Email;
						}
						break;
				}
				break;

			case 'U':
				switch (site[1])
				{
					case 'E':
						if (::strncmp(site, "UECC", 4) == 0 && ::isdelim(site[4]))
							mode = event::Email;
						break;

					case 'S':
						if (::strncmp(site, "USCF", 4) == 0 && ::isdelim(site[4]))
							mode = event::PaperMail;
						break;
				}
				break;

			case 'W':
				if (::strncmp(site, "WCCF", 4) == 0 && ::isdelim(site[4]))
					mode = event::PaperMail;
				break;
		}
	}

	return mode;
}


void
PgnReader::replaceFigurineSet(char const* fromSet, char const* toSet, mstl::string& str)
{
	char* s = str.begin();
	char* e = str.end();

	while (s < e)
	{
		if (m_parsingComment)
		{
			if (*s == '}')
				m_parsingComment = false;

			++s;
		}
		else if (::isalpha(*s))
		{
			char* p = const_cast<char*>(::strchr(toSet, *s));

			if (p && p - toSet < 5)
			{
				// parse: [KQRBN]([a-h][1-8])?[x:-]?[a-h][1-8]

				char*	t			= s + 1;
				bool	needFyle	= true;

				switch (::CharToType[Byte(*t)])
				{
					case ::Fyle:
						needFyle = false;
						++t;
						break;

					case ::Rank:
						++t;
						break;
				}

				if (::CharToType[Byte(*t)] == ::Capture)
				{
					++t;
					needFyle = true;
				}

				if (::CharToType[Byte(*t)] == ::Fyle)
				{
					++t;
					needFyle = false;
				}

				if (!needFyle && ::CharToType[Byte(*t)] == ::Rank)
				{
					M_ASSERT(p - toSet < 6);
					*s = fromSet[p - toSet];
					s = t + 1;
				}
				else
				{
					++s;
				}
			}
			else
			{
				if (p)
					++s;

				if (::CharToType[Byte(*s)] == ::Fyle)
				{
					// parse: [a-h][x:-]?[2-7]
					// parse: [a-h][18][=]?QRBN
					// parse: [a-h][18][=]?[(][QRBN][)]

					char*	t = s + 1;

					if (::CharToType[Byte(*t)] == ::Capture)
						++t;

					if (::CharToType[Byte(*t)] == ::Rank)
					{
						s = t + 1;

						if (*t == '1' || *t == '8')
						{
							bool delim = false;

							if (*t == '=')
								++t;

							if (*t == '(')
							{
								++t;
								delim = true;
							}

							if ((p = const_cast<char*>(::strchr(toSet, *t))))
							{
								int index = p - toSet;

								if (!delim || t[1] == ')')
								{
									*t = fromSet[index];
									t += (delim ? 2 : 1);
								}
							}

							s = t;
						}
					}
					else
					{
						++s;
					}
				}
				else if (p == 0)
				{
					++s;
				}
			}
		}
		else
		{
			if (*s == ';')
				return;

			if (*s == '{')
				m_parsingComment = true;

			++s;
		}
	}
}

// vi:set ts=3 sw=3:
