convert fastq into fasta
exec "$reformat ignorebadquality=t in=$input out=$output threads=$threads ;"

reformat
conda install -c bioconda bbtools


   wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2
$minimap2 -t $threads -x map-ont -c $transFasta $input > $output1 ;
 produce(branch.toString() +".paf"){

$minimap2 -t $threads -x splice -c $genomeFasta $input > $output1;
	   grep \$'\\t+\\t' $output1 | awk -F'\\t' -v OFS="\\t" '{ print \$4-\$3,0,0,0,0,0,0,0,\$5,\$1,\$2,\$3,\$4,\$6,\$7,\$8,\$9,2, 100","\$4-\$3-100",",\$3","\$3+100",",  \$8","\$9-\$4+\$3+100"," }' > $output2 ;
	   grep \$'\\t-\\t' $output1 | awk -F'\\t' -v OFS="\\t" '{ print \$4-\$3,0,0,0,0,0,0,0,\$5,\$1,\$2,\$3,\$4,\$6,\$7,\$8,\$9,2, 100","\$4-\$3-100",", \$2-\$4","\$2-\$4+100",", \$8","\$9-\$4+\$3+100"," }' >> $output2 ;


what are
filter_transcripts
filter_transcripts = {
    doc "Filter transcripts"
    output.dir=jaffa_output+branch.toString()
    produce(input.prefix+".txt"){ // ,branch+".geneCounts") {
        from(".paf") {
            exec """
	    $process_transcriptome_align_table $input $gapSize $transTable \'$anno_prefix\' > $output1
            ""","filter_transcripts"
        }
	// code related to obtaining gene-level counts in below 
	//sort -u -k1,1 $input | cut -f6 | sort | uniq -c | sed 's/^ *//g' >> ${output.dir}/${branch}.transCounts ;
	//$make_count_table ${output.dir}/${branch}.transCounts $transTable > $output2 ;
    }
}

extract_fusion_sequences
# extract_seq_from_fasta is a c++ script
extract_fusion_sequences = {
    doc "Extract fusion sequences"
    output.dir=jaffa_output+branch
    produce(input.prefix+".fusions.fa") {
        from(".txt", ".fasta") {
            exec """
                cat $input1 | awk '{print \$1}' > ${output}.temp ;
                $reformat in=$input2 out=stdout.fasta fastawrap=0 | $extract_seq_from_fasta ${output}.temp > $output ;
                rm ${output}.temp ;
            ""","extract_fusion_sequences"
        }
    }
} 

make_fasta_reads_table
make_fasta_reads_table = {
    doc "Make fasta reads table"
    output.dir=jaffa_output+branch.toString()
    produce(input.txt.prefix+".reads") {
        from("txt") {
            exec """
                echo  -e "transcript\tbreak_min\tbreak_max\tfusion_genes\tspanning_pairs\tspanning_reads" > $output ; 
                awk '{ print \$1"\t"\$2"\t"\$3"\t"\$4"\t"0"\t"1}' $input | sort -u  >> $output
            ""","make_fasta_reads_table"
        }
    }
}

get_final_list
get_final_list = {
    doc "Get final list"
    output.dir=jaffa_output+branch.toString()
    produce(branch.toString()+".summary") {
        from(".psl", ".reads") { //, ".geneCounts") {
            exec """
	        if [ ! -s $input1 ] ; then
		   touch $output ;
 		else 
                   $R --vanilla --args $input1 $input2 $transTable $knownTable 
		   $finalGapSize $exclude $reassign_dist $output < $R_get_final_list ;
		 fi;
            ""","get_final_list"
        }
    }
}


compile_all_results 
# get_fusion_seqs is a shell script
compile_all_results = {
    doc "Compile all results"
    var type : "" 
    if (jaffa_output) {
        output.dir=jaffa_output
    }
    produce(outputName+".fasta",outputName+".csv") {
        // change to the jaffa output directory   
        exec """
            $R --vanilla --args $output2.prefix $inputs.summary < $R_compile_results_script ;
            rm -f $output1;
            while read line; do $get_fusion_seqs \$line $output1 ; done < $output2;

            echo "Done writing $output1";
            echo "All Done." ;
	    echo "*************************************************************************" ;
	    echo " Citation for JAFFA_direct, JAFFA_assembly and JAFFA_hybrid: " ;
	    echo "   Davidson, N.M., Majewski, I.J. & Oshlack, A. ";
	    echo "   JAFFA: High sensitivity transcriptome-focused fusion gene detection." ;
	    echo "   Genome Med 7, 43 (2015)" ;
	    echo "*************************************************************************" ;
	    echo " Citation for JAFFAL: " ;
	    echo "   Davidson, N.M. et al. ";
	    echo "   JAFFAL: detecting fusion genes with long-read transcriptome sequencing" ;
	    echo "   Genome Biol. 23, 10 (2022)" ;
	    echo "*************************************************************************" ;
        ""","compile_all_results"
    }
}
