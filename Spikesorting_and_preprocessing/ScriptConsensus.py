

import os
import spikeinterface as si
import spikeinterface.extractors as se 
import spikeinterface.toolkit as st
import spikeinterface.sorters as ss
import spikeinterface.comparison as sc
import spikeinterface.widgets as sw
from spikeinterface.toolkit.postprocessing import compute_principal_components
from spikeinterface.toolkit.qualitymetrics import (compute_snrs, compute_firing_rate,
     compute_isi_violations, calculate_pc_metrics, compute_quality_metrics)
import tempfile

os.environ['TEMPDIR'] = tempfile.gettempdir()
import matplotlib.pyplot as plt
import numpy as np
import json
from spikeinterface.exporters import export_to_phy

def creatparam(direc):
    

    parameter = {"samplerate": 30000, "spike_sign": -1}
    geom = np.array([[1, 0],[2, 0],[3, 0],[4, 0]])
    #ED mod file name handling
    np.savetxt(os.path.join(direc,'geom.csv'), geom, delimiter=',')
    # ED mod file name handling
    this_file_path = os.path.join(direc,'params.json')
    with open(this_file_path, 'w') as mon_fichier:
    	json.dump(parameter, mon_fichier)
        
    print('Should have saved param file to:',this_file_path )

def run_trid(recording,directory_output):
    print(ss.installed_sorters())
    default_TDC_params = ss.TridesclousSorter.default_params()
    print(default_TDC_params)
    # tridesclous spike sorting
    default_TDC_params['detect_threshold'] = 5
    
    # parameters set by params dictionary
    sorting_TDC_5 = ss.run_tridesclous(recording=recording, output_folder=directory_output+'/tmp_TDC_5',
                                       **default_TDC_params )
    #ED added use of os.path.join
    # this_output_folder = os.path.join(directory_output,'wf_MS')
    # we_all = si.extract_waveforms(recording, sorting_TDC_5, folder = this_output_folder, 
    #                                   max_spikes_per_unit = None, progress_bar = True)
    # #ED added use of os.path.join
    # this_output_folder = os.path.join(directory_output,'phy_MS')
    # export_to_phy(we_all, output_folder = this_output_folder,
    #                   progress_bar = True, total_memory = '100M')
    return sorting_TDC_5
    
def run_iron(recording,directory_output):
    ss.IronClustSorter.set_ironclust_path('/mnt/genzel/Rat/HM/Rat_HM_Ephys/Preprocess/Script/ironclust')
    ss.IronClustSorter.ironclust_path
    ss.installed_sorters()
    # run spike sorting by group
    sorting_IC = ss.run_ironclust(recording, 
                                  output_folder= directory_output + '/results_IC',
                                  verbose=True)
    this_output_folder = os.path.join(directory_output,'wf_IC')
    we_all = si.extract_waveforms(recording, sorting_IC, folder = this_output_folder, 
                                      max_spikes_per_unit = None, progress_bar = True)
    #ED added use of os.path.join
    this_output_folder = os.path.join(directory_output,'phy_IC')
    export_to_phy(we_all, output_folder = this_output_folder,
                      progress_bar = True, total_memory = '100M')
    return sorting_IC

def run_Waveclus(recording,directory_output):
    ss.WaveClusSorter.set_waveclus_path('/media/genzel/TOSHIBAEXT/wave_clus/')
    
    ss.installed_sorters()
    # run spike sorting by group
    sorting_WC = ss.run_waveclus(recording, 
                                  output_folder= directory_output + '/results_WC',
                                  verbose=True)
    
    we_all = si.extract_waveforms(recording, sorting_WC, folder=directory_output+"/wf_WC_all", 
                                      max_spikes_per_unit=None, progress_bar=True)
    
    #export_to_phy(we_all, output_folder=directory_output+'/phy_WC',
     #                progress_bar=True, total_memory='100M')

def run_Mountainsort(recording, directory_output): ##Function that will run mountainsort, extract the information from mountainsort and export to phy
    ss.installed_sorters()
    default_MS = ss.Mountainsort4Sorter.default_params()
    print(default_MS)
    default_MS['num_workers'] = 4
    default_MS['detect_threshold'] = 5
    this_output_folder = os.path.join(directory_output, 'results_MS')
    sorting_MS = ss.run_mountainsort4(recording,
                                      output_folder = this_output_folder,
                                      verbose = True, **default_MS,)
        
    #ED added use of os.path.join
    this_output_folder = os.path.join(directory_output,'wf_MS')
    we_all = si.extract_waveforms(recording, sorting_MS, folder = this_output_folder, 
                                      max_spikes_per_unit = None, progress_bar = True,total_memory = '100M', n_jobs=4)
    #ED added use of os.path.join
    this_output_folder = os.path.join(directory_output,'phy_MS')
    export_to_phy(we_all, output_folder = this_output_folder,
                      progress_bar = True, total_memory = '100M', n_jobs=4)
    return sorting_MS


def comp(recording,sortingIron,sortingMount,sortingTri,directory_output):
    
    mcmp = sc.compare_multiple_sorters([sortingIron, sortingMount, sortingTri], ['IC', 'MS4', 'TDC'], 
                                            spiketrain_mode='union', verbose=True)
    if consensus_found(mcmp):
        w = sw.plot_multicomp_agreement(mcmp)
        w = sw.plot_multicomp_agreement_by_sorter(mcmp)
        sw.plot_multicomp_graph(mcmp)
    
        agr_3 = mcmp.get_agreement_sorting(minimum_agreement_count=2)
        we_agr = si.extract_waveforms(recording, agr_3, folder=directory_output+"/wf_agr", 
                                          max_spikes_per_unit=None, progress_bar=True,total_memory='100M', n_jobs=4)
        export_to_phy(we_agr, output_folder=directory_output+'/phy_AGR',
                          progress_bar=True)
    else:
        js = {"Consensus": False}
        this_file_path = os.path.join(directory_output,'consensus.json')
        with open(this_file_path, 'w') as mon_fichier:
                json.dump(js, mon_fichier)
        print('no consensus found')

def consensus_found(compare):
    """
    Checks if consensus is found.

    Parameters
    ----------
    compare : AgreementSortingExtractor
        Result from running the solters.

    Returns
    -------
    check : boolean
        True if consensus is found.

    """
    check = False
    for i in compare.compute_subgraphs()[0]:
        if len(i) > 1:
            check = True
            break
    return check

def qual(recording,sorting, folder):
    this_output_folder = os.path.join(folder, 'qual')
    we = si.extract_waveforms(recording, sorting, folder = this_output_folder, max_spikes_per_unit = None, progress_bar = True,total_memory = '100M', n_jobs=4)
    #ED added use of os.path.join
    print(we)
    firing_rates = compute_firing_rate(we)
    print(firing_rates)
    isi_violation_ratio, isi_violations_rate, isi_violations_count = compute_isi_violations(we)
    print(isi_violation_ratio)
    snrs = compute_snrs(we)
    print(snrs)
    
    pc = compute_principal_components(we, load_if_exists=True,
                                     n_components=3, mode='by_channel_local')
    print(pc)

    pc_metrics = calculate_pc_metrics(pc, metric_names=['nearest_neighbor'])
    print(pc_metrics)
    os.makedirs(this_output_folder, exist_ok=True)  
    metrics = compute_quality_metrics(we)
    print(metrics)
    metrics.to_csv(this_output_folder+'metrics.csv')                   

def main():
    #tetrodes_list = [7,9,28,29,30,4,2,25,24,31,12,14,23,17]
    tetrodes_list = [30]
    #ED: the 'input' command makes Spyder crash. So we will input the files 
    # directly as variables here instead for now.
    # directory = input("Enter the data directory: ")
    # name = input("Enter the name of the file to spikesort: ")
    directory = "/media/genzel/data/spikesorting/Rat/Rat4_20201109"
    if not os.path.isdir(directory):
        print('Directory not found!')
    print(directory)
    # name = 'tetrode_recording.nt1.mda'
    # From Caitlin: I think 2, 4, 6, 7, 8, 22 and 30 are the best.
    
    # Extract all tetrodes mentioned in tetrode list
    for tt_num in tetrodes_list:
        this_name = 'Rat_Hm_Ephys_Rat4_389239_20201109_Maze_merged_nt' + str(tt_num) + '_Preprocess_detrend.mda'   

        output = os.path.join('/media/genzel/data/spikesorting/Rat/Rat4_20201109', 'AGR_detrend_preprocessed_output_T' + str(tt_num))
        #output = os.path.join('/ceph/genzel/Rat/HM/Rat_HM_Ephys/Preprocess/Rat1_20200909', 'test_output_T' + str(tt_num))
        
        # output = directory+'\output' # Note the backslash will change between linux and win
        # EDresults_MS
        creatparam(directory) #Create the parameter and geom file
        print('Running Mountainsort on file:' + this_name + '...')
        rec = se.MdaRecordingExtractor(directory,raw_fname=this_name,params_fname='params.json',geom_fname='geom.csv')
        w = sw.plot_timeseries(rec) #plot the first second of the recording

        recording_f = st.bandpass_filter(rec, freq_min=300, freq_max=6000) #Band pass filtering
        
        w = sw.plot_timeseries(recording_f)
        rec.annotate(is_filtered=True)
        SortingI = run_iron(recording_f,output) ## Run mountainsort and export to phy
        SortingM = run_Mountainsort(recording_f,output) ## Run mountainsort and export to phy
        SortingT = run_trid(recording_f,output) ## Run mountainsort and export to phy
        comp(recording_f,SortingI,SortingM,SortingT,output)
        qual(recording_f,SortingM,output)
        run_phy = 0
    
        if run_phy:
            from phy.apps.template import template_gui
            this_data_folder = "/media/genzel/data/spikesorting/Rat/Rat2_20200910"
            this_tt = '24' 
            this_params_file = os.path.join(this_data_folder, 'preprocessed_output_T' + this_tt, 'phy_MS/' 'params.py')
            if not os.path.isfile(this_params_file):
                print('File not found!')
            template_gui(this_params_file)
     
  
if __name__ == '__main__':
    main()