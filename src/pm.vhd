library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PM is 
    port(
        clk : in std_logic;
        addr : in unsigned(10 downto 0);
        pm_out : out unsigned(15 downto 0);
        we : in std_logic; 
        w_addr : in unsigned(10 downto 0);
        w_data : in unsigned(15 downto 0)
    );
end PM;
--PM ska innehålla programmet vid start, bootloadern ska endast ladda in nya instruktioner 
architecture func of PM is 
    type PM_t is array(0 to 2047) of unsigned(15 downto 0);
    signal pm_data : PM_t := (
		0 => X"0000",
		1 => X"D890",
		2 => X"3080",
		3 => X"D903",
		4 => X"1908",
		5 => X"D880",
		6 => X"D980",
		7 => X"D0C8",
		8 => X"DD01",
		9 => X"1D00",
		10 => X"421A",
		11 => X"E680",
		12 => X"DDF8",
		13 => X"DA28",
		14 => X"D188",
		15 => X"B280",
		16 => X"2000",
		17 => X"0000",
		18 => X"E9A8",
		19 => X"6032",
		20 => X"B778",
		21 => X"EF30",
		22 => X"5820",
		23 => X"EF3A",
		24 => X"6020",
		25 => X"DD01",
		26 => X"CF30",
		27 => X"1D20",
		28 => X"C201",
		29 => X"1F20",
		30 => X"40D0",
		31 => X"CA01",
		32 => X"EF2B",
		33 => X"503D",
		34 => X"EF2D",
		35 => X"5040",
		36 => X"EF2A",
		37 => X"5043",
		38 => X"EF2F",
		39 => X"5046",
		40 => X"EF2E",
		41 => X"504D",
		42 => X"EF6E",
		43 => X"5049",
		44 => X"EF28",
		45 => X"5051",
		46 => X"EF29",
		47 => X"5055",
		48 => X"EF61",
		49 => X"503A",
		50 => X"EF08",
		51 => X"5059",
		52 => X"EF1A",
		53 => X"5063",
		54 => X"EF0A",
		55 => X"5098",
		56 => X"0000",
		57 => X"4010",
		58 => X"DF0A",
		59 => X"40D0",
		60 => X"1F20",
		61 => X"DF12",
		62 => X"40D0",
		63 => X"1F20",
		64 => X"DF13",
		65 => X"40D0",
		66 => X"1F20",
		67 => X"DF15",
		68 => X"40D0",
		69 => X"1F20",
		70 => X"DF16",
		71 => X"40D0",
		72 => X"1F20",
		73 => X"DF1E",
		74 => X"DD03",
		75 => X"40D0",
		76 => X"1D20",
		77 => X"DF1F",
		78 => X"DD02",
		79 => X"40D0",
		80 => X"1D20",
		81 => X"DF1B",
		82 => X"DD04",
		83 => X"40D0",
		84 => X"1D20",
		85 => X"DF1D",
		86 => X"DD05",
		87 => X"40D0",
		88 => X"1D20",
		89 => X"DD00",
		90 => X"0D18",
		91 => X"6010",
		92 => X"DF10",
		93 => X"C881",
		94 => X"C981",
		95 => X"4215",
		96 => X"E680",
		97 => X"CA02",
		98 => X"4010",
		99 => X"DCF8",
		100 => X"DA28",
		101 => X"B418",
		102 => X"8898",
		103 => X"D980",
		104 => X"0CD8",
		105 => X"508C",
		106 => X"C181",
		107 => X"1548",
		108 => X"1D20",
		109 => X"C481",
		110 => X"ED01",
		111 => X"6875",
		112 => X"C201",
		113 => X"1548",
		114 => X"1D20",
		115 => X"B750",
		116 => X"4082",
		117 => X"ED02",
		118 => X"5082",
		119 => X"DF1F",
		120 => X"ED03",
		121 => X"5082",
		122 => X"DF1E",
		123 => X"ED04",
		124 => X"5082",
		125 => X"DF1B",
		126 => X"ED05",
		127 => X"5082",
		128 => X"DF1D",
		129 => X"B750",
		130 => X"4215",
		131 => X"E680",
		132 => X"C081",
		133 => X"D140",
		134 => X"0880",
		135 => X"688A",
		136 => X"C481",
		137 => X"D880",
		138 => X"4068",
		139 => X"C201",
		140 => X"C981",
		141 => X"DF10",
		142 => X"B608",
		143 => X"09C0",
		144 => X"6096",
		145 => X"CC01",
		146 => X"4215",
		147 => X"E680",
		148 => X"408F",
		149 => X"C081",
		150 => X"B0E0",
		151 => X"4010",
		152 => X"DD10",
		153 => X"3500",
		154 => X"1750",
		155 => X"C704",
		156 => X"1F50",
		157 => X"D140",
		158 => X"C0D0",
		159 => X"8898",
		160 => X"0880",
		161 => X"58A4",
		162 => X"DD80",
		163 => X"8880",
		164 => X"D980",
		165 => X"DF10",
		166 => X"F880",
		167 => X"4215",
		168 => X"E680",
		169 => X"C081",
		170 => X"0880",
		171 => X"58AE",
		172 => X"0000",
		173 => X"8880",
		174 => X"EDCF",
		175 => X"58A7",
		176 => X"C581",
		177 => X"DD28",
		178 => X"DDF8",
		179 => X"0D20",
		180 => X"50BA",
		181 => X"1650",
		182 => X"1E58",
		183 => X"C501",
		184 => X"40B3",
		185 => X"C581",
		186 => X"F080",
		187 => X"40DA",
		188 => X"DA28",
		189 => X"425D",
		190 => X"E680",
		191 => X"B728",
		192 => X"D0C8",
		193 => X"B280",
		194 => X"437F",
		195 => X"E680",
		196 => X"B280",
		197 => X"415C",
		198 => X"E680",
		199 => X"B2F0",
		200 => X"4172",
		201 => X"E680",
		202 => X"4186",
		203 => X"E680",
		204 => X"421A",
		205 => X"E680",
		206 => X"400D",
		207 => X"0000",
		208 => X"4215",
		209 => X"E680",
		210 => X"D140",
		211 => X"C081",
		212 => X"0880",
		213 => X"58D8",
		214 => X"C202",
		215 => X"8880",
		216 => X"4010",
		217 => X"C181",
		218 => X"DD78",
		219 => X"DF01",
		220 => X"DC80",
		221 => X"0D58",
		222 => X"6145",
		223 => X"1650",
		224 => X"EF01",
		225 => X"50EA",
		226 => X"EF02",
		227 => X"5114",
		228 => X"EF03",
		229 => X"5134",
		230 => X"EF04",
		231 => X"5125",
		232 => X"C502",
		233 => X"414D",
		234 => X"EE04",
		235 => X"68F0",
		236 => X"D801",
		237 => X"C494",
		238 => X"40DD",
		239 => X"C502",
		240 => X"EE0A",
		241 => X"68FA",
		242 => X"0000",
		243 => X"1820",
		244 => X"C201",
		245 => X"D0C8",
		246 => X"1820",
		247 => X"C502",
		248 => X"40DD",
		249 => X"DF04",
		250 => X"1820",
		251 => X"C201",
		252 => X"1AA0",
		253 => X"1828",
		254 => X"C281",
		255 => X"D800",
		256 => X"1828",
		257 => X"EE03",
		258 => X"6907",
		259 => X"D801",
		260 => X"C502",
		261 => X"1828",
		262 => X"1650",
		263 => X"EE01",
		264 => X"694D",
		265 => X"C281",
		266 => X"D800",
		267 => X"1828",
		268 => X"C281",
		269 => X"C501",
		270 => X"1650",
		271 => X"1E28",
		272 => X"C281",
		273 => X"DF02",
		274 => X"40DD",
		275 => X"C501",
		276 => X"EE01",
		277 => X"6920",
		278 => X"C501",
		279 => X"1420",
		280 => X"1040",
		281 => X"C001",
		282 => X"1840",
		283 => X"1450",
		284 => X"1C28",
		285 => X"C281",
		286 => X"40DD",
		287 => X"C501",
		288 => X"EE02",
		289 => X"6925",
		290 => X"C501",
		291 => X"40DD",
		292 => X"DF03",
		293 => X"EE05",
		294 => X"692C",
		295 => X"0000",
		296 => X"CC94",
		297 => X"594D",
		298 => X"DF04",
		299 => X"40DD",
		300 => X"EE0B",
		301 => X"594D",
		302 => X"DF01",
		303 => X"8648",
		304 => X"C201",
		305 => X"1E20",
		306 => X"C202",
		307 => X"40DD",
		308 => X"EE01",
		309 => X"6925",
		310 => X"C502",
		311 => X"CD01",
		312 => X"1650",
		313 => X"C501",
		314 => X"1420",
		315 => X"1040",
		316 => X"C001",
		317 => X"1840",
		318 => X"C402",
		319 => X"1040",
		320 => X"C801",
		321 => X"1840",
		322 => X"1E28",
		323 => X"40DD",
		324 => X"C281",
		325 => X"EC80",
		326 => X"694D",
		327 => X"E680",
		328 => X"EF01",
		329 => X"514D",
		330 => X"C201",
		331 => X"40BD",
		332 => X"0000",
		333 => X"F880",
		334 => X"F880",
		335 => X"C895",
		336 => X"6154",
		337 => X"0000",
		338 => X"D140",
		339 => X"8080",
		340 => X"DF0E",
		341 => X"4215",
		342 => X"E680",
		343 => X"F080",
		344 => X"421A",
		345 => X"E680",
		346 => X"400D",
		347 => X"F080",
		348 => X"B528",
		349 => X"1350",
		350 => X"C502",
		351 => X"13D0",
		352 => X"B450",
		353 => X"C401",
		354 => X"8530",
		355 => X"0D40",
		356 => X"516D",
		357 => X"14D0",
		358 => X"EC80",
		359 => X"696D",
		360 => X"0000",
		361 => X"CB01",
		362 => X"CD01",
		363 => X"4163",
		364 => X"C381",
		365 => X"1B28",
		366 => X"C282",
		367 => X"1BA8",
		368 => X"4E80",
		369 => X"CA81",
		370 => X"FE80",
		371 => X"D0CA",
		372 => X"1300",
		373 => X"C802",
		374 => X"1380",
		375 => X"8338",
		376 => X"D065",
		377 => X"0B00",
		378 => X"614D",
		379 => X"D000",
		380 => X"C862",
		381 => X"0B00",
		382 => X"6183",
		383 => X"D0C8",
		384 => X"B280",
		385 => X"43A9",
		386 => X"E680",
		387 => X"F680",
		388 => X"4E80",
		389 => X"0000",
		390 => X"F880",
		391 => X"FD80",
		392 => X"FE80",
		393 => X"C8A8",
		394 => X"618D",
		395 => X"D140",
		396 => X"8080",
		397 => X"D0C8",
		398 => X"1480",
		399 => X"C001",
		400 => X"1580",
		401 => X"C001",
		402 => X"1600",
		403 => X"ED81",
		404 => X"6999",
		405 => X"DF1E",
		406 => X"4215",
		407 => X"E680",
		408 => X"C081",
		409 => X"EE00",
		410 => X"61C1",
		411 => X"C001",
		412 => X"DF00",
		413 => X"C701",
		414 => X"8758",
		415 => X"8748",
		416 => X"8F60",
		417 => X"EF15",
		418 => X"59C6",
		419 => X"0000",
		420 => X"1700",
		421 => X"4215",
		422 => X"E680",
		423 => X"C001",
		424 => X"C081",
		425 => X"EC81",
		426 => X"51F4",
		427 => X"DF1F",
		428 => X"4215",
		429 => X"E680",
		430 => X"C081",
		431 => X"8648",
		432 => X"CE01",
		433 => X"DC0D",
		434 => X"8C58",
		435 => X"0C48",
		436 => X"59B8",
		437 => X"0000",
		438 => X"B448",
		439 => X"CC02",
		440 => X"1700",
		441 => X"4215",
		442 => X"E680",
		443 => X"C001",
		444 => X"CC01",
		445 => X"61B8",
		446 => X"C081",
		447 => X"41F4",
		448 => X"0000",
		449 => X"B760",
		450 => X"8748",
		451 => X"8758",
		452 => X"EF15",
		453 => X"61A4",
		454 => X"DC00",
		455 => X"8C60",
		456 => X"8C48",
		457 => X"59DB",
		458 => X"0000",
		459 => X"DF00",
		460 => X"4215",
		461 => X"E680",
		462 => X"C081",
		463 => X"DF1F",
		464 => X"4215",
		465 => X"E680",
		466 => X"C081",
		467 => X"EC00",
		468 => X"51DB",
		469 => X"DF00",
		470 => X"4215",
		471 => X"E680",
		472 => X"CC01",
		473 => X"41D3",
		474 => X"C081",
		475 => X"8480",
		476 => X"CC81",
		477 => X"1700",
		478 => X"4215",
		479 => X"E680",
		480 => X"C081",
		481 => X"0848",
		482 => X"51EC",
		483 => X"C401",
		484 => X"EC00",
		485 => X"69DD",
		486 => X"C001",
		487 => X"DF1F",
		488 => X"4215",
		489 => X"E680",
		490 => X"41DD",
		491 => X"C081",
		492 => X"EC00",
		493 => X"6211",
		494 => X"C401",
		495 => X"DF00",
		496 => X"4215",
		497 => X"E680",
		498 => X"41EC",
		499 => X"C081",
		500 => X"EE00",
		501 => X"5211",
		502 => X"DF0E",
		503 => X"4215",
		504 => X"E680",
		505 => X"C081",
		506 => X"EE00",
		507 => X"6203",
		508 => X"DF1E",
		509 => X"4215",
		510 => X"E680",
		511 => X"D800",
		512 => X"8860",
		513 => X"B600",
		514 => X"C081",
		515 => X"DD00",
		516 => X"C501",
		517 => X"CE0A",
		518 => X"6204",
		519 => X"0000",
		520 => X"CD01",
		521 => X"C60A",
		522 => X"B750",
		523 => X"4215",
		524 => X"E680",
		525 => X"B760",
		526 => X"C081",
		527 => X"4215",
		528 => X"E680",
		529 => X"F680",
		530 => X"F580",
		531 => X"4E80",
		532 => X"F080",
		533 => X"DD08",
		534 => X"3500",
		535 => X"8508",
		536 => X"4E80",
		537 => X"1F50",
		538 => X"F800",
		539 => X"F880",
		540 => X"FE80",
		541 => X"DF14",
		542 => X"C894",
		543 => X"6224",
		544 => X"E880",
		545 => X"5224",
		546 => X"D140",
		547 => X"8080",
		548 => X"D013",
		549 => X"4215",
		550 => X"E680",
		551 => X"C801",
		552 => X"6225",
		553 => X"C081",
		554 => X"D0FF",
		555 => X"8880",
		556 => X"6231",
		557 => X"E880",
		558 => X"5231",
		559 => X"D140",
		560 => X"8080",
		561 => X"DF01",
		562 => X"4215",
		563 => X"E680",
		564 => X"C081",
		565 => X"DF03",
		566 => X"4215",
		567 => X"E680",
		568 => X"C081",
		569 => X"DF03",
		570 => X"4215",
		571 => X"E680",
		572 => X"C081",
		573 => X"DF07",
		574 => X"4215",
		575 => X"E680",
		576 => X"C081",
		577 => X"DF1E",
		578 => X"4215",
		579 => X"E680",
		580 => X"C081",
		581 => X"DF0C",
		582 => X"4215",
		583 => X"E680",
		584 => X"C081",
		585 => X"DF0A",
		586 => X"4215",
		587 => X"E680",
		588 => X"C081",
		589 => X"DF01",
		590 => X"4215",
		591 => X"E680",
		592 => X"C081",
		593 => X"DF0C",
		594 => X"4215",
		595 => X"E680",
		596 => X"C081",
		597 => X"DF1A",
		598 => X"4215",
		599 => X"E680",
		600 => X"C081",
		601 => X"F680",
		602 => X"F080",
		603 => X"4E80",
		604 => X"F000",
		605 => X"FE80",
		606 => X"FD80",
		607 => X"F880",
		608 => X"F900",
		609 => X"F980",
		610 => X"FA00",
		611 => X"DB80",
		612 => X"429C",
		613 => X"E680",
		614 => X"EE1F",
		615 => X"5A6B",
		616 => X"0000",
		617 => X"CE14",
		618 => X"4266",
		619 => X"EE0A",
		620 => X"6270",
		621 => X"EE0A",
		622 => X"5A88",
		623 => X"0000",
		624 => X"B0E0",
		625 => X"CD81",
		626 => X"1158",
		627 => X"C584",
		628 => X"11D8",
		629 => X"B428",
		630 => X"CD83",
		631 => X"FD80",
		632 => X"B4D8",
		633 => X"C484",
		634 => X"0CA0",
		635 => X"5281",
		636 => X"1548",
		637 => X"1D58",
		638 => X"C581",
		639 => X"427A",
		640 => X"C481",
		641 => X"CA04",
		642 => X"42AD",
		643 => X"E680",
		644 => X"F580",
		645 => X"CD81",
		646 => X"4263",
		647 => X"1C58",
		648 => X"D0C8",
		649 => X"C581",
		650 => X"1658",
		651 => X"1460",
		652 => X"C403",
		653 => X"1560",
		654 => X"1D00",
		655 => X"C601",
		656 => X"CC01",
		657 => X"EC00",
		658 => X"6A8D",
		659 => X"C001",
		660 => X"F200",
		661 => X"F180",
		662 => X"F100",
		663 => X"F080",
		664 => X"F580",
		665 => X"F680",
		666 => X"4E80",
		667 => X"0000",
		668 => X"DE00",
		669 => X"DBA8",
		670 => X"B5B8",
		671 => X"1658",
		672 => X"C382",
		673 => X"0BA0",
		674 => X"52AB",
		675 => X"1538",
		676 => X"0D60",
		677 => X"5AA0",
		678 => X"0000",
		679 => X"B650",
		680 => X"B5B8",
		681 => X"42A0",
		682 => X"0000",
		683 => X"4E80",
		684 => X"0000",
		685 => X"FA00",
		686 => X"FC00",
		687 => X"FE80",
		688 => X"42C3",
		689 => X"E680",
		690 => X"D2BF",
		691 => X"B680",
		692 => X"E896",
		693 => X"54AE",
		694 => X"E895",
		695 => X"5310",
		696 => X"E892",
		697 => X"53C2",
		698 => X"E893",
		699 => X"53C2",
		700 => X"0000",
		701 => X"9800",
		702 => X"0000",
		703 => X"F680",
		704 => X"F400",
		705 => X"4E80",
		706 => X"F200",
		707 => X"C101",
		708 => X"C181",
		709 => X"1310",
		710 => X"1398",
		711 => X"C901",
		712 => X"C981",
		713 => X"E892",
		714 => X"52D3",
		715 => X"E893",
		716 => X"52DF",
		717 => X"E895",
		718 => X"52EB",
		719 => X"E896",
		720 => X"52EB",
		721 => X"0000",
		722 => X"9800",
		723 => X"EB00",
		724 => X"6ADA",
		725 => X"EB80",
		726 => X"52F0",
		727 => X"0000",
		728 => X"42F0",
		729 => X"D893",
		730 => X"EB80",
		731 => X"52F5",
		732 => X"D893",
		733 => X"42EE",
		734 => X"D892",
		735 => X"EB00",
		736 => X"6AE6",
		737 => X"EB80",
		738 => X"52F0",
		739 => X"0000",
		740 => X"42F0",
		741 => X"D892",
		742 => X"EB80",
		743 => X"6AF5",
		744 => X"0000",
		745 => X"42EE",
		746 => X"D892",
		747 => X"0B38",
		748 => X"52F0",
		749 => X"0000",
		750 => X"42F1",
		751 => X"DB01",
		752 => X"DB00",
		753 => X"C281",
		754 => X"1B28",
		755 => X"42F9",
		756 => X"CA81",
		757 => X"B490",
		758 => X"B118",
		759 => X"42F9",
		760 => X"B1C8",
		761 => X"4E80",
		762 => X"0000",
		763 => X"FC80",
		764 => X"FE00",
		765 => X"DC80",
		766 => X"EE00",
		767 => X"530B",
		768 => X"DD00",
		769 => X"EE00",
		770 => X"530B",
		771 => X"0000",
		772 => X"8558",
		773 => X"ED0A",
		774 => X"5B01",
		775 => X"CE01",
		776 => X"C481",
		777 => X"4301",
		778 => X"CD0A",
		779 => X"B5D0",
		780 => X"B548",
		781 => X"F600",
		782 => X"4E80",
		783 => X"F480",
		784 => X"F900",
		785 => X"F980",
		786 => X"FA80",
		787 => X"FE80",
		788 => X"43A9",
		789 => X"E680",
		790 => X"D34B",
		791 => X"B680",
		792 => X"43B4",
		793 => X"E000",
		794 => X"B310",
		795 => X"B118",
		796 => X"43B4",
		797 => X"E000",
		798 => X"B130",
		799 => X"1310",
		800 => X"C102",
		801 => X"1398",
		802 => X"C182",
		803 => X"81B8",
		804 => X"DC80",
		805 => X"DC00",
		806 => X"8130",
		807 => X"1618",
		808 => X"1590",
		809 => X"42FB",
		810 => X"E680",
		811 => X"B740",
		812 => X"8748",
		813 => X"4357",
		814 => X"E680",
		815 => X"C401",
		816 => X"0C30",
		817 => X"5B28",
		818 => X"C901",
		819 => X"C481",
		820 => X"0CB8",
		821 => X"5B25",
		822 => X"C981",
		823 => X"F680",
		824 => X"F280",
		825 => X"F180",
		826 => X"F100",
		827 => X"C102",
		828 => X"1310",
		829 => X"C182",
		830 => X"1398",
		831 => X"C282",
		832 => X"1428",
		833 => X"8338",
		834 => X"8340",
		835 => X"1B28",
		836 => X"C902",
		837 => X"C982",
		838 => X"CA82",
		839 => X"1328",
		840 => X"C283",
		841 => X"4E80",
		842 => X"82B0",
		843 => X"F680",
		844 => X"F280",
		845 => X"F180",
		846 => X"F100",
		847 => X"C281",
		848 => X"D000",
		849 => X"1828",
		850 => X"CA81",
		851 => X"1328",
		852 => X"C283",
		853 => X"4E80",
		854 => X"82B0",
		855 => X"F900",
		856 => X"F980",
		857 => X"FA80",
		858 => X"FB00",
		859 => X"FB80",
		860 => X"FC00",
		861 => X"FC80",
		862 => X"FE00",
		863 => X"FE80",
		864 => X"DA00",
		865 => X"DB02",
		866 => X"1B20",
		867 => X"C201",
		868 => X"DB00",
		869 => X"1B20",
		870 => X"C201",
		871 => X"1F20",
		872 => X"C201",
		873 => X"1D20",
		874 => X"C201",
		875 => X"1DA0",
		876 => X"D892",
		877 => X"D900",
		878 => X"B1A8",
		879 => X"FA80",
		880 => X"43C2",
		881 => X"E680",
		882 => X"F280",
		883 => X"437F",
		884 => X"E680",
		885 => X"F680",
		886 => X"F600",
		887 => X"F480",
		888 => X"F400",
		889 => X"F380",
		890 => X"F300",
		891 => X"F280",
		892 => X"F180",
		893 => X"4E80",
		894 => X"F100",
		895 => X"FA00",
		896 => X"FB00",
		897 => X"FB80",
		898 => X"FC00",
		899 => X"FC80",
		900 => X"FA80",
		901 => X"1328",
		902 => X"DB81",
		903 => X"C283",
		904 => X"FA80",
		905 => X"0B38",
		906 => X"5392",
		907 => X"1428",
		908 => X"EC00",
		909 => X"6B92",
		910 => X"0000",
		911 => X"C281",
		912 => X"4389",
		913 => X"C381",
		914 => X"B228",
		915 => X"F280",
		916 => X"CB81",
		917 => X"FB80",
		918 => X"0B38",
		919 => X"5B9F",
		920 => X"0000",
		921 => X"14A0",
		922 => X"1CA8",
		923 => X"C201",
		924 => X"C281",
		925 => X"4396",
		926 => X"C381",
		927 => X"F380",
		928 => X"8B38",
		929 => X"F280",
		930 => X"1B28",
		931 => X"F480",
		932 => X"F400",
		933 => X"F380",
		934 => X"F300",
		935 => X"4E80",
		936 => X"F200",
		937 => X"FA80",
		938 => X"D001",
		939 => X"1828",
		940 => X"D000",
		941 => X"C282",
		942 => X"1828",
		943 => X"C281",
		944 => X"1828",
		945 => X"CA83",
		946 => X"4E80",
		947 => X"F280",
		948 => X"F900",
		949 => X"1510",
		950 => X"C103",
		951 => X"8510",
		952 => X"1590",
		953 => X"ED80",
		954 => X"6BC0",
		955 => X"C101",
		956 => X"0950",
		957 => X"6BB8",
		958 => X"0000",
		959 => X"B068",
		960 => X"4800",
		961 => X"F100",
		962 => X"FE80",
		963 => X"43D8",
		964 => X"E680",
		965 => X"FA00",
		966 => X"4403",
		967 => X"E680",
		968 => X"F200",
		969 => X"B2A0",
		970 => X"F680",
		971 => X"4E80",
		972 => X"C281",
		973 => X"0D58",
		974 => X"63D1",
		975 => X"B650",
		976 => X"B658",
		977 => X"4E80",
		978 => X"0D58",
		979 => X"5BD6",
		980 => X"B650",
		981 => X"B658",
		982 => X"4E80",
		983 => X"0000",
		984 => X"FE80",
		985 => X"B228",
		986 => X"1290",
		987 => X"1318",
		988 => X"C102",
		989 => X"C182",
		990 => X"1410",
		991 => X"1498",
		992 => X"B540",
		993 => X"B5C8",
		994 => X"43D2",
		995 => X"E680",
		996 => X"8528",
		997 => X"85B0",
		998 => X"B060",
		999 => X"43CD",
		1000 => X"E680",
		1001 => X"8E00",
		1002 => X"E892",
		1003 => X"53EF",
		1004 => X"E893",
		1005 => X"53F0",
		1006 => X"0000",
		1007 => X"C601",
		1008 => X"EE28",
		1009 => X"5BF8",
		1010 => X"0000",
		1011 => X"B760",
		1012 => X"CF28",
		1013 => X"8070",
		1014 => X"43F8",
		1015 => X"DE28",
		1016 => X"1E20",
		1017 => X"C202",
		1018 => X"1820",
		1019 => X"B3E0",
		1020 => X"8260",
		1021 => X"B500",
		1022 => X"8128",
		1023 => X"81B0",
		1024 => X"F680",
		1025 => X"4E80",
		1026 => X"0000",
		1027 => X"FE80",
		1028 => X"DF00",
		1029 => X"EA81",
		1030 => X"5C15",
		1031 => X"EB01",
		1032 => X"5C10",
		1033 => X"0C48",
		1034 => X"5424",
		1035 => X"0C48",
		1036 => X"5C1E",
		1037 => X"0000",
		1038 => X"4418",
		1039 => X"0000",
		1040 => X"0CC0",
		1041 => X"5C2D",
		1042 => X"C481",
		1043 => X"441E",
		1044 => X"0000",
		1045 => X"0C48",
		1046 => X"5C2D",
		1047 => X"C401",
		1048 => X"CB01",
		1049 => X"C481",
		1050 => X"DD80",
		1051 => X"1618",
		1052 => X"442F",
		1053 => X"C981",
		1054 => X"CA81",
		1055 => X"C401",
		1056 => X"1590",
		1057 => X"DE00",
		1058 => X"442F",
		1059 => X"C901",
		1060 => X"CA81",
		1061 => X"CB01",
		1062 => X"C401",
		1063 => X"C481",
		1064 => X"1590",
		1065 => X"1618",
		1066 => X"C901",
		1067 => X"442F",
		1068 => X"C981",
		1069 => X"DD80",
		1070 => X"DE00",
		1071 => X"E892",
		1072 => X"5434",
		1073 => X"E893",
		1074 => X"5439",
		1075 => X"0000",
		1076 => X"EB82",
		1077 => X"644A",
		1078 => X"D469",
		1079 => X"4454",
		1080 => X"1F20",
		1081 => X"EB81",
		1082 => X"644A",
		1083 => X"D475",
		1084 => X"CA02",
		1085 => X"EF00",
		1086 => X"5454",
		1087 => X"0000",
		1088 => X"4457",
		1089 => X"E680",
		1090 => X"CA01",
		1091 => X"1520",
		1092 => X"ED01",
		1093 => X"6C48",
		1094 => X"C501",
		1095 => X"CD02",
		1096 => X"4454",
		1097 => X"1D20",
		1098 => X"4800",
		1099 => X"E680",
		1100 => X"0D40",
		1101 => X"6405",
		1102 => X"0D48",
		1103 => X"6405",
		1104 => X"1DA0",
		1105 => X"CA01",
		1106 => X"4405",
		1107 => X"CB81",
		1108 => X"F680",
		1109 => X"4E80",
		1110 => X"0000",
		1111 => X"FF00",
		1112 => X"FE80",
		1113 => X"DF00",
		1114 => X"1320",
		1115 => X"C202",
		1116 => X"8230",
		1117 => X"DD80",
		1118 => X"1620",
		1119 => X"4475",
		1120 => X"E680",
		1121 => X"1DA0",
		1122 => X"CB01",
		1123 => X"EB01",
		1124 => X"645D",
		1125 => X"CA01",
		1126 => X"F680",
		1127 => X"4E80",
		1128 => X"F700",
		1129 => X"85E0",
		1130 => X"85F0",
		1131 => X"ED8A",
		1132 => X"6471",
		1133 => X"0000",
		1134 => X"DF00",
		1135 => X"4473",
		1136 => X"0000",
		1137 => X"DF01",
		1138 => X"CD8A",
		1139 => X"4E80",
		1140 => X"0000",
		1141 => X"8DE0",
		1142 => X"8DF0",
		1143 => X"ED80",
		1144 => X"5C7D",
		1145 => X"0000",
		1146 => X"DF00",
		1147 => X"447F",
		1148 => X"0000",
		1149 => X"DF01",
		1150 => X"C58A",
		1151 => X"4E80",
		1152 => X"0000",
		1153 => X"F900",
		1154 => X"F980",
		1155 => X"1510",
		1156 => X"1598",
		1157 => X"0D58",
		1158 => X"6C94",
		1159 => X"C103",
		1160 => X"C183",
		1161 => X"B658",
		1162 => X"1510",
		1163 => X"1598",
		1164 => X"0D58",
		1165 => X"6C94",
		1166 => X"CE01",
		1167 => X"C181",
		1168 => X"EE01",
		1169 => X"648A",
		1170 => X"C101",
		1171 => X"4497",
		1172 => X"0D58",
		1173 => X"5C98",
		1174 => X"0000",
		1175 => X"B680",
		1176 => X"F180",
		1177 => X"4E80",
		1178 => X"F100",
		1179 => X"F900",
		1180 => X"1510",
		1181 => X"1D28",
		1182 => X"C102",
		1183 => X"C281",
		1184 => X"DD80",
		1185 => X"1DA8",
		1186 => X"C281",
		1187 => X"1DA8",
		1188 => X"C101",
		1189 => X"C281",
		1190 => X"1590",
		1191 => X"1DA8",
		1192 => X"ED02",
		1193 => X"64A4",
		1194 => X"CD01",
		1195 => X"C281",
		1196 => X"4E80",
		1197 => X"F100",
		1198 => X"FE80",
		1199 => X"B210",
		1200 => X"B118",
		1201 => X"D568",
		1202 => X"B680",
		1203 => X"43B4",
		1204 => X"E000",
		1205 => X"B120",
		1206 => X"C102",
		1207 => X"C182",
		1208 => X"C282",
		1209 => X"1510",
		1210 => X"1598",
		1211 => X"8D58",
		1212 => X"1D28",
		1213 => X"C902",
		1214 => X"C982",
		1215 => X"CA82",
		1216 => X"DD00",
		1217 => X"1D28",
		1218 => X"B228",
		1219 => X"C2AB",
		1220 => X"B310",
		1221 => X"B118",
		1222 => X"B1A8",
		1223 => X"449B",
		1224 => X"E680",
		1225 => X"B130",
		1226 => X"B328",
		1227 => X"449B",
		1228 => X"E680",
		1229 => X"B130",
		1230 => X"1310",
		1231 => X"DB81",
		1232 => X"DC00",
		1233 => X"D8A9",
		1234 => X"B528",
		1235 => X"B290",
		1236 => X"437F",
		1237 => X"E680",
		1238 => X"B298",
		1239 => X"437F",
		1240 => X"E680",
		1241 => X"B2D0",
		1242 => X"1518",
		1243 => X"CD27",
		1244 => X"5CE5",
		1245 => X"C501",
		1246 => X"C202",
		1247 => X"15A0",
		1248 => X"8DD0",
		1249 => X"1DA0",
		1250 => X"CA02",
		1251 => X"DD26",
		1252 => X"1D18",
		1253 => X"1B90",
		1254 => X"D500",
		1255 => X"4481",
		1256 => X"E680",
		1257 => X"0B38",
		1258 => X"54EE",
		1259 => X"C401",
		1260 => X"44E5",
		1261 => X"C381",
		1262 => X"EB28",
		1263 => X"555A",
		1264 => X"C381",
		1265 => X"C301",
		1266 => X"1B10",
		1267 => X"C102",
		1268 => X"8130",
		1269 => X"D800",
		1270 => X"1810",
		1271 => X"C902",
		1272 => X"E8A9",
		1273 => X"6CFD",
		1274 => X"0000",
		1275 => X"10A0",
		1276 => X"80C0",
		1277 => X"C281",
		1278 => X"44E6",
		1279 => X"8930",
		1280 => X"DC80",
		1281 => X"DD00",
		1282 => X"C281",
		1283 => X"1D28",
		1284 => X"CA81",
		1285 => X"F880",
		1286 => X"D893",
		1287 => X"F900",
		1288 => X"F980",
		1289 => X"FA00",
		1290 => X"FA80",
		1291 => X"FB00",
		1292 => X"FB80",
		1293 => X"FC00",
		1294 => X"FC80",
		1295 => X"43C2",
		1296 => X"E680",
		1297 => X"F480",
		1298 => X"F400",
		1299 => X"F380",
		1300 => X"F300",
		1301 => X"F280",
		1302 => X"F200",
		1303 => X"F180",
		1304 => X"F100",
		1305 => X"F080",
		1306 => X"C281",
		1307 => X"1528",
		1308 => X"ED01",
		1309 => X"552B",
		1310 => X"CA81",
		1311 => X"C481",
		1312 => X"B510",
		1313 => X"B128",
		1314 => X"B2D0",
		1315 => X"B628",
		1316 => X"449B",
		1317 => X"E680",
		1318 => X"B160",
		1319 => X"B290",
		1320 => X"C283",
		1321 => X"4501",
		1322 => X"82B0",
		1323 => X"DD83",
		1324 => X"1520",
		1325 => X"85D0",
		1326 => X"C501",
		1327 => X"8540",
		1328 => X"ED29",
		1329 => X"655A",
		1330 => X"0000",
		1331 => X"1D20",
		1332 => X"8258",
		1333 => X"EC01",
		1334 => X"5D3D",
		1335 => X"DE00",
		1336 => X"1E20",
		1337 => X"CC01",
		1338 => X"C581",
		1339 => X"4535",
		1340 => X"C201",
		1341 => X"1CA0",
		1342 => X"8A58",
		1343 => X"1B10",
		1344 => X"15A0",
		1345 => X"B2A0",
		1346 => X"437F",
		1347 => X"E680",
		1348 => X"1520",
		1349 => X"8DD0",
		1350 => X"C282",
		1351 => X"1528",
		1352 => X"8D58",
		1353 => X"1D28",
		1354 => X"B290",
		1355 => X"437F",
		1356 => X"E680",
		1357 => X"1590",
		1358 => X"8B58",
		1359 => X"8BB0",
		1360 => X"B358",
		1361 => X"C283",
		1362 => X"82B0",
		1363 => X"DC00",
		1364 => X"CC01",
		1365 => X"0B38",
		1366 => X"6CE5",
		1367 => X"D4E5",
		1368 => X"43B4",
		1369 => X"E680",
		1370 => X"E8A9",
		1371 => X"5563",
		1372 => X"1520",
		1373 => X"C202",
		1374 => X"15A0",
		1375 => X"8DD0",
		1376 => X"8588",
		1377 => X"1DA0",
		1378 => X"CA02",
		1379 => X"B2A0",
		1380 => X"C283",
		1381 => X"F680",
		1382 => X"4E80",
		1383 => X"82D0",
		1384 => X"DD01",
		1385 => X"1D28",
		1386 => X"C282",
		1387 => X"DD7F",
		1388 => X"1D28",
		1389 => X"F680",
		1390 => X"4E80",
		1391 => X"C282",
		
		others => (others => '0')
    );


begin
    process(clk) begin
        if rising_edge(clk) then
            if we = '1' then 
                pm_data(to_integer(w_addr)) <= w_data;
            end if;
            pm_out <= pm_data(to_integer(addr));
        end if;
    end process;
end architecture;