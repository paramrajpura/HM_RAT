Dependencies: To-add. 

# Convertion from .rec to .mda
```
./trodesexport -mountainsort -rec /mnt/genzel/Rat/HM/Rat_HM_Ephys/Rat_HM_Ephys_Rat5_406576/Rat_HM_Ephys_Rat5_406576_20210614/Rat_Hm_Ephys_Rat5_406576_20210614_presleep/Rat_Hm_Ephys_Rat5_406576_20210614_presleep.rec -sortingmode 1
./trodesexport -mountainsort -rec
```

# DownsamplingMDAfile
DownsamplingMDAfile
## Installation 


# Hexmaze Rat scripts
Repository for Hexmaze Rat project. 

## Main scripts: :file_folder: 
```
pip install numpy
pip install pandas
pip install scipy
```

## LFP analysis (Emanuele Ciardo)
_**Data preprocessing:**_ 
You need to add the file mdaio to the python path

  * main.m : The script receives as an input an .mda file - which has already been downsampled - that the user can select once the pop-up is opened. The main action it perform are:
-select the NREM portion of the recording. This is done by loading a second file where the sleepscoring file “states” is stored

_**IC selection:**_ 

  *main_ica : The script receives as input the output of the script ‘main’. It has the purpose to assess which independent components are to be removed. Since this approach has been ruled out, this script should be greatly modified. Another purpose of this script is to select the channels of interest (1 for PFC, 1 for HPC)

_**Event detection:**_ 

  * main_event : The script receives as input the output of the script ‘main_ica’. It performs 2 actions:

-removes artefacts.  It is done in 2 ways: 1) for normal movement artefacts it relies on an amplitude-based threshold; 2) for the resetting artefact it relies on a slightly finer algorithm, which takes into account the second derivative of the signal and the distance between detected artefacts, thus exploting the periodic nature of the artefact

-parces the signal into NREM bouts. This step is required for the subsequent event detection

-event detection. The user can choose what to detect: ripples, spindles, delta or all of them. The user can then, while examining the plotted detections, decide to modify the thresholds for the detection.




**Data analysis:**_ 

  * main_analysis: performs basic analysis: counting of the events and detection of sequences and cooccurrences of events

## Spikesorting : (Kayvan Combadiere) :file_folder: 

_**Installation and environment:**_

On the JAPAN PC, the environment is already installed and named testphy

Create a new environment, Python needs to be >=3.7

```conda create --name environmnent```

Activate your environment
If you want to use spyder

```conda install spyder```

for spikeinterface installation

```pip install spikeinterface[full]==0.94```

```pip install phy --pre --upgrade```

For Mountainsort4 in spikeinterface

```pip install mountainsort4```

if this step fails, it means you need to do the following pip install git+https://github.com/magland/isosplit5_python.git (you might have to do pip install git separately first, if git is not already installed)

For Tridesclous in spikeinterface

```pip install tridesclous```

For IronClust

Follow the procedure on https://spikeinterface.readthedocs.io/en/latest/install_sorters.html

Usage

To export the data from Trodes : navigate to the Trodes folder and then type

`trodesexport -mountainsort -rec <full path to rec file ending in .rec> -sortingmode 1`

(this will create 1 '.mda' file per tetrode, which is what Mountainsort expects)

_**Square Shape Artefact removal:**_ 

  * Preprocessing_squareArtefact.py 

This file will performe concatenation and removal of the "square shape artefact". Depending on the size of the files it use a lot of memory usage.
This Python script works by concatenating the file 

File to preprocess should be in 3 different Folder :
  * mda_extracted_presleep
  * mda_extracted_maze
  * mda_extracted_postsleep

Each folder the mda extraction from trode of the files.

The script will ask : the directory of those folder, which rat, on what study day and the TNU number of the rat.

Output :

It will create a new folder named preprocess with the concated and preprocess file in it group by rat and studyday.

_**Detrending:**_ 

  * TestChronux.m

MATLAB needed

This process will detrend the signal of a recording. This MATLAB script use the local detrend function from Chronux to create a linear regression
on a moving local window of 0.1 second

How to Use it :
- Decompress the folder chronux2.12. 

- In matlab go to your directory with the function, add the chronux folder and subfolder to the path.

- Change the directory to the recording (MDA file) of the file you want to detrend in sig = readmda('PATH').

- Change the name of the output recording file

Output :

MDA file of the localy detrend signal

_**Spike sorting:**_ 


  * scriptConsensus.py

2 options to run the code:

Open the script 'ScriptConsensus.py', update tetrodes_list and optionally path_to_file to indicate the '.rec' raw data file. Run the code by pressing F5.

Note 1: you'll have to be in the right conda environment!

Note 2: this will create 1 subfolder per tetrode. It will use the inbuilt function of spikeinterface to run either the consensus or mountainsort if no consensus found and export to phy the result.

Once the main code has run: 2 options for the manual refinement with Phy:

    Option 1. Run, from python:

from phy.apps.template import template_gui
this_params_file = path_to_data\output_TX\phy_MS\params.py (where X = the tetrode to be sorted)
template_gui(this_params_file)

    Option 2: Run, from a command line:

phy template-gui path_to_data\output_Tx\phy_MS\params.py 
(change the X to be the tetrode number of your choice)


This script will do the spike sorting.The Python script use spikeinterface library to implement a consensus between MountainSort4 IronClust and tridesclous.(Further Sorter can be installed). The output of this file is a folder for PHY visualisation and manual curation.

How to Use it :
- Change the list_tetrode[] with the number of tetrode you want to use.

- Change the path to the recording (MDA file), the path of the OutPut

Output :

Phy folder of the tetrode in the list_tetrode of the recording
## Running the script
It will ask as an input the path to the folder where the mda file are stored
And create a folder as an output with the downsampled mda file per study day in the folder where the mda file are stored
