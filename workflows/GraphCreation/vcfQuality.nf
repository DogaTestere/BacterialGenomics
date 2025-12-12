include { VCF_QUALITY_GRAPH } from "../../modules/GraphCreation/vcfQualityGraph.nf"

workflow VCF_GRAPH_CREATION {
    take:
    vcf_file_ch

    main:
    (qual_png, depth_png, tsv_file) = VCF_QUALITY_GRAPH(vcf_file_ch, file(params.vcf_quality_graph_script))

    emit:
    qual_png
    depth_png
}