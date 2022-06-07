# -*- coding: utf-8 -*-
"""
Created on Mon Apr 11 10:22:17 2022

@author: kayva
"""

import os
import spikeinterface as si
import spikeinterface.extractors as se 
import spikeinterface.toolkit as st
import spikeinterface.sorters as ss
import spikeinterface.comparison as sc
import spikeinterface.widgets as sw
from mountainlab_pytools import mdaio
import tempfile

os.environ['TEMPDIR'] = tempfile.gettempdir()
import matplotlib.pyplot as plt
import numpy as np
 
from spikeinterface.exporters import export_to_phy

def creatparam(direc):
    import json

    parameter = {"samplerate": 30000, "spike_sign": -1}
    geom = np.array([[1, 0],[2, 0],[3, 0],[4, 0]])
    np.savetxt(direc+'geom.csv', geom, delimiter=',')

    with open(direc+'params.json', 'w') as mon_fichier:
    	json.dump(parameter, mon_fichier)

def run_trid(recording,directory_output):
    print(ss.installed_sorters())
    default_TDC_params = ss.TridesclousSorter.default_params()
    print(default_TDC_params)
    # tridesclous spike sorting
    default_TDC_params['detect_threshold'] = 3
    
    # parameters set by params dictionary
    sorting_TDC_5 = ss.run_tridesclous(recording=recording, output_folder=directory_output+'/tmp_TDC_5',
                                       **default_TDC_params )
    we_all = si.extract_waveforms(recording, sorting_TDC_5, folder=directory_output+"/wf_TDC_all", 
                                      max_spikes_per_unit=None, progress_bar=True)
    export_to_phy(we_all, output_folder=directory_output+'/phy_TDC',
                  progress_bar=True, total_memory='100M')
    
def run_iron(recording,directory_output):
    ss.IronClustSorter.set_ironclust_path('/home/genzel/Downloads/ironclust')
    ss.IronClustSorter.ironclust_path
    ss.installed_sorters()
    # run spike sorting by group
    sorting_IC = ss.run_ironclust(recording, 
                                  output_folder= directory_output + '/results_IC',
                                  verbose=True)
    
    w_rs = sw.plot_rasters(sorting_IC)
    
    we_all = si.extract_waveforms(recording_f, sorting_IC, folder=directory_output+"/wf_IC_all", 
                                      max_spikes_per_unit=None, progress_bar=True)
    
    export_to_phy(we_all, output_folder=directory_output+'/phy_IC',
                     progress_bar=True, total_memory='100M')
    
def metrics(waveform):
    
    folder = 'waveforms_mearec'
    firing_rates = st.compute_firing_rate(we_all)
    print(firing_rates)
    isi_violation_ratio, isi_violations_rate, isi_violations_count = st.compute_isi_violations(we_all)
    print(isi_violation_ratio)
    snrs = st.compute_snrs(we_all)
    print(snrs)
    
    pc = st.compute_principal_components(we_all, load_if_exists=True,
                                         n_components=3, mode='by_channel_local')
    print(pc)
    
    pc_metrics = st.calculate_pc_metrics(pc, metric_names=['nearest_neighbor'])
    print(pc_metrics)
    metrics = st.compute_quality_metrics(we_all, )
    print(metrics)

def run_Waveclus(recording,directory_output):
    ss.WaveClusSorter.set_waveclus_path('/media/genzel/TOSHIBA EXT/wave_clus/')
    
    ss.installed_sorters()
    # run spike sorting by group
    sorting_WC = ss.run_waveclus(recording, 
                                  output_folder= directory_output + '/results_WC',
                                  verbose=True)
    
    we_all = si.extract_waveforms(recording_f, sorting_WC, folder=directory_output+"/wf_WC_all", 
                                      max_spikes_per_unit=None, progress_bar=True)
    
    export_to_phy(we_all, output_folder=directory_output+'/phy_WC',
                     progress_bar=True, total_memory='100M')

def run_Mountainsort(recording,directory_output):
    ss.installed_sorters()
    default_MS = ss.Mountainsort4Sorter.default_params()
    # x = np.array(1)
    # for i in range(1,7):
    #     default_MS['detect_threshold'] = i
    #     default_MS['num_workers'] = 4
    #     print(default_MS)
    #     sorting_MS = ss.run_mountainsort4(recording, output_folder=directory_output+'/results_MS', verbose=True, **default_MS,)
    #     nbcluster = sorting_MS.get_num_units()
    #     x=np.append(x,nbcluster)
    # print(x)
    # x = np.delete(x, 0,0)
    
    # default_MS['detect_threshold'] = 7
    print(default_MS)
    sorting_MS = ss.run_mountainsort4(recording, output_folder=directory_output+'/results_MS', verbose=True, **default_MS,)
        
    we_all = si.extract_waveforms(recording, sorting_MS, folder=directory_output+"/wf_MS", 
                                      max_spikes_per_unit=None, progress_bar=True)
    
    export_to_phy(we_all, output_folder=directory_output+'/phy_MS',
                      progress_bar=True, total_memory='100M')

def run_Klusta(recording,directory_output):
    ss.installed_sorters()
    
    # run spike sorting on entire recording
    sorting_KS = ss.run_klusta(recording_saved, output_folder=directory_output+'/results_KS', verbose=True)
    print('Found', len(sorting_KS.get_unit_ids()), 'units')

def comp(sorting):

    mcmp = sc.compare_multiple_sorters(sorting, [ 'IC', 'MS4', 'TDC'], 
                                           spiketrain_mode='union', verbose=True)
    
    # mcmp = sc.compare_multiple_sorters([sorting_KS, sorting_IC, sorting_MS, sorting_TDC_5], ['KS', 'IC', 'MS4', 'TDC'], 
    #                                        spiketrain_mode='union', verbose=True)
    w = sw.plot_multicomp_agreement(mcmp)
    w = sw.plot_multicomp_agreement_by_sorter(mcmp)
    sw.plot_multicomp_graph(mcmp)
    agr_3 = mcmp.get_agreement_sorting(minimum_agreement_count=2)


directory = input("Enter the directory: ")
print(directory)
rat = input("Enter the rat (ex : Rat1): ")
studyday = input("Enter the StudyDay: ")
number = input("Enter the TSU number : ")
tetrode = input("Enter the tetrode number (nt2) : ")

directory_mda = directory+'/'+rat+'_'+studyday+'/'
output = directory+'/'+rat+'_'+studyday+'/Result_'+rat+'_'+studyday+'_'+tetrode
creatparam(directory_mda)
rec = se.MdaRecordingExtractor(directory_mda,raw_fname='/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+tetrode+'Preprocess.mda',params_fname='params.json',geom_fname='geom.csv')
w = sw.plot_timeseries(rec)
recording_f = st.bandpass_filter(rec, freq_min=300, freq_max=6000)
w = sw.plot_timeseries(recording_f)
rec.annotate(is_filtered=True)
run_iron(recording_f,output)
run_Mountainsort(recording_f,output)

# rec = se.MdaRecordingExtractor('/media/genzel/TOSHIBAEXT/rat2/Rat_Hm_Ephys_Rat2_389237_20200915_presleep.mountainsort',raw_fname='Rat_Hm_Ephys_Rat2_389237_20200915_presleep.nt3.mda',params_fname='params.json',geom_fname='geom.csv')
# w = sw.plot_timeseries(rec)
# #%%

# sorting_check = se.PhySortingExtractor('/media/genzel/TOSHIBAEXT/rat2/result_trode13/phy_IC')
# print(f'Spike train of a unit: {sorting_check.get_unit_spike_train(1)}')
# timestamps = sorting_check.get_unit_spike_train(1)
# recording = mdaio.readmda(directory+'Flaten13.mda')
# import pandas as pd
# recording = pd.DataFrame(recording).transpose()
# recording.columns = ['wavech1','wavech2','wavech3','wavech4']
# recording.reset_index()
# wavemeanBP = np.zeros([400,4])

# for i in timestamps:
#     if np.where(recording.index==i):
#         waveBP = recording.iloc[i-200:i+200]
#         waveBP = waveBP.to_numpy()
#         wavemeanBP = wavemeanBP+ waveBP
       
# wavemeanBP = wavemeanBP/timestamps.shape[0]
# wavemeanBP = pd.DataFrame(wavemeanBP)
# wavemeanBP.columns = ['wavech1','wavech2','wavech3','wavech4']
# pltBP = wavemeanBP.plot(kind='line')





# def butter_bandpass(lowcut, highcut, fs, order=5):
#     return butter(order, [lowcut, highcut], fs=fs, btype='band')

# def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
#     b, a = butter_bandpass(lowcut, highcut, fs, order=order)
#     y = lfilter(b, a, data)
#     return y


# # sign.plot(kind='line')
# fe = 30000
# f_nyq = fe/2
# fc1 = 300
# fc2 = 6000
# cut = recording.iloc[647971786-100:647971786+100]
# cut = cut.to_numpy()
# meanBP=wavemeanBP.to_numpy()
# recording1 = butter_bandpass_filter(cut[:, 0], 300, 6000, fe, order=5)
# recording2 = butter_bandpass_filter(cut[:, 1], 300, 6000, fe, order=5)
# recording3 = butter_bandpass_filter(cut[:, 2], 300, 6000, fe, order=5)
# recording4 = butter_bandpass_filter(cut[:, 3], 300, 6000, fe, order=5)
# recording1 = pd.DataFrame(recording1)
# recording2 = pd.DataFrame(recording2)
# recording3 = pd.DataFrame(recording3)
# recording4 = pd.DataFrame(recording4)
# df = pd.concat([recording1, recording2,recording3,recording4], axis=1)


# df.plot(kind='line')
# recording[90000:150000].plot(kind='line')



# recording.plot()


# #%%

# we_all = si.extract_waveforms(recording_saved, sorting_check, folder="/media/genzel/TOSHIBAEXT/Rat4_mda/rawConcate//wf_check", 
#                                   max_spikes_per_unit=None, progress_bar=True)
# export_to_phy(we_all , output_folder='/media/genzel/TOSHIBAEXT/Rat4_mda/rawConcate/phy_check')

# os.system('phy template-gui /media/genzel/TOSHIBAEXT/Rat4_mda/rawConcate/phy_MS/params.py')


# import sys
# import matplotlib.pyplot as plt
# from phylib.io.model import load_model
# from phylib.utils.color import selected_cluster_color

# # First, we load the TemplateModel.
# model = load_model(directory_output+'/phy_MS')  # first argument: path to params.py

# # We obtain the cluster id from the command-line arguments.
# cluster_id = int(7)  # second argument: cluster index

# # We get the waveforms of the cluster.
# waveforms = model.get_cluster_spike_waveforms(cluster_id)
# n_spikes, n_samples, n_channels_loc = waveforms.shape

# # We get the channel ids where the waveforms are located.
# channel_ids = model.get_cluster_channels(cluster_id)

# # We plot the waveforms on the first four channels.
# f, axes = plt.subplots(1, min(4, n_channels_loc), sharey=True)
# for ch in range(min(4, n_channels_loc)):
#     axes[ch].plot(waveforms[::100, :, ch].T, c=selected_cluster_color(0, .05))
#     axes[ch].set_title("channel %d" % channel_ids[ch])
# plt.show()
