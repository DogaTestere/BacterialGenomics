from pathlib import Path
import csv
import argparse

import matplotlib.pyplot as plt
import pandas as pd

# ##bcftools_callCommand=call -mv -Ob -o ec1_S1_L001_sorted.bcf; Date=Thu Dec 11 13:39:00 2025
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	ec1_S1_L001_sorted.bam
# BA000007.3	58	.	C	G	23.434	.	DP=2;VDB=0.36;SGB=-0.453602;MQ0F=0;AC=2;AN=2;DP4=0,0,2,0;MQ=31	GT:PL	1/1:53,6,0
# BA000007.3	64	.	C	T	27.4222	.	DP=2;VDB=0.36;SGB=-0.453602;MQ0F=0;AC=2;AN=2;DP4=0,0,2,0;MQ=31	GT:PL	1/1:57,6,0
# BA000007.3	225	.	CACCACCACCATCACCATTACCA	CACCA	137.416	.	INDEL;IDV=5;IMF=0.555556;DP=9;VDB=0.925301;SGB=-0.662043;RPBZ=0;MQBZ=-2.71052;MQSBZ=-0.755929;BQBZ=1.75;SCBZ=0;MQ0F=0;AC=2;AN=2;DP4=0,0,7,2;MQ=27	GT:PL	1/1:167,27,0
# BA000007.3	319	.	CTTTTTTTT	CTTTTTTTTT	93.4151	.	INDEL;IDV=10;IMF=1;DP=10;VDB=0.13615;SGB=-0.651104;MQ0F=0;AC=2;AN=2;DP4=0,0,1,7;MQ=27	GT:PL	1/1:123,24,0
# BA000007.3	410	.	G	T	122.415	.	DP=8;VDB=0.730264;SGB=-0.616816;MQSBZ=-2;MQ0F=0;AC=2;AN=2;DP4=0,0,2,4;MQ=32	GT:PL	1/1:152,18,0

def extractQualAndAlt(vcfPath, outputLoc):
    vcf_file = Path(vcfPath)

    results = [] # POS, REF, ALT, QUAL, DEPTH

    with vcf_file.open() as f:
        for line in f:
            if line.startswith("#"):
                continue

            fields = line.strip().split("\t")

            pos = fields[1]
            ref = fields[3]
            alt = fields[4]
            qual = fields[5]

            info = fields[7]
            info_dict = dict(
                item.split("=") if "=" in item else (item, None)
                for item in info.split(";")
            )
            dp = int(info_dict.get("DP", 0))

            results.append({
                "POSITION" : int(pos),
                "REFERENCE" : ref,
                "ALTERNATIVE" : alt,
                "QUALITY" : float(qual),
                "DEPTH": dp
            })

    
    with open(outputLoc, "w", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=["POSITION", "REFERENCE", "ALTERNATIVE", "QUALITY", "DEPTH"], delimiter="\t")
        writer.writeheader()
        writer.writerows(results)

def plotVcfFile(positions, quals, depths, outputPhotoPath):
    df = pd.DataFrame({
        "POS": positions,
        "QUAL": quals,
        "DP": depths
    })

    window = 10_000
    df["BIN"] = (df["POS"] // window) * window

    binned_qual = df.groupby("BIN")["QUAL"].median()
    binned_dp = df.groupby("BIN")["DP"].mean()

    # --- 1. Median QUAL scatter + line ---
    plt.figure(figsize=(12,4))
    plt.scatter(binned_qual.index, binned_qual.values, s=20, alpha=0.7)
    plt.plot(binned_qual.index, binned_qual.values, linewidth=1)
    plt.xlabel("Genomic Position (10 kb bins)")
    plt.ylabel("Median QUAL")
    plt.tight_layout()
    plt.savefig(outputPhotoPath.replace(".png", "_qual.png"), dpi=150)
    plt.close()

    # --- 2. Mean depth scatter + line ---
    plt.figure(figsize=(12,4))
    plt.scatter(binned_dp.index, binned_dp.values, s=20, alpha=0.7)
    plt.plot(binned_dp.index, binned_dp.values, linewidth=1)
    plt.xlabel("Genomic Position (10 kb bins)")
    plt.ylabel("Mean Depth (DP)")
    plt.tight_layout()
    plt.savefig(outputPhotoPath.replace(".png", "_depth.png"), dpi=150)
    plt.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vcf", required=True, help="Path to input VCF file")
    parser.add_argument("--out", required=True, help="Where to write TSV output")
    parser.add_argument("--plot", required=True, help="Where to save plot PNG")
    args = parser.parse_args()

    extractQualAndAlt(args.vcf, args.out)

    # Collect QUAL values for plotting
    positions = []
    quals = []
    depths = []

    with open(args.out) as f:
        next(f)
        for line in f:
            p, _, _, q, dp = line.strip().split("\t")
            positions.append(int(p))
            quals.append(float(q))
            depths.append(int(dp))

    plotVcfFile(positions, quals, depths, args.plot)



if __name__ == "__main__":
    main()