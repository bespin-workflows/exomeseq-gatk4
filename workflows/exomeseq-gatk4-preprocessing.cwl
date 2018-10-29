#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label:  WES GATK4 Preprocessing
doc: |
  Whole Exome Sequence analysis GATK4 Preprocessing
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../types/bespin-types.yml
inputs:
  # Intervals should come from capture kit (target intervals) bed format
  target_intervals: File[]?
  # Intervals should come from capture kit (bait intervals) bed format
  bait_intervals: File[]?
  # Named read pair in FASTQ format
  read_pair:
      type: ../types/bespin-types.yml#FASTQReadPairType
  # reference genome, fasta
  reference_genome:
    type: File
    secondaryFiles:
    - .amb
    - .ann
    - .bwt
    - .pac
    - .sa
    - .fai
    - ^.dict
  # Number of threads to use
  threads: int
  # Read Group annotation
  # Can be the project name
  library: string
  # e.g. Illumina
  platform: string
  known_sites:
    type: File[] # vcf files of known sites, with indexing
    secondaryFiles:
    - .idx
outputs:
  fastqc_reports:
    type: File[]
    outputSource: preprocessing/fastqc_reports
  trim_reports:
    type: File[]
    outputSource: preprocessing/trim_reports
  markduplicates_bam:
    type: File
    outputSource: preprocessing/markduplicates_bam
    doc: "BAM and bai files from markduplicates"
  recalibration_table:
    type: File
    outputSource: preprocessing/recalibration_table
    doc: "Table of recalibration"
  recalibrated_reads:
    type: File
    outputSource: preprocessing/recalibrated_reads
    doc: "BAM files containing recalibrated reads"
steps:
  prepare_reference_data:
    run: ../subworkflows/exomeseq-00-prepare-reference-data.cwl
    in:
      target_intervals: target_intervals
      bait_intervals: bait_intervals
      reference_genome: reference_genome
    out:
      - target_interval_list
      - bait_interval_list
  preprocessing:
    run: ../subworkflows/exomeseq-gatk4-01-preprocessing.cwl
    in:
      intervals: target_intervals
      target_interval_list: prepare_reference_data/target_interval_list
      bait_interval_list: prepare_reference_data/bait_interval_list
      read_pair: read_pair
      reference_genome: reference_genome
      threads: threads
      library: library
      platform: platform
      known_sites: known_sites
    out:
      - fastqc_reports
      - trim_reports
      - markduplicates_bam
      - recalibration_table
      - recalibrated_reads
