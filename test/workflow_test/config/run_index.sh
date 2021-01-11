#!/bin/bash -x
## -x : expands variables and prints commands as they are called

##
## Requires fasta index next to fasta file
##
## TODO: automate the index
##

echo $@
params=("$@")

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=
LONGOPTS=gtf:,fasta:,organism:,taxid:,nthread:,empires,hisat2,star,r,kallisto,salmon,dexseq,index:,all

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

gtf=- fasta=- index=-
empires=n all=n
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        --gtf)
            gtf="$2"
            shift 2
            ;;
        --fasta)
            fasta="$2"
            shift 2
            ;;
        --empires)
        empires=y
            shift
            ;;
		--all)
        all=y
            shift
            ;;
		--index)
        index="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            shift
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 0 ]]; then
    echo "$0: empty flag detected, is this intentional?!"
    #exit 4
fi

## Run indices
if [[ "$all" = "y" ]]; then
	podman run --pull=always -v $index:/home/data/indices -v $gtf:$gtf -v $fasta:$fasta --rm hadziahmetovic/generate-indices:latest /home/scripts/generate_indices.sh ${params[@]}
fi

if [[ "$empires" = "y" ]]; then
    ## echo "empires call here ... $gtf $fasta"
    ## start empires index
	podman run --pull=always -v $index:/home/data/indices -v $gtf:$gtf -v $fasta:$fasta -v $fasta.fai:$fasta.fai --rm -it hadziahmetovic/empires:latest /home/scripts/empires_buildindex.sh $gtf $fasta $fasta.fai


	## podman run --pull=always -v /mnt/raidinput/tmp/hadziahmetovic:/home/data/out 
	## -v /mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/Homo_sapiens.GRCh37.75.gtf
	##:/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/Homo_sapiens.GRCh37.75.gtf 
	## -v /mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa
	##:/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa 
	## -v /mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa.fai
	##:/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa.fai 
	## --rm -it hadziahmetovic/empires:latest 
	## /home/scripts/empires_buildindex.sh 
	##		/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/Homo_sapiens.GRCh37.75.gtf 
	##		/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa 
	##		/mnt/einstein/work/GENOMIC_DERIVED/PAN/homo_sapiens/standardchr/dna/Homo_sapiens.GRCh37.75.dna.toplevel.fa.fai 
	##		/home/data/indices/empires/Homo_sapiens.GRCh37.75.dna.toplevel.fa.index
fi




