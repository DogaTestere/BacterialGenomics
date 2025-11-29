/*
def path = file('/some/path/file.txt')

assert path.baseName == 'file'
assert path.extension == 'txt'
assert path.name == 'file.txt'
assert path.parent == '/some/path'
*/

process indexing {
    // The tuple qualifier groups multiple values into a single input definition.
    input:
    path ref_file

    val thread_val

    output:
    tuple path("ref_index"), val(ref_file.baseName)

    script:
    base_name = "${ref_file.baseName}"
    """
    mkdir -p ref_index
    bowtie2-build --threads $thread_val $ref_file ref_index/$base_name
    """
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

workflow {
    main:
    fastq_ch = channel.fromFilePairs("./DogaNextflow/FastqFiles/*_R{1,2}_*.{fastq,fastq.gz}", checkIfExists: true)

    // The first operator emits the first item in a source channel, or the first item that matches a condition. The condition can be a regular expression, a type qualifier (i.e. Java class), or a boolean predicate.
    ref_ch = channel.fromPath("./DogaNextflow/FastqFiles/*_genomic.fna", checkIfExists: true)
                    .first()
    thread_val = 4

    indexedRefFile = indexing(ref_ch, thread_val)

    aligned_input_ch = indexedRefFile.combine(fastq_ch)

    samFile = refAlignment(aligned_input_ch)

    sortedBam = samConversion(thread_val, samFile)
    bamIndexing(sortedBam)
    bcfFile = readCollapsing(ref_ch, sortedBam)
    vcfFile = vcfIndexing(bcfFile)

    // [E::idx_find_and_load] Could not retrieve index file for 'GCA_000008865.2_ASM886v2_genomic.vcf.gz'
    // vcf file also needs the vcf.gz.tbi file
    concensusFasta = concensusCreation(vcfFile, ref_ch)

    publish:
    concensusFasta = concensusFasta
}

output {
    concensusFasta {
        path "."
    }
}

/*
The combine operator produces the combinations (i.e. cross product, “Cartesian” product) of two source channels, or a channel and a list (as the right operand), emitting each combination separately.
Returns: channel

numbers = channel.of(1, 2, 3)
words = channel.of('hello', 'ciao')

numbers
    .combine(words)
    .view()

[1, hello]
[2, hello]
[3, hello]
[1, ciao]
[2, ciao]
[3, ciao]
*/