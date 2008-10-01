package BlockAliases;

our %alias;


$alias{en_sentsegm} = [qw( SEnglishW_to_SEnglishM::Sentence_segmentation)];

$alias{en_w2m} =  [qw(
		      SEnglishW_to_SEnglishM::Tokenize_and_tag
		      SEnglishW_to_SEnglishM::Lemmatize_mtree
		     )];

$alias{en_m2p} =  [qw(
		      SEnglishM_to_SEnglishP::Phrase_parsing
		      SEnglishM_to_SEnglishP::Fix_relative_that
		     )];

$alias{en_p2a} =  [qw(
		      SEnglishP_to_SEnglishA::Mark_heads
		      SEnglishP_to_SEnglishA::Build_atree
		      SEnglishP_to_SEnglishA::Rehang_coord
		      SEnglishP_to_SEnglishA::Rehang_appos
		      SEnglishP_to_SEnglishA::Rehang_most
		     )];

$alias{en_a2t} =  [qw(

		      SEnglishA_to_SEnglishT::Mark_auxiliary_nodes
		      SEnglishA_to_SEnglishT::Mark_negator_as_aux
		      SEnglishA_to_SEnglishT::Build_ttree
	          SEnglishA_to_SEnglishT::Mark_named_entities
		      SEnglishA_to_SEnglishT::Fill_is_member
		      SEnglishA_to_SEnglishT::Assign_coap_functors
		      SEnglishA_to_SEnglishT::Distrib_coord_aux

		      SEnglishA_to_SEnglishT::Mark_clause_heads
		      SEnglishA_to_SEnglishT::Mark_relclause_heads

		      SEnglishA_to_SEnglishT::Mark_passives
		      SEnglishA_to_SEnglishT::Assign_functors
		      SEnglishA_to_SEnglishT::Fix_tlemmas
		      SEnglishA_to_SEnglishT::Mark_infin
		      #SEnglishA_to_SEnglishT::Add_cor_act
		      SEnglishA_to_SEnglishT::Recompute_deepord
		      SEnglishA_to_SEnglishT::Assign_nodetype
		      SEnglishA_to_SEnglishT::Assign_sempos
		      SEnglishA_to_SEnglishT::Assign_grammatemes

		      SEnglishA_to_SEnglishT::Detect_formeme

		      Repair::Reload_schema_in_plsgz
		      Repair::Set_node_schema_types

		     )];


$alias{en_w2t} = [qw(en_w2m en_m2p en_p2a en_a2t)];


$alias{cz_m2a} = [qw(
		      SCzechM_to_SCzechA::McD_parser
		   )];


$alias{cz_a2t} = [qw(
		      SCzechA_to_SCzechT::Mark_auxiliary_nodes
		      SCzechA_to_SCzechT::Build_ttree
		      SCzechA_to_SCzechT::Rehang_unary_coord_conj

		      SCzechA_to_SCzechT::Fill_is_member
		      SCzechA_to_SCzechT::Assign_coap_functors
		      SCzechA_to_SCzechT::Distrib_coord_aux

		      SCzechA_to_SCzechT::Mark_clause_heads
		      SCzechA_to_SCzechT::Mark_relclause_heads

		      SCzechA_to_SCzechT::Fix_tlemmas

		      SCzechA_to_SCzechT::Recompute_deepord
		      SCzechA_to_SCzechT::Assign_nodetype
                      SCzechA_to_SCzechT::Assign_grammatemes
		      SCzechA_to_SCzechT::Detect_formeme

		      Repair::Reload_schema_in_plsgz
		      Repair::Set_node_schema_types

		   )];

$alias{cs_a2t}=[qw(cz_a2t)];


$alias{align} = [qw(
                      Align_SEnglishT_SCzechT::Heuristic_alignment
		   )];

$alias{demo1} = [qw(
	      SEnglishW_to_SEnglishM::Sentence_segmentation
              SEnglishW_to_SEnglishM::Tokenize_and_tag
              SEnglishW_to_SEnglishM::Lemmatize_mtree

              SEnglishM_to_SEnglishP::Phrase_parsing

              SEnglishP_to_SEnglishA::Mark_heads
              SEnglishP_to_SEnglishA::Build_atree
              SEnglishP_to_SEnglishA::Rehang_appos

              SEnglishA_to_SEnglishT::Mark_auxiliary_nodes
              SEnglishA_to_SEnglishT::Build_ttree
              SEnglishA_to_SEnglishT::Fill_is_member
              SEnglishA_to_SEnglishT::Assign_coap_functors
              SEnglishA_to_SEnglishT::Distrib_coord_aux

               SEnglishA_to_SEnglishT::Mark_passives
               SEnglishA_to_SEnglishT::Assign_functors
               SEnglishA_to_SEnglishT::Fix_tlemmas
               SEnglishA_to_SEnglishT::Mark_infin
               SEnglishA_to_SEnglishT::Add_cor_act
               SEnglishA_to_SEnglishT::Recompute_deepord
               SEnglishA_to_SEnglishT::Assign_nodetype
               SEnglishA_to_SEnglishT::Assign_sempos
               SEnglishA_to_SEnglishT::Assign_grammatemes


)];
# SEnglishW_to_SEnglishM::Sentence_segmentation is not always wanted

$alias{en_a2t_klimes} = [qw(
			SEnglishA_to_SEnglishT::TBLa2t_phase0
			SEnglishA_to_SEnglishT::TBLa2t_phase1
			SEnglishA_to_SEnglishT::TBLa2t_phase2
			SEnglishA_to_SEnglishT::TBLa2t_phase3
			SEnglishA_to_SEnglishT::TBLa2t_phase4
)];

$alias{cs_a2t_klimes} = [qw(
			SCzechA_to_SCzechT::TBLa2t_phase0
			SCzechA_to_SCzechT::TBLa2t_phase1_a
			SCzechA_to_SCzechT::TBLa2t_phase2
			SCzechA_to_SCzechT::TBLa2t_phase3
			SCzechA_to_SCzechT::TBLa2t_phase4
)];



$alias{obo_english_to_tecto} = [qw(
	      SEnglishW_to_SEnglishM::Each_line_as_sentence
              SEnglishW_to_SEnglishM::Tokenize_and_tag
              SEnglishW_to_SEnglishM::Lemmatize_mtree

              SEnglishM_to_SEnglishP::Phrase_parsing

              SEnglishP_to_SEnglishA::Mark_heads
              SEnglishP_to_SEnglishA::Build_atree
              SEnglishP_to_SEnglishA::Rehang_appos

              SEnglishA_to_SEnglishT::Mark_auxiliary_nodes
              SEnglishA_to_SEnglishT::Build_ttree
              SEnglishA_to_SEnglishT::Fill_is_member
              SEnglishA_to_SEnglishT::Assign_coap_functors
              SEnglishA_to_SEnglishT::Distrib_coord_aux

               SEnglishA_to_SEnglishT::Mark_passives
               SEnglishA_to_SEnglishT::Assign_functors
               SEnglishA_to_SEnglishT::Fix_tlemmas
               SEnglishA_to_SEnglishT::Mark_infin
               SEnglishA_to_SEnglishT::Add_cor_act
               SEnglishA_to_SEnglishT::Recompute_deepord
               SEnglishA_to_SEnglishT::Assign_nodetype
               SEnglishA_to_SEnglishT::Assign_sempos
               SEnglishA_to_SEnglishT::Assign_grammatemes


)];


$alias{wmt} = [qw(

              SEnglishW_to_SEnglishM::Tokenize_and_tag
              SEnglishW_to_SEnglishM::Lemmatize_mtree

              SEnglishM_to_SEnglishP::Phrase_parsing
              SEnglishM_to_SEnglishP::Fix_relative_that

              SEnglishP_to_SEnglishA::Mark_heads
              SEnglishP_to_SEnglishA::Build_atree
              SEnglishP_to_SEnglishA::Rehang_appos

              SEnglishA_to_SEnglishT::Mark_auxiliary_nodes
              SEnglishA_to_SEnglishT::Build_ttree
              SEnglishA_to_SEnglishT::Fill_is_member
              SEnglishA_to_SEnglishT::Assign_coap_functors
              SEnglishA_to_SEnglishT::Distrib_coord_aux

               SEnglishA_to_SEnglishT::Mark_passives
               SEnglishA_to_SEnglishT::Assign_functors
               SEnglishA_to_SEnglishT::Fix_tlemmas
               SEnglishA_to_SEnglishT::Mark_infin
               SEnglishA_to_SEnglishT::Add_cor_act
               SEnglishA_to_SEnglishT::Recompute_deepord
               SEnglishA_to_SEnglishT::Assign_nodetype
               SEnglishA_to_SEnglishT::Assign_sempos
               SEnglishA_to_SEnglishT::Assign_grammatemes

	       SEnglishA_to_SEnglishT::Detect_formeme

               Repair::Reload_schema_in_plsgz
               Repair::Set_node_schema_types
)];



$alias{test} = [qw(

	      SEnglishP_to_SEnglishA::Mark_heads
              SEnglishP_to_SEnglishA::Build_atree
              SEnglishP_to_SEnglishA::Rehang_appos

              SEnglishA_to_SEnglishT::Mark_auxiliary_nodes
              SEnglishA_to_SEnglishT::Build_ttree
              SEnglishA_to_SEnglishT::Fill_is_member
              SEnglishA_to_SEnglishT::Assign_coap_functors
              SEnglishA_to_SEnglishT::Distrib_coord_aux

	      SEnglishA_to_SEnglishT::Mark_clause_heads
	      SEnglishA_to_SEnglishT::Mark_relclause_heads

	      SEnglishA_to_SEnglishT::Mark_passives
               SEnglishA_to_SEnglishT::Assign_functors
               SEnglishA_to_SEnglishT::Fix_tlemmas
               SEnglishA_to_SEnglishT::Mark_infin
               SEnglishA_to_SEnglishT::Add_cor_act
               SEnglishA_to_SEnglishT::Recompute_deepord
               SEnglishA_to_SEnglishT::Assign_nodetype
               SEnglishA_to_SEnglishT::Assign_sempos
               SEnglishA_to_SEnglishT::Assign_grammatemes

	       SEnglishA_to_SEnglishT::Detect_formeme

               Repair::Reload_schema_in_plsgz
               Repair::Set_node_schema_types


		 )];


$alias{buildttree} = [qw(CzechA_to_CzechT/Build_ttree.pm)];

$alias{ptb_to_pedt} = [];

$alias{e2c} = [];

$alias{tri} = [qw(SEnglishW_to_SEnglishM::Sentence_segmentation
		  SEnglishW_to_SEnglishM::Tokenize_and_tag
		  SEnglishW_to_SEnglishM::Lemmatize_mtree)];


$alias{english_analysis} =
[qw(
              SEnglishW_to_SEnglishM::Tokenize_and_tag
              SEnglishW_to_SEnglishM::Lemmatize_mtree

              SEnglishM_to_SEnglishP::Phrase_parsing

              SEnglishP_to_SEnglishA::Mark_heads
              SEnglishP_to_SEnglishA::Build_atree
              SEnglishP_to_SEnglishA::Rehang_appos

)];


$alias{translate} =
  [qw(
              SEnglishT_to_TCzechT::Clone_ttree
              SEnglishT_to_TCzechT::Translate_tlemmas_combined
              SEnglishT_to_TCzechT::Translate_formemes

              SEnglishT_to_TCzechT::Add_noun_gender
              SEnglishT_to_TCzechT::Add_verb_aspect


              Repair::Reload_schema_in_plsgz
              Repair::Set_node_schema_types

    )];

$alias{repair} =
  [qw(
       Repair::Reload_schema_in_plsgz
       Repair::Set_node_schema_types

    )];



$alias{old_cs_t2a} =
  [qw(
       TCzechT_to_TCzechA::Clone_atree
       TCzechT_to_TCzechA::Add_prepositions
       TCzechT_to_TCzechA::Add_subconjs
       TCzechT_to_TCzechA::Init_mtags.pm
       TCzechT_to_TCzechA::Fill_noun_gender.pm
       TCzechT_to_TCzechA::Resolve_attr_agreement
       TCzechT_to_TCzechA::Run_inflection.pm

    )];

$alias{cs_t2a} =
  [qw(
       TCzechT_to_TCzechA::Clone_atree

       TCzechT_to_TCzechA::Init_morphcat

       TCzechT_to_TCzechA::Impose_rel_pron_agr
       TCzechT_to_TCzechA::Impose_subjpred_agr
       TCzechT_to_TCzechA::Impose_attr_agr
       TCzechT_to_TCzechA::Impose_compl_agr

       TCzechT_to_TCzechA::Drop_subj_pers_prons

       TCzechT_to_TCzechA::Add_prepositions
       TCzechT_to_TCzechA::Add_subconjs
       TCzechT_to_TCzechA::Resolve_verbs

       TCzechT_to_TCzechA::Clause_numbering

       TCzechT_to_TCzechA::Add_sent_final_punct
       TCzechT_to_TCzechA::Add_subord_clause_punct
       TCzechT_to_TCzechA::Add_coord_punct

       #TCzechT_to_TCzechA::Move_clitics
       #TCzechT_to_TCzechA::Recompute_ordering

       #TCzechT_to_TCzechA::Finish_mtags
       TCzechT_to_TCzechA::Generate_wordforms

       TCzechT_to_TCzechA::Vocalize_prepositions
       TCzechT_to_TCzechA::Capitalize_sent_start

       TCzechA_to_TCzechW::Concatenate_tokens
    )];








#              SEnglishA_to_SEnglishT::Build_ttree
#              SEnglishA_to_SEnglishT::Fill_is_member
#              SEnglishA_to_SEnglishT::Assign_coap_functors
#              SEnglishA_to_SEnglishT::Distrib_coord_aux
#              SEnglishA_to_SEnglishT::Mark_passives
#              SEnglishA_to_SEnglishT::Assign_functors
#              SEnglishA_to_SEnglishT::Fix_tlemmas
#              SEnglishA_to_SEnglishT::Mark_infin
#              SEnglishA_to_SEnglishT::Add_cor_act
#              SEnglishA_to_SEnglishT::Recompute_deepord
#              SEnglishA_to_SEnglishT::Assign_nodetype
#              SEnglishA_to_SEnglishT::Assign_sempos
#              SEnglishA_to_SEnglishT::Assign_grammatemes

#              SEnglishT_to_MTCzechT::Clone_ttree
#              SSEnglishT_to_TCzechT::Translate_tlemmas
