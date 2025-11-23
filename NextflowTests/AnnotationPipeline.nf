/*
Processes are:
- Quality Control : fasq files ---> return a quality value
- Trimming : fastq files and a quality value ---> return trimmed files

- Indexing ref : a ref file ---> return an indexed ref
- Aligning reads to ref : Trimmed or not fastq files and reference file --> sam file

- Sam to bam conversion : Sam file ---> bam file
- Sort the bam file : bam file ---> sorted_bam
- Indexing of sorted bam file : sorted_bam file ---> indexed_bam

- collapsing reads : reference file and sorted bam --> bcf file
- turning bcf to vcf : bcf file ---> vcf file
- compressing and indexing : vcf file ---> vcf.gz file

- creating a concensus : vcf.gz file and reference file ---> concensus genome

- annotation : concensus file ---> genbank files for this job

bcftools allow for a quality check but the specific filters needs to be manually judged, there is no one filter for all.
*/

// !TODO: thread_val and probably base_name needs to be globally available
/*
def path = file('/some/path/file.txt')

assert path.baseName == 'file'
assert path.extension == 'txt'
assert path.name == 'file.txt'
assert path.parent == '/some/path'
*/

// !NOTE: Maybe command options can be flexable instead of hard coded

process trimmomatic {
    input:
    // path to trimmomatic jar
    path fastq_1
    path fastq_2
    
    val thread_val
    val base_name

    output:
    // paired 1 and 2 files

    script:
    """
    java -jar $trim_jar \
    $fastq_1 $fastq_2 \
    $paired_1 $unpaired_1 \
    $paired_2 $unpaired_2 \
    $step_options
    """
    // Extra steps(rules?) can be added to the end of it. Full list of it is in https://github.com/usadellab/Trimmomatic under "Step options"
}

process fastqc {
    input:
    // paired 1 and 2 files

    output:
    //html file path 
    //zip file path

    script:
    "fastqc -o qc/ $paired_dir/*.fq.gc"
}

process indexing{
    input:
    val thread_val
    val base_name

    path ref_file

    output:
    // the directory with the base_name of the file
    // so i just need to point to the ref directory

    script:
    "bowtie2-build --threads $thread_val $ref_file ref_index/$base_name"
}

process fastqRefAlignment {
    input:
    val base_name
    
    path fastq_1
    path fastq_2

    // Just the location of the ref_index
    path index_dir

    output:
    path "${base_name}.sam"

    script:
    sam_file = "${base_name}.sam"
    "bowtie2 -x $index_dir/$base_name -1 $fastq_1 -2 $fastq_2 -S $sam_file"
}

process samBamConversion {
    input:
    // $base_name.sam location
    val base_name
    val thread_val

    output:
    // sorted bam location

    script:
    bam_file = "${base_name}.bam"
    tmp_file = "${base_name}.tmp.sort"
    sorted_bam = "${base_name}_sorted.bam"
    """
    samtools view -uS -o bam/$bam_file $sam_file
    samtools sort -@ $thread_val -T $tmp_file -o $sorted_bam $bam_file 
    """
}

process samtoolsIndexing {
    input:
    // sorted bam file location

    output:
    // indexed and sorted bam file location

    script:
    "samtools index $sorted_bam"
}

process collapsingReads {
    input:
    path ref_file
    // sorted file location

    val base_name

    output:
    // collapsed read

    script:
    "bcftools mpileup -f $ref_file $sorted_bam | bcftools call -mv -Ob -o $collapsed_read"
}

process vcfCompressionIndexing {
    input:
    val base_name
    
    // collapsed_read location

    output:
    // vcf.gz file location

    script:
    """
    bcftools convert -O v -o $vcf_file $collapsed_read
    bgzip -c $vcf_file > $zipped_file
    tabix -p vcf $zipped_file
    """
}

process concensusCreation {
    input:
    val base_name

    path ref_file
    // vcf.gz file location

    output:
    // concensus genome file

    script:
    "bcftools consensus -f $ref_file $zipped_file > $consensus_file"
}

process annotation {
    input:
    val base_name
    val prk_name
    val kingdom_name

    // consensus genome file

    output:
    // A whole directory but most importantly a gbk or gbf file

    script:
    "prokka --outdir $result_dir --prefix $prk_name --force $consensus"
}

workflow {

}