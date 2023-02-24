# -*- coding: utf-8 -*-
"""
Created on Mon May 23 14:08:05 2022

@author: mdadmin
"""

# imports
    # Use Easy OCR for 10 first frame_index, to know which index correspond to which LED state
    
from pathlib import Path
import numpy as np
import cv2
from sklearn.linear_model import LinearRegression
import pandas as pd

# directories
    # Dio
    # where to save rgb
videos_files = Path(r'E:\Documents\EPF\PFE\Work\Codes\check\Videos')
videos = list(sorted(videos_files.glob('eye*.mp4')))
metadata = list(sorted(videos_files.glob('eye*.meta')))


# functions 

def Correct_gpu_cpu(gpu, cpu):
    reg = LinearRegression().fit(gpu.reshape(-1, 1), cpu)
    reg_ts = reg.predict(gpu.reshape(-1, 1))-cpu
    offset = reg_ts[:1000].mean()
    Corr_ts = reg_ts - offset
    return Corr_ts

def LED_Intensity(demixed, time_meta):
    for n in range(12):
        df_temp = pd.DataFrame({'key' : [], "LED_Intensity_%s" %(n) : []})
        df_temp['key'] = time_meta[0:(len(demixed[:N, n]-1))]
        df_temp["LED_Intensity_%s" %(eye)] = demixed[:N, n]
        if n==0:
            df0 = df_temp
        if n==1:
            df1 = df_temp
        if n==2:
            df2 = df_temp
        if n==3:
            df3 = df_temp
        if n==4:
            df4 = df_temp
        if n==5:
            df5 = df_temp
        if n==6:
            df6 = df_temp
        if n==7:
            df7 = df_temp
        if n==8:
            df8 = df_temp
        if n==9:
            df9 = df_temp
        if n==10:
            df10 = df_temp
        if n==11:
            df11 = df_temp

    dfs = [df0, df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11]  

    df_final = ft.reduce(lambda left, right: pd.merge(left, right, on='key', how='outer', suffixes=(None, None)), dfs)  
    df_final = df_final.sort_values('key')
    df_final.interpolate(inplace=True)

    for eye in range(12):
        # ax.plot(df_final['key'][:100], df_final["Red_LED_Intensity_%s" %(eye)][:100])
        df_total = df_total + df_final[f"LED_Intensity_{eye}"]

    ica_thresh = df_total.values > 0

    ica_red = pandas.DataFrame({'Time_in_seconds' : [], 'ICA_red' : []})
    ica_red.Time_in_seconds = df_final['key']
    ica_red.ICA_red = ica_thresh

# DETECT_LED_CENTER


# Crop and to RGB

# Center of mass ?




# main

for m in range(len(metadata)) :
    
    # Getting the data from the metadata files
    data = np.genfromtxt(metadata[m], delimiter=',', names=True)
    
    # Opening DIO files
    
    
    # Correcting the ts thanks to linear regression
    Corrected_ts = Correct_gpu_cpu(data['callback_gpu_ts'], data['callback_clock_ts'])
    
    
    # Opening the video 
    cap = cv2.VideoCapture(str(videos[m]))
    
    while (cap.isOpened()):

        res, frame = cap.read() # Read Current Frame
        frame_index = int(cap.get(cv2.CAP_PROP_POS_FRAMES)) # Current Frame Index
        
        # Detect led center with ffmpeg
        
        # Crop aroud led center
        
        # To RGB
        
        # ICA
            # Identify if signal as its corresponding led

# Out of iter :

# Add all LED ICA


# Find center of Mass for Added_LED_ICA and for DIO

# FInd offset and drift between LED and DIO

# Correct ts 

######################

# CHange Ts from the tracker

      


  
  
  
  
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
