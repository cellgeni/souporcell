
| <h1>⚠️ This repo has been archived. Please use [nf-demultiplex](https://github.com/cellgeni/nf-demultiplex) </h1>|
| ----------------------------------------------------------------------------------------------- |


# Souporcell
Repo containing our scripts for running souporcell


### Directory structure should be as followed:

top level directories - actions, data, work

actions - contains all the scripts which are used to run souporcell

data - contains subdirectories for each sample with sampleid as name, output is written to these subdirectories

work - contains logs subdirectory which stores all the log files for running souporcell

### Getting Data

Please note this getting data section is specific to the Sanger IRODs system. If you are not getting data from IRODs on the FARM ignore this step.

Ensure the file `irods.txt` contains 2 tab separated fields. The first contains a sample IDs and the second contains a path to the location on irods. 
Each row contains a single sample ID and its corresponding irods path as shown below:

```bash
HCA_BN_F12627470_and_HCA_BN_F12605339	/seq/illumina/cellranger-arc/cellranger-arc201_count_064b1aef6f2236956380fb5c29e21639
HCA_BN_F12627473_and_HCA_BN_F12605342	/seq/illumina/cellranger-arc/cellranger-arc201_count_4dca0a7604dad9e18f43910b87d4dc1e
```

Run the script `get.sh` inside the `data` directory and it will download all the relevant data. If you have different file names to the default edit `get.sh` as the comments instruct. I recommend using a screen session for this process.
To run the script simply:

```bash
cd data
../actions/get.sh
```

### Running souporcell

Ensure your sample ID list is contained within the `samples.txt` file. It should be a single field file containing one sample ID per row. I.e.

```bash
HCA_BN_F12627470_and_HCA_BN_F12605339
HCA_BN_F12627473_and_HCA_BN_F12605342
```

Run the script `submit.sh` inside the `work` directory. 

```bash
cd work
../actions/submit.sh
```

If you need to change the donor values or resources used then edit the `submit.sh` script as appropriate. If you want to change the souporcell parameters
then edit the `spoon.sh` script.

Jobs will be submitted to the FARM, they can be monitored with the command `bjobs` or you can look at the log and error files within the `logs` subdirectory.

**Note on compressed (`.gz`) files**: both VCF and barcodes files need to be extracted if they are compressed before running `spoon.sh`. i.e.: for `barcode.tsv.gz` run `gunzip barcode.tsv.gz` to extract the barcode file.

### Running shared_samples.py

Run the script `twosubmit.sh` inside the `shared_samples` directory. I recommend doing this on a screen session.

```bash
cd shared_samples
../actions/twosubmit.sh
```

If you need to change the donor shared value, edit the `twosubmit.sh` script

Please note if you are comparing samples that had souporcell ran with different k values, use the larger k value for n shared. Also ensure that the 
samples with the smaller k value are submitted in the second `cat samplefile` so that there are no indexing errors. This will mean having 2 sample 
files that are read.
