# generated at Wed Apr 25 18:38:08 2001

package AFA;
# tohle je automaticky vygenerovany modul na prirazovani funktoru

#################
# hlavicka modulu

use Exporter;
@ISA=(Exporter);
$VERSION = "1.00";
@EXPORT = qw(&AutoFunctor);
use vars qw($VERSION @EXPORT);

#################
# hlavicka funkce

sub AutoFunctor($$$$$) {
 my $tag_gov   = shift; # pozicni morfologicka znacka ridiciho uzlu 
                       # (nebo uzlu nad souradici spojkou)
 my $tag_dep   = shift; # poz. morf. znacka uzlu, jehoz funktor se hleda
 my $afun_gov  = lc(shift); # analyticka funkce ridiciho uzlu
 my $afun_dep  = lc(shift); # analyticka funkce zavisleho uzlu
 my $prep_conj = shift; # predlozka nebo podradici spojka, ktera je "mezi" obema uzly 

###################################
# vyroba vstupnich atributu

 $prep_conj=~tr/áéìíýóúù¾¹èøï»ò/aeeiyouuzscrdtn/;

 $tag_gov=~m/^(.)(.)..(.)......(.)/;
 my $pos_gov=lc($1); 
 my $subpos_gov=$2;  
 my $case_gov=$3; 
 my $voice_gov=lc($4);
 
 $tag_dep=~m/^(.)(.)..(.)......(.)/;
 my $pos_dep=lc($1); 
 my $subpos_dep=$2;  
 my $case_dep=$3; 
 my $voice_dep=lc($4);

##################################
# nahrazeni specialnich znaku zastupnymi retezci 
# (stejnym zpusobem, jak to bylo treba pri preprocesingu pro c4.5 v beautifySubPos.pl)

    $subpos_dep=~s/([A-Z])/$1\_/;
    $subpos_gov=~s/([A-Z])/$1\_/;

    $subpos_dep=~s/\#/spec_hash/;
    $subpos_dep=~s/\*/spec_aster/;
    $subpos_dep=~s/\,/spec_comma/;
    $subpos_dep=~s/\./spec_dot/;
    $subpos_dep=~s/\!/spec_exmark/;
    $subpos_dep=~s/\:/spec_ddot/;
    $subpos_dep=~s/\;/spec_semicol/;
    $subpos_dep=~s/\=/spec_eq/;
    $subpos_dep=~s/\?/spec_qmark/;
    $subpos_dep=~s/\^/spec_head/;
    $subpos_dep=~s/\~/spec_tilda/;
    $subpos_dep=~s/\}/spec_rbrace/;
    $subpos_dep=~s/\@/spec_zavinac/;

    $subpos_gov=~s/\#/spec_hash/;
    $subpos_gov=~s/\*/spec_aster/;
    $subpos_gov=~s/\,/spec_comma/;
    $subpos_gov=~s/\./spec_dot/;
    $subpos_gov=~s/\!/spec_exmark/;
    $subpos_gov=~s/\:/spec_ddot/;
    $subpos_gov=~s/\;/spec_semicol/;
    $subpos_gov=~s/\=/spec_eq/;
    $subpos_gov=~s/\?/spec_qmark/;
    $subpos_gov=~s/\^/spec_head/;
    $subpos_gov=~s/\~/spec_tilda/;
    $subpos_gov=~s/\}/spec_rbrace/;
    $subpos_gov=~s/\@/spec_zavinac/;

    $subpos_gov=lc($subpos_gov);
    $subpos_dep=lc($subpos_dep);
    	
        
   	$prep_conj=~s/^$/empty/;

  	$case_gov=~s/\-/spec_na/; # not assigned    
  	$case_dep=~s/\-/spec_na/; 
  	$voice_gov=~s/\-/spec_na/; 
  	$voice_dep=~s/\-/spec_na/; 
     
my $functor="";
my $prec=0;
my $estimate="";
 
##########################################################################
# nasleduje kod vygenerovany podle rozhodovaciho stromu z c4.5

#print "\n(6:$afun_gov) (10:$prep_conj) (11:$afun_dep) (12:$pos_gov) 
#(13:$subpos_gov) (14:$case_gov) (15:$voice_gov) (16:$pos_dep) 
#(17:$subpos_dep) (18:$case_dep) (19:$voice_dep)\n"; if ($afun_dep eq "atrobj") { $functor="ACMP"; $estimate="(3.0/2.8)"}
 if ($afun_dep eq "atvv") { $functor="COMPL"; $estimate="(21.0/3.7)"}
 if ($afun_dep eq "auxo") { $functor="INTF"; $estimate="(6.0/3.3)"}
 if ($afun_dep eq "auxr") { $functor="ACT"; $estimate="(132.0/3.8)"}
 if ($afun_dep eq "auxt") { $functor="ACT"; $estimate="(1.0/0.8)"}
 if ($afun_dep eq "auxv") { $functor="RSTR"; $estimate="(4.0/3.1)"}
 if ($afun_dep eq "objatr") { $functor="ADDR"; $estimate="(1.0/0.8)"}
 if ($afun_dep eq "adv") {
    if ($prep_conj eq "aby") { $functor="AIM"; $estimate="(16.0/9.8)"}
    if ($prep_conj eq "ac") { $functor="CNCS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "ackoliv") { $functor="CNCS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "aniz") { $functor="CNCS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "at") { $functor="CNCS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "beh") { $functor="TPAR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "behem") { $functor="TPAR"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "bez") { $functor="ACMP"; $estimate="(16.0/1.3)"}
    if ($prep_conj eq "cesta") { $functor="MEANS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "co") { $functor="TWHEN"; $estimate="(4.0/2.2)"}
    if ($prep_conj eq "de") { $functor="MOD"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "dik") { $functor="CAUS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "diky") { $functor="CAUS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "dle") { $functor="NORM"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "do") { $functor="DIR3"; $estimate="(109.0/42.0)"}
    if ($prep_conj eq "forma") { $functor="MEANS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "jak") { $functor="CPR"; $estimate="(5.0/4.1)"}
    if ($prep_conj eq "jakmile") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "jako") { $functor="CPR"; $estimate="(8.0/4.5)"}
    if ($prep_conj eq "jestlize") { $functor="COND"; $estimate="(4.0/1.2)"}
    if ($prep_conj eq "k") { $functor="DIR3"; $estimate="(57.0/36.0)"}
    if ($prep_conj eq "kdyby") { $functor="CTERF"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "konec") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "krome") { $functor="RESTR"; $estimate="(6.0/1.2)"}
    if ($prep_conj eq "kvuli") { $functor="CAUS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "li") { $functor="COND"; $estimate="(7.0/2.4)"}
    if ($prep_conj eq "misto") { $functor="SUBS"; $estimate="(4.0/1.2)"}
    if ($prep_conj eq "nad") { $functor="DIR3"; $estimate="(6.0/5.1)"}
    if ($prep_conj eq "ohled_s_na") { $functor="REG"; $estimate="(4.0/1.2)"}
    if ($prep_conj eq "okolo") { $functor="LOC"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "oproti") { $functor="CPR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pocatek") { $functor="TWHEN"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "podle") { $functor="CRIT"; $estimate="(27.0/13.3)"}
    if ($prep_conj eq "pokud") { $functor="COND"; $estimate="(16.0/4.8)"}
    if ($prep_conj eq "pomoci") { $functor="MEANS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "porovnani_v_k") { $functor="CPR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pred") { $functor="TWHEN"; $estimate="(14.0/6.8)"}
    if ($prep_conj eq "pres") { $functor="MEANS"; $estimate="(5.0/4.1)"}
    if ($prep_conj eq "prestoze") { $functor="CNCS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pri") { $functor="TWHEN"; $estimate="(62.0/25.2)"}
    if ($prep_conj eq "prostrednictvi") { $functor="MEANS"; $estimate="(2.0/1.8)"}
    if ($prep_conj eq "proti") { $functor="BEN"; $estimate="(6.0/5.1)"}
    if ($prep_conj eq "proto") { $functor="PRED"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "protoze") { $functor="CAUS"; $estimate="(25.0/2.5)"}
    if ($prep_conj eq "rozdil_na_od") { $functor="CPR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "rozpor_v_s") { $functor="BEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "s") { $functor="ACMP"; $estimate="(51.0/18.9)"}
    if ($prep_conj eq "s_pomoc") { $functor="MEANS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "soulad_do_s") { $functor="PAT"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "souvislost_v_s") { $functor="ACMP"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "spolecne_s") { $functor="ACMP"; $estimate="(4.0/1.2)"}
    if ($prep_conj eq "spolu_s") { $functor="ACMP"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "spoluprace_v_s") { $functor="ACMP"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "u") { $functor="LOC"; $estimate="(49.0/6.1)"}
    if ($prep_conj eq "v_dusledek") { $functor="CAUS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "v_pripad") { $functor="COND"; $estimate="(3.0/2.1)"}
    if ($prep_conj eq "v_prospech") { $functor="BEN"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "v_prubeh") { $functor="TPAR"; $estimate="(3.0/2.1)"}
    if ($prep_conj eq "v_rada") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "v_ramec") { $functor="APP"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "vcetne") { $functor="ACMP"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "vedle") { $functor="RESTR"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "vuci") { $functor="REG"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "vzdyt") { $functor="PRED"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "vzhledem_k") { $functor="REG"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "zacatek") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "zatimco") { $functor="TPAR"; $estimate="(6.0/1.2)"}
    if ($prep_conj eq "empty") {
       if ($case_dep eq "3") { $functor="BEN"; $estimate="(33.0/13.5)"}
       if ($case_dep eq "x") { $functor="CPR"; $estimate="(1.0/0.8)"}
       if ($case_dep eq "1") {
          if ($subpos_gov eq "a_") { $functor="EXT"; $estimate="(2.0/1.8)"}
          if ($subpos_gov eq "b_") { $functor="PAT"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "g") { $functor="RSTR"; $estimate="(3.0/2.1)"}
          if ($subpos_gov eq "s") { $functor="COMPL"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "spec_ddot") { $functor="DENOM"; $estimate="(1.0/0.8)"}
       } 
       if ($case_dep eq "2") {
          if ($subpos_gov eq "a_") { $functor="CPR"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "f") { $functor="CPR"; $estimate="(3.0/2.8)"}
          if ($subpos_gov eq "n_") { $functor="APP"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "p") { $functor="TWHEN"; $estimate="(5.0/3.2)"}
          if ($subpos_gov eq "s") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "z_") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "b_") {
             if ($afun_gov eq "adv") { $functor="CPR"; $estimate="(2.0/1.8)"}
             if ($afun_gov eq "atr") { $functor="ACMP"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "obj") { $functor="ACMP"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "pred") { $functor="LOC"; $estimate="(4.0/3.1)"}
             if ($afun_gov eq "sb") { $functor="CAUS"; $estimate="(1.0/0.8)"}
       }  } 
       if ($case_dep eq "4") {
          if ($pos_dep eq "a") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($pos_dep eq "c") { $functor="RSTR"; $estimate="(11.0/2.5)"}
          if ($pos_dep eq "r") { $functor="BEN"; $estimate="(1.0/0.8)"}
          if ($pos_dep eq "n") {
             if ($subpos_gov eq "a_") { $functor="THL"; $estimate="(2.0/1.0)"}
             if ($subpos_gov eq "b_") { $functor="THL"; $estimate="(21.0/16.8)"}
             if ($subpos_gov eq "f") { $functor="ADDR"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "g") { $functor="CPR"; $estimate="(4.0/3.1)"}
             if ($subpos_gov eq "i") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "n_") { $functor="THL"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "spec_hash") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "p") {
                if ($afun_gov eq "adv") { $functor="PAT"; $estimate="(1.0/0.8)"}
                if ($afun_gov eq "atr") { $functor="TWHEN"; $estimate="(2.0/1.0)"}
                if ($afun_gov eq "pred") { $functor="THL"; $estimate="(9.0/6.4)"}
          }  } 
          if ($pos_dep eq "p") {
             if ($pos_gov eq "d") { $functor="EXT"; $estimate="(2.0/1.0)"}
             if ($pos_gov eq "n") { $functor="APP"; $estimate="(1.0/0.8)"}
             if ($pos_gov eq "v") { $functor="ADDR"; $estimate="(2.0/1.8)"}
       }  } 
       if ($case_dep eq "6") {
          if ($subpos_gov eq "a_") { $functor="CPR"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "g") { $functor="CPR"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "n_") { $functor="LOC"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "b_") {
             if ($afun_gov eq "obj") { $functor="THO"; $estimate="(2.0/1.0)"}
             if ($afun_gov eq "pred") { $functor="CPR"; $estimate="(3.0/2.8)"}
       }  } 
       if ($case_dep eq "7") {
          if ($pos_dep eq "a") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($pos_dep eq "c") { $functor="THO"; $estimate="(5.0/2.3)"}
          if ($pos_dep eq "n") { $functor="MEANS"; $estimate="(82.0/38.6)"}
          if ($pos_dep eq "p") { $functor="MEANS"; $estimate="(16.0/11.7)"}
       } 
       if ($case_dep eq "spec_na") {
          if ($subpos_dep eq "f") { $functor="INTT"; $estimate="(4.0/3.1)"}
          if ($subpos_dep eq "g") { $functor="MANN"; $estimate="(430.0/260.5)"}
          if ($subpos_dep eq "o") { $functor="EXT"; $estimate="(2.0/1.8)"}
          if ($subpos_dep eq "spec_comma") { $functor="CONJ"; $estimate="(8.0/1.3)"}
          if ($subpos_dep eq "spec_zavinac") { $functor="DPHR"; $estimate="(5.0/4.1)"}
          if ($subpos_dep eq "t_") { $functor="EXT"; $estimate="(8.0/2.4)"}
          if ($subpos_dep eq "x_") { $functor="EXT"; $estimate="(2.0/1.8)"}
          if ($subpos_dep eq "b") {
             if ($pos_gov eq "a") { $functor="EXT"; $estimate="(37.0/18.6)"}
             if ($pos_gov eq "c") { $functor="EXT"; $estimate="(2.0/1.0)"}
             if ($pos_gov eq "d") { $functor="EXT"; $estimate="(17.0/10.9)"}
             if ($pos_gov eq "n") { $functor="RHEM"; $estimate="(22.0/14.1)"}
             if ($pos_gov eq "v") { $functor="TWHEN"; $estimate="(505.0/345.7)"}
             if ($pos_gov eq "z") { $functor="RHEM"; $estimate="(6.0/4.3)"}
          } 
          if ($subpos_dep eq "b_") {
             if ($subpos_gov eq "a_") { $functor="MANN"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "b") { $functor="RSTR"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "b_") { $functor="COND"; $estimate="(10.0/7.5)"}
             if ($subpos_gov eq "n_") { $functor="PRED"; $estimate="(2.0/1.0)"}
             if ($subpos_gov eq "p") { $functor="CAUS"; $estimate="(2.0/1.8)"}
          } 
          if ($subpos_dep eq "p") {
             if ($afun_gov eq "atr") { $functor="DPHR"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "auxg") { $functor="PRED"; $estimate="(3.0/1.1)"}
             if ($afun_gov eq "obj") { $functor="PREC"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "pred") {
                if ($subpos_gov eq "b_") { $functor="AIM"; $estimate="(4.0/3.1)"}
                if ($subpos_gov eq "p") { $functor="CNCS"; $estimate="(2.0/1.8)"}
          }  } 
          if ($subpos_dep eq "spec_eq") {
             if ($subpos_gov eq "f") { $functor="TTILL"; $estimate="(2.0/1.0)"}
             if ($subpos_gov eq "g") { $functor="CPR"; $estimate="(2.0/1.0)"}
             if ($subpos_gov eq "p") { $functor="NORM"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "s") { $functor="LOC"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "spec_ddot") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "n_") {
                if ($afun_gov eq "atr") { $functor="RSTR"; $estimate="(15.0/1.3)"}
                if ($afun_gov eq "auxg") { $functor="RSTR"; $estimate="(2.0/1.0)"}
                if ($afun_gov eq "exd") { $functor="RSTR"; $estimate="(1.0/0.8)"}
                if ($afun_gov eq "pred") { $functor="TWHEN"; $estimate="(5.0/2.3)"}
          }  } 
          if ($subpos_dep eq "v") {
             if ($voice_gov eq "a") { $functor="THO"; $estimate="(4.0/1.2)"}
             if ($voice_gov eq "spec_na") { $functor="EXT"; $estimate="(3.0/1.1)"}
    }  }  } 
    if ($prep_conj eq "kdyz") {
       if ($subpos_dep eq "b_") { $functor="COND"; $estimate="(11.0/5.6)"}
       if ($subpos_dep eq "p") { $functor="TWHEN"; $estimate="(8.0/3.5)"}
       if ($subpos_dep eq "s") { $functor="COND"; $estimate="(1.0/0.8)"}
    } 
    if ($prep_conj eq "kolem") {
       if ($subpos_dep eq "n_") { $functor="EXT"; $estimate="(6.0/4.3)"}
       if ($subpos_dep eq "p_") { $functor="LOC"; $estimate="(3.0/1.1)"}
    } 
    if ($prep_conj eq "mezi") {
       if ($case_dep eq "4") { $functor="DIR3"; $estimate="(3.0/1.1)"}
       if ($case_dep eq "7") { $functor="LOC"; $estimate="(11.0/3.6)"}
    } 
    if ($prep_conj eq "mimo") {
       if ($pos_dep eq "a") { $functor="RESTR"; $estimate="(3.0/1.1)"}
       if ($pos_dep eq "n") { $functor="DPHR"; $estimate="(2.0/1.8)"}
    } 
    if ($prep_conj eq "na") {
       if ($case_dep eq "4") { $functor="DIR3"; $estimate="(71.0/43.3)"}
       if ($case_dep eq "6") { $functor="LOC"; $estimate="(76.0/18.1)"}
       if ($case_dep eq "spec_na") { $functor="PAT"; $estimate="(4.0/3.1)"}
    } 
    if ($prep_conj eq "na_zaklad") {
       if ($pos_gov eq "n") { $functor="CRIT"; $estimate="(2.0/1.8)"}
       if ($pos_gov eq "v") { $functor="NORM"; $estimate="(2.0/1.0)"}
    } 
    if ($prep_conj eq "nez") {
       if ($voice_gov eq "a") { $functor="TWHEN"; $estimate="(3.0/2.1)"}
       if ($voice_gov eq "spec_na") { $functor="CPR"; $estimate="(22.0/1.3)"}
    } 
    if ($prep_conj eq "o") {
       if ($pos_dep eq "d") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($pos_dep eq "n") { $functor="TWHEN"; $estimate="(3.0/2.1)"}
       if ($pos_dep eq "x") { $functor="DIFF"; $estimate="(1.0/0.8)"}
       if ($pos_dep eq "c") {
          if ($voice_gov eq "a") { $functor="DIFF"; $estimate="(2.0/1.0)"}
          if ($voice_gov eq "spec_na") { $functor="EXT"; $estimate="(2.0/1.8)"}
    }  } 
    if ($prep_conj eq "od") {
       if ($pos_dep eq "n") { $functor="TSIN"; $estimate="(21.0/9.1)"}
       if ($pos_dep eq "p") { $functor="ORIG"; $estimate="(2.0/1.0)"}
       if ($pos_dep eq "x") { $functor="DIR1"; $estimate="(1.0/0.8)"}
    } 
    if ($prep_conj eq "po") {
       if ($case_dep eq "4") { $functor="LOC"; $estimate="(2.0/1.8)"}
       if ($case_dep eq "6") { $functor="TWHEN"; $estimate="(36.0/13.5)"}
    } 
    if ($prep_conj eq "pod") {
       if ($voice_gov eq "a") { $functor="DIR3"; $estimate="(3.0/2.8)"}
       if ($voice_gov eq "spec_na") { $functor="REG"; $estimate="(2.0/1.8)"}
    } 
    if ($prep_conj eq "pro") {
       if ($case_gov eq "1") { $functor="BEN"; $estimate="(3.0/1.1)"}
       if ($case_gov eq "2") { $functor="RSTR"; $estimate="(3.0/2.1)"}
       if ($case_gov eq "4") { $functor="AIM"; $estimate="(3.0/1.1)"}
       if ($case_gov eq "spec_na") { $functor="BEN"; $estimate="(60.0/23.1)"}
    } 
    if ($prep_conj eq "takze") {
       if ($pos_gov eq "j") { $functor="PRED"; $estimate="(3.0/1.1)"}
       if ($pos_gov eq "v") { $functor="CSQ"; $estimate="(2.0/1.0)"}
    } 
    if ($prep_conj eq "v") {
       if ($case_dep eq "4") { $functor="TWHEN"; $estimate="(11.0/3.6)"}
       if ($case_dep eq "6") { $functor="LOC"; $estimate="(362.0/137.9)"}
       if ($case_dep eq "spec_na") { $functor="LOC"; $estimate="(2.0/1.0)"}
       if ($case_dep eq "x") { $functor="LOC"; $estimate="(1.0/0.8)"}
    } 
    if ($prep_conj eq "z") {
       if ($pos_gov eq "a") { $functor="DIR1"; $estimate="(4.0/2.2)"}
       if ($pos_gov eq "j") { $functor="ORIG"; $estimate="(3.0/1.1)"}
       if ($pos_gov eq "n") { $functor="DIR2"; $estimate="(1.0/0.8)"}
       if ($pos_gov eq "v") { $functor="DIR1"; $estimate="(55.0/22.0)"}
    } 
    if ($prep_conj eq "za") {
       if ($case_dep eq "7") { $functor="LOC"; $estimate="(3.0/2.1)"}
       if ($case_dep eq "2") {
          if ($voice_gov eq "a") { $functor="COND"; $estimate="(3.0/1.1)"}
          if ($voice_gov eq "spec_na") { $functor="PAT"; $estimate="(2.0/1.8)"}
       } 
       if ($case_dep eq "4") {
          if ($subpos_gov eq "b_") { $functor="SUBS"; $estimate="(6.0/2.3)"}
          if ($subpos_gov eq "f") { $functor="MANN"; $estimate="(3.0/2.8)"}
          if ($subpos_gov eq "n_") { $functor="PAT"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "p") { $functor="THL"; $estimate="(8.0/5.4)"}
          if ($subpos_gov eq "s") { $functor="SUBS"; $estimate="(2.0/1.8)"}
    }  } 
    if ($prep_conj eq "ze") {
       if ($afun_gov eq "adv") { $functor="RSTR"; $estimate="(3.0/2.1)"}
       if ($afun_gov eq "atr") { $functor="EFF"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "obj") { $functor="CAUS"; $estimate="(3.0/2.1)"}
       if ($afun_gov eq "pred") { $functor="CAUS"; $estimate="(5.0/3.2)"}
 }  } 
 if ($afun_dep eq "advatr") {
    if ($prep_conj eq "do") { $functor="EXT"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "k") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "po") { $functor="PAT"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pro") { $functor="AIM"; $estimate="(2.0/1.8)"}
    if ($prep_conj eq "s") { $functor="ACMP"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "u") { $functor="LOC"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "v") { $functor="LOC"; $estimate="(1.0/0.8)"}
 } 
 if ($afun_dep eq "atr") {
    if ($prep_conj eq "aby") { $functor="AIM"; $estimate="(8.0/4.5)"}
    if ($prep_conj eq "behem") { $functor="TPAR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "bez") { $functor="ACMP"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "celo_v_s") { $functor="ACMP"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "de") { $functor="APP"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "do") { $functor="DIR3"; $estimate="(36.0/10.4)"}
    if ($prep_conj eq "forum") { $functor="BEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "jako") { $functor="CPR"; $estimate="(2.0/1.8)"}
    if ($prep_conj eq "k_konec") { $functor="LOC"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "kdyz") { $functor="RSTR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "mezi") { $functor="LOC"; $estimate="(18.0/2.5)"}
    if ($prep_conj eq "mimo") { $functor="LOC"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "na_zaklad") { $functor="NORM"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "nad") { $functor="LOC"; $estimate="(9.0/4.5)"}
    if ($prep_conj eq "oblast_v") { $functor="LOC"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "okolo") { $functor="RSTR"; $estimate="(3.0/2.1)"}
    if ($prep_conj eq "po") { $functor="TWHEN"; $estimate="(15.0/11.6)"}
    if ($prep_conj eq "pod") { $functor="DIR3"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "podle") { $functor="CRIT"; $estimate="(2.0/1.8)"}
    if ($prep_conj eq "pomoci") { $functor="MEANS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "postupem") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pred") { $functor="TWHEN"; $estimate="(6.0/4.3)"}
    if ($prep_conj eq "pres") { $functor="EXT"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "pro") { $functor="BEN"; $estimate="(75.0/31.5)"}
    if ($prep_conj eq "prostrednictvi") { $functor="MEANS"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "proti") { $functor="BEN"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "s") { $functor="ACMP"; $estimate="(52.0/24.0)"}
    if ($prep_conj eq "soulad_v_s") { $functor="RSTR"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "u") { $functor="LOC"; $estimate="(11.0/1.3)"}
    if ($prep_conj eq "v") { $functor="LOC"; $estimate="(163.0/26.8)"}
    if ($prep_conj eq "v_zaveru") { $functor="APP"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "v_dusledek") { $functor="CAUS"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "v_ramec") { $functor="LOC"; $estimate="(2.0/1.8)"}
    if ($prep_conj eq "vcetne") { $functor="ACMP"; $estimate="(3.0/1.1)"}
    if ($prep_conj eq "vedle") { $functor="LOC"; $estimate="(1.0/0.8)"}
    if ($prep_conj eq "versus") { $functor="DENOM"; $estimate="(3.0/2.1)"}
    if ($prep_conj eq "vuci") { $functor="REG"; $estimate="(4.0/1.2)"}
    if ($prep_conj eq "z") { $functor="DIR1"; $estimate="(88.0/12.8)"}
    if ($prep_conj eq "zda") { $functor="PAT"; $estimate="(2.0/1.0)"}
    if ($prep_conj eq "empty") {
       if ($pos_dep eq "a") { $functor="RSTR"; $estimate="(3028.0/67.1)"}
       if ($pos_dep eq "c") { $functor="RSTR"; $estimate="(514.0/30.2)"}
       if ($pos_dep eq "j") { $functor="RSTR"; $estimate="(2.0/1.0)"}
       if ($pos_dep eq "r") { $functor="ID"; $estimate="(1.0/0.8)"}
       if ($pos_dep eq "d") {
          if ($case_gov eq "1") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($case_gov eq "4") { $functor="RSTR"; $estimate="(3.0/1.1)"}
          if ($case_gov eq "6") { $functor="EXT"; $estimate="(1.0/0.8)"}
          if ($case_gov eq "7") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
          if ($case_gov eq "spec_na") { $functor="RHEM"; $estimate="(2.0/1.0)"}
          if ($case_gov eq "x") { $functor="ATT"; $estimate="(1.0/0.8)"}
          if ($case_gov eq "2") {
             if ($subpos_dep eq "b") { $functor="MANN"; $estimate="(2.0/1.8)"}
             if ($subpos_dep eq "g") { $functor="RSTR"; $estimate="(6.0/4.3)"}
       }  } 
       if ($pos_dep eq "n") {
          if ($case_dep eq "3") { $functor="ADDR"; $estimate="(14.0/6.8)"}
          if ($case_dep eq "5") { $functor="RSTR"; $estimate="(4.0/2.2)"}
          if ($case_dep eq "1") {
             if ($case_gov eq "1") { $functor="RSTR"; $estimate="(153.0/37.2)"}
             if ($case_gov eq "3") { $functor="ID"; $estimate="(4.0/1.2)"}
             if ($case_gov eq "4") { $functor="ID"; $estimate="(13.0/2.5)"}
             if ($case_gov eq "6") { $functor="ID"; $estimate="(14.0/2.5)"}
             if ($case_gov eq "7") { $functor="ID"; $estimate="(4.0/2.2)"}
             if ($case_gov eq "2") {
                if ($afun_gov eq "adv") { $functor="ID"; $estimate="(2.0/1.0)"}
                if ($afun_gov eq "atr") { $functor="ID"; $estimate="(30.0/11.3)"}
                if ($afun_gov eq "exd") { $functor="RSTR"; $estimate="(2.0/1.0)"}
                if ($afun_gov eq "sb") { $functor="RSTR"; $estimate="(4.0/1.2)"}
             } 
             if ($case_gov eq "spec_na") {
                if ($pos_gov eq "v") { $functor="ACT"; $estimate="(7.0/4.4)"}
                if ($pos_gov eq "x") { $functor="RSTR"; $estimate="(53.0/6.1)"}
                if ($pos_gov eq "z") { $functor="DENOM"; $estimate="(21.0/7.0)"}
             } 
             if ($case_gov eq "x") {
                if ($afun_gov eq "auxg") { $functor="DENOM"; $estimate="(5.0/2.3)"}
                if ($afun_gov eq "auxx") { $functor="ACT"; $estimate="(17.0/9.9)"}
          }  } 
          if ($case_dep eq "2") {
             if ($pos_gov eq "a") { $functor="EXT"; $estimate="(3.0/2.8)"}
             if ($pos_gov eq "c") { $functor="MAT"; $estimate="(11.0/2.5)"}
             if ($pos_gov eq "d") { $functor="ACT"; $estimate="(2.0/1.8)"}
             if ($pos_gov eq "v") { $functor="PAT"; $estimate="(118.0/62.3)"}
             if ($pos_gov eq "x") { $functor="RSTR"; $estimate="(8.0/5.4)"}
             if ($pos_gov eq "z") { $functor="MAT"; $estimate="(10.0/5.6)"}
             if ($pos_gov eq "n") {
                if ($case_gov eq "1") { $functor="PAT"; $estimate="(444.0/274.6)"}
                if ($case_gov eq "2") { $functor="APP"; $estimate="(354.0/239.6)"}
                if ($case_gov eq "3") { $functor="PAT"; $estimate="(61.0/27.2)"}
                if ($case_gov eq "6") { $functor="PAT"; $estimate="(186.0/105.2)"}
                if ($case_gov eq "4") {
                   if ($afun_gov eq "adv") { $functor="APP"; $estimate="(30.0/21.2)"}
                   if ($afun_gov eq "advatr") { $functor="PAT"; $estimate="(1.0/0.8)"}
                   if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(70.0/32.4)"}
                   if ($afun_gov eq "atradv") { $functor="PAT"; $estimate="(2.0/1.0)"}
                   if ($afun_gov eq "atrobj") { $functor="APP"; $estimate="(1.0/0.8)"}
                   if ($afun_gov eq "atvv") { $functor="APP"; $estimate="(1.0/0.8)"}
                   if ($afun_gov eq "exd") { $functor="APP"; $estimate="(5.0/4.1)"}
                   if ($afun_gov eq "obj") { $functor="APP"; $estimate="(195.0/133.0)"}
                   if ($afun_gov eq "sb") { $functor="APP"; $estimate="(3.0/2.8)"}
                } 
                if ($case_gov eq "7") {
                   if ($afun_gov eq "adv") { $functor="PAT"; $estimate="(38.0/18.6)"}
                   if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(17.0/9.9)"}
                   if ($afun_gov eq "exd") { $functor="MAT"; $estimate="(3.0/2.1)"}
                   if ($afun_gov eq "obj") { $functor="PAT"; $estimate="(40.0/21.7)"}
                   if ($afun_gov eq "pnom") { $functor="APP"; $estimate="(34.0/13.5)"}
                } 
                if ($case_gov eq "x") {
                   if ($afun_gov eq "atr") { $functor="MAT"; $estimate="(11.0/5.6)"}
                   if ($afun_gov eq "auxx") { $functor="DIR3"; $estimate="(1.0/0.8)"}
                   if ($afun_gov eq "obj") { $functor="MAT"; $estimate="(1.0/0.8)"}
                   if ($afun_gov eq "sb") { $functor="APP"; $estimate="(2.0/1.0)"}
          }  }  } 
          if ($case_dep eq "4") {
             if ($pos_gov eq "a") { $functor="REG"; $estimate="(1.0/0.8)"}
             if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(17.0/11.8)"}
             if ($pos_gov eq "p") { $functor="PAT"; $estimate="(1.0/0.8)"}
             if ($pos_gov eq "v") { $functor="PAT"; $estimate="(7.0/3.4)"}
             if ($pos_gov eq "x") { $functor="RSTR"; $estimate="(6.0/1.2)"}
             if ($pos_gov eq "z") { $functor="BEN"; $estimate="(2.0/1.0)"}
          } 
          if ($case_dep eq "6") {
             if ($afun_gov eq "adv") { $functor="ID"; $estimate="(2.0/1.8)"}
             if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(4.0/3.1)"}
             if ($afun_gov eq "auxx") { $functor="PAT"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "exd") { $functor="PAT"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "obj") { $functor="ACT"; $estimate="(2.0/1.8)"}
             if ($afun_gov eq "pred") { $functor="LOC"; $estimate="(1.0/0.8)"}
             if ($afun_gov eq "sb") { $functor="RSTR"; $estimate="(4.0/2.2)"}
          } 
          if ($case_dep eq "7") {
             if ($case_gov eq "1") { $functor="LOC"; $estimate="(5.0/4.1)"}
             if ($case_gov eq "2") { $functor="APP"; $estimate="(1.0/0.8)"}
             if ($case_gov eq "4") { $functor="MEANS"; $estimate="(4.0/3.1)"}
             if ($case_gov eq "6") { $functor="ACMP"; $estimate="(2.0/1.8)"}
             if ($case_gov eq "7") { $functor="RSTR"; $estimate="(16.0/3.7)"}
             if ($case_gov eq "spec_na") { $functor="ACMP"; $estimate="(2.0/1.8)"}
             if ($case_gov eq "x") { $functor="ACMP"; $estimate="(3.0/2.1)"}
          } 
          if ($case_dep eq "x") {
             if ($subpos_gov eq "b_") { $functor="PAT"; $estimate="(9.0/3.5)"}
             if ($subpos_gov eq "n_") { $functor="APP"; $estimate="(16.0/10.8)"}
             if ($subpos_gov eq "p") { $functor="ACT"; $estimate="(1.0/0.8)"}
             if ($subpos_gov eq "x_") { $functor="DPHR"; $estimate="(1.0/0.8)"}
       }  } 
       if ($pos_dep eq "p") {
          if ($subpos_dep eq "1") { $functor="APP"; $estimate="(3.0/2.1)"}
          if ($subpos_dep eq "8") { $functor="APP"; $estimate="(76.0/11.7)"}
          if ($subpos_dep eq "d_") { $functor="RSTR"; $estimate="(143.0/2.6)"}
          if ($subpos_dep eq "h_") { $functor="MAT"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "j_") { $functor="APP"; $estimate="(4.0/2.2)"}
          if ($subpos_dep eq "l_") { $functor="RSTR"; $estimate="(35.0/3.8)"}
          if ($subpos_dep eq "s_") { $functor="APP"; $estimate="(165.0/33.1)"}
          if ($subpos_dep eq "w_") { $functor="RSTR"; $estimate="(11.0/1.3)"}
          if ($subpos_dep eq "z_") { $functor="RSTR"; $estimate="(49.0/3.8)"}
          if ($subpos_dep eq "4") {
             if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(24.0/1.3)"}
             if ($pos_gov eq "v") { $functor="PAT"; $estimate="(3.0/1.1)"}
          } 
          if ($subpos_dep eq "p_") {
             if ($afun_gov eq "atr") { $functor="MAT"; $estimate="(2.0/1.8)"}
             if ($afun_gov eq "pred") { $functor="PAT"; $estimate="(2.0/1.0)"}
             if ($afun_gov eq "sb") { $functor="MAT"; $estimate="(2.0/1.0)"}
       }  } 
       if ($pos_dep eq "t") {
          if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(2.0/1.0)"}
          if ($afun_gov eq "sb") { $functor="RSTR"; $estimate="(4.0/1.2)"}
       } 
       if ($pos_dep eq "v") {
          if ($subpos_gov eq "a_") { $functor="RSTR"; $estimate="(4.0/1.2)"}
          if ($subpos_gov eq "b") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($subpos_gov eq "b_") { $functor="PAT"; $estimate="(5.0/3.2)"}
          if ($subpos_gov eq "d_") { $functor="RSTR"; $estimate="(10.0/1.3)"}
          if ($subpos_gov eq "f") { $functor="PAT"; $estimate="(7.0/4.4)"}
          if ($subpos_gov eq "i") { $functor="EFF"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "n_") { $functor="RSTR"; $estimate="(357.0/34.4)"}
          if ($subpos_gov eq "p") { $functor="PAT"; $estimate="(9.0/2.4)"}
          if ($subpos_gov eq "s") { $functor="RSTR"; $estimate="(3.0/1.1)"}
          if ($subpos_gov eq "spec_hash") { $functor="PRED"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "spec_zavinac") { $functor="RSTR"; $estimate="(4.0/1.2)"}
          if ($subpos_gov eq "spec_ddot") {
             if ($voice_dep eq "a") { $functor="RSTR"; $estimate="(4.0/2.2)"}
             if ($voice_dep eq "spec_na") { $functor="ACT"; $estimate="(3.0/1.1)"}
       }  } 
       if ($pos_dep eq "x") {
          if ($pos_gov eq "a") { $functor="RSTR"; $estimate="(1.0/0.8)"}
          if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(104.0/63.0)"}
          if ($pos_gov eq "v") { $functor="PAT"; $estimate="(4.0/2.2)"}
          if ($pos_gov eq "x") { $functor="RSTR"; $estimate="(32.0/3.8)"}
          if ($pos_gov eq "z") { $functor="DENOM"; $estimate="(4.0/1.2)"}
       } 
       if ($pos_dep eq "z") {
          if ($pos_gov eq "d") { $functor="DIFF"; $estimate="(1.0/0.8)"}
          if ($pos_gov eq "n") { $functor="EXT"; $estimate="(3.0/2.8)"}
          if ($pos_gov eq "v") { $functor="PAT"; $estimate="(2.0/1.0)"}
    }  } 
    if ($prep_conj eq "jak") {
       if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(2.0/1.0)"}
       if ($pos_gov eq "v") { $functor="ACT"; $estimate="(2.0/1.8)"}
    } 
    if ($prep_conj eq "k") {
       if ($afun_gov eq "adv") { $functor="DIR3"; $estimate="(4.0/1.2)"}
       if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(8.0/3.5)"}
       if ($afun_gov eq "exd") { $functor="DIR3"; $estimate="(8.0/1.3)"}
       if ($afun_gov eq "obj") { $functor="PAT"; $estimate="(9.0/5.5)"}
       if ($afun_gov eq "pnom") { $functor="AIM"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "sb") {
          if ($case_dep eq "1") { $functor="DIR1"; $estimate="(2.0/1.8)"}
          if ($case_dep eq "3") { $functor="PAT"; $estimate="(6.0/3.3)"}
    }  } 
    if ($prep_conj eq "kolem") {
       if ($pos_gov eq "n") { $functor="ACT"; $estimate="(2.0/1.8)"}
       if ($pos_gov eq "v") { $functor="PAT"; $estimate="(3.0/1.1)"}
    } 
    if ($prep_conj eq "na") {
       if ($case_dep eq "2") { $functor="DIR3"; $estimate="(9.0/7.3)"}
       if ($case_dep eq "4") { $functor="PAT"; $estimate="(86.0/38.7)"}
       if ($case_dep eq "6") { $functor="LOC"; $estimate="(45.0/12.6)"}
       if ($case_dep eq "spec_na") { $functor="DIR3"; $estimate="(2.0/1.8)"}
       if ($case_dep eq "x") { $functor="EFF"; $estimate="(3.0/2.1)"}
    } 
    if ($prep_conj eq "nez") {
       if ($pos_gov eq "c") { $functor="MAT"; $estimate="(2.0/1.0)"}
       if ($pos_gov eq "d") { $functor="CPR"; $estimate="(2.0/1.0)"}
       if ($pos_gov eq "v") { $functor="ACT"; $estimate="(2.0/1.8)"}
    } 
    if ($prep_conj eq "o") {
       if ($subpos_gov eq "b_") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($subpos_gov eq "f") { $functor="DIFF"; $estimate="(2.0/1.8)"}
       if ($subpos_gov eq "g") { $functor="DIFF"; $estimate="(3.0/1.1)"}
       if ($subpos_gov eq "l_") { $functor="DPHR"; $estimate="(1.0/0.8)"}
       if ($subpos_gov eq "n_") { $functor="PAT"; $estimate="(90.0/5.0)"}
       if ($subpos_gov eq "p") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($subpos_gov eq "spec_hash") { $functor="PAT"; $estimate="(1.0/0.8)"}
    } 
    if ($prep_conj eq "od") {
       if ($case_gov eq "1") { $functor="DIR1"; $estimate="(3.0/2.8)"}
       if ($case_gov eq "2") { $functor="TSIN"; $estimate="(5.0/2.3)"}
       if ($case_gov eq "4") { $functor="DIR1"; $estimate="(1.0/0.8)"}
       if ($case_gov eq "7") { $functor="TSIN"; $estimate="(2.0/1.0)"}
       if ($case_gov eq "spec_na") { $functor="ADDR"; $estimate="(2.0/1.0)"}
    } 
    if ($prep_conj eq "pri") {
       if ($afun_gov eq "atr") { $functor="LOC"; $estimate="(7.0/3.4)"}
       if ($afun_gov eq "obj") { $functor="COND"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "pnom") { $functor="TWHEN"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "pred") { $functor="COND"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "sb") { $functor="TWHEN"; $estimate="(2.0/1.0)"}
    } 
    if ($prep_conj eq "za") {
       if ($case_dep eq "2") { $functor="COND"; $estimate="(4.0/3.8)"}
       if ($case_dep eq "4") { $functor="PAT"; $estimate="(20.0/12.0)"}
       if ($case_dep eq "7") { $functor="DIR3"; $estimate="(1.0/0.8)"}
       if ($case_dep eq "spec_na") { $functor="EXT"; $estimate="(1.0/0.8)"}
    } 
    if ($prep_conj eq "ze") {
       if ($pos_gov eq "a") { $functor="DIFF"; $estimate="(1.0/0.8)"}
       if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(30.0/13.4)"}
       if ($pos_gov eq "v") { $functor="PAT"; $estimate="(17.0/9.9)"}
 }  } 
 if ($afun_dep eq "atradv") {
    if ($case_dep eq "2") { $functor="TPAR"; $estimate="(1.0/0.8)"}
    if ($case_dep eq "4") { $functor="BEN"; $estimate="(9.0/5.5)"}
    if ($case_dep eq "7") { $functor="LOC"; $estimate="(1.0/0.8)"}
    if ($case_dep eq "spec_na") { $functor="RSTR"; $estimate="(4.0/3.1)"}
    if ($case_dep eq "3") {
       if ($prep_conj eq "empty") { $functor="ADDR"; $estimate="(2.0/1.0)"}
       if ($prep_conj eq "k") { $functor="PAT"; $estimate="(3.0/2.1)"}
    } 
    if ($case_dep eq "6") {
       if ($prep_conj eq "na") { $functor="LOC"; $estimate="(5.0/1.2)"}
       if ($prep_conj eq "pri") { $functor="TWHEN"; $estimate="(2.0/1.0)"}
       if ($prep_conj eq "v") { $functor="LOC"; $estimate="(9.0/2.4)"}
 }  } 
 if ($afun_dep eq "atratr") {
    if ($case_dep eq "2") { $functor="ORIG"; $estimate="(1.0/0.8)"}
    if ($case_dep eq "3") { $functor="AIM"; $estimate="(1.0/0.8)"}
    if ($case_dep eq "4") { $functor="PAT"; $estimate="(1.0/0.8)"}
    if ($case_dep eq "6") { $functor="LOC"; $estimate="(10.0/3.5)"}
    if ($case_dep eq "7") { $functor="ADDR"; $estimate="(3.0/2.8)"}
    if ($case_dep eq "spec_na") { $functor="RSTR"; $estimate="(2.0/1.8)"}
 } 
 if ($afun_dep eq "atv") {
    if ($pos_gov eq "n") { $functor="RSTR"; $estimate="(3.0/1.1)"}
    if ($pos_gov eq "p") { $functor="RSTR"; $estimate="(2.0/1.0)"}
    if ($pos_gov eq "v") { $functor="COMPL"; $estimate="(33.0/9.3)"}
    if ($pos_gov eq "z") { $functor="PRED"; $estimate="(5.0/2.3)"}
 } 
 if ($afun_dep eq "auxy") {
    if ($subpos_dep eq "b") { $functor="RHEM"; $estimate="(83.0/49.6)"}
    if ($subpos_dep eq "c_") { $functor="RHEM"; $estimate="(1.0/0.8)"}
    if ($subpos_dep eq "d_") { $functor="APPS"; $estimate="(1.0/0.8)"}
    if ($subpos_dep eq "spec_comma") { $functor="APPS"; $estimate="(3.0/2.1)"}
    if ($subpos_dep eq "spec_head") { $functor="PREC"; $estimate="(49.0/21.9)"}
    if ($subpos_dep eq "t_") { $functor="RHEM"; $estimate="(13.0/7.7)"}
    if ($subpos_dep eq "g") {
       if ($subpos_gov eq "b_") { $functor="ATT"; $estimate="(16.0/11.7)"}
       if ($subpos_gov eq "f") { $functor="PREC"; $estimate="(1.0/0.8)"}
       if ($subpos_gov eq "s") { $functor="MOD"; $estimate="(2.0/1.0)"}
 }  } 
 if ($afun_dep eq "auxz") {
    if ($pos_gov eq "a") { $functor="RHEM"; $estimate="(10.0/3.5)"}
    if ($pos_gov eq "c") { $functor="EXT"; $estimate="(14.0/2.5)"}
    if ($pos_gov eq "d") { $functor="EXT"; $estimate="(5.0/3.2)"}
    if ($pos_gov eq "j") { $functor="RHEM"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "n") { $functor="RHEM"; $estimate="(122.0/18.2)"}
    if ($pos_gov eq "p") { $functor="RHEM"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "t") { $functor="RHEM"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "v") { $functor="RHEM"; $estimate="(284.0/23.7)"}
    if ($pos_gov eq "x") { $functor="RHEM"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "z") { $functor="RHEM"; $estimate="(6.0/2.3)"}
 } 
 if ($afun_dep eq "exd") {
    if ($pos_gov eq "a") { $functor="CPR"; $estimate="(4.0/2.2)"}
    if ($pos_gov eq "d") { $functor="PAT"; $estimate="(10.0/3.5)"}
    if ($pos_gov eq "p") { $functor="RSTR"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "x") { $functor="RSTR"; $estimate="(3.0/2.1)"}
    if ($pos_gov eq "n") {
       if ($case_gov eq "4") { $functor="RSTR"; $estimate="(7.0/2.4)"}
       if ($case_gov eq "6") { $functor="PAR"; $estimate="(3.0/1.1)"}
       if ($case_gov eq "x") { $functor="DENOM"; $estimate="(37.0/12.5)"}
       if ($case_gov eq "1") {
          if ($case_dep eq "1") { $functor="APP"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "2") { $functor="PAT"; $estimate="(2.0/1.8)"}
          if ($case_dep eq "spec_na") { $functor="PAR"; $estimate="(22.0/1.3)"}
       } 
       if ($case_gov eq "2") {
          if ($pos_dep eq "a") { $functor="MAT"; $estimate="(1.0/0.8)"}
          if ($pos_dep eq "c") { $functor="RSTR"; $estimate="(10.0/1.3)"}
          if ($pos_dep eq "d") { $functor="THO"; $estimate="(1.0/0.8)"}
          if ($pos_dep eq "n") { $functor="CPR"; $estimate="(3.0/2.8)"}
    }  } 
    if ($pos_gov eq "v") {
       if ($prep_conj eq "do") { $functor="DIR3"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "jako") { $functor="CPR"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "nez") { $functor="EXT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "od") { $functor="TSIN"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "v") { $functor="LOC"; $estimate="(4.0/2.2)"}
       if ($prep_conj eq "vcetne") { $functor="ACMP"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "z") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "empty") {
          if ($subpos_dep eq "4") { $functor="PAT"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "a_") { $functor="ADDR"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "b") { $functor="APPS"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "g") { $functor="ACT"; $estimate="(2.0/1.8)"}
          if ($subpos_dep eq "l") { $functor="ACT"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "n_") { $functor="PAT"; $estimate="(4.0/3.1)"}
          if ($subpos_dep eq "s") { $functor="PAR"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "spec_comma") { $functor="PREC"; $estimate="(1.0/0.8)"}
          if ($subpos_dep eq "spec_eq") { $functor="PAR"; $estimate="(10.0/1.3)"}
    }  } 
    if ($pos_gov eq "z") {
       if ($pos_dep eq "a") { $functor="DENOM"; $estimate="(3.0/1.1)"}
       if ($pos_dep eq "d") { $functor="ATT"; $estimate="(2.0/1.8)"}
       if ($pos_dep eq "p") { $functor="DENOM"; $estimate="(2.0/1.0)"}
       if ($pos_dep eq "v") { $functor="PRED"; $estimate="(8.0/2.4)"}
       if ($pos_dep eq "x") { $functor="DENOM"; $estimate="(33.0/1.4)"}
       if ($pos_dep eq "z") { $functor="CONJ"; $estimate="(2.0/1.0)"}
       if ($pos_dep eq "c") {
          if ($subpos_gov eq "spec_ddot") { $functor="RSTR"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "spec_hash") { $functor="DENOM"; $estimate="(18.0/11.9)"}
       } 
       if ($pos_dep eq "n") {
          if ($case_dep eq "1") { $functor="DENOM"; $estimate="(286.0/14.0)"}
          if ($case_dep eq "2") { $functor="DENOM"; $estimate="(2.0/1.0)"}
          if ($case_dep eq "4") { $functor="DENOM"; $estimate="(3.0/1.1)"}
          if ($case_dep eq "5") { $functor="DENOM"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "6") { $functor="LOC"; $estimate="(2.0/1.0)"}
          if ($case_dep eq "7") { $functor="DENOM"; $estimate="(2.0/1.8)"}
          if ($case_dep eq "x") { $functor="APPS"; $estimate="(12.0/5.7)"}
 }  }  } 
 if ($afun_dep eq "obj") {
    if ($pos_gov eq "a") { $functor="PAT"; $estimate="(74.0/25.3)"}
    if ($pos_gov eq "c") { $functor="RSTR"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "d") { $functor="PAT"; $estimate="(3.0/2.1)"}
    if ($pos_gov eq "p") { $functor="RSTR"; $estimate="(3.0/2.1)"}
    if ($pos_gov eq "t") { $functor="PAT"; $estimate="(2.0/1.0)"}
    if ($pos_gov eq "x") { $functor="PAT"; $estimate="(2.0/1.8)"}
    if ($pos_gov eq "j") {
       if ($afun_gov eq "adv") { $functor="COND"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "auxc") { $functor="PRED"; $estimate="(2.0/1.0)"}
       if ($afun_gov eq "auxy") { $functor="NA"; $estimate="(2.0/1.0)"}
       if ($afun_gov eq "auxz") { $functor="PAT"; $estimate="(2.0/1.0)"}
    } 
    if ($pos_gov eq "n") {
       if ($afun_gov eq "adv") { $functor="MANN"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "atr") { $functor="RSTR"; $estimate="(72.0/6.1)"}
       if ($afun_gov eq "auxx") { $functor="ADDR"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "pred") { $functor="ACT"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "sb") { $functor="APP"; $estimate="(2.0/1.8)"}
       if ($afun_gov eq "obj") {
          if ($case_dep eq "2") { $functor="MAT"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "4") { $functor="PAT"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "7") { $functor="ACT"; $estimate="(2.0/1.8)"}
          if ($case_dep eq "spec_na") { $functor="RSTR"; $estimate="(5.0/1.2)"}
    }  } 
    if ($pos_gov eq "v") {
       if ($prep_conj eq "aby") { $functor="PAT"; $estimate="(5.0/1.2)"}
       if ($prep_conj eq "bez") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "jak") { $functor="PAT"; $estimate="(2.0/1.0)"}
       if ($prep_conj eq "k") { $functor="PAT"; $estimate="(31.0/16.4)"}
       if ($prep_conj eq "mezi") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "na") { $functor="PAT"; $estimate="(59.0/19.0)"}
       if ($prep_conj eq "nad") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "o") { $functor="PAT"; $estimate="(98.0/5.0)"}
       if ($prep_conj eq "o_pro") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "od") { $functor="ORIG"; $estimate="(9.0/3.5)"}
       if ($prep_conj eq "pomoci") { $functor="MEANS"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "pred") { $functor="EFF"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "pres") { $functor="DPHR"; $estimate="(2.0/1.0)"}
       if ($prep_conj eq "proto") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($prep_conj eq "s") { $functor="PAT"; $estimate="(51.0/24.0)"}
       if ($prep_conj eq "v") { $functor="PAT"; $estimate="(2.0/1.0)"}
       if ($prep_conj eq "za") { $functor="EFF"; $estimate="(19.0/11.0)"}
       if ($prep_conj eq "zda") { $functor="PAT"; $estimate="(8.0/1.3)"}
       if ($prep_conj eq "ze") { $functor="PAT"; $estimate="(75.0/5.0)"}
       if ($prep_conj eq "empty") {
          if ($case_dep eq "1") { $functor="PAT"; $estimate="(28.0/7.1)"}
          if ($case_dep eq "2") { $functor="PAT"; $estimate="(57.0/5.0)"}
          if ($case_dep eq "3") { $functor="ADDR"; $estimate="(184.0/74.1)"}
          if ($case_dep eq "4") { $functor="PAT"; $estimate="(1014.0/32.4)"}
          if ($case_dep eq "6") { $functor="ADDR"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "spec_na") { $functor="PAT"; $estimate="(168.0/23.6)"}
          if ($case_dep eq "x") { $functor="PAT"; $estimate="(3.0/1.1)"}
          if ($case_dep eq "7") {
             if ($voice_gov eq "a") { $functor="PAT"; $estimate="(27.0/8.2)"}
             if ($voice_gov eq "p") { $functor="ACT"; $estimate="(11.0/6.6)"}
             if ($voice_gov eq "spec_na") { $functor="ACT"; $estimate="(3.0/2.8)"}
       }  } 
       if ($prep_conj eq "do") {
          if ($voice_gov eq "a") { $functor="DPHR"; $estimate="(3.0/2.1)"}
          if ($voice_gov eq "p") { $functor="DIR3"; $estimate="(1.0/0.8)"}
          if ($voice_gov eq "spec_na") { $functor="DIR3"; $estimate="(2.0/1.0)"}
       } 
       if ($prep_conj eq "z") {
          if ($subpos_gov eq "p") { $functor="ORIG"; $estimate="(4.0/3.1)"}
          if ($subpos_gov eq "s") { $functor="ORIG"; $estimate="(2.0/1.0)"}
          if ($subpos_gov eq "b_") {
             if ($afun_gov eq "atr") { $functor="PAT"; $estimate="(4.0/1.2)"}
             if ($afun_gov eq "pred") { $functor="DIR1"; $estimate="(3.0/1.1)"}
    }  }  } 
    if ($pos_gov eq "z") {
       if ($pos_dep eq "c") { $functor="RSTR"; $estimate="(2.0/1.0)"}
       if ($pos_dep eq "n") { $functor="PAT"; $estimate="(6.0/2.3)"}
       if ($pos_dep eq "p") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($pos_dep eq "v") { $functor="PRED"; $estimate="(28.0/3.7)"}
       if ($pos_dep eq "x") { $functor="ACT"; $estimate="(1.0/0.8)"}
 }  } 
 if ($afun_dep eq "pnom") {
    if ($pos_gov eq "a") { $functor="CPR"; $estimate="(2.0/1.0)"}
    if ($pos_gov eq "d") { $functor="PRED"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "j") { $functor="COND"; $estimate="(1.0/0.8)"}
    if ($pos_gov eq "v") { $functor="PAT"; $estimate="(467.0/22.7)"}
    if ($pos_gov eq "z") { $functor="PRED"; $estimate="(19.0/2.5)"}
    if ($pos_gov eq "n") {
       if ($afun_gov eq "adv") { $functor="RSTR"; $estimate="(2.0/1.0)"}
       if ($afun_gov eq "atr") { $functor="RSTR"; $estimate="(8.0/1.3)"}
       if ($afun_gov eq "auxx") { $functor="COND"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "pred") { $functor="PAT"; $estimate="(8.0/2.4)"}
       if ($afun_gov eq "sb") { $functor="RSTR"; $estimate="(3.0/1.1)"}
 }  } 
 if ($afun_dep eq "pred") {
    if ($voice_gov eq "a") { $functor="PAR"; $estimate="(24.0/4.9)"}
    if ($voice_gov eq "p") { $functor="PRED"; $estimate="(17.0/3.7)"}
    if ($voice_gov eq "spec_na") { $functor="PRED"; $estimate="(1723.0/76.4)"}
 } 
 if ($afun_dep eq "sb") {
    if ($case_gov eq "1") { $functor="ACT"; $estimate="(9.0/6.4)"}
    if ($case_gov eq "7") { $functor="ACT"; $estimate="(2.0/1.0)"}
    if ($case_gov eq "2") {
       if ($pos_dep eq "c") { $functor="RSTR"; $estimate="(32.0/2.6)"}
       if ($pos_dep eq "d") { $functor="RSTR"; $estimate="(8.0/1.3)"}
       if ($pos_dep eq "n") { $functor="ACT"; $estimate="(2.0/1.8)"}
       if ($pos_dep eq "p") { $functor="ACT"; $estimate="(8.0/2.4)"}
    } 
    if ($case_gov eq "4") {
       if ($afun_gov eq "adv") { $functor="PAT"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "atr") { $functor="RSTR"; $estimate="(2.0/1.0)"}
       if ($afun_gov eq "atradv") { $functor="ACT"; $estimate="(1.0/0.8)"}
       if ($afun_gov eq "obj") { $functor="ACT"; $estimate="(3.0/1.1)"}
    } 
    if ($case_gov eq "6") {
       if ($afun_gov eq "adv") { $functor="ACT"; $estimate="(2.0/1.0)"}
       if ($afun_gov eq "pred") { $functor="PAT"; $estimate="(2.0/1.0)"}
    } 
    if ($case_gov eq "spec_na") {
       if ($voice_gov eq "p") { $functor="PAT"; $estimate="(92.0/20.3)"}
       if ($voice_gov eq "spec_na") { $functor="ACT"; $estimate="(130.0/28.8)"}
       if ($voice_gov eq "a") {
          if ($case_dep eq "1") { $functor="ACT"; $estimate="(1529.0/102.3)"}
          if ($case_dep eq "2") { $functor="ACT"; $estimate="(10.0/2.4)"}
          if ($case_dep eq "3") { $functor="ACT"; $estimate="(3.0/1.1)"}
          if ($case_dep eq "4") { $functor="PAT"; $estimate="(13.0/3.6)"}
          if ($case_dep eq "5") { $functor="ACT"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "6") { $functor="LOC"; $estimate="(1.0/0.8)"}
          if ($case_dep eq "spec_na") { $functor="ACT"; $estimate="(179.0/20.4)"}
          if ($case_dep eq "x") { $functor="ACT"; $estimate="(3.0/2.1)"}
    }  } 
    if ($case_gov eq "x") {
       if ($subpos_dep eq "a_") { $functor="RSTR"; $estimate="(1.0/0.8)"}
       if ($subpos_dep eq "g") { $functor="RSTR"; $estimate="(1.0/0.8)"}
       if ($subpos_dep eq "n_") { $functor="ACT"; $estimate="(25.0/7.1)"}
       if ($subpos_dep eq "s") { $functor="ACT"; $estimate="(1.0/0.8)"}
       if ($subpos_dep eq "spec_eq") { $functor="RSTR"; $estimate="(4.0/1.2)"}
       if ($subpos_dep eq "spec_zavinac") { $functor="ACT"; $estimate="(4.0/1.2)"}
       if ($subpos_dep eq "y") { $functor="PAT"; $estimate="(1.0/0.8)"}
 } }


#$estimate=~m/\((.+)\/(.+)\)/;
#$prec=($1-$2)/$1;

# vysledek je dvojice: 
# navrzeny funktor a odhad jeho spravnosti z intervalu (0,1>

return ($functor, $estimate);

}


