import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe

def plot(nmat,nmatRCE,onsets,offsets,pitch,segind,segcard):
    """
    Plots Curves for things and stuff
    """
    
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
    origxstart = nmatRCE.iloc[segind[0],0]
    card=segcard
    origxend=nmatRCE.iloc[(segind[0] + card - 1),0] + nmatRCE.iloc[(segind[0] + card - 1),1]
    origwidth=origxend - origxstart
    origx=(origwidth) / 2 + origxstart
    linewidthstart= origwidth #need to normalize to pixel length
    origpitchmin=min(nmatRCE.iloc[segind[0]:(segind[0] + card - 1),2]) - 2
    colornoalpha=cmap1(colornum)
    colornum=colornum + 1
    
    for j in range(1,len(ind)):
        noteInd = ind[j]-1
        compxstart=nmatRCE.iloc[noteInd,0]
        compxend=nmatRCE.iloc[noteInd + (card - 1),0] + nmatRCE.iloc[noteInd + (card - 1),1]
        compwidth=compxend - compxstart
        compx=(compwidth) / 2 + compxstart
        linewidthend= compwidth #need to normalize to pixel length
        comppitchmin=min(nmatRCE.iloc[noteInd:noteInd + (card - 1),2]) - 2
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