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

$fonts->{'wingdings'} = {
  'apiname' => 'Wing',
  'fontname' => 'Wingdings',
  'type' => 'TrueType',
  'ascender' => 898,
  'capheight' => 722,
  'descender' => -210,
  'italicangle' => 0,
  'underlineposition' => -200,
  'underlinethickness' => 100,
  'xheight' => 722,
  'flags' => 4,
  'isfixedpitch' => 0,
  'issymbol' => 1,
  'fontbbox' => [ 0, -210, 1358, 898 ],
  'char' => [
    '.notdef'                               , # 0x00, 0o000, 0
    '.notdef'                               , # 0x01, 0o001, 1
    '.notdef'                               , # 0x02, 0o002, 2
    '.notdef'                               , # 0x03, 0o003, 3
    '.notdef'                               , # 0x04, 0o004, 4
    '.notdef'                               , # 0x05, 0o005, 5
    '.notdef'                               , # 0x06, 0o006, 6
    '.notdef'                               , # 0x07, 0o007, 7
    '.notdef'                               , # 0x08, 0o010, 8
    '.notdef'                               , # 0x09, 0o011, 9
    '.notdef'                               , # 0x0A, 0o012, 10
    '.notdef'                               , # 0x0B, 0o013, 11
    '.notdef'                               , # 0x0C, 0o014, 12
    '.notdef'                               , # 0x0D, 0o015, 13
    '.notdef'                               , # 0x0E, 0o016, 14
    '.notdef'                               , # 0x0F, 0o017, 15
    '.notdef'                               , # 0x10, 0o020, 16
    '.notdef'                               , # 0x11, 0o021, 17
    '.notdef'                               , # 0x12, 0o022, 18
    '.notdef'                               , # 0x13, 0o023, 19
    '.notdef'                               , # 0x14, 0o024, 20
    '.notdef'                               , # 0x15, 0o025, 21
    '.notdef'                               , # 0x16, 0o026, 22
    '.notdef'                               , # 0x17, 0o027, 23
    '.notdef'                               , # 0x18, 0o030, 24
    '.notdef'                               , # 0x19, 0o031, 25
    '.notdef'                               , # 0x1A, 0o032, 26
    '.notdef'                               , # 0x1B, 0o033, 27
    '.notdef'                               , # 0x1C, 0o034, 28
    '.notdef'                               , # 0x1D, 0o035, 29
    '.notdef'                               , # 0x1E, 0o036, 30
    '.notdef'                               , # 0x1F, 0o037, 31
    'space'                                 , # 0x20, 0o040, 32
    'pencil'                                , # 0x21, 0o041, 33
    'scissors'                              , # 0x22, 0o042, 34
    'scissorscutting'                       , # 0x23, 0o043, 35
    'readingglasses'                        , # 0x24, 0o044, 36
    'bell'                                  , # 0x25, 0o045, 37
    'book'                                  , # 0x26, 0o046, 38
    'candle'                                , # 0x27, 0o047, 39
    'telephonesolid'                        , # 0x28, 0o050, 40
    'telhandsetcirc'                        , # 0x29, 0o051, 41
    'envelopeback'                          , # 0x2A, 0o052, 42
    'envelopefront'                         , # 0x2B, 0o053, 43
    'mailboxflagdwn'                        , # 0x2C, 0o054, 44
    'mailboxflagup'                         , # 0x2D, 0o055, 45
    'mailbxopnflgup'                        , # 0x2E, 0o056, 46
    'mailbxopnflgdwn'                       , # 0x2F, 0o057, 47
    'folder'                                , # 0x30, 0o060, 48
    'folderopen'                            , # 0x31, 0o061, 49
    'filetalltext1'                         , # 0x32, 0o062, 50
    'filetalltext'                          , # 0x33, 0o063, 51
    'filetalltext3'                         , # 0x34, 0o064, 52
    'filecabinet'                           , # 0x35, 0o065, 53
    'hourglass'                             , # 0x36, 0o066, 54
    'keyboard'                              , # 0x37, 0o067, 55
    'mouse2button'                          , # 0x38, 0o070, 56
    'ballpoint'                             , # 0x39, 0o071, 57
    'pc'                                    , # 0x3A, 0o072, 58
    'harddisk'                              , # 0x3B, 0o073, 59
    'floppy3'                               , # 0x3C, 0o074, 60
    'floppy5'                               , # 0x3D, 0o075, 61
    'tapereel'                              , # 0x3E, 0o076, 62
    'handwrite'                             , # 0x3F, 0o077, 63
    'handwriteleft'                         , # 0x40, 0o100, 64
    'handv'                                 , # 0x41, 0o101, 65
    'handok'                                , # 0x42, 0o102, 66
    'thumbup'                               , # 0x43, 0o103, 67
    'thumbdown'                             , # 0x44, 0o104, 68
    'handptleft'                            , # 0x45, 0o105, 69
    'handptright'                           , # 0x46, 0o106, 70
    'handptup'                              , # 0x47, 0o107, 71
    'handptdwn'                             , # 0x48, 0o110, 72
    'handhalt'                              , # 0x49, 0o111, 73
    'smileface'                             , # 0x4A, 0o112, 74
    'neutralface'                           , # 0x4B, 0o113, 75
    'frownface'                             , # 0x4C, 0o114, 76
    'bomb'                                  , # 0x4D, 0o115, 77
    'skullcrossbones'                       , # 0x4E, 0o116, 78
    'flag'                                  , # 0x4F, 0o117, 79
    'pennant'                               , # 0x50, 0o120, 80
    'airplane'                              , # 0x51, 0o121, 81
    'sunshine'                              , # 0x52, 0o122, 82
    'droplet'                               , # 0x53, 0o123, 83
    'snowflake'                             , # 0x54, 0o124, 84
    'crossoutline'                          , # 0x55, 0o125, 85
    'crossshadow'                           , # 0x56, 0o126, 86
    'crossceltic'                           , # 0x57, 0o127, 87
    'crossmaltese'                          , # 0x58, 0o130, 88
    'starofdavid'                           , # 0x59, 0o131, 89
    'crescentstar'                          , # 0x5A, 0o132, 90
    'yinyang'                               , # 0x5B, 0o133, 91
    'om'                                    , # 0x5C, 0o134, 92
    'wheel'                                 , # 0x5D, 0o135, 93
    'aries'                                 , # 0x5E, 0o136, 94
    'taurus'                                , # 0x5F, 0o137, 95
    'gemini'                                , # 0x60, 0o140, 96
    'cancer'                                , # 0x61, 0o141, 97
    'leo'                                   , # 0x62, 0o142, 98
    'virgo'                                 , # 0x63, 0o143, 99
    'libra'                                 , # 0x64, 0o144, 100
    'scorpio'                               , # 0x65, 0o145, 101
    'saggitarius'                           , # 0x66, 0o146, 102
    'capricorn'                             , # 0x67, 0o147, 103
    'aquarius'                              , # 0x68, 0o150, 104
    'pisces'                                , # 0x69, 0o151, 105
    'ampersanditlc'                         , # 0x6A, 0o152, 106
    'ampersandit'                           , # 0x6B, 0o153, 107
    'circle6'                               , # 0x6C, 0o154, 108
    'circleshadowdwn'                       , # 0x6D, 0o155, 109
    'square6'                               , # 0x6E, 0o156, 110
    'box3'                                  , # 0x6F, 0o157, 111
    'box4'                                  , # 0x70, 0o160, 112
    'boxshadowdwn'                          , # 0x71, 0o161, 113
    'boxshadowup'                           , # 0x72, 0o162, 114
    'lozenge4'                              , # 0x73, 0o163, 115
    'lozenge6'                              , # 0x74, 0o164, 116
    'rhombus6'                              , # 0x75, 0o165, 117
    'xrhombus'                              , # 0x76, 0o166, 118
    'rhombus4'                              , # 0x77, 0o167, 119
    'clear'                                 , # 0x78, 0o170, 120
    'escape'                                , # 0x79, 0o171, 121
    'command'                               , # 0x7A, 0o172, 122
    'rosette'                               , # 0x7B, 0o173, 123
    'rosettesolid'                          , # 0x7C, 0o174, 124
    'quotedbllftbld'                        , # 0x7D, 0o175, 125
    'quotedblrtbld'                         , # 0x7E, 0o176, 126
    '.notdef'                               , # 0x7F, 0o177, 127
    'zerosans'                              , # 0x80, 0o200, 128
    'onesans'                               , # 0x81, 0o201, 129
    'twosans'                               , # 0x82, 0o202, 130
    'threesans'                             , # 0x83, 0o203, 131
    'foursans'                              , # 0x84, 0o204, 132
    'fivesans'                              , # 0x85, 0o205, 133
    'sixsans'                               , # 0x86, 0o206, 134
    'sevensans'                             , # 0x87, 0o207, 135
    'eightsans'                             , # 0x88, 0o210, 136
    'ninesans'                              , # 0x89, 0o211, 137
    'tensans'                               , # 0x8A, 0o212, 138
    'zerosansinv'                           , # 0x8B, 0o213, 139
    'onesansinv'                            , # 0x8C, 0o214, 140
    'twosansinv'                            , # 0x8D, 0o215, 141
    'threesansinv'                          , # 0x8E, 0o216, 142
    'foursansinv'                           , # 0x8F, 0o217, 143
    'fivesansinv'                           , # 0x90, 0o220, 144
    'sixsansinv'                            , # 0x91, 0o221, 145
    'sevensansinv'                          , # 0x92, 0o222, 146
    'eightsansinv'                          , # 0x93, 0o223, 147
    'ninesansinv'                           , # 0x94, 0o224, 148
    'tensansinv'                            , # 0x95, 0o225, 149
    'budleafne'                             , # 0x96, 0o226, 150
    'budleafnw'                             , # 0x97, 0o227, 151
    'budleafsw'                             , # 0x98, 0o230, 152
    'budleafse'                             , # 0x99, 0o231, 153
    'vineleafboldne'                        , # 0x9A, 0o232, 154
    'vineleafboldnw'                        , # 0x9B, 0o233, 155
    'vineleafboldsw'                        , # 0x9C, 0o234, 156
    'vineleafboldse'                        , # 0x9D, 0o235, 157
    'circle2'                               , # 0x9E, 0o236, 158
    'circle4'                               , # 0x9F, 0o237, 159
    'square2'                               , # 0xA0, 0o240, 160
    'ring2'                                 , # 0xA1, 0o241, 161
    'ring4'                                 , # 0xA2, 0o242, 162
    'ring6'                                 , # 0xA3, 0o243, 163
    'ringbutton2'                           , # 0xA4, 0o244, 164
    'target'                                , # 0xA5, 0o245, 165
    'circleshadowup'                        , # 0xA6, 0o246, 166
    'square4'                               , # 0xA7, 0o247, 167
    'box2'                                  , # 0xA8, 0o250, 168
    'tristar2'                              , # 0xA9, 0o251, 169
    'crosstar2'                             , # 0xAA, 0o252, 170
    'pentastar2'                            , # 0xAB, 0o253, 171
    'hexstar2'                              , # 0xAC, 0o254, 172
    'octastar2'                             , # 0xAD, 0o255, 173
    'dodecastar3'                           , # 0xAE, 0o256, 174
    'octastar4'                             , # 0xAF, 0o257, 175
    'registersquare'                        , # 0xB0, 0o260, 176
    'registercircle'                        , # 0xB1, 0o261, 177
    'cuspopen'                              , # 0xB2, 0o262, 178
    'cuspopen1'                             , # 0xB3, 0o263, 179
    'query'                                 , # 0xB4, 0o264, 180
    'circlestar'                            , # 0xB5, 0o265, 181
    'starshadow'                            , # 0xB6, 0o266, 182
    'oneoclock'                             , # 0xB7, 0o267, 183
    'twooclock'                             , # 0xB8, 0o270, 184
    'threeoclock'                           , # 0xB9, 0o271, 185
    'fouroclock'                            , # 0xBA, 0o272, 186
    'fiveoclock'                            , # 0xBB, 0o273, 187
    'sixoclock'                             , # 0xBC, 0o274, 188
    'sevenoclock'                           , # 0xBD, 0o275, 189
    'eightoclock'                           , # 0xBE, 0o276, 190
    'nineoclock'                            , # 0xBF, 0o277, 191
    'tenoclock'                             , # 0xC0, 0o300, 192
    'elevenoclock'                          , # 0xC1, 0o301, 193
    'twelveoclock'                          , # 0xC2, 0o302, 194
    'arrowdwnleft1'                         , # 0xC3, 0o303, 195
    'arrowdwnrt1'                           , # 0xC4, 0o304, 196
    'arrowupleft1'                          , # 0xC5, 0o305, 197
    'arrowuprt1'                            , # 0xC6, 0o306, 198
    'arrowleftup1'                          , # 0xC7, 0o307, 199
    'arrowrtup1'                            , # 0xC8, 0o310, 200
    'arrowleftdwn1'                         , # 0xC9, 0o311, 201
    'arrowrtdwn1'                           , # 0xCA, 0o312, 202
    'quiltsquare2'                          , # 0xCB, 0o313, 203
    'quiltsquare2inv'                       , # 0xCC, 0o314, 204
    'leafccwsw'                             , # 0xCD, 0o315, 205
    'leafccwnw'                             , # 0xCE, 0o316, 206
    'leafccwse'                             , # 0xCF, 0o317, 207
    'leafccwne'                             , # 0xD0, 0o320, 208
    'leafnw'                                , # 0xD1, 0o321, 209
    'leafsw'                                , # 0xD2, 0o322, 210
    'leafne'                                , # 0xD3, 0o323, 211
    'leafse'                                , # 0xD4, 0o324, 212
    'deleteleft'                            , # 0xD5, 0o325, 213
    'deleteright'                           , # 0xD6, 0o326, 214
    'head2left'                             , # 0xD7, 0o327, 215
    'head2right'                            , # 0xD8, 0o330, 216
    'head2up'                               , # 0xD9, 0o331, 217
    'head2down'                             , # 0xDA, 0o332, 218
    'circleleft'                            , # 0xDB, 0o333, 219
    'circleright'                           , # 0xDC, 0o334, 220
    'circleup'                              , # 0xDD, 0o335, 221
    'circledown'                            , # 0xDE, 0o336, 222
    'barb2left'                             , # 0xDF, 0o337, 223
    'barb2right'                            , # 0xE0, 0o340, 224
    'barb2up'                               , # 0xE1, 0o341, 225
    'barb2down'                             , # 0xE2, 0o342, 226
    'barb2nw'                               , # 0xE3, 0o343, 227
    'barb2ne'                               , # 0xE4, 0o344, 228
    'barb2sw'                               , # 0xE5, 0o345, 229
    'barb2se'                               , # 0xE6, 0o346, 230
    'barb4left'                             , # 0xE7, 0o347, 231
    'barb4right'                            , # 0xE8, 0o350, 232
    'barb4up'                               , # 0xE9, 0o351, 233
    'barb4down'                             , # 0xEA, 0o352, 234
    'barb4nw'                               , # 0xEB, 0o353, 235
    'barb4ne'                               , # 0xEC, 0o354, 236
    'barb4sw'                               , # 0xED, 0o355, 237
    'barb4se'                               , # 0xEE, 0o356, 238
    'bleft'                                 , # 0xEF, 0o357, 239
    'bright'                                , # 0xF0, 0o360, 240
    'bup'                                   , # 0xF1, 0o361, 241
    'bdown'                                 , # 0xF2, 0o362, 242
    'bleftright'                            , # 0xF3, 0o363, 243
    'bupdown'                               , # 0xF4, 0o364, 244
    'bnw'                                   , # 0xF5, 0o365, 245
    'bne'                                   , # 0xF6, 0o366, 246
    'bsw'                                   , # 0xF7, 0o367, 247
    'bse'                                   , # 0xF8, 0o370, 248
    'bdash1'                                , # 0xF9, 0o371, 249
    'bdash2'                                , # 0xFA, 0o372, 250
    'xmarkbld'                              , # 0xFB, 0o373, 251
    'checkbld'                              , # 0xFC, 0o374, 252
    'boxxmarkbld'                           , # 0xFD, 0o375, 253
    'boxcheckbld'                           , # 0xFE, 0o376, 254
    'windowslogo'                           , # 0xFF, 0o377, 255
  ],
  'wx' => {
    '.notdef' => 500                        , # 0x00, 0o000, 0
    'space' => 1000                         , # 0x03, 0o003, 3
    'pencil' => 1030                        , # 0x04, 0o004, 4
    'scissors' => 1144                      , # 0x05, 0o005, 5
    'scissorscutting' => 1301               , # 0x06, 0o006, 6
    'readingglasses' => 1343                , # 0x07, 0o007, 7
    'bell' => 893                           , # 0x08, 0o010, 8
    'book' => 1216                          , # 0x09, 0o011, 9
    'candle' => 458                         , # 0x0A, 0o012, 10
    'telephonesolid' => 1083                , # 0x0B, 0o013, 11
    'telhandsetcirc' => 891                 , # 0x0C, 0o014, 12
    'envelopeback' => 1132                  , # 0x0D, 0o015, 13
    'envelopefront' => 1132                 , # 0x0E, 0o016, 14
    'mailboxflagdwn' => 1171                , # 0x0F, 0o017, 15
    'mailboxflagup' => 1171                 , # 0x10, 0o020, 16
    'mailbxopnflgup' => 1440                , # 0x11, 0o021, 17
    'mailbxopnflgdwn' => 1443               , # 0x12, 0o022, 18
    'folder' => 1096                        , # 0x13, 0o023, 19
    'folderopen' => 1343                    , # 0x14, 0o024, 20
    'filetalltext1' => 698                  , # 0x15, 0o025, 21
    'filetalltext' => 698                   , # 0x16, 0o026, 22
    'filetalltext3' => 891                  , # 0x17, 0o027, 23
    'filecabinet' => 554                    , # 0x18, 0o030, 24
    'hourglass' => 602                      , # 0x19, 0o031, 25
    'keyboard' => 1072                      , # 0x1A, 0o032, 26
    'mouse2button' => 947                   , # 0x1B, 0o033, 27
    'ballpoint' => 1078                     , # 0x1C, 0o034, 28
    'pc' => 939                             , # 0x1D, 0o035, 29
    'harddisk' => 891                       , # 0x1E, 0o036, 30
    'floppy3' => 891                        , # 0x1F, 0o037, 31
    'floppy5' => 891                        , # 0x20, 0o040, 32
    'tapereel' => 891                       , # 0x21, 0o041, 33
    'handwrite' => 909                      , # 0x22, 0o042, 34
    'handwriteleft' => 909                  , # 0x23, 0o043, 35
    'handv' => 587                          , # 0x24, 0o044, 36
    'handok' => 792                         , # 0x25, 0o045, 37
    'thumbup' => 674                        , # 0x26, 0o046, 38
    'thumbdown' => 674                      , # 0x27, 0o047, 39
    'handptleft' => 941                     , # 0x28, 0o050, 40
    'handptright' => 941                    , # 0x29, 0o051, 41
    'handptup' => 548                       , # 0x2A, 0o052, 42
    'handptdwn' => 548                      , # 0x2B, 0o053, 43
    'handhalt' => 891                       , # 0x2C, 0o054, 44
    'smileface' => 843                      , # 0x2D, 0o055, 45
    'neutralface' => 843                    , # 0x2E, 0o056, 46
    'frownface' => 843                      , # 0x2F, 0o057, 47
    'bomb' => 1110                          , # 0x30, 0o060, 48
    'skullcrossbones' => 660                , # 0x31, 0o061, 49
    'flag' => 849                           , # 0x32, 0o062, 50
    'pennant' => 1088                       , # 0x33, 0o063, 51
    'airplane' => 888                       , # 0x34, 0o064, 52
    'sunshine' => 880                       , # 0x35, 0o065, 53
    'droplet' => 650                        , # 0x36, 0o066, 54
    'snowflake' => 812                      , # 0x37, 0o067, 55
    'xmarkbld' => 635                       , # 0x38, 0o070, 56
    'checkbld' => 785                       , # 0x39, 0o071, 57
    'boxxmarkbld' => 891                    , # 0x3A, 0o072, 58
    'boxcheckbld' => 891                    , # 0x3B, 0o073, 59
    'crossoutline' => 746                   , # 0x3C, 0o074, 60
    'crossshadow' => 746                    , # 0x3D, 0o075, 61
    'crossceltic' => 722                    , # 0x3E, 0o076, 62
    'crossmaltese' => 693                   , # 0x3F, 0o077, 63
    'starofdavid' => 794                    , # 0x40, 0o100, 64
    'crescentstar' => 885                   , # 0x41, 0o101, 65
    'yinyang' => 891                        , # 0x42, 0o102, 66
    'om' => 895                             , # 0x43, 0o103, 67
    'wheel' => 891                          , # 0x44, 0o104, 68
    'aries' => 1156                         , # 0x45, 0o105, 69
    'taurus' => 1054                        , # 0x46, 0o106, 70
    'gemini' => 963                         , # 0x47, 0o107, 71
    'cancer' => 1090                        , # 0x48, 0o110, 72
    'leo' => 940                            , # 0x49, 0o111, 73
    'virgo' => 933                          , # 0x4A, 0o112, 74
    'libra' => 945                          , # 0x4B, 0o113, 75
    'scorpio' => 1024                       , # 0x4C, 0o114, 76
    'saggitarius' => 928                    , # 0x4D, 0o115, 77
    'capricorn' => 1096                     , # 0x4E, 0o116, 78
    'aquarius' => 1064                      , # 0x4F, 0o117, 79
    'pisces' => 779                         , # 0x50, 0o120, 80
    'ampersanditlc' => 1049                 , # 0x51, 0o121, 81
    'ampersandit' => 1270                   , # 0x52, 0o122, 82
    'quotedbllftbld' => 530                 , # 0x53, 0o123, 83
    'quotedblrtbld' => 530                  , # 0x54, 0o124, 84
    'rosette' => 891                        , # 0x55, 0o125, 85
    'rosettesolid' => 891                   , # 0x56, 0o126, 86
    'budleafne' => 1000                     , # 0x57, 0o127, 87
    'budleafnw' => 1000                     , # 0x58, 0o130, 88
    'budleafsw' => 1000                     , # 0x59, 0o131, 89
    'budleafse' => 1000                     , # 0x5A, 0o132, 90
    'vineleafboldne' => 1000                , # 0x5B, 0o133, 91
    'vineleafboldnw' => 1000                , # 0x5C, 0o134, 92
    'vineleafboldsw' => 1000                , # 0x5D, 0o135, 93
    'vineleafboldse' => 1000                , # 0x5E, 0o136, 94
    'clear' => 1060                         , # 0x5F, 0o137, 95
    'escape' => 1060                        , # 0x60, 0o140, 96
    'command' => 891                        , # 0x61, 0o141, 97
    'zerosans' => 891                       , # 0x62, 0o142, 98
    'onesans' => 891                        , # 0x63, 0o143, 99
    'twosans' => 891                        , # 0x64, 0o144, 100
    'threesans' => 891                      , # 0x65, 0o145, 101
    'foursans' => 891                       , # 0x66, 0o146, 102
    'fivesans' => 891                       , # 0x67, 0o147, 103
    'sixsans' => 891                        , # 0x68, 0o150, 104
    'sevensans' => 891                      , # 0x69, 0o151, 105
    'eightsans' => 891                      , # 0x6A, 0o152, 106
    'ninesans' => 891                       , # 0x6B, 0o153, 107
    'tensans' => 891                        , # 0x6C, 0o154, 108
    'zerosansinv' => 891                    , # 0x6D, 0o155, 109
    'onesansinv' => 891                     , # 0x6E, 0o156, 110
    'twosansinv' => 891                     , # 0x6F, 0o157, 111
    'threesansinv' => 891                   , # 0x70, 0o160, 112
    'foursansinv' => 891                    , # 0x71, 0o161, 113
    'fivesansinv' => 891                    , # 0x72, 0o162, 114
    'sixsansinv' => 891                     , # 0x73, 0o163, 115
    'sevensansinv' => 891                   , # 0x74, 0o164, 116
    'eightsansinv' => 891                   , # 0x75, 0o165, 117
    'ninesansinv' => 891                    , # 0x76, 0o166, 118
    'tensansinv' => 891                     , # 0x77, 0o167, 119
    'circle2' => 312                        , # 0x78, 0o170, 120
    'circle4' => 457                        , # 0x79, 0o171, 121
    'circle6' => 746                        , # 0x7A, 0o172, 122
    'ring2' => 891                          , # 0x7B, 0o173, 123
    'ring4' => 891                          , # 0x7C, 0o174, 124
    'ring6' => 891                          , # 0x7D, 0o175, 125
    'ringbutton2' => 891                    , # 0x7E, 0o176, 126
    'target' => 891                         , # 0x7F, 0o177, 127
    'circleshadowup' => 952                 , # 0x80, 0o200, 128
    'circleshadowdwn' => 952                , # 0x81, 0o201, 129
    'square2' => 312                        , # 0x82, 0o202, 130
    'square4' => 457                        , # 0x83, 0o203, 131
    'square6' => 746                        , # 0x84, 0o204, 132
    'box2' => 891                           , # 0x85, 0o205, 133
    'box3' => 891                           , # 0x86, 0o206, 134
    'box4' => 891                           , # 0x87, 0o207, 135
    'boxshadowup' => 891                    , # 0x88, 0o210, 136
    'boxshadowdwn' => 891                   , # 0x89, 0o211, 137
    'rhombus4' => 577                       , # 0x8A, 0o212, 138
    'rhombus6' => 986                       , # 0x8B, 0o213, 139
    'lozenge4' => 457                       , # 0x8C, 0o214, 140
    'lozenge6' => 746                       , # 0x8D, 0o215, 141
    'tristar2' => 891                       , # 0x8E, 0o216, 142
    'crosstar2' => 891                      , # 0x8F, 0o217, 143
    'pentastar2' => 891                     , # 0x90, 0o220, 144
    'hexstar2' => 891                       , # 0x91, 0o221, 145
    'octastar2' => 891                      , # 0x92, 0o222, 146
    'dodecastar3' => 891                    , # 0x93, 0o223, 147
    'octastar4' => 891                      , # 0x94, 0o224, 148
    'registersquare' => 891                 , # 0x95, 0o225, 149
    'registercircle' => 891                 , # 0x96, 0o226, 150
    'cuspopen' => 891                       , # 0x97, 0o227, 151
    'cuspopen1' => 891                      , # 0x98, 0o230, 152
    'xrhombus' => 891                       , # 0x99, 0o231, 153
    'query' => 891                          , # 0x9A, 0o232, 154
    'circlestar' => 891                     , # 0x9B, 0o233, 155
    'starshadow' => 891                     , # 0x9C, 0o234, 156
    'oneoclock' => 891                      , # 0x9D, 0o235, 157
    'twooclock' => 891                      , # 0x9E, 0o236, 158
    'threeoclock' => 891                    , # 0x9F, 0o237, 159
    'fouroclock' => 891                     , # 0xA0, 0o240, 160
    'fiveoclock' => 891                     , # 0xA1, 0o241, 161
    'sixoclock' => 891                      , # 0xA2, 0o242, 162
    'sevenoclock' => 891                    , # 0xA3, 0o243, 163
    'eightoclock' => 891                    , # 0xA4, 0o244, 164
    'nineoclock' => 891                     , # 0xA5, 0o245, 165
    'tenoclock' => 891                      , # 0xA6, 0o246, 166
    'elevenoclock' => 891                   , # 0xA7, 0o247, 167
    'twelveoclock' => 891                   , # 0xA8, 0o250, 168
    'arrowdwnleft1' => 891                  , # 0xA9, 0o251, 169
    'arrowdwnrt1' => 891                    , # 0xAA, 0o252, 170
    'arrowupleft1' => 891                   , # 0xAB, 0o253, 171
    'arrowuprt1' => 891                     , # 0xAC, 0o254, 172
    'arrowleftup1' => 1047                  , # 0xAD, 0o255, 173
    'arrowrtup1' => 1047                    , # 0xAE, 0o256, 174
    'arrowleftdwn1' => 1047                 , # 0xAF, 0o257, 175
    'arrowrtdwn1' => 1047                   , # 0xB0, 0o260, 176
    'quiltsquare2' => 1000                  , # 0xB1, 0o261, 177
    'quiltsquare2inv' => 1000               , # 0xB2, 0o262, 178
    'leafccwsw' => 1000                     , # 0xB3, 0o263, 179
    'leafccwnw' => 1000                     , # 0xB4, 0o264, 180
    'leafccwse' => 1000                     , # 0xB5, 0o265, 181
    'leafccwne' => 1000                     , # 0xB6, 0o266, 182
    'leafnw' => 1000                        , # 0xB7, 0o267, 183
    'leafsw' => 1000                        , # 0xB8, 0o270, 184
    'leafne' => 1000                        , # 0xB9, 0o271, 185
    'leafse' => 1000                        , # 0xBA, 0o272, 186
    'deleteleft' => 1252                    , # 0xBB, 0o273, 187
    'deleteright' => 1252                   , # 0xBC, 0o274, 188
    'head2left' => 794                      , # 0xBD, 0o275, 189
    'head2right' => 794                     , # 0xBE, 0o276, 190
    'head2up' => 891                        , # 0xBF, 0o277, 191
    'head2down' => 891                      , # 0xC0, 0o300, 192
    'circleleft' => 891                     , # 0xC1, 0o301, 193
    'circleright' => 891                    , # 0xC2, 0o302, 194
    'circleup' => 891                       , # 0xC3, 0o303, 195
    'circledown' => 891                     , # 0xC4, 0o304, 196
    'barb2left' => 979                      , # 0xC5, 0o305, 197
    'barb2right' => 979                     , # 0xC6, 0o306, 198
    'barb2up' => 891                        , # 0xC7, 0o307, 199
    'barb2down' => 891                      , # 0xC8, 0o310, 200
    'barb2nw' => 775                        , # 0xC9, 0o311, 201
    'barb2ne' => 775                        , # 0xCA, 0o312, 202
    'barb2sw' => 775                        , # 0xCB, 0o313, 203
    'barb2se' => 775                        , # 0xCC, 0o314, 204
    'barb4left' => 1067                     , # 0xCD, 0o315, 205
    'barb4right' => 1067                    , # 0xCE, 0o316, 206
    'barb4up' => 891                        , # 0xCF, 0o317, 207
    'barb4down' => 891                      , # 0xD0, 0o320, 208
    'barb4nw' => 872                        , # 0xD1, 0o321, 209
    'barb4ne' => 872                        , # 0xD2, 0o322, 210
    'barb4sw' => 872                        , # 0xD3, 0o323, 211
    'barb4se' => 872                        , # 0xD4, 0o324, 212
    'bleft' => 891                          , # 0xD5, 0o325, 213
    'bright' => 891                         , # 0xD6, 0o326, 214
    'bup' => 810                            , # 0xD7, 0o327, 215
    'bdown' => 810                          , # 0xD8, 0o330, 216
    'bleftright' => 1060                    , # 0xD9, 0o331, 217
    'bupdown' => 810                        , # 0xDA, 0o332, 218
    'bnw' => 781                            , # 0xDB, 0o333, 219
    'bne' => 781                            , # 0xDC, 0o334, 220
    'bsw' => 781                            , # 0xDD, 0o335, 221
    'bse' => 781                            , # 0xDE, 0o336, 222
    'bdash1' => 481                         , # 0xDF, 0o337, 223
    'bdash2' => 385                         , # 0xE0, 0o340, 224
    'windowslogo' => 1034                   , # 0xE1, 0o341, 225
  },
};

1;
