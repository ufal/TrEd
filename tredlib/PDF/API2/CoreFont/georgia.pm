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

$fonts->{'georgia'} = {
  'apiname' => 'Ge1',
  'fontname' => 'Georgia',
  'type' => 'TrueType',
  'ascender' => 916,
  'capheight' => 692,
  'descender' => -219,
  'italicangle' => 0,
  'underlineposition' => -181,
  'underlinethickness' => 101,
  'xheight' => 481,
  'flags' => 34,
  'isfixedpitch' => 0,
  'issymbol' => 0,
  'fontbbox' => [ -173, -216, 1166, 912 ],
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
    'nonmarkingreturn' => 241               , # 0x02, 0o002, 2
    'space' => 241                          , # 0x03, 0o003, 3
    'exclam' => 331                         , # 0x04, 0o004, 4
    'quotedbl' => 411                       , # 0x05, 0o005, 5
    'numbersign' => 643                     , # 0x06, 0o006, 6
    'dollar' => 609                         , # 0x07, 0o007, 7
    'percent' => 817                        , # 0x08, 0o010, 8
    'ampersand' => 710                      , # 0x09, 0o011, 9
    'quotesingle' => 215                    , # 0x0A, 0o012, 10
    'parenleft' => 375                      , # 0x0B, 0o013, 11
    'parenright' => 375                     , # 0x0C, 0o014, 12
    'asterisk' => 472                       , # 0x0D, 0o015, 13
    'plus' => 643                           , # 0x0E, 0o016, 14
    'comma' => 269                          , # 0x0F, 0o017, 15
    'hyphen' => 374                         , # 0x10, 0o020, 16
    'period' => 269                         , # 0x11, 0o021, 17
    'slash' => 468                          , # 0x12, 0o022, 18
    'zero' => 613                           , # 0x13, 0o023, 19
    'one' => 429                            , # 0x14, 0o024, 20
    'two' => 558                            , # 0x15, 0o025, 21
    'three' => 551                          , # 0x16, 0o026, 22
    'four' => 564                           , # 0x17, 0o027, 23
    'five' => 528                           , # 0x18, 0o030, 24
    'six' => 565                            , # 0x19, 0o031, 25
    'seven' => 502                          , # 0x1A, 0o032, 26
    'eight' => 596                          , # 0x1B, 0o033, 27
    'nine' => 565                           , # 0x1C, 0o034, 28
    'colon' => 312                          , # 0x1D, 0o035, 29
    'semicolon' => 312                      , # 0x1E, 0o036, 30
    'less' => 643                           , # 0x1F, 0o037, 31
    'equal' => 643                          , # 0x20, 0o040, 32
    'greater' => 643                        , # 0x21, 0o041, 33
    'question' => 478                       , # 0x22, 0o042, 34
    'at' => 928                             , # 0x23, 0o043, 35
    'A' => 670                              , # 0x24, 0o044, 36
    'B' => 653                              , # 0x25, 0o045, 37
    'C' => 642                              , # 0x26, 0o046, 38
    'D' => 749                              , # 0x27, 0o047, 39
    'E' => 653                              , # 0x28, 0o050, 40
    'F' => 599                              , # 0x29, 0o051, 41
    'G' => 725                              , # 0x2A, 0o052, 42
    'H' => 814                              , # 0x2B, 0o053, 43
    'I' => 389                              , # 0x2C, 0o054, 44
    'J' => 517                              , # 0x2D, 0o055, 45
    'K' => 694                              , # 0x2E, 0o056, 46
    'L' => 603                              , # 0x2F, 0o057, 47
    'M' => 927                              , # 0x30, 0o060, 48
    'N' => 767                              , # 0x31, 0o061, 49
    'O' => 744                              , # 0x32, 0o062, 50
    'P' => 609                              , # 0x33, 0o063, 51
    'Q' => 744                              , # 0x34, 0o064, 52
    'R' => 701                              , # 0x35, 0o065, 53
    'S' => 561                              , # 0x36, 0o066, 54
    'T' => 618                              , # 0x37, 0o067, 55
    'U' => 756                              , # 0x38, 0o070, 56
    'V' => 666                              , # 0x39, 0o071, 57
    'W' => 975                              , # 0x3A, 0o072, 58
    'X' => 710                              , # 0x3B, 0o073, 59
    'Y' => 615                              , # 0x3C, 0o074, 60
    'Z' => 601                              , # 0x3D, 0o075, 61
    'bracketleft' => 375                    , # 0x3E, 0o076, 62
    'backslash' => 468                      , # 0x3F, 0o077, 63
    'bracketright' => 375                   , # 0x40, 0o100, 64
    'asciicircum' => 643                    , # 0x41, 0o101, 65
    'underscore' => 643                     , # 0x42, 0o102, 66
    'grave' => 500                          , # 0x43, 0o103, 67
    'a' => 503                              , # 0x44, 0o104, 68
    'b' => 560                              , # 0x45, 0o105, 69
    'c' => 454                              , # 0x46, 0o106, 70
    'd' => 574                              , # 0x47, 0o107, 71
    'e' => 483                              , # 0x48, 0o110, 72
    'f' => 325                              , # 0x49, 0o111, 73
    'g' => 509                              , # 0x4A, 0o112, 74
    'h' => 582                              , # 0x4B, 0o113, 75
    'i' => 292                              , # 0x4C, 0o114, 76
    'j' => 291                              , # 0x4D, 0o115, 77
    'k' => 535                              , # 0x4E, 0o116, 78
    'l' => 286                              , # 0x4F, 0o117, 79
    'm' => 880                              , # 0x50, 0o120, 80
    'n' => 590                              , # 0x51, 0o121, 81
    'o' => 539                              , # 0x52, 0o122, 82
    'p' => 571                              , # 0x53, 0o123, 83
    'q' => 559                              , # 0x54, 0o124, 84
    'r' => 409                              , # 0x55, 0o125, 85
    's' => 432                              , # 0x56, 0o126, 86
    't' => 345                              , # 0x57, 0o127, 87
    'u' => 575                              , # 0x58, 0o130, 88
    'v' => 496                              , # 0x59, 0o131, 89
    'w' => 737                              , # 0x5A, 0o132, 90
    'x' => 504                              , # 0x5B, 0o133, 91
    'y' => 492                              , # 0x5C, 0o134, 92
    'z' => 443                              , # 0x5D, 0o135, 93
    'braceleft' => 430                      , # 0x5E, 0o136, 94
    'bar' => 375                            , # 0x5F, 0o137, 95
    'braceright' => 430                     , # 0x60, 0o140, 96
    'asciitilde' => 643                     , # 0x61, 0o141, 97
    'Adieresis' => 670                      , # 0x62, 0o142, 98
    'Aring' => 670                          , # 0x63, 0o143, 99
    'Ccedilla' => 642                       , # 0x64, 0o144, 100
    'Eacute' => 653                         , # 0x65, 0o145, 101
    'Ntilde' => 767                         , # 0x66, 0o146, 102
    'Odieresis' => 744                      , # 0x67, 0o147, 103
    'Udieresis' => 756                      , # 0x68, 0o150, 104
    'aacute' => 503                         , # 0x69, 0o151, 105
    'agrave' => 503                         , # 0x6A, 0o152, 106
    'acircumflex' => 503                    , # 0x6B, 0o153, 107
    'adieresis' => 503                      , # 0x6C, 0o154, 108
    'atilde' => 503                         , # 0x6D, 0o155, 109
    'aring' => 503                          , # 0x6E, 0o156, 110
    'ccedilla' => 454                       , # 0x6F, 0o157, 111
    'eacute' => 483                         , # 0x70, 0o160, 112
    'egrave' => 483                         , # 0x71, 0o161, 113
    'ecircumflex' => 483                    , # 0x72, 0o162, 114
    'edieresis' => 483                      , # 0x73, 0o163, 115
    'iacute' => 292                         , # 0x74, 0o164, 116
    'igrave' => 292                         , # 0x75, 0o165, 117
    'icircumflex' => 292                    , # 0x76, 0o166, 118
    'idieresis' => 292                      , # 0x77, 0o167, 119
    'ntilde' => 590                         , # 0x78, 0o170, 120
    'oacute' => 539                         , # 0x79, 0o171, 121
    'ograve' => 539                         , # 0x7A, 0o172, 122
    'ocircumflex' => 539                    , # 0x7B, 0o173, 123
    'odieresis' => 539                      , # 0x7C, 0o174, 124
    'otilde' => 539                         , # 0x7D, 0o175, 125
    'uacute' => 575                         , # 0x7E, 0o176, 126
    'ugrave' => 575                         , # 0x7F, 0o177, 127
    'ucircumflex' => 575                    , # 0x80, 0o200, 128
    'udieresis' => 575                      , # 0x81, 0o201, 129
    'dagger' => 472                         , # 0x82, 0o202, 130
    'degree' => 419                         , # 0x83, 0o203, 131
    'cent' => 555                           , # 0x84, 0o204, 132
    'sterling' => 622                       , # 0x85, 0o205, 133
    'section' => 500                        , # 0x86, 0o206, 134
    'bullet' => 392                         , # 0x87, 0o207, 135
    'paragraph' => 500                      , # 0x88, 0o210, 136
    'germandbls' => 548                     , # 0x89, 0o211, 137
    'registered' => 941                     , # 0x8A, 0o212, 138
    'copyright' => 941                      , # 0x8B, 0o213, 139
    'trademark' => 942                      , # 0x8C, 0o214, 140
    'acute' => 500                          , # 0x8D, 0o215, 141
    'dieresis' => 500                       , # 0x8E, 0o216, 142
    'notequal' => 643                       , # 0x8F, 0o217, 143
    'AE' => 970                             , # 0x90, 0o220, 144
    'Oslash' => 744                         , # 0x91, 0o221, 145
    'infinity' => 716                       , # 0x92, 0o222, 146
    'plusminus' => 643                      , # 0x93, 0o223, 147
    'lessequal' => 643                      , # 0x94, 0o224, 148
    'greaterequal' => 643                   , # 0x95, 0o225, 149
    'yen' => 614                            , # 0x96, 0o226, 150
    'mu1' => 566                            , # 0x97, 0o227, 151
    'partialdiff' => 576                    , # 0x98, 0o230, 152
    'summation' => 705                      , # 0x99, 0o231, 153
    'product' => 834                        , # 0x9A, 0o232, 154
    'pi1' => 591                            , # 0x9B, 0o233, 155
    'integral' => 499                       , # 0x9C, 0o234, 156
    'ordfeminine' => 500                    , # 0x9D, 0o235, 157
    'ordmasculine' => 500                   , # 0x9E, 0o236, 158
    'Ohm' => 778                            , # 0x9F, 0o237, 159
    'ae' => 736                             , # 0xA0, 0o240, 160
    'oslash' => 539                         , # 0xA1, 0o241, 161
    'questiondown' => 478                   , # 0xA2, 0o242, 162
    'exclamdown' => 331                     , # 0xA3, 0o243, 163
    'logicalnot' => 643                     , # 0xA4, 0o244, 164
    'radical' => 668                        , # 0xA5, 0o245, 165
    'florin' => 519                         , # 0xA6, 0o246, 166
    'approxequal' => 643                    , # 0xA7, 0o247, 167
    'increment' => 668                      , # 0xA8, 0o250, 168
    'guillemotleft' => 581                  , # 0xA9, 0o251, 169
    'guillemotright' => 581                 , # 0xAA, 0o252, 170
    'ellipsis' => 807                       , # 0xAB, 0o253, 171
    'Agrave' => 670                         , # 0xAC, 0o254, 172
    'Atilde' => 670                         , # 0xAD, 0o255, 173
    'Otilde' => 744                         , # 0xAE, 0o256, 174
    'OE' => 998                             , # 0xAF, 0o257, 175
    'oe' => 816                             , # 0xB0, 0o260, 176
    'endash' => 643                         , # 0xB1, 0o261, 177
    'emdash' => 856                         , # 0xB2, 0o262, 178
    'quotedblleft' => 410                   , # 0xB3, 0o263, 179
    'quotedblright' => 410                  , # 0xB4, 0o264, 180
    'quoteleft' => 226                      , # 0xB5, 0o265, 181
    'quoteright' => 226                     , # 0xB6, 0o266, 182
    'divide' => 643                         , # 0xB7, 0o267, 183
    'lozenge' => 561                        , # 0xB8, 0o270, 184
    'ydieresis' => 492                      , # 0xB9, 0o271, 185
    'Ydieresis' => 615                      , # 0xBA, 0o272, 186
    'fraction' => 81                        , # 0xBB, 0o273, 187
    'Euro' => 642                           , # 0xBC, 0o274, 188
    'guilsinglleft' => 415                  , # 0xBD, 0o275, 189
    'guilsinglright' => 415                 , # 0xBE, 0o276, 190
    'fi' => 582                             , # 0xBF, 0o277, 191
    'fl' => 589                             , # 0xC0, 0o300, 192
    'daggerdbl' => 472                      , # 0xC1, 0o301, 193
    'periodcentered' => 279                 , # 0xC2, 0o302, 194
    'quotesinglbase' => 226                 , # 0xC3, 0o303, 195
    'quotedblbase' => 410                   , # 0xC4, 0o304, 196
    'perthousand' => 1205                   , # 0xC5, 0o305, 197
    'Acircumflex' => 670                    , # 0xC6, 0o306, 198
    'Ecircumflex' => 653                    , # 0xC7, 0o307, 199
    'Aacute' => 670                         , # 0xC8, 0o310, 200
    'Edieresis' => 653                      , # 0xC9, 0o311, 201
    'Egrave' => 653                         , # 0xCA, 0o312, 202
    'Iacute' => 389                         , # 0xCB, 0o313, 203
    'Icircumflex' => 389                    , # 0xCC, 0o314, 204
    'Idieresis' => 389                      , # 0xCD, 0o315, 205
    'Igrave' => 389                         , # 0xCE, 0o316, 206
    'Oacute' => 744                         , # 0xCF, 0o317, 207
    'Ocircumflex' => 744                    , # 0xD0, 0o320, 208
    'Ograve' => 744                         , # 0xD1, 0o321, 209
    'Uacute' => 756                         , # 0xD2, 0o322, 210
    'Ucircumflex' => 756                    , # 0xD3, 0o323, 211
    'Ugrave' => 756                         , # 0xD4, 0o324, 212
    'dotlessi' => 292                       , # 0xD5, 0o325, 213
    'circumflex' => 500                     , # 0xD6, 0o326, 214
    'tilde' => 500                          , # 0xD7, 0o327, 215
    'macron' => 500                         , # 0xD8, 0o330, 216
    'breve' => 500                          , # 0xD9, 0o331, 217
    'dotaccent' => 500                      , # 0xDA, 0o332, 218
    'ring' => 500                           , # 0xDB, 0o333, 219
    'cedilla' => 500                        , # 0xDC, 0o334, 220
    'hungarumlaut' => 500                   , # 0xDD, 0o335, 221
    'ogonek' => 500                         , # 0xDE, 0o336, 222
    'caron' => 500                          , # 0xDF, 0o337, 223
    'Lslash' => 603                         , # 0xE0, 0o340, 224
    'lslash' => 286                         , # 0xE1, 0o341, 225
    'Scaron' => 561                         , # 0xE2, 0o342, 226
    'scaron' => 432                         , # 0xE3, 0o343, 227
    'Zcaron' => 601                         , # 0xE4, 0o344, 228
    'zcaron' => 443                         , # 0xE5, 0o345, 229
    'brokenbar' => 375                      , # 0xE6, 0o346, 230
    'Eth' => 749                            , # 0xE7, 0o347, 231
    'eth' => 531                            , # 0xE8, 0o350, 232
    'Yacute' => 615                         , # 0xE9, 0o351, 233
    'yacute' => 492                         , # 0xEA, 0o352, 234
    'Thorn' => 614                          , # 0xEB, 0o353, 235
    'thorn' => 559                          , # 0xEC, 0o354, 236
    'minus' => 643                          , # 0xED, 0o355, 237
    'multiply' => 643                       , # 0xEE, 0o356, 238
    'onesuperior' => 500                    , # 0xEF, 0o357, 239
    'twosuperior' => 500                    , # 0xF0, 0o360, 240
    'threesuperior' => 500                  , # 0xF1, 0o361, 241
    'onehalf' => 1049                       , # 0xF2, 0o362, 242
    'onequarter' => 1049                    , # 0xF3, 0o363, 243
    'threequarters' => 1049                 , # 0xF4, 0o364, 244
    'franc' => 622                          , # 0xF5, 0o365, 245
    'Gbreve' => 725                         , # 0xF6, 0o366, 246
    'gbreve' => 509                         , # 0xF7, 0o367, 247
    'Idotaccent' => 389                     , # 0xF8, 0o370, 248
    'Scedilla' => 561                       , # 0xF9, 0o371, 249
    'scedilla' => 432                       , # 0xFA, 0o372, 250
    'Cacute' => 642                         , # 0xFB, 0o373, 251
    'cacute' => 454                         , # 0xFC, 0o374, 252
    'Ccaron' => 642                         , # 0xFD, 0o375, 253
    'ccaron' => 454                         , # 0xFE, 0o376, 254
    'dcroat' => 574                         , # 0xFF, 0o377, 255
    'overscore' => 643                      , # 0x100, 0o400, 256
    'middot' => 279                         , # 0x101, 0o401, 257
    'Abreve' => 670                         , # 0x102, 0o402, 258
    'abreve' => 503                         , # 0x103, 0o403, 259
    'Aogonek' => 670                        , # 0x104, 0o404, 260
    'aogonek' => 503                        , # 0x105, 0o405, 261
    'Dcaron' => 749                         , # 0x106, 0o406, 262
    'dcaron' => 665                         , # 0x107, 0o407, 263
    'Dcroat' => 749                         , # 0x108, 0o410, 264
    'Eogonek' => 653                        , # 0x109, 0o411, 265
    'eogonek' => 483                        , # 0x10A, 0o412, 266
    'Ecaron' => 653                         , # 0x10B, 0o413, 267
    'ecaron' => 483                         , # 0x10C, 0o414, 268
    'Lacute' => 603                         , # 0x10D, 0o415, 269
    'lacute' => 286                         , # 0x10E, 0o416, 270
    'Lcaron' => 603                         , # 0x10F, 0o417, 271
    'lcaron' => 376                         , # 0x110, 0o420, 272
    'Ldot' => 603                           , # 0x111, 0o421, 273
    'ldot' => 420                           , # 0x112, 0o422, 274
    'Nacute' => 767                         , # 0x113, 0o423, 275
    'nacute' => 590                         , # 0x114, 0o424, 276
    'Ncaron' => 767                         , # 0x115, 0o425, 277
    'ncaron' => 590                         , # 0x116, 0o426, 278
    'Ohungarumlaut' => 744                  , # 0x117, 0o427, 279
    'ohungarumlaut' => 539                  , # 0x118, 0o430, 280
    'Racute' => 701                         , # 0x119, 0o431, 281
    'racute' => 409                         , # 0x11A, 0o432, 282
    'Rcaron' => 701                         , # 0x11B, 0o433, 283
    'rcaron' => 409                         , # 0x11C, 0o434, 284
    'Sacute' => 561                         , # 0x11D, 0o435, 285
    'sacute' => 432                         , # 0x11E, 0o436, 286
    'Tcommaaccent' => 618                   , # 0x11F, 0o437, 287
    'tcommaaccent' => 345                   , # 0x120, 0o440, 288
    'Tcaron' => 618                         , # 0x121, 0o441, 289
    'tcaron' => 345                         , # 0x122, 0o442, 290
    'Uring' => 756                          , # 0x123, 0o443, 291
    'uring' => 575                          , # 0x124, 0o444, 292
    'Uhungarumlaut' => 756                  , # 0x125, 0o445, 293
    'uhungarumlaut' => 575                  , # 0x126, 0o446, 294
    'Zacute' => 601                         , # 0x127, 0o447, 295
    'zacute' => 443                         , # 0x128, 0o450, 296
    'Zdotaccent' => 601                     , # 0x129, 0o451, 297
    'zdotaccent' => 443                     , # 0x12A, 0o452, 298
    'Gamma' => 583                          , # 0x12B, 0o453, 299
    'Theta' => 744                          , # 0x12C, 0o454, 300
    'Phi' => 766                            , # 0x12D, 0o455, 301
    'alpha' => 597                          , # 0x12E, 0o456, 302
    'delta' => 539                          , # 0x12F, 0o457, 303
    'epsilon' => 468                        , # 0x130, 0o460, 304
    'sigma' => 572                          , # 0x131, 0o461, 305
    'tau' => 450                            , # 0x132, 0o462, 306
    'phi' => 695                            , # 0x133, 0o463, 307
    'underscoredbl' => 643                  , # 0x134, 0o464, 308
    'exclamdbl' => 575                      , # 0x135, 0o465, 309
    'nsuperior' => 525                      , # 0x136, 0o466, 310
    'peseta' => 1204                        , # 0x137, 0o467, 311
    'IJ' => 887                             , # 0x138, 0o470, 312
    'ij' => 572                             , # 0x139, 0o471, 313
    'napostrophe' => 644                    , # 0x13A, 0o472, 314
    'minute' => 321                         , # 0x13B, 0o473, 315
    'second' => 517                         , # 0x13C, 0o474, 316
    'afii61248' => 817                      , # 0x13D, 0o475, 317
    'afii61289' => 323                      , # 0x13E, 0o476, 318
    'H22073' => 604                         , # 0x13F, 0o477, 319
    'H18543' => 354                         , # 0x140, 0o500, 320
    'H18551' => 354                         , # 0x141, 0o501, 321
    'H18533' => 604                         , # 0x142, 0o502, 322
    'openbullet' => 354                     , # 0x143, 0o503, 323
    'Amacron' => 670                        , # 0x144, 0o504, 324
    'amacron' => 503                        , # 0x145, 0o505, 325
    'Ccircumflex' => 642                    , # 0x146, 0o506, 326
    'ccircumflex' => 454                    , # 0x147, 0o507, 327
    'Cdotaccent' => 642                     , # 0x148, 0o510, 328
    'cdotaccent' => 454                     , # 0x149, 0o511, 329
    'Emacron' => 653                        , # 0x14A, 0o512, 330
    'emacron' => 483                        , # 0x14B, 0o513, 331
    'Ebreve' => 653                         , # 0x14C, 0o514, 332
    'ebreve' => 483                         , # 0x14D, 0o515, 333
    'Edotaccent' => 653                     , # 0x14E, 0o516, 334
    'edotaccent' => 483                     , # 0x14F, 0o517, 335
    'Gcircumflex' => 725                    , # 0x150, 0o520, 336
    'gcircumflex' => 509                    , # 0x151, 0o521, 337
    'Gdotaccent' => 725                     , # 0x152, 0o522, 338
    'gdotaccent' => 509                     , # 0x153, 0o523, 339
    'Gcommaaccent' => 725                   , # 0x154, 0o524, 340
    'gcommaaccent' => 509                   , # 0x155, 0o525, 341
    'Hcircumflex' => 814                    , # 0x156, 0o526, 342
    'hcircumflex' => 582                    , # 0x157, 0o527, 343
    'Hbar' => 814                           , # 0x158, 0o530, 344
    'hbar' => 582                           , # 0x159, 0o531, 345
    'Itilde' => 389                         , # 0x15A, 0o532, 346
    'itilde' => 292                         , # 0x15B, 0o533, 347
    'Imacron' => 389                        , # 0x15C, 0o534, 348
    'imacron' => 292                        , # 0x15D, 0o535, 349
    'Ibreve' => 389                         , # 0x15E, 0o536, 350
    'ibreve' => 292                         , # 0x15F, 0o537, 351
    'Iogonek' => 389                        , # 0x160, 0o540, 352
    'iogonek' => 292                        , # 0x161, 0o541, 353
    'Jcircumflex' => 517                    , # 0x162, 0o542, 354
    'jcircumflex' => 291                    , # 0x163, 0o543, 355
    'Kcommaaccent' => 694                   , # 0x164, 0o544, 356
    'kcommaaccent' => 535                   , # 0x165, 0o545, 357
    'kgreenlandic' => 544                   , # 0x166, 0o546, 358
    'Lcommaaccent' => 603                   , # 0x167, 0o547, 359
    'lcommaaccent' => 286                   , # 0x168, 0o550, 360
    'Ncommaaccent' => 767                   , # 0x169, 0o551, 361
    'ncommaaccent' => 590                   , # 0x16A, 0o552, 362
    'Eng' => 767                            , # 0x16B, 0o553, 363
    'eng' => 578                            , # 0x16C, 0o554, 364
    'Omacron' => 744                        , # 0x16D, 0o555, 365
    'omacron' => 539                        , # 0x16E, 0o556, 366
    'Obreve' => 744                         , # 0x16F, 0o557, 367
    'obreve' => 539                         , # 0x170, 0o560, 368
    'Rcommaaccent' => 701                   , # 0x171, 0o561, 369
    'rcommaaccent' => 409                   , # 0x172, 0o562, 370
    'Scircumflex' => 561                    , # 0x173, 0o563, 371
    'scircumflex' => 432                    , # 0x174, 0o564, 372
    'Tbar' => 618                           , # 0x175, 0o565, 373
    'tbar' => 345                           , # 0x176, 0o566, 374
    'Utilde' => 756                         , # 0x177, 0o567, 375
    'utilde' => 575                         , # 0x178, 0o570, 376
    'Umacron' => 756                        , # 0x179, 0o571, 377
    'umacron' => 575                        , # 0x17A, 0o572, 378
    'Ubreve' => 756                         , # 0x17B, 0o573, 379
    'ubreve' => 575                         , # 0x17C, 0o574, 380
    'Uogonek' => 756                        , # 0x17D, 0o575, 381
    'uogonek' => 575                        , # 0x17E, 0o576, 382
    'Wcircumflex' => 975                    , # 0x17F, 0o577, 383
    'wcircumflex' => 737                    , # 0x180, 0o600, 384
    'Ycircumflex' => 615                    , # 0x181, 0o601, 385
    'ycircumflex' => 492                    , # 0x182, 0o602, 386
    'longs' => 299                          , # 0x183, 0o603, 387
    'Aringacute' => 670                     , # 0x184, 0o604, 388
    'aringacute' => 503                     , # 0x185, 0o605, 389
    'AEacute' => 970                        , # 0x186, 0o606, 390
    'aeacute' => 736                        , # 0x187, 0o607, 391
    'Oslashacute' => 744                    , # 0x188, 0o610, 392
    'oslashacute' => 539                    , # 0x189, 0o611, 393
    'anoteleia' => 312                      , # 0x18A, 0o612, 394
    'Wgrave' => 975                         , # 0x18B, 0o613, 395
    'wgrave' => 737                         , # 0x18C, 0o614, 396
    'Wacute' => 975                         , # 0x18D, 0o615, 397
    'wacute' => 737                         , # 0x18E, 0o616, 398
    'Wdieresis' => 975                      , # 0x18F, 0o617, 399
    'wdieresis' => 737                      , # 0x190, 0o620, 400
    'Ygrave' => 615                         , # 0x191, 0o621, 401
    'ygrave' => 492                         , # 0x192, 0o622, 402
    'quotereversed' => 195                  , # 0x193, 0o623, 403
    'radicalex' => 643                      , # 0x194, 0o624, 404
    'lira' => 622                           , # 0x195, 0o625, 405
    'estimated' => 615                      , # 0x196, 0o626, 406
    'oneeighth' => 1049                     , # 0x197, 0o627, 407
    'threeeighths' => 1049                  , # 0x198, 0o630, 408
    'fiveeighths' => 1049                   , # 0x199, 0o631, 409
    'seveneighths' => 1049                  , # 0x19A, 0o632, 410
    'commaaccent' => 604                    , # 0x19B, 0o633, 411
    'undercommaaccent' => 500               , # 0x19C, 0o634, 412
    'tonos' => 500                          , # 0x19D, 0o635, 413
    'dieresistonos' => 500                  , # 0x19E, 0o636, 414
    'Alphatonos' => 675                     , # 0x19F, 0o637, 415
    'Epsilontonos' => 798                   , # 0x1A0, 0o640, 416
    'Etatonos' => 959                       , # 0x1A1, 0o641, 417
    'Iotatonos' => 532                      , # 0x1A2, 0o642, 418
    'Omicrontonos' => 851                   , # 0x1A3, 0o643, 419
    'Upsilontonos' => 800                   , # 0x1A4, 0o644, 420
    'Omegatonos' => 876                     , # 0x1A5, 0o645, 421
    'iotadieresistonos' => 295              , # 0x1A6, 0o646, 422
    'Alpha' => 670                          , # 0x1A7, 0o647, 423
    'Beta' => 653                           , # 0x1A8, 0o650, 424
    'Delta' => 660                          , # 0x1A9, 0o651, 425
    'Epsilon' => 653                        , # 0x1AA, 0o652, 426
    'Zeta' => 601                           , # 0x1AB, 0o653, 427
    'Eta' => 814                            , # 0x1AC, 0o654, 428
    'Iota' => 389                           , # 0x1AD, 0o655, 429
    'Kappa' => 694                          , # 0x1AE, 0o656, 430
    'Lambda' => 673                         , # 0x1AF, 0o657, 431
    'Mu' => 927                             , # 0x1B0, 0o660, 432
    'Nu' => 767                             , # 0x1B1, 0o661, 433
    'Xi' => 693                             , # 0x1B2, 0o662, 434
    'Omicron' => 744                        , # 0x1B3, 0o663, 435
    'Pi' => 808                             , # 0x1B4, 0o664, 436
    'Rho' => 609                            , # 0x1B5, 0o665, 437
    'Sigma' => 603                          , # 0x1B6, 0o666, 438
    'Tau' => 618                            , # 0x1B7, 0o667, 439
    'Upsilon' => 615                        , # 0x1B8, 0o670, 440
    'Chi' => 710                            , # 0x1B9, 0o671, 441
    'Psi' => 874                            , # 0x1BA, 0o672, 442
    'Omega' => 778                          , # 0x1BB, 0o673, 443
    'Iotadieresis' => 389                   , # 0x1BC, 0o674, 444
    'Upsilondieresis' => 615                , # 0x1BD, 0o675, 445
    'alphatonos' => 597                     , # 0x1BE, 0o676, 446
    'epsilontonos' => 468                   , # 0x1BF, 0o677, 447
    'etatonos' => 570                       , # 0x1C0, 0o700, 448
    'iotatonos' => 295                      , # 0x1C1, 0o701, 449
    'upsilondieresistonos' => 541           , # 0x1C2, 0o702, 450
    'beta' => 565                           , # 0x1C3, 0o703, 451
    'gamma' => 513                          , # 0x1C4, 0o704, 452
    'zeta' => 403                           , # 0x1C5, 0o705, 453
    'eta' => 570                            , # 0x1C6, 0o706, 454
    'theta' => 556                          , # 0x1C7, 0o707, 455
    'iota' => 295                           , # 0x1C8, 0o710, 456
    'kappa' => 536                          , # 0x1C9, 0o711, 457
    'lambda' => 487                         , # 0x1CA, 0o712, 458
    'mu' => 579                             , # 0x1CB, 0o713, 459
    'nu' => 501                             , # 0x1CC, 0o714, 460
    'xi' => 440                             , # 0x1CD, 0o715, 461
    'omicron' => 539                        , # 0x1CE, 0o716, 462
    'rho' => 557                            , # 0x1CF, 0o717, 463
    'sigma1' => 445                         , # 0x1D0, 0o720, 464
    'upsilon' => 541                        , # 0x1D1, 0o721, 465
    'chi' => 506                            , # 0x1D2, 0o722, 466
    'psi' => 730                            , # 0x1D3, 0o723, 467
    'omega' => 714                          , # 0x1D4, 0o724, 468
    'iotadieresis' => 295                   , # 0x1D5, 0o725, 469
    'upsilondieresis' => 541                , # 0x1D6, 0o726, 470
    'omicrontonos' => 539                   , # 0x1D7, 0o727, 471
    'upsilontonos' => 541                   , # 0x1D8, 0o730, 472
    'omegatonos' => 714                     , # 0x1D9, 0o731, 473
    'afii10023' => 653                      , # 0x1DA, 0o732, 474
    'afii10051' => 785                      , # 0x1DB, 0o733, 475
    'afii10052' => 583                      , # 0x1DC, 0o734, 476
    'afii10053' => 656                      , # 0x1DD, 0o735, 477
    'afii10054' => 561                      , # 0x1DE, 0o736, 478
    'afii10055' => 389                      , # 0x1DF, 0o737, 479
    'afii10056' => 389                      , # 0x1E0, 0o740, 480
    'afii10057' => 517                      , # 0x1E1, 0o741, 481
    'afii10058' => 1011                     , # 0x1E2, 0o742, 482
    'afii10059' => 1065                     , # 0x1E3, 0o743, 483
    'afii10060' => 839                      , # 0x1E4, 0o744, 484
    'afii10061' => 694                      , # 0x1E5, 0o745, 485
    'afii10062' => 656                      , # 0x1E6, 0o746, 486
    'afii10145' => 810                      , # 0x1E7, 0o747, 487
    'afii10017' => 670                      , # 0x1E8, 0o750, 488
    'afii10018' => 651                      , # 0x1E9, 0o751, 489
    'afii10019' => 653                      , # 0x1EA, 0o752, 490
    'afii10020' => 583                      , # 0x1EB, 0o753, 491
    'afii10021' => 722                      , # 0x1EC, 0o754, 492
    'afii10022' => 653                      , # 0x1ED, 0o755, 493
    'afii10024' => 984                      , # 0x1EE, 0o756, 494
    'afii10025' => 609                      , # 0x1EF, 0o757, 495
    'afii10026' => 818                      , # 0x1F0, 0o760, 496
    'afii10027' => 818                      , # 0x1F1, 0o761, 497
    'afii10028' => 694                      , # 0x1F2, 0o762, 498
    'afii10029' => 756                      , # 0x1F3, 0o763, 499
    'afii10030' => 927                      , # 0x1F4, 0o764, 500
    'afii10031' => 814                      , # 0x1F5, 0o765, 501
    'afii10032' => 744                      , # 0x1F6, 0o766, 502
    'afii10033' => 808                      , # 0x1F7, 0o767, 503
    'afii10034' => 609                      , # 0x1F8, 0o770, 504
    'afii10035' => 642                      , # 0x1F9, 0o771, 505
    'afii10036' => 618                      , # 0x1FA, 0o772, 506
    'afii10037' => 656                      , # 0x1FB, 0o773, 507
    'afii10038' => 766                      , # 0x1FC, 0o774, 508
    'afii10039' => 710                      , # 0x1FD, 0o775, 509
    'afii10040' => 808                      , # 0x1FE, 0o776, 510
    'afii10041' => 748                      , # 0x1FF, 0o777, 511
    'afii10042' => 1098                     , # 0x200, 0o1000, 512
    'afii10043' => 1098                     , # 0x201, 0o1001, 513
    'afii10044' => 762                      , # 0x202, 0o1002, 514
    'afii10045' => 967                      , # 0x203, 0o1003, 515
    'afii10046' => 640                      , # 0x204, 0o1004, 516
    'afii10047' => 657                      , # 0x205, 0o1005, 517
    'afii10048' => 1065                     , # 0x206, 0o1006, 518
    'afii10049' => 696                      , # 0x207, 0o1007, 519
    'afii10065' => 503                      , # 0x208, 0o1010, 520
    'afii10066' => 540                      , # 0x209, 0o1011, 521
    'afii10067' => 518                      , # 0x20A, 0o1012, 522
    'afii10068' => 439                      , # 0x20B, 0o1013, 523
    'afii10069' => 559                      , # 0x20C, 0o1014, 524
    'afii10070' => 483                      , # 0x20D, 0o1015, 525
    'afii10072' => 787                      , # 0x20E, 0o1016, 526
    'afii10073' => 473                      , # 0x20F, 0o1017, 527
    'afii10074' => 612                      , # 0x210, 0o1020, 528
    'afii10075' => 612                      , # 0x211, 0o1021, 529
    'afii10076' => 551                      , # 0x212, 0o1022, 530
    'afii10077' => 581                      , # 0x213, 0o1023, 531
    'afii10078' => 715                      , # 0x214, 0o1024, 532
    'afii10079' => 608                      , # 0x215, 0o1025, 533
    'afii10080' => 539                      , # 0x216, 0o1026, 534
    'afii10081' => 601                      , # 0x217, 0o1027, 535
    'afii10082' => 571                      , # 0x218, 0o1030, 536
    'afii10083' => 454                      , # 0x219, 0o1031, 537
    'afii10084' => 470                      , # 0x21A, 0o1032, 538
    'afii10085' => 492                      , # 0x21B, 0o1033, 539
    'afii10086' => 752                      , # 0x21C, 0o1034, 540
    'afii10087' => 504                      , # 0x21D, 0o1035, 541
    'afii10088' => 602                      , # 0x21E, 0o1036, 542
    'afii10089' => 572                      , # 0x21F, 0o1037, 543
    'afii10090' => 863                      , # 0x220, 0o1040, 544
    'afii10091' => 864                      , # 0x221, 0o1041, 545
    'afii10092' => 577                      , # 0x222, 0o1042, 546
    'afii10093' => 757                      , # 0x223, 0o1043, 547
    'afii10094' => 497                      , # 0x224, 0o1044, 548
    'afii10095' => 486                      , # 0x225, 0o1045, 549
    'afii10096' => 789                      , # 0x226, 0o1046, 550
    'afii10097' => 547                      , # 0x227, 0o1047, 551
    'afii10071' => 483                      , # 0x228, 0o1050, 552
    'afii10099' => 570                      , # 0x229, 0o1051, 553
    'afii10100' => 439                      , # 0x22A, 0o1052, 554
    'afii10101' => 486                      , # 0x22B, 0o1053, 555
    'afii10102' => 432                      , # 0x22C, 0o1054, 556
    'afii10103' => 292                      , # 0x22D, 0o1055, 557
    'afii10104' => 292                      , # 0x22E, 0o1056, 558
    'afii10105' => 291                      , # 0x22F, 0o1057, 559
    'afii10106' => 773                      , # 0x230, 0o1060, 560
    'afii10107' => 797                      , # 0x231, 0o1061, 561
    'afii10108' => 582                      , # 0x232, 0o1062, 562
    'afii10109' => 551                      , # 0x233, 0o1063, 563
    'afii10110' => 492                      , # 0x234, 0o1064, 564
    'afii10193' => 603                      , # 0x235, 0o1065, 565
    'afii10050' => 576                      , # 0x236, 0o1066, 566
    'afii10098' => 430                      , # 0x237, 0o1067, 567
    'afii00208' => 856                      , # 0x238, 0o1070, 568
    'afii61352' => 1220                     , # 0x239, 0o1071, 569
    'pi' => 601                             , # 0x23A, 0o1072, 570
    'foursuperior' => 500                   , # 0x23B, 0o1073, 571
    'fivesuperior' => 500                   , # 0x23C, 0o1074, 572
    'sevensuperior' => 500                  , # 0x23D, 0o1075, 573
    'eightsuperior' => 500                  , # 0x23E, 0o1076, 574
    'Dieresis' => 500                       , # 0x23F, 0o1077, 575
    'Acute' => 500                          , # 0x240, 0o1100, 576
    'Grave' => 500                          , # 0x241, 0o1101, 577
    'Circumflex' => 500                     , # 0x242, 0o1102, 578
    'Caron' => 500                          , # 0x243, 0o1103, 579
    'Breve' => 500                          , # 0x244, 0o1104, 580
    'Hungarumlaut' => 500                   , # 0x245, 0o1105, 581
    'Scommaaccent' => 561                   , # 0x246, 0o1106, 582
    'scommaaccent' => 432                   , # 0x247, 0o1107, 583
    'currency' => 571                       , # 0x248, 0o1110, 584
  },
};

1;
