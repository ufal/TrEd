use Fslib;

my @format=(
'@P form',
'@P lemma',
'@P tag',
'@P afun',
'@N ord');		       # jednoduchy FS format se 4-mi
                               # atributy, ord urcuje poradi uzlu ve
                               # vete i ve stromu

my $fs=
  FSFile->create(		# vytvori novy FSFile objekt
    FS => FSFormat->create(@format), # v nasem formatu
    hint => '${tag}',	        # co se ma zobrazovat, kdyz je mys nad uzlem
    patterns => ['${form}','${afun}'],  # jak se zobrazuji atributy
    trees => [],		# zatim zadne stromy
    backend => 'FSBackend');	# ukladat budeme jako FS (default)

# vytvorime 10 cvicnych stromu
my ($root,$node);
foreach (1..10) {
  $root=$fs->new_tree($_);	# vytvori novy koren
  $root->{form}="#$_";
  $root->{ord}=0;
  foreach (1..4) {
    $node=FSNode->new();	# novy uzel
    $node->{form}="uzel-$_";
    $node->{ord}=$_;
    Paste($node,$root,$fs->FS->defs()); # vrazime ho pod koren
  }
}

$fs->writeFile('test.fs');
