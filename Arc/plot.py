import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe

def plot(nmat,segind,segcard):
    """
    plot(nmat,segind,segcard)
    ######################################################
    
    Displays Arc Plot Diagram. This consists of a series of arcs overlayed on MIDI data presented horizontally.
    
    Parameters:
        nmat (pandas.df): A Note Matrix that contains pitch, timing, and velocity information for a series of notes.
        nmatRCE (pandas.df): A version of the Note Matrix which has each element reduced to a binary value.
        onsets (list): A list of values that describes when each note would begin in the piece.
        offsets (list): A list of values that describes when each note would end in the piece.
        segind (list): A list of lists of values that describe the occurences of each pattern found in the piece.
        segcard (list): A list that describes how many notes should be in each pattern.
    """
    
    onsets = nmat['Time']
    offsets = onsets + nmat['Duration']
    pitch = nmat['Pitch']
    
    _midiplot(onsets,offsets,pitch)

    colornum=1
    #cmap1=jet(len(segcard))
    #cmap1 = plt.cm.get_cmap('jet')
    pitchmean=nmat['Pitch (C4=60)'].mean()

    #segind=[1,72,161,244,264,382,517,726]
    framelabels = ["Onset in Beats", "Durations in Beats", "Pitch (C4=60)"]
    #segcard=20
    rads = [1]
    # for i in range(0,len(segind)-1):
    try:
        ind=segind
    finally:
        pass
    #     try
    #         try
    #             simind=r(i).simind;
    #         catch
    #             simind=r(i).invind;
    #         end
    #     catch
    #         simind=[];
    #     end
    #       ind
    origxstart = nmat.iloc[segind[0],0]
    card=segcard
    origxend=nmat.iloc[(segind[0] + card - 1),0] + nmat.iloc[(segind[0] + card - 1),1]
    origwidth=origxend - origxstart
    origx=(origwidth) / 2 + origxstart
    linewidthstart= origwidth #need to normalize to pixel length
    origpitchmin=min(nmat.iloc[segind[0]:(segind[0] + card - 1),2]) - 2
    colornoalpha=cmap1(colornum)
    colornum=colornum + 1
    
    for j in range(1,len(ind)):
        noteInd = ind[j]-1
        compxstart=nmat.iloc[noteInd,0]
        compxend=nmat.iloc[noteInd + (card - 1),0] + nmat.iloc[noteInd + (card - 1),1]
        compwidth=compxend - compxstart
        compx=(compwidth) / 2 + compxstart
        linewidthend= compwidth #need to normalize to pixel length
        comppitchmin=min(nmat.iloc[noteInd:noteInd + (card - 1),2]) - 2
        rad=(compx - origx) / 2
        rads.append(rad)
        x=rad + origx
        nsegments=100
        linewidth=np.dot(card,3)
        
        if segcard:
            colornoalpha=[0,0,1]
            
        coloralpha=colornoalpha.append(0.5)
        _arc(x=x,y=pitchmean,r=rad,linewidthstart=linewidthstart,linewidthend=linewidthend)

def _arc(x,y,r,nsegments=100,coloralpha='r',linewidthstart=5,linewidthend=10):
    """
    _arc(x,y,r,nsegments=100,coloralpha='r',linewidthstart=5,linewidthend=10)
    #########################################################################
    
    Draws an arc from one point to another.
    
    Parameters:
        x (float): The time value the arc will start at.
        y (float): The pitch value the arc will start at.
        r (float): The radius of the arc.
        nsegments (int): The number of line segments that make up the arc.
        coloralpha (str): The color of the line segments.
        linewidthstart (int): the width of each line segment at the beginning.
        linewidthend (int): the width of each line segment at the end.
    """
    th=np.arange(0,np.pi,np.pi/100)
    xunit=r * np.cos(th) + x;
    yunit=r * np.sin(th) + y;
    linewidthincrement=(linewidthstart-linewidthend)/len(xunit);

    plt.figure(1)
    for i in range(2,len(th)):
        plt.plot([xunit[i-1],xunit[i]], [yunit[i-1],yunit[i]],coloralpha,linewidth = linewidthend+i*linewidthincrement)
        
def _midiplot(onsets,offsets,pitch):
    plt.figure(figsize=(20,10))
    
    for i in range(0,len(onsets)):
        plt.plot([onsets[i],offsets[i]], [pitch[i],pitch[i]], 'g', lw=2, path_effects=[pe.Stroke(linewidth=5, foreground='g'), pe.Normal()])

    plt.xlabel("Beats")
    plt.ylabel("Pitch (C4=60)")