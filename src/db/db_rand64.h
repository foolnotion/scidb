// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_rand64_included
#define _db_rand64_included

#include "db_common.h"

namespace db {
namespace rand64 {

enum
{
	Num_Pieces					= db::piece::Last + 1,

	Num_Pieces_Entries		= Num_Pieces*64,
	Num_Promoted_Entries		= Num_Pieces*64,
	Num_Holding_Entries		= Num_Pieces,
	Num_Castling_Entries		= 4,
	Num_EnPassant_Entries	= 16,
	Num_ToMove_Entries		= 1,
	Num_ChecksGiven_Entries	= 8,

	Num_Total_Entries			= Num_Pieces_Entries
									+ Num_Promoted_Entries
									+ Num_Holding_Entries
									+ Num_Castling_Entries
									+ Num_EnPassant_Entries
									+ Num_ToMove_Entries
									+ Num_ChecksGiven_Entries,
};

uint64_t const RandomTable	[Num_Total_Entries] =
{
#define U64 UINT64_C
	// ================== PIECES ======================================================================

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// WhiteKing -----------------------------------------------------------------=--------------------
	U64(0x1ec62f17201666a9), U64(0xbbfacfa8b9cedc99), U64(0xd52582ca4006e48d), U64(0xbe5cc29389b0a011),
	U64(0x70b7b299fa084b79), U64(0x31fc91d4b888aac6), U64(0x953d8d65f16a27f5), U64(0xa9e1894a083988a6),

	U64(0x21454de44a9c3b61), U64(0x5f8b1149ed761b1d), U64(0x175d8e3320bc756e), U64(0xdf290612a1c03992),
	U64(0xe8eb7e4dd25319a8), U64(0x0af4b12ca66fd9c4), U64(0xbc7a46849f1ecb92), U64(0x3176f59e6d590325),

	U64(0xba1dd7cef5e19864), U64(0x66354050f7debe97), U64(0xa9bf0a169bacd362), U64(0x6fbcab3c9569da6c),
	U64(0xf776879f9737354a), U64(0x1bb627864a4de101), U64(0x7e0e89ff7ed651a4), U64(0xd60fbbffa2bc218e),

	U64(0x9fae83ea899cdc65), U64(0xe968a74b29e28a00), U64(0x7441d6653deb9005), U64(0x0114e67f4d201286),
	U64(0xb570a88f1bb4a04f), U64(0x979a9ed22e05d8f5), U64(0x5c07b95482adfa30), U64(0x895a9ebc0f0425f9),

	U64(0xeb9c39059e157744), U64(0x56eaba15345d2d3f), U64(0xe16e06e1d7ecc810), U64(0x36e6163492b22bd2),
	U64(0xb16091b81a2e4d3f), U64(0x457ccde451eb1bc7), U64(0x84d57d447975de25), U64(0x9f9e74faa2ad3bd3),

	U64(0x24c7ae8acd3ad30d), U64(0xa3cbda8eb6cd6d17), U64(0x92d9ee42cbfa4f52), U64(0x438f893e666ffa6b),
	U64(0x3ccc5d24464f62b1), U64(0xcfa9275812d9e5db), U64(0xbbf17284897c0f48), U64(0xa077f2f8f190127b),

	U64(0x5fdeec8850464c2b), U64(0x9429d7f4c15885f4), U64(0x4dcac2831e23e842), U64(0x4e109f15c27a18bf),
	U64(0x8999f31dcc6fe7a9), U64(0x38d5a8a6044dd9ee), U64(0xa744dd883d5c7225), U64(0xeeb12aaf9f92ef25),

	U64(0xb1b218b1bb67cf61), U64(0xe83e436e7362d9de), U64(0x537512d7cdb2153b), U64(0xd6483b5692e687aa),
	U64(0x6b0a45a3318c51d5), U64(0x226771aa9189c198), U64(0x53235ce529bfd016), U64(0x5ca80b4f2d5e1eb6),

	// WhiteQueen -------------------------------------------------------------------------------------
	U64(0x53245edcd60cf397), U64(0x7f6a708b5e8c84a4), U64(0x0325e8b4fb9a1aa4), U64(0x14887c78f2a09203),
	U64(0xc2bb16d21c0bc8cc), U64(0xe055caaa118766fc), U64(0x359748cb791ec67d), U64(0x3b61d875ea2b7561),

	U64(0x2a1b6c8960df15e0), U64(0x9bf0d7a44740e32f), U64(0xc22bf6c21eee246f), U64(0xc020519cb401d072),
	U64(0x0f0968c3468e10e2), U64(0xac96e408328061cb), U64(0x7f7777aa95130c9b), U64(0x6ce2af6150e0495a),

	U64(0xabf54956d8e7b2ae), U64(0x5d61b62788db096f), U64(0x1dd0995e3a3833f6), U64(0x4830b9ec0a52efea),
	U64(0x4b6deac9ba54aed7), U64(0xd8a5b2d82eb070ef), U64(0x0c78f51efd50a99d), U64(0xb2d750e4cc381595),

	U64(0xcc5a3d6cc8412cf9), U64(0x716449e782e7c15e), U64(0x60971d4c2dd8a2de), U64(0xd181dae3d9e17d00),
	U64(0x0a51553f160a644a), U64(0x33c2e7d569cfe4ff), U64(0xf5463eadaa35d7b1), U64(0x8597d849d5df0697),

	U64(0x54673596ef45e29f), U64(0x2753a9185702bdec), U64(0x68edde16eb851e87), U64(0xe63abaa5324431d8),
	U64(0x238e3822a5480bbf), U64(0x569dfbff9e7a3228), U64(0x583d319124ecc023), U64(0x174c93c203e706ca),

	U64(0x75515b06b221631f), U64(0xa3c0046d21d3937a), U64(0x786176c17d7255e2), U64(0x7fe7b6e3fee8447b),
	U64(0x36b33d94116aa3d6), U64(0xa540f2adc881ad04), U64(0xc8e77cabc847bb78), U64(0x3bb391ff43276713),

	U64(0x9195bbff45b7f7e2), U64(0x79019d67f09cbcc8), U64(0xa8f17ad8e5ff080e), U64(0x345b6fbbb3a98cd3),
	U64(0x280ec7eb3f29a129), U64(0x8cf0d5580efabe5e), U64(0xd74514789ff96be4), U64(0xaf51af61e09dcf72),

	U64(0x2d886dba5494feb9), U64(0x47847fb8831e9742), U64(0x9c4645caf979f848), U64(0xbdcb1b461cbac0bb),
	U64(0xe0f76bfdabb9f044), U64(0x452df2be09d5455a), U64(0x6360e134cb41175a), U64(0xedf28a4ba7818d3b),

	// WhiteRook --------------------------------------------------------------------------------------
	U64(0xcadac8d042c2659d), U64(0x454389d89b0bf801), U64(0xec352b4584ab0ba2), U64(0x7d109cb245e59d87),
	U64(0x68a74d8f67ac0998), U64(0x2da1d772e2672337), U64(0x95c65d9f325a81a9), U64(0x035c69e246ea2a2a),

	U64(0x7b2584588863292a), U64(0x3e7d05d5e89afde4), U64(0x58171422cfdfec83), U64(0xd9a2075d95f868da),
	U64(0x1da8afd77bdee29b), U64(0x8d25e865fa5d1f41), U64(0x5cad8f0581b90560), U64(0xb8723d6f3e47b827),

	U64(0xe1e4abe6712a85f9), U64(0x8f0c5a1f19477a43), U64(0x9407dd91b7023406), U64(0x570a67babc5dffa8),
	U64(0x965a6a2c6308a099), U64(0x7e873487004f9484), U64(0xac9ef8359380d43a), U64(0xaff31969a6d0e11f),

	U64(0xe4b3607a61f4ebf2), U64(0xd30d436ce815daa6), U64(0xf2ec127dd9b24bc0), U64(0x29d24cc261e39f76),
	U64(0xfdf4d684c0def5a4), U64(0x3a91401a9f01288d), U64(0x3d8f6a35d8bc4aaf), U64(0x125dd19b7b757b2c),

	U64(0xbe494ce02ed6499d), U64(0x1880774dacc00e63), U64(0x0440f9561070c655), U64(0xac5d0be114b6a229),
	U64(0xdb3375c59bf08566), U64(0xa10ced9c93388160), U64(0x54a4dad59cc2c007), U64(0x559408bc146bbebd),

	U64(0xb8bad0664b209c79), U64(0xbf586f0e24fefe87), U64(0xec6d94b7a39286d1), U64(0xed7c1459a5dc2519),
	U64(0x4978282330d42273), U64(0x0ff3fd26a98417ca), U64(0xf26c9f7ae2b230b5), U64(0x8c94dbd31f38dfbf),

	U64(0xd5a3e7288ebf4c96), U64(0x6e3944a9cd85a4c5), U64(0xba9c4bc7e7b5c9d9), U64(0x33e8ebb8ab9dca03),
	U64(0xaa2c2de0783569d0), U64(0x2b85abd021bf9d89), U64(0xa439c8d9600cd247), U64(0x622af17e71ccf035),

	U64(0x2d5461656222a132), U64(0x757de25d90c312b2), U64(0x5bf4142296887e24), U64(0x1f57f40b682dfae4),
	U64(0x5900905f7327b2fa), U64(0x55d3cee7500a070a), U64(0x28431e31c56377f6), U64(0xf2bac6ac56be5bd0),

	// WhiteBishop ------------------------------------------------------------------------------------
	U64(0xdf46c89083b67e29), U64(0x0a79e77d5e82473b), U64(0x1acf90d006f2a77f), U64(0x0161a43fe951ed4e),
	U64(0x684fe4624c50d017), U64(0x9d56130f929b7b28), U64(0x5612e8d14194e557), U64(0x8317bf19e7c0ec61),

	U64(0x4bed0c56e8ae7c16), U64(0x6524d908ba6fd75a), U64(0xef1a4afc64d2dec2), U64(0xcc91a06a6aed0e5b),
	U64(0x0e8caf25e2e3131f), U64(0xc682ff6ccc7fbce9), U64(0xb90a317118687ab2), U64(0x483fdd9d5943b01b),

	U64(0xd9ab9bfdcab982e4), U64(0x8c36670af77644c3), U64(0xbeec4e0f0681b526), U64(0xeba28e747d18b8f0),
	U64(0x2e101a99326fea47), U64(0xddda32425f702ea0), U64(0xc0b14cad105e3672), U64(0x359cd242522f1563),

	U64(0xd6affd6dc37876be), U64(0x35bda8df5ead1224), U64(0xc20e838ad96bba45), U64(0x92291e135d8e98f1),
	U64(0xd4d628339ae65ffc), U64(0xfeccbee630743e10), U64(0x58e92ff7f6be6df2), U64(0x1e57637797590664),

	U64(0x7203145c2f63a685), U64(0x8fec2a2b0bead59d), U64(0xdd56487be5b8c600), U64(0x8b11513f987dc92c),
	U64(0x1594970f9cab8f30), U64(0x1bb5f0ea58bfeff2), U64(0x42ff96fc97d2ebd4), U64(0x7cb5664988b73c3f),

	U64(0xf27eb6647cd62c13), U64(0x30a27ac7b6107567), U64(0xeaf3b797f5e00eba), U64(0xd35e513359631e1f),
	U64(0xc9f7f89c795c345c), U64(0xf400f0cb9df71b18), U64(0xc82d0a7de2b8c037), U64(0xf79bf08329ee7b74),

	U64(0xcf53f738e1b27b1f), U64(0x949207eb00202221), U64(0xb0aac2d90efef7a7), U64(0x67144a43ef08d0ab),
	U64(0xb58a58edfc076d67), U64(0xc18306361a8ae880), U64(0x900136708271a8d7), U64(0x4c62781522d048eb),

	U64(0x62f096438e887dee), U64(0xf35dd72cab848b30), U64(0x94e3a6cdb64a1d46), U64(0x38a2d0bfa0bbcb49),
	U64(0x1e2e21c184b7a78d), U64(0xcaabdc94b883b7c4), U64(0xe730d8e63586e008), U64(0x9b46fc7effbf9fac),

	// WhiteKnight ------------------------------------------------------------------------------------
	U64(0xf3c9da6687146357), U64(0xbc0fc65dbeb389bc), U64(0x9be6bbd61f09bf49), U64(0x2140339ed7c11b99),
	U64(0x6fc48df6290562cd), U64(0x380b4bff46db1f22), U64(0x1ada26b72231ccb5), U64(0x705a1f7bdedaa01e),

	U64(0xa2d620ab9407e5d0), U64(0x67ab1673e4980aea), U64(0xafc2252962d550a4), U64(0xf3dfaf76b775c562),
	U64(0x5ccbef3d0397c662), U64(0x01b3b57a62eeae95), U64(0xaec1518190e067c5), U64(0x37488a3d36314db2),

	U64(0x961eff8f15d8504a), U64(0x64ff8e2e721a603c), U64(0x681143138be3ec55), U64(0x5ecbdb18d4c08510),
	U64(0xd2c8dd0b141f60b8), U64(0x90906cc9ba81725f), U64(0x6e6ceecf99b39cda), U64(0x3833b12c83573c84),

	U64(0x77d6cce0c53d35c6), U64(0xeaec84bd94c7a906), U64(0x4e438c6201dfe450), U64(0xe01676f81ef373d3),
	U64(0x90b2023a3ee105ae), U64(0x6d8598e2dc2a22cb), U64(0x7aec68a3a3616522), U64(0xd2751bc8535dcec1),

	U64(0x5220c84bb8c51285), U64(0x57810a9091810fbd), U64(0x71a46e32f4e57778), U64(0x04b44d5b5d146bfc),
	U64(0x2943475171c4730c), U64(0x422be94e746cea55), U64(0x2696be9f46720f2f), U64(0x34588bcf5b61c2bc),

	U64(0xdcd4a8018a685369), U64(0x59e93e1485a41634), U64(0xc31571199e9eb91b), U64(0x4ffe620332c7095b),
	U64(0x4bac0fa0a2cf284d), U64(0x1c035a2a33cefe8f), U64(0x0d6ae8360e511267), U64(0xc9cc8849a2a35773),

	U64(0xc880c44800e4b171), U64(0x4657625b07c46cba), U64(0x9e9cae5ad99cf4bd), U64(0xbcda94886adc4193),
	U64(0x969c91aed057979e), U64(0x45f618b5564b7b33), U64(0x8e7c8c99777ef253), U64(0x8e9e9771832e577d),

	U64(0x91dde22a9480b4bd), U64(0x70ddf3148befa451), U64(0x10b84400fa414520), U64(0xbc5a066b606baf65),
	U64(0x514dd10b07527017), U64(0xcbab54a0ff2c2a98), U64(0xfd7421297472cf1b), U64(0x59f1839342ef0fb7),

	// WhitePawn --------------------------------------------------------------------------------------
	U64(0xc75866298a6e4bac), U64(0xc8ee38b2898619e0), U64(0x7f979c89244eb074), U64(0x6dfe79552a503ae7),
	U64(0x84e2657e2ef4ea59), U64(0x5212c47457504706), U64(0xc2d6c23f1ff0fbd8), U64(0xead331b5f2fbe7cc),

	U64(0x196b78ae8fab6cec), U64(0x82e9b89e64e183d4), U64(0xedf8a811a8525983), U64(0x81401e0a707f4a2a),
	U64(0xe97db9ef64670a17), U64(0xdca4e599aa2b2046), U64(0x55997b5728384a93), U64(0x0efea3f38b47dc02),

	U64(0xf7715d0117066b50), U64(0x202f640d407c7784), U64(0x41fc2d1db8d2c58a), U64(0xf1aea04995261294),
	U64(0x1b97ca9b94818e5c), U64(0x1a604d81c6832882), U64(0x29de3de90ec4b09c), U64(0x833b362a95d350cc),

	U64(0x92bb628c33d0c1a6), U64(0x17b218339404dff9), U64(0x8ecc53ee80c128fd), U64(0xde322a7a6d6d0b7f),
	U64(0x9a1bf2c58b17b96d), U64(0x46841b0080569274), U64(0x175635b631158926), U64(0x97e00b81c49f16a7),

	U64(0x0b0b7c04c7b91bbf), U64(0x07b6f44fe486244c), U64(0x6e3abe3d9168fa01), U64(0xb8e6064f060e9848),
	U64(0x9a7407276634a98f), U64(0x08dddb9a33d0af4c), U64(0xf48074674a428565), U64(0x4c42426a115ca77c),

	U64(0x2e476b77c7666bad), U64(0x3ff12da796160fa8), U64(0xb6b1986a2ecba623), U64(0x1e5bf26bac6a2cc8),
	U64(0xe854e404456189d7), U64(0xa6bc5714b0e06a85), U64(0xd94634b1c5575759), U64(0x22edb1d386f7a76b),

	U64(0x05425da975aa39f5), U64(0x6ad785b5f1cb9ba3), U64(0x92f67a06e954aa6c), U64(0x808537a95a748260),
	U64(0x6cf997acd7762b1c), U64(0x61bb904dbec76cc7), U64(0xd3646f8af70ef000), U64(0xdcff1f6ef367b6ea),

	U64(0xf66e9417cc7b0cae), U64(0x8399ddcbbcc6a55c), U64(0xb3f777be95923c1c), U64(0x6386d01553c46e6d),
	U64(0x1d342f505e226825), U64(0x8c484323c0c0c008), U64(0x7a7acbc76ac93bdc), U64(0x5c61d0590ea1a132),

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// BlackKing --------------------------------------------------------------------------------------
	U64(0x2f64bef8708ccc76), U64(0x8f69cb123b86b473), U64(0x14629d43439b0b9a), U64(0xb51615b61addd932),
	U64(0x56083fb3f25972d2), U64(0x5824911f1514af24), U64(0xcc31f9a300cd86fb), U64(0x106f10489953b0f0),

	U64(0x4e0da08ed53e3f42), U64(0x861454c96e778a89), U64(0x85fa8e9cb37aebe4), U64(0x185f7b31ecc2b80f),
	U64(0x77b4840c225dba24), U64(0x21f3044fd95b9644), U64(0xb10b52c194b80c12), U64(0xd3511042b3dc6e17),

	U64(0x127c6a623e7a8096), U64(0xac40b42d23979b50), U64(0x24eaf6e4d79f81dd), U64(0xc188cff8736251b9),
	U64(0x12392eb101fe558e), U64(0x02e402c80d947c34), U64(0x8b9d039619325a97), U64(0x5d9b0636b0704c83),

	U64(0x8a94b7d08b8d601d), U64(0x5733a1895681c0aa), U64(0xdd5a40d653d15e74), U64(0xbb054e3cf7ccbacd),
	U64(0x6e4b27ff19f158fb), U64(0x41e3901659df0572), U64(0xf6e26bfacb2b1d27), U64(0x4fefc0f2472ecd13),

	U64(0x3e27d9ba892b921e), U64(0x948f060bc89c832a), U64(0x8baa3f0efc1c2af2), U64(0x2381a923ba396109),
	U64(0xd3b06958774253f0), U64(0x0b445b670f7c832e), U64(0xa2be518eb068da7c), U64(0x3bbb38d5b2cdd554),

	U64(0x1da3d990a138c7b6), U64(0xc8e233f9accae801), U64(0xa05e74f15d3eeef5), U64(0xfea7f74d1c9bcaff),
	U64(0xae0b4bfcf6a32afa), U64(0x6be0332e6af8a0cf), U64(0x943177446ddd6775), U64(0xba0da641f019b36e),

	U64(0x384025f9ab18fbba), U64(0x1939888bb6674ce0), U64(0x59e11e6d2f07fa4b), U64(0xa596f492bd8f9bca),
	U64(0xe939068dd320fec1), U64(0x00dcc4c3618c975c), U64(0x0486fcb60f496caa), U64(0xcd6e638cc3106b1a),

	U64(0x28b8c5a56fc98845), U64(0x349ddc52f07e66d6), U64(0xdc5b17f35598ab96), U64(0x536c255baf56d4ec),
	U64(0x7d58b9aa06d26aa3), U64(0xc479e0c6ddbc2a4e), U64(0x0668cbed0f5dcbea), U64(0x751054ba6613a289),

	// BlackQueen -------------------------------------------------------------------------------------
	U64(0x03c7280b077d6d7a), U64(0xe12382c91253cda1), U64(0xbefda033140e3cb7), U64(0x1b6f806491b094b5),
	U64(0x1e98babfcc965316), U64(0x57d2ade56704a531), U64(0xd54fc0a170ffd7aa), U64(0x354ead717998c00d),

	U64(0xeae96f6e4b1508c1), U64(0x7c0dc22bf8632b40), U64(0x83bc6818b369f89a), U64(0x4efc4febd26e4b42),
	U64(0xf8ceefc9feb1874f), U64(0xf845bec6c1ccf8a0), U64(0x3e2b5a324714c3bb), U64(0x1d9eab2892b42859),

	U64(0xb25280c92f83b2a2), U64(0xeff78ea70b1c5e36), U64(0x6d4de2bb930efe72), U64(0x64b95da4f88ca989),
	U64(0xfac373fc552add76), U64(0x3c841f46705e8b18), U64(0xc32fb541343401f9), U64(0xf2c11cce7a469839),

	U64(0xb817729006c14c65), U64(0x1071ec724569f6af), U64(0x621edfa9de9439e7), U64(0x1a22c4d5150f2baa),
	U64(0x75cca15a55258a3d), U64(0x24f570d7d46087f1), U64(0x73a8a9518592ea87), U64(0x925f5b9e52691f97),

	U64(0xb9b2c60211b8ee24), U64(0x4308bc03f750dbc6), U64(0xfc913f36d178361f), U64(0x63322686eb9ad5fa),
	U64(0x58a258ad8bfe49ce), U64(0x6e58e93d4969b576), U64(0x4cfdeb892f7103d9), U64(0xe6d396b7019b60fa),

	U64(0x891d9d8a680b0fe9), U64(0x3af29f54df3c8952), U64(0x4e4ab77a442734fe), U64(0x6e9ee2c78557d228),
	U64(0x39205e41d0b4f1bd), U64(0x2d7afbfd5b402083), U64(0xefaaa35cfcb13cd3), U64(0xd5eb1dcb6c10d071),

	U64(0xec6670a35fef81f5), U64(0xec28f44e30a9996c), U64(0x20f1adb9f2960c1e), U64(0x6d0d8e411f5845a6),
	U64(0xa15d0c9740e3a337), U64(0x7e2d2c54bff916f2), U64(0x2af10716e9691641), U64(0x1dadd22c12ff5b22),

	U64(0x6ba5819a9948d2c1), U64(0x415fc03a15510c4d), U64(0x40a4b22bdc58b560), U64(0x6b94dc456fc3dca1),
	U64(0xbc04ae725dca44cd), U64(0x851229741d509353), U64(0xdfa93ba511ed67a5), U64(0x9930157fc5022cce),

	// BlackRook --------------------------------------------------------------------------------------
	U64(0xa14f64e7e2a08adf), U64(0x6b642680b3befe04), U64(0xa5cec9da49db1e5b), U64(0xc8a4791b8796b72b),
	U64(0x96dcda1732dac346), U64(0xdd6a468b90154135), U64(0xc92cf06b2f7cec8b), U64(0x49fdd61b76fb21c1),

	U64(0x952d68a7d37cbdd1), U64(0x1d02dca5ecce6696), U64(0x7947464767cc4eb1), U64(0xbc5690e29707fd78),
	U64(0x1b77de938eb37a92), U64(0x82a0316874d3f3b4), U64(0x0438b0002bc65e99), U64(0xf7165ab04168fe6d),

	U64(0x333d75259eefcd14), U64(0x8906c3ac02d0bea4), U64(0xffd91e4fe65f12e9), U64(0xc14b1bf2982e4aed),
	U64(0x35d83daf48cfe68f), U64(0x9ec31949cd275677), U64(0x2c3ee7e34b57d352), U64(0x94660b0b00324807),

	U64(0x3f7e45098859afce), U64(0x69a26300773711d6), U64(0xfcf669991e52df6b), U64(0xe9fe0aec1acf55b5),
	U64(0x6a22ade2d0520453), U64(0x79b4957bf7ad0aaa), U64(0x10bd4cdb980db736), U64(0xf851ceac6b23657f),

	U64(0xad9451efea678535), U64(0x5646fc2f7a3ccca8), U64(0x12501485c46afe0b), U64(0xe44bf524b8fe2551),
	U64(0xc7b072886b0fd978), U64(0x2c29835d87188eeb), U64(0xebd902fb34841eca), U64(0xbc8da25aafd4c949),

	U64(0xe8e2f478103c805c), U64(0xf4bfa9cbd7ed9c07), U64(0xac7f6a4adad8b297), U64(0xbd209ad1b5f145ba),
	U64(0x4f9d4c0a69871173), U64(0xf6e28f3f8b89aebc), U64(0x4b13bc67fe616132), U64(0xcfe6c79ca07bb7bc),

	U64(0x80a3f66f2c6a0eff), U64(0xe3afb253772a75fc), U64(0xf40c5da6637f1c4d), U64(0x29002c86cc15c154),
	U64(0x4dfe86a1b23ee0d9), U64(0x65622cdf439dec74), U64(0x30fda6a5933ffba0), U64(0x960092fd4722f32b),

	U64(0x4ab30ab6a72584cb), U64(0xc74a9ae8575cdeeb), U64(0x2e04317419a09c84), U64(0x49c487bc3b339189),
	U64(0xf1e89841c5586c04), U64(0x618a5d4557a060db), U64(0x67b1f2b29381993c), U64(0xdac343bda84599fd),

	// BlackBishop ------------------------------------------------------------------------------------
	U64(0xebff8b8df3c83a0a), U64(0xf9942b8463438981), U64(0x6c2f8a36722bbac5), U64(0xa7cae83f1120ef53),
	U64(0x6be91f12cdd0ca04), U64(0xc441e4b94cecfb40), U64(0xcadae4afd1198c20), U64(0x47d6c333e59f0d9b),

	U64(0x1c7fe4e60648c3bd), U64(0xf61d326de86eab61), U64(0x71ea832569a032f7), U64(0x27b805c6b65ae940),
	U64(0x4ab0f7d8436b08dc), U64(0xd7709084e3c83ba6), U64(0xeda91d50da13848d), U64(0x8540270732c408e0),

	U64(0x35efdcdef2789841), U64(0xf937151d7d7be252), U64(0xe95c415b888c8aec), U64(0x171a6366a0e1271b),
	U64(0x9149c05e04f7036c), U64(0x414f8230851b4649), U64(0xfb51808713dc84ba), U64(0xf933e08fb5dfaebc),

	U64(0x28254a305cc7753f), U64(0x6e9300d69c44cb1b), U64(0x1fed087462b8e3c9), U64(0x311931c6cc9d371f),
	U64(0x0ab3c7d461118dc9), U64(0x9f67ffd0d3815586), U64(0x8586a78a5a5d0daa), U64(0xc35e56c16ad732e8),

	U64(0x5dec4f660f327eb4), U64(0xbeca79c300886406), U64(0xaad304bb2ea3f914), U64(0x4f6aec0ed980ff6f),
	U64(0x1ddf22d9fbb4a2f0), U64(0x0a5faf84525bab3e), U64(0x0b2f339ac1074ead), U64(0xceeb55e80a6a92c2),

	U64(0x8a439d961671da6f), U64(0x66467b94b6de5d2f), U64(0x21505ba132d4907d), U64(0x34c443b890fac25f),
	U64(0x48c89fd2e655cdf9), U64(0x15897d714819c7e6), U64(0xf7a8f3d223780746), U64(0x6778549c3bbb486b),

	U64(0x889aeb3bf2632b9a), U64(0xcb8fb06abda385ff), U64(0x502d1ab72f606c48), U64(0x29b34ae2ff2c21a9),
	U64(0x5f6942a552a43ba1), U64(0xd9b44265023be3d7), U64(0x29081045ed355455), U64(0x2f915936359af5a0),

	U64(0x6c3889068abe571c), U64(0x97b66c46539aa106), U64(0xec346e6de2e3f311), U64(0x6aadba9193ad40f6),
	U64(0xd835cf0ef3a71198), U64(0x10e62386c249b3fc), U64(0x1cd290d68761f8e2), U64(0xb8337434d4e694e1),

	// BlackKnight ------------------------------------------------------------------------------------
	U64(0xbd77a59f1d361ebb), U64(0x3fd63cdae63a60cf), U64(0xabbde3878f5d3ddc), U64(0x7bd30af727464ee0),
	U64(0xc54b2e6fd776f8ec), U64(0x87536cc23efddac8), U64(0xa673f8fea0989c7a), U64(0x07079efe6a0393e1),

	U64(0xd59ef63e8c0a3f87), U64(0x275f3761c2b39d86), U64(0xabb109a58d81d722), U64(0x6fa8223d3df3b5a3),
	U64(0xc21d3f51d871af26), U64(0x09d5c9fc29803819), U64(0x866d72e99c8219c0), U64(0xf903690329ec9854),

	U64(0x463c5862fd725e53), U64(0xfaa2e3b9009c23ff), U64(0x51ed3fa38b3e32e1), U64(0x3fdd054ae621b7a9),
	U64(0x63422f3c0fcdb872), U64(0xdb599cddb7ba5bb7), U64(0x29d821145131732f), U64(0xa768e7bd756f318c),

	U64(0x6c499d80db10e3f2), U64(0x1ccb5e0f3dfd948e), U64(0xe59cdfdfde9ae15f), U64(0x9d490cddfef6d223),
	U64(0xb8985e20b3c308b5), U64(0xca4145a21a50a82a), U64(0xefa50915dbc7e668), U64(0x66c706d2ddde9849),

	U64(0x9ce9a5932d0364d2), U64(0x9686b7e5e8901ff7), U64(0xa9a42437501eaad7), U64(0x20679ed4ada474e1),
	U64(0x367a3bbc6c11bba2), U64(0xe4cfc9c30e06a14d), U64(0xc589b195c383ecfd), U64(0x841ce907bbb6a61c),

	U64(0x3d731ef371ea6132), U64(0xab7a347deeedc48a), U64(0xa5ba154bec151ef8), U64(0x17726f865e2ee581),
	U64(0xdbca0e729ac306f2), U64(0xf7ee9f7dbf54f4d7), U64(0x6c10670c9169452e), U64(0x5a49ee9a2bc1486f),

	U64(0x23630d9bff542959), U64(0xdcb2d15124939ab9), U64(0xa5de1bef76950515), U64(0x730f408f5dc85968),
	U64(0xd8c24e6721021521), U64(0xe61242e7661ab160), U64(0xceb3901956105e41), U64(0x09a56e7a2a9b7040),

	U64(0x6dddfaced358af91), U64(0x6d597db8d1caf88d), U64(0x7dfa62e1b1760d84), U64(0x08e19fa60dfeb1bf),
	U64(0xa34875d78b045e7e), U64(0x0a294952e7727e87), U64(0xac7d17ef5e7b791a), U64(0x51d95a618d846d91),

	// BlackPawn --------------------------------------------------------------------------------------
	U64(0xc58896c783248e00), U64(0xb28c400d0e64ade8), U64(0xc41ecb9b99a69765), U64(0xa1bcd8aae00885c1),
	U64(0xd66f8316f2155659), U64(0x8eeb7bcc71816ad0), U64(0xc0fd3c6163d7ca66), U64(0x3483cad9e03c498e),

	U64(0x797e845514e40aec), U64(0x9213f80bf739746d), U64(0x6effa9a6b1ea0966), U64(0xecf7c1c9d0e33dba),
	U64(0x244b3a0a6a1914d3), U64(0x6ff19fb917323431), U64(0x1fed9c34d7fa3bfe), U64(0xc374c9f28e32936a),

	U64(0x82e29126f964e26e), U64(0x5e19b04bcae033ab), U64(0x8e843603dbe6f7c4), U64(0xa69036d38dc44fa7),
	U64(0xdc8900d3ffe9bb33), U64(0x7df691fb44c14455), U64(0x8db41acc4e059813), U64(0x9b2d3d0de5b20868),

	U64(0x4b39506de2dc33e8), U64(0x497fa4ddbb3b07ce), U64(0x6c5debfda2c4ba40), U64(0x8fdbde6d48bf1975),
	U64(0xff2f49b04059933f), U64(0xecbe4f65b27376f4), U64(0x2721d3581a8b968c), U64(0x1a24f47aac88d68b),

	U64(0x789e285d63687859), U64(0x90d51721750bfb72), U64(0x6ec71da00ade928f), U64(0xf30d9e21516cb984),
	U64(0x26e15240e445a13b), U64(0x1f2c3c30333f106d), U64(0xc112f0277a1d8d9e), U64(0xb8ded447d7ac9df4),

	U64(0xec3468c53d70f8e2), U64(0xc2762a9062b4fd52), U64(0x125a697ea5c928fc), U64(0x699ccbae2e951159),
	U64(0xb84b2eebee507f54), U64(0x3f758e5dc86257e0), U64(0x98cce7a224a0ec87), U64(0x9c664fde6084eb02),

	U64(0xd0fc175ca6c00b3f), U64(0xab97afa35e0176ee), U64(0xc33d3e3c9d339042), U64(0xdb4d05320bec3d50),
	U64(0x039be4f2ea598bb3), U64(0x82f71649af9e5b54), U64(0xa314e81e7bdd8915), U64(0xef47b0e2d07c4d8e),

	U64(0xc95b40effdb0f22f), U64(0xc388499302f30a22), U64(0xff906154a95d03a7), U64(0x9d33ff38637e7a05),
	U64(0x2552ea8ad2b403cd), U64(0x5e613aa2d28e5a87), U64(0x004ec1298ccbd07a), U64(0x8315aeb53c3d81ce),

	// ================== PROMOTED ====================================================================

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// WhiteKing --------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// WhiteQueen -------------------------------------------------------------------------------------
	U64(0x044703d57fb1e299), U64(0x8a3c60812c08665a), U64(0x32dc7de4cae88a7b), U64(0x6b90680243c4b54c),
	U64(0x6e3060c4bbed7fee), U64(0x09a012c21457c46f), U64(0x713f791a21ad43ca), U64(0x5a4d0ec873244cdf),

	U64(0x59a713355c986f8f), U64(0xa347356dba0fbfad), U64(0x6650c485ba5b1243), U64(0x2d86094817cc64f2),
	U64(0x20fdc446a93f6201), U64(0x1db9308f0d27dbdf), U64(0x98f63ae9645b1111), U64(0x03415b7672cca0bd),

	U64(0x910f4a575767cff3), U64(0x5182927aff4f928c), U64(0xdde2b660565a30dc), U64(0x3f42ec666558c5b3),
	U64(0xce05da712568cac7), U64(0xfd9326b46e518555), U64(0x9334d36563994ecd), U64(0x3bd434362a7b358c),

	U64(0x14b4d64afc2171bb), U64(0x8332f03346030a46), U64(0x56300105aba021c0), U64(0x470610c2fb63b7b5),
	U64(0x10c12cf0c2f837f5), U64(0x7d8af8d403969661), U64(0xa8cb40dbe096915d), U64(0xfb306c5498354397),

	U64(0xe25d9ee093992b8b), U64(0x1f406a7e77f19817), U64(0x06592044d4d8c7e7), U64(0x986ca3c584c84454),
	U64(0xcec495f755c884f0), U64(0x3d8e0276e94a3fb3), U64(0x6dfc65f711f0e645), U64(0xf04572c328e9c0fd),

	U64(0x1de908cfe3f5fc3b), U64(0xe1e609e5214fc6f0), U64(0x1b97e198798ccc46), U64(0x52983c479b769f0d),
	U64(0xe1ad316c24a875e2), U64(0x759a9b5ac9742a91), U64(0x6bb1e5f7b2bb7e47), U64(0xe543c7cd3569a2d2),

	U64(0x56312cb746ff2365), U64(0x03e7298e5b86bf22), U64(0x516e9a17bf3b9d0e), U64(0xb507b363062bfe41),
	U64(0x7600192a061dd0e5), U64(0x1d3fdfd7ab7ed9ee), U64(0x422f696efd2a98f8), U64(0x4d3652c8c76f687c),

	U64(0x9f7711eae210b999), U64(0x3fe55a4a3db93342), U64(0xf9867077d2c22292), U64(0x06938ebd5352aba1),
	U64(0xcfbdf8fd28e52d4a), U64(0x9f5dc89b771ea0ba), U64(0x76170ff911d3d955), U64(0x7e7bddf4e7d92fad),

	// WhiteRook --------------------------------------------------------------------------------------
	U64(0x28bb97717bb86c3f), U64(0xe14b10911730bfe5), U64(0x65fdc8cfbb000784), U64(0x3413b92f048583c8),
	U64(0x449ccb9483380adc), U64(0xa4a34f7dd630cec5), U64(0xf23142fcbf290710), U64(0xab1645e0b73ebeb6),

	U64(0x9f7ac648b66b58ef), U64(0x81da786a8e1a3a07), U64(0xab80b2cb27644d91), U64(0xc57b0159cd1cf77a),
	U64(0x84425693d1e998f6), U64(0xa086ad9f1b17e973), U64(0x6c29c7100c6ea19b), U64(0x3a318a14b98d372b),

	U64(0xf01ba582f9382406), U64(0xa1cde875f370ae9c), U64(0xb9a0ab780158707e), U64(0x8d26ff790475117e),
	U64(0xdd33f98a55e26ad9), U64(0x549c9afccdff9451), U64(0xfed35e6c20eabe08), U64(0xee602ea3d3b08637),

	U64(0xfb60f74da1a791f3), U64(0xb25a86f4ba75b20e), U64(0x5402f6bd8285b194), U64(0xb5e9f6533809151f),
	U64(0x105f0a553888caad), U64(0xb364c84f9a7f366d), U64(0x13c5a20c72a2e3ce), U64(0xb6121d22131c0104),

	U64(0xa4cb87927ec6cc17), U64(0x897b31544122583b), U64(0xd9bed4853c502a78), U64(0x211fee372e06645f),
	U64(0x87d38f49fd841678), U64(0x22644edaa636120a), U64(0x693c919475426ccc), U64(0x77b3666bd380005d),

	U64(0x09972e5b72ba54c1), U64(0xa6d576eb8a9adbef), U64(0x151e128a1470cc43), U64(0xba872ea0ccbcac7c),
	U64(0xfaadf26b0bedcb90), U64(0xf4d0746e2cd9c2cb), U64(0xebc24328279cf3c0), U64(0x7b91361891e74156),

	U64(0x952d28d81c4cd5e5), U64(0x73974085e2ebdfed), U64(0x19c8a787015bc845), U64(0xf0d3a2e4b44b9030),
	U64(0x1fc804c725e40440), U64(0x7f850c159d730e8d), U64(0x46a26a52fc055ad2), U64(0x187096a491259118),

	U64(0xb1af461d516eee12), U64(0x9bd1e1fa908307da), U64(0x298e4a3f09caee63), U64(0x19cc5ee9aa4fbc78),
	U64(0x65fad64d232fe9ee), U64(0xc1b5e63af64d55e8), U64(0xc70158cce44d2e70), U64(0x15d1b9bb5466ad4c),

	// WhiteBishop ------------------------------------------------------------------------------------
	U64(0xf72067659687ef21), U64(0x577ac5a51e5651c5), U64(0x297b213cebe4451b), U64(0xafbc7b8a2782f71a),
	U64(0x7c744bd7713ebc3c), U64(0xca1da973d1bb1a14), U64(0x6a9d797790afccad), U64(0xad40920248a2e551),

	U64(0x4ff44c34da7b4dd0), U64(0xde8e75b6789090ff), U64(0x88f3cb3c8b5dbf18), U64(0x9924d71d3d7359bf),
	U64(0x7777434ec63d90f8), U64(0x4fcd31f2f421c717), U64(0x5aaee550208ae7f0), U64(0x29d4a3cab10a9a44),

	U64(0xc01a289fe006387f), U64(0x2a487fc2e4f569fb), U64(0xd33f764f4052ecb7), U64(0xb53262e2308fa659),
	U64(0xfd8d825e26a8a2d1), U64(0xf08610bafd66009f), U64(0xfaa9928d90ecc574), U64(0xdcda00e8a1970957),

	U64(0x2b8ae9d228a44b14), U64(0xf30ff94d8ae2dbbc), U64(0x0dc59391a4b26780), U64(0x192a2b602b123aab),
	U64(0xd1c0fbdcb077da5d), U64(0x65ca4e0e02964227), U64(0xda82400db9d07a0a), U64(0xaa16f0d4828d0050),

	U64(0x73580533d9f2fb99), U64(0x8e6e9922b252bdb1), U64(0x65651bc93644c5e1), U64(0x4ec958544caaa9c3),
	U64(0x9e6a3fde44907510), U64(0x3ee6737f5f934fb3), U64(0x67fb5df086391215), U64(0x0899d25e2b391f79),

	U64(0x20f7402ecd84404c), U64(0x18d96f18f8b826d0), U64(0x1a4e1ba1fdb05563), U64(0x1324d44c84bbef0a),
	U64(0xc7613d66f20232d4), U64(0xd5bd4ad2cc618853), U64(0xae981ca25036ed10), U64(0xd08c493917325f88),

	U64(0xac56a76157fd0921), U64(0x161037898e176e8d), U64(0xdf27c2fb173845dc), U64(0xf734ec0a2d041943),
	U64(0xa9bca8004f1d7086), U64(0x08126a5da13c42d9), U64(0xab894b4e6ebca682), U64(0x476bd91a4ca0c161),

	U64(0xc0ef0788f08d9463), U64(0x600f737ed7910113), U64(0x39a0b9dbbc8e5d10), U64(0x5ea41ef6508a97ef),
	U64(0xedf320cbe664658c), U64(0xaf2ce404a46dae6e), U64(0xdadcfcb48f1c02a8), U64(0xcd60c5789e26b8b6),

	// WhiteKnight ------------------------------------------------------------------------------------
	U64(0x3a93e22c7f6b3c55), U64(0x9fba7867a63c8ac8), U64(0x3ede983f7b06516b), U64(0x6da1e9f12833259c),
	U64(0x5d69e428228cca9a), U64(0x79e16b54bdca7e02), U64(0xc517aa54a54ed12d), U64(0x98db096afb729beb),

	U64(0x2aee2474d7bf2d7c), U64(0x72999224bb580060), U64(0xc2c7ffb795d4e1e7), U64(0x13e15ad5c2d3d951),
	U64(0x53214a10ad7c784e), U64(0x95265cbe69f01d02), U64(0x80927db966612b20), U64(0xb9302c026f2a80b2),

	U64(0x4e93e5fbc38cafd7), U64(0x6ce58a3a4917dffd), U64(0x3bea7e195d96172a), U64(0x4f050de918e728b2),
	U64(0x1167bf4ccb9f1a34), U64(0x1a620288f4a12b4b), U64(0xa5da9b1ba501f044), U64(0x578460a649b24a39),

	U64(0x1f9ca81ea33005a0), U64(0xa17023dd34f22eff), U64(0x3654be3ac3a26289), U64(0x4dd1b68eb1ada829),
	U64(0x03e9d68eabc9d7fe), U64(0xf5d6d12955e96f2d), U64(0xccdcad5bdc7bd1a1), U64(0xd28da598cbfbc3ca),

	U64(0x4d9c20c7eaa8703d), U64(0x9906d6c9c38b591e), U64(0x01cedc5a39e5b5c9), U64(0x9630082145dd2f1e),
	U64(0xff49c8f0afc01a91), U64(0x44d0aec75c666288), U64(0x57b84b8764d3da3d), U64(0x72abd9c2b876c142),

	U64(0x2f791f047047bd5d), U64(0x1b43a4a5b7f5244d), U64(0xac918f8b4d9d1e00), U64(0xb5663909d9d6303a),
	U64(0x80923ffe2bae8db2), U64(0xddeeb25f2e41e526), U64(0xeef27b1803a60f3a), U64(0x12fc5033c7c95105),

	U64(0x997968b0dadb71b6), U64(0xa98dcc93091ee1da), U64(0xe393a663d106d4b2), U64(0xb7fe4077025d3331),
	U64(0x734f98ea7a95ea1d), U64(0xd53c5a45bb8cdfa1), U64(0x11d58b895af5f73a), U64(0xbba44fb18d7bad4c),

	U64(0x3b18e9ef00b4c810), U64(0xb017cbfb12688bd6), U64(0x1af46d6374011c6a), U64(0x8cab2463b6c0e01d),
	U64(0x3d761d20063ee258), U64(0x2aadb6180f80c2d3), U64(0xd6814d04b2584c63), U64(0xe7a11b9d7d769494),

	// WhitePawn --------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// Empty ------------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// BlackKing --------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// BlackQueen -------------------------------------------------------------------------------------
	U64(0xcaf1ca6cd004e7bc), U64(0x1122bbd8f31a9801), U64(0xdf3939952977e95f), U64(0x77aa072d06890a48),
	U64(0x116569c8ba82a83a), U64(0xc9997d1a2f05161a), U64(0x51c153dd787cf748), U64(0xe7f1c48a17f0c994),

	U64(0xc95a8e15d4e4aac2), U64(0x17369b1ad4dfb135), U64(0x44dbebde2de33051), U64(0x1169ade998830992),
	U64(0xcfe3985db2d35d21), U64(0xd1b94354c3d22c4d), U64(0x73e101f840df8084), U64(0x89e6a53131fc7242),

	U64(0xe7d461f15c6129b4), U64(0xa69dee16a765d2b0), U64(0x48c0b32df8ddc0fb), U64(0xb7c9d582a54c0b2c),
	U64(0x80576b83319d83f9), U64(0x59714b37b93b5e39), U64(0xb26dfdc7254c0ac9), U64(0x89ef22889d7081a6),

	U64(0x8b1e7a1bc43beb1c), U64(0x861eddf3fdf4d64f), U64(0x56dbac3597f7e48b), U64(0x190b253068b60e60),
	U64(0x294532d1f3b50a20), U64(0x058a1a4819387af4), U64(0xfd1836fd44897416), U64(0x3e572ff979d8ca38),

	U64(0xc6b5b477d2ee43b5), U64(0xc9c6056490e28221), U64(0xfb0d0d4c55eeddde), U64(0xd64f148443724752),
	U64(0x2f6bc2d724af9792), U64(0xbd7b0f8478d446ab), U64(0x144588401f496bf3), U64(0x1ad8889a5aa8e26c),

	U64(0xa9448d0f698b8370), U64(0x906953398a3df494), U64(0xa5280a61ef2d0450), U64(0x0c92df7ab48210ac),
	U64(0xf8a95606e064f51b), U64(0xb253ddc5e1b54ff4), U64(0xb5d274ebd42fcb9c), U64(0xb3f8b22a412d350f),

	U64(0xf18717011ddb123b), U64(0x579fe8f10c63060c), U64(0xe76ff8e4aab118a0), U64(0x6d34106328ce50ac),
	U64(0xa60927ade8ccdca7), U64(0x3804de0c37c58434), U64(0xc92548d8939af17a), U64(0x4163dbff847088b3),

	U64(0xe7365cbc6a7f8730), U64(0x55dff0476966e4b4), U64(0xd5884ee48c058d27), U64(0xec14f49f926b0d1d),
	U64(0x1004ad6869a8c64d), U64(0x3eacccee6b0d2cf0), U64(0x0d4dd3188efdf8f3), U64(0x7fafe619290cf26e),

	// BlackRook --------------------------------------------------------------------------------------
	U64(0x9475361b15b45cd5), U64(0x70c766782c6225c0), U64(0xecb6d461dd6c8568), U64(0xb518eacb142499c5),
	U64(0x1dfc510cd7016641), U64(0x9010d26bd30013d6), U64(0x475fb6cd262d3895), U64(0x1ea46e3bcbee6f47),

	U64(0xa83a45a05758d1c4), U64(0x7f3dd6bb2c715f0d), U64(0x73c1dc8d32c0180f), U64(0xfc10f3a3c497c54d),
	U64(0xbc5edf6509acaf89), U64(0x563f3cfce243d3f8), U64(0x46c1f063e6b8ca39), U64(0x223e2c38b61edc4e),

	U64(0x884d4eac614c987a), U64(0xad980ec0c9b3ccdc), U64(0x73334f7053ecda9c), U64(0x54fe44475c2803fb),
	U64(0x4ce513f999517686), U64(0xb744be4992d915b4), U64(0x2b627e280a8dd01f), U64(0xe8e9d8da88a760e7),

	U64(0x5ba23807ace2576b), U64(0x81b2aa898d7ff740), U64(0x31a160801ed3585f), U64(0xf86a9bada37fe981),
	U64(0x0dfa846a5626e47a), U64(0xff293f1d1de94a79), U64(0x01a6483cc3fb62c0), U64(0x02f86bcc14474ff9),

	U64(0x96a1e55142ddb8db), U64(0xac0b9688d3023544), U64(0x8f263f7ce1f7b3cc), U64(0x21cbc42ba4582264),
	U64(0x3a21ced28a3d6fa8), U64(0x02327b02f1a6a37f), U64(0xad0f89f58a31f96c), U64(0xe5c726eb2395f91f),

	U64(0x4e691ecbfdff4c35), U64(0x451033ddedb79722), U64(0x8011bf394690d8d1), U64(0xa4159629bd0ce70e),
	U64(0x3c3cf99dabf131aa), U64(0xa7db417ed5cef0f6), U64(0x068d4a5f2548652f), U64(0xabccc0992b67af9e),

	U64(0xfe2312497bf4c414), U64(0xab76533d29e3c6ea), U64(0x8d96dda010ba133a), U64(0x3a61654f9da998bf),
	U64(0xbb2ff9574df0d641), U64(0x576784e75cc9d113), U64(0x6365ce9628bd842e), U64(0x5fa9ca7e22d71d72),

	U64(0xe697a8f517ab3d3f), U64(0xd35c48fba6cf7eef), U64(0x8d499580f4544852), U64(0xab5da9e9ae24ad63),
	U64(0xd83283085553e1fd), U64(0x8940b08b9b2fc0d4), U64(0x35ce432f12163d2e), U64(0x217f1caa6a824b26),

	// BlackBishop ------------------------------------------------------------------------------------
	U64(0x8495248ab305ee8f), U64(0xc0944c15e3c09778), U64(0x9f59cef04505da02), U64(0x47efd3ec19fb73c0),
	U64(0x32b9d1ed571b84b8), U64(0x15e82e121ffd9115), U64(0x3a898fc4ece11b80), U64(0x5a06111a2088be1f),

	U64(0x9d3c1d1302e84551), U64(0xc8ee1ca11e20a35e), U64(0x1e4a273c98576ebd), U64(0xd1fc122dd721044c),
	U64(0x32e60a2983d1c843), U64(0x180370f4abada20f), U64(0x852d84b34edc83d2), U64(0xc9ba66fee4843746),

	U64(0x4a05addc1ea2e944), U64(0xcb96c4247c24e036), U64(0x1053b4ccf6c024d6), U64(0x581ae15866c42214),
	U64(0x2126b228fdb69cb5), U64(0x4f688c6727828a1f), U64(0xbc0156dbcef2a7de), U64(0xa6f7652af004d29f),

	U64(0x05aae96e3384dfe4), U64(0x6e0b75ab4901a6c9), U64(0x382637115387cc68), U64(0x2009a159d9509cb5),
	U64(0x3e47b851efbef3a4), U64(0x8bed069c11856a55), U64(0xd7c04ef29cf3751e), U64(0x22f1e6aabfe845aa),

	U64(0x5c685bafc31b3c9f), U64(0x244475599eceffd5), U64(0x85dfeab10d5752d6), U64(0x603b914a4429875e),
	U64(0x35b8f864e4685bdb), U64(0x140368fd88e26668), U64(0x97655506a678b4bc), U64(0xfd2f0668eb41e684),

	U64(0xf5a13e0e1d60b856), U64(0xd71ea59c19c54bea), U64(0x363454db33ee5ef4), U64(0x0a86593ec58517e8),
	U64(0x39cac56cc61f3368), U64(0xbb870177729e6283), U64(0xbf16bb430520dde5), U64(0xb0ff0dfa8ef47265),

	U64(0x250cabf0859b323b), U64(0x5fa8c13086419e55), U64(0x6caa31dec6814cc6), U64(0x5c73de210d683e98),
	U64(0x9f46f244eaf78bcf), U64(0xa8aa67f9237dbb68), U64(0xc031fe468f6f6967), U64(0x0d0cfcd52bb265d4),

	U64(0x7225a1188a0376eb), U64(0x399be2aedab54c3b), U64(0x46739c9baf790ac0), U64(0xd38e499b69fa1e25),
	U64(0x7f8ddfb015f07d87), U64(0x24936e7db2759b2d), U64(0x69f15803d26af16a), U64(0x62fdb302c66279d4),

	// BlackKnight ------------------------------------------------------------------------------------
	U64(0xab4045843a34f2e0), U64(0xae96e568385585de), U64(0x44a6a43e32a682b4), U64(0x1276bdc2fc1b7238),
	U64(0x153a63a94e385bdd), U64(0xc48762efcfbadae4), U64(0xea13669343bcd4b9), U64(0x992161e6ef2c2919),

	U64(0xa7185f2616bd83c1), U64(0x38f85c7bcda11a85), U64(0x90e2e582b1c84a64), U64(0x8d75aa382752602a),
	U64(0xda433164b4750dc1), U64(0xa8be7b123a102607), U64(0x58d916991d8a5cc4), U64(0xd1327ef186fb215a),

	U64(0xc96f5a7d211f3f9f), U64(0xbf7bfed396840428), U64(0x267a311ebcd14f08), U64(0x82fac9552fa58953),
	U64(0xf0c1baa7e1513de5), U64(0x73f10c94a39100fd), U64(0x608a57252ef6f020), U64(0xa085261969416c01),

	U64(0x77bcdc0127c4da80), U64(0x95104c33771f4a98), U64(0xf70e5b4dae84cfd0), U64(0xf71c3f6b2fd5891c),
	U64(0xe4e1af2cf1bcb046), U64(0xdb9cdd7d25570179), U64(0xfebc55cf05ef2fbf), U64(0x2f71c5493a5be25a),

	U64(0x178831e02b8775b2), U64(0xd7b84fb5e0de02f0), U64(0x4cf4b1acc505eb02), U64(0xff2ca02deb5af054),
	U64(0x475dbafc509421a2), U64(0xc974fffbb9c5bcbd), U64(0x724bb3259de1f22f), U64(0x051bcfecd0485d42),

	U64(0x81b99d563b25e57a), U64(0xf4fc75ad58cca9f2), U64(0x5329b615e95c5bdf), U64(0xca21baeeba56a815),
	U64(0x6d148daab4ac1bb7), U64(0x4590974f7d6ec962), U64(0x0cef72d2cdef5930), U64(0x6803ad1d2c809a22),

	U64(0x3d5ceaecade87f00), U64(0x5d5675218dd4da7e), U64(0xa762655491b63283), U64(0x76618a18da1cfd9a),
	U64(0x9a9f5c4a59c51554), U64(0x8c4d65413c6bbfe6), U64(0x10a3d155d65cd6c1), U64(0x9e266498ec93bb5c),

	U64(0x11bea6e26eff78fd), U64(0x3ad2351100f322d5), U64(0x9e78abd3cd79162c), U64(0x2fdc971bd1756a88),
	U64(0xebdba47c4a9c567a), U64(0x94974a65ffaf78a4), U64(0xdae46bb9fceadb75), U64(0x06396ddce8fd9c68),

	// BlackPawn --------------------------------------------------------------------------------------
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

	// ================== HOLDING =====================================================================

	U64(0),							// Empty
	U64(0),							// WhiteKing
	U64(0x9d39247e33776d41),	// WhiteQueen
	U64(0x2af7398005aaa5c7),	// WhiteRook
	U64(0x44db015024623547),	// WhiteBishop
	U64(0x9c15f73e62a76ae2),	// WhiteKnight
	U64(0x75834465489c0c89),	// WhitePawn
	U64(0),							// (unused)
	U64(0),							// (unused)
	U64(0),							// BlackKing
	U64(0x3290ac3a203001bf),	// BlackQueen
	U64(0x0fbbad1f61042279),	// BlackRook
	U64(0xe83a908ff2fb60ca),	// BlackBishop
	U64(0x0d7e765d58755c10),	// BlackKnight
	U64(0x1a083822ceafe02d),	// BlackPawn

	// ================== CASTLING ====================================================================

	U64(0x38918d25eac93e11),	// WhiteQS
	U64(0x60c5f1b38762756d),	// WhiteKS
	U64(0x4a2da478101f9d64),	// BlackQS
	U64(0xfed940d4bb964ecb),	// BlackKS

	// ================== EN PASSANT ==================================================================

	U64(0xbc5e6419e34ab321),	// a3
	U64(0x3513a06b02fc5132),	// b3
	U64(0xb83ea9358f46207b),	// c3
	U64(0xe575a233ac88fbf0),	// d3
	U64(0x64c8173b165c69ac),	// e3
	U64(0xe361ef6d97725e14),	// f3
	U64(0x1ad0d77aa083746f),	// g3
	U64(0x29a2f875cbc5f61a),	// h3

	U64(0x0d929e0170d1eda7),	// a6
	U64(0xd13dda118259fd9f),	// b6
	U64(0xe8cb491492468f4b),	// c6
	U64(0x9c49ffc0f1b05f16),	// d6
	U64(0xb76ca00d646c4009),	// e6
	U64(0x99d8482b93ac2334),	// f6
	U64(0x9d8a11eda9fe0d09),	// g6
	U64(0x021f507b5b6d8771),	// h6

	// ================== TO MOVE =====================================================================

	U64(0xb1aac26e1c3caa9d),	// Black

	// ================== CHECKS GIVEN ================================================================

	// White ------------------------------------------------------------------------------------------
	0,
	U64(0x1e8860e4e8afcffc),	// one check given
	U64(0x107fb5302e49b653),	// two checks given
	U64(0x453ca2eb419de2c5),	// three check given

	// Black ------------------------------------------------------------------------------------------
	0,
	U64(0xa3094e8eb1649123),	// one check given
	U64(0xe850ac9a440dd0af),	// two checks given
	U64(0xe6eb2d90ade835b6),	// three check given

#undef U64
};

uint64_t const* const Pieces			= RandomTable;
uint64_t const* const Promoted		= Pieces + Num_Pieces_Entries;
uint64_t const* const Holding			= Promoted + Num_Promoted_Entries;
uint64_t const* const Castling		= Holding + Num_Holding_Entries;
uint64_t const* const EnPassant		= Castling + Num_Castling_Entries;
uint64_t const* const ToMove			= EnPassant + Num_EnPassant_Entries;
uint64_t const* const ChecksGiven	= ToMove + Num_ToMove_Entries;

} // namespace rand64
} // namespace db

#endif // _db_rand64_included

// vi:set ts=3 sw=3:
