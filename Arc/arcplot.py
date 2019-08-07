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
    pitch = nmat['Pitch']
    offsets = [sum(x) for x in zip(onsets, nmat['Duration'])]
    
    _midiplot(onsets,offsets,pitch)

    colornum=1
    #cmap1=jet(len(segcard))
    #cmap1 = plt.cm.get_cmap('jet')
    pitchmax=nmat['Pitch'].max()
    pitchmean=nmat['Pitch'].mean()
    pitchmean=(pitchmax+pitchmean)/2

    # framelabels = ["Onset in Beats", "Durations in Beats", "Pitch (C4=60)"]
    rads = [1]
    # for i in range(0,len(segind)-1):
    #try:
    temp=onsets[segind]
    temp=temp.sort_values()
    #SortInd = temp.head() 
    SortInd=list(temp.index.values) 
    #r = r.sort_values(by=["cov"], ascending=False).reset_index(drop=True)
    ind=SortInd
    segind=ind
    #finally:
    #    pass
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
    origxstart = onsets[segind[0]]
    card=segcard
    origxend=offsets[segind[0]+card-1]
    origwidth=origxend - origxstart
    origx=(origwidth) / 2 + origxstart
    # linewidthstart= origwidth ### need to normalize to pixel length
    # origpitchmin=min(pitch[segind[0]:(segind[0] + card - 1)]) - 2
    # colornoalpha=[colornum]
    colornum=colornum + 1
    
    for j in range(1,len(ind)):
        #noteInd = ind[j]
        #compxstart=nmat.iloc[noteInd,0]
        compxstart = onsets[ind[j]]
        #compxend=nmat.iloc[noteInd + (card - 1),0] + nmat.iloc[noteInd + (card - 1),1]
        compxend = offsets[ind[j]+card-1]
        compwidth=compxend - compxstart
        compx=(compwidth) / 2 + compxstart
        # linewidthend= compwidth ### need to normalize to pixel length
        #comppitchmin=min(pitch[ind[j]:ind[j] + (card - 1)]) - 2
        rad=(compx - origx) / 2
        rads.append(rad)
        x=rad + origx
        #linewidth=np.dot(card,3)
        
        # if segcard:
        #     colornoalpha=[0,0,1]
            
        # coloralpha=colornoalpha.append(0.5)
        _arc(x=x,y=pitchmean,r=rad)

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
    th=np.arange(0,np.pi,np.pi/200)
    xunit=r * np.cos(th) + x
    yunit=r * np.sin(th) + y
    linewidthincrement=(linewidthstart-linewidthend)/len(xunit)

    plt.figure(1)
    
    for i in range(2,len(th)):
        plt.plot([xunit[i-1],xunit[i]], [yunit[i-1],yunit[i]],'b',linewidth = 10*(linewidthend+i*linewidthincrement), zorder=0, alpha=0.05)
        
def _midiplot(onsets,offsets,pitch):
    plt.figure(figsize=(20,10))
    
    for i in range(0,len(onsets)):
        plt.plot([onsets[i],offsets[i]], [pitch[i],pitch[i]], 'k', lw=2, path_effects=[pe.Stroke(linewidth=2, foreground='k'), pe.Normal()], zorder=5)
        
    plt.xlabel("Beats")
    plt.ylabel("Pitch (C4=60)")