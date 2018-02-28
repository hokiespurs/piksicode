function [strid, strlines] = readPiksiMSGCSV(fname)
%% Read Piksi CSV, let other functions parse this output 
fid = fopen(fname,'r');
allchars = fread(fid,'*char');
strlines = strsplit(allchars','\n');
strid = cellfun(@getLineMSGID,strlines,'UniformOutput',false);
fclose(fid);

end

function id = getLineMSGID(x)
dat = strsplit(x,',');
if numel(dat)>3
    id = dat{4};
else
    id = '';
end

end