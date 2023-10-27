# Bioinformatics Tutorial: Quality Assessment of Data with FastQC

The first step of most biofinformatic analyses is to assess the quality of the data you have recieved. In this example, we are working with real DNA sequencing data from a research project studying E. coli. We will use a common software, [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), to assess the quality of the data.  

Before we start, let us make sure we are in out `tutorial-fastqc` directory by printing our working directory:


```bash
cd ~/tutorial-fastqc
```


```bash
pwd
```

We should see `/home/<username>/tutorial-fastqc`.

## Step 1: Download data

First, we need to download our sequencing data to that we want to analyze for our research project. For this tutorial, we will be downloading data used in the Data Carpentry workshop. This data includes both the genome of Escherichia coli (E. coli) and paired-end RNA sequencing reads obtained from a study carried out by Blount et al. published in [PNAS](http://www.pnas.org/content/105/23/7899). Additional information about how the data was modified in preparation for this analysis can be found on the [Data Carpentry's workshop website](https://datacarpentry.org/wrangling-genomics/aio.html).

We have a script called `download_data.sh` that will download our bioinformatic data. Let's go ahead and run this script to download our data. 


```bash
./download_data.sh
```

Our sequencing data files, all ending in .fastq, can now be found in a folder called /data. 

## Step 2: Prepare software

Now that we have our data, we need to install the software we want to use to analyze it. 

There are different ways to install and use software, including installing from source, using pre-compiled binaries, and containers. In the biology domains, many software packages are already available as pre-built containers. We can fetch one of these containers and have HTCondor set it up for our job, which means we do not have to install the FastQC software or it's dependencies. 

We will use a Docker container built by the State Public Health Bioinformatics Community (staphb), and convert it to an apptainer container by creating an apptainer definition file: 


```bash
ls software/
```


```bash
cat software/fastqc.def
```

And then running a command to build an apptainer container (which we won't run, but is listed here for future reference): 
`$ apptainer build fastqc.sif software/fastqc.def`

Instead, we will download our ready-to-go apptainer .sif file:


```bash
./download_software.sh
```


```bash
ls software/
```

## Step 3: Prepare an Executable

We need to create an executable to pass to our HTCondor jobs, so that HTCondor knows what to run on our behalf. 

Let's take a look at our executable, `fastqc.sh`:


```bash
cat fastqc.sh
```

# Step 4: Prepare HTCondor Submit File to Run One Job

Now we create our HTCondor submit file, which tells HTCondor what to run and how many resources to make available to our job:


```bash
cat fastqc.submit
```

## Step 5: Submit One HTCondor Job and Check Results

We are ready to submit our first job!


```bash
condor_submit fastqc.submit
```

We can check on the status of our job in HTCondor's queue using:


```bash
condor_q
```

By using transfer_output_remaps in our submit file, we told HTCondor to store our FastQC output files in the results directory. Let's take a look at our scientific results:


```bash
ls results/
```

It's always good practice to look at our standard error, standard out, and HTCondor log files to catch unexpected output:


```bash
ls logs/
```

## Step 5: Scale Out Your Analysis

### Create A List of All Files We Want Analyzed

To queue a job to analyze each of our sequencing data files, we will take advantage of HTCondor's `queue` statement. First, let's create a list of files we want analyzed:


```bash
ls data/ | cut -f1 -d "." > list_of_samples.txt
```

Let us take a look at the contents of this file: 


```bash
cat list_of_samples.txt
```

Edits the Submit File to Queue a Job to Analyze Each Biological Sample

HTCondor has different `queue` syntaxes to help researchers automatically queue many jobs. We will use `queue <variable> from <list.txt>` to queue a job for each of of our samples in `list_of_samples.txt`. 

Once we define `<variable>`, we can also use it elsewhere in the submit file. 

Let's replace each occurence of the sample identifier with the `$(sample)` variable, and then iterating through our list of samples as shown in `list_of_samples.txt`.


```bash
cat many-fastqc.submit
```

    # HTCondor Submit File: fastqc.submit
    
    # Provide our executable and arguments
    executable = fastqc.sh
    arguments = $(sample).trim.sub.fastq
    
    # Provide the container for our software
    universe    = container
    container_image = software/fastqc.sif
    
    # List files that need to be transferred to the job
    transfer_input_files = data/$(sample).trim.sub.fastq
    should_transfer_files = YES
    
    # Tell HTCondor to transfer output to our /results directory
    transfer_output_files = $(sample).trim.sub_fastqc.html
    transfer_output_remaps = "$(sample).trim.sub_fastqc.html = results/$(sample).trim.sub_fastqc.html"
    
    # Track job information
    log = logs/fastqc.log
    output = logs/fastqc.out
    error = logs/fastqc.err
    
    # Resource Requests
    request_cpus = 1
    request_memory = 1GB
    request_disk = 1GB
    
    # Tell HTCondor to run our job once:
    queue sample from list_of_samples.txt


And then submit many jobs using this single submit file!


```bash
condor_submit many-fastqc.submit
```

Notice that using a **single submit file**, we now have **multiple jobs in the queue**.

We can check on the status of our multiple jobs in HTCondor's queue by using:


```bash
condor_q
```

When ready, we can check our results in our `results/` directory:

```bash
ls results/
```

## Step 6: Return the output to your local computer

Once you are done with your computational analysis, you will want to move the results to your local computer or to a long term storage location.

Let's practice copying our `.html` files to our local laptop. 

First, open a new terminal. Do not log into your OSPool account. Instead, navigate to where you want the files to go on your computer. We will store them in our `Downloads` folder. 

```bash
cd ~/Downloads
```
Then use `scp` ("secure copy") command to copy our results folder and it's contents:

```bash
scp -r username@hostname:/home/username/folder ./
```
For many files, it will be easiest to create a compressed tarball (.tar.gz file) of your files and transfer that instead of each file individually.

An example of this could be `scp -r username@ap40.uw.osg-htc.org:/home/username/results ./`

Now, open the `.html` files using your internet browser on your local computer. 

**Congratulations on finishing the first step of a sequencing analysis pipeline!**

