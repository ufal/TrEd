#=======================================================================
#  ____  ____  _____              _    ____ ___   ____
# |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
# | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
# |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
# |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
# Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
# This library is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
#=======================================================================

$fonts->{'timesroman'} = {
  'apiname' => 'Ti1',
  'fontname' => 'Times-Roman',
  'type' => 'Type1',
  'ascender' => '683',
  'capheight' => '662',
  'descender' => '-217',
  'fontbbox' => ['-168','-218','1000','898'],
  'iscore' => 1,
  'isfixedpitch' => 0,
  'italicangle' => '0',
  'missingwidth' => '250',
  'stdhw' => '28',
  'stdvw' => '84',
  'underlineposition' => '-100',
  'underlinethickness' => '50',
  'xheight' => '450',
  'char' => [
    'grave'                                 , # ? # 0x00, 0o000, 0
    'acute'                                 , # ? # 0x01, 0o001, 1
    'circumflex'                            , # ? # 0x02, 0o002, 2
    'tilde'                                 , # ? # 0x03, 0o003, 3
    'dieresis'                              , # ? # 0x04, 0o004, 4
    'hungarumlaut'                          , # ? # 0x05, 0o005, 5
    'ring'                                  , # ? # 0x06, 0o006, 6
    'caron'                                 , # ? # 0x07, 0o007, 7
    'breve'                                 , # ? # 0x08, 0o010, 8
    'macron'                                , # ? # 0x09, 0o011, 9
    'dotaccent'                             , # ? # 0x0A, 0o012, 10
    'cedilla'                               , # ? # 0x0B, 0o013, 11
    'ogonek'                                , # ? # 0x0C, 0o014, 12
    'quotesinglbase'                        , # ? # 0x0D, 0o015, 13
    'guilsinglleft'                         , # ? # 0x0E, 0o016, 14
    'guilsinglright'                        , # ? # 0x0F, 0o017, 15
    'quotedblleft'                          , # ? # 0x10, 0o020, 16
    'quotedblright'                         , # ? # 0x11, 0o021, 17
    'quotedblbase'                          , # ? # 0x12, 0o022, 18
    'guillemotleft'                         , # ? # 0x13, 0o023, 19
    'guillemotright'                        , # ? # 0x14, 0o024, 20
    'endash'                                , # ? # 0x15, 0o025, 21
    'emdash'                                , # ? # 0x16, 0o026, 22
    'compwordmark'                          , # ? # 0x17, 0o027, 23
    'perthousandzero'                       , # ? # 0x18, 0o030, 24
    'dotlessi'                              , # ? # 0x19, 0o031, 25
    'dotlessj'                              , # ? # 0x1A, 0o032, 26
    'ff'                                    , # ? # 0x1B, 0o033, 27
    'fi'                                    , # ? # 0x1C, 0o034, 28
    'fl'                                    , # ? # 0x1D, 0o035, 29
    'ffi'                                   , # ? # 0x1E, 0o036, 30
    'ffl'                                   , # ? # 0x1F, 0o037, 31
    'space'                                 , # 0x20, 0o040, 32
    'exclam'                                , # 0x21, 0o041, 33
    'quotedbl'                              , # 0x22, 0o042, 34
    'numbersign'                            , # 0x23, 0o043, 35
    'dollar'                                , # 0x24, 0o044, 36
    'percent'                               , # 0x25, 0o045, 37
    'ampersand'                             , # 0x26, 0o046, 38
    'quotesingle'                           , # 0x27, 0o047, 39
    'parenleft'                             , # 0x28, 0o050, 40
    'parenright'                            , # 0x29, 0o051, 41
    'asterisk'                              , # 0x2A, 0o052, 42
    'plus'                                  , # 0x2B, 0o053, 43
    'comma'                                 , # 0x2C, 0o054, 44
    'hyphen'                                , # 0x2D, 0o055, 45
    'period'                                , # 0x2E, 0o056, 46
    'slash'                                 , # 0x2F, 0o057, 47
    'zero'                                  , # 0x30, 0o060, 48
    'one'                                   , # 0x31, 0o061, 49
    'two'                                   , # 0x32, 0o062, 50
    'three'                                 , # 0x33, 0o063, 51
    'four'                                  , # 0x34, 0o064, 52
    'five'                                  , # 0x35, 0o065, 53
    'six'                                   , # 0x36, 0o066, 54
    'seven'                                 , # 0x37, 0o067, 55
    'eight'                                 , # 0x38, 0o070, 56
    'nine'                                  , # 0x39, 0o071, 57
    'colon'                                 , # 0x3A, 0o072, 58
    'semicolon'                             , # 0x3B, 0o073, 59
    'less'                                  , # 0x3C, 0o074, 60
    'equal'                                 , # 0x3D, 0o075, 61
    'greater'                               , # 0x3E, 0o076, 62
    'question'                              , # 0x3F, 0o077, 63
    'at'                                    , # 0x40, 0o100, 64
    'A'                                     , # 0x41, 0o101, 65
    'B'                                     , # 0x42, 0o102, 66
    'C'                                     , # 0x43, 0o103, 67
    'D'                                     , # 0x44, 0o104, 68
    'E'                                     , # 0x45, 0o105, 69
    'F'                                     , # 0x46, 0o106, 70
    'G'                                     , # 0x47, 0o107, 71
    'H'                                     , # 0x48, 0o110, 72
    'I'                                     , # 0x49, 0o111, 73
    'J'                                     , # 0x4A, 0o112, 74
    'K'                                     , # 0x4B, 0o113, 75
    'L'                                     , # 0x4C, 0o114, 76
    'M'                                     , # 0x4D, 0o115, 77
    'N'                                     , # 0x4E, 0o116, 78
    'O'                                     , # 0x4F, 0o117, 79
    'P'                                     , # 0x50, 0o120, 80
    'Q'                                     , # 0x51, 0o121, 81
    'R'                                     , # 0x52, 0o122, 82
    'S'                                     , # 0x53, 0o123, 83
    'T'                                     , # 0x54, 0o124, 84
    'U'                                     , # 0x55, 0o125, 85
    'V'                                     , # 0x56, 0o126, 86
    'W'                                     , # 0x57, 0o127, 87
    'X'                                     , # 0x58, 0o130, 88
    'Y'                                     , # 0x59, 0o131, 89
    'Z'                                     , # 0x5A, 0o132, 90
    'bracketleft'                           , # 0x5B, 0o133, 91
    'backslash'                             , # 0x5C, 0o134, 92
    'bracketright'                          , # 0x5D, 0o135, 93
    'asciicircum'                           , # 0x5E, 0o136, 94
    'underscore'                            , # 0x5F, 0o137, 95
    'grave'                                 , # 0x60, 0o140, 96
    'a'                                     , # 0x61, 0o141, 97
    'b'                                     , # 0x62, 0o142, 98
    'c'                                     , # 0x63, 0o143, 99
    'd'                                     , # 0x64, 0o144, 100
    'e'                                     , # 0x65, 0o145, 101
    'f'                                     , # 0x66, 0o146, 102
    'g'                                     , # 0x67, 0o147, 103
    'h'                                     , # 0x68, 0o150, 104
    'i'                                     , # 0x69, 0o151, 105
    'j'                                     , # 0x6A, 0o152, 106
    'k'                                     , # 0x6B, 0o153, 107
    'l'                                     , # 0x6C, 0o154, 108
    'm'                                     , # 0x6D, 0o155, 109
    'n'                                     , # 0x6E, 0o156, 110
    'o'                                     , # 0x6F, 0o157, 111
    'p'                                     , # 0x70, 0o160, 112
    'q'                                     , # 0x71, 0o161, 113
    'r'                                     , # 0x72, 0o162, 114
    's'                                     , # 0x73, 0o163, 115
    't'                                     , # 0x74, 0o164, 116
    'u'                                     , # 0x75, 0o165, 117
    'v'                                     , # 0x76, 0o166, 118
    'w'                                     , # 0x77, 0o167, 119
    'x'                                     , # 0x78, 0o170, 120
    'y'                                     , # 0x79, 0o171, 121
    'z'                                     , # 0x7A, 0o172, 122
    'braceleft'                             , # 0x7B, 0o173, 123
    'bar'                                   , # 0x7C, 0o174, 124
    'braceright'                            , # 0x7D, 0o175, 125
    'asciitilde'                            , # 0x7E, 0o176, 126
    'bullet'                                , # ? # 0x7F, 0o177, 127
    'Euro'                                  , # ? # 0x80, 0o200, 128
    'bullet'                                , # ? # 0x81, 0o201, 129
    'quotesinglbase'                        , # ? # 0x82, 0o202, 130
    'florin'                                , # ? # 0x83, 0o203, 131
    'quotedblbase'                          , # ? # 0x84, 0o204, 132
    'ellipsis'                              , # ? # 0x85, 0o205, 133
    'dagger'                                , # ? # 0x86, 0o206, 134
    'daggerdbl'                             , # ? # 0x87, 0o207, 135
    'circumflex'                            , # ? # 0x88, 0o210, 136
    'perthousand'                           , # ? # 0x89, 0o211, 137
    'Scaron'                                , # ? # 0x8A, 0o212, 138
    'guilsinglleft'                         , # ? # 0x8B, 0o213, 139
    'OE'                                    , # ? # 0x8C, 0o214, 140
    'bullet'                                , # ? # 0x8D, 0o215, 141
    'Zcaron'                                , # ? # 0x8E, 0o216, 142
    'bullet'                                , # ? # 0x8F, 0o217, 143
    'bullet'                                , # ? # 0x90, 0o220, 144
    'quoteleft'                             , # ? # 0x91, 0o221, 145
    'quoteright'                            , # ? # 0x92, 0o222, 146
    'quotedblleft'                          , # ? # 0x93, 0o223, 147
    'quotedblright'                         , # ? # 0x94, 0o224, 148
    'bullet'                                , # ? # 0x95, 0o225, 149
    'endash'                                , # ? # 0x96, 0o226, 150
    'emdash'                                , # ? # 0x97, 0o227, 151
    'tilde'                                 , # ? # 0x98, 0o230, 152
    'trademark'                             , # ? # 0x99, 0o231, 153
    'scaron'                                , # ? # 0x9A, 0o232, 154
    'guilsinglright'                        , # ? # 0x9B, 0o233, 155
    'oe'                                    , # ? # 0x9C, 0o234, 156
    'bullet'                                , # ? # 0x9D, 0o235, 157
    'zcaron'                                , # ? # 0x9E, 0o236, 158
    'Ydieresis'                             , # ? # 0x9F, 0o237, 159
    'space'                                 , # 0xA0, 0o240, 160
    'exclamdown'                            , # 0xA1, 0o241, 161
    'cent'                                  , # 0xA2, 0o242, 162
    'sterling'                              , # 0xA3, 0o243, 163
    'currency'                              , # 0xA4, 0o244, 164
    'yen'                                   , # 0xA5, 0o245, 165
    'brokenbar'                             , # 0xA6, 0o246, 166
    'section'                               , # 0xA7, 0o247, 167
    'dieresis'                              , # 0xA8, 0o250, 168
    'copyright'                             , # 0xA9, 0o251, 169
    'ordfeminine'                           , # 0xAA, 0o252, 170
    'guillemotleft'                         , # 0xAB, 0o253, 171
    'logicalnot'                            , # 0xAC, 0o254, 172
    'hyphen'                                , # 0xAD, 0o255, 173
    'registered'                            , # 0xAE, 0o256, 174
    'overscore'                             , # 0xAF, 0o257, 175
    'degree'                                , # 0xB0, 0o260, 176
    'plusminus'                             , # 0xB1, 0o261, 177
    'twosuperior'                           , # 0xB2, 0o262, 178
    'threesuperior'                         , # 0xB3, 0o263, 179
    'acute'                                 , # 0xB4, 0o264, 180
    'mu1'                                   , # 0xB5, 0o265, 181
    'paragraph'                             , # 0xB6, 0o266, 182
    'periodcentered'                        , # 0xB7, 0o267, 183
    'cedilla'                               , # 0xB8, 0o270, 184
    'onesuperior'                           , # 0xB9, 0o271, 185
    'ordmasculine'                          , # 0xBA, 0o272, 186
    'guillemotright'                        , # 0xBB, 0o273, 187
    'onequarter'                            , # 0xBC, 0o274, 188
    'onehalf'                               , # 0xBD, 0o275, 189
    'threequarters'                         , # 0xBE, 0o276, 190
    'questiondown'                          , # 0xBF, 0o277, 191
    'Agrave'                                , # 0xC0, 0o300, 192
    'Aacute'                                , # 0xC1, 0o301, 193
    'Acircumflex'                           , # 0xC2, 0o302, 194
    'Atilde'                                , # 0xC3, 0o303, 195
    'Adieresis'                             , # 0xC4, 0o304, 196
    'Aring'                                 , # 0xC5, 0o305, 197
    'AE'                                    , # 0xC6, 0o306, 198
    'Ccedilla'                              , # 0xC7, 0o307, 199
    'Egrave'                                , # 0xC8, 0o310, 200
    'Eacute'                                , # 0xC9, 0o311, 201
    'Ecircumflex'                           , # 0xCA, 0o312, 202
    'Edieresis'                             , # 0xCB, 0o313, 203
    'Igrave'                                , # 0xCC, 0o314, 204
    'Iacute'                                , # 0xCD, 0o315, 205
    'Icircumflex'                           , # 0xCE, 0o316, 206
    'Idieresis'                             , # 0xCF, 0o317, 207
    'Eth'                                   , # 0xD0, 0o320, 208
    'Ntilde'                                , # 0xD1, 0o321, 209
    'Ograve'                                , # 0xD2, 0o322, 210
    'Oacute'                                , # 0xD3, 0o323, 211
    'Ocircumflex'                           , # 0xD4, 0o324, 212
    'Otilde'                                , # 0xD5, 0o325, 213
    'Odieresis'                             , # 0xD6, 0o326, 214
    'multiply'                              , # 0xD7, 0o327, 215
    'Oslash'                                , # 0xD8, 0o330, 216
    'Ugrave'                                , # 0xD9, 0o331, 217
    'Uacute'                                , # 0xDA, 0o332, 218
    'Ucircumflex'                           , # 0xDB, 0o333, 219
    'Udieresis'                             , # 0xDC, 0o334, 220
    'Yacute'                                , # 0xDD, 0o335, 221
    'Thorn'                                 , # 0xDE, 0o336, 222
    'germandbls'                            , # 0xDF, 0o337, 223
    'agrave'                                , # 0xE0, 0o340, 224
    'aacute'                                , # 0xE1, 0o341, 225
    'acircumflex'                           , # 0xE2, 0o342, 226
    'atilde'                                , # 0xE3, 0o343, 227
    'adieresis'                             , # 0xE4, 0o344, 228
    'aring'                                 , # 0xE5, 0o345, 229
    'ae'                                    , # 0xE6, 0o346, 230
    'ccedilla'                              , # 0xE7, 0o347, 231
    'egrave'                                , # 0xE8, 0o350, 232
    'eacute'                                , # 0xE9, 0o351, 233
    'ecircumflex'                           , # 0xEA, 0o352, 234
    'edieresis'                             , # 0xEB, 0o353, 235
    'igrave'                                , # 0xEC, 0o354, 236
    'iacute'                                , # 0xED, 0o355, 237
    'icircumflex'                           , # 0xEE, 0o356, 238
    'idieresis'                             , # 0xEF, 0o357, 239
    'eth'                                   , # 0xF0, 0o360, 240
    'ntilde'                                , # 0xF1, 0o361, 241
    'ograve'                                , # 0xF2, 0o362, 242
    'oacute'                                , # 0xF3, 0o363, 243
    'ocircumflex'                           , # 0xF4, 0o364, 244
    'otilde'                                , # 0xF5, 0o365, 245
    'odieresis'                             , # 0xF6, 0o366, 246
    'divide'                                , # 0xF7, 0o367, 247
    'oslash'                                , # 0xF8, 0o370, 248
    'ugrave'                                , # 0xF9, 0o371, 249
    'uacute'                                , # 0xFA, 0o372, 250
    'ucircumflex'                           , # 0xFB, 0o373, 251
    'udieresis'                             , # 0xFC, 0o374, 252
    'yacute'                                , # 0xFD, 0o375, 253
    'thorn'                                 , # 0xFE, 0o376, 254
    'ydieresis'                             , # 0xFF, 0o377, 255
  ],
  'wx' => {'ntilde' => '500','cacute' => '444','Ydieresis' => '722','Oacute' => '722','zdotaccent' => '444','acute' => '333','lcommaaccent' => '278','ohungarumlaut' => '500','parenleft' => '333','lozenge' => '471','zero' => '500','aring' => '444','ncaron' => '500','Acircumflex' => '722','Zcaron' => '611','Nacute' => '722','scommaaccent' => '389','multiply' => '564','ellipsis' => '1000','uacute' => '500','hungarumlaut' => '333','aogonek' => '444','aacute' => '444','Emacron' => '611','Lslash' => '611','cedilla' => '333','A' => '722','B' => '667','Ecaron' => '611','Kcommaaccent' => '722','C' => '667','florin' => '500','D' => '722','Igrave' => '333','E' => '611','braceright' => '480','F' => '556','G' => '722','Abreve' => '722','H' => '722','germandbls' => '500','I' => '333','J' => '389','K' => '722','L' => '611','adieresis' => '444','M' => '889','lcaron' => '344','braceleft' => '480','N' => '722','O' => '722','P' => '556','Q' => '722','R' => '667','brokenbar' => '200','S' => '556','T' => '611','Lacute' => '611','U' => '722','V' => '722','quoteleft' => '333','Rcommaaccent' => '667','W' => '944','scedilla' => '389','X' => '722','ocircumflex' => '500','Y' => '722','Z' => '611','semicolon' => '278','Dcaron' => '722','Uogonek' => '722','sacute' => '389','dieresis' => '333','Dcroat' => '722','a' => '444','b' => '500','threequarters' => '750','twosuperior' => '300','c' => '444','d' => '500','e' => '444','f' => '333','g' => '500','h' => '500','i' => '278','ograve' => '500','j' => '278','k' => '500','gbreve' => '500','l' => '278','m' => '778','n' => '500','tcommaaccent' => '278','circumflex' => '333','o' => '500','edieresis' => '444','p' => '500','dotlessi' => '278','q' => '500','r' => '333','notequal' => '549','Ohungarumlaut' => '722','s' => '389','t' => '278','u' => '500','Ccaron' => '667','v' => '500','w' => '722','x' => '500','Ucircumflex' => '722','y' => '500','racute' => '333','z' => '444','amacron' => '444','daggerdbl' => '500','Idotaccent' => '333','Eth' => '722','Iogonek' => '333','Atilde' => '722','Lcommaaccent' => '611','gcommaaccent' => '500','greaterequal' => '549','summation' => '600','idieresis' => '278','dollar' => '500','trademark' => '980','Scommaaccent' => '556','Iacute' => '333','sterling' => '500','currency' => '500','ncommaaccent' => '500','Umacron' => '722','quotedblright' => '444','Odieresis' => '722','yen' => '500','oslash' => '500','backslash' => '278','Egrave' => '611','quotedblleft' => '444','exclamdown' => '333','Tcaron' => '611','Omacron' => '722','eight' => '500','OE' => '889','oacute' => '500','Zdotaccent' => '611','five' => '500','eogonek' => '444','Thorn' => '556','ordmasculine' => '310','Imacron' => '333','Ccedilla' => '667','icircumflex' => '278','three' => '500','Scaron' => '556','space' => '250','seven' => '500','Uring' => '722','quotesinglbase' => '333','breve' => '333','quotedbl' => '408','zcaron' => '444','degree' => '400','nacute' => '500','uhungarumlaut' => '500','registered' => '760','parenright' => '333','eth' => '500','greater' => '564','AE' => '889','Zacute' => '611','ogonek' => '333','six' => '500','Tcommaaccent' => '611','hyphen' => '333','questiondown' => '444','ring' => '333','Rcaron' => '667','mu' => '500','guilsinglleft' => '333','guillemotright' => '500','logicalnot' => '564','Ocircumflex' => '722','bullet' => '350','lslash' => '278','udieresis' => '500','ampersand' => '778','dotaccent' => '333','ecaron' => '444','Yacute' => '722','exclam' => '333','igrave' => '278','abreve' => '444','threesuperior' => '300','Eacute' => '611','four' => '500','copyright' => '760','Ugrave' => '722','fraction' => '167','Gcommaaccent' => '722','Agrave' => '722','lacute' => '278','edotaccent' => '444','emacron' => '444','section' => '500','dcaron' => '588','.notdef' => 0,'two' => '500','dcroat' => '500','Otilde' => '722','quotedblbase' => '444','ydieresis' => '500','tilde' => '333','oe' => '722','Ncommaaccent' => '722','ecircumflex' => '444','Adieresis' => '722','lessequal' => '549','macron' => '333','endash' => '500','ccaron' => '444','Ntilde' => '722','Cacute' => '667','uogonek' => '500','bar' => '200','Uhungarumlaut' => '722','Delta' => '612','caron' => '333','ae' => '667','Edieresis' => '611','atilde' => '444','perthousand' => '1000','Aogonek' => '722','onequarter' => '750','Scedilla' => '556','equal' => '564','at' => '921','Ncaron' => '722','minus' => '564','plusminus' => '564','underscore' => '500','quoteright' => '333','ordfeminine' => '276','iacute' => '278','onehalf' => '750','Uacute' => '722','iogonek' => '278','periodcentered' => '250','egrave' => '444','bracketright' => '333','thorn' => '500','Aacute' => '722','Icircumflex' => '333','Idieresis' => '333','onesuperior' => '300','Aring' => '722','acircumflex' => '444','uring' => '500','tcaron' => '326','less' => '564','radical' => '453','percent' => '833','umacron' => '500','Lcaron' => '611','plus' => '564','asciicircum' => '469','asciitilde' => '541','scaron' => '389','dagger' => '500','Amacron' => '722','omacron' => '500','Sacute' => '556','colon' => '278','Ograve' => '722','asterisk' => '500','zacute' => '444','Gbreve' => '722','grave' => '333','Euro' => '500','rcaron' => '333','imacron' => '278','Racute' => '667','comma' => '250','kcommaaccent' => '500','yacute' => '500','guillemotleft' => '500','question' => '444','Ecircumflex' => '611','odieresis' => '500','eacute' => '444','ugrave' => '500','divide' => '564','agrave' => '444','Edotaccent' => '611','ccedilla' => '444','rcommaaccent' => '333','numbersign' => '500','bracketleft' => '333','ucircumflex' => '500','partialdiff' => '476','guilsinglright' => '333','nine' => '500','Udieresis' => '722','quotesingle' => '180','otilde' => '500','Oslash' => '722','paragraph' => '453','slash' => '278','Eogonek' => '611','period' => '250','emdash' => '1000','cent' => '500','one' => '500','fi' => '556','fl' => '556','commaaccent' => '250'},
};

1;
