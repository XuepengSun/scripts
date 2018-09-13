
blastn -task megablast -word_size 100 -evalue 1e-10 -num_threads 50 \
-outfmt "6 qseqid sseqid qlen slen length qstart qend sstart send pident evalue bitscore sskingdom staxid ssciname" \
-db nt \
-query sieversii_v5_scaffold.fasta \
-out siev_v5_scaf.nt.blastn 


