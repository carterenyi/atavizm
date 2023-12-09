function r=arcPlotGUICorpus(r,in)
%% Run Search and Rank first
%data needed:
%nmat
%r (output of searchAndRank)
%with segind ... nmatSR etc

if nargin==1
    color=1;
    nmat=r.nmat;
    r=r.r;
    plotTitle='Arc Diagram of MIDI file';
else
    type=in.type;
    color=in.color;
    nmat=in.nmat;
    plotTitle=in.title;
    pieceTitles=in.pieceTitles;
end

%see if nargin = 6 below
chans=unique(nmat(:,3));

%clear non-recursive strings
for i=numel(r):-1:1
    if numel(r(i).segind)==1 %&& numel(r(i).invind)==0
        r(i)=[];
    end
end

% if nargin >=7
%     r=r(rselect);
% end

for i=1:numel(r)
    clearvars starts
    nmatSR=r(i).nmatSR;
    segind=r(i).segind;
    starts(numel(segind))=nan;
    for j=1:numel(segind)
        starts(j)=nmatSR(segind(j),1);
    end
    [starts, ind]=sort(starts);
    r(i).segind=segind(ind);
end

colornum=1;

if color==3
    cmap1 = colormap(parula(numel(r)));
elseif color==4
    cmap1 = colormap(hsv(numel(r)));
elseif color==5
    cmap1 = colormap(spring(numel(r)));
elseif color==6
    cmap1 = colormap(summer(numel(r)));
elseif color==7
    cmap1 = colormap(autumn(numel(r)));
elseif color==8
cmap1 = colormap(winter(numel(r)));
else
cmap1 = colormap(jet(numel(r)));
end

fig=figure(1);
cla(fig)
screensize = get( groot, 'Screensize' );
set(fig,'Color','w','Name','ATAVizM: Arc Diagram','Position', screensize*.9);
hold on
midiplot(1)=plot([nmat(1,1) (nmat(1,1)+nmat(1,2))], [nmat(1,4) nmat(1,4)],'Color','k','LineWidth', 12);
legendplots(1)=midiplot(1);
title(plotTitle,'FontSize',30);

%ylabel('MIDI pitch (C4=60)','FontSize',16);
set(gca,'FontSize',16,'FontWeight','bold');

%initialize colors and labels for legend
labels{1+numel(r)}=[];
labels{1}='Piece';
for i=1:numel(r)
    if numel(r(i).name)<16
        labels{1+i}=r(i).name;
    else
        labels{1+i}=r(i).name(1:16);
    end
    if numel(r)==1
        h(i)=plot([nmat(1,1) (nmat(1,1)+nmat(1,2))], [nmat(1,4) nmat(1,4)],'Color',[0,0,1],'LineWidth',10);
    else
        h(i)=plot([nmat(1,1) (nmat(1,1)+nmat(1,2))], [nmat(1,4) nmat(1,4)],'Color',cmap1(i,:),'LineWidth',10);
    end
    legendplots(end+1)=h(i);
end


pitchmean=mean(nmat(:,4));
pitchmax=max(nmat(:,4));
xmin=min(nmat(:,1));
xmax=max(nmat(:,1));
xrange=xmax-xmin;
xmin=xmin-.1*xrange;
xmax=xmax+.1*xrange;
position = getpixelposition(gca);
plotsizex=position(3);
plotsizey=position(4);
xpixels=plotsizex/xmax;
rads=1;

for i=1:numel(r)
    nmatSR=r(i).nmatSR;
    segind=r(i).segind;
    card=r(i).card;
    for k=1:numel(segind)  
        origxstart=nmatSR(segind(k),1);
        origxend=nmatSR(segind(k)+card(k)-1,1)+nmatSR(segind(k)+card(k)-1,2);
        origwidth=origxend-origxstart;
        origx=(origwidth)/2+origxstart;
        linewidthstart=origwidth*xpixels;
        origpitchmin=min(nmatSR(segind(1):segind(k)+card(k)-1,4))-2;
        colornoalpha=cmap1(i,:);
        %colornum=colornum+1;
        for j=k+1:numel(segind)

            compxstart=nmatSR(segind(j),1);
            try
                compxend=nmatSR(segind(j)+card(j)-1,1)+nmatSR(segind(j)+card(j)-1,2);
            catch
                compxend=nmatSR(segind(j)+card(j)-2,1)+nmatSR(segind(j)+card(j)-2,2);
            end
            compwidth=compxend-compxstart;
            compx=(compwidth)/2+compxstart;
            linewidthend=compwidth*xpixels;
            rad=(compx-origx)/2;
            rads(end+1)=rad;
            x=rad+origx;
            nsegments=100;
            %linewidth=card*3;
            if type==2
                if k+1~=j
                    continue
                end
            end
            if type==4
                if k+numel(segind)-1~=j
                    if k+1~=j
                        continue
                    end
                end
            end
            if numel(r)==1
                colornoalpha=[0,0,1];
            end
            coloralpha=[colornoalpha,.3];
            h = arc(x,pitchmean,rad,nsegments,coloralpha,linewidthstart,linewidthend);
        end
        if type==1
            break
        end
    end
end

for i=1:numel(nmat(:,1))
    if isnan(nmat(i,4))==1
        continue
    end
    midiplot2(i)=line([nmat(i,1) (nmat(i,1)+nmat(i,2))], [nmat(i,4) nmat(i,4)],'Color','k','LineWidth',12);
end

numel(chans)
if numel(chans)==1
    %midiplot2(1)=line([nmat(1,1) (nmat(1,1)+nmat(1,2))], [nmat(1,4) nmat(1,4)],'Color','k','LineWidth', 16);
    for i=1:numel(nmat(:,1))
        midiplot2(i)=line([nmat(i,1) (nmat(i,1)+nmat(i,2))], [nmat(i,4) nmat(i,4)],'Color','k','LineWidth',16);
        midiplot3(i)=line([nmat(i,1)+.1 (nmat(i,1)+nmat(i,2))-.1], [nmat(i,4) nmat(i,4)],'Color','w','LineWidth',12);
    end
% else  
%     cmap2=hot(numel(chans));
%     colornum=1;
%         for i=1:numel(nmat(:,1))
%             if isnan(nmat(i,4))==1
%                 continue
%             end
%                 midiplot3(i)=line([nmat(i,1)+.1 (nmat(i,1)+nmat(i,2))-.1], [nmat(i,4) nmat(i,4)],'LineWidth',8);
%                 if min(chans)==1
%                 midiplot3(i).Color=cmap2(numel(chans)-nmat(i,3)+1,:);
%                 else
%                    midiplot3(i).Color=cmap2(numel(chans)-nmat(i,3),:);
%                 end
%         end
%         colornum=colornum+1;
end
ymin=min(nmat(:,4));
ymax=ymin+max(rads);
yrange=ymax-ymin;
ybuffer=.2*yrange;
%ylim([ymin-ybuffer ymax+ybuffer])
ylim([40 80])
ax=gca;
ax.YAxis.Visible = 'off';
for i=1:numel(r)
    for j=1:numel(r(i).segind)
        if isnan(r(i).key(j))==0
            text(r(i).segind(j)+.25,pitchmean-ybuffer/3,keyname(r(i).key(j),2),'FontSize',16,'HorizontalAlignment','center','VerticalAlignment','middle')
        end
    end
end

%ylim([59.8 60.8])
yticks([])
xlim([.8 nmat(end,1)-.3])
xticks([1:nmat(end-1,1)]+.25)
if numel(pieceTitles)<=10
    xticklabels(pieceTitles)
else
    xticklabels([1:nmat(end-1,1)])
end

xlabel('')
hold off
legend(legendplots,labels,'Box','off');%'Position',[0.75 0.75 0.2 0.2]);

end
