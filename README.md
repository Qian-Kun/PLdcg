# Protocol

## 1. Performed Pfam domain annotations for whole-genome gene sets.
*	Downloaded HMMER version [hmmer-3.1b1](http://eddylab.org/software/hmmer3/3.1b1/hmmer-3.1b1.tar.gz).
*	Downloaded Pfam database from [Pfam-A.hmm.gz](ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam27.0/Pfam-A.hmm.gz).

```
hmmsearch --domtblout Pin_domain.tab --cpu 10 Pfam-A.hmm PLdcg/sample_data/pep/P.infestans_gene_aa.fa > P.infestans_gene_aa.Pfam.out
perl PLdcg/util/Pfam_annotation_step1.pl Pin_domain.tab P.infestans_gene_aa.Pfam.out P.infestans_gene_aa.Pfam.out.step1
perl PLdcg/util/Pfam_annotation_step2.pl P.infestans_gene_aa.Pfam.out.step1 P.infestans_gene_aa.Pfam.out.step2
perl PLdcg/util/Pfam_annotation_step3.pl P.infestans_gene_aa.Pfam.out.step2 P.infestans_gene_aa.Pfam.out.step3
perl PLdcg/util/Pfam_annotation_step4.pl PLdcg/sample_data/CE_domain_infor.txt P.infestans_gene_aa.Pfam.out.step3 P.infestans_gene_aa.Pfam.out.result
```

## 2. Phylogenetic analysis to identify CE2, CE3, and CE12.
*	Several identified gene domains from CE2, CE3, and CE12, which were obtained from [CAZy database](http://www.cazy.org/).
*	Download TreeBest version 1.9.2 from TreeSoft: [TreeBeST](http://treesoft.sourceforge.net/treebest.shtml).
*	Performing sequence alignment using [MUSCLE version 3.8.31](http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz) and building Neighbour-joining tree using TreeBest.

```
perl PLdcg/util/get_domain_sequences.pl PLdcg/sample_data/GDSL_domain.ID Pin_domain.tab P.infestans_gene_aa.fa > GDSL_for_NJ.fa
cat PLdcg/sample_data/GDSL_domain.fa >> GDSL_for_NJ.fa
muscle -in GDSL_for_NJ.fa -out GDSL_for_NJ.fa.muscle
treebest nj -b 1000 GDSL_for_NJ.fa.muscle > GDSL_for_NJ.fa.muscle.nhx
```

*	From the phylogenetic file 'GDSL_for_NJ.fa.muscle.nhx' that is viewed by [forester.jar](https://github.com/cmzmasek/forester/blob/master/forester/java/forester.jar?raw=true), sub-families were identified to be clustered together.

## 3. Detect orthologous groups and obtain 'groups.txt' file.
*	first set up Orthomcl and MySQL server.

```
orthomclInstallSchema orthomcl.config install_schema.log
mkdir sequences
cd sequences
orthomclAdjustFasta Pramorum PLdcg/sample_data/pep/Phyra1_1_gene_aa.fa 1
orthomclAdjustFasta Pcapsici PLdcg/sample_data/pep/Phyca11_gene_aa.fa 1
orthomclAdjustFasta Pcinnamomi PLdcg/sample_data/pep/Phyci1_gene_aa.fa 1
orthomclAdjustFasta Pinfestans PLdcg/sample_data/pep/Phyin_gene_aa.fa 1
orthomclAdjustFasta Plateralis PLdcg/sample_data/pep/Phylat_gene_aa.fa 1
orthomclAdjustFasta PnicotianaeR0 PLdcg/sample_data/pep/Pnicotianae_gene_aa.fa 1
orthomclAdjustFasta PnicotianaeR1 PLdcg/sample_data/pep/Phyni_race1_gene_aa.fa 1
orthomclAdjustFasta Psojae PLdcg/sample_data/pep/Physo3_gene_aa.fa 1
orthomclAdjustFasta Harabidopsidis PLdcg/sample_data/pep/Hpa_gene_aa.fa 1
orthomclAdjustFasta Paphanidermatum PLdcg/sample_data/pep/pag1_gene_aa.fa 1
orthomclAdjustFasta Parrhenomanes PLdcg/sample_data/pep/par_gene_aa.fa 1
orthomclAdjustFasta Pirregulare PLdcg/sample_data/pep/pir_gene_aa.fa 1
orthomclAdjustFasta Piwayamai PLdcg/sample_data/pep/piw_gene_aa.fa 1
orthomclAdjustFasta PultimumVS PLdcg/sample_data/pep/pug3_gene_aa.fa 1
orthomclAdjustFasta PultimumVU PLdcg/sample_data/pep/pug1_gene_aa.fa 1
orthomclAdjustFasta Pvexans PLdcg/sample_data/pep/pve_gene_aa.fa 1
cd ..
orthomclFilterFasta sequences 10 20
formatdb -i goodProteins.fasta -p T
blastall -i goodProteins.fasta -d goodProteins.fasta -p blastp -F 'm S' -v 100000 -b 100000 -z 116024 -e 1e-5 -m 8 -a 12 -o blast_goodProteins.out
orthomclBlastParser blast_goodProteins.out sequences > SimilarSequences.txt
orthomclLoadBlast orthomcl.config SimilarSequences.txt
orthomclPairs orthomcl.config pairs.log cleanup=yes
orthomclDumpPairsFiles orthomcl.config
mcl mclInput --abc -I 1.5 -o mclOutput
orthomclMclToGroups PIGROUP 1000 < mclOutput > groups.txt
perl PLdcg/util/orthologous_group_for_special_genes.pl CE_annotation_file.list groups.txt annotated_group.txt
```

## 4. Manually remove groups containing proteases that are predicted by MEROPS.
