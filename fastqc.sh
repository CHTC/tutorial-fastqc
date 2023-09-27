#!/bin/bash
# Executable name: fastqc.sh

# Prepare software environment
export PATH=/FastQC:/usr/lib/jvm/java-11-openjdk-amd64/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/jli

# Run FastQC to determine the quality of our raw .fastq sequencing data
fastqc $1
