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

/*
def path = file('/some/path/file.txt')

assert path.baseName == 'file'
assert path.extension == 'txt'
assert path.name == 'file.txt'
assert path.parent == '/some/path'
*/

/*
Conda package names can be specified using the conda directive. Multiple package names can be specified by separating them with a blank space. For example:
process hello {
  conda 'bwa samtools multiqc'

  script:
  """
  your_command --here
  """
}
*/
process trimmomatic {
    conda 'trimmomatic'
    input:
    tuple path(trim_jar), path(fastq_1), path(fastq_2)
    
    val thread_val
    val step_options 

    output:
    tuple path(paired_1), path(paired_2)

    script:
    base_name = "${fastq_1.baseName}"
    paired_1 = "${base_name}_forward_paired.fq.gz"
    paired_2 = "${base_name}_reverse_paired.fq.gz"
    unpaired_1 = "${base_name}_forward_unpaired.fq.gz"
    unpaired_2 = "${base_name}_reverse_unpaired.fq.gz"
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
    conda 'fastqc'
    
    input:
    tuple path(read_1), path(read_2)
    // paired 1 and 2 files or initial fastq files

    output:
    tuple path(html_file1), path(html_file2)
    tuple path(zip_file1), path(zip_file2)
    script:
    html_file1 = "${read_1.baseName}.html"
    html_file2 = "${read_2.baseName}.html"
    zip_file1 = "${read_1.baseName}.zip"
    zip_file2 = "${read_2.baseName}.zip"
    "fastqc $read_1 $read_2"
}

// Duplicate fastqc for a second usage in the same workflow context
process fastqc_post {
    conda 'fastqc'
    
    input:
    tuple path(read_1), path(read_2)

    output:
    tuple path(html_file1), path(html_file2)
    tuple path(zip_file1), path(zip_file2)
    script:
    html_file1 = "${read_1.baseName}.html"
    html_file2 = "${read_2.baseName}.html"
    zip_file1 = "${read_1.baseName}.zip"
    zip_file2 = "${read_2.baseName}.zip"
    "fastqc $read_1 $read_2"
}

process indexing{
    input:
    val thread_val

    path ref_file

    output:
    tuple path("ref_index"), val(ref_file.baseName)

    script:
    base_name = "${ref_file.baseName}"
    "bowtie2-build --threads $thread_val $ref_file ref_index/$base_name"
}

process refAlignment {
    input:
    tuple path(index_dir), val(ref_base), val(sample_id), path(reads)

    output:
    path sam_file

    script:
    sam_file = "${sample_id}.sam"
    """
    bowtie2 -x ${index_dir}/${ref_base} -1 ${reads[0]} -2 ${reads[1]} -S ${sam_file}
    """
}

process samConversion {
    input:
    val thread_val
    path sam_file

    output:
    path sorted_bam

    script:
    bam_file = "${sam_file.baseName}.bam"
    tmp_file = "${sam_file.baseName}.tmp.sort"
    sorted_bam = "${sam_file.baseName}_sorted.bam"
    """
    mkdir -p bam
    samtools view -uS -o bam/$bam_file $sam_file
    samtools sort -@ $thread_val -T $tmp_file -o $sorted_bam bam/$bam_file 
    """
}

process bamIndexing {
    input:
    path sorted_bam

    script:
    "samtools index $sorted_bam"
}

process readCollapsing {
    input:
    path(ref_file)
    path(sorted_bam)

    output:
    path bcf_file

    script:
    bcf_file = "${ref_file.baseName}.bcf"
    "bcftools mpileup -f $ref_file $sorted_bam | bcftools call -mv -Ob -o $bcf_file"
}

process vcfIndexing {
    input:
    path bcf_file

    output:
    tuple path(zipped_file), path(index_vcf)

    script:
    vcf_file = "${bcf_file.baseName}.vcf"
    index_vcf = "${bcf_file.baseName}.vcf.gz.tbi"
    zipped_file = "${bcf_file.baseName}.vcf.gz"
    """
    bcftools convert -O v -o $vcf_file $bcf_file
    bgzip -c $vcf_file > $zipped_file
    tabix -p vcf $zipped_file
    """
}

process concensusCreation {
    //publishDir "FinalResult"

    input:
    tuple path(zipped_file), path(index_vcf)
    path ref_file

    output:
    path concensus_file

    script:
    concensus_file = "${ref_file.baseName}.fasta"
    "bcftools consensus -f $ref_file $zipped_file > $concensus_file"
}

process annotation {
    input:
    path concensus
    val prk_name

    output:
    tuple path("prk"), path("prk/${prk_name}.gb*")

    script:
    "prokka --outdir prk --prefix $prk_name --force $concensus"
}

workflow {
    main:
    thread_val = 4
    step_options = "ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36"
    prk_name = "prokkaAnnotes"

    // Current path "~\miniconda3\pkgs\trimmomatic-0.40-hdfd78af_0\share\trimmomatic-0.40-0\trimmomatic.jar"
    // Maybe moving it to the working directory wouldn't break anything.
        trimmJar = channel.fromPath("/home/yasemen/miniconda3/pkgs/trimmomatic-0.40-hdfd78af_0/share/trimmomatic-0.40-0/trimmomatic.jar", checkIfExists:true)
    
    fastq_ch = channel.fromFilePairs("./DogaNextflow/FastqFiles/*_R{1,2}_*.{fastq,fastq.gz}", checkIfExists: true)
    ref_ch = channel.fromPath("./DogaNextflow/FastqFiles/*_genomic.fna", checkIfExists: true)
                    .first()

    // First QC
    initial_fastqc = fastqc(fastq_ch)

    trim_and_fastq_ch = trimmJar.combine(fastq_ch)
    paired_tuple = trimmomatic(trim_and_fastq_ch, thread_val, step_options)

    // Second QC
    second_fastqc = fastqc_post(paired_tuple)

    // indexing ref file
    indexed_ref_file = indexing(ref_ch, thread_val)
    aligned_input_ch = indexed_ref_file.combine(fastq_ch)

    sam_file = refAlignment(aligned_input_ch)
    sorted_bam = samConversion(thread_val, sam_file)
    bamIndexing(sorted_bam)
    bcf_file = readCollapsing(ref_ch, sorted_bam)
    vcf_file = vcfIndexing(bcf_file)

    concensus_file = concensusCreation(vcf_file, ref_ch)

    prokkaDir_and_gbFile = annotation(concensus_file, prk_name)
        return [initial_fastqc, second_fastqc, concensus_file, prokkaDir_and_gbFile]

}
