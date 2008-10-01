#!/usr/bin/perl

use SimpleTagger::Czech;

use encoding qw(utf-8);

#my @forms = qw(Milan Čermák , kterého policie považuje za komplice půlmiliardového zloděje Františka Procházky , údajně o rekordní prosincové krádeži mluvil se svým známým už loni v létě .);


my @forms = qw(Západní novináři v Číně obdrželi v minulých dnech výhrůžné telefonáty nebo e-mailové a textové zprávy kvůli údajnému zkreslování faktů při informování o nedávných protičínských protestech v Tibetu . Některé anonymy vyhrožovaly reportérům smrtí , uvedla agentura AP .);

my @forms = qw(Prezident Václav Klaus přijme ve čtvrtek na Pražském hradě nejvyšší státní zástupkyni Renatu Veseckou . Prezident i nejvyšší státní zástupkyně jsou kvůli svým krokům v rámci justice častým terčem kritiky ze strany některých politiků i soudců .);

SimpleTagger::Czech::tag_sentence(@forms);
