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

$fonts->{'verdanaitalic'} = {
  'apiname' => 'Ve4',
  'fontname' => 'Verdana,Italic',
  'type' => 'TrueType',
  'ascender' => 1005,
  'capheight' => 727,
  'descender' => -209,
  'italicangle' => -13,
  'underlineposition' => -180,
  'underlinethickness' => 120,
  'xheight' => 545,
  'flags' => 96,
  'isfixedpitch' => 0,
  'issymbol' => 0,
  'fontbbox' => [ -131, -206, 1460, 1000 ],
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
    'middot'                                , # 0xB7, 0o267, 183
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
  'wx' => {
    '.notdef' => 1000                       , # 0x00, 0o000, 0
    '.null' => 0                            , # 0x01, 0o001, 1
    'nonmarkingreturn' => 351               , # 0x02, 0o002, 2
    'space' => 351                          , # 0x03, 0o003, 3
    'exclam' => 393                         , # 0x04, 0o004, 4
    'quotedbl' => 458                       , # 0x05, 0o005, 5
    'numbersign' => 818                     , # 0x06, 0o006, 6
    'dollar' => 635                         , # 0x07, 0o007, 7
    'percent' => 1076                       , # 0x08, 0o010, 8
    'ampersand' => 726                      , # 0x09, 0o011, 9
    'quotesingle' => 268                    , # 0x0A, 0o012, 10
    'parenleft' => 454                      , # 0x0B, 0o013, 11
    'parenright' => 454                     , # 0x0C, 0o014, 12
    'asterisk' => 635                       , # 0x0D, 0o015, 13
    'plus' => 818                           , # 0x0E, 0o016, 14
    'comma' => 363                          , # 0x0F, 0o017, 15
    'hyphen' => 454                         , # 0x10, 0o020, 16
    'period' => 363                         , # 0x11, 0o021, 17
    'slash' => 454                          , # 0x12, 0o022, 18
    'zero' => 635                           , # 0x13, 0o023, 19
    'one' => 635                            , # 0x14, 0o024, 20
    'two' => 635                            , # 0x15, 0o025, 21
    'three' => 635                          , # 0x16, 0o026, 22
    'four' => 635                           , # 0x17, 0o027, 23
    'five' => 635                           , # 0x18, 0o030, 24
    'six' => 635                            , # 0x19, 0o031, 25
    'seven' => 635                          , # 0x1A, 0o032, 26
    'eight' => 635                          , # 0x1B, 0o033, 27
    'nine' => 635                           , # 0x1C, 0o034, 28
    'colon' => 454                          , # 0x1D, 0o035, 29
    'semicolon' => 454                      , # 0x1E, 0o036, 30
    'less' => 818                           , # 0x1F, 0o037, 31
    'equal' => 818                          , # 0x20, 0o040, 32
    'greater' => 818                        , # 0x21, 0o041, 33
    'question' => 545                       , # 0x22, 0o042, 34
    'at' => 1000                            , # 0x23, 0o043, 35
    'A' => 682                              , # 0x24, 0o044, 36
    'B' => 685                              , # 0x25, 0o045, 37
    'C' => 698                              , # 0x26, 0o046, 38
    'D' => 765                              , # 0x27, 0o047, 39
    'E' => 632                              , # 0x28, 0o050, 40
    'F' => 574                              , # 0x29, 0o051, 41
    'G' => 775                              , # 0x2A, 0o052, 42
    'H' => 751                              , # 0x2B, 0o053, 43
    'I' => 420                              , # 0x2C, 0o054, 44
    'J' => 454                              , # 0x2D, 0o055, 45
    'K' => 692                              , # 0x2E, 0o056, 46
    'L' => 556                              , # 0x2F, 0o057, 47
    'M' => 842                              , # 0x30, 0o060, 48
    'N' => 748                              , # 0x31, 0o061, 49
    'O' => 787                              , # 0x32, 0o062, 50
    'P' => 603                              , # 0x33, 0o063, 51
    'Q' => 787                              , # 0x34, 0o064, 52
    'R' => 695                              , # 0x35, 0o065, 53
    'S' => 683                              , # 0x36, 0o066, 54
    'T' => 616                              , # 0x37, 0o067, 55
    'U' => 731                              , # 0x38, 0o070, 56
    'V' => 682                              , # 0x39, 0o071, 57
    'W' => 990                              , # 0x3A, 0o072, 58
    'X' => 685                              , # 0x3B, 0o073, 59
    'Y' => 615                              , # 0x3C, 0o074, 60
    'Z' => 685                              , # 0x3D, 0o075, 61
    'bracketleft' => 454                    , # 0x3E, 0o076, 62
    'backslash' => 454                      , # 0x3F, 0o077, 63
    'bracketright' => 454                   , # 0x40, 0o100, 64
    'asciicircum' => 818                    , # 0x41, 0o101, 65
    'underscore' => 635                     , # 0x42, 0o102, 66
    'grave' => 635                          , # 0x43, 0o103, 67
    'a' => 600                              , # 0x44, 0o104, 68
    'b' => 623                              , # 0x45, 0o105, 69
    'c' => 520                              , # 0x46, 0o106, 70
    'd' => 623                              , # 0x47, 0o107, 71
    'e' => 595                              , # 0x48, 0o110, 72
    'f' => 351                              , # 0x49, 0o111, 73
    'g' => 621                              , # 0x4A, 0o112, 74
    'h' => 632                              , # 0x4B, 0o113, 75
    'i' => 274                              , # 0x4C, 0o114, 76
    'j' => 344                              , # 0x4D, 0o115, 77
    'k' => 586                              , # 0x4E, 0o116, 78
    'l' => 274                              , # 0x4F, 0o117, 79
    'm' => 973                              , # 0x50, 0o120, 80
    'n' => 632                              , # 0x51, 0o121, 81
    'o' => 606                              , # 0x52, 0o122, 82
    'p' => 623                              , # 0x53, 0o123, 83
    'q' => 623                              , # 0x54, 0o124, 84
    'r' => 426                              , # 0x55, 0o125, 85
    's' => 520                              , # 0x56, 0o126, 86
    't' => 394                              , # 0x57, 0o127, 87
    'u' => 632                              , # 0x58, 0o130, 88
    'v' => 590                              , # 0x59, 0o131, 89
    'w' => 818                              , # 0x5A, 0o132, 90
    'x' => 591                              , # 0x5B, 0o133, 91
    'y' => 590                              , # 0x5C, 0o134, 92
    'z' => 525                              , # 0x5D, 0o135, 93
    'braceleft' => 634                      , # 0x5E, 0o136, 94
    'bar' => 454                            , # 0x5F, 0o137, 95
    'braceright' => 634                     , # 0x60, 0o140, 96
    'asciitilde' => 818                     , # 0x61, 0o141, 97
    'Adieresis' => 682                      , # 0x62, 0o142, 98
    'Aring' => 682                          , # 0x63, 0o143, 99
    'Ccedilla' => 698                       , # 0x64, 0o144, 100
    'Eacute' => 632                         , # 0x65, 0o145, 101
    'Ntilde' => 748                         , # 0x66, 0o146, 102
    'Odieresis' => 787                      , # 0x67, 0o147, 103
    'Udieresis' => 731                      , # 0x68, 0o150, 104
    'aacute' => 600                         , # 0x69, 0o151, 105
    'agrave' => 600                         , # 0x6A, 0o152, 106
    'acircumflex' => 600                    , # 0x6B, 0o153, 107
    'adieresis' => 600                      , # 0x6C, 0o154, 108
    'atilde' => 600                         , # 0x6D, 0o155, 109
    'aring' => 600                          , # 0x6E, 0o156, 110
    'ccedilla' => 520                       , # 0x6F, 0o157, 111
    'eacute' => 595                         , # 0x70, 0o160, 112
    'egrave' => 595                         , # 0x71, 0o161, 113
    'ecircumflex' => 595                    , # 0x72, 0o162, 114
    'edieresis' => 595                      , # 0x73, 0o163, 115
    'iacute' => 274                         , # 0x74, 0o164, 116
    'igrave' => 274                         , # 0x75, 0o165, 117
    'icircumflex' => 274                    , # 0x76, 0o166, 118
    'idieresis' => 274                      , # 0x77, 0o167, 119
    'ntilde' => 632                         , # 0x78, 0o170, 120
    'oacute' => 606                         , # 0x79, 0o171, 121
    'ograve' => 606                         , # 0x7A, 0o172, 122
    'ocircumflex' => 606                    , # 0x7B, 0o173, 123
    'odieresis' => 606                      , # 0x7C, 0o174, 124
    'otilde' => 606                         , # 0x7D, 0o175, 125
    'uacute' => 632                         , # 0x7E, 0o176, 126
    'ugrave' => 632                         , # 0x7F, 0o177, 127
    'ucircumflex' => 632                    , # 0x80, 0o200, 128
    'udieresis' => 632                      , # 0x81, 0o201, 129
    'dagger' => 635                         , # 0x82, 0o202, 130
    'degree' => 541                         , # 0x83, 0o203, 131
    'cent' => 635                           , # 0x84, 0o204, 132
    'sterling' => 635                       , # 0x85, 0o205, 133
    'section' => 635                        , # 0x86, 0o206, 134
    'bullet' => 545                         , # 0x87, 0o207, 135
    'paragraph' => 635                      , # 0x88, 0o210, 136
    'germandbls' => 620                     , # 0x89, 0o211, 137
    'registered' => 1000                    , # 0x8A, 0o212, 138
    'copyright' => 1000                     , # 0x8B, 0o213, 139
    'trademark' => 976                      , # 0x8C, 0o214, 140
    'acute' => 635                          , # 0x8D, 0o215, 141
    'dieresis' => 635                       , # 0x8E, 0o216, 142
    'notequal' => 818                       , # 0x8F, 0o217, 143
    'AE' => 989                             , # 0x90, 0o220, 144
    'Oslash' => 787                         , # 0x91, 0o221, 145
    'infinity' => 1000                      , # 0x92, 0o222, 146
    'plusminus' => 818                      , # 0x93, 0o223, 147
    'lessequal' => 818                      , # 0x94, 0o224, 148
    'greaterequal' => 818                   , # 0x95, 0o225, 149
    'yen' => 635                            , # 0x96, 0o226, 150
    'mu1' => 641                            , # 0x97, 0o227, 151
    'partialdiff' => 635                    , # 0x98, 0o230, 152
    'summation' => 727                      , # 0x99, 0o231, 153
    'product' => 818                        , # 0x9A, 0o232, 154
    'pi1' => 707                            , # 0x9B, 0o233, 155
    'integral' => 635                       , # 0x9C, 0o234, 156
    'ordfeminine' => 545                    , # 0x9D, 0o235, 157
    'ordmasculine' => 545                   , # 0x9E, 0o236, 158
    'Ohm' => 818                            , # 0x9F, 0o237, 159
    'ae' => 954                             , # 0xA0, 0o240, 160
    'oslash' => 606                         , # 0xA1, 0o241, 161
    'questiondown' => 545                   , # 0xA2, 0o242, 162
    'exclamdown' => 393                     , # 0xA3, 0o243, 163
    'logicalnot' => 818                     , # 0xA4, 0o244, 164
    'radical' => 818                        , # 0xA5, 0o245, 165
    'florin' => 635                         , # 0xA6, 0o246, 166
    'approxequal' => 818                    , # 0xA7, 0o247, 167
    'increment' => 726                      , # 0xA8, 0o250, 168
    'guillemotleft' => 644                  , # 0xA9, 0o251, 169
    'guillemotright' => 644                 , # 0xAA, 0o252, 170
    'ellipsis' => 818                       , # 0xAB, 0o253, 171
    'Agrave' => 682                         , # 0xAC, 0o254, 172
    'Atilde' => 682                         , # 0xAD, 0o255, 173
    'Otilde' => 787                         , # 0xAE, 0o256, 174
    'OE' => 1069                            , # 0xAF, 0o257, 175
    'oe' => 980                             , # 0xB0, 0o260, 176
    'endash' => 635                         , # 0xB1, 0o261, 177
    'emdash' => 1000                        , # 0xB2, 0o262, 178
    'quotedblleft' => 458                   , # 0xB3, 0o263, 179
    'quotedblright' => 458                  , # 0xB4, 0o264, 180
    'quoteleft' => 268                      , # 0xB5, 0o265, 181
    'quoteright' => 268                     , # 0xB6, 0o266, 182
    'divide' => 818                         , # 0xB7, 0o267, 183
    'lozenge' => 818                        , # 0xB8, 0o270, 184
    'ydieresis' => 590                      , # 0xB9, 0o271, 185
    'Ydieresis' => 615                      , # 0xBA, 0o272, 186
    'fraction' => 361                       , # 0xBB, 0o273, 187
    'Euro' => 635                           , # 0xBC, 0o274, 188
    'guilsinglleft' => 454                  , # 0xBD, 0o275, 189
    'guilsinglright' => 454                 , # 0xBE, 0o276, 190
    'fi' => 625                             , # 0xBF, 0o277, 191
    'fl' => 625                             , # 0xC0, 0o300, 192
    'daggerdbl' => 635                      , # 0xC1, 0o301, 193
    'periodcentered' => 363                 , # 0xC2, 0o302, 194
    'quotesinglbase' => 268                 , # 0xC3, 0o303, 195
    'quotedblbase' => 458                   , # 0xC4, 0o304, 196
    'perthousand' => 1518                   , # 0xC5, 0o305, 197
    'Acircumflex' => 682                    , # 0xC6, 0o306, 198
    'Ecircumflex' => 632                    , # 0xC7, 0o307, 199
    'Aacute' => 682                         , # 0xC8, 0o310, 200
    'Edieresis' => 632                      , # 0xC9, 0o311, 201
    'Egrave' => 632                         , # 0xCA, 0o312, 202
    'Iacute' => 420                         , # 0xCB, 0o313, 203
    'Icircumflex' => 420                    , # 0xCC, 0o314, 204
    'Idieresis' => 420                      , # 0xCD, 0o315, 205
    'Igrave' => 420                         , # 0xCE, 0o316, 206
    'Oacute' => 787                         , # 0xCF, 0o317, 207
    'Ocircumflex' => 787                    , # 0xD0, 0o320, 208
    'Ograve' => 787                         , # 0xD1, 0o321, 209
    'Uacute' => 731                         , # 0xD2, 0o322, 210
    'Ucircumflex' => 731                    , # 0xD3, 0o323, 211
    'Ugrave' => 731                         , # 0xD4, 0o324, 212
    'dotlessi' => 274                       , # 0xD5, 0o325, 213
    'circumflex' => 635                     , # 0xD6, 0o326, 214
    'tilde' => 635                          , # 0xD7, 0o327, 215
    'macron' => 635                         , # 0xD8, 0o330, 216
    'breve' => 635                          , # 0xD9, 0o331, 217
    'dotaccent' => 635                      , # 0xDA, 0o332, 218
    'ring' => 635                           , # 0xDB, 0o333, 219
    'cedilla' => 635                        , # 0xDC, 0o334, 220
    'hungarumlaut' => 635                   , # 0xDD, 0o335, 221
    'ogonek' => 635                         , # 0xDE, 0o336, 222
    'caron' => 635                          , # 0xDF, 0o337, 223
    'Lslash' => 556                         , # 0xE0, 0o340, 224
    'lslash' => 274                         , # 0xE1, 0o341, 225
    'Scaron' => 683                         , # 0xE2, 0o342, 226
    'scaron' => 520                         , # 0xE3, 0o343, 227
    'Zcaron' => 685                         , # 0xE4, 0o344, 228
    'zcaron' => 525                         , # 0xE5, 0o345, 229
    'brokenbar' => 454                      , # 0xE6, 0o346, 230
    'Eth' => 765                            , # 0xE7, 0o347, 231
    'eth' => 611                            , # 0xE8, 0o350, 232
    'Yacute' => 615                         , # 0xE9, 0o351, 233
    'yacute' => 590                         , # 0xEA, 0o352, 234
    'Thorn' => 605                          , # 0xEB, 0o353, 235
    'thorn' => 623                          , # 0xEC, 0o354, 236
    'minus' => 818                          , # 0xED, 0o355, 237
    'multiply' => 818                       , # 0xEE, 0o356, 238
    'onesuperior' => 541                    , # 0xEF, 0o357, 239
    'twosuperior' => 541                    , # 0xF0, 0o360, 240
    'threesuperior' => 541                  , # 0xF1, 0o361, 241
    'onehalf' => 1000                       , # 0xF2, 0o362, 242
    'onequarter' => 1000                    , # 0xF3, 0o363, 243
    'threequarters' => 1000                 , # 0xF4, 0o364, 244
    'franc' => 635                          , # 0xF5, 0o365, 245
    'Gbreve' => 775                         , # 0xF6, 0o366, 246
    'gbreve' => 621                         , # 0xF7, 0o367, 247
    'Idot' => 420                           , # 0xF8, 0o370, 248
    'Scedilla' => 683                       , # 0xF9, 0o371, 249
    'scedilla' => 520                       , # 0xFA, 0o372, 250
    'Cacute' => 698                         , # 0xFB, 0o373, 251
    'cacute' => 520                         , # 0xFC, 0o374, 252
    'Ccaron' => 698                         , # 0xFD, 0o375, 253
    'ccaron' => 520                         , # 0xFE, 0o376, 254
    'dmacron' => 623                        , # 0xFF, 0o377, 255
    'overscore' => 635                      , # 0x100, 0o400, 256
    'middot' => 363                         , # 0x101, 0o401, 257
    'Abreve' => 682                         , # 0x102, 0o402, 258
    'abreve' => 600                         , # 0x103, 0o403, 259
    'Aogonek' => 682                        , # 0x104, 0o404, 260
    'aogonek' => 600                        , # 0x105, 0o405, 261
    'Dcaron' => 765                         , # 0x106, 0o406, 262
    'dcaron' => 647                         , # 0x107, 0o407, 263
    'Dslash' => 765                         , # 0x108, 0o410, 264
    'Eogonek' => 632                        , # 0x109, 0o411, 265
    'eogonek' => 595                        , # 0x10A, 0o412, 266
    'Ecaron' => 632                         , # 0x10B, 0o413, 267
    'ecaron' => 595                         , # 0x10C, 0o414, 268
    'Lacute' => 556                         , # 0x10D, 0o415, 269
    'lacute' => 274                         , # 0x10E, 0o416, 270
    'Lcaron' => 556                         , # 0x10F, 0o417, 271
    'lcaron' => 295                         , # 0x110, 0o420, 272
    'Ldot' => 556                           , # 0x111, 0o421, 273
    'ldot' => 458                           , # 0x112, 0o422, 274
    'Nacute' => 748                         , # 0x113, 0o423, 275
    'nacute' => 632                         , # 0x114, 0o424, 276
    'Ncaron' => 748                         , # 0x115, 0o425, 277
    'ncaron' => 632                         , # 0x116, 0o426, 278
    'Odblacute' => 787                      , # 0x117, 0o427, 279
    'odblacute' => 606                      , # 0x118, 0o430, 280
    'Racute' => 695                         , # 0x119, 0o431, 281
    'racute' => 426                         , # 0x11A, 0o432, 282
    'Rcaron' => 695                         , # 0x11B, 0o433, 283
    'rcaron' => 426                         , # 0x11C, 0o434, 284
    'Sacute' => 683                         , # 0x11D, 0o435, 285
    'sacute' => 520                         , # 0x11E, 0o436, 286
    'Tcedilla' => 616                       , # 0x11F, 0o437, 287
    'tcedilla' => 394                       , # 0x120, 0o440, 288
    'Tcaron' => 616                         , # 0x121, 0o441, 289
    'tcaron' => 394                         , # 0x122, 0o442, 290
    'Uring' => 731                          , # 0x123, 0o443, 291
    'uring' => 632                          , # 0x124, 0o444, 292
    'Udblacute' => 731                      , # 0x125, 0o445, 293
    'udblacute' => 632                      , # 0x126, 0o446, 294
    'Zacute' => 685                         , # 0x127, 0o447, 295
    'zacute' => 525                         , # 0x128, 0o450, 296
    'Zdot' => 685                           , # 0x129, 0o451, 297
    'zdot' => 525                           , # 0x12A, 0o452, 298
    'Gamma' => 566                          , # 0x12B, 0o453, 299
    'Theta' => 787                          , # 0x12C, 0o454, 300
    'Phi' => 814                            , # 0x12D, 0o455, 301
    'alpha' => 623                          , # 0x12E, 0o456, 302
    'delta' => 607                          , # 0x12F, 0o457, 303
    'epsilon' => 512                        , # 0x130, 0o460, 304
    'sigma' => 630                          , # 0x131, 0o461, 305
    'tau' => 496                            , # 0x132, 0o462, 306
    'phi' => 790                            , # 0x133, 0o463, 307
    'underscoredbl' => 635                  , # 0x134, 0o464, 308
    'exclamdbl' => 624                      , # 0x135, 0o465, 309
    'nsuperior' => 545                      , # 0x136, 0o466, 310
    'peseta' => 1163                        , # 0x137, 0o467, 311
    'IJ' => 870                             , # 0x138, 0o470, 312
    'ij' => 613                             , # 0x139, 0o471, 313
    'napostrophe' => 730                    , # 0x13A, 0o472, 314
    'minute' => 361                         , # 0x13B, 0o473, 315
    'second' => 557                         , # 0x13C, 0o474, 316
    'afii61248' => 1076                     , # 0x13D, 0o475, 317
    'afii61289' => 323                      , # 0x13E, 0o476, 318
    'H22073' => 604                         , # 0x13F, 0o477, 319
    'H18543' => 354                         , # 0x140, 0o500, 320
    'H18551' => 354                         , # 0x141, 0o501, 321
    'H18533' => 604                         , # 0x142, 0o502, 322
    'openbullet' => 354                     , # 0x143, 0o503, 323
    'Amacron' => 682                        , # 0x144, 0o504, 324
    'amacron' => 600                        , # 0x145, 0o505, 325
    'Ccircumflex' => 698                    , # 0x146, 0o506, 326
    'ccircumflex' => 520                    , # 0x147, 0o507, 327
    'Cdot' => 698                           , # 0x148, 0o510, 328
    'cdot' => 520                           , # 0x149, 0o511, 329
    'Emacron' => 632                        , # 0x14A, 0o512, 330
    'emacron' => 595                        , # 0x14B, 0o513, 331
    'Ebreve' => 632                         , # 0x14C, 0o514, 332
    'ebreve' => 595                         , # 0x14D, 0o515, 333
    'Edot' => 632                           , # 0x14E, 0o516, 334
    'edot' => 595                           , # 0x14F, 0o517, 335
    'Gcircumflex' => 775                    , # 0x150, 0o520, 336
    'gcircumflex' => 621                    , # 0x151, 0o521, 337
    'Gdot' => 775                           , # 0x152, 0o522, 338
    'gdot' => 621                           , # 0x153, 0o523, 339
    'Gcedilla' => 775                       , # 0x154, 0o524, 340
    'gcedilla' => 621                       , # 0x155, 0o525, 341
    'Hcircumflex' => 751                    , # 0x156, 0o526, 342
    'hcircumflex' => 632                    , # 0x157, 0o527, 343
    'Hbar' => 751                           , # 0x158, 0o530, 344
    'hbar' => 632                           , # 0x159, 0o531, 345
    'Itilde' => 420                         , # 0x15A, 0o532, 346
    'itilde' => 274                         , # 0x15B, 0o533, 347
    'Imacron' => 420                        , # 0x15C, 0o534, 348
    'imacron' => 274                        , # 0x15D, 0o535, 349
    'Ibreve' => 420                         , # 0x15E, 0o536, 350
    'ibreve' => 274                         , # 0x15F, 0o537, 351
    'Iogonek' => 420                        , # 0x160, 0o540, 352
    'iogonek' => 274                        , # 0x161, 0o541, 353
    'Jcircumflex' => 454                    , # 0x162, 0o542, 354
    'jcircumflex' => 344                    , # 0x163, 0o543, 355
    'Kcedilla' => 692                       , # 0x164, 0o544, 356
    'kcedilla' => 586                       , # 0x165, 0o545, 357
    'kgreenlandic' => 586                   , # 0x166, 0o546, 358
    'Lcedilla' => 556                       , # 0x167, 0o547, 359
    'lcedilla' => 274                       , # 0x168, 0o550, 360
    'Ncedilla' => 748                       , # 0x169, 0o551, 361
    'ncedilla' => 632                       , # 0x16A, 0o552, 362
    'Eng' => 748                            , # 0x16B, 0o553, 363
    'eng' => 632                            , # 0x16C, 0o554, 364
    'Omacron' => 787                        , # 0x16D, 0o555, 365
    'omacron' => 606                        , # 0x16E, 0o556, 366
    'Obreve' => 787                         , # 0x16F, 0o557, 367
    'obreve' => 606                         , # 0x170, 0o560, 368
    'Rcedilla' => 695                       , # 0x171, 0o561, 369
    'rcedilla' => 426                       , # 0x172, 0o562, 370
    'Scircumflex' => 683                    , # 0x173, 0o563, 371
    'scircumflex' => 520                    , # 0x174, 0o564, 372
    'Tbar' => 616                           , # 0x175, 0o565, 373
    'tbar' => 394                           , # 0x176, 0o566, 374
    'Utilde' => 731                         , # 0x177, 0o567, 375
    'utilde' => 632                         , # 0x178, 0o570, 376
    'Umacron' => 731                        , # 0x179, 0o571, 377
    'umacron' => 632                        , # 0x17A, 0o572, 378
    'Ubreve' => 731                         , # 0x17B, 0o573, 379
    'ubreve' => 630                         , # 0x17C, 0o574, 380
    'Uogonek' => 731                        , # 0x17D, 0o575, 381
    'uogonek' => 632                        , # 0x17E, 0o576, 382
    'Wcircumflex' => 990                    , # 0x17F, 0o577, 383
    'wcircumflex' => 818                    , # 0x180, 0o600, 384
    'Ycircumflex' => 615                    , # 0x181, 0o601, 385
    'ycircumflex' => 590                    , # 0x182, 0o602, 386
    'longs' => 300                          , # 0x183, 0o603, 387
    'Aringacute' => 682                     , # 0x184, 0o604, 388
    'aringacute' => 600                     , # 0x185, 0o605, 389
    'AEacute' => 989                        , # 0x186, 0o606, 390
    'aeacute' => 954                        , # 0x187, 0o607, 391
    'Oslashacute' => 787                    , # 0x188, 0o610, 392
    'oslashacute' => 606                    , # 0x189, 0o611, 393
    'anoteleia' => 454                      , # 0x18A, 0o612, 394
    'Wgrave' => 990                         , # 0x18B, 0o613, 395
    'wgrave' => 818                         , # 0x18C, 0o614, 396
    'Wacute' => 990                         , # 0x18D, 0o615, 397
    'wacute' => 818                         , # 0x18E, 0o616, 398
    'Wdieresis' => 990                      , # 0x18F, 0o617, 399
    'wdieresis' => 818                      , # 0x190, 0o620, 400
    'Ygrave' => 615                         , # 0x191, 0o621, 401
    'ygrave' => 590                         , # 0x192, 0o622, 402
    'quotereversed' => 268                  , # 0x193, 0o623, 403
    'radicalex' => 635                      , # 0x194, 0o624, 404
    'afii08941' => 635                      , # 0x195, 0o625, 405
    'estimated' => 717                      , # 0x196, 0o626, 406
    'oneeighth' => 1000                     , # 0x197, 0o627, 407
    'threeeighths' => 1000                  , # 0x198, 0o630, 408
    'fiveeighths' => 1000                   , # 0x199, 0o631, 409
    'seveneighths' => 1000                  , # 0x19A, 0o632, 410
    'commaaccent' => 363                    , # 0x19B, 0o633, 411
    'undercommaaccent' => 635               , # 0x19C, 0o634, 412
    'tonos' => 635                          , # 0x19D, 0o635, 413
    'dieresistonos' => 635                  , # 0x19E, 0o636, 414
    'Alphatonos' => 683                     , # 0x19F, 0o637, 415
    'Epsilontonos' => 750                   , # 0x1A0, 0o640, 416
    'Etatonos' => 870                       , # 0x1A1, 0o641, 417
    'Iotatonos' => 539                      , # 0x1A2, 0o642, 418
    'Omicrontonos' => 880                   , # 0x1A3, 0o643, 419
    'Upsilontonos' => 753                   , # 0x1A4, 0o644, 420
    'Omegatonos' => 907                     , # 0x1A5, 0o645, 421
    'iotadieresistonos' => 274              , # 0x1A6, 0o646, 422
    'Alpha' => 682                          , # 0x1A7, 0o647, 423
    'Beta' => 685                           , # 0x1A8, 0o650, 424
    'Delta' => 726                          , # 0x1A9, 0o651, 425
    'Epsilon' => 632                        , # 0x1AA, 0o652, 426
    'Zeta' => 685                           , # 0x1AB, 0o653, 427
    'Eta' => 751                            , # 0x1AC, 0o654, 428
    'Iota' => 420                           , # 0x1AD, 0o655, 429
    'Kappa' => 692                          , # 0x1AE, 0o656, 430
    'Lambda' => 685                         , # 0x1AF, 0o657, 431
    'Mu' => 842                             , # 0x1B0, 0o660, 432
    'Nu' => 748                             , # 0x1B1, 0o661, 433
    'Xi' => 648                             , # 0x1B2, 0o662, 434
    'Omicron' => 787                        , # 0x1B3, 0o663, 435
    'Pi' => 751                             , # 0x1B4, 0o664, 436
    'Rho' => 603                            , # 0x1B5, 0o665, 437
    'Sigma' => 672                          , # 0x1B6, 0o666, 438
    'Tau' => 616                            , # 0x1B7, 0o667, 439
    'Upsilon' => 615                        , # 0x1B8, 0o670, 440
    'Chi' => 685                            , # 0x1B9, 0o671, 441
    'Psi' => 870                            , # 0x1BA, 0o672, 442
    'Omega' => 818                          , # 0x1BB, 0o673, 443
    'Iotadieresis' => 420                   , # 0x1BC, 0o674, 444
    'Upsilondieresis' => 615                , # 0x1BD, 0o675, 445
    'alphatonos' => 623                     , # 0x1BE, 0o676, 446
    'epsilontonos' => 512                   , # 0x1BF, 0o677, 447
    'etatonos' => 632                       , # 0x1C0, 0o700, 448
    'iotatonos' => 274                      , # 0x1C1, 0o701, 449
    'upsilondieresistonos' => 630           , # 0x1C2, 0o702, 450
    'beta' => 620                           , # 0x1C3, 0o703, 451
    'gamma' => 590                          , # 0x1C4, 0o704, 452
    'zeta' => 457                           , # 0x1C5, 0o705, 453
    'eta' => 632                            , # 0x1C6, 0o706, 454
    'theta' => 624                          , # 0x1C7, 0o707, 455
    'iota' => 274                           , # 0x1C8, 0o710, 456
    'kappa' => 591                          , # 0x1C9, 0o711, 457
    'lambda' => 591                         , # 0x1CA, 0o712, 458
    'mu' => 638                             , # 0x1CB, 0o713, 459
    'nu' => 590                             , # 0x1CC, 0o714, 460
    'xi' => 502                             , # 0x1CD, 0o715, 461
    'omicron' => 606                        , # 0x1CE, 0o716, 462
    'rho' => 624                            , # 0x1CF, 0o717, 463
    'sigma1' => 507                         , # 0x1D0, 0o720, 464
    'upsilon' => 630                        , # 0x1D1, 0o721, 465
    'chi' => 589                            , # 0x1D2, 0o722, 466
    'psi' => 821                            , # 0x1D3, 0o723, 467
    'omega' => 813                          , # 0x1D4, 0o724, 468
    'iotadieresis' => 274                   , # 0x1D5, 0o725, 469
    'upsilondieresis' => 630                , # 0x1D6, 0o726, 470
    'omicrontonos' => 606                   , # 0x1D7, 0o727, 471
    'upsilontonos' => 630                   , # 0x1D8, 0o730, 472
    'omegatonos' => 813                     , # 0x1D9, 0o731, 473
    'afii10023' => 632                      , # 0x1DA, 0o732, 474
    'afii10051' => 792                      , # 0x1DB, 0o733, 475
    'afii10052' => 566                      , # 0x1DC, 0o734, 476
    'afii10053' => 700                      , # 0x1DD, 0o735, 477
    'afii10054' => 683                      , # 0x1DE, 0o736, 478
    'afii10055' => 420                      , # 0x1DF, 0o737, 479
    'afii10056' => 420                      , # 0x1E0, 0o740, 480
    'afii10057' => 454                      , # 0x1E1, 0o741, 481
    'afii10058' => 1118                     , # 0x1E2, 0o742, 482
    'afii10059' => 1103                     , # 0x1E3, 0o743, 483
    'afii10060' => 817                      , # 0x1E4, 0o744, 484
    'afii10061' => 692                      , # 0x1E5, 0o745, 485
    'afii10062' => 615                      , # 0x1E6, 0o746, 486
    'afii10145' => 751                      , # 0x1E7, 0o747, 487
    'afii10017' => 682                      , # 0x1E8, 0o750, 488
    'afii10018' => 685                      , # 0x1E9, 0o751, 489
    'afii10019' => 685                      , # 0x1EA, 0o752, 490
    'afii10020' => 566                      , # 0x1EB, 0o753, 491
    'afii10021' => 745                      , # 0x1EC, 0o754, 492
    'afii10022' => 632                      , # 0x1ED, 0o755, 493
    'afii10024' => 973                      , # 0x1EE, 0o756, 494
    'afii10025' => 615                      , # 0x1EF, 0o757, 495
    'afii10026' => 750                      , # 0x1F0, 0o760, 496
    'afii10027' => 750                      , # 0x1F1, 0o761, 497
    'afii10028' => 692                      , # 0x1F2, 0o762, 498
    'afii10029' => 734                      , # 0x1F3, 0o763, 499
    'afii10030' => 842                      , # 0x1F4, 0o764, 500
    'afii10031' => 751                      , # 0x1F5, 0o765, 501
    'afii10032' => 787                      , # 0x1F6, 0o766, 502
    'afii10033' => 751                      , # 0x1F7, 0o767, 503
    'afii10034' => 603                      , # 0x1F8, 0o770, 504
    'afii10035' => 698                      , # 0x1F9, 0o771, 505
    'afii10036' => 616                      , # 0x1FA, 0o772, 506
    'afii10037' => 615                      , # 0x1FB, 0o773, 507
    'afii10038' => 814                      , # 0x1FC, 0o774, 508
    'afii10039' => 685                      , # 0x1FD, 0o775, 509
    'afii10040' => 761                      , # 0x1FE, 0o776, 510
    'afii10041' => 711                      , # 0x1FF, 0o777, 511
    'afii10042' => 1030                     , # 0x200, 0o1000, 512
    'afii10043' => 1044                     , # 0x201, 0o1001, 513
    'afii10044' => 788                      , # 0x202, 0o1002, 514
    'afii10045' => 920                      , # 0x203, 0o1003, 515
    'afii10046' => 680                      , # 0x204, 0o1004, 516
    'afii10047' => 701                      , # 0x205, 0o1005, 517
    'afii10048' => 1034                     , # 0x206, 0o1006, 518
    'afii10049' => 706                      , # 0x207, 0o1007, 519
    'afii10065' => 600                      , # 0x208, 0o1010, 520
    'afii10066' => 614                      , # 0x209, 0o1011, 521
    'afii10067' => 594                      , # 0x20A, 0o1012, 522
    'afii10068' => 471                      , # 0x20B, 0o1013, 523
    'afii10069' => 621                      , # 0x20C, 0o1014, 524
    'afii10070' => 595                      , # 0x20D, 0o1015, 525
    'afii10072' => 797                      , # 0x20E, 0o1016, 526
    'afii10073' => 524                      , # 0x20F, 0o1017, 527
    'afii10074' => 640                      , # 0x210, 0o1020, 528
    'afii10075' => 640                      , # 0x211, 0o1021, 529
    'afii10076' => 591                      , # 0x212, 0o1022, 530
    'afii10077' => 620                      , # 0x213, 0o1023, 531
    'afii10078' => 696                      , # 0x214, 0o1024, 532
    'afii10079' => 637                      , # 0x215, 0o1025, 533
    'afii10080' => 606                      , # 0x216, 0o1026, 534
    'afii10081' => 637                      , # 0x217, 0o1027, 535
    'afii10082' => 623                      , # 0x218, 0o1030, 536
    'afii10083' => 530                      , # 0x219, 0o1031, 537
    'afii10084' => 496                      , # 0x21A, 0o1032, 538
    'afii10085' => 590                      , # 0x21B, 0o1033, 539
    'afii10086' => 840                      , # 0x21C, 0o1034, 540
    'afii10087' => 591                      , # 0x21D, 0o1035, 541
    'afii10088' => 644                      , # 0x21E, 0o1036, 542
    'afii10089' => 605                      , # 0x21F, 0o1037, 543
    'afii10090' => 875                      , # 0x220, 0o1040, 544
    'afii10091' => 887                      , # 0x221, 0o1041, 545
    'afii10092' => 640                      , # 0x222, 0o1042, 546
    'afii10093' => 794                      , # 0x223, 0o1043, 547
    'afii10094' => 570                      , # 0x224, 0o1044, 548
    'afii10095' => 546                      , # 0x225, 0o1045, 549
    'afii10096' => 838                      , # 0x226, 0o1046, 550
    'afii10097' => 599                      , # 0x227, 0o1047, 551
    'afii10071' => 595                      , # 0x228, 0o1050, 552
    'afii10099' => 632                      , # 0x229, 0o1051, 553
    'afii10100' => 471                      , # 0x22A, 0o1052, 554
    'afii10101' => 546                      , # 0x22B, 0o1053, 555
    'afii10102' => 520                      , # 0x22C, 0o1054, 556
    'afii10103' => 274                      , # 0x22D, 0o1055, 557
    'afii10104' => 274                      , # 0x22E, 0o1056, 558
    'afii10105' => 344                      , # 0x22F, 0o1057, 559
    'afii10106' => 914                      , # 0x230, 0o1060, 560
    'afii10107' => 914                      , # 0x231, 0o1061, 561
    'afii10108' => 632                      , # 0x232, 0o1062, 562
    'afii10109' => 591                      , # 0x233, 0o1063, 563
    'afii10110' => 590                      , # 0x234, 0o1064, 564
    'afii10193' => 637                      , # 0x235, 0o1065, 565
    'afii10050' => 566                      , # 0x236, 0o1066, 566
    'afii10098' => 471                      , # 0x237, 0o1067, 567
    'afii00208' => 1000                     , # 0x238, 0o1070, 568
    'afii61352' => 1171                     , # 0x239, 0o1071, 569
    'pi' => 637                             , # 0x23A, 0o1072, 570
    'foursuperior' => 541                   , # 0x23B, 0o1073, 571
    'fivesuperior' => 541                   , # 0x23C, 0o1074, 572
    'sevensuperior' => 541                  , # 0x23D, 0o1075, 573
    'eightsuperior' => 541                  , # 0x23E, 0o1076, 574
    'onesupforfrac' => 541                  , # 0x23F, 0o1077, 575
    'DontCompressHTMX' => 0                 , # 0x240, 0o1100, 576
    'Ohorn' => 806                          , # 0x246, 0o1106, 582
    'ohorn' => 606                          , # 0x247, 0o1107, 583
    'Uhorn' => 756                          , # 0x248, 0o1110, 584
    'uhorn' => 659                          , # 0x249, 0o1111, 585
    'hookabovecomb' => 0                    , # 0x24A, 0o1112, 586
    'dotbelowcomb' => 0                     , # 0x24B, 0o1113, 587
    'gravecomb' => 0                        , # 0x24C, 0o1114, 588
    'acutecomb' => 0                        , # 0x24D, 0o1115, 589
    'glyph590' => 635                       , # 0x24E, 0o1116, 590
    'glyph591' => 635                       , # 0x24F, 0o1117, 591
    'glyph592' => 635                       , # 0x250, 0o1120, 592
    'glyph593' => 635                       , # 0x251, 0o1121, 593
    'glyph594' => 635                       , # 0x252, 0o1122, 594
    'glyph595' => 635                       , # 0x253, 0o1123, 595
    'glyph596' => 635                       , # 0x254, 0o1124, 596
    'glyph597' => 635                       , # 0x255, 0o1125, 597
    'glyph598' => 635                       , # 0x256, 0o1126, 598
    'glyph599' => 635                       , # 0x257, 0o1127, 599
    'glyph600' => 635                       , # 0x258, 0o1130, 600
    'glyph601' => 635                       , # 0x259, 0o1131, 601
    'glyph602' => 635                       , # 0x25A, 0o1132, 602
    'glyph603' => 635                       , # 0x25B, 0o1133, 603
    'glyph604' => 635                       , # 0x25C, 0o1134, 604
    'Adotbelow' => 682                      , # 0x25D, 0o1135, 605
    'adotbelow' => 600                      , # 0x25E, 0o1136, 606
    'Ahookabove' => 682                     , # 0x25F, 0o1137, 607
    'ahookabove' => 600                     , # 0x260, 0o1140, 608
    'Acircumflexacute' => 682               , # 0x261, 0o1141, 609
    'acircumflexacute' => 600               , # 0x262, 0o1142, 610
    'Acircumflexgrave' => 682               , # 0x263, 0o1143, 611
    'acircumflexgrave' => 600               , # 0x264, 0o1144, 612
    'Acircumflexhookabove' => 682           , # 0x265, 0o1145, 613
    'acircumflexhookabove' => 600           , # 0x266, 0o1146, 614
    'Acircumflextilde' => 682               , # 0x267, 0o1147, 615
    'acircumflextilde' => 600               , # 0x268, 0o1150, 616
    'Acircumflexdotbelow' => 682            , # 0x269, 0o1151, 617
    'acircumflexdotbelow' => 600            , # 0x26A, 0o1152, 618
    'Abreveacute' => 682                    , # 0x26B, 0o1153, 619
    'abreveacute' => 600                    , # 0x26C, 0o1154, 620
    'Abrevegrave' => 682                    , # 0x26D, 0o1155, 621
    'abrevegrave' => 600                    , # 0x26E, 0o1156, 622
    'Abrevehookabove' => 682                , # 0x26F, 0o1157, 623
    'abrevehookabove' => 600                , # 0x270, 0o1160, 624
    'Abrevetilde' => 682                    , # 0x271, 0o1161, 625
    'abrevetilde' => 600                    , # 0x272, 0o1162, 626
    'Abrevedotbelow' => 682                 , # 0x273, 0o1163, 627
    'abrevedotbelow' => 600                 , # 0x274, 0o1164, 628
    'Edotbelow' => 632                      , # 0x275, 0o1165, 629
    'edotbelow' => 595                      , # 0x276, 0o1166, 630
    'Ehookabove' => 632                     , # 0x277, 0o1167, 631
    'ehookabove' => 595                     , # 0x278, 0o1170, 632
    'Etilde' => 632                         , # 0x279, 0o1171, 633
    'etilde' => 595                         , # 0x27A, 0o1172, 634
    'Ecircumflexacute' => 632               , # 0x27B, 0o1173, 635
    'ecircumflexacute' => 595               , # 0x27C, 0o1174, 636
    'Ecircumflexgrave' => 632               , # 0x27D, 0o1175, 637
    'ecircumflexgrave' => 595               , # 0x27E, 0o1176, 638
    'Ecircumflexhookabove' => 632           , # 0x27F, 0o1177, 639
    'ecircumflexhookabove' => 595           , # 0x280, 0o1200, 640
    'Ecircumflextilde' => 632               , # 0x281, 0o1201, 641
    'ecircumflextilde' => 595               , # 0x282, 0o1202, 642
    'Ecircumflexdotbelow' => 632            , # 0x283, 0o1203, 643
    'ecircumflexdotbelow' => 595            , # 0x284, 0o1204, 644
    'Ihookabove' => 420                     , # 0x285, 0o1205, 645
    'ihookabove' => 274                     , # 0x286, 0o1206, 646
    'Idotbelow' => 420                      , # 0x287, 0o1207, 647
    'idotbelow' => 274                      , # 0x288, 0o1210, 648
    'Odotbelow' => 787                      , # 0x34C, 0o1514, 844
    'odotbelow' => 606                      , # 0x34D, 0o1515, 845
    'Ohookabove' => 787                     , # 0x34E, 0o1516, 846
    'ohookabove' => 606                     , # 0x34F, 0o1517, 847
    'Ocircumflexacute' => 787               , # 0x350, 0o1520, 848
    'ocircumflexacute' => 606               , # 0x351, 0o1521, 849
    'Ocircumflexgrave' => 787               , # 0x352, 0o1522, 850
    'ocircumflexgrave' => 606               , # 0x353, 0o1523, 851
    'Ocircumflexhookabove' => 787           , # 0x354, 0o1524, 852
    'ocircumflexhookabove' => 606           , # 0x355, 0o1525, 853
    'Ocircumflextilde' => 787               , # 0x356, 0o1526, 854
    'ocircumflextilde' => 606               , # 0x357, 0o1527, 855
    'Ocircumflexdotbelow' => 787            , # 0x358, 0o1530, 856
    'ocircumflexdotbelow' => 606            , # 0x359, 0o1531, 857
    'Ohornacute' => 806                     , # 0x35A, 0o1532, 858
    'ohornacute' => 606                     , # 0x35B, 0o1533, 859
    'Ohorngrave' => 806                     , # 0x35C, 0o1534, 860
    'ohorngrave' => 606                     , # 0x35D, 0o1535, 861
    'Ohornhookabove' => 806                 , # 0x35E, 0o1536, 862
    'ohornhookabove' => 606                 , # 0x35F, 0o1537, 863
    'Ohorntilde' => 806                     , # 0x360, 0o1540, 864
    'ohorntilde' => 606                     , # 0x361, 0o1541, 865
    'Ohorndotbelow' => 806                  , # 0x362, 0o1542, 866
    'ohorndotbelow' => 606                  , # 0x363, 0o1543, 867
    'Udotbelow' => 731                      , # 0x364, 0o1544, 868
    'udotbelow' => 632                      , # 0x365, 0o1545, 869
    'Uhookabove' => 731                     , # 0x366, 0o1546, 870
    'uhookabove' => 632                     , # 0x367, 0o1547, 871
    'Uhornacute' => 756                     , # 0x368, 0o1550, 872
    'uhornacute' => 659                     , # 0x369, 0o1551, 873
    'Uhorngrave' => 756                     , # 0x36A, 0o1552, 874
    'uhorngrave' => 659                     , # 0x36B, 0o1553, 875
    'Uhornhookabove' => 756                 , # 0x36C, 0o1554, 876
    'uhornhookabove' => 659                 , # 0x36D, 0o1555, 877
    'Uhorntilde' => 756                     , # 0x36E, 0o1556, 878
    'uhorntilde' => 659                     , # 0x36F, 0o1557, 879
    'Uhorndotbelow' => 756                  , # 0x370, 0o1560, 880
    'uhorndotbelow' => 659                  , # 0x371, 0o1561, 881
    'glyph882' => 615                       , # 0x372, 0o1562, 882
    'glyph883' => 590                       , # 0x373, 0o1563, 883
    'Ydotbelow' => 615                      , # 0x374, 0o1564, 884
    'ydotbelow' => 590                      , # 0x375, 0o1565, 885
    'Yhookabove' => 615                     , # 0x376, 0o1566, 886
    'yhookabove' => 590                     , # 0x377, 0o1567, 887
    'Ytilde' => 615                         , # 0x378, 0o1570, 888
    'ytilde' => 590                         , # 0x379, 0o1571, 889
    'dong' => 623                           , # 0x37A, 0o1572, 890
    'tildecomb' => 0                        , # 0x37B, 0o1573, 891
    'currency' => 635                       , # 0x37C, 0o1574, 892
  },
};

1;
