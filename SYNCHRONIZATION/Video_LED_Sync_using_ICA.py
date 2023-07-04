# -*- coding: utf-8 -*-
"""
Created on Fri June 16 14:08:05 2023

@author: paramrajpura
"""

# Compiled from the previous works :
# https://github.com/genzellab/HM_RAT/blob/main/SYNCHRONIZATION/synch_editedbyOzge.py
# https://github.com/genzellab/HM_RAT/blob/main/SYNCHRONIZATION/Exctract_LEDs_28_01_2023.ipynb
# https://github.com/genzellab/HM_RAT/blob/main/SYNCHRONIZATION/synchronization.py


import os
import cv2
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
#from tqdm.notebook import tqdm, tnrange
from sklearn.decomposition import FastICA
from sklearn.cluster import KMeans
import pandas as pd
from datetime import datetime , time , timedelta
import re
import functools as ft
from sklearn.linear_model import LinearRegression
import argparse
import sys




'''
    The basepath must contain the following files:
    1. Eye video files: .mp4 formats (12 files for each eye)
    2. X,y co-ordinates of crops for LED positions : .led_crop format (1 file containing 12 xy co-ordinates)
    3. Time stamp files containing framewise clock timestamps after linear regression: .csv format (12 files)
        Note: TODO: Add the logic of meta to .csv conversion using Linear regression in this script.
    4. Time stamps recorded from LED controller referred to as DIO: .dat format (3 files for red,blue and 
    initial systime)
        a. Rat4_20201109_maze.dio_MCU_Din1.dat for initial time stamp
        b. Rat4_20201109_maze_merged.dio_MCU_Din1.dat for blue DIO
        c. Rat4_20201109_maze_merged.dio_MCU_Din2.dat for red DIO
'''


# Reads all the mp4 files in the folder, checks for a led_crop_coordinates file and meta file
def get_video_files_with_metadata(basepath,led_xy=True,time_stamp=True, info=True):
    path = Path(basepath).resolve()
    videos_filepath_list = list(sorted(path.glob('*eye*.mp4')))
#     print(videos_filepath_list)
    
    crop_xy_dict = {}
    # Verify if led_coordinates supplied
    if led_xy:
        crop_file_list = list(sorted(path.glob('*.led_crop')))
#         print(crop_file_list)
        if crop_file_list:
            # read crops coords for each video and store
            with open(crop_file_list[0]) as f:
                crop_txt = f.readlines()
#                 print(crop_txt)
            for line in crop_txt:
                try:
                    vid_path, x, y = line.split(',')
                    crop_xy_dict[vid_path] = (int(x), int(y))
                except ValueError:
                    print("Faulty line:", line, 'Maybe led coordinates are missing?')
                    break
        else:
            raise Exception("File containing led crop coordinates not found.")
    if time_stamp:
        # csv files no longer required since ts data extracted from meta files
#         tsdata_filepath_list = list(sorted(path.glob('*.csv')))
        meta_filepath_list = list(sorted(path.glob('*.meta')))
        
    #TODO: Verify for single file path in the list to avoid conflicting data
    dio_file_path_dict={}
    dio_file_path_dict['init'] = list(sorted(path.glob('*maze.*.dat')))
    
    dio_file_path_dict['blue'] = list(sorted(path.glob('*maze_merged*Din1.dat')))
    dio_file_path_dict['red'] = list(sorted(path.glob('*maze_merged*Din2.dat')))

    if info:
        
        print(f"Following {len(videos_filepath_list)} videos will be processed:")
        for file in videos_filepath_list:
            print(str(file))

        print(f"Following {len(meta_filepath_list)} meta files will be processed:")
        for file in meta_filepath_list:
            print(str(file))

        print(f"Following {len(crop_xy_dict)} crop co-ordinates will be processed:")
        for file in crop_xy_dict:
            print(str(file),crop_xy_dict[file])

        print(f"Following {len(dio_file_path_dict)} dio files will be processed:")
        for file in dio_file_path_dict:
            print(str(file),str(dio_file_path_dict[file][0]))
    return videos_filepath_list,crop_xy_dict,meta_filepath_list,dio_file_path_dict



def process_ica_signals(demixed, mix_weights,time_meta):
    fps = 30.0
    eD = 0.5       # expected Duty cycle of 0.5
    ef_red = 0.5   # expected frequency of 0.5 Hz
    ef_blue = 2.5  # expected frequency of 2.5 Hz
    
    dD = np.zeros(demixed.shape[1])
    df_red = np.zeros(demixed.shape[1])
    df_blue = np.zeros(demixed.shape[1])
    
    colors = {0: 'red', 1: 'blue', None: 'gray'}
    N = -1
    N_ICA = -1  # numbers of samples to use for ICA, -1 for all
    
    # This ensures if video crop is improper or signal corrupted, that eye is ignored
    df_red_out = None
    df_blue_out = None
    
    for n in range(demixed.shape[1]):

        # Check the mixing weights if the demixed signal polarity is reversed
        # (negative weights for ROI. Assuming rest of pixel array has weight zero, mean weight tells us sign.)
        flip_ica = mix_weights[n] < 0
        if flip_ica:
            demixed[:, n] = -demixed[:, n]

        km = KMeans(n_clusters=2, random_state=0).fit(demixed[:, n].reshape(-1, 1))
        y_km = km.predict(demixed[:, n].reshape(-1, 1))

        # check polarity, if necessary flip to match pulse polarity
        # print(f'Centers: {float(km.cluster_centers_[0]*1000):.2f}, {float(km.cluster_centers_[1]*1000):.2f}')
        centers = km.cluster_centers_.ravel()

        flip_kmeans = centers[0] > centers[1]
        flip = flip_ica ^ flip_kmeans
        # print(f'Polarity FLIP: {flip} (ICA {flip_ica}, kmeans {flip_kmeans})')
        if flip_kmeans:
            # print('Flipping!')
            y_km = np.abs(y_km-1)

        duty_cycle = y_km.sum()/len(y_km)
        freq = (np.diff(y_km)>0).sum()/len(y_km) * fps
        dD[n] = abs(eD-duty_cycle)
        df_red[n] = abs(ef_red - freq)
        df_blue[n] = abs(ef_blue - freq)

        # Attempt to identify the ICA signal as a color LED
        good_DC = dD[n] < 0.2 * eD
        good_freq = np.array([df_red[n] < ef_red * 0.1, df_blue[n] < ef_blue * 0.1])
        is_signal = good_DC and good_freq.sum()
        signal_color = good_freq.argmax() if is_signal else None
        print(f"ICA signal number: {n}, DutyCycle:{duty_cycle}, Freq:{freq}")
        sig_col = colors[signal_color]
        sig_name = 'None' if signal_color is None else colors[signal_color]
        
        if sig_col=='red':
            a = y_km[:N]
            df_red_out = pd.DataFrame({'key' : [], "LED_Intensity" : []})
            # "Red_LED_Intensity_%s" %(eye)
            df_red_out['key'] = time_meta[0:(len(demixed[:N, n]-1))]
            df_red_out["LED_Intensity"] = demixed[:N, n]
        elif sig_col=='blue':
            a = y_km[:N]
            df_blue_out = pd.DataFrame({'key' : [], "LED_Intensity" : []})
            # "Red_LED_Intensity_%s" %(eye)
            df_blue_out['key'] = time_meta[0:(len(demixed[:N, n]-1))]
            df_blue_out["LED_Intensity"] = demixed[:N, n]
    return df_red_out,df_blue_out


# The offset is subtracted to make sure the drift is 0 at the start and at the end between the timestamps.
def pred_cpu_ts_from_gpu_ts(gpu, cpu):
    # Fit a linear regression model between GPU and CPU timestamps
    reg = LinearRegression().fit(gpu.reshape(-1, 1), cpu)
    # Use the model to predict CPU timestamps
    reg_ts = reg.predict(gpu.reshape(-1, 1))
    # Calculate the mean difference between the predicted and actual CPU timestamps for the first 1000 samples
    offset = (reg_ts - cpu)[:1000].mean()
    # Adjust the predicted CPU timestamps by the offset
    Corr_ts = reg_ts - offset
    print("Results of GPU to CPU delay, drift correction:")
    print(f"First GPU timestamp:{gpu[0]}, First CPU timestamp: {cpu[0]}, First predicted timestamp: {reg_ts[0]}")
    print(f"Calculated Offset from 1000 samples: {offset}, Final corrected timestamp:{Corr_ts[0]}")
    return Corr_ts


# # Function without subtracting offset
# # FOr visualisation check helper function vis_gpu_cpu_ts
# def pred_cpu_ts_from_gpu_ts(gpu_train, cpu_train, gpu_test,cpu_test_eval=None):
#     reg = LinearRegression().fit(gpu_train.reshape(-1, 1), cpu_train)
#     print("Regression coefficients of GPU2CPU linear model:",reg.coef_)
#     pred_cpu = reg.predict(gpu_test.reshape(-1, 1))
#     pred_score = None
#     # If true dio values are passed in inputs, compute R-squared scores for performance
#     if cpu_test_eval is not None:
#         pred_score = reg.score(gpu_test.reshape(-1, 1),cpu_test_eval)
#     return pred_cpu,pred_score

def vis_gpu_cpu_ts(path='/home/genzel/param/sync_inp_files'):
    # Verify the gpu vs cpu timestamp relationship
    path = Path(path).resolve()
    meta_filepath_list = list(sorted(path.glob('*.meta')))
    for filepath in meta_filepath_list:
        ts_data = np.genfromtxt(filepath, delimiter=',', names=True)
    #     print(ts_data['callback_gpu_ts'], ts_data['callback_clock_ts'])
    
        corr_cpu_ts = pred_cpu_ts_from_gpu_ts(ts_data['callback_gpu_ts'], ts_data['callback_clock_ts'])
        df = pd.DataFrame()
        df['extracted_seconds_timestamp'] = pd.to_datetime(corr_cpu_ts,unit='s',utc=True)
        df['extracted_seconds_timestamp'] = df['extracted_seconds_timestamp'].dt.tz_convert('CET').dt.tz_localize(
            None)
    #     print("R squared score of the GPU2CPU linear model: ",pred_score)
        error = ts_data['callback_clock_ts'] - corr_cpu_ts
        plt.figure()
        plt.plot(error)
        plt.title("Error in original and predicted CPU timestamp")
        plt.show()
        plt.figure()
        plt.plot(ts_data['callback_gpu_ts']- ts_data['callback_clock_ts'])
        plt.show()
        
        
        
        
        
def process_video_with_metadata(file_path,xy_coord,meta_filepath,process_frame_count):
    cap = cv2.VideoCapture(str(file_path))
    frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    frames_to_process = process_frame_count if process_frame_count is not None else frame_count
    
    # read time stamps from the meta file : alternative but uncorrected
    # Getting the data from the metadata files
    ts_data = np.genfromtxt(meta_filepath, delimiter=',', names=True)

    # Correcting the timestamps from meta file using linear regression
    corr_cpu_ts = pred_cpu_ts_from_gpu_ts(ts_data['callback_gpu_ts'], ts_data['callback_clock_ts'])
    df = pd.DataFrame()
    df['extracted_seconds_timestamp'] = pd.to_datetime(corr_cpu_ts,unit='s',utc=True)
    df['extracted_seconds_timestamp'] = df['extracted_seconds_timestamp'].dt.tz_convert('CET').dt.tz_localize(
        None)

    # extract time stamps from the csv files based on sync_edited: as they are corrected timestamps
    # Not using this since meta files can be used instead of csv and csv vs meta values didnt match 
    # with linear regression
#     df = pd.read_csv(str(ts_file_path), sep=',',parse_dates=['Timestamps_M'])#dtype=str)
#     df['extracted_seconds_timestamp'] = pd.to_datetime(df['Timestamps_M'], unit='s',utc=True)
#     df['extracted_seconds_timestamp'] = df['extracted_seconds_timestamp'].dt.tz_convert('CET').dt.tz_localize(None)
#     print(df['extracted_seconds_timestamp']) # time_meta 
#     print(df['extracted_seconds_timestamp'][0].value/ 10**9) # time_meta 
    
    
    
#     df = pd.read_csv(str(ts_file_path), sep=',',parse_dates=['callback_clock_ts'])#dtype=str)
#     df['extracted_seconds_timestamp'] = pd.to_datetime(df['callback_clock_ts'], unit='s')
    
    if(frame_count != len(df['extracted_seconds_timestamp'])):
        print("Frame counts do not match!!!")
        print(f"Frame count from video({frame_count})")
        print(f"Frame count from metadata({len(df['extracted_seconds_timestamp'])})")
    
              
    rgb_frames = np.empty((frames_to_process,16,16,3))
#     while(cap.isOpened()):
    for i in range(frames_to_process):
        ret, frame = cap.read()
        if frame is None:
            break
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # Start coordinate, here (5, 5)
        # represents the top left corner of rectangle
        start_point = (xy_coord[0]-8, xy_coord[1]-8)


        frame = frame[start_point[1]:start_point[1]+16,start_point[0]:start_point[0]+16]
#         rgb_frames = np.append(rgb_frames,frame.reshape(-1, 16, 16, 3), axis=0)
        rgb_frames[i,:,:,:] = frame
#         cv2.imshow('ImageWindow', frame)
#         cv2.waitKey(1)
        if i % 1000 == 0:
            print("Processed frames:",i," at ",datetime.now(),end='\r')
#     print(rgb_frames)
#     cv2.destroyAllWindows()
#     cv2.waitKey(1)
    cap.release()
    # number of components to extract from image crops: blue, red and noise
    nc = 3 
    ica = FastICA(n_components=nc, random_state=0)
    # reshape rgb_frames to a 2Darray
    X = rgb_frames.reshape(rgb_frames.shape[0], -1).astype(float) 
#     print(X.shape)
    # extraction of the independent signals 
    demixed = ica.fit_transform(X)
    mix_weights = ica.mixing_.mean(axis=0)
    
    red_ica_df,blue_ica_df = process_ica_signals(demixed,mix_weights,df['extracted_seconds_timestamp'])
    
    return red_ica_df,blue_ica_df


# Code to visualise the red_ica_df
#     fig, ax = plt.subplots(1, figsize=(40, 8)) #sharex="col", sharey=True )
#     ax.plot(red_ica_df['key'], red_ica_df['Red_LED_Intensity'], c='r')
#     ax.set_xlabel('Time')
#     ax.set_ylabel('Sum of ICAs (Red LED Intensities) of All Eyes')
#     # ax.set_xlim([df_final['key'][0], df_final['key'][width]])
#     plt.tight_layout()



def extract_com_from_merged_ica(agg_ica):
    # threhold
    agg_ica_thresh = agg_ica.Total_Intensity > 0
    
    # Save binarized and summed red ICA and correspnding timstamps
    agg_ica_out = pd.DataFrame({'Time_in_seconds' : [], 'ICA' : []})
    agg_ica_out.Time_in_seconds = agg_ica['key']
    agg_ica_out.ICA = agg_ica_thresh.astype(int)
    
#     time_ica = ica_red['Time_in_seconds']
#     ica_int = ica_red['ICA']
    sig_med = np.array(np.diff(agg_ica_out.ICA))
    sig_med = np.append(0, sig_med) # why add this 0 ? depends on any condition
    rising_edge = np.asarray(np.where(sig_med==1)).flatten()
    falling_edge = np.asarray(np.where(sig_med==-1)).flatten()
    com_ica = pd.DataFrame({'Center_of_mass' : []})  
    if agg_ica_out.Time_in_seconds[rising_edge[0]] < agg_ica_out.Time_in_seconds[falling_edge[0]]:  
        for i in range(min(len(rising_edge), len(falling_edge))):
            com_ica.at[i, 'Center_of_mass'] = agg_ica_out.Time_in_seconds[rising_edge[i]]
            +(agg_ica_out.Time_in_seconds[falling_edge[i]]
              -agg_ica_out.Time_in_seconds[rising_edge[i]])/2
    else:
        for i in range(min(len(rising_edge), len(falling_edge))-1):
            com_ica.at[i, 'Center_of_mass'] = agg_ica_out.Time_in_seconds[rising_edge[i]]
            +(agg_ica_out.Time_in_seconds[falling_edge[i+1]]
              -agg_ica_out.Time_in_seconds[rising_edge[i]])/2
    return com_ica


def merge_ica_and_extract_com(red_ica_list,blue_ica_list):
    # merge all eye data when running for all eyes
    it = iter(range(len(red_ica_list))) 
    red_ica_total = ft.reduce(lambda left, right: pd.merge(left, right, on='key', how='outer', 
                                                      suffixes=(None,"_"+str(next(it)))), 
                              red_ica_list)
    red_ica_total = red_ica_total.sort_values('key')
#     print("Before interpolation:",red_ica_total.isnull().sum())
    for column in red_ica_total.columns:
        if column == 'key':
            continue
        else:
            red_ica_total[column] = red_ica_total[column].interpolate()
#     red_ica_total.filter(like='LED_Intensity').interpolate(inplace=True)
    #red_ica_total.interpolate(inplace=True)# red_ica_total.fillna(0) # red_ica_total.filter(like='LED_Intensity').interpolate(inplace=True) #
#     print("After interpolation:",red_ica_total.isnull().sum())
    
    it = iter(range(len(blue_ica_list)))                          
    blue_ica_total = ft.reduce(lambda left, right: pd.merge(left, right, on='key', how='outer', 
                                                      suffixes=(None,"_"+str(next(it)))),
                               blue_ica_list)  
    blue_ica_total = blue_ica_total.sort_values('key')
#     print("Before interpolation:",blue_ica_total.isnull().sum())
    for column in blue_ica_total.columns:
        if column == 'key':
            continue
        else:
            blue_ica_total[column] = blue_ica_total[column].interpolate()
#     print("After interpolation:",blue_ica_total.isnull().sum())
    
    red_ica_total['Total_Intensity'] = red_ica_total.filter(like='LED_Intensity').sum(1)
    blue_ica_total['Total_Intensity'] = blue_ica_total.filter(like='LED_Intensity').sum(1)
    
    red_ica_total = red_ica_total[['key', 'Total_Intensity']]
    red_ica_total = red_ica_total.reset_index(drop=True)
    blue_ica_total = blue_ica_total[['key', 'Total_Intensity']]
    blue_ica_total = blue_ica_total.reset_index(drop=True)
#     print(red_ica_total)
#     print(blue_ica_total)
#     fig, ax = plt.subplots(1, figsize=(40, 8))
#     ax.plot(red_ica_total['key'], red_ica_total['Total_Intensity'], c='r')
#     ax.plot(blue_ica_total['key'], blue_ica_total['Total_Intensity'], c='b')


    # get centre of mass for both aggregated signals
    red_ica_com = extract_com_from_merged_ica(red_ica_total)
    blue_ica_com = extract_com_from_merged_ica(blue_ica_total)
    
    return red_ica_com, blue_ica_com, red_ica_total, blue_ica_total
    
    
    
    
#Extract DIOS

def readTrodesExtractedDataFile(filename):
    with open(filename, 'rb') as f:
        # Check if first line is start of settings block
        if f.readline().decode('ascii').strip() != '<Start settings>':
            raise Exception("Settings format not supported")
        fields = True
        fieldsText = {}
        for line in f:
            # Read through block of settings
            if(fields):
                line = line.decode('ascii').strip()
                # filling in fields dict
                if line != '<End settings>':
                    vals = line.split(': ')
                    fieldsText.update({vals[0].lower(): vals[1]})
                # End of settings block, signal end of fields
                else:
                    fields = False
                    dt = parseFields(fieldsText['fields'])
                    fieldsText['data'] = np.zeros([1], dtype = dt)
                    break
        # Reads rest of file at once, using dtype format generated by parseFields()
        dt = parseFields(fieldsText['fields'])
        data = np.fromfile(f, dt)
        fieldsText.update({'data': data})
        return fieldsText
# Parses last fields parameter (<time uint32><...>) as a single string
# Assumes it is formatted as <name number * type> or <name type>
# Returns: np.dtype
def parseFields(fieldstr):
    # Returns np.dtype from field string
    sep = re.split('\s', re.sub(r"\>\<|\>|\<", ' ', fieldstr).strip())
    # print(sep)
    typearr = []
    # Every two elmts is fieldname followed by datatype
    for i in range(0,sep.__len__(), 2):
        fieldname = sep[i]
        repeats = 1
        ftype = 'uint32'
        # Finds if a <num>* is included in datatype
        if sep[i+1].__contains__('*'):
            temptypes = re.split('\*', sep[i+1])
            # Results in the correct assignment, whether str is num*dtype or dtype*num
            ftype = temptypes[temptypes[0].isdigit()]
            repeats = int(temptypes[temptypes[1].isdigit()])
        else:
            ftype = sep[i+1]
        try:
            fieldtype = getattr(np, ftype)
        except AttributeError:
            print(ftype + " is not a valid field type.\n")
            exit(1)
        else:
            typearr.append((str(fieldname), fieldtype, repeats))
    return np.dtype(typearr)


def extract_dio_com(dio_file_path_dict):
    sys_time_dict = readTrodesExtractedDataFile(dio_file_path_dict['init'][0])
    sys_time = int(sys_time_dict['system_time_at_creation'])/1000
    timestamp_at_creation = int(sys_time_dict['timestamp_at_creation'])#/1000
    sys_time_dt = datetime.utcfromtimestamp(sys_time)#pd.to_datetime(sys_time, unit='s',utc=True)#
#     print(pd.to_datetime(sys_time, unit='s'),sys_time_dt,datetime.utcfromtimestamp(timestamp_at_creation/1000))
    # print(sys_time,sys_time_dt)
    red_dict_dio = readTrodesExtractedDataFile(dio_file_path_dict['red'][0])
    red_DIO = red_dict_dio['data']
    
    red_DIO_ts = [((sys_time_dt + timedelta(seconds = (i[0]-timestamp_at_creation)/ 30000)).timestamp(),
                   i[1]) for i in red_DIO]
#     print(red_DIO)
    red_DIO_df  = pd.DataFrame({"Time_Stamp_(DIO)" : [datetime.fromtimestamp(i[0]) for i in red_DIO_ts], 
                                "Time_in_seconds_(DIO)" : [str(i[0]) for i in red_DIO_ts], 
                                "State": [i[1] for i in red_DIO_ts]} )
#     print(red_DIO_ts)
#     print(red_DIO_df)
    
    blue_dict_dio = readTrodesExtractedDataFile(dio_file_path_dict['blue'][0])
    blue_DIO = blue_dict_dio['data']
    blue_DIO_ts = [((sys_time_dt + timedelta(seconds = (i[0]-timestamp_at_creation)/ 30000)).timestamp() , 
                    i[1]) for i in blue_DIO]
    blue_DIO_df  = pd.DataFrame({"Time_Stamp_(DIO)" : [datetime.fromtimestamp(i[0]) for i in blue_DIO_ts], 
                                 "Time_in_seconds_(DIO)" : [str(i[0]) for i in blue_DIO_ts], 
                                 "State": [i[1] for i in blue_DIO_ts]} )
    
#     # Visualise DIO raw signals
#     fig, ax = plt.subplots()
#     h1 = ax.stem(red_DIO_df["Time_Stamp_(DIO)"], red_DIO_df["State"],'red',markerfmt='ro') #markerfmt=' '
#     h2 = ax.stem(blue_DIO_df["Time_Stamp_(DIO)"], blue_DIO_df["State"],'blue',markerfmt='bo') #markerfmt=' '
    
#     proxies = [h1,h2]
#     legend_names = ['Red_DIO','Blue_DIO']
#     plt.legend(proxies, legend_names, loc='best', numpoints=1)
#     for h in proxies:
#         h.set_visible(False)
#     plt.show()
    
    
    com_dio_red = pd.DataFrame({'Center_of_mass' : []})
    if red_DIO_df["State"][0]==1:
        for i in range(2, len(red_DIO_df["State"]), 2):
            com_dio_red.at[(i-2)/2, 'Center_of_mass'] = red_DIO_df["Time_Stamp_(DIO)"][i-2]
            +(red_DIO_df["Time_Stamp_(DIO)"][i]-red_DIO_df["Time_Stamp_(DIO)"][i-2])/2
    else:
        for i in range(3, len(red_DIO_df["State"]), 2):
            com_dio_red.at[(((i-1)/2)-1), 'Center_of_mass'] = red_DIO_df["Time_Stamp_(DIO)"][i-2]
            +(red_DIO_df["Time_Stamp_(DIO)"][i]-red_DIO_df["Time_Stamp_(DIO)"][i-2])/2
            
    
    com_dio_blue = pd.DataFrame({'Center_of_mass' : []})
    if blue_DIO_df["State"][0]==1:
        for i in range(2, len(blue_DIO_df["State"]), 2):
            com_dio_blue.at[(i-2)/2, 'Center_of_mass'] = blue_DIO_df["Time_Stamp_(DIO)"][i-2]
            +(blue_DIO_df["Time_Stamp_(DIO)"][i]-blue_DIO_df["Time_Stamp_(DIO)"][i-2])/2
    else:
        for i in range(3, len(blue_DIO_df["State"]), 2):
            com_dio_blue.at[(((i-1)/2)-1), 'Center_of_mass'] = blue_DIO_df["Time_Stamp_(DIO)"][i-2]
            +(blue_DIO_df["Time_Stamp_(DIO)"][i]-blue_DIO_df["Time_Stamp_(DIO)"][i-2])/2
    return com_dio_red,com_dio_blue


def visualise_ica_dio_coms(dio_com_red,ica_com_red,dio_com_blue,ica_com_blue):    
    dio_com_red["Amp"] = 0.6
    ica_com_red["Amp"] = 0.6
    dio_com_blue["Amp"] = 0.5
    ica_com_blue["Amp"] = 0.5
    # dio_com["Center_of_mass"] = pd.to_datetime(dio_com["Center_of_mass"])

    # ax1 = dio_com_red.plot(kind='scatter', x="Center_of_mass", y='Amp', color='r') 
    # ax2 = ica_com_red.plot(kind='scatter', x="Center_of_mass", y='Amp', color='orange',ax=ax1)
    # ax3 = ica_com_blue.plot(kind='scatter', x="Center_of_mass", y='Amp', color='b',ax=ax1)
    # ax3 = dio_com_blue.plot(kind='scatter', x="Center_of_mass", y='Amp', color='c',ax=ax1)


    fig, ax = plt.subplots()
    h1 = ax.stem(dio_com_red["Center_of_mass"], dio_com_red["Amp"],linefmt='red',markerfmt='ro') #markerfmt=' '
    h2 = ax.stem(ica_com_red["Center_of_mass"], ica_com_red["Amp"],linefmt='orange',markerfmt='yo')

    h3 = ax.stem(dio_com_blue["Center_of_mass"], dio_com_blue["Amp"],linefmt='blue',markerfmt='bo')
    h4 = ax.stem(ica_com_blue["Center_of_mass"], ica_com_blue["Amp"],linefmt='cyan',markerfmt='co')
    
    proxies = [h1,h2,h3,h4]
    legend_names = ['Red_DIO','Red_ICA','Blue_DIO','Blue_ICA']
    plt.legend(proxies, legend_names, loc='best', numpoints=1)
#     for h in proxies:
#         h.set_visible(False)
    plt.show()




'''Assuming that this model will be specific to each set of eye videos
We train the model everytime and predict the timestamps
The predicted timestamps will have some error so ultimately a closest dio time stamp to the 
predicted dio time stamp shall be chosen for analysis.'''

# Old one without offset
# def pred_dio_ts_from_ica_ts(ica_train, dio_train, ica_test,dio_test_eval=None):
#     reg = LinearRegression().fit(ica_train.reshape(-1, 1), dio_train)
#     print("Regression coefficients of ICA2DIO linear model:",reg.coef_)
#     pred_dio = reg.predict(ica_test.reshape(-1, 1))
#     pred_score = None
#     # If true dio values are passed in inputs, compute R-squared scores for performance
#     if dio_test_eval is not None:
#         pred_score = reg.score(ica_test.reshape(-1, 1),dio_test_eval)
#     return pred_dio,pred_score




# New one with offset
def pred_dio_ts_from_ica_ts_and_verify(ica_train, dio_train,test_cpu_blue,test_cpu_red,frame_wise_ts,
                                       vis_on=False):
    reg = LinearRegression().fit(ica_train.reshape(-1, 1), dio_train)
#     print("Regression coefficients of ICA2DIO linear model:",reg.coef_)
    pred_dio_blue = reg.predict(test_cpu_blue.reshape(-1, 1))
    pred_dio_red = reg.predict(test_cpu_red.reshape(-1, 1))
    pred_frame_wise_ts = reg.predict(frame_wise_ts.reshape(-1, 1))
    offset_red = pred_dio_red[0] - test_cpu_red[0]
    offset_blue = pred_dio_blue[0] - test_cpu_blue[0]
    assert offset_red == offset_blue, f"Offset in red({offset_red}) and blue ({offset_blue})signal is not same"
    print("Offset for final correction(s) is: ",offset_red)
    pred_dio_blue = pred_dio_blue - offset_blue
    pred_dio_red = pred_dio_red - offset_red
    pred_frame_wise_ts = pred_frame_wise_ts - offset_red
    # Try dio test instead of testcpu
    if vis_on:
        plt.figure()
        plt.plot(pred_dio_blue)
        plt.title("Predicted ts vs Frame number")
        plt.show()
        
        plt.figure()
        plt.plot(pred_dio_blue - test_cpu_blue)
        plt.title("Predicted ts-cpu vs Frame number")
        plt.show()
        
        val_dio = reg.predict(ica_train.reshape(-1, 1))
        plt.figure()
        plt.plot(val_dio - dio_train)
        plt.title("pred dio on train - dio ground truth vs Frame number")
        plt.show()
        
        plt.figure()
        plt.plot(pred_frame_wise_ts - frame_wise_ts)
        plt.title("pred framewise ts - cpu avg framewise ts vs Frame number")
        plt.show()
    return pred_dio_blue,pred_dio_red,pred_frame_wise_ts


# Finding first overlap needs to be after the first DIO signals in red/blue
def trim_ts_before_first_overlap(ica_ts_red,dio_ts_red,ica_ts_blue,dio_ts_blue):
    start_point_ica= 0
    # trimmed dio is the first and last signal removed
    trimmed_dio_red = dio_ts_red.values[1:-2]
    print(f"trimmed red dio len: {trimmed_dio_red.shape}, before trim: {dio_ts_red.shape} ")
    trimmed_ica_red_front = ica_ts_red[(ica_ts_red > dio_ts_red.values[0])].to_numpy()
    print(f"trimmed red ica front len: {trimmed_ica_red_front.shape}, before trim: {ica_ts_red.shape} ")
    trimmed_ica_red = trimmed_ica_red_front[start_point_ica:len(trimmed_dio_red)+start_point_ica]
    print(f"trimmed red ica len: {trimmed_ica_red.shape}, before trim: {ica_ts_red.shape} ")
    # trimmed ica is the ma
    
    # trimmed ica signals to start after the timestamp when DIO was initialised
    # trimmed ica signals to end before the last DIO since that might be corrupted when switched off.
#     trimmed_ica = ica_ts[(ica_ts > dio_ts.values[0]) & (ica_ts < dio_ts.values[-2])].to_numpy()
    
    # After the signal is trimmed, need to check if there are any outliers or abnormal shifts
#     trimmed_dio = dio_ts.to_numpy()[1:len(trimmed_ica)+1]
    diff = trimmed_dio_red - trimmed_ica_red
    print("Red: Trimmed dio - Trimmed ICA difference is: ",diff)
    plt.figure()
    plt.plot(diff)
    plt.title("diff between RED : trimmed dio and trimmed ica vs Frame number")
    plt.show()
    
    
    # trimmed dio is the first and last signal removed
    trimmed_dio_blue = dio_ts_blue[(dio_ts_blue > dio_ts_red.values[0]) & 
                                   (dio_ts_blue < dio_ts_red.values[-1])].to_numpy()
    print(f"trimmed blue dio len: {trimmed_dio_blue.shape}, before trim: {dio_ts_blue.shape} ")
    trimmed_ica_blue_front = ica_ts_blue[(ica_ts_blue > dio_ts_red.values[0])].to_numpy()
    print(f"trimmed blue ica front len: {trimmed_ica_blue_front.shape}, before trim: {ica_ts_blue.shape} ")
    trimmed_ica_blue = trimmed_ica_blue_front[5*start_point_ica:len(trimmed_dio_blue)+5*start_point_ica]
    print(f"trimmed blue ica len: {trimmed_ica_blue.shape}, before trim: {ica_ts_blue.shape} ")
    # trimmed ica is the ma
    
    # trimmed ica signals to start after the timestamp when DIO was initialised
    # trimmed ica signals to end before the last DIO since that might be corrupted when switched off.
#     trimmed_ica = ica_ts[(ica_ts > dio_ts.values[0]) & (ica_ts < dio_ts.values[-2])].to_numpy()
    
    # After the signal is trimmed, need to check if there are any outliers or abnormal shifts
#     trimmed_dio = dio_ts.to_numpy()[1:len(trimmed_ica)+1]
    diff = trimmed_dio_blue - trimmed_ica_blue
    print("Blue: Trimmed dio - Trimmed ICA difference is: ",diff)
    plt.figure()
    plt.plot(diff)
    plt.title("diff between trimmed dio and trimmed ica vs Frame number")
    plt.show()
    
    return trimmed_ica_red,trimmed_dio_red,trimmed_ica_blue,trimmed_dio_blue


def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
            It must be "yes" (the default), "no" or None (meaning
            an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == "":
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='OpenCV video processing')
    
    help_text = "Input folder contains the following : 1. Eye video files: .mp4 formats (12 files, for each eye) \n \
 2. X,y co-ordinates of crops for LED positions : .led_crop format (1 file containing 12 xy co-ordinates) \n \
 3. Time stamp files containing framewise clock timestamps after linear regression: .csv format (12 files) \n \
    Note: TODO: Add the logic of meta to .csv conversion using Linear regression in this script. \n \
 4. Time stamps recorded from LED controller referred to as DIO: .dat format (3 files for red,blue and \
 initial systime) \n \
     a. Rat4_20201109_maze.dio_MCU_Din1.dat for initial time stamp \n \
     b. Rat4_20201109_maze_merged.dio_MCU_Din1.dat for blue DIO \n \
     c. Rat4_20201109_maze_merged.dio_MCU_Din2.dat for red DIO \n \
    Example: python Video_LED_Sync_using_ICA.py -i '/home/genzel/param/sync_inp_files' -o '/home/genzel/param/outpath/' "
    
    parser.add_argument('-i', "--input", dest='input_path', help=help_text)
    parser.add_argument('-o', "--output", dest='output_path', help='full path for generating framewise timestamps synchronised with DIO time')
    args = parser.parse_args()
    if args.input_path is None:  # or args.output is None
        sys.exit("Please provide path to input and output video files! See --help")
    print('Input path: ', args.input_path, 'Output log path: ', args.output_path)

    # Main routine

	# Get file list paths and the metadata paths related to it : dio timestamps, xy co-ords, ???
    vfl,xy_dict,meta_file_list,dio_file_path_dict = get_video_files_with_metadata(args.input_path)


    # Verify from user for input options
    u_resp = query_yes_no("Do you want to go ahead with selected files? Please verify before proceeding")

    if u_resp:


        # loop over each video file to get the df
        red_ica_list = []
        blue_ica_list = []
        process_frame_count = None
        for itr,video_file_path in enumerate(vfl):
            print("\n")
            print("Processing for eye:",itr)
            print("Filepath:",video_file_path)
            print("XY coordinates for crop:",xy_dict[str(video_file_path)])
            
            red_ica_out,blue_ica_out = process_video_with_metadata(video_file_path,xy_dict[str(video_file_path)],
                                                            meta_file_list[itr],process_frame_count)
            if (red_ica_out is not None) and (blue_ica_out is not None): 
                red_ica_list.append(red_ica_out)
                blue_ica_list.append(blue_ica_out)
                print("=================")
            else:
                print("CORRUPTED SIGNAL/VIDEO CROP....IGNORING THIS EYE FOR ANALYSIS:",str(video_file_path))


        # for item in blue_ica_list:
        #     print(item.shape)

        # Get the average of the timestamps extracted from each eye video frame. 
        # TODO: Discuss whats the best strategy to calculate the timestamp for stitched frame
        # 1. Choose ts of eye as per rat position 2. Remove unused eyes and average 3. Use all eyes data
        # Current strategy is 2
        final_size = min([eye_ts.shape[0] for eye_ts in blue_ica_list])
        print(final_size)
        sum_ts = np.zeros((final_size,))
        for item in blue_ica_list:
            ts_df = pd.to_datetime(item['key']).astype(int)/ 10**9
            # print(ts_df[0],ts_df[1])
            sum_ts = sum_ts + ts_df.to_numpy()[:final_size]
            
        avg_ts_per_frame = sum_ts/len(blue_ica_list)
                        
        # process the combined ica signals and get centre of mass for the aggregated signal from all eyes
        ica_com_red,ica_com_blue, red_ica_total, blue_ica_total = merge_ica_and_extract_com(red_ica_list,blue_ica_list)

        # extract dio signal, time stamps, 
        # process the dio signals and timestamps, and 
        # get centre of mass for dio signals
        dio_com_red, dio_com_blue = extract_dio_com(dio_file_path_dict)

        visualise_ica_dio_coms(dio_com_red,ica_com_red,dio_com_blue,ica_com_blue)


        ts_ica_red = pd.to_datetime(ica_com_red['Center_of_mass']).astype(int)/ 10**9
        ts_dio_red = pd.to_datetime(dio_com_red['Center_of_mass']).astype(int)/ 10**9

        ts_dio_blue = pd.to_datetime(dio_com_blue['Center_of_mass']).astype(int)/ 10**9
        ts_ica_blue = pd.to_datetime(ica_com_blue['Center_of_mass']).astype(int)/ 10**9


        ica_train_red, dio_train_red, ica_train_blue, dio_train_blue = trim_ts_before_first_overlap(ts_ica_red, 
                                                                                            ts_dio_red, 
                                                                                            ts_ica_blue, 
                                                                                            ts_dio_blue)
        red_ica_corrected_s = pd.to_datetime(red_ica_total['key']).astype(int)/ 10**9
        blue_ica_corrected_s = pd.to_datetime(blue_ica_total['key']).astype(int)/ 10**9
        # print("Red ICA total timestamps:",red_ica_corrected_s.to_numpy())
        # Train on red and test on blue
        # train_set_size = int(0.5 * len(ica_train_red))
        pred_dio_blue,pred_dio_red,pred_framewise_ts = pred_dio_ts_from_ica_ts_and_verify(ica_train_blue,dio_train_blue,
                                                                blue_ica_corrected_s.to_numpy(),
                                                                red_ica_corrected_s.to_numpy(),
                                                                avg_ts_per_frame,
                                                                vis_on=True)
        # print("Predicted DIO from regressor:",pred_dio_blue)
        # print(dio_train_red[train_set_size:], pred_dio_red)
        diff = pred_dio_blue - blue_ica_corrected_s.to_numpy()
        print("Min diff in seconds between final corrected vs cpu corrected:", np.min(diff))
        print("Max diff in seconds between final corrected vs cpu corrected::", np.max(diff))

       # Save the corrected average framewise ts to csv file
        pred_ts_df = pd.DataFrame(pred_framewise_ts,columns=['Corrected Time Stamp'])
        pred_ts_df.to_csv(args.output_path + "stitched_framewise_ts.csv",index_label='Frame Number')
        # blue_ica_corrected_s.to_csv(args.output_path + "blue_corrected_ts.csv")

        # To visualise the gpu and cpu timestamps difference
        # Check this function definition above
        # vis_gpu_cpu_ts()
    else:
        exit()






