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

$fonts->{'verdanabolditalic'} = {
  'apiname' => 'Ve3',
  'fontname' => 'Verdana,BoldItalic',
  'type' => 'TrueType',
  'ascender' => 1005,
  'capheight' => 727,
  'descender' => -209,
  'italicangle' => -13,
  'underlineposition' => -139,
  'underlinethickness' => 211,
  'xheight' => 548,
  'flags' => 262240,
  'isfixedpitch' => 0,
  'issymbol' => 0,
  'fontbbox' => [ -166, -207, 1704, 1000 ],
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
    'nonmarkingreturn' => 341               , # 0x02, 0o002, 2
    'space' => 341                          , # 0x03, 0o003, 3
    'exclam' => 402                         , # 0x04, 0o004, 4
    'quotedbl' => 587                       , # 0x05, 0o005, 5
    'numbersign' => 867                     , # 0x06, 0o006, 6
    'dollar' => 710                         , # 0x07, 0o007, 7
    'percent' => 1271                       , # 0x08, 0o010, 8
    'ampersand' => 862                      , # 0x09, 0o011, 9
    'quotesingle' => 332                    , # 0x0A, 0o012, 10
    'parenleft' => 543                      , # 0x0B, 0o013, 11
    'parenright' => 543                     , # 0x0C, 0o014, 12
    'asterisk' => 710                       , # 0x0D, 0o015, 13
    'plus' => 867                           , # 0x0E, 0o016, 14
    'comma' => 361                          , # 0x0F, 0o017, 15
    'hyphen' => 479                         , # 0x10, 0o020, 16
    'period' => 361                         , # 0x11, 0o021, 17
    'slash' => 689                          , # 0x12, 0o022, 18
    'zero' => 710                           , # 0x13, 0o023, 19
    'one' => 710                            , # 0x14, 0o024, 20
    'two' => 710                            , # 0x15, 0o025, 21
    'three' => 710                          , # 0x16, 0o026, 22
    'four' => 710                           , # 0x17, 0o027, 23
    'five' => 710                           , # 0x18, 0o030, 24
    'six' => 710                            , # 0x19, 0o031, 25
    'seven' => 710                          , # 0x1A, 0o032, 26
    'eight' => 710                          , # 0x1B, 0o033, 27
    'nine' => 710                           , # 0x1C, 0o034, 28
    'colon' => 402                          , # 0x1D, 0o035, 29
    'semicolon' => 402                      , # 0x1E, 0o036, 30
    'less' => 867                           , # 0x1F, 0o037, 31
    'equal' => 867                          , # 0x20, 0o040, 32
    'greater' => 867                        , # 0x21, 0o041, 33
    'question' => 616                       , # 0x22, 0o042, 34
    'at' => 963                             , # 0x23, 0o043, 35
    'A' => 776                              , # 0x24, 0o044, 36
    'B' => 761                              , # 0x25, 0o045, 37
    'C' => 723                              , # 0x26, 0o046, 38
    'D' => 830                              , # 0x27, 0o047, 39
    'E' => 683                              , # 0x28, 0o050, 40
    'F' => 650                              , # 0x29, 0o051, 41
    'G' => 811                              , # 0x2A, 0o052, 42
    'H' => 837                              , # 0x2B, 0o053, 43
    'I' => 545                              , # 0x2C, 0o054, 44
    'J' => 555                              , # 0x2D, 0o055, 45
    'K' => 770                              , # 0x2E, 0o056, 46
    'L' => 637                              , # 0x2F, 0o057, 47
    'M' => 947                              , # 0x30, 0o060, 48
    'N' => 846                              , # 0x31, 0o061, 49
    'O' => 850                              , # 0x32, 0o062, 50
    'P' => 732                              , # 0x33, 0o063, 51
    'Q' => 850                              , # 0x34, 0o064, 52
    'R' => 782                              , # 0x35, 0o065, 53
    'S' => 710                              , # 0x36, 0o066, 54
    'T' => 681                              , # 0x37, 0o067, 55
    'U' => 812                              , # 0x38, 0o070, 56
    'V' => 763                              , # 0x39, 0o071, 57
    'W' => 1128                             , # 0x3A, 0o072, 58
    'X' => 763                              , # 0x3B, 0o073, 59
    'Y' => 736                              , # 0x3C, 0o074, 60
    'Z' => 691                              , # 0x3D, 0o075, 61
    'bracketleft' => 543                    , # 0x3E, 0o076, 62
    'backslash' => 689                      , # 0x3F, 0o077, 63
    'bracketright' => 543                   , # 0x40, 0o100, 64
    'asciicircum' => 867                    , # 0x41, 0o101, 65
    'underscore' => 710                     , # 0x42, 0o102, 66
    'grave' => 710                          , # 0x43, 0o103, 67
    'a' => 667                              , # 0x44, 0o104, 68
    'b' => 699                              , # 0x45, 0o105, 69
    'c' => 588                              , # 0x46, 0o106, 70
    'd' => 699                              , # 0x47, 0o107, 71
    'e' => 664                              , # 0x48, 0o110, 72
    'f' => 422                              , # 0x49, 0o111, 73
    'g' => 699                              , # 0x4A, 0o112, 74
    'h' => 712                              , # 0x4B, 0o113, 75
    'i' => 341                              , # 0x4C, 0o114, 76
    'j' => 402                              , # 0x4D, 0o115, 77
    'k' => 670                              , # 0x4E, 0o116, 78
    'l' => 341                              , # 0x4F, 0o117, 79
    'm' => 1058                             , # 0x50, 0o120, 80
    'n' => 712                              , # 0x51, 0o121, 81
    'o' => 685                              , # 0x52, 0o122, 82
    'p' => 699                              , # 0x53, 0o123, 83
    'q' => 699                              , # 0x54, 0o124, 84
    'r' => 497                              , # 0x55, 0o125, 85
    's' => 593                              , # 0x56, 0o126, 86
    't' => 455                              , # 0x57, 0o127, 87
    'u' => 712                              , # 0x58, 0o130, 88
    'v' => 648                              , # 0x59, 0o131, 89
    'w' => 979                              , # 0x5A, 0o132, 90
    'x' => 668                              , # 0x5B, 0o133, 91
    'y' => 650                              , # 0x5C, 0o134, 92
    'z' => 596                              , # 0x5D, 0o135, 93
    'braceleft' => 710                      , # 0x5E, 0o136, 94
    'bar' => 543                            , # 0x5F, 0o137, 95
    'braceright' => 710                     , # 0x60, 0o140, 96
    'asciitilde' => 867                     , # 0x61, 0o141, 97
    'Adieresis' => 776                      , # 0x62, 0o142, 98
    'Aring' => 776                          , # 0x63, 0o143, 99
    'Ccedilla' => 723                       , # 0x64, 0o144, 100
    'Eacute' => 683                         , # 0x65, 0o145, 101
    'Ntilde' => 846                         , # 0x66, 0o146, 102
    'Odieresis' => 850                      , # 0x67, 0o147, 103
    'Udieresis' => 812                      , # 0x68, 0o150, 104
    'aacute' => 667                         , # 0x69, 0o151, 105
    'agrave' => 667                         , # 0x6A, 0o152, 106
    'acircumflex' => 667                    , # 0x6B, 0o153, 107
    'adieresis' => 667                      , # 0x6C, 0o154, 108
    'atilde' => 667                         , # 0x6D, 0o155, 109
    'aring' => 667                          , # 0x6E, 0o156, 110
    'ccedilla' => 588                       , # 0x6F, 0o157, 111
    'eacute' => 664                         , # 0x70, 0o160, 112
    'egrave' => 664                         , # 0x71, 0o161, 113
    'ecircumflex' => 664                    , # 0x72, 0o162, 114
    'edieresis' => 664                      , # 0x73, 0o163, 115
    'iacute' => 341                         , # 0x74, 0o164, 116
    'igrave' => 341                         , # 0x75, 0o165, 117
    'icircumflex' => 341                    , # 0x76, 0o166, 118
    'idieresis' => 341                      , # 0x77, 0o167, 119
    'ntilde' => 712                         , # 0x78, 0o170, 120
    'oacute' => 685                         , # 0x79, 0o171, 121
    'ograve' => 685                         , # 0x7A, 0o172, 122
    'ocircumflex' => 685                    , # 0x7B, 0o173, 123
    'odieresis' => 685                      , # 0x7C, 0o174, 124
    'otilde' => 685                         , # 0x7D, 0o175, 125
    'uacute' => 712                         , # 0x7E, 0o176, 126
    'ugrave' => 712                         , # 0x7F, 0o177, 127
    'ucircumflex' => 712                    , # 0x80, 0o200, 128
    'udieresis' => 712                      , # 0x81, 0o201, 129
    'dagger' => 710                         , # 0x82, 0o202, 130
    'degree' => 587                         , # 0x83, 0o203, 131
    'cent' => 710                           , # 0x84, 0o204, 132
    'sterling' => 710                       , # 0x85, 0o205, 133
    'section' => 710                        , # 0x86, 0o206, 134
    'bullet' => 710                         , # 0x87, 0o207, 135
    'paragraph' => 710                      , # 0x88, 0o210, 136
    'germandbls' => 712                     , # 0x89, 0o211, 137
    'registered' => 963                     , # 0x8A, 0o212, 138
    'copyright' => 963                      , # 0x8B, 0o213, 139
    'trademark' => 963                      , # 0x8C, 0o214, 140
    'acute' => 710                          , # 0x8D, 0o215, 141
    'dieresis' => 710                       , # 0x8E, 0o216, 142
    'notequal' => 867                       , # 0x8F, 0o217, 143
    'AE' => 1093                            , # 0x90, 0o220, 144
    'Oslash' => 850                         , # 0x91, 0o221, 145
    'infinity' => 1058                      , # 0x92, 0o222, 146
    'plusminus' => 867                      , # 0x93, 0o223, 147
    'lessequal' => 867                      , # 0x94, 0o224, 148
    'greaterequal' => 867                   , # 0x95, 0o225, 149
    'yen' => 710                            , # 0x96, 0o226, 150
    'mu1' => 721                            , # 0x97, 0o227, 151
    'partialdiff' => 710                    , # 0x98, 0o230, 152
    'summation' => 698                      , # 0x99, 0o231, 153
    'product' => 869                        , # 0x9A, 0o232, 154
    'pi1' => 708                            , # 0x9B, 0o233, 155
    'integral' => 538                       , # 0x9C, 0o234, 156
    'ordfeminine' => 597                    , # 0x9D, 0o235, 157
    'ordmasculine' => 597                   , # 0x9E, 0o236, 158
    'Ohm' => 843                            , # 0x9F, 0o237, 159
    'ae' => 1018                            , # 0xA0, 0o240, 160
    'oslash' => 685                         , # 0xA1, 0o241, 161
    'questiondown' => 616                   , # 0xA2, 0o242, 162
    'exclamdown' => 402                     , # 0xA3, 0o243, 163
    'logicalnot' => 867                     , # 0xA4, 0o244, 164
    'radical' => 867                        , # 0xA5, 0o245, 165
    'florin' => 710                         , # 0xA6, 0o246, 166
    'approxequal' => 867                    , # 0xA7, 0o247, 167
    'increment' => 805                      , # 0xA8, 0o250, 168
    'guillemotleft' => 849                  , # 0xA9, 0o251, 169
    'guillemotright' => 849                 , # 0xAA, 0o252, 170
    'ellipsis' => 1048                      , # 0xAB, 0o253, 171
    'Agrave' => 776                         , # 0xAC, 0o254, 172
    'Atilde' => 776                         , # 0xAD, 0o255, 173
    'Otilde' => 850                         , # 0xAE, 0o256, 174
    'OE' => 1135                            , # 0xAF, 0o257, 175
    'oe' => 1067                            , # 0xB0, 0o260, 176
    'endash' => 710                         , # 0xB1, 0o261, 177
    'emdash' => 1000                        , # 0xB2, 0o262, 178
    'quotedblleft' => 587                   , # 0xB3, 0o263, 179
    'quotedblright' => 587                  , # 0xB4, 0o264, 180
    'quoteleft' => 332                      , # 0xB5, 0o265, 181
    'quoteright' => 332                     , # 0xB6, 0o266, 182
    'divide' => 867                         , # 0xB7, 0o267, 183
    'lozenge' => 867                        , # 0xB8, 0o270, 184
    'ydieresis' => 650                      , # 0xB9, 0o271, 185
    'Ydieresis' => 736                      , # 0xBA, 0o272, 186
    'fraction' => 321                       , # 0xBB, 0o273, 187
    'Euro' => 710                           , # 0xBC, 0o274, 188
    'guilsinglleft' => 543                  , # 0xBD, 0o275, 189
    'guilsinglright' => 543                 , # 0xBE, 0o276, 190
    'fi' => 727                             , # 0xBF, 0o277, 191
    'fl' => 730                             , # 0xC0, 0o300, 192
    'daggerdbl' => 710                      , # 0xC1, 0o301, 193
    'periodcentered' => 361                 , # 0xC2, 0o302, 194
    'quotesinglbase' => 332                 , # 0xC3, 0o303, 195
    'quotedblbase' => 587                   , # 0xC4, 0o304, 196
    'perthousand' => 1777                   , # 0xC5, 0o305, 197
    'Acircumflex' => 776                    , # 0xC6, 0o306, 198
    'Ecircumflex' => 683                    , # 0xC7, 0o307, 199
    'Aacute' => 776                         , # 0xC8, 0o310, 200
    'Edieresis' => 683                      , # 0xC9, 0o311, 201
    'Egrave' => 683                         , # 0xCA, 0o312, 202
    'Iacute' => 545                         , # 0xCB, 0o313, 203
    'Icircumflex' => 545                    , # 0xCC, 0o314, 204
    'Idieresis' => 545                      , # 0xCD, 0o315, 205
    'Igrave' => 545                         , # 0xCE, 0o316, 206
    'Oacute' => 850                         , # 0xCF, 0o317, 207
    'Ocircumflex' => 850                    , # 0xD0, 0o320, 208
    'Ograve' => 850                         , # 0xD1, 0o321, 209
    'Uacute' => 812                         , # 0xD2, 0o322, 210
    'Ucircumflex' => 812                    , # 0xD3, 0o323, 211
    'Ugrave' => 812                         , # 0xD4, 0o324, 212
    'dotlessi' => 341                       , # 0xD5, 0o325, 213
    'circumflex' => 710                     , # 0xD6, 0o326, 214
    'tilde' => 710                          , # 0xD7, 0o327, 215
    'macron' => 710                         , # 0xD8, 0o330, 216
    'breve' => 710                          , # 0xD9, 0o331, 217
    'dotaccent' => 710                      , # 0xDA, 0o332, 218
    'ring' => 710                           , # 0xDB, 0o333, 219
    'cedilla' => 710                        , # 0xDC, 0o334, 220
    'hungarumlaut' => 710                   , # 0xDD, 0o335, 221
    'ogonek' => 710                         , # 0xDE, 0o336, 222
    'caron' => 710                          , # 0xDF, 0o337, 223
    'Lslash' => 637                         , # 0xE0, 0o340, 224
    'lslash' => 351                         , # 0xE1, 0o341, 225
    'Scaron' => 710                         , # 0xE2, 0o342, 226
    'scaron' => 593                         , # 0xE3, 0o343, 227
    'Zcaron' => 691                         , # 0xE4, 0o344, 228
    'zcaron' => 596                         , # 0xE5, 0o345, 229
    'brokenbar' => 543                      , # 0xE6, 0o346, 230
    'Eth' => 830                            , # 0xE7, 0o347, 231
    'eth' => 679                            , # 0xE8, 0o350, 232
    'Yacute' => 736                         , # 0xE9, 0o351, 233
    'yacute' => 650                         , # 0xEA, 0o352, 234
    'Thorn' => 734                          , # 0xEB, 0o353, 235
    'thorn' => 699                          , # 0xEC, 0o354, 236
    'minus' => 867                          , # 0xED, 0o355, 237
    'multiply' => 867                       , # 0xEE, 0o356, 238
    'onesuperior' => 597                    , # 0xEF, 0o357, 239
    'twosuperior' => 597                    , # 0xF0, 0o360, 240
    'threesuperior' => 597                  , # 0xF1, 0o361, 241
    'onehalf' => 1181                       , # 0xF2, 0o362, 242
    'onequarter' => 1181                    , # 0xF3, 0o363, 243
    'threequarters' => 1181                 , # 0xF4, 0o364, 244
    'franc' => 710                          , # 0xF5, 0o365, 245
    'Gbreve' => 811                         , # 0xF6, 0o366, 246
    'gbreve' => 699                         , # 0xF7, 0o367, 247
    'Idot' => 545                           , # 0xF8, 0o370, 248
    'Scedilla' => 710                       , # 0xF9, 0o371, 249
    'scedilla' => 593                       , # 0xFA, 0o372, 250
    'Cacute' => 723                         , # 0xFB, 0o373, 251
    'cacute' => 588                         , # 0xFC, 0o374, 252
    'Ccaron' => 723                         , # 0xFD, 0o375, 253
    'ccaron' => 588                         , # 0xFE, 0o376, 254
    'dmacron' => 699                        , # 0xFF, 0o377, 255
    'overscore' => 710                      , # 0x100, 0o400, 256
    'middot' => 361                         , # 0x101, 0o401, 257
    'Abreve' => 776                         , # 0x102, 0o402, 258
    'abreve' => 667                         , # 0x103, 0o403, 259
    'Aogonek' => 776                        , # 0x104, 0o404, 260
    'aogonek' => 667                        , # 0x105, 0o405, 261
    'Dcaron' => 830                         , # 0x106, 0o406, 262
    'dcaron' => 879                         , # 0x107, 0o407, 263
    'Dslash' => 830                         , # 0x108, 0o410, 264
    'Eogonek' => 683                        , # 0x109, 0o411, 265
    'eogonek' => 664                        , # 0x10A, 0o412, 266
    'Ecaron' => 683                         , # 0x10B, 0o413, 267
    'ecaron' => 664                         , # 0x10C, 0o414, 268
    'Lacute' => 637                         , # 0x10D, 0o415, 269
    'lacute' => 341                         , # 0x10E, 0o416, 270
    'Lcaron' => 637                         , # 0x10F, 0o417, 271
    'lcaron' => 522                         , # 0x110, 0o420, 272
    'Ldot' => 637                           , # 0x111, 0o421, 273
    'ldot' => 556                           , # 0x112, 0o422, 274
    'Nacute' => 846                         , # 0x113, 0o423, 275
    'nacute' => 712                         , # 0x114, 0o424, 276
    'Ncaron' => 846                         , # 0x115, 0o425, 277
    'ncaron' => 712                         , # 0x116, 0o426, 278
    'Odblacute' => 850                      , # 0x117, 0o427, 279
    'odblacute' => 685                      , # 0x118, 0o430, 280
    'Racute' => 782                         , # 0x119, 0o431, 281
    'racute' => 497                         , # 0x11A, 0o432, 282
    'Rcaron' => 782                         , # 0x11B, 0o433, 283
    'rcaron' => 497                         , # 0x11C, 0o434, 284
    'Sacute' => 710                         , # 0x11D, 0o435, 285
    'sacute' => 593                         , # 0x11E, 0o436, 286
    'Tcedilla' => 681                       , # 0x11F, 0o437, 287
    'tcedilla' => 455                       , # 0x120, 0o440, 288
    'Tcaron' => 681                         , # 0x121, 0o441, 289
    'tcaron' => 465                         , # 0x122, 0o442, 290
    'Uring' => 812                          , # 0x123, 0o443, 291
    'uring' => 712                          , # 0x124, 0o444, 292
    'Udblacute' => 812                      , # 0x125, 0o445, 293
    'udblacute' => 712                      , # 0x126, 0o446, 294
    'Zacute' => 691                         , # 0x127, 0o447, 295
    'zacute' => 596                         , # 0x128, 0o450, 296
    'Zdot' => 691                           , # 0x129, 0o451, 297
    'zdot' => 596                           , # 0x12A, 0o452, 298
    'Gamma' => 637                          , # 0x12B, 0o453, 299
    'Theta' => 850                          , # 0x12C, 0o454, 300
    'Phi' => 952                            , # 0x12D, 0o455, 301
    'alpha' => 699                          , # 0x12E, 0o456, 302
    'delta' => 686                          , # 0x12F, 0o457, 303
    'epsilon' => 584                        , # 0x130, 0o460, 304
    'sigma' => 725                          , # 0x131, 0o461, 305
    'tau' => 535                            , # 0x132, 0o462, 306
    'phi' => 914                            , # 0x133, 0o463, 307
    'underscoredbl' => 710                  , # 0x134, 0o464, 308
    'exclamdbl' => 703                      , # 0x135, 0o465, 309
    'nsuperior' => 597                      , # 0x136, 0o466, 310
    'peseta' => 1343                        , # 0x137, 0o467, 311
    'IJ' => 1007                            , # 0x138, 0o470, 312
    'ij' => 727                             , # 0x139, 0o471, 313
    'napostrophe' => 825                    , # 0x13A, 0o472, 314
    'minute' => 352                         , # 0x13B, 0o473, 315
    'second' => 616                         , # 0x13C, 0o474, 316
    'afii61248' => 1271                     , # 0x13D, 0o475, 317
    'afii61289' => 414                      , # 0x13E, 0o476, 318
    'H22073' => 604                         , # 0x13F, 0o477, 319
    'H18543' => 354                         , # 0x140, 0o500, 320
    'H18551' => 354                         , # 0x141, 0o501, 321
    'H18533' => 604                         , # 0x142, 0o502, 322
    'openbullet' => 354                     , # 0x143, 0o503, 323
    'Amacron' => 776                        , # 0x144, 0o504, 324
    'amacron' => 667                        , # 0x145, 0o505, 325
    'Ccircumflex' => 723                    , # 0x146, 0o506, 326
    'ccircumflex' => 588                    , # 0x147, 0o507, 327
    'Cdot' => 723                           , # 0x148, 0o510, 328
    'cdot' => 588                           , # 0x149, 0o511, 329
    'Emacron' => 683                        , # 0x14A, 0o512, 330
    'emacron' => 664                        , # 0x14B, 0o513, 331
    'Ebreve' => 683                         , # 0x14C, 0o514, 332
    'ebreve' => 664                         , # 0x14D, 0o515, 333
    'Edot' => 683                           , # 0x14E, 0o516, 334
    'edot' => 664                           , # 0x14F, 0o517, 335
    'Gcircumflex' => 811                    , # 0x150, 0o520, 336
    'gcircumflex' => 699                    , # 0x151, 0o521, 337
    'Gdot' => 811                           , # 0x152, 0o522, 338
    'gdot' => 699                           , # 0x153, 0o523, 339
    'Gcedilla' => 811                       , # 0x154, 0o524, 340
    'gcedilla' => 699                       , # 0x155, 0o525, 341
    'Hcircumflex' => 837                    , # 0x156, 0o526, 342
    'hcircumflex' => 712                    , # 0x157, 0o527, 343
    'Hbar' => 837                           , # 0x158, 0o530, 344
    'hbar' => 712                           , # 0x159, 0o531, 345
    'Itilde' => 545                         , # 0x15A, 0o532, 346
    'itilde' => 341                         , # 0x15B, 0o533, 347
    'Imacron' => 545                        , # 0x15C, 0o534, 348
    'imacron' => 341                        , # 0x15D, 0o535, 349
    'Ibreve' => 545                         , # 0x15E, 0o536, 350
    'ibreve' => 341                         , # 0x15F, 0o537, 351
    'Iogonek' => 545                        , # 0x160, 0o540, 352
    'iogonek' => 341                        , # 0x161, 0o541, 353
    'Jcircumflex' => 555                    , # 0x162, 0o542, 354
    'jcircumflex' => 402                    , # 0x163, 0o543, 355
    'Kcedilla' => 770                       , # 0x164, 0o544, 356
    'kcedilla' => 670                       , # 0x165, 0o545, 357
    'kgreenlandic' => 670                   , # 0x166, 0o546, 358
    'Lcedilla' => 637                       , # 0x167, 0o547, 359
    'lcedilla' => 341                       , # 0x168, 0o550, 360
    'Ncedilla' => 846                       , # 0x169, 0o551, 361
    'ncedilla' => 712                       , # 0x16A, 0o552, 362
    'Eng' => 846                            , # 0x16B, 0o553, 363
    'eng' => 712                            , # 0x16C, 0o554, 364
    'Omacron' => 850                        , # 0x16D, 0o555, 365
    'omacron' => 685                        , # 0x16E, 0o556, 366
    'Obreve' => 850                         , # 0x16F, 0o557, 367
    'obreve' => 685                         , # 0x170, 0o560, 368
    'Rcedilla' => 782                       , # 0x171, 0o561, 369
    'rcedilla' => 497                       , # 0x172, 0o562, 370
    'Scircumflex' => 710                    , # 0x173, 0o563, 371
    'scircumflex' => 593                    , # 0x174, 0o564, 372
    'Tbar' => 681                           , # 0x175, 0o565, 373
    'tbar' => 455                           , # 0x176, 0o566, 374
    'Utilde' => 812                         , # 0x177, 0o567, 375
    'utilde' => 712                         , # 0x178, 0o570, 376
    'Umacron' => 812                        , # 0x179, 0o571, 377
    'umacron' => 712                        , # 0x17A, 0o572, 378
    'Ubreve' => 812                         , # 0x17B, 0o573, 379
    'ubreve' => 712                         , # 0x17C, 0o574, 380
    'Uogonek' => 812                        , # 0x17D, 0o575, 381
    'uogonek' => 712                        , # 0x17E, 0o576, 382
    'Wcircumflex' => 1128                   , # 0x17F, 0o577, 383
    'wcircumflex' => 979                    , # 0x180, 0o600, 384
    'Ycircumflex' => 736                    , # 0x181, 0o601, 385
    'ycircumflex' => 650                    , # 0x182, 0o602, 386
    'longs' => 344                          , # 0x183, 0o603, 387
    'Aringacute' => 776                     , # 0x184, 0o604, 388
    'aringacute' => 667                     , # 0x185, 0o605, 389
    'AEacute' => 1093                       , # 0x186, 0o606, 390
    'aeacute' => 1018                       , # 0x187, 0o607, 391
    'Oslashacute' => 850                    , # 0x188, 0o610, 392
    'oslashacute' => 685                    , # 0x189, 0o611, 393
    'anoteleia' => 402                      , # 0x18A, 0o612, 394
    'Wgrave' => 1128                        , # 0x18B, 0o613, 395
    'wgrave' => 979                         , # 0x18C, 0o614, 396
    'Wacute' => 1128                        , # 0x18D, 0o615, 397
    'wacute' => 979                         , # 0x18E, 0o616, 398
    'Wdieresis' => 1128                     , # 0x18F, 0o617, 399
    'wdieresis' => 979                      , # 0x190, 0o620, 400
    'Ygrave' => 736                         , # 0x191, 0o621, 401
    'ygrave' => 650                         , # 0x192, 0o622, 402
    'quotereversed' => 332                  , # 0x193, 0o623, 403
    'radicalex' => 710                      , # 0x194, 0o624, 404
    'afii08941' => 710                      , # 0x195, 0o625, 405
    'estimated' => 748                      , # 0x196, 0o626, 406
    'oneeighth' => 1181                     , # 0x197, 0o627, 407
    'threeeighths' => 1181                  , # 0x198, 0o630, 408
    'fiveeighths' => 1181                   , # 0x199, 0o631, 409
    'seveneighths' => 1181                  , # 0x19A, 0o632, 410
    'commaaccent' => 361                    , # 0x19B, 0o633, 411
    'undercommaaccent' => 710               , # 0x19C, 0o634, 412
    'tonos' => 710                          , # 0x19D, 0o635, 413
    'dieresistonos' => 710                  , # 0x19E, 0o636, 414
    'Alphatonos' => 797                     , # 0x19F, 0o637, 415
    'Epsilontonos' => 847                   , # 0x1A0, 0o640, 416
    'Etatonos' => 1000                      , # 0x1A1, 0o641, 417
    'Iotatonos' => 705                      , # 0x1A2, 0o642, 418
    'Omicrontonos' => 968                   , # 0x1A3, 0o643, 419
    'Upsilontonos' => 939                   , # 0x1A4, 0o644, 420
    'Omegatonos' => 970                     , # 0x1A5, 0o645, 421
    'iotadieresistonos' => 341              , # 0x1A6, 0o646, 422
    'Alpha' => 776                          , # 0x1A7, 0o647, 423
    'Beta' => 761                           , # 0x1A8, 0o650, 424
    'Delta' => 805                          , # 0x1A9, 0o651, 425
    'Epsilon' => 683                        , # 0x1AA, 0o652, 426
    'Zeta' => 691                           , # 0x1AB, 0o653, 427
    'Eta' => 837                            , # 0x1AC, 0o654, 428
    'Iota' => 545                           , # 0x1AD, 0o655, 429
    'Kappa' => 770                          , # 0x1AE, 0o656, 430
    'Lambda' => 776                         , # 0x1AF, 0o657, 431
    'Mu' => 947                             , # 0x1B0, 0o660, 432
    'Nu' => 846                             , # 0x1B1, 0o661, 433
    'Xi' => 714                             , # 0x1B2, 0o662, 434
    'Omicron' => 850                        , # 0x1B3, 0o663, 435
    'Pi' => 837                             , # 0x1B4, 0o664, 436
    'Rho' => 732                            , # 0x1B5, 0o665, 437
    'Sigma' => 683                          , # 0x1B6, 0o666, 438
    'Tau' => 681                            , # 0x1B7, 0o667, 439
    'Upsilon' => 736                        , # 0x1B8, 0o670, 440
    'Chi' => 763                            , # 0x1B9, 0o671, 441
    'Psi' => 976                            , # 0x1BA, 0o672, 442
    'Omega' => 843                          , # 0x1BB, 0o673, 443
    'Iotadieresis' => 545                   , # 0x1BC, 0o674, 444
    'Upsilondieresis' => 736                , # 0x1BD, 0o675, 445
    'alphatonos' => 699                     , # 0x1BE, 0o676, 446
    'epsilontonos' => 584                   , # 0x1BF, 0o677, 447
    'etatonos' => 712                       , # 0x1C0, 0o700, 448
    'iotatonos' => 341                      , # 0x1C1, 0o701, 449
    'upsilondieresistonos' => 706           , # 0x1C2, 0o702, 450
    'beta' => 716                           , # 0x1C3, 0o703, 451
    'gamma' => 650                          , # 0x1C4, 0o704, 452
    'zeta' => 549                           , # 0x1C5, 0o705, 453
    'eta' => 712                            , # 0x1C6, 0o706, 454
    'theta' => 700                          , # 0x1C7, 0o707, 455
    'iota' => 341                           , # 0x1C8, 0o710, 456
    'kappa' => 670                          , # 0x1C9, 0o711, 457
    'lambda' => 650                         , # 0x1CA, 0o712, 458
    'mu' => 719                             , # 0x1CB, 0o713, 459
    'nu' => 648                             , # 0x1CC, 0o714, 460
    'xi' => 580                             , # 0x1CD, 0o715, 461
    'omicron' => 685                        , # 0x1CE, 0o716, 462
    'rho' => 699                            , # 0x1CF, 0o717, 463
    'sigma1' => 562                         , # 0x1D0, 0o720, 464
    'upsilon' => 706                        , # 0x1D1, 0o721, 465
    'chi' => 635                            , # 0x1D2, 0o722, 466
    'psi' => 941                            , # 0x1D3, 0o723, 467
    'omega' => 894                          , # 0x1D4, 0o724, 468
    'iotadieresis' => 341                   , # 0x1D5, 0o725, 469
    'upsilondieresis' => 706                , # 0x1D6, 0o726, 470
    'omicrontonos' => 685                   , # 0x1D7, 0o727, 471
    'upsilontonos' => 706                   , # 0x1D8, 0o730, 472
    'omegatonos' => 894                     , # 0x1D9, 0o731, 473
    'afii10023' => 683                      , # 0x1DA, 0o732, 474
    'afii10051' => 910                      , # 0x1DB, 0o733, 475
    'afii10052' => 637                      , # 0x1DC, 0o734, 476
    'afii10053' => 741                      , # 0x1DD, 0o735, 477
    'afii10054' => 710                      , # 0x1DE, 0o736, 478
    'afii10055' => 545                      , # 0x1DF, 0o737, 479
    'afii10056' => 545                      , # 0x1E0, 0o740, 480
    'afii10057' => 555                      , # 0x1E1, 0o741, 481
    'afii10058' => 1222                     , # 0x1E2, 0o742, 482
    'afii10059' => 1214                     , # 0x1E3, 0o743, 483
    'afii10060' => 936                      , # 0x1E4, 0o744, 484
    'afii10061' => 770                      , # 0x1E5, 0o745, 485
    'afii10062' => 736                      , # 0x1E6, 0o746, 486
    'afii10145' => 837                      , # 0x1E7, 0o747, 487
    'afii10017' => 776                      , # 0x1E8, 0o750, 488
    'afii10018' => 757                      , # 0x1E9, 0o751, 489
    'afii10019' => 761                      , # 0x1EA, 0o752, 490
    'afii10020' => 637                      , # 0x1EB, 0o753, 491
    'afii10021' => 841                      , # 0x1EC, 0o754, 492
    'afii10022' => 683                      , # 0x1ED, 0o755, 493
    'afii10024' => 1115                     , # 0x1EE, 0o756, 494
    'afii10025' => 706                      , # 0x1EF, 0o757, 495
    'afii10026' => 848                      , # 0x1F0, 0o760, 496
    'afii10027' => 848                      , # 0x1F1, 0o761, 497
    'afii10028' => 770                      , # 0x1F2, 0o762, 498
    'afii10029' => 845                      , # 0x1F3, 0o763, 499
    'afii10030' => 947                      , # 0x1F4, 0o764, 500
    'afii10031' => 837                      , # 0x1F5, 0o765, 501
    'afii10032' => 850                      , # 0x1F6, 0o766, 502
    'afii10033' => 837                      , # 0x1F7, 0o767, 503
    'afii10034' => 732                      , # 0x1F8, 0o770, 504
    'afii10035' => 723                      , # 0x1F9, 0o771, 505
    'afii10036' => 681                      , # 0x1FA, 0o772, 506
    'afii10037' => 736                      , # 0x1FB, 0o773, 507
    'afii10038' => 952                      , # 0x1FC, 0o774, 508
    'afii10039' => 763                      , # 0x1FD, 0o775, 509
    'afii10040' => 849                      , # 0x1FE, 0o776, 510
    'afii10041' => 787                      , # 0x1FF, 0o777, 511
    'afii10042' => 1163                     , # 0x200, 0o1000, 512
    'afii10043' => 1177                     , # 0x201, 0o1001, 513
    'afii10044' => 907                      , # 0x202, 0o1002, 514
    'afii10045' => 1062                     , # 0x203, 0o1003, 515
    'afii10046' => 757                      , # 0x204, 0o1004, 516
    'afii10047' => 741                      , # 0x205, 0o1005, 517
    'afii10048' => 1195                     , # 0x206, 0o1006, 518
    'afii10049' => 794                      , # 0x207, 0o1007, 519
    'afii10065' => 667                      , # 0x208, 0o1010, 520
    'afii10066' => 696                      , # 0x209, 0o1011, 521
    'afii10067' => 677                      , # 0x20A, 0o1012, 522
    'afii10068' => 531                      , # 0x20B, 0o1013, 523
    'afii10069' => 691                      , # 0x20C, 0o1014, 524
    'afii10070' => 664                      , # 0x20D, 0o1015, 525
    'afii10072' => 999                      , # 0x20E, 0o1016, 526
    'afii10073' => 587                      , # 0x20F, 0o1017, 527
    'afii10074' => 722                      , # 0x210, 0o1020, 528
    'afii10075' => 722                      , # 0x211, 0o1021, 529
    'afii10076' => 670                      , # 0x212, 0o1022, 530
    'afii10077' => 709                      , # 0x213, 0o1023, 531
    'afii10078' => 830                      , # 0x214, 0o1024, 532
    'afii10079' => 719                      , # 0x215, 0o1025, 533
    'afii10080' => 685                      , # 0x216, 0o1026, 534
    'afii10081' => 719                      , # 0x217, 0o1027, 535
    'afii10082' => 699                      , # 0x218, 0o1030, 536
    'afii10083' => 588                      , # 0x219, 0o1031, 537
    'afii10084' => 535                      , # 0x21A, 0o1032, 538
    'afii10085' => 650                      , # 0x21B, 0o1033, 539
    'afii10086' => 965                      , # 0x21C, 0o1034, 540
    'afii10087' => 668                      , # 0x21D, 0o1035, 541
    'afii10088' => 729                      , # 0x21E, 0o1036, 542
    'afii10089' => 684                      , # 0x21F, 0o1037, 543
    'afii10090' => 1002                     , # 0x220, 0o1040, 544
    'afii10091' => 1012                     , # 0x221, 0o1041, 545
    'afii10092' => 743                      , # 0x222, 0o1042, 546
    'afii10093' => 937                      , # 0x223, 0o1043, 547
    'afii10094' => 649                      , # 0x224, 0o1044, 548
    'afii10095' => 608                      , # 0x225, 0o1045, 549
    'afii10096' => 994                      , # 0x226, 0o1046, 550
    'afii10097' => 681                      , # 0x227, 0o1047, 551
    'afii10071' => 664                      , # 0x228, 0o1050, 552
    'afii10099' => 712                      , # 0x229, 0o1051, 553
    'afii10100' => 531                      , # 0x22A, 0o1052, 554
    'afii10101' => 605                      , # 0x22B, 0o1053, 555
    'afii10102' => 593                      , # 0x22C, 0o1054, 556
    'afii10103' => 341                      , # 0x22D, 0o1055, 557
    'afii10104' => 341                      , # 0x22E, 0o1056, 558
    'afii10105' => 402                      , # 0x22F, 0o1057, 559
    'afii10106' => 1012                     , # 0x230, 0o1060, 560
    'afii10107' => 1019                     , # 0x231, 0o1061, 561
    'afii10108' => 712                      , # 0x232, 0o1062, 562
    'afii10109' => 670                      , # 0x233, 0o1063, 563
    'afii10110' => 650                      , # 0x234, 0o1064, 564
    'afii10193' => 719                      , # 0x235, 0o1065, 565
    'afii10050' => 637                      , # 0x236, 0o1066, 566
    'afii10098' => 531                      , # 0x237, 0o1067, 567
    'afii00208' => 1000                     , # 0x238, 0o1070, 568
    'afii61352' => 1293                     , # 0x239, 0o1071, 569
    'pi' => 719                             , # 0x23A, 0o1072, 570
    'foursuperior' => 597                   , # 0x23B, 0o1073, 571
    'fivesuperior' => 597                   , # 0x23C, 0o1074, 572
    'sevensuperior' => 597                  , # 0x23D, 0o1075, 573
    'eightsuperior' => 597                  , # 0x23E, 0o1076, 574
    'onesupforfrac' => 597                  , # 0x23F, 0o1077, 575
    'DontCompressHTMX' => 0                 , # 0x240, 0o1100, 576
    'glyph577' => 0                         , # 0x241, 0o1101, 577
    'glyph578' => 0                         , # 0x242, 0o1102, 578
    'glyph579' => 0                         , # 0x243, 0o1103, 579
    'glyph580' => 0                         , # 0x244, 0o1104, 580
    'glyph581' => 0                         , # 0x245, 0o1105, 581
    'Ohorn' => 913                          , # 0x246, 0o1106, 582
    'ohorn' => 685                          , # 0x247, 0o1107, 583
    'Uhorn' => 846                          , # 0x248, 0o1110, 584
    'uhorn' => 741                          , # 0x249, 0o1111, 585
    'hookabovecomb' => 0                    , # 0x24A, 0o1112, 586
    'dotbelowcomb' => 0                     , # 0x24B, 0o1113, 587
    'gravecomb' => 0                        , # 0x24C, 0o1114, 588
    'acutecomb' => 0                        , # 0x24D, 0o1115, 589
    'glyph590' => 710                       , # 0x24E, 0o1116, 590
    'glyph591' => 710                       , # 0x24F, 0o1117, 591
    'glyph592' => 710                       , # 0x250, 0o1120, 592
    'glyph593' => 710                       , # 0x251, 0o1121, 593
    'glyph594' => 710                       , # 0x252, 0o1122, 594
    'glyph595' => 710                       , # 0x253, 0o1123, 595
    'glyph596' => 710                       , # 0x254, 0o1124, 596
    'glyph597' => 710                       , # 0x255, 0o1125, 597
    'glyph598' => 710                       , # 0x256, 0o1126, 598
    'glyph599' => 710                       , # 0x257, 0o1127, 599
    'glyph600' => 710                       , # 0x258, 0o1130, 600
    'glyph601' => 710                       , # 0x259, 0o1131, 601
    'glyph602' => 710                       , # 0x25A, 0o1132, 602
    'glyph603' => 710                       , # 0x25B, 0o1133, 603
    'glyph604' => 710                       , # 0x25C, 0o1134, 604
    'Adotbelow' => 776                      , # 0x25D, 0o1135, 605
    'adotbelow' => 667                      , # 0x25E, 0o1136, 606
    'Ahookabove' => 776                     , # 0x25F, 0o1137, 607
    'ahookabove' => 667                     , # 0x260, 0o1140, 608
    'Acircumflexacute' => 776               , # 0x261, 0o1141, 609
    'acircumflexacute' => 667               , # 0x262, 0o1142, 610
    'Acircumflexgrave' => 776               , # 0x263, 0o1143, 611
    'acircumflexgrave' => 667               , # 0x264, 0o1144, 612
    'Acircumflexhookabove' => 776           , # 0x265, 0o1145, 613
    'acircumflexhookabove' => 667           , # 0x266, 0o1146, 614
    'Acircumflextilde' => 776               , # 0x267, 0o1147, 615
    'acircumflextilde' => 667               , # 0x268, 0o1150, 616
    'Acircumflexdotbelow' => 776            , # 0x269, 0o1151, 617
    'acircumflexdotbelow' => 667            , # 0x26A, 0o1152, 618
    'Abreveacute' => 776                    , # 0x26B, 0o1153, 619
    'abreveacute' => 667                    , # 0x26C, 0o1154, 620
    'Abrevegrave' => 776                    , # 0x26D, 0o1155, 621
    'abrevegrave' => 667                    , # 0x26E, 0o1156, 622
    'Abrevehookabove' => 776                , # 0x26F, 0o1157, 623
    'abrevehookabove' => 667                , # 0x270, 0o1160, 624
    'Abrevetilde' => 776                    , # 0x271, 0o1161, 625
    'abrevetilde' => 667                    , # 0x272, 0o1162, 626
    'Abrevedotbelow' => 776                 , # 0x273, 0o1163, 627
    'abrevedotbelow' => 667                 , # 0x274, 0o1164, 628
    'Edotbelow' => 683                      , # 0x275, 0o1165, 629
    'edotbelow' => 664                      , # 0x276, 0o1166, 630
    'Ehookabove' => 683                     , # 0x277, 0o1167, 631
    'ehookabove' => 664                     , # 0x278, 0o1170, 632
    'Etilde' => 683                         , # 0x279, 0o1171, 633
    'etilde' => 664                         , # 0x27A, 0o1172, 634
    'Ecircumflexacute' => 683               , # 0x27B, 0o1173, 635
    'ecircumflexacute' => 664               , # 0x27C, 0o1174, 636
    'Ecircumflexgrave' => 683               , # 0x27D, 0o1175, 637
    'ecircumflexgrave' => 664               , # 0x27E, 0o1176, 638
    'Ecircumflexhookabove' => 683           , # 0x27F, 0o1177, 639
    'ecircumflexhookabove' => 664           , # 0x280, 0o1200, 640
    'Ecircumflextilde' => 683               , # 0x281, 0o1201, 641
    'ecircumflextilde' => 664               , # 0x282, 0o1202, 642
    'Ecircumflexdotbelow' => 683            , # 0x283, 0o1203, 643
    'ecircumflexdotbelow' => 664            , # 0x284, 0o1204, 644
    'Ihookabove' => 545                     , # 0x285, 0o1205, 645
    'ihookabove' => 341                     , # 0x286, 0o1206, 646
    'Idotbelow' => 545                      , # 0x287, 0o1207, 647
    'idotbelow' => 341                      , # 0x288, 0o1210, 648
    'glyph649' => 0                         , # 0x289, 0o1211, 649
    'glyph650' => 0                         , # 0x28A, 0o1212, 650
    'glyph651' => 0                         , # 0x28B, 0o1213, 651
    'glyph652' => 0                         , # 0x28C, 0o1214, 652
    'sheva' => 0                            , # 0x28D, 0o1215, 653
    'hatafsegol' => 0                       , # 0x28E, 0o1216, 654
    'hatafpatah' => 0                       , # 0x28F, 0o1217, 655
    'hatafqamats' => 0                      , # 0x290, 0o1220, 656
    'hiriq' => 0                            , # 0x291, 0o1221, 657
    'tsere' => 0                            , # 0x292, 0o1222, 658
    'segol' => 0                            , # 0x293, 0o1223, 659
    'patah' => 0                            , # 0x294, 0o1224, 660
    'qamats' => 0                           , # 0x295, 0o1225, 661
    'holam' => 0                            , # 0x296, 0o1226, 662
    'qubuts' => 0                           , # 0x297, 0o1227, 663
    'dagesh' => 0                           , # 0x298, 0o1230, 664
    'meteg' => 0                            , # 0x299, 0o1231, 665
    'maqaf' => 0                            , # 0x29A, 0o1232, 666
    'rafe' => 0                             , # 0x29B, 0o1233, 667
    'paseq' => 0                            , # 0x29C, 0o1234, 668
    'shindot' => 0                          , # 0x29D, 0o1235, 669
    'sindot' => 0                           , # 0x29E, 0o1236, 670
    'sofpasuq' => 0                         , # 0x29F, 0o1237, 671
    'alef' => 0                             , # 0x2A0, 0o1240, 672
    'bet' => 0                              , # 0x2A1, 0o1241, 673
    'gimel' => 0                            , # 0x2A2, 0o1242, 674
    'dalet' => 0                            , # 0x2A3, 0o1243, 675
    'he' => 0                               , # 0x2A4, 0o1244, 676
    'vav' => 0                              , # 0x2A5, 0o1245, 677
    'zayin' => 0                            , # 0x2A6, 0o1246, 678
    'het' => 0                              , # 0x2A7, 0o1247, 679
    'tet' => 0                              , # 0x2A8, 0o1250, 680
    'yod' => 0                              , # 0x2A9, 0o1251, 681
    'finalkaf' => 0                         , # 0x2AA, 0o1252, 682
    'kaf' => 0                              , # 0x2AB, 0o1253, 683
    'lamed' => 0                            , # 0x2AC, 0o1254, 684
    'finalmem' => 0                         , # 0x2AD, 0o1255, 685
    'mem' => 0                              , # 0x2AE, 0o1256, 686
    'finalnun' => 0                         , # 0x2AF, 0o1257, 687
    'nun' => 0                              , # 0x2B0, 0o1260, 688
    'samekh' => 0                           , # 0x2B1, 0o1261, 689
    'ayin' => 0                             , # 0x2B2, 0o1262, 690
    'finalpe' => 0                          , # 0x2B3, 0o1263, 691
    'pe' => 0                               , # 0x2B4, 0o1264, 692
    'finaltsadi' => 0                       , # 0x2B5, 0o1265, 693
    'tsadi' => 0                            , # 0x2B6, 0o1266, 694
    'qof' => 0                              , # 0x2B7, 0o1267, 695
    'resh' => 0                             , # 0x2B8, 0o1270, 696
    'shin' => 0                             , # 0x2B9, 0o1271, 697
    'tav' => 0                              , # 0x2BA, 0o1272, 698
    'doublevav' => 0                        , # 0x2BB, 0o1273, 699
    'vavyod' => 0                           , # 0x2BC, 0o1274, 700
    'doubleyod' => 0                        , # 0x2BD, 0o1275, 701
    'geresh' => 0                           , # 0x2BE, 0o1276, 702
    'gershayim' => 0                        , # 0x2BF, 0o1277, 703
    'newsheqelsign' => 0                    , # 0x2C0, 0o1300, 704
    'vavshindot' => 0                       , # 0x2C1, 0o1301, 705
    'finalkafsheva' => 0                    , # 0x2C2, 0o1302, 706
    'finalkafqamats' => 0                   , # 0x2C3, 0o1303, 707
    'lamedholam' => 0                       , # 0x2C4, 0o1304, 708
    'lamedholamdagesh' => 0                 , # 0x2C5, 0o1305, 709
    'altayin' => 0                          , # 0x2C6, 0o1306, 710
    'shinshindot' => 0                      , # 0x2C7, 0o1307, 711
    'shinsindot' => 0                       , # 0x2C8, 0o1310, 712
    'shindageshshindot' => 0                , # 0x2C9, 0o1311, 713
    'shindageshsindot' => 0                 , # 0x2CA, 0o1312, 714
    'alefpatah' => 0                        , # 0x2CB, 0o1313, 715
    'alefqamats' => 0                       , # 0x2CC, 0o1314, 716
    'alefmapiq' => 0                        , # 0x2CD, 0o1315, 717
    'betdagesh' => 0                        , # 0x2CE, 0o1316, 718
    'gimeldagesh' => 0                      , # 0x2CF, 0o1317, 719
    'daletdagesh' => 0                      , # 0x2D0, 0o1320, 720
    'hedagesh' => 0                         , # 0x2D1, 0o1321, 721
    'vavdagesh' => 0                        , # 0x2D2, 0o1322, 722
    'zayindagesh' => 0                      , # 0x2D3, 0o1323, 723
    'tetdagesh' => 0                        , # 0x2D4, 0o1324, 724
    'yoddagesh' => 0                        , # 0x2D5, 0o1325, 725
    'finalkafdagesh' => 0                   , # 0x2D6, 0o1326, 726
    'kafdagesh' => 0                        , # 0x2D7, 0o1327, 727
    'lameddagesh' => 0                      , # 0x2D8, 0o1330, 728
    'memdagesh' => 0                        , # 0x2D9, 0o1331, 729
    'nundagesh' => 0                        , # 0x2DA, 0o1332, 730
    'samekhdagesh' => 0                     , # 0x2DB, 0o1333, 731
    'finalpedagesh' => 0                    , # 0x2DC, 0o1334, 732
    'pedagesh' => 0                         , # 0x2DD, 0o1335, 733
    'tsadidagesh' => 0                      , # 0x2DE, 0o1336, 734
    'qofdagesh' => 0                        , # 0x2DF, 0o1337, 735
    'reshdagesh' => 0                       , # 0x2E0, 0o1340, 736
    'shindagesh' => 0                       , # 0x2E1, 0o1341, 737
    'tavdages' => 0                         , # 0x2E2, 0o1342, 738
    'vavholam' => 0                         , # 0x2E3, 0o1343, 739
    'betrafe' => 0                          , # 0x2E4, 0o1344, 740
    'kafrafe' => 0                          , # 0x2E5, 0o1345, 741
    'perafe' => 0                           , # 0x2E6, 0o1346, 742
    'aleflamed' => 0                        , # 0x2E7, 0o1347, 743
    'zerowidthnonjoiner' => 0               , # 0x2E8, 0o1350, 744
    'zerowidthjoiner' => 0                  , # 0x2E9, 0o1351, 745
    'lefttorightmark' => 0                  , # 0x2EA, 0o1352, 746
    'righttoleftmark' => 0                  , # 0x2EB, 0o1353, 747
    'afii57388' => 0                        , # 0x2EC, 0o1354, 748
    'afii57403' => 0                        , # 0x2ED, 0o1355, 749
    'afii57407' => 0                        , # 0x2EE, 0o1356, 750
    'afii57409' => 0                        , # 0x2EF, 0o1357, 751
    'afii57440' => 0                        , # 0x2F0, 0o1360, 752
    'afii57451' => 0                        , # 0x2F1, 0o1361, 753
    'afii57452' => 0                        , # 0x2F2, 0o1362, 754
    'afii57453' => 0                        , # 0x2F3, 0o1363, 755
    'afii57454' => 0                        , # 0x2F4, 0o1364, 756
    'afii57455' => 0                        , # 0x2F5, 0o1365, 757
    'afii57456' => 0                        , # 0x2F6, 0o1366, 758
    'afii57457' => 0                        , # 0x2F7, 0o1367, 759
    'afii57458' => 0                        , # 0x2F8, 0o1370, 760
    'afii57392' => 0                        , # 0x2F9, 0o1371, 761
    'afii57393' => 0                        , # 0x2FA, 0o1372, 762
    'afii57394' => 0                        , # 0x2FB, 0o1373, 763
    'afii57395' => 0                        , # 0x2FC, 0o1374, 764
    'afii57396' => 0                        , # 0x2FD, 0o1375, 765
    'afii57397' => 0                        , # 0x2FE, 0o1376, 766
    'afii57398' => 0                        , # 0x2FF, 0o1377, 767
    'afii57399' => 0                        , # 0x300, 0o1400, 768
    'afii57400' => 0                        , # 0x301, 0o1401, 769
    'afii57401' => 0                        , # 0x302, 0o1402, 770
    'afii57381' => 0                        , # 0x303, 0o1403, 771
    'afii57461' => 0                        , # 0x304, 0o1404, 772
    'afii63167' => 0                        , # 0x305, 0o1405, 773
    'afii57459' => 0                        , # 0x306, 0o1406, 774
    'afii57543' => 0                        , # 0x307, 0o1407, 775
    'afii57534' => 0                        , # 0x308, 0o1410, 776
    'afii57494' => 0                        , # 0x309, 0o1411, 777
    'afii62843' => 0                        , # 0x30A, 0o1412, 778
    'afii62844' => 0                        , # 0x30B, 0o1413, 779
    'afii62845' => 0                        , # 0x30C, 0o1414, 780
    'afii64240' => 0                        , # 0x30D, 0o1415, 781
    'afii64241' => 0                        , # 0x30E, 0o1416, 782
    'afii63954' => 0                        , # 0x30F, 0o1417, 783
    'afii57382' => 0                        , # 0x310, 0o1420, 784
    'afii64242' => 0                        , # 0x311, 0o1421, 785
    'afii62881' => 0                        , # 0x312, 0o1422, 786
    'afii57504' => 0                        , # 0x313, 0o1423, 787
    'afii57369' => 0                        , # 0x314, 0o1424, 788
    'afii57370' => 0                        , # 0x315, 0o1425, 789
    'afii57371' => 0                        , # 0x316, 0o1426, 790
    'afii57372' => 0                        , # 0x317, 0o1427, 791
    'afii57373' => 0                        , # 0x318, 0o1430, 792
    'afii57374' => 0                        , # 0x319, 0o1431, 793
    'afii57375' => 0                        , # 0x31A, 0o1432, 794
    'afii57391' => 0                        , # 0x31B, 0o1433, 795
    'afii57471' => 0                        , # 0x31C, 0o1434, 796
    'afii57460' => 0                        , # 0x31D, 0o1435, 797
    'afii52258' => 0                        , # 0x31E, 0o1436, 798
    'afii57506' => 0                        , # 0x31F, 0o1437, 799
    'afii62958' => 0                        , # 0x320, 0o1440, 800
    'afii62956' => 0                        , # 0x321, 0o1441, 801
    'afii52957' => 0                        , # 0x322, 0o1442, 802
    'afii57505' => 0                        , # 0x323, 0o1443, 803
    'afii62889' => 0                        , # 0x324, 0o1444, 804
    'afii62887' => 0                        , # 0x325, 0o1445, 805
    'afii62888' => 0                        , # 0x326, 0o1446, 806
    'afii57507' => 0                        , # 0x327, 0o1447, 807
    'afii62961' => 0                        , # 0x328, 0o1450, 808
    'afii62959' => 0                        , # 0x329, 0o1451, 809
    'afii62960' => 0                        , # 0x32A, 0o1452, 810
    'afii57508' => 0                        , # 0x32B, 0o1453, 811
    'afii62962' => 0                        , # 0x32C, 0o1454, 812
    'afii57567' => 0                        , # 0x32D, 0o1455, 813
    'afii62964' => 0                        , # 0x32E, 0o1456, 814
    'afii52305' => 0                        , # 0x32F, 0o1457, 815
    'afii52306' => 0                        , # 0x330, 0o1460, 816
    'afii57509' => 0                        , # 0x331, 0o1461, 817
    'afii62967' => 0                        , # 0x332, 0o1462, 818
    'afii62965' => 0                        , # 0x333, 0o1463, 819
    'afii62966' => 0                        , # 0x334, 0o1464, 820
    'afii57555' => 0                        , # 0x335, 0o1465, 821
    'afii52364' => 0                        , # 0x336, 0o1466, 822
    'afii63753' => 0                        , # 0x337, 0o1467, 823
    'afii63754' => 0                        , # 0x338, 0o1470, 824
    'afii63759' => 0                        , # 0x339, 0o1471, 825
    'afii63763' => 0                        , # 0x33A, 0o1472, 826
    'afii63795' => 0                        , # 0x33B, 0o1473, 827
    'afii62891' => 0                        , # 0x33C, 0o1474, 828
    'afii63808' => 0                        , # 0x33D, 0o1475, 829
    'afii62938' => 0                        , # 0x33E, 0o1476, 830
    'afii63810' => 0                        , # 0x33F, 0o1477, 831
    'afii62942' => 0                        , # 0x340, 0o1500, 832
    'afii62947' => 0                        , # 0x341, 0o1501, 833
    'afii63813' => 0                        , # 0x342, 0o1502, 834
    'afii63823' => 0                        , # 0x343, 0o1503, 835
    'afii63824' => 0                        , # 0x344, 0o1504, 836
    'afii63833' => 0                        , # 0x345, 0o1505, 837
    'afii63844' => 0                        , # 0x346, 0o1506, 838
    'afii62882' => 0                        , # 0x347, 0o1507, 839
    'afii62883' => 0                        , # 0x348, 0o1510, 840
    'afii62884' => 0                        , # 0x349, 0o1511, 841
    'afii62885' => 0                        , # 0x34A, 0o1512, 842
    'afii62886' => 0                        , # 0x34B, 0o1513, 843
    'Odotbelow' => 850                      , # 0x34C, 0o1514, 844
    'odotbelow' => 685                      , # 0x34D, 0o1515, 845
    'Ohookabove' => 850                     , # 0x34E, 0o1516, 846
    'ohookabove' => 685                     , # 0x34F, 0o1517, 847
    'Ocircumflexacute' => 850               , # 0x350, 0o1520, 848
    'ocircumflexacute' => 685               , # 0x351, 0o1521, 849
    'Ocircumflexgrave' => 850               , # 0x352, 0o1522, 850
    'ocircumflexgrave' => 685               , # 0x353, 0o1523, 851
    'Ocircumflexhookabove' => 850           , # 0x354, 0o1524, 852
    'ocircumflexhookabove' => 685           , # 0x355, 0o1525, 853
    'Ocircumflextilde' => 850               , # 0x356, 0o1526, 854
    'ocircumflextilde' => 685               , # 0x357, 0o1527, 855
    'Ocircumflexdotbelow' => 850            , # 0x358, 0o1530, 856
    'ocircumflexdotbelow' => 685            , # 0x359, 0o1531, 857
    'Ohornacute' => 913                     , # 0x35A, 0o1532, 858
    'ohornacute' => 685                     , # 0x35B, 0o1533, 859
    'Ohorngrave' => 913                     , # 0x35C, 0o1534, 860
    'ohorngrave' => 685                     , # 0x35D, 0o1535, 861
    'Ohornhookabove' => 913                 , # 0x35E, 0o1536, 862
    'ohornhookabove' => 685                 , # 0x35F, 0o1537, 863
    'Ohorntilde' => 913                     , # 0x360, 0o1540, 864
    'ohorntilde' => 685                     , # 0x361, 0o1541, 865
    'Ohorndotbelow' => 913                  , # 0x362, 0o1542, 866
    'ohorndotbelow' => 685                  , # 0x363, 0o1543, 867
    'Udotbelow' => 812                      , # 0x364, 0o1544, 868
    'udotbelow' => 712                      , # 0x365, 0o1545, 869
    'Uhookabove' => 812                     , # 0x366, 0o1546, 870
    'uhookabove' => 712                     , # 0x367, 0o1547, 871
    'Uhornacute' => 846                     , # 0x368, 0o1550, 872
    'uhornacute' => 741                     , # 0x369, 0o1551, 873
    'Uhorngrave' => 846                     , # 0x36A, 0o1552, 874
    'uhorngrave' => 741                     , # 0x36B, 0o1553, 875
    'Uhornhookabove' => 846                 , # 0x36C, 0o1554, 876
    'uhornhookabove' => 741                 , # 0x36D, 0o1555, 877
    'Uhorntilde' => 846                     , # 0x36E, 0o1556, 878
    'uhorntilde' => 741                     , # 0x36F, 0o1557, 879
    'Uhorndotbelow' => 846                  , # 0x370, 0o1560, 880
    'uhorndotbelow' => 741                  , # 0x371, 0o1561, 881
    'glyph882' => 736                       , # 0x372, 0o1562, 882
    'glyph883' => 650                       , # 0x373, 0o1563, 883
    'Ydotbelow' => 736                      , # 0x374, 0o1564, 884
    'ydotbelow' => 650                      , # 0x375, 0o1565, 885
    'Yhookabove' => 736                     , # 0x376, 0o1566, 886
    'yhookabove' => 650                     , # 0x377, 0o1567, 887
    'Ytilde' => 736                         , # 0x378, 0o1570, 888
    'ytilde' => 650                         , # 0x379, 0o1571, 889
    'dong' => 699                           , # 0x37A, 0o1572, 890
    'tildecomb' => 0                        , # 0x37B, 0o1573, 891
    'currency' => 710                       , # 0x37C, 0o1574, 892
  },
};

1;
