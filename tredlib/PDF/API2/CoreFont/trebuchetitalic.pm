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

$fonts->{'trebuchetitalic'} = {
  'apiname' => 'Tr4',
  'fontname' => 'TrebuchetMS,Italic',
  'type' => 'TrueType',
  'ascender' => 938,
  'capheight' => 715,
  'descender' => -222,
  'italicangle' => -10,
  'underlineposition' => -261,
  'underlinethickness' => 127,
  'xheight' => 522,
  'flags' => 104,
  'isfixedpitch' => 0,
  'issymbol' => 0,
  'fontbbox' => [ -109, -257, 1107, 945 ],
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
    'nonbreakingspace'                      , # 0xA0, 0o240, 160
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
    'sfthyphen'                             , # 0xAD, 0o255, 173
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
    '.notdef' => 500                        , # 0x00, 0o000, 0
    'space' => 301                          , # 0x03, 0o003, 3
    'exclam' => 367                         , # 0x04, 0o004, 4
    'quotedbl' => 324                       , # 0x05, 0o005, 5
    'numbersign' => 524                     , # 0x06, 0o006, 6
    'dollar' => 480                         , # 0x07, 0o007, 7
    'percent' => 600                        , # 0x08, 0o010, 8
    'ampersand' => 706                      , # 0x09, 0o011, 9
    'quotesingle' => 159                    , # 0x0A, 0o012, 10
    'parenleft' => 367                      , # 0x0B, 0o013, 11
    'parenright' => 367                     , # 0x0C, 0o014, 12
    'asterisk' => 367                       , # 0x0D, 0o015, 13
    'plus' => 524                           , # 0x0E, 0o016, 14
    'comma' => 367                          , # 0x0F, 0o017, 15
    'hyphen' => 367                         , # 0x10, 0o020, 16
    'period' => 367                         , # 0x11, 0o021, 17
    'slash' => 524                          , # 0x12, 0o022, 18
    'zero' => 524                           , # 0x13, 0o023, 19
    'one' => 524                            , # 0x14, 0o024, 20
    'two' => 524                            , # 0x15, 0o025, 21
    'three' => 524                          , # 0x16, 0o026, 22
    'four' => 524                           , # 0x17, 0o027, 23
    'five' => 524                           , # 0x18, 0o030, 24
    'six' => 524                            , # 0x19, 0o031, 25
    'seven' => 524                          , # 0x1A, 0o032, 26
    'eight' => 524                          , # 0x1B, 0o033, 27
    'nine' => 524                           , # 0x1C, 0o034, 28
    'colon' => 367                          , # 0x1D, 0o035, 29
    'semicolon' => 367                      , # 0x1E, 0o036, 30
    'less' => 524                           , # 0x1F, 0o037, 31
    'equal' => 524                          , # 0x20, 0o040, 32
    'greater' => 524                        , # 0x21, 0o041, 33
    'question' => 367                       , # 0x22, 0o042, 34
    'at' => 770                             , # 0x23, 0o043, 35
    'A' => 610                              , # 0x24, 0o044, 36
    'B' => 565                              , # 0x25, 0o045, 37
    'C' => 598                              , # 0x26, 0o046, 38
    'D' => 613                              , # 0x27, 0o047, 39
    'E' => 535                              , # 0x28, 0o050, 40
    'F' => 524                              , # 0x29, 0o051, 41
    'G' => 676                              , # 0x2A, 0o052, 42
    'H' => 654                              , # 0x2B, 0o053, 43
    'I' => 278                              , # 0x2C, 0o054, 44
    'J' => 476                              , # 0x2D, 0o055, 45
    'K' => 575                              , # 0x2E, 0o056, 46
    'L' => 506                              , # 0x2F, 0o057, 47
    'M' => 761                              , # 0x30, 0o060, 48
    'N' => 638                              , # 0x31, 0o061, 49
    'O' => 673                              , # 0x32, 0o062, 50
    'P' => 543                              , # 0x33, 0o063, 51
    'Q' => 673                              , # 0x34, 0o064, 52
    'R' => 582                              , # 0x35, 0o065, 53
    'S' => 480                              , # 0x36, 0o066, 54
    'T' => 580                              , # 0x37, 0o067, 55
    'U' => 648                              , # 0x38, 0o070, 56
    'V' => 587                              , # 0x39, 0o071, 57
    'W' => 852                              , # 0x3A, 0o072, 58
    'X' => 556                              , # 0x3B, 0o073, 59
    'Y' => 570                              , # 0x3C, 0o074, 60
    'Z' => 550                              , # 0x3D, 0o075, 61
    'bracketleft' => 367                    , # 0x3E, 0o076, 62
    'backslash' => 355                      , # 0x3F, 0o077, 63
    'bracketright' => 367                   , # 0x40, 0o100, 64
    'asciicircum' => 524                    , # 0x41, 0o101, 65
    'underscore' => 524                     , # 0x42, 0o102, 66
    'grave' => 524                          , # 0x43, 0o103, 67
    'a' => 525                              , # 0x44, 0o104, 68
    'b' => 557                              , # 0x45, 0o105, 69
    'c' => 459                              , # 0x46, 0o106, 70
    'd' => 557                              , # 0x47, 0o107, 71
    'e' => 537                              , # 0x48, 0o110, 72
    'f' => 401                              , # 0x49, 0o111, 73
    'g' => 501                              , # 0x4A, 0o112, 74
    'h' => 557                              , # 0x4B, 0o113, 75
    'i' => 306                              , # 0x4C, 0o114, 76
    'j' => 366                              , # 0x4D, 0o115, 77
    'k' => 504                              , # 0x4E, 0o116, 78
    'l' => 320                              , # 0x4F, 0o117, 79
    'm' => 830                              , # 0x50, 0o120, 80
    'n' => 546                              , # 0x51, 0o121, 81
    'o' => 536                              , # 0x52, 0o122, 82
    'p' => 557                              , # 0x53, 0o123, 83
    'q' => 557                              , # 0x54, 0o124, 84
    'r' => 416                              , # 0x55, 0o125, 85
    's' => 404                              , # 0x56, 0o126, 86
    't' => 419                              , # 0x57, 0o127, 87
    'u' => 556                              , # 0x58, 0o130, 88
    'v' => 489                              , # 0x59, 0o131, 89
    'w' => 744                              , # 0x5A, 0o132, 90
    'x' => 500                              , # 0x5B, 0o133, 91
    'y' => 493                              , # 0x5C, 0o134, 92
    'z' => 474                              , # 0x5D, 0o135, 93
    'braceleft' => 367                      , # 0x5E, 0o136, 94
    'bar' => 524                            , # 0x5F, 0o137, 95
    'braceright' => 367                     , # 0x60, 0o140, 96
    'asciitilde' => 524                     , # 0x61, 0o141, 97
    'Adieresis' => 610                      , # 0x62, 0o142, 98
    'Aring' => 610                          , # 0x63, 0o143, 99
    'Ccedilla' => 598                       , # 0x64, 0o144, 100
    'Eacute' => 535                         , # 0x65, 0o145, 101
    'Ntilde' => 638                         , # 0x66, 0o146, 102
    'Odieresis' => 673                      , # 0x67, 0o147, 103
    'Udieresis' => 648                      , # 0x68, 0o150, 104
    'aacute' => 525                         , # 0x69, 0o151, 105
    'agrave' => 525                         , # 0x6A, 0o152, 106
    'acircumflex' => 525                    , # 0x6B, 0o153, 107
    'adieresis' => 525                      , # 0x6C, 0o154, 108
    'atilde' => 525                         , # 0x6D, 0o155, 109
    'aring' => 525                          , # 0x6E, 0o156, 110
    'ccedilla' => 459                       , # 0x6F, 0o157, 111
    'eacute' => 537                         , # 0x70, 0o160, 112
    'egrave' => 537                         , # 0x71, 0o161, 113
    'ecircumflex' => 537                    , # 0x72, 0o162, 114
    'edieresis' => 537                      , # 0x73, 0o163, 115
    'iacute' => 306                         , # 0x74, 0o164, 116
    'igrave' => 306                         , # 0x75, 0o165, 117
    'icircumflex' => 306                    , # 0x76, 0o166, 118
    'idieresis' => 306                      , # 0x77, 0o167, 119
    'ntilde' => 546                         , # 0x78, 0o170, 120
    'oacute' => 536                         , # 0x79, 0o171, 121
    'ograve' => 536                         , # 0x7A, 0o172, 122
    'ocircumflex' => 536                    , # 0x7B, 0o173, 123
    'odieresis' => 536                      , # 0x7C, 0o174, 124
    'otilde' => 536                         , # 0x7D, 0o175, 125
    'uacute' => 556                         , # 0x7E, 0o176, 126
    'ugrave' => 556                         , # 0x7F, 0o177, 127
    'ucircumflex' => 556                    , # 0x80, 0o200, 128
    'udieresis' => 556                      , # 0x81, 0o201, 129
    'dagger' => 458                         , # 0x82, 0o202, 130
    'degree' => 524                         , # 0x83, 0o203, 131
    'cent' => 524                           , # 0x84, 0o204, 132
    'sterling' => 529                       , # 0x85, 0o205, 133
    'section' => 453                        , # 0x86, 0o206, 134
    'bullet' => 524                         , # 0x87, 0o207, 135
    'paragraph' => 598                      , # 0x88, 0o210, 136
    'germandbls' => 546                     , # 0x89, 0o211, 137
    'registered' => 712                     , # 0x8A, 0o212, 138
    'copyright' => 712                      , # 0x8B, 0o213, 139
    'trademark' => 634                      , # 0x8C, 0o214, 140
    'acute' => 524                          , # 0x8D, 0o215, 141
    'dieresis' => 524                       , # 0x8E, 0o216, 142
    'notequal' => 524                       , # 0x8F, 0o217, 143
    'AE' => 866                             , # 0x90, 0o220, 144
    'Oslash' => 673                         , # 0x91, 0o221, 145
    'infinity' => 524                       , # 0x92, 0o222, 146
    'plusminus' => 524                      , # 0x93, 0o223, 147
    'lessequal' => 524                      , # 0x94, 0o224, 148
    'greaterequal' => 524                   , # 0x95, 0o225, 149
    'yen' => 556                            , # 0x96, 0o226, 150
    'mu' => 556                             , # 0x97, 0o227, 151
    'partialdiff' => 549                    , # 0x98, 0o230, 152
    'summation' => 524                      , # 0x99, 0o231, 153
    'product' => 552                        , # 0x9A, 0o232, 154
    'pi' => 601                             , # 0x9B, 0o233, 155
    'integral' => 524                       , # 0x9C, 0o234, 156
    'ordfeminine' => 452                    , # 0x9D, 0o235, 157
    'ordmasculine' => 458                   , # 0x9E, 0o236, 158
    'Omega' => 668                          , # 0x9F, 0o237, 159
    'ae' => 844                             , # 0xA0, 0o240, 160
    'oslash' => 536                         , # 0xA1, 0o241, 161
    'questiondown' => 367                   , # 0xA2, 0o242, 162
    'exclamdown' => 367                     , # 0xA3, 0o243, 163
    'logicalnot' => 524                     , # 0xA4, 0o244, 164
    'radical' => 524                        , # 0xA5, 0o245, 165
    'florin' => 401                         , # 0xA6, 0o246, 166
    'approxequal' => 524                    , # 0xA7, 0o247, 167
    'Delta' => 584                          , # 0xA8, 0o250, 168
    'guillemotleft' => 524                  , # 0xA9, 0o251, 169
    'guillemotright' => 524                 , # 0xAA, 0o252, 170
    'ellipsis' => 734                       , # 0xAB, 0o253, 171
    'nonbreakingspace' => 301               , # 0xAC, 0o254, 172
    'Agrave' => 610                         , # 0xAD, 0o255, 173
    'Atilde' => 610                         , # 0xAE, 0o256, 174
    'Otilde' => 673                         , # 0xAF, 0o257, 175
    'OE' => 993                             , # 0xB0, 0o260, 176
    'oe' => 891                             , # 0xB1, 0o261, 177
    'endash' => 367                         , # 0xB2, 0o262, 178
    'emdash' => 734                         , # 0xB3, 0o263, 179
    'quotedblleft' => 524                   , # 0xB4, 0o264, 180
    'quotedblright' => 524                  , # 0xB5, 0o265, 181
    'quoteleft' => 367                      , # 0xB6, 0o266, 182
    'quoteright' => 367                     , # 0xB7, 0o267, 183
    'divide' => 524                         , # 0xB8, 0o270, 184
    'lozenge' => 494                        , # 0xB9, 0o271, 185
    'ydieresis' => 493                      , # 0xBA, 0o272, 186
    'Ydieresis' => 570                      , # 0xBB, 0o273, 187
    'fraction' => 528                       , # 0xBC, 0o274, 188
    'Euro' => 524                           , # 0xBD, 0o275, 189
    'guilsinglleft' => 367                  , # 0xBE, 0o276, 190
    'guilsinglright' => 367                 , # 0xBF, 0o277, 191
    'fi' => 636                             , # 0xC0, 0o300, 192
    'fl' => 672                             , # 0xC1, 0o301, 193
    'daggerdbl' => 458                      , # 0xC2, 0o302, 194
    'periodcentered' => 367                 , # 0xC3, 0o303, 195
    'quotesinglbase' => 367                 , # 0xC4, 0o304, 196
    'quotedblbase' => 524                   , # 0xC5, 0o305, 197
    'perthousand' => 912                    , # 0xC6, 0o306, 198
    'Acircumflex' => 610                    , # 0xC7, 0o307, 199
    'Ecircumflex' => 535                    , # 0xC8, 0o310, 200
    'Aacute' => 610                         , # 0xC9, 0o311, 201
    'Edieresis' => 535                      , # 0xCA, 0o312, 202
    'Egrave' => 535                         , # 0xCB, 0o313, 203
    'Iacute' => 278                         , # 0xCC, 0o314, 204
    'Icircumflex' => 278                    , # 0xCD, 0o315, 205
    'Idieresis' => 278                      , # 0xCE, 0o316, 206
    'Igrave' => 278                         , # 0xCF, 0o317, 207
    'Oacute' => 673                         , # 0xD0, 0o320, 208
    'Ocircumflex' => 673                    , # 0xD1, 0o321, 209
    'apple' => 500                          , # 0xD2, 0o322, 210
    'Ograve' => 673                         , # 0xD3, 0o323, 211
    'Uacute' => 648                         , # 0xD4, 0o324, 212
    'Ucircumflex' => 648                    , # 0xD5, 0o325, 213
    'Ugrave' => 648                         , # 0xD6, 0o326, 214
    'dotlessi' => 306                       , # 0xD7, 0o327, 215
    'circumflex' => 524                     , # 0xD8, 0o330, 216
    'tilde' => 524                          , # 0xD9, 0o331, 217
    'macron' => 524                         , # 0xDA, 0o332, 218
    'breve' => 524                          , # 0xDB, 0o333, 219
    'dotaccent' => 524                      , # 0xDC, 0o334, 220
    'ring' => 524                           , # 0xDD, 0o335, 221
    'cedilla' => 524                        , # 0xDE, 0o336, 222
    'hungarumlaut' => 524                   , # 0xDF, 0o337, 223
    'ogonek' => 524                         , # 0xE0, 0o340, 224
    'caron' => 524                          , # 0xE1, 0o341, 225
    'Lslash' => 506                         , # 0xE2, 0o342, 226
    'lslash' => 294                         , # 0xE3, 0o343, 227
    'Scaron' => 480                         , # 0xE4, 0o344, 228
    'scaron' => 404                         , # 0xE5, 0o345, 229
    'Zcaron' => 550                         , # 0xE6, 0o346, 230
    'zcaron' => 474                         , # 0xE7, 0o347, 231
    'brokenbar' => 524                      , # 0xE8, 0o350, 232
    'Eth' => 613                            , # 0xE9, 0o351, 233
    'eth' => 549                            , # 0xEA, 0o352, 234
    'Yacute' => 570                         , # 0xEB, 0o353, 235
    'Thorn' => 543                          , # 0xEC, 0o354, 236
    'thorn' => 557                          , # 0xED, 0o355, 237
    'minus' => 524                          , # 0xEE, 0o356, 238
    'onesuperior' => 451                    , # 0xEF, 0o357, 239
    'twosuperior' => 451                    , # 0xF0, 0o360, 240
    'threesuperior' => 451                  , # 0xF1, 0o361, 241
    'onehalf' => 814                        , # 0xF2, 0o362, 242
    'onequarter' => 814                     , # 0xF3, 0o363, 243
    'threequarters' => 814                  , # 0xF4, 0o364, 244
    'mu1' => 556                            , # 0xF5, 0o365, 245
    'Ohm' => 668                            , # 0xF6, 0o366, 246
    'yacute' => 493                         , # 0xF8, 0o370, 248
    'multiply' => 524                       , # 0xF9, 0o371, 249
    'sfthyphen' => 367                      , # 0xFA, 0o372, 250
    'dotlessj' => 366                       , # 0xFB, 0o373, 251
    'f007' => 367                           , # 0xFC, 0o374, 252
    'franc' => 941                          , # 0xFD, 0o375, 253
    'Gbreve' => 676                         , # 0xFE, 0o376, 254
    'gbreve' => 501                         , # 0xFF, 0o377, 255
    'Idotaccent' => 278                     , # 0x100, 0o400, 256
    'Scedilla' => 480                       , # 0x101, 0o401, 257
    'scedilla' => 404                       , # 0x102, 0o402, 258
    'Cacute' => 598                         , # 0x103, 0o403, 259
    'cacute' => 459                         , # 0x104, 0o404, 260
    'Ccaron' => 598                         , # 0x105, 0o405, 261
    'ccaron' => 459                         , # 0x106, 0o406, 262
    'dcroat' => 557                         , # 0x107, 0o407, 263
    'overscore' => 524                      , # 0x108, 0o410, 264
    'commaaccenthigh' => 367                , # 0x109, 0o411, 265
    'middot' => 367                         , # 0x10A, 0o412, 266
    'Abreve' => 610                         , # 0x10B, 0o413, 267
    'abreve' => 525                         , # 0x10C, 0o414, 268
    'Aogonek' => 610                        , # 0x10D, 0o415, 269
    'aogonek' => 525                        , # 0x10E, 0o416, 270
    'Dcaron' => 613                         , # 0x10F, 0o417, 271
    'dcaron' => 691                         , # 0x110, 0o420, 272
    'Dslash' => 613                         , # 0x111, 0o421, 273
    'Eogonek' => 535                        , # 0x112, 0o422, 274
    'eogonek' => 537                        , # 0x113, 0o423, 275
    'Ecaron' => 535                         , # 0x114, 0o424, 276
    'ecaron' => 537                         , # 0x115, 0o425, 277
    'Lacute' => 506                         , # 0x116, 0o426, 278
    'lacute' => 320                         , # 0x117, 0o427, 279
    'Lcaron' => 506                         , # 0x118, 0o430, 280
    'lcaron' => 320                         , # 0x119, 0o431, 281
    'Ldot' => 506                           , # 0x11A, 0o432, 282
    'ldot' => 506                           , # 0x11B, 0o433, 283
    'Nacute' => 638                         , # 0x11C, 0o434, 284
    'nacute' => 546                         , # 0x11D, 0o435, 285
    'Ncaron' => 638                         , # 0x11E, 0o436, 286
    'ncaron' => 546                         , # 0x11F, 0o437, 287
    'Odblacute' => 673                      , # 0x120, 0o440, 288
    'odblacute' => 536                      , # 0x121, 0o441, 289
    'Racute' => 582                         , # 0x122, 0o442, 290
    'racute' => 416                         , # 0x123, 0o443, 291
    'Rcaron' => 582                         , # 0x124, 0o444, 292
    'rcaron' => 416                         , # 0x125, 0o445, 293
    'Sacute' => 480                         , # 0x126, 0o446, 294
    'sacute' => 404                         , # 0x127, 0o447, 295
    'Tcedilla' => 580                       , # 0x128, 0o450, 296
    'tcedilla' => 419                       , # 0x129, 0o451, 297
    'Tcaron' => 580                         , # 0x12A, 0o452, 298
    'tcaron' => 496                         , # 0x12B, 0o453, 299
    'Uring' => 648                          , # 0x12C, 0o454, 300
    'uring' => 556                          , # 0x12D, 0o455, 301
    'Udblacute' => 648                      , # 0x12E, 0o456, 302
    'udblacute' => 556                      , # 0x12F, 0o457, 303
    'Zacute' => 550                         , # 0x130, 0o460, 304
    'zacute' => 474                         , # 0x131, 0o461, 305
    'Zdot' => 550                           , # 0x132, 0o462, 306
    'zdot' => 474                           , # 0x133, 0o463, 307
    'foursuperior' => 451                   , # 0x134, 0o464, 308
    'currency' => 524                       , # 0x135, 0o465, 309
    'questiongreek' => 367                  , # 0x136, 0o466, 310
    'tonos' => 523                          , # 0x137, 0o467, 311
    'dieresistonos' => 523                  , # 0x138, 0o470, 312
    'Alphatonos' => 610                     , # 0x139, 0o471, 313
    'anoteleia' => 367                      , # 0x13A, 0o472, 314
    'Epsilontonos' => 645                   , # 0x13B, 0o473, 315
    'Etatonos' => 753                       , # 0x13C, 0o474, 316
    'Iotatonos' => 375                      , # 0x13D, 0o475, 317
    'Omicrontonos' => 733                   , # 0x13E, 0o476, 318
    'Upsilontonos' => 713                   , # 0x13F, 0o477, 319
    'Omegatonos' => 758                     , # 0x140, 0o500, 320
    'iotadieresistonos' => 269              , # 0x141, 0o501, 321
    'Alpha' => 610                          , # 0x142, 0o502, 322
    'Beta' => 565                           , # 0x143, 0o503, 323
    'Gamma' => 515                          , # 0x144, 0o504, 324
    'Epsilon' => 536                        , # 0x145, 0o505, 325
    'Zeta' => 549                           , # 0x146, 0o506, 326
    'Eta' => 653                            , # 0x147, 0o507, 327
    'Theta' => 690                          , # 0x148, 0o510, 328
    'Iota' => 277                           , # 0x149, 0o511, 329
    'Kappa' => 576                          , # 0x14A, 0o512, 330
    'Lambda' => 587                         , # 0x14B, 0o513, 331
    'Mu' => 761                             , # 0x14C, 0o514, 332
    'Nu' => 638                             , # 0x14D, 0o515, 333
    'Xi' => 602                             , # 0x14E, 0o516, 334
    'Omicron' => 673                        , # 0x14F, 0o517, 335
    'Pi' => 636                             , # 0x150, 0o520, 336
    'Rho' => 542                            , # 0x151, 0o521, 337
    'Sigma' => 541                          , # 0x152, 0o522, 338
    'Tau' => 581                            , # 0x153, 0o523, 339
    'Upsilon' => 569                        , # 0x154, 0o524, 340
    'Phi' => 766                            , # 0x155, 0o525, 341
    'Chi' => 557                            , # 0x156, 0o526, 342
    'Psi' => 758                            , # 0x157, 0o527, 343
    'Iotadieresis' => 277                   , # 0x158, 0o530, 344
    'Upsilondieresis' => 569                , # 0x159, 0o531, 345
    'alphatonos' => 546                     , # 0x15A, 0o532, 346
    'epsilontonos' => 464                   , # 0x15B, 0o533, 347
    'etatonos' => 553                       , # 0x15C, 0o534, 348
    'iotatonos' => 269                      , # 0x15D, 0o535, 349
    'upsilondieresistonos' => 549           , # 0x15E, 0o536, 350
    'alpha' => 546                          , # 0x15F, 0o537, 351
    'beta' => 563                           , # 0x160, 0o540, 352
    'gamma' => 525                          , # 0x161, 0o541, 353
    'delta' => 546                          , # 0x162, 0o542, 354
    'epsilon' => 464                        , # 0x163, 0o543, 355
    'zeta' => 440                           , # 0x164, 0o544, 356
    'eta' => 553                            , # 0x165, 0o545, 357
    'theta' => 565                          , # 0x166, 0o546, 358
    'iota' => 269                           , # 0x167, 0o547, 359
    'kappa' => 537                          , # 0x168, 0o550, 360
    'lambda' => 527                         , # 0x169, 0o551, 361
    'nu' => 500                             , # 0x16A, 0o552, 362
    'xi' => 454                             , # 0x16B, 0o553, 363
    'omicron' => 543                        , # 0x16C, 0o554, 364
    'rho' => 577                            , # 0x16D, 0o555, 365
    'sigma1' => 472                         , # 0x16E, 0o556, 366
    'sigma' => 575                          , # 0x16F, 0o557, 367
    'tau' => 432                            , # 0x170, 0o560, 368
    'upsilon' => 549                        , # 0x171, 0o561, 369
    'phi' => 701                            , # 0x172, 0o562, 370
    'chi' => 514                            , # 0x173, 0o563, 371
    'psi' => 740                            , # 0x174, 0o564, 372
    'omega' => 762                          , # 0x175, 0o565, 373
    'iotadieresis' => 269                   , # 0x176, 0o566, 374
    'upsilondieresis' => 549                , # 0x177, 0o567, 375
    'omicrontonos' => 543                   , # 0x178, 0o570, 376
    'upsilontonos' => 549                   , # 0x179, 0o571, 377
    'omegatonos' => 762                     , # 0x17A, 0o572, 378
    'afii10023' => 546                      , # 0x17B, 0o573, 379
    'afii10051' => 721                      , # 0x17C, 0o574, 380
    'afii10052' => 519                      , # 0x17D, 0o575, 381
    'afii10053' => 565                      , # 0x17E, 0o576, 382
    'afii10054' => 477                      , # 0x17F, 0o577, 383
    'afii10055' => 277                      , # 0x180, 0o600, 384
    'afii10056' => 277                      , # 0x181, 0o601, 385
    'afii10057' => 466                      , # 0x182, 0o602, 386
    'afii10058' => 980                      , # 0x183, 0o603, 387
    'afii10059' => 915                      , # 0x184, 0o604, 388
    'afii10060' => 745                      , # 0x185, 0o605, 389
    'afii10061' => 611                      , # 0x186, 0o606, 390
    'afii10062' => 580                      , # 0x187, 0o607, 391
    'afii10145' => 638                      , # 0x188, 0o610, 392
    'afii10017' => 610                      , # 0x189, 0o611, 393
    'afii10018' => 569                      , # 0x18A, 0o612, 394
    'afii10019' => 569                      , # 0x18B, 0o613, 395
    'afii10020' => 519                      , # 0x18C, 0o614, 396
    'afii10021' => 684                      , # 0x18D, 0o615, 397
    'afii10022' => 546                      , # 0x18E, 0o616, 398
    'afii10024' => 888                      , # 0x18F, 0o617, 399
    'afii10025' => 518                      , # 0x190, 0o620, 400
    'afii10026' => 670                      , # 0x191, 0o621, 401
    'afii10027' => 670                      , # 0x192, 0o622, 402
    'afii10028' => 608                      , # 0x193, 0o623, 403
    'afii10029' => 674                      , # 0x194, 0o624, 404
    'afii10030' => 751                      , # 0x195, 0o625, 405
    'afii10031' => 653                      , # 0x196, 0o626, 406
    'afii10032' => 674                      , # 0x197, 0o627, 407
    'afii10033' => 636                      , # 0x198, 0o630, 408
    'afii10034' => 561                      , # 0x199, 0o631, 409
    'afii10035' => 563                      , # 0x19A, 0o632, 410
    'afii10036' => 619                      , # 0x19B, 0o633, 411
    'afii10037' => 580                      , # 0x19C, 0o634, 412
    'afii10038' => 749                      , # 0x19D, 0o635, 413
    'afii10039' => 575                      , # 0x19E, 0o636, 414
    'afii10040' => 645                      , # 0x19F, 0o637, 415
    'afii10041' => 596                      , # 0x1A0, 0o640, 416
    'afii10042' => 891                      , # 0x1A1, 0o641, 417
    'afii10043' => 908                      , # 0x1A2, 0o642, 418
    'afii10044' => 742                      , # 0x1A3, 0o643, 419
    'afii10045' => 772                      , # 0x1A4, 0o644, 420
    'afii10046' => 576                      , # 0x1A5, 0o645, 421
    'afii10047' => 567                      , # 0x1A6, 0o646, 422
    'afii10048' => 890                      , # 0x1A7, 0o647, 423
    'afii10049' => 598                      , # 0x1A8, 0o650, 424
    'afii10065' => 539                      , # 0x1A9, 0o651, 425
    'afii10066' => 578                      , # 0x1AA, 0o652, 426
    'afii10067' => 539                      , # 0x1AB, 0o653, 427
    'afii10068' => 454                      , # 0x1AC, 0o654, 428
    'afii10069' => 584                      , # 0x1AD, 0o655, 429
    'afii10070' => 513                      , # 0x1AE, 0o656, 430
    'afii10072' => 736                      , # 0x1AF, 0o657, 431
    'afii10073' => 452                      , # 0x1B0, 0o660, 432
    'afii10074' => 568                      , # 0x1B1, 0o661, 433
    'afii10075' => 568                      , # 0x1B2, 0o662, 434
    'afii10076' => 522                      , # 0x1B3, 0o663, 435
    'afii10077' => 581                      , # 0x1B4, 0o664, 436
    'afii10078' => 735                      , # 0x1B5, 0o665, 437
    'afii10079' => 563                      , # 0x1B6, 0o666, 438
    'afii10080' => 541                      , # 0x1B7, 0o667, 439
    'afii10081' => 555                      , # 0x1B8, 0o670, 440
    'afii10082' => 559                      , # 0x1B9, 0o671, 441
    'afii10083' => 456                      , # 0x1BA, 0o672, 442
    'afii10084' => 840                      , # 0x1BB, 0o673, 443
    'afii10085' => 504                      , # 0x1BC, 0o674, 444
    'afii10086' => 751                      , # 0x1BD, 0o675, 445
    'afii10087' => 514                      , # 0x1BE, 0o676, 446
    'afii10088' => 589                      , # 0x1BF, 0o677, 447
    'afii10089' => 544                      , # 0x1C0, 0o700, 448
    'afii10090' => 834                      , # 0x1C1, 0o701, 449
    'afii10091' => 863                      , # 0x1C2, 0o702, 450
    'afii10092' => 645                      , # 0x1C3, 0o703, 451
    'afii10093' => 736                      , # 0x1C4, 0o704, 452
    'afii10094' => 536                      , # 0x1C5, 0o705, 453
    'afii10095' => 458                      , # 0x1C6, 0o706, 454
    'afii10096' => 732                      , # 0x1C7, 0o707, 455
    'afii10097' => 527                      , # 0x1C8, 0o710, 456
    'afii10071' => 513                      , # 0x1C9, 0o711, 457
    'afii10099' => 550                      , # 0x1CA, 0o712, 458
    'afii10100' => 454                      , # 0x1CB, 0o713, 459
    'afii10101' => 456                      , # 0x1CC, 0o714, 460
    'afii10102' => 412                      , # 0x1CD, 0o715, 461
    'afii10103' => 290                      , # 0x1CE, 0o716, 462
    'afii10104' => 290                      , # 0x1CF, 0o717, 463
    'afii10105' => 300                      , # 0x1D0, 0o720, 464
    'afii10106' => 865                      , # 0x1D1, 0o721, 465
    'afii10107' => 806                      , # 0x1D2, 0o722, 466
    'afii10108' => 550                      , # 0x1D3, 0o723, 467
    'afii10109' => 522                      , # 0x1D4, 0o724, 468
    'afii10110' => 504                      , # 0x1D5, 0o725, 469
    'afii10193' => 566                      , # 0x1D6, 0o726, 470
    'afii10050' => 519                      , # 0x1D7, 0o727, 471
    'afii10098' => 438                      , # 0x1D8, 0o730, 472
    'Amacron' => 610                        , # 0x1D9, 0o731, 473
    'amacron' => 525                        , # 0x1DA, 0o732, 474
    'Ccircumflex' => 598                    , # 0x1DB, 0o733, 475
    'ccircumflex' => 459                    , # 0x1DC, 0o734, 476
    'Cdot' => 598                           , # 0x1DD, 0o735, 477
    'cdot' => 459                           , # 0x1DE, 0o736, 478
    'Emacron' => 535                        , # 0x1DF, 0o737, 479
    'emacron' => 537                        , # 0x1E0, 0o740, 480
    'Ebreve' => 535                         , # 0x1E1, 0o741, 481
    'ebreve' => 537                         , # 0x1E2, 0o742, 482
    'Edot' => 535                           , # 0x1E3, 0o743, 483
    'edot' => 537                           , # 0x1E4, 0o744, 484
    'Gcircumflex' => 676                    , # 0x1E5, 0o745, 485
    'gcircumflex' => 501                    , # 0x1E6, 0o746, 486
    'Gdot' => 676                           , # 0x1E7, 0o747, 487
    'gdot' => 501                           , # 0x1E8, 0o750, 488
    'Gcedilla' => 676                       , # 0x1E9, 0o751, 489
    'gcedilla' => 501                       , # 0x1EA, 0o752, 490
    'Hcircumflex' => 654                    , # 0x1EB, 0o753, 491
    'hcircumflex' => 557                    , # 0x1EC, 0o754, 492
    'Hbar' => 682                           , # 0x1ED, 0o755, 493
    'hbar' => 553                           , # 0x1EE, 0o756, 494
    'Itilde' => 278                         , # 0x1EF, 0o757, 495
    'itilde' => 306                         , # 0x1F0, 0o760, 496
    'Imacron' => 278                        , # 0x1F1, 0o761, 497
    'imacron' => 306                        , # 0x1F2, 0o762, 498
    'Ibreve' => 278                         , # 0x1F3, 0o763, 499
    'ibreve' => 306                         , # 0x1F4, 0o764, 500
    'Iogonek' => 278                        , # 0x1F5, 0o765, 501
    'iogonek' => 306                        , # 0x1F6, 0o766, 502
    'IJ' => 727                             , # 0x1F7, 0o767, 503
    'ij' => 585                             , # 0x1F8, 0o770, 504
    'Jcircumflex' => 476                    , # 0x1F9, 0o771, 505
    'jcircumflex' => 366                    , # 0x1FA, 0o772, 506
    'Kcedilla' => 575                       , # 0x1FB, 0o773, 507
    'kcedilla' => 504                       , # 0x1FC, 0o774, 508
    'kgreenlandic' => 537                   , # 0x1FD, 0o775, 509
    'Lcedilla' => 506                       , # 0x1FE, 0o776, 510
    'lcedilla' => 320                       , # 0x1FF, 0o777, 511
    'Ncedilla' => 638                       , # 0x200, 0o1000, 512
    'ncedilla' => 546                       , # 0x201, 0o1001, 513
    'napostrophe' => 604                    , # 0x202, 0o1002, 514
    'Eng' => 651                            , # 0x203, 0o1003, 515
    'eng' => 546                            , # 0x204, 0o1004, 516
    'Omacron' => 673                        , # 0x205, 0o1005, 517
    'omacron' => 536                        , # 0x206, 0o1006, 518
    'Obreve' => 673                         , # 0x207, 0o1007, 519
    'obreve' => 536                         , # 0x208, 0o1010, 520
    'Rcedilla' => 582                       , # 0x209, 0o1011, 521
    'rcedilla' => 416                       , # 0x20A, 0o1012, 522
    'Scircumflex' => 480                    , # 0x20B, 0o1013, 523
    'scircumflex' => 404                    , # 0x20C, 0o1014, 524
    'Tbar' => 580                           , # 0x20D, 0o1015, 525
    'tbar' => 419                           , # 0x20E, 0o1016, 526
    'Utilde' => 648                         , # 0x20F, 0o1017, 527
    'utilde' => 556                         , # 0x210, 0o1020, 528
    'Umacron' => 648                        , # 0x211, 0o1021, 529
    'umacron' => 556                        , # 0x212, 0o1022, 530
    'Ubreve' => 648                         , # 0x213, 0o1023, 531
    'ubreve' => 556                         , # 0x214, 0o1024, 532
    'Uogonek' => 648                        , # 0x215, 0o1025, 533
    'uogonek' => 556                        , # 0x216, 0o1026, 534
    'Wcircumflex' => 852                    , # 0x217, 0o1027, 535
    'wcircumflex' => 744                    , # 0x218, 0o1030, 536
    'Ycircumflex' => 570                    , # 0x219, 0o1031, 537
    'ycircumflex' => 493                    , # 0x21A, 0o1032, 538
    'longs' => 349                          , # 0x21B, 0o1033, 539
    'Aringacute' => 610                     , # 0x21C, 0o1034, 540
    'aringacute' => 525                     , # 0x21D, 0o1035, 541
    'AEacute' => 866                        , # 0x21E, 0o1036, 542
    'aeacute' => 844                        , # 0x21F, 0o1037, 543
    'Oslashacute' => 673                    , # 0x220, 0o1040, 544
    'oslashacute' => 536                    , # 0x221, 0o1041, 545
    'Wgrave' => 852                         , # 0x222, 0o1042, 546
    'wgrave' => 744                         , # 0x223, 0o1043, 547
    'Wacute' => 852                         , # 0x224, 0o1044, 548
    'wacute' => 744                         , # 0x225, 0o1045, 549
    'Wdieresis' => 852                      , # 0x226, 0o1046, 550
    'wdieresis' => 744                      , # 0x227, 0o1047, 551
    'Ygrave' => 570                         , # 0x228, 0o1050, 552
    'ygrave' => 493                         , # 0x229, 0o1051, 553
    'afii00208' => 734                      , # 0x22A, 0o1052, 554
    'underscoredbl' => 523                  , # 0x22B, 0o1053, 555
    'minute' => 159                         , # 0x22C, 0o1054, 556
    'second' => 338                         , # 0x22D, 0o1055, 557
    'exclamdbl' => 609                      , # 0x22E, 0o1056, 558
    'radicalex' => 524                      , # 0x22F, 0o1057, 559
    'nsuperior' => 451                      , # 0x230, 0o1060, 560
    'afii08941' => 529                      , # 0x231, 0o1061, 561
    'peseta' => 1109                        , # 0x232, 0o1062, 562
    'afii61248' => 698                      , # 0x233, 0o1063, 563
    'afii61289' => 524                      , # 0x234, 0o1064, 564
    'afii61352' => 894                      , # 0x235, 0o1065, 565
    'estimated' => 549                      , # 0x236, 0o1066, 566
    'oneeighth' => 814                      , # 0x237, 0o1067, 567
    'threeeighths' => 814                   , # 0x238, 0o1070, 568
    'fiveeighths' => 814                    , # 0x239, 0o1071, 569
    'seveneighths' => 814                   , # 0x23A, 0o1072, 570
    'H22073' => 604                         , # 0x23B, 0o1073, 571
    'H18543' => 354                         , # 0x23C, 0o1074, 572
    'H18551' => 354                         , # 0x23D, 0o1075, 573
    'H18533' => 604                         , # 0x23E, 0o1076, 574
    'openbullet' => 354                     , # 0x23F, 0o1077, 575
    'quotereversed' => 367                  , # 0x240, 0o1100, 576
  },
};

1;
