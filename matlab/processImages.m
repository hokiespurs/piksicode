function processImages(imFolder, piksiFolder, trajFolder,outfile)
%% 
PHASECENTERZ = 0.147; % Estimated height of ARP over bottom of antenna
CAMZDOWN = 0.381;     % Measured distance from bottom of gps to camera

%% Get Images
imNames = dirname([imFolder '/*.jpg']);


%% Get MEPs
fname = dirname([piksiFolder '/*-msg.csv']);
[tStart, tshutter] = getPiksiCameraMEP(fname{1});

%% Get Trajectory
fname = dirname([trajFolder '/*.pos']);
[t, lat,lon,height,sde,sdn,sdz,sdtot]=readPOS(fname{1});

%% Lat Lon to UTM
[E,N] = deg2utm(lat,lon);

%% interpolate Trajectory
tsow = secondsofweek(t);

interpE = interp1(tsow,E,tStart);
interpN = interp1(tsow,N,tStart);
interpHeight = interp1(tsow,height,tStart);
interpSde = interp1(tsow,sde,tStart);
interpSdn = interp1(tsow,sdn,tStart);
interpSdz = interp1(tsow,sdz,tStart);
interpSdtot = interp1(tsow,sdtot,tStart);
interplon = interp1(tsow,lon,tStart);
interplat = interp1(tsow,lat,tStart);
%% Apply Corrections to Z
interpHeight = interpHeight - PHASECENTERZ - CAMZDOWN;

%% Write CSV File
fid = fopen(outfile,'w+t');
fprintf(fid, 'Image Name, E, N, Height, sde, sdn, sdz, sdtot, lon, lat\n');
for i=1:numel(imNames)
    [~,justName,ext] = fileparts(imNames{i});
    fprintf(fid,'%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%f,%f\n',...
        [justName ext],interpE(i),interpN(i),interpHeight(i),...
        interpSde(i),interpSdn(i),interpSdz(i),interpSdtot(i),...
        interplon(i), interplat(i));
end
fclose(fid);

end

function [t, lat,lon,height,sde,sdn,sdz,sdtot] = readPOS(fname)
%%
fid = fopen(fname);
dat = fread(fid,'*char');
fclose(fid);

AllLines = strsplit(dat','\n');

noLine = cellfun(@(x) isempty(x),AllLines);
AllLines(noLine)=[];

isStart = cellfun(@(x) strcmp(x(1),'%'),AllLines);

ind = find(isStart,1,'last');

header = AllLines(1:ind);
alldata = AllLines(ind+1:end);


t = getTime(alldata);

lat = getValFromCell(alldata,3,1,' ');
lon = getValFromCell(alldata,4,1,' ');
height = getValFromCell(alldata,5,1,' ');
sde = getValFromCell(alldata,8,1,' ');
sdn = getValFromCell(alldata,9,1,' ');
sdz = getValFromCell(alldata,10,1,' ');
sdtot = sqrt((sde).^2+(sdn).^2+(sdz).^2);


end

function val = getValFromCell(data,colnum,isnum,delim)

if isnum
    val = cellfun(@(x) getNumFromCell(x,colnum,delim),data);
else
    val = cellfun(@(x) getStrFromCell(x,colnum,delim),data,'UniformOutput',false);
end

end

function numval = getNumFromCell(X,colnum,delim)

allvals = strsplit(X,delim);

if numel(allvals)>=colnum
    numval = str2double(allvals{colnum});
else
    numval = nan;
end

end

function strval = getStrFromCell(X,colnum,delim)

allvals = strsplit(X,delim);

if numel(allvals)>=colnum
    strval = allvals{colnum};
else
    strval = nan;
end

end

function t = getTime(alldata)
    t = cellfun(@(x) parseTime(x),alldata);

end

function t = parseTime(X)

allvals = strsplit(X,' ');

if numel(allvals)>1
    tdate = allvals{1};
    ttime = allvals{2};
    t = datenum([tdate ttime],'yyyy/mm/ddHH:MM:ss.fff');
else
    t = nan; 
end


end